package com.school.canteen.util;

import com.school.canteen.dto.DishFeatureDTO;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/** 菜品特征关键词提取引擎，从评价中提取口味、食材、烹饪方式等特征词 */
public class DishFeatureKeywordEngine {

    public enum Category {
        TASTE,
        AROMA,
        TEXTURE,
        APPEARANCE,
        INGREDIENT,
        COOKING_METHOD,
        FRESHNESS
    }

    public record Params(
            int topN,
            int minWordLength,
            int minFrequency,
            double wReviews,
            double wSales
    ) {
        public Params {
            if (topN <= 0) topN = 50;
            if (minWordLength <= 0) minWordLength = 2;
            if (minFrequency <= 0) minFrequency = 1;
            if (wReviews < 0) wReviews = 1.0;
            if (wSales < 0) wSales = 0.0;
        }
    }

    public record DishReviewDoc(Long dishId, String comment, List<String> quickTags) {}

    public static class Result {
        private final long version;
        private final List<DishFeatureDTO.KeywordAnalysis> keywords;
        private final int matchedReviews;
        private final int coveredDishes;

        public Result(long version, List<DishFeatureDTO.KeywordAnalysis> keywords, int matchedReviews, int coveredDishes) {
            this.version = version;
            this.keywords = keywords;
            this.matchedReviews = matchedReviews;
            this.coveredDishes = coveredDishes;
        }

        public long getVersion() {
            return version;
        }

        public List<DishFeatureDTO.KeywordAnalysis> getKeywords() {
            return keywords;
        }

        public int getMatchedReviews() {
            return matchedReviews;
        }

        public int getCoveredDishes() {
            return coveredDishes;
        }
    }

    private static final Set<String> STOP_WORDS = new HashSet<>(Arrays.asList(
            "的", "了", "是", "我", "你", "他", "在", "就", "不", "也", "很", "非常", "这个", "那个", "感觉"
    ));

    private static final List<String> GENERIC_WORDS = Arrays.asList(
            "不错", "一般", "还行", "推荐", "可以", "满意", "差不多", "还不错", "挺好", "很好", "太好了"
    );

    private static final List<String> DENY_PATTERNS = Arrays.asList(
            "服务", "态度", "分量", "价格", "贵", "便宜", "性价比", "环境", "卫生", "排队", "出餐", "速度", "窗口", "阿姨"
    );

    private static final Map<Category, List<String>> CATEGORY_DICTIONARY = new LinkedHashMap<>();

    static {
        CATEGORY_DICTIONARY.put(Category.TASTE, Arrays.asList(
                "好吃", "美味", "鲜", "香", "清淡", "油腻", "太油", "偏油", "太咸", "偏咸", "咸", "淡",
                "辣", "麻辣", "酸", "酸甜", "甜", "太甜", "偏甜", "苦", "腥", "回甘"
        ));
        CATEGORY_DICTIONARY.put(Category.AROMA, Arrays.asList(
                "香气扑鼻", "香气", "香味", "香", "腥", "异味", "怪味"
        ));
        CATEGORY_DICTIONARY.put(Category.TEXTURE, Arrays.asList(
                "酥脆", "脆", "软嫩", "嫩", "筋道", "Q弹", "入口即化", "口感好", "口感", "嚼劲", "顺滑", "绵密"
        ));
        CATEGORY_DICTIONARY.put(Category.APPEARANCE, Arrays.asList(
                "色泽诱人", "色泽", "卖相好", "卖相", "好看", "诱人", "颜值", "摆盘"
        ));
        CATEGORY_DICTIONARY.put(Category.INGREDIENT, Arrays.asList(
                "鸡", "鸡肉", "鸡蛋", "牛", "牛肉", "羊", "羊肉", "猪", "猪肉", "鱼", "虾", "豆腐", "土豆",
                "西红柿", "番茄", "青椒", "茄子", "白菜", "萝卜", "葱", "姜", "蒜", "香菜", "玉米", "蘑菇"
        ));
        CATEGORY_DICTIONARY.put(Category.COOKING_METHOD, Arrays.asList(
                "红烧", "清蒸", "爆炒", "炒", "油炸", "炸", "凉拌", "炖", "煮", "卤", "烤", "焗", "煎", "蒸"
        ));
        CATEGORY_DICTIONARY.put(Category.FRESHNESS, Arrays.asList(
                "食材新鲜", "新鲜", "不新鲜", "馊", "回锅", "隔夜"
        ));
    }

    private static final List<String> PHRASE_DICTIONARY = buildPhraseDictionary();

    private static List<String> buildPhraseDictionary() {
        Set<String> set = new LinkedHashSet<>();
        for (List<String> words : CATEGORY_DICTIONARY.values()) {
            for (String w : words) {
                if (w != null && !w.isBlank() && w.length() >= 2) set.add(w.trim());
            }
        }
        List<String> list = new ArrayList<>(set);
        list.sort((a, b) -> {
            int cmp = Integer.compare(b.length(), a.length());
            if (cmp != 0) return cmp;
            return a.compareTo(b);
        });
        return list;
    }

    public static Result compute(List<DishReviewDoc> docs, Map<Long, Integer> dishSales, long version, Params params) {
        if (docs == null || docs.isEmpty()) {
            return new Result(version, Collections.emptyList(), 0, 0);
        }
        Map<String, KeywordAgg> agg = new HashMap<>();
        Set<Long> coveredDishes = new HashSet<>();
        int matchedReviews = 0;

        for (DishReviewDoc doc : docs) {
            if (doc == null || doc.dishId() == null) continue;
            Long dishId = doc.dishId();
            List<String> tokens = extractDishRelatedTokens(doc.comment(), doc.quickTags(), params);
            if (tokens.isEmpty()) continue;
            matchedReviews++;
            coveredDishes.add(dishId);
            for (String token : tokens) {
                KeywordAgg a = agg.computeIfAbsent(token, k -> new KeywordAgg());
                a.reviewHits += 1;
                a.dishIds.add(dishId);
            }
        }

        for (Map.Entry<String, KeywordAgg> e : agg.entrySet()) {
            if (dishSales == null || dishSales.isEmpty()) break;
            int totalSales = 0;
            for (Long dishId : e.getValue().dishIds) {
                totalSales += Math.max(0, dishSales.getOrDefault(dishId, 0));
            }
            e.getValue().salesBoost = totalSales;
        }

        List<DishFeatureDTO.KeywordAnalysis> keywords = agg.entrySet().stream()
                .filter(e -> e.getValue().reviewHits >= params.minFrequency)
                .map(e -> toDTO(e.getKey(), e.getValue(), params))
                .sorted((a, b) -> {
                    int cmp = Integer.compare(b.getValue(), a.getValue());
                    if (cmp != 0) return cmp;
                    return a.getName().compareTo(b.getName());
                })
                .limit(params.topN)
                .collect(Collectors.toList());

        return new Result(version, keywords, matchedReviews, coveredDishes.size());
    }

    private static DishFeatureDTO.KeywordAnalysis toDTO(String token, KeywordAgg agg, Params params) {
        DishFeatureDTO.KeywordAnalysis dto = new DishFeatureDTO.KeywordAnalysis();
        dto.setName(token);
        Category category = classify(token);
        dto.setCategory(category == null ? null : category.name());
        dto.setDishCount(agg.dishIds.size());
        Map<String, Object> breakdown = new LinkedHashMap<>();
        breakdown.put("reviewHits", agg.reviewHits);
        if (params.wSales > 0) breakdown.put("salesBoost", agg.salesBoost);
        dto.setBreakdown(breakdown);

        double score = params.wReviews * agg.reviewHits;
        if (params.wSales > 0) {
            score += params.wSales * Math.log1p(agg.salesBoost);
        }
        dto.setValue(Math.max(1, (int) Math.round(score)));
        return dto;
    }

    private static class KeywordAgg {
        int reviewHits = 0;
        int salesBoost = 0;
        Set<Long> dishIds = new HashSet<>();
    }

    private static List<String> extractDishRelatedTokens(String comment, List<String> quickTags, Params params) {
        Set<String> result = new LinkedHashSet<>();

        if (quickTags != null) {
            for (String tag : quickTags) {
                String t = normalize(tag);
                if (t == null) continue;
                if (isDenied(t) || isGeneric(t)) continue;
                Category c = classify(t);
                if (c != null) result.add(t);
            }
        }

        if (comment != null && !comment.isBlank()) {
            String text = comment.trim();
            for (String phrase : PHRASE_DICTIONARY) {
                if (text.contains(phrase)) result.add(phrase);
            }
            String[] words = text.split("[^\\u4e00-\\u9fa5]+");
            for (String w : words) {
                String t = normalize(w);
                if (t == null) continue;
                if (t.length() < params.minWordLength) continue;
                if (STOP_WORDS.contains(t)) continue;
                if (isDenied(t) || isGeneric(t)) continue;
                Category c = classify(t);
                if (c != null) result.add(t);
            }
        }

        return new ArrayList<>(result);
    }

    private static boolean isDenied(String token) {
        for (String p : DENY_PATTERNS) {
            if (token.contains(p)) return true;
        }
        return false;
    }

    private static boolean isGeneric(String token) {
        for (String g : GENERIC_WORDS) {
            if (token.equals(g)) return true;
        }
        return false;
    }

    private static String normalize(String s) {
        if (s == null) return null;
        String t = s.trim();
        if (t.isEmpty()) return null;
        t = t.replaceAll("\\s+", "");
        return t.isEmpty() ? null : t;
    }

    public static Category classify(String token) {
        if (token == null || token.isBlank()) return null;
        String t = token.trim();
        for (Map.Entry<Category, List<String>> e : CATEGORY_DICTIONARY.entrySet()) {
            for (String w : e.getValue()) {
                if (t.equals(w) || t.contains(w)) return e.getKey();
            }
        }
        String lower = t.toLowerCase(Locale.ROOT);
        if (lower.contains("q弹")) return Category.TEXTURE;
        return null;
    }
}

