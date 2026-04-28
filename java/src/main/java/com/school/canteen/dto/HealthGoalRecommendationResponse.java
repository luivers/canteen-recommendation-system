package com.school.canteen.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/** 健康目标推荐响应DTO，包含7日营养画像、健康目标和推荐菜品 */
@Data
public class HealthGoalRecommendationResponse {
    private Profile7d profile7d;
    private List<Goal> goals;
    private List<RecommendedDish> recommendations;
    private LocalDateTime generatedAt;

    @Data
    public static class Profile7d {
        private BigDecimal caloriesTotal;
        private BigDecimal proteinTotal;
        private BigDecimal fatTotal;
        private BigDecimal carbohydrateTotal;

        private BigDecimal caloriesDailyAvg;
        private BigDecimal proteinDailyAvg;
        private BigDecimal fatDailyAvg;
        private BigDecimal carbohydrateDailyAvg;

        private BigDecimal proteinEnergyRatio;
        private BigDecimal fatEnergyRatio;
        private BigDecimal carbohydrateEnergyRatio;
    }

    @Data
    public static class Goal {
        private String code;
        private String title;
        private String description;
        private BigDecimal currentRatio;
        private BigDecimal targetMinRatio;
        private BigDecimal targetMaxRatio;
        private BigDecimal deviation;
    }

    @Data
    public static class RecommendedDish {
        private Long id;
        private String name;
        private String imageUrl;
        private BigDecimal price;

        private Integer calories;
        private BigDecimal protein;
        private BigDecimal fat;
        private BigDecimal carbohydrate;

        private Integer nutritionScore;
        private Integer fitPercent;
        private List<String> healthTags;

        private String description;
        private String canteenName;
        private String windowName;
        private String category;
    }
}

