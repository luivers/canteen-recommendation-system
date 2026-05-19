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

    /** RRF 融合常数。k 越大，头部排名的优势越被抑制，融合越平滑。60 为业界常用经验值。 */
    private static final int RRF_K = 60;
    /** 每个策略召回的候选池大小，远大于最终 limit 以保证融合后仍有充足候选。 */
    private static final int CANDIDATE_POOL = 30;

    private record WeightProfile(double cf, double content, double popular, double context) {}

    private static final WeightProfile W_NEW_USER        = new WeightProfile(0.0, 0.0, 0.7, 0.3);
    private static final WeightProfile W_PREFERENCE      = new WeightProfile(0.0, 0.6, 0.2, 0.2);
    private static final WeightProfile W_EXISTING_ORDER  = new WeightProfile(0.2, 0.3, 0.3, 0.2);
    private static final WeightProfile W_REVIEW_BASED    = new WeightProfile(0.45, 0.30, 0.15, 0.10);

    private enum YouMayLikeMode {
        PREFERENCE_BASED,
        REVIEW_BASED,
        EXISTING_WITHOUT_REVIEW,
        NEW_USER
    }

    private LinkedHashMap<Dish, String> buildYouMayLikeRecommendations(Long userId, int limit) {
        int safeLimit = Math.max(1, Math.min(50, limit));
        WeightProfile w = pickWeights(resolveYouMayLikeMode(userId));

        // 1) 各策略独立召回候选池（权重为 0 时跳过，避免无效计算）
        List<Dish> cfList      = w.cf()      > 0 ? safeRecommend("collaborative", userId, CANDIDATE_POOL) : Collections.emptyList();
        List<Dish> contentList = w.content() > 0 ? safeRecommend("content",       userId, CANDIDATE_POOL) : Collections.emptyList();
        List<Dish> popularList = w.popular() > 0 ? safeRecommend("popular",       userId, CANDIDATE_POOL) : Collections.emptyList();
        List<Dish> contextList = w.context() > 0 ? safeRecommend("context",       userId, CANDIDATE_POOL) : Collections.emptyList();

        // 2) RRF 融合：分数按 weight / (k + rank) 累加，多策略命中自然加权排前
        Map<Long, Double> fused = new HashMap<>();
        Map<Long, Dish> dishById = new HashMap<>();
        Map<Long, String> primarySource = new HashMap<>();
        Map<Long, Double> maxContribution = new HashMap<>();

        accumulate(cfList,      w.cf(),      "cf",      fused, dishById, primarySource, maxContribution);
        accumulate(contentList, w.content(), "content", fused, dishById, primarySource, maxContribution);
        accumulate(popularList, w.popular(), "popular", fused, dishById, primarySource, maxContribution);
        accumulate(contextList, w.context(), "context", fused, dishById, primarySource, maxContribution);

        // 3) 排序并截断
        LinkedHashMap<Dish, String> result = fused.entrySet().stream()
                .sorted(Map.Entry.<Long, Double>comparingByValue().reversed())
                .limit(safeLimit)
                .collect(Collectors.toMap(
                        e -> dishById.get(e.getKey()),
                        e -> reasonOf(primarySource.get(e.getKey())),
                        (a, b) -> a,
                        LinkedHashMap::new));

        // 4) 候选不足时用热门兜底
        if (result.size() < safeLimit) {
            Set<Long> seen = result.keySet().stream()
                    .map(Dish::getId).filter(Objects::nonNull).collect(Collectors.toSet());
            for (Dish d : safeRecommend("popular", userId, safeLimit * 2)) {
                if (result.size() >= safeLimit) break;
                if (isDishRecommendable(d) && seen.add(d.getId())) {
                    result.put(d, "热门推荐");
                }
            }
        }
        return result;
    }

    private void accumulate(List<Dish> ranked, double weight, String tag,
                            Map<Long, Double> fused,
                            Map<Long, Dish> dishById,
                            Map<Long, String> primarySource,
                            Map<Long, Double> maxContribution) {
        if (weight <= 0 || ranked == null || ranked.isEmpty()) {
            return;
        }
        int rank = 1;
        for (Dish d : ranked) {
            if (!isDishRecommendable(d)) {
                continue;
            }
            Long id = d.getId();
            double contribution = weight / (RRF_K + rank);
            fused.merge(id, contribution, (a, b) -> a + b);
            dishById.putIfAbsent(id, d);
            Double prevMax = maxContribution.get(id);
            if (prevMax == null || contribution > prevMax) {
                maxContribution.put(id, contribution);
                primarySource.put(id, tag);
            }
            rank++;
        }
    }

    private WeightProfile pickWeights(YouMayLikeMode mode) {
        return switch (mode) {
            case REVIEW_BASED            -> W_REVIEW_BASED;
            case PREFERENCE_BASED        -> W_PREFERENCE;
            case EXISTING_WITHOUT_REVIEW -> W_EXISTING_ORDER;
            case NEW_USER                -> W_NEW_USER;
        };
    }

    private String reasonOf(String tag) {
        if (tag == null) {
            return "为你推荐";
        }
        return switch (tag) {
            case "cf"      -> "根据与您相似用户的评价推荐";
            case "content" -> "根据您的个人偏好推荐";
            case "context" -> "当前时段/天气推荐";
            default        -> "热门推荐";
        };
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
