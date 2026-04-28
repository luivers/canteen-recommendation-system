package com.school.canteen.service.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.User;
import com.school.canteen.entity.UserProfile;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.repository.ReviewRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.repository.UserProfileRepository;
import com.school.canteen.service.RecommendationService;
import com.school.canteen.service.strategy.RecommendationStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.Cacheable;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class RecommendationServiceImpl implements RecommendationService {

    private static final Logger log = LoggerFactory.getLogger(RecommendationServiceImpl.class);

    private final Map<String, RecommendationStrategy> strategies;
    
    @Autowired
    private DishRepository dishRepository;
    
    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserProfileRepository userProfileRepository;

    public RecommendationServiceImpl(List<RecommendationStrategy> strategyList) {
        this.strategies = strategyList.stream()
                .collect(Collectors.toMap(RecommendationStrategy::getStrategyType, s -> s));
    }

    @Override
    public List<Dish> getPersonalizedRecommendations(Long userId, int limit) {
        if (userId == null || limit <= 0) {
            return Collections.emptyList();
        }
        LinkedHashMap<Dish, String> merged = buildYouMayLikeRecommendations(userId, limit);
        return new ArrayList<>(merged.keySet()).stream().limit(limit).collect(Collectors.toList());
    }

    @Override
    public List<Dish> getRecommendationsByStrategy(String strategyType, Long userId, int limit) {
        RecommendationStrategy strategy = strategies.get(strategyType);
        if (strategy == null) {
            return Collections.emptyList();
        }
        try {
            return strategy.recommend(userId, limit);
        } catch (RuntimeException ignored) {
            return Collections.emptyList();
        }
    }

    @Override
    public List<Dish> getHealthRecommendations(Long userId, String goal, int limit) {
        if (limit <= 0) {
            return Collections.emptyList();
        }
        if ("weight_loss".equalsIgnoreCase(goal)) {
            return dishRepository.findByCaloriesLessThan(500, PageRequest.of(0, limit));
        }
        if ("muscle_gain".equalsIgnoreCase(goal)) {
            return dishRepository.findByProteinGreaterThan(new BigDecimal("20"), PageRequest.of(0, limit));
        }
        return Collections.emptyList();
    }

    @Override
    public List<Dish> getDiscoveryRecommendations(Long userId, int limit) {
        if (userId == null || limit <= 0) {
            return Collections.emptyList();
        }

        List<Long> orderedDishIds = orderRepository.findOrderedDishIdsByUserId(userId);
        if (orderedDishIds == null || orderedDishIds.isEmpty()) {
            return getRecommendationsByStrategy("popular", userId, limit);
        }

        List<Dish> recs = dishRepository.findByIdNotIn(orderedDishIds, PageRequest.of(0, limit));
        if (recs.size() >= limit) {
            return recs;
        }

        List<Dish> fallback = getRecommendationsByStrategy("popular", userId, limit);
        Set<Long> existing = recs.stream().map(Dish::getId).filter(Objects::nonNull).collect(Collectors.toSet());
        for (Dish d : fallback) {
            if (d == null || d.getId() == null || existing.contains(d.getId())) {
                continue;
            }
            recs.add(d);
            existing.add(d.getId());
            if (recs.size() >= limit) {
                break;
            }
        }
        return recs;
    }

    @Override
    public Map<String, List<Dish>> getComprehensiveRecommendations(Long userId) {
        Map<String, List<Dish>> result = new HashMap<>();
        
        result.put("personalized", getPersonalizedRecommendations(userId, 5));
        result.put("popular", getRecommendationsByStrategy("popular", userId, 5));
        
        // Discovery
        result.put("discovery", getDiscoveryRecommendations(userId, 5));
        
        // Context (e.g. "Lunch Special") - Placeholder
        // result.put("context", getRecommendationsByStrategy("context", userId, 5));
        
        return result;
    }
    
    @Override
    @Cacheable(value = "recommendations", key = "'today_new_' + #limit")
    public List<Dish> getTodayNewDishes(int limit) {
        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end = today.plusDays(1).atStartOfDay();
        return dishRepository.findTodayNewDishes(
                start,
                end,
                com.school.canteen.entity.Dish.DishStatus.AVAILABLE,
                PageRequest.of(0, Math.max(1, Math.min(50, limit)))
        );
    }

    @Override
    public List<Dish> getTodayPersonalizedHotDishes(Long userId, int limit) {
        int safeLimit = Math.max(1, Math.min(50, limit));
        List<Dish> popular = safeRecommend("popular", userId, Math.max(safeLimit * 4, safeLimit + 12));
        if (userId == null || !hasPreferenceProfile(userId)) {
            return popular.stream()
                    .filter(this::isDishRecommendable)
                    .limit(safeLimit)
                    .collect(Collectors.toList());
        }

        List<Dish> content = safeRecommend("content", userId, Math.max(safeLimit * 4, safeLimit + 12));
        Set<Long> preferredIds = content.stream()
                .filter(this::isDishRecommendable)
                .map(Dish::getId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        if (preferredIds.isEmpty()) {
            return popular.stream()
                    .filter(this::isDishRecommendable)
                    .limit(safeLimit)
                    .collect(Collectors.toList());
        }

        List<Dish> result = new ArrayList<>();
        Set<Long> seenIds = new HashSet<>();

        for (Dish dish : popular) {
            if (result.size() >= safeLimit) {
                break;
            }
            if (!isDishRecommendable(dish) || !preferredIds.contains(dish.getId()) || !seenIds.add(dish.getId())) {
                continue;
            }
            result.add(dish);
        }

        for (Dish dish : popular) {
            if (result.size() >= safeLimit) {
                break;
            }
            if (!isDishRecommendable(dish) || !seenIds.add(dish.getId())) {
                continue;
            }
            result.add(dish);
        }

        return result;
    }
    
    @Override
    public List<Map<String, Object>> getPersonalizedRecommendationsWithReason(Long userId, int limit) {
        if (userId == null || limit <= 0) {
            return List.of();
        }

        LinkedHashMap<Dish, String> merged = buildYouMayLikeRecommendations(userId, limit);
        List<Map<String, Object>> result = new ArrayList<>();

        for (Map.Entry<Dish, String> entry : merged.entrySet().stream().limit(limit).collect(Collectors.toList())) {
            Dish d = entry.getKey();
            String reason = entry.getValue();

            Map<String, Object> m = new HashMap<>();
            m.put("id", d.getId());
            m.put("name", d.getName());
            m.put("price", d.getPrice());
            m.put("imageUrl", d.getImageUrl());
            m.put("image", d.getImageUrl());
            m.put("tasteTags", d.getTasteTags());
            m.put("dishCategory", d.getDishCategory());
            m.put("status", d.getStatus() != null ? d.getStatus().name() : null);
            m.put("available", d.getStatus() == Dish.DishStatus.AVAILABLE);
            m.put("averageRating", d.getAverageRating());
            m.put("ratingCount", d.getRatingCount());
            Integer sales = orderRepository.getDishTotalSales(d.getId());
            m.put("sales", sales == null ? 0 : sales);
            m.put("canteenName", d.getCanteenName());
            m.put("windowName", d.getWindowName());
            m.put("windowLocation", d.getWindowLocation());
            m.put("description", d.getDescription());
            m.put("calories", d.getCalories());
            m.put("protein", d.getProtein());
            m.put("fat", d.getFat());
            m.put("carbohydrate", d.getCarbohydrate());
            m.put("isPromotion", d.getIsPromotion());
            m.put("promotionPrice", d.getPromotionPrice());
            m.put("promotionType", d.getPromotionType());
            m.put("promotionStart", d.getPromotionStart());
            m.put("promotionEnd", d.getPromotionEnd());
            m.put("reason", reason);
            m.put("recommendSource", reason);
            result.add(m);
        }

        return result;
    }

    private static final int CF_TARGET_COUNT = 2;
    private static final int CONTENT_TARGET_COUNT = 2;

    private enum YouMayLikeMode {
        PREFERENCE_BASED,
        REVIEW_BASED,
        EXISTING_WITHOUT_REVIEW,
        NEW_USER
    }

    private LinkedHashMap<Dish, String> buildYouMayLikeRecommendations(Long userId, int limit) {
        int safeLimit = Math.max(1, Math.min(50, limit));
        YouMayLikeMode mode = resolveYouMayLikeMode(userId);

        int cfTarget = 0;
        int contentTarget = 0;

        if (mode == YouMayLikeMode.PREFERENCE_BASED) {
            // 用户明确设置了偏好时，优先按偏好推荐，保证“猜你喜欢”实时反映偏好变化
            contentTarget = safeLimit;
        } else if (mode == YouMayLikeMode.REVIEW_BASED) {
            cfTarget = Math.min(CF_TARGET_COUNT, safeLimit);
            contentTarget = Math.min(CONTENT_TARGET_COUNT, Math.max(0, safeLimit - cfTarget));
        } else if (mode == YouMayLikeMode.EXISTING_WITHOUT_REVIEW) {
            contentTarget = Math.min(CONTENT_TARGET_COUNT, safeLimit);
        }

        LinkedHashMap<Dish, String> merged = new LinkedHashMap<>();
        Set<Long> seenIds = new HashSet<>();

        if (cfTarget > 0) {
            List<Dish> cf = safeRecommend("collaborative", userId, Math.max(cfTarget * 4, cfTarget + 8));
            appendFromSource(merged, seenIds, cf, cfTarget, "根据与您相似用户的评价推荐");
        }

        if (contentTarget > 0) {
            List<Dish> content = safeRecommend("content", userId, Math.max(contentTarget * 4, contentTarget + 8));
            appendFromSource(merged, seenIds, content, contentTarget, "根据您的个人偏好推荐");
        }

        int need = safeLimit - merged.size();
        if (need > 0) {
            List<Dish> popular = safeRecommend("popular", userId, Math.max(need * 4, safeLimit + 12));
            appendFromSource(merged, seenIds, popular, need, "热门推荐");
        }

        return merged;
    }

    private List<Dish> safeRecommend(String strategyType, Long userId, int limit) {
        if (limit <= 0) {
            return Collections.emptyList();
        }
        RecommendationStrategy strategy = strategies.get(strategyType);
        if (strategy == null) {
            return Collections.emptyList();
        }
        try {
            List<Dish> dishes = strategy.recommend(userId, limit);
            return dishes == null ? Collections.emptyList() : dishes;
        } catch (RuntimeException e) {
            log.warn("{} recommendation failed for user {}: {}", strategyType, userId, e.getMessage());
            return Collections.emptyList();
        }
    }

    private void appendFromSource(LinkedHashMap<Dish, String> merged,
                                  Set<Long> seenIds,
                                  List<Dish> source,
                                  int maxAdd,
                                  String reason) {
        if (maxAdd <= 0 || source == null || source.isEmpty()) {
            return;
        }

        int added = 0;
        for (Dish dish : source) {
            if (added >= maxAdd) {
                break;
            }
            if (!isDishRecommendable(dish)) {
                continue;
            }
            Long dishId = dish.getId();
            if (!seenIds.add(dishId)) {
                continue;
            }
            merged.put(dish, reason);
            added++;
        }
    }

    private boolean isDishRecommendable(Dish dish) {
        return dish != null
                && dish.getId() != null
                && dish.getStatus() == Dish.DishStatus.AVAILABLE;
    }

    private YouMayLikeMode resolveYouMayLikeMode(Long userId) {
        boolean hasReviews = hasReviewHistory(userId);
        boolean hasOrders = hasOrderHistory(userId);
        boolean hasPreferences = hasPreferenceProfile(userId);

        // 只要用户已有评价历史，就固定走“协同过滤 + 个人偏好”的混合推荐配比
        if (hasReviews) {
            return YouMayLikeMode.REVIEW_BASED;
        }
        if (hasPreferences) {
            return YouMayLikeMode.PREFERENCE_BASED;
        }
        if (!hasOrders) {
            return YouMayLikeMode.NEW_USER;
        }
        return YouMayLikeMode.EXISTING_WITHOUT_REVIEW;
    }

    private boolean hasOrderHistory(Long userId) {
        try {
            return orderRepository.existsByUser_Id(userId);
        } catch (Exception e) {
            log.warn("check order history failed for user {}: {}", userId, e.getMessage());
            return false;
        }
    }

    private boolean hasReviewHistory(Long userId) {
        try {
            List<?> reviews = reviewRepository.findByUserId(userId);
            return reviews != null && !reviews.isEmpty();
        } catch (Exception e) {
            log.warn("check review history failed for user {}: {}", userId, e.getMessage());
            return false;
        }
    }

    private boolean hasPreferenceProfile(Long userId) {
        try {
            User user = userRepository.findById(userId).orElse(null);
            if (user == null) {
                return false;
            }
            if (isNonDefaultLevel(user.getSpicinessLevel()) || isNonDefaultLevel(user.getSweetnessLevel())) {
                return true;
            }
            if (hasText(user.getDietaryRestrictions())) {
                return true;
            }
            if (user.getDietaryTags() != null && !user.getDietaryTags().isEmpty()) {
                return true;
            }

            UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
            if (profile == null) {
                return false;
            }
            if (hasText(profile.getFlavorPreferences())
                    || hasText(profile.getDietaryRestrictions())
                    || hasText(profile.getAllergies())) {
                return true;
            }
            if (Boolean.TRUE.equals(profile.getIsHalal()) || Boolean.TRUE.equals(profile.getIsVegetarian())) {
                return true;
            }
            return profile.getSpiceTolerance() != null && profile.getSpiceTolerance() > 0;
        } catch (Exception e) {
            log.warn("check preference profile failed for user {}: {}", userId, e.getMessage());
            return false;
        }
    }

    private boolean isNonDefaultLevel(Integer level) {
        return level != null && level != 3;
    }

    private boolean hasText(String text) {
        return text != null && !text.trim().isEmpty();
    }
}
