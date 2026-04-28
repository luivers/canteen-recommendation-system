package com.school.canteen.util;

import com.school.canteen.dto.ReviewDTO;

import java.util.*;
import java.util.stream.Collectors;

/** 评价关键词处理器，从评论和标签中提取情感关键词并统计频次 */
public class KeywordProcessor {

    public static Map<String, Object> process(List<String> comments, List<List<String>> tagsList, ReviewDTO.KeywordFilter filter) {
        Map<String, Double> keywordWeights = new HashMap<>();
        List<String> samples = new ArrayList<>();
        int totalMatched = comments.size(); 

        List<String> stopWords = filter.getStopWords() != null ? filter.getStopWords() : new ArrayList<>();
        if (stopWords.isEmpty()) {
            stopWords = Arrays.asList("的", "了", "是", "我", "你", "他", "在", "就", "不", "也", "很", "非常", "这个", "那个", "味道", "感觉");
        }
        Set<String> stopSet = new HashSet<>(stopWords);
        
        // Define default sentiment keywords
        List<String> goodKeywords = Arrays.asList("好吃", "美味", "香", "鲜", "不错", "绝", "赞", "服务好", "态度好", "热情", "快", "周到", "实惠", "便宜", "划算", "性价比", "干净", "卫生", "舒适", "整洁", "分量足", "量大", "撑", "出餐快", "服务周到", "环境好", "价格合理", "物美价廉");
        List<String> badKeywords = Arrays.asList(
                "难吃", "腥", "不新鲜", "慢", "恶劣", "不划算", "吃不饱",
                "脏", "乱", "不卫生", "虫", "异物", "吵", "太油",
                "太咸", "死咸", "齁咸", "咸了", "过咸","臭",
                "太淡", "没味", "淡了", "没盐",
                "饭凉", "菜凉", "凉了",
                "量少", "太少", "很少", "分量少",
                "等太久", "很久", "排队久",
                "服务差", "态度差", "环境差", "卫生差", "体验差", "口感差", "味道差", "质量差",
                "太贵", "很贵", "死贵", "不值"
        );
        
        Set<String> targetSentimentKeywords = new HashSet<>();
        if ("GOOD".equalsIgnoreCase(filter.getSentiment())) {
            targetSentimentKeywords.addAll(goodKeywords);
        } else if ("BAD".equalsIgnoreCase(filter.getSentiment())) {
            targetSentimentKeywords.addAll(badKeywords);
        } else {
             // If ALL, we still want to capture these phrases if they appear, but we also allow other words
        }

        Set<String> categoryWords = new HashSet<>();
        if (filter.getCategoryMapping() != null) {
            for (Map.Entry<String, List<String>> entry : filter.getCategoryMapping().entrySet()) {
                if (entry.getValue() == null) continue;
                for (String w : entry.getValue()) {
                    if (w != null && !w.isBlank()) categoryWords.add(w.trim());
                }
            }
        }

        List<String> dictionaryWords = new ArrayList<>();
        dictionaryWords.addAll(goodKeywords);
        dictionaryWords.addAll(badKeywords);
        dictionaryWords.addAll(categoryWords);
        dictionaryWords.sort((a, b) -> {
            int lenCmp = Integer.compare(b.length(), a.length());
            if (lenCmp != 0) return lenCmp;
            return a.compareTo(b);
        });
        
        // Determine source config
        boolean useComment = true;
        boolean useTags = true;
        if (filter.getDataSource() != null) {
            switch (filter.getDataSource()) {
                case COMMENT: useTags = false; break;
                case QUICK_TAGS: useComment = false; break;
                case BOTH: break;
            }
        }

        for (int i = 0; i < comments.size(); i++) {
            String comment = comments.get(i);
            List<String> tags = (tagsList != null && i < tagsList.size()) ? tagsList.get(i) : null;
            
            // Extraction Strategy: 
            // 1. Direct Dictionary Match (High Priority) -> captures "Service Good"
            // 2. Segmentation Fallback (Low Priority) -> captures single words
            
            List<String> tokens = new ArrayList<>();
            
            if (useComment && comment != null) {
                // Dictionary Match
                for (String dictWord : dictionaryWords) {
                    if (comment.contains(dictWord)) {
                        tokens.add(dictWord);
                    }
                }
                
                // Fallback: Simple Segmentation (only if not strictly sentiment filtered or if we want everything)
                // If sentiment filter is active, we mostly care about the target keywords.
                // But user complained about "missing parts". 
                // Let's keep segmentation but maybe filter it stricter.
                String[] words = comment.split("[^\\u4e00-\\u9fa5]+");
                for (String w : words) {
                    if (w.length() >= (filter.getMinWordLength() != null ? filter.getMinWordLength() : 2)) {
                        // Avoid adding if already covered by a longer dictionary word? 
                        // For simplicity, just add it. Frequency count will handle it.
                        // Or better: check if this word is part of any already added token?
                        boolean covered = false;
                        for (String t : tokens) {
                            if (t.contains(w) && t.length() > w.length()) {
                                covered = true; 
                                break;
                            }
                        }
                        if (!covered) {
                            tokens.add(w);
                        }
                    }
                }
            }

            if (useTags && tags != null) {
                tokens.addAll(tags);
            }

            boolean hasMatch = false;

            for (String token : tokens) {
                if (stopSet.contains(token)) continue;

                // Sentiment Filtering
                if (!targetSentimentKeywords.isEmpty()) {
                    boolean sentimentMatch = false;
                    if (targetSentimentKeywords.contains(token)) {
                        sentimentMatch = true;
                    } else {
                        for (String k : targetSentimentKeywords) {
                            if (token.contains(k)) {
                                sentimentMatch = true;
                                break;
                            }
                        }
                    }
                    if (!sentimentMatch) continue;
                }

                if (filter.getIncludeKeywords() != null && !filter.getIncludeKeywords().isEmpty()) {
                    boolean inc = false;
                    for (String k : filter.getIncludeKeywords()) {
                        if (token.contains(k)) { inc = true; break; }
                    }
                    if (!inc) continue;
                }
                
                if (filter.getExcludeKeywords() != null && !filter.getExcludeKeywords().isEmpty()) {
                    boolean exc = false;
                    for (String k : filter.getExcludeKeywords()) {
                        if (token.contains(k)) { exc = true; break; }
                    }
                    if (exc) continue;
                }

                keywordWeights.put(token, keywordWeights.getOrDefault(token, 0.0) + 1.0);
                hasMatch = true;
            }

            if (hasMatch && samples.size() < 5) {
                String sample = comment != null && !comment.isEmpty() ? comment : (tags != null ? tags.toString() : "");
                if (!sample.isEmpty()) samples.add(sample);
            }
        }

        List<Map<String, Object>> keywords = keywordWeights.entrySet().stream()
                .filter(e -> e.getValue() >= (filter.getMinFrequency() != null ? filter.getMinFrequency() : 1))
                .sorted((e1, e2) -> {
                    int cmp = Double.compare(e2.getValue(), e1.getValue());
                    if (cmp != 0) return cmp;
                    return e1.getKey().compareTo(e2.getKey());
                })
                .limit(filter.getTopN() != null ? filter.getTopN() : 50)
                .map(e -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("name", e.getKey());
                    map.put("value", e.getValue().intValue());
                    return map;
                })
                .collect(Collectors.toList());

        Map<String, Object> result = new HashMap<>();
        result.put("totalReviews", totalMatched);
        result.put("matchedReviews", totalMatched);
        result.put("keywords", keywords);
        result.put("sampleReviews", samples);

        return result;
    }
}
