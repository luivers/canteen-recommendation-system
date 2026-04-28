package com.school.canteen.service.strategy.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.Review;
import com.school.canteen.entity.ReviewItem;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.ReviewRepository;
import com.school.canteen.service.strategy.RecommendationStrategy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/** 协同过滤推荐策略，基于用户评价相似度进行菜品推荐 */
@Component
public class CollaborativeFilteringStrategy implements RecommendationStrategy {

    private static final Logger logger = LoggerFactory.getLogger(CollaborativeFilteringStrategy.class);

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private RedisTemplate<Object, Object> redisTemplate;

    private static final String REC_CACHE_KEY_PREFIX = "rec:cf:user:";

    @Override
    public List<Dish> recommend(Long userId, int limit) {
        if (userId == null || limit <= 0) {
            return Collections.emptyList();
        }

        String cacheKey = REC_CACHE_KEY_PREFIX + userId;
        try {
            Object cached = redisTemplate.opsForValue().get(cacheKey);
            if (cached instanceof List<?> list && !list.isEmpty() && list.get(0) instanceof Dish) {
                @SuppressWarnings("unchecked")
                List<Dish> cachedRecs = (List<Dish>) list;
                return cachedRecs.stream()
                        .filter(this::isDishAvailable)
                        .limit(limit)
                        .collect(Collectors.toList());
            }
        } catch (Exception e) {
            logger.warn("Redis read error: {}", e.getMessage());
        }

        List<Dish> recommendations = calculateUserBasedCF(userId, limit);

        try {
            if (!recommendations.isEmpty()) {
                redisTemplate.opsForValue().set(cacheKey, recommendations, 1, TimeUnit.HOURS);
            }
        } catch (Exception e) {
            logger.warn("Redis write error: {}", e.getMessage());
        }

        return recommendations;
    }

    private List<Dish> calculateUserBasedCF(Long targetUserId, int limit) {
        List<Review> allReviews = reviewRepository.findAll();
        if (allReviews == null || allReviews.isEmpty()) {
            return Collections.emptyList();
        }

        Map<Long, Map<Long, Double>> userItemRatings = buildUserItemRatings(allReviews);
        if (!userItemRatings.containsKey(targetUserId)) {
            logger.debug("User {} has no usable review history for CF", targetUserId);
            return Collections.emptyList();
        }

        Map<Long, Double> targetRatings = userItemRatings.get(targetUserId);
        Map<Long, Double> userSimilarities = new HashMap<>();

        for (Map.Entry<Long, Map<Long, Double>> entry : userItemRatings.entrySet()) {
            Long otherUserId = entry.getKey();
            if (otherUserId.equals(targetUserId)) {
                continue;
            }
            double similarity = calculateCosineSimilarity(targetRatings, entry.getValue());
            if (similarity > 0) {
                userSimilarities.put(otherUserId, similarity);
            }
        }

        List<Long> similarUsers = userSimilarities.entrySet().stream()
                .sorted(Map.Entry.<Long, Double>comparingByValue().reversed())
                .limit(10)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());

        Map<Long, Double> candidateItems = new HashMap<>();
        for (Long similarUserId : similarUsers) {
            double similarity = userSimilarities.getOrDefault(similarUserId, 0.0);
            Map<Long, Double> otherRatings = userItemRatings.getOrDefault(similarUserId, Collections.emptyMap());

            for (Map.Entry<Long, Double> entry : otherRatings.entrySet()) {
                Long dishId = entry.getKey();
                Double rating = entry.getValue();
                if (dishId == null || rating == null) {
                    continue;
                }
                if (!targetRatings.containsKey(dishId)) {
                    candidateItems.merge(dishId, similarity * rating, Double::sum);
                }
            }
        }

        List<Long> recommendedDishIds;
        if (!candidateItems.isEmpty()) {
            recommendedDishIds = candidateItems.entrySet().stream()
                    .sorted(Map.Entry.<Long, Double>comparingByValue().reversed())
                    .limit(limit)
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());
        } else {
            // 数据较稀疏时，使用“其他用户高评分且我没评过”的全局协同兜底
            recommendedDishIds = buildGlobalCollaborativeFallbackIds(userItemRatings, targetRatings, limit);
        }

        return loadAvailableDishesInOrder(recommendedDishIds, limit);
    }

    private Map<Long, Map<Long, Double>> buildUserItemRatings(List<Review> allReviews) {
        Map<Long, Map<Long, Double>> userItemRatings = new HashMap<>();

        for (Review review : allReviews) {
            if (!isReviewUsable(review)) {
                continue;
            }

            Long userId = review.getUser().getId();
            Map<Long, Double> ratings = userItemRatings.computeIfAbsent(userId, k -> new HashMap<>());

            boolean hasItemRating = false;
            if (review.getItems() != null && !review.getItems().isEmpty()) {
                for (ReviewItem ri : review.getItems()) {
                    if (ri == null || ri.getDish() == null || ri.getDish().getId() == null || ri.getRating() == null) {
                        continue;
                    }
                    mergeDishRating(ratings, ri.getDish().getId(), ri.getRating().doubleValue());
                    hasItemRating = true;
                }
            }

            // 老数据兼容：若没有 review_items，则使用 overallRating 给该订单菜品打分
            if (!hasItemRating && review.getOverallRating() != null && review.getOrder() != null
                    && review.getOrder().getOrderItems() != null) {
                for (OrderItem oi : review.getOrder().getOrderItems()) {
                    if (oi == null || oi.getDish() == null || oi.getDish().getId() == null) {
                        continue;
                    }
                    mergeDishRating(ratings, oi.getDish().getId(), review.getOverallRating());
                }
            }
        }

        return userItemRatings.entrySet().stream()
                .filter(e -> e.getValue() != null && !e.getValue().isEmpty())
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }

    private boolean isReviewUsable(Review review) {
        if (review == null || review.getUser() == null || review.getUser().getId() == null) {
            return false;
        }
        Review.ReviewStatus status = review.getStatus();
        return status == null
                || status == Review.ReviewStatus.NORMAL
                || status == Review.ReviewStatus.WARNING;
    }

    private void mergeDishRating(Map<Long, Double> ratings, Long dishId, Double score) {
        if (dishId == null || score == null) {
            return;
        }
        ratings.merge(dishId, score, (oldVal, newVal) -> (oldVal + newVal) / 2.0);
    }

    private List<Long> buildGlobalCollaborativeFallbackIds(Map<Long, Map<Long, Double>> userItemRatings,
                                                            Map<Long, Double> targetRatings,
                                                            int limit) {
        Map<Long, double[]> dishAgg = new HashMap<>();

        for (Map<Long, Double> ratings : userItemRatings.values()) {
            for (Map.Entry<Long, Double> entry : ratings.entrySet()) {
                Long dishId = entry.getKey();
                Double score = entry.getValue();
                if (dishId == null || score == null || targetRatings.containsKey(dishId)) {
                    continue;
                }
                double[] agg = dishAgg.computeIfAbsent(dishId, k -> new double[]{0.0, 0.0});
                agg[0] += score;
                agg[1] += 1.0;
            }
        }

        return dishAgg.entrySet().stream()
                .sorted((a, b) -> {
                    double aAvg = a.getValue()[1] == 0 ? 0 : a.getValue()[0] / a.getValue()[1];
                    double bAvg = b.getValue()[1] == 0 ? 0 : b.getValue()[0] / b.getValue()[1];
                    if (Double.compare(bAvg, aAvg) != 0) {
                        return Double.compare(bAvg, aAvg);
                    }
                    return Double.compare(b.getValue()[1], a.getValue()[1]);
                })
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private List<Dish> loadAvailableDishesInOrder(List<Long> dishIds, int limit) {
        if (dishIds == null || dishIds.isEmpty()) {
            return Collections.emptyList();
        }

        Map<Long, Dish> byId = dishRepository.findAllById(dishIds).stream()
                .filter(Objects::nonNull)
                .filter(this::isDishAvailable)
                .collect(Collectors.toMap(Dish::getId, d -> d, (a, b) -> a, LinkedHashMap::new));

        List<Dish> ordered = new ArrayList<>();
        Set<Long> seen = new HashSet<>();
        for (Long id : dishIds) {
            if (id == null || !seen.add(id)) {
                continue;
            }
            Dish dish = byId.get(id);
            if (dish != null) {
                ordered.add(dish);
                if (ordered.size() >= limit) {
                    break;
                }
            }
        }
        return ordered;
    }

    private boolean isDishAvailable(Dish dish) {
        return dish != null && dish.getId() != null && dish.getStatus() == Dish.DishStatus.AVAILABLE;
    }

    private double calculateCosineSimilarity(Map<Long, Double> ratings1, Map<Long, Double> ratings2) {
        double dotProduct = 0.0;
        double norm1 = 0.0;
        double norm2 = 0.0;

        Set<Long> commonItems = new HashSet<>(ratings1.keySet());
        commonItems.retainAll(ratings2.keySet());

        if (commonItems.isEmpty()) {
            return 0.0;
        }

        for (Long itemId : ratings1.keySet()) {
            double r = ratings1.get(itemId);
            norm1 += r * r;
        }
        for (Long itemId : ratings2.keySet()) {
            double r = ratings2.get(itemId);
            norm2 += r * r;
        }

        for (Long itemId : commonItems) {
            dotProduct += ratings1.get(itemId) * ratings2.get(itemId);
        }

        if (norm1 == 0 || norm2 == 0) {
            return 0.0;
        }
        return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
    }

    @Override
    public String getStrategyType() {
        return "collaborative";
    }
}
