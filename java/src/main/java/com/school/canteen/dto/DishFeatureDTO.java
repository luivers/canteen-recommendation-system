package com.school.canteen.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 菜品特征分析相关DTO聚合类
 */
public class DishFeatureDTO {

    @Data
    public static class KeywordAnalysis {
        private String name;
        private Integer value;
        private String category;
        private Integer dishCount;
        private Map<String, Object> breakdown;
    }

    @Data
    public static class RelatedDish {
        private Long id;
        private String name;
        private BigDecimal price;
        private String dishCategory;
        private Long canteenId;
        private String canteenName;
        private Long windowId;
        private String windowName;
        private Integer salesCount;
        private Integer reviewHitCount;
        private Double averageRating;
        private List<String> hitSources;
    }
}
