package com.school.canteen.service.strategy.impl;

import com.school.canteen.entity.Dish;
import com.school.canteen.entity.User;
import com.school.canteen.entity.UserProfile;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.repository.UserProfileRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.strategy.RecommendationStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.HashMap;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/** 基于内容的推荐策略，根据用户口味偏好和历史点单行为匹配菜品特征 */
@Component
public class ContentBasedStrategy implements RecommendationStrategy {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DishRepository dishRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserProfileRepository userProfileRepository;

    @Override
    public List<Dish> recommend(Long userId, int limit) {
        if (userId == null || limit <= 0) {
            return Collections.emptyList();
        }

        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return Collections.emptyList();
        }

        Set<String> allPreferences = new LinkedHashSet<>();
        Set<Long> orderedDishIds = new HashSet<>();

        List<Long> ordered = orderRepository.findOrderedDishIdsByUserId(userId);
        if (ordered != null && !ordered.isEmpty()) {
            orderedDishIds.addAll(
                    ordered.stream()
                            .filter(Objects::nonNull)
                            .collect(Collectors.toSet())
            );
        }

        UserProfile profile = userProfileRepository.findByUserId(userId).orElse(null);
        collectExplicitPreferences(user, profile, allPreferences);
        PreferenceConstraint explicitConstraint = buildPreferenceConstraint(allPreferences);
        Set<String> preferenceKeywords = normalizePreferenceKeywords(allPreferences, user, profile);

        List<Dish> recommendations = new ArrayList<>();

        // 1) 优先按当前偏好标签推荐，确保偏好变更后结果即时体现
        if (!preferenceKeywords.isEmpty()) {
            List<Dish> ranked = rankByPreferences(preferenceKeywords, explicitConstraint);
            appendPreferenceMatchedRecommendations(recommendations, ranked, orderedDishIds, limit);
        }

        // 2) 当缺少显式偏好时，才使用历史点单推断偏好
        if (recommendations.size() < limit && preferenceKeywords.isEmpty() && !orderedDishIds.isEmpty()) {
            List<Dish> orderedDishes = dishRepository.findAllById(new ArrayList<>(orderedDishIds));
            for (Dish dish : orderedDishes) {
                if (dish != null && dish.getTasteTags() != null) {
                    for (String tag : dish.getTasteTags()) {
                        if (tag != null && !tag.trim().isEmpty()) {
                            allPreferences.add(tag.trim());
                        }
                    }
                }
            }

            if (!allPreferences.isEmpty()) {
                List<Dish> matched = dishRepository.findByTasteTagsIn(allPreferences);
                if (matched != null && !matched.isEmpty()) {
                    recommendations.addAll(
                            matched.stream()
                                    .filter(d -> d != null && d.getId() != null)
                                    .filter(d -> d.getStatus() == Dish.DishStatus.AVAILABLE)
                                    .filter(d -> !orderedDishIds.contains(d.getId()))
                                    .collect(Collectors.toList())
                    );
                }
            }
        }

        // 3) 标签不足时，用常点品类补齐
        if (recommendations.size() < limit && preferenceKeywords.isEmpty() && !orderedDishIds.isEmpty()) {
            Set<Dish.DishCategory> preferredCategories = dishRepository.findAllById(new ArrayList<>(orderedDishIds)).stream()
                    .map(Dish::getDishCategory)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toSet());

            if (!preferredCategories.isEmpty()) {
                List<Dish> available = dishRepository.findByStatus(Dish.DishStatus.AVAILABLE);
                recommendations.addAll(
                        available.stream()
                                .filter(d -> d != null && d.getId() != null)
                                .filter(d -> !orderedDishIds.contains(d.getId()))
                                .filter(d -> preferredCategories.contains(d.getDishCategory()))
                                .collect(Collectors.toList())
                );
            }
        }

        return recommendations.stream()
                .filter(Objects::nonNull)
                .filter(d -> d.getStatus() == Dish.DishStatus.AVAILABLE)
                .distinct()
                .limit(limit)
                .collect(Collectors.toList());
    }

    private void collectExplicitPreferences(User user, UserProfile profile, Set<String> target) {
        if (target == null) {
            return;
        }

        if (profile != null) {
            addCsvValues(profile.getFlavorPreferences(), target);
            addCsvValues(profile.getDietaryRestrictions(), target);

            if (Boolean.TRUE.equals(profile.getIsHalal())) {
                target.add("清真");
            }
            if (Boolean.TRUE.equals(profile.getIsVegetarian())) {
                target.add("素食");
            }
        }

        addCsvValues(user.getDietaryRestrictions(), target);
        if (user.getDietaryTags() != null) {
            target.addAll(
                    user.getDietaryTags().stream()
                            .filter(Objects::nonNull)
                            .map(String::trim)
                            .filter(s -> !s.isEmpty())
                            .collect(Collectors.toSet())
            );
        }
    }

    private void addCsvValues(String csv, Set<String> target) {
        if (csv == null || csv.trim().isEmpty() || target == null) {
            return;
        }
        String[] parts = csv.split(",");
        for (String part : parts) {
            if (part == null) {
                continue;
            }
            String p = part.trim();
            if (!p.isEmpty()) {
                target.add(p);
            }
        }
    }

    private Set<String> normalizePreferenceKeywords(Set<String> rawPreferences, User user, UserProfile profile) {
        Set<String> out = new LinkedHashSet<>();
        if (rawPreferences != null) {
            for (String p : rawPreferences) {
                if (p == null || p.trim().isEmpty()) {
                    continue;
                }
                String normalized = p.trim();
                out.add(normalized);
                expandKeywordByRule(normalized, out);
            }
        }

        Integer spiceLevel = profile != null && profile.getSpiceTolerance() != null
                ? profile.getSpiceTolerance()
                : user.getSpicinessLevel();
        Integer sweetLevel = user.getSweetnessLevel();

        boolean hasExplicitNoSpicy = containsAnyKeyword(rawPreferences, "不辣", "无辣", "清淡");
        if (spiceLevel != null && !hasExplicitNoSpicy) {
            addSpiceLevelKeywords(spiceLevel, out);
        }
        if (sweetLevel != null) {
            addSweetLevelKeywords(sweetLevel, out);
        }

        return out;
    }

    private void expandKeywordByRule(String keyword, Set<String> target) {
        if (keyword == null || keyword.isBlank() || target == null) {
            return;
        }
        String k = keyword.trim();

        if (k.startsWith("辣度:")) {
            Integer level = parsePreferenceLevel(k.substring(3));
            if (level != null) {
                addSpiceLevelKeywords(level, target);
            }
        }
        if (k.startsWith("甜度:")) {
            Integer level = parsePreferenceLevel(k.substring(3));
            if (level != null) {
                addSweetLevelKeywords(level, target);
            }
        }

        if (k.contains("川菜") || k.contains("湘菜") || k.contains("麻辣")) {
            target.add("辣");
            target.add("重口");
            target.add("重口味");
        }
        if (k.contains("粤菜") || k.contains("苏菜") || k.contains("浙菜") || k.contains("闽菜")
                || k.contains("清淡") || k.contains("健康") || k.contains("低脂") || k.contains("低糖")) {
            target.add("清淡");
            target.add("鲜");
        }
        if (k.contains("鲁菜") || k.contains("东北菜") || k.contains("西北菜") || k.contains("家常")) {
            target.add("咸");
            target.add("重口");
        }

        if (k.contains("甜")) target.add("甜");
        if (k.contains("酸")) target.add("酸");
        if (k.contains("咸")) target.add("咸");
        if (k.contains("辣")) target.add("辣");
    }

    private Integer parsePreferenceLevel(String text) {
        if (text == null || text.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(text.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void addSpiceLevelKeywords(Integer level, Set<String> target) {
        if (level == null || target == null) {
            return;
        }
        if (level >= 4) {
            target.add("辣");
        }
        if (level >= 5) {
            target.add("重口");
            target.add("重口味");
        }
        if (level <= 2) {
            target.add("清淡");
        }
    }

    private void addSweetLevelKeywords(Integer level, Set<String> target) {
        if (level == null || target == null) {
            return;
        }
        if (level >= 4) {
            target.add("甜");
        }
    }

    private List<Dish> rankByPreferences(Set<String> keywords, PreferenceConstraint constraint) {
        if (keywords == null || keywords.isEmpty()) {
            return Collections.emptyList();
        }

        List<Dish> available = dishRepository.findByStatus(Dish.DishStatus.AVAILABLE);
        if (available == null || available.isEmpty()) {
            return Collections.emptyList();
        }

        Map<Dish, Integer> scoreByDish = new HashMap<>();
        for (Dish dish : available) {
            if (dish == null || dish.getId() == null) {
                continue;
            }
            if (!matchesHardConstraints(dish, constraint)) {
                continue;
            }
            int score = scoreDish(dish, keywords);
            if (score > 0) {
                scoreByDish.put(dish, score);
            }
        }

        return scoreByDish.entrySet().stream()
                .sorted(
                        Comparator.<Map.Entry<Dish, Integer>>comparingInt(Map.Entry::getValue).reversed()
                                .thenComparing(e -> e.getKey().getAverageRating() == null ? 0.0 : e.getKey().getAverageRating(), Comparator.reverseOrder())
                                .thenComparing(e -> e.getKey().getRatingCount() == null ? 0 : e.getKey().getRatingCount(), Comparator.reverseOrder())
                )
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private PreferenceConstraint buildPreferenceConstraint(Set<String> rawPreferences) {
        if (rawPreferences == null || rawPreferences.isEmpty()) {
            return PreferenceConstraint.empty();
        }

        boolean nonSpicyRequired = containsAnyKeyword(rawPreferences, "不辣", "无辣", "清淡", "少辣", "微辣");
        Set<String> preferredCuisines = new LinkedHashSet<>();
        for (String pref : rawPreferences) {
            String p = pref == null ? "" : pref.trim();
            if (p.isEmpty()) {
                continue;
            }
            if (p.contains("粤菜")) preferredCuisines.add("粤菜");
            if (p.contains("浙菜")) preferredCuisines.add("浙菜");
            if (p.contains("苏菜")) preferredCuisines.add("苏菜");
            if (p.contains("闽菜")) preferredCuisines.add("闽菜");
            if (p.contains("鲁菜")) preferredCuisines.add("鲁菜");
            if (p.contains("川菜")) preferredCuisines.add("川菜");
            if (p.contains("湘菜")) preferredCuisines.add("湘菜");
            if (p.contains("徽菜")) preferredCuisines.add("徽菜");
            if (p.contains("东北菜")) preferredCuisines.add("东北菜");
            if (p.contains("西北菜")) preferredCuisines.add("西北菜");
        }
        return new PreferenceConstraint(nonSpicyRequired, preferredCuisines);
    }

    private boolean matchesHardConstraints(Dish dish, PreferenceConstraint constraint) {
        if (dish == null || constraint == null) {
            return false;
        }
        String searchable = buildDishSearchText(dish);

        if (constraint.nonSpicyRequired() && containsAny(searchable,
                "辣", "麻辣", "香辣", "重辣", "川味", "川菜", "湘菜", "剁椒", "麻婆", "水煮")) {
            return false;
        }

        if (!constraint.preferredCuisines().isEmpty()) {
            boolean cuisineMatched = constraint.preferredCuisines().stream().anyMatch(searchable::contains);
            if (!cuisineMatched) {
                return false;
            }
        }

        return true;
    }

    private String buildDishSearchText(Dish dish) {
        StringBuilder sb = new StringBuilder();
        appendText(sb, dish.getName());
        appendText(sb, dish.getDescription());
        appendText(sb, dish.getWindowName());
        appendText(sb, dish.getCanteenName());
        if (dish.getTasteTags() != null) {
            for (String tag : dish.getTasteTags()) {
                appendText(sb, tag);
            }
        }
        return sb.toString().toLowerCase(Locale.ROOT);
    }

    private void appendText(StringBuilder sb, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }
        if (sb.length() > 0) {
            sb.append(' ');
        }
        sb.append(value.trim());
    }

    private boolean containsAnyKeyword(Set<String> rawPreferences, String... keywords) {
        if (rawPreferences == null || rawPreferences.isEmpty() || keywords == null || keywords.length == 0) {
            return false;
        }
        for (String pref : rawPreferences) {
            String p = pref == null ? "" : pref.trim();
            if (p.isEmpty()) {
                continue;
            }
            for (String keyword : keywords) {
                if (keyword != null && !keyword.isEmpty() && p.contains(keyword)) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean containsAny(String text, String... keywords) {
        if (text == null || text.isEmpty() || keywords == null || keywords.length == 0) {
            return false;
        }
        for (String keyword : keywords) {
            if (keyword != null && !keyword.isEmpty() && text.contains(keyword.toLowerCase(Locale.ROOT))) {
                return true;
            }
        }
        return false;
    }

    private record PreferenceConstraint(boolean nonSpicyRequired, Set<String> preferredCuisines) {
        private static PreferenceConstraint empty() {
            return new PreferenceConstraint(false, Collections.emptySet());
        }
    }

    private int scoreDish(Dish dish, Set<String> keywords) {
        if (dish == null || keywords == null || keywords.isEmpty()) {
            return 0;
        }

        int score = 0;
        String dishName = toLower(dish.getName());
        String dishDesc = toLower(dish.getDescription());
        List<String> tasteTags = dish.getTasteTags() == null
                ? Collections.emptyList()
                : dish.getTasteTags().stream().filter(Objects::nonNull).map(this::toLower).collect(Collectors.toList());

        for (String rawKeyword : keywords) {
            String keyword = toLower(rawKeyword);
            if (keyword.isEmpty()) {
                continue;
            }

            boolean matchedTasteTag = tasteTags.stream()
                    .anyMatch(tag -> tag.equals(keyword) || tag.contains(keyword) || keyword.contains(tag));
            if (matchedTasteTag) {
                score += 4;
            }

            boolean matchedText = (!dishName.isEmpty() && dishName.contains(keyword))
                    || (!dishDesc.isEmpty() && dishDesc.contains(keyword));
            if (matchedText) {
                score += 2;
            }
        }
        return score;
    }

    private String toLower(String text) {
        if (text == null) {
            return "";
        }
        return text.trim().toLowerCase(Locale.ROOT);
    }

    private void appendPreferenceMatchedRecommendations(List<Dish> recommendations,
                                                        List<Dish> ranked,
                                                        Set<Long> orderedDishIds,
                                                        int limit) {
        if (recommendations == null || ranked == null || ranked.isEmpty() || limit <= 0) {
            return;
        }

        Set<Long> seen = recommendations.stream()
                .filter(Objects::nonNull)
                .map(Dish::getId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        // 先推荐未点过的匹配菜品
        for (Dish dish : ranked) {
            if (recommendations.size() >= limit) {
                return;
            }
            if (dish == null || dish.getId() == null || !seen.add(dish.getId())) {
                continue;
            }
            if (orderedDishIds != null && orderedDishIds.contains(dish.getId())) {
                continue;
            }
            recommendations.add(dish);
        }

        // 再补充已点过但仍与偏好匹配的菜品，避免结果被热门推荐完全覆盖
        for (Dish dish : ranked) {
            if (recommendations.size() >= limit) {
                return;
            }
            if (dish == null || dish.getId() == null || !seen.add(dish.getId())) {
                continue;
            }
            recommendations.add(dish);
        }
    }

    @Override
    public String getStrategyType() {
        return "content";
    }
}
