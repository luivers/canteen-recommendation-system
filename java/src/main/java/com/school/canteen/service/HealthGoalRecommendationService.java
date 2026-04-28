package com.school.canteen.service;

import com.school.canteen.dto.HealthGoalRecommendationResponse;
import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.User;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.OrderItemRepository;
import com.school.canteen.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/** 基于健康目标的菜品推荐服务，分析用户7日营养摄入并生成个性化建议 */
@Service
@RequiredArgsConstructor
public class HealthGoalRecommendationService {

    private static final String CACHE_KEY_PREFIX = "rec:healthgoals:user:";
    private static final String DIRTY_KEY_PREFIX = "rec:healthgoals:dirty:user:";

    private static final BigDecimal ENERGY_BASELINE_KCAL = new BigDecimal("2000");
    private static final BigDecimal PROTEIN_RATIO_MIN = new BigDecimal("0.10");
    private static final BigDecimal PROTEIN_RATIO_MAX = new BigDecimal("0.20");
    private static final BigDecimal FAT_RATIO_MIN = new BigDecimal("0.20");
    private static final BigDecimal FAT_RATIO_MAX = new BigDecimal("0.30");
    private static final BigDecimal CARB_RATIO_MIN = new BigDecimal("0.50");
    private static final BigDecimal CARB_RATIO_MAX = new BigDecimal("0.65");

    private final OrderItemRepository orderItemRepository;
    private final DishRepository dishRepository;
    private final UserRepository userRepository;
    private final RedisTemplate<Object, Object> redisTemplate;

    public void markDirty(Long userId) {
        if (userId == null) return;
        try {
            redisTemplate.opsForValue().set(DIRTY_KEY_PREFIX + userId, "1", 24, TimeUnit.HOURS);
        } catch (Exception ignored) {
        }
    }

    public HealthGoalRecommendationResponse getRecommendations(Long userId, int limit, String refreshToken, List<Long> excludeIds) {
        if (userId == null) {
            return emptyResponse();
        }
        int safeLimit = Math.max(1, Math.min(limit, 12));

        boolean hasExclude = excludeIds != null && !excludeIds.isEmpty();
        String cacheKey = CACHE_KEY_PREFIX + userId + ":" + (refreshToken == null || refreshToken.isBlank() ? "default" : refreshToken.trim());

        boolean dirty = false;
        try {
            dirty = redisTemplate.hasKey(DIRTY_KEY_PREFIX + userId);
        } catch (Exception ignored) {
        }

        if (!dirty && !hasExclude && (refreshToken == null || refreshToken.isBlank())) {
            try {
                Object cached = redisTemplate.opsForValue().get(cacheKey);
                if (cached instanceof HealthGoalRecommendationResponse resp) {
                    return trim(resp, safeLimit);
                }
            } catch (Exception ignored) {
            }
        }

        HealthGoalRecommendationResponse computed = compute(userId, safeLimit, refreshToken, excludeIds);

        try {
            if (!hasExclude && computed != null) {
                redisTemplate.opsForValue().set(cacheKey, computed, 1, TimeUnit.HOURS);
            }
            if (dirty) {
                redisTemplate.delete(DIRTY_KEY_PREFIX + userId);
            }
        } catch (Exception ignored) {
        }

        return computed;
    }

    private HealthGoalRecommendationResponse compute(Long userId, int limit, String refreshToken, List<Long> excludeIds) {
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(7);

        List<OrderItem> items = orderItemRepository.findByUserIdAndCreateTimeBetweenFetchDish(
                userId,
                List.of(Order.OrderStatus.PAID, Order.OrderStatus.PREPARING, Order.OrderStatus.READY, Order.OrderStatus.COMPLETED),
                start,
                end
        );

        NutritionTotals totals = sumNutrition(items);
        HealthGoalRecommendationResponse.Profile7d profile7d = buildProfile(totals);
        List<HealthGoalRecommendationResponse.Goal> goals = buildGoals(profile7d);

        User user = userRepository.findById(userId).orElse(null);
        List<HealthGoalRecommendationResponse.RecommendedDish> recommendations = recommendDishes(user, goals, limit, refreshToken, excludeIds);

        HealthGoalRecommendationResponse resp = new HealthGoalRecommendationResponse();
        resp.setProfile7d(profile7d);
        resp.setGoals(goals);
        resp.setRecommendations(recommendations);
        resp.setGeneratedAt(LocalDateTime.now());
        return resp;
    }

    private List<HealthGoalRecommendationResponse.RecommendedDish> recommendDishes(
            User user,
            List<HealthGoalRecommendationResponse.Goal> goals,
            int limit,
            String refreshToken,
            List<Long> excludeIds
    ) {
        List<Dish> all = dishRepository.findByStatus(Dish.DishStatus.AVAILABLE);
        if (all == null || all.isEmpty()) return List.of();

        Set<Long> exclude = excludeIds == null ? Set.of() : excludeIds.stream().filter(Objects::nonNull).collect(Collectors.toSet());
        int candidateCap = Math.min(all.size(), 500);
        List<Dish> candidates = pickCandidates(all, candidateCap, refreshToken);

        List<ScoredDish> scored = new ArrayList<>();
        for (Dish d : candidates) {
            if (d == null || d.getId() == null) continue;
            if (exclude.contains(d.getId())) continue;

            double nutrition = scoreNutrition(d, goals);
            double taste = scoreTaste(d, user);
            double fit = 0.8 * nutrition + 0.2 * taste;
            int fitPercent = (int) Math.round(clamp01(fit) * 100);
            if (fitPercent < 80) continue;

            int nutritionScore = (int) Math.round(clamp01(nutrition) * 100);
            scored.add(new ScoredDish(d, nutritionScore, fitPercent));
        }

        scored.sort(Comparator.comparingInt(ScoredDish::fitPercent).reversed().thenComparingInt(ScoredDish::nutritionScore).reversed());

        List<HealthGoalRecommendationResponse.RecommendedDish> out = new ArrayList<>();
        for (ScoredDish sd : scored) {
            if (out.size() >= limit) break;
            out.add(toRecommended(sd.dish(), sd.nutritionScore(), sd.fitPercent()));
        }
        return out;
    }

    private List<Dish> pickCandidates(List<Dish> all, int cap, String refreshToken) {
        List<Dish> pool = new ArrayList<>(all);
        long seed = refreshToken == null || refreshToken.isBlank() ? System.nanoTime() : refreshToken.hashCode();
        Collections.shuffle(pool, new Random(seed));
        if (pool.size() > cap) {
            return pool.subList(0, cap);
        }
        return pool;
    }

    private double scoreNutrition(Dish d, List<HealthGoalRecommendationResponse.Goal> goals) {
        if (goals == null || goals.isEmpty()) {
            return 0.5;
        }
        double total = 0;
        for (HealthGoalRecommendationResponse.Goal g : goals) {
            total += scoreByGoal(d, g.getCode());
        }
        return clamp01(total / goals.size());
    }

    private double scoreByGoal(Dish d, String goalCode) {
        int calories = d.getCalories() == null ? 0 : d.getCalories();
        double protein = toDouble(d.getProtein());
        double fat = toDouble(d.getFat());
        double carb = toDouble(d.getCarbohydrate());

        return switch (goalCode) {
            case "CONTROL_CALORIES" -> scoreLowerBetter(calories, 700, 300);
            case "HIGH_PROTEIN" -> scoreHigherBetter(protein, 20);
            case "LOW_FAT" -> scoreLowerBetter(fat, 20, 10);
            case "CONTROL_CARBS" -> scoreLowerBetter(carb, 70, 45);
            default -> 0.5;
        };
    }

    private double scoreTaste(Dish d, User user) {
        if (user == null) return 0.5;
        List<String> tags = d.getTasteTags() == null ? List.of() : d.getTasteTags();
        int spicy = user.getSpicinessLevel() == null ? 3 : user.getSpicinessLevel();
        int sweet = user.getSweetnessLevel() == null ? 3 : user.getSweetnessLevel();
        String restrictions = user.getDietaryRestrictions() == null ? "" : user.getDietaryRestrictions();

        double score = 0.5;

        boolean dishSpicy = tags.stream().anyMatch(t -> t != null && t.contains("辣"));
        boolean dishSweet = tags.stream().anyMatch(t -> t != null && t.contains("甜"));

        if (restrictions.contains("不吃辣") || restrictions.contains("忌辣") || restrictions.contains("少辣")) {
            if (dishSpicy) score -= 0.4;
        } else {
            if (spicy >= 4 && dishSpicy) score += 0.25;
            if (spicy <= 2 && dishSpicy) score -= 0.2;
        }

        if (sweet >= 4 && dishSweet) score += 0.15;
        if (sweet <= 2 && dishSweet) score -= 0.15;

        return clamp01(score);
    }

    private HealthGoalRecommendationResponse.RecommendedDish toRecommended(Dish d, int nutritionScore, int fitPercent) {
        HealthGoalRecommendationResponse.RecommendedDish rd = new HealthGoalRecommendationResponse.RecommendedDish();
        rd.setId(d.getId());
        rd.setName(d.getName());
        rd.setImageUrl(d.getImageUrl());
        rd.setPrice(d.getPrice());
        rd.setCalories(d.getCalories());
        rd.setProtein(d.getProtein());
        rd.setFat(d.getFat());
        rd.setCarbohydrate(d.getCarbohydrate());
        rd.setNutritionScore(nutritionScore);
        rd.setFitPercent(fitPercent);
        rd.setHealthTags(buildHealthTags(d));
        
        rd.setDescription(d.getDescription());
        rd.setCanteenName(d.getCanteenName());
        rd.setWindowName(d.getWindowName());
        if (d.getDishCategory() != null) {
            rd.setCategory(d.getDishCategory().name());
        }
        return rd;
    }

    private List<String> buildHealthTags(Dish d) {
        List<String> tags = new ArrayList<>();
        Integer calories = d.getCalories();
        BigDecimal protein = d.getProtein();
        BigDecimal fat = d.getFat();
        BigDecimal carb = d.getCarbohydrate();

        if (calories != null && calories <= 400) tags.add("低热量");
        if (protein != null && protein.compareTo(new BigDecimal("20")) >= 0) tags.add("高蛋白");
        if (fat != null && fat.compareTo(new BigDecimal("10")) <= 0) tags.add("低脂");
        if (carb != null && carb.compareTo(new BigDecimal("50")) <= 0) tags.add("控碳");

        if (tags.size() > 3) {
            return tags.subList(0, 3);
        }
        return tags;
    }

    private NutritionTotals sumNutrition(List<OrderItem> items) {
        BigDecimal calories = BigDecimal.ZERO;
        BigDecimal protein = BigDecimal.ZERO;
        BigDecimal fat = BigDecimal.ZERO;
        BigDecimal carb = BigDecimal.ZERO;
        if (items == null) return new NutritionTotals(calories, protein, fat, carb);
        for (OrderItem item : items) {
            if (item == null || item.getDish() == null) continue;
            int qty = item.getQuantity() == null ? 0 : item.getQuantity();
            if (qty <= 0) continue;
            Dish d = item.getDish();

            calories = calories.add(BigDecimal.valueOf((long) safeInt(d.getCalories()) * qty));
            protein = protein.add(safeDecimal(d.getProtein()).multiply(BigDecimal.valueOf(qty)));
            fat = fat.add(safeDecimal(d.getFat()).multiply(BigDecimal.valueOf(qty)));
            carb = carb.add(safeDecimal(d.getCarbohydrate()).multiply(BigDecimal.valueOf(qty)));
        }
        return new NutritionTotals(calories, protein, fat, carb);
    }

    private HealthGoalRecommendationResponse.Profile7d buildProfile(NutritionTotals totals) {
        HealthGoalRecommendationResponse.Profile7d p = new HealthGoalRecommendationResponse.Profile7d();
        BigDecimal days = new BigDecimal("7");

        p.setCaloriesTotal(totals.calories);
        p.setProteinTotal(totals.protein);
        p.setFatTotal(totals.fat);
        p.setCarbohydrateTotal(totals.carb);

        p.setCaloriesDailyAvg(div(totals.calories, days));
        p.setProteinDailyAvg(div(totals.protein, days));
        p.setFatDailyAvg(div(totals.fat, days));
        p.setCarbohydrateDailyAvg(div(totals.carb, days));

        BigDecimal proteinKcal = totals.protein.multiply(new BigDecimal("4"));
        BigDecimal fatKcal = totals.fat.multiply(new BigDecimal("9"));
        BigDecimal carbKcal = totals.carb.multiply(new BigDecimal("4"));
        BigDecimal macroKcalTotal = proteinKcal.add(fatKcal).add(carbKcal);

        if (macroKcalTotal.compareTo(BigDecimal.ZERO) > 0) {
            p.setProteinEnergyRatio(div(proteinKcal, macroKcalTotal));
            p.setFatEnergyRatio(div(fatKcal, macroKcalTotal));
            p.setCarbohydrateEnergyRatio(div(carbKcal, macroKcalTotal));
        } else {
            p.setProteinEnergyRatio(BigDecimal.ZERO);
            p.setFatEnergyRatio(BigDecimal.ZERO);
            p.setCarbohydrateEnergyRatio(BigDecimal.ZERO);
        }
        return p;
    }

    private List<HealthGoalRecommendationResponse.Goal> buildGoals(HealthGoalRecommendationResponse.Profile7d profile) {
        if (profile == null) return List.of();

        BigDecimal proteinR = safeDecimal(profile.getProteinEnergyRatio());
        BigDecimal fatR = safeDecimal(profile.getFatEnergyRatio());
        BigDecimal carbR = safeDecimal(profile.getCarbohydrateEnergyRatio());
        BigDecimal caloriesAvg = safeDecimal(profile.getCaloriesDailyAvg());

        List<HealthGoalRecommendationResponse.Goal> goals = new ArrayList<>();

        goals.add(goalRatio("HIGH_PROTEIN", "高蛋白补充", "蛋白质供能占比偏低，建议适度提高优质蛋白摄入。", proteinR, PROTEIN_RATIO_MIN, PROTEIN_RATIO_MAX));
        goals.add(goalRatio("LOW_FAT", "低脂目标", "脂肪供能占比偏高，建议减少高油脂菜品频率。", fatR, FAT_RATIO_MIN, FAT_RATIO_MAX));
        goals.add(goalRatio("CONTROL_CARBS", "控碳目标", "碳水供能占比偏高，建议控制精制碳水摄入。", carbR, CARB_RATIO_MIN, CARB_RATIO_MAX));

        HealthGoalRecommendationResponse.Goal caloriesGoal = new HealthGoalRecommendationResponse.Goal();
        caloriesGoal.setCode("CONTROL_CALORIES");
        caloriesGoal.setTitle("控能目标");
        caloriesGoal.setDescription("最近7天日均能量偏高时，建议选择更轻盈的菜品组合。");
        caloriesGoal.setCurrentRatio(caloriesAvg);
        caloriesGoal.setTargetMinRatio(ENERGY_BASELINE_KCAL);
        caloriesGoal.setTargetMaxRatio(ENERGY_BASELINE_KCAL);
        caloriesGoal.setDeviation(caloriesAvg.subtract(ENERGY_BASELINE_KCAL).abs());
        goals.add(caloriesGoal);

        goals.forEach(g -> {
            if (g.getDeviation() == null) g.setDeviation(BigDecimal.ZERO);
        });
        goals.sort(Comparator.comparing(HealthGoalRecommendationResponse.Goal::getDeviation).reversed());

        List<HealthGoalRecommendationResponse.Goal> top = goals.stream().limit(3).collect(Collectors.toList());
        return top;
    }

    private HealthGoalRecommendationResponse.Goal goalRatio(
            String code,
            String title,
            String desc,
            BigDecimal current,
            BigDecimal min,
            BigDecimal max
    ) {
        HealthGoalRecommendationResponse.Goal g = new HealthGoalRecommendationResponse.Goal();
        g.setCode(code);
        g.setTitle(title);
        g.setDescription(desc);
        g.setCurrentRatio(current);
        g.setTargetMinRatio(min);
        g.setTargetMaxRatio(max);
        g.setDeviation(ratioDeviation(current, min, max));
        return g;
    }

    private BigDecimal ratioDeviation(BigDecimal current, BigDecimal min, BigDecimal max) {
        BigDecimal c = safeDecimal(current);
        if (c.compareTo(min) < 0) return min.subtract(c);
        if (c.compareTo(max) > 0) return c.subtract(max);
        return BigDecimal.ZERO;
    }

    private HealthGoalRecommendationResponse emptyResponse() {
        HealthGoalRecommendationResponse resp = new HealthGoalRecommendationResponse();
        resp.setProfile7d(new HealthGoalRecommendationResponse.Profile7d());
        resp.setGoals(List.of());
        resp.setRecommendations(List.of());
        resp.setGeneratedAt(LocalDateTime.now());
        return resp;
    }

    private HealthGoalRecommendationResponse trim(HealthGoalRecommendationResponse resp, int limit) {
        if (resp == null) return emptyResponse();
        List<HealthGoalRecommendationResponse.RecommendedDish> list = resp.getRecommendations();
        if (list != null && list.size() > limit) {
            resp.setRecommendations(list.subList(0, limit));
        }
        return resp;
    }

    private static BigDecimal safeDecimal(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }

    private static int safeInt(Integer v) {
        return v == null ? 0 : v;
    }

    private static BigDecimal div(BigDecimal a, BigDecimal b) {
        if (a == null || b == null || b.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;
        return a.divide(b, 6, RoundingMode.HALF_UP);
    }

    private static double clamp01(double v) {
        if (v < 0) return 0;
        if (v > 1) return 1;
        return v;
    }

    private static double scoreHigherBetter(double value, double target) {
        if (target <= 0) return 0.5;
        return clamp01(value / target);
    }

    private static double scoreLowerBetter(double value, double maxGood, double ideal) {
        if (value <= ideal) return 1.0;
        if (value >= maxGood) return 0.0;
        return clamp01((maxGood - value) / (maxGood - ideal));
    }

    private static double scoreLowerBetter(int value, int maxGood, int ideal) {
        if (value <= ideal) return 1.0;
        if (value >= maxGood) return 0.0;
        return clamp01((double) (maxGood - value) / (double) (maxGood - ideal));
    }

    private static double toDouble(BigDecimal v) {
        return v == null ? 0.0 : v.doubleValue();
    }

    private record NutritionTotals(BigDecimal calories, BigDecimal protein, BigDecimal fat, BigDecimal carb) {
        NutritionTotals() {
            this(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
        }
    }

    private record ScoredDish(Dish dish, int nutritionScore, int fitPercent) {
    }
}
