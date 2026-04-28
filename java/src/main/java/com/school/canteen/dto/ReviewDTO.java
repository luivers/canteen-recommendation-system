package com.school.canteen.dto;

import lombok.Data;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 评价相关DTO聚合类
 */
public class ReviewDTO {

    @Data
    public static class CreateRequest {
        @NotNull(message = "订单ID不能为空")
        private Long orderId;

        @NotNull(message = "口味评分不能为空")
        @Min(value = 1, message = "口味评分不能小于1")
        @Max(value = 5, message = "口味评分不能大于5")
        private Integer tasteRating;

        @NotNull(message = "分量评分不能为空")
        @Min(value = 1, message = "分量评分不能小于1")
        @Max(value = 5, message = "分量评分不能大于5")
        private Integer portionRating;

        @NotNull(message = "价格评分不能为空")
        @Min(value = 1, message = "价格评分不能小于1")
        @Max(value = 5, message = "价格评分不能大于5")
        private Integer priceRating;

        @NotNull(message = "卫生评分不能为空")
        @Min(value = 1, message = "卫生评分不能小于1")
        @Max(value = 5, message = "卫生评分不能大于5")
        private Integer hygieneRating;

        @Size(max = 1000, message = "评价内容不能超过1000字")
        private String comment;

        private List<String> quickTags = new ArrayList<>();

        @Valid
        @Size(min = 1, message = "请至少为一个菜品评分")
        private List<ItemRequest> items = new ArrayList<>();
    }

    @Data
    public static class ItemRequest {
        @NotNull(message = "菜品ID不能为空")
        private Long dishId;

        @NotNull(message = "菜品评分不能为空")
        @Min(value = 1, message = "菜品评分不能小于1")
        @Max(value = 5, message = "菜品评分不能大于5")
        private Integer rating;
    }

    @Data
    public static class KeywordFilter {
        // Date Range
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        private LocalDate startDate;
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
        private LocalDate endDate;

        // Configs
        private DataSource dataSource;
        private Integer minRating;
        private List<String> includeKeywords;
        private List<String> excludeKeywords;
        private Integer minWordLength;
        private Integer minFrequency;
        private Integer topN;
        private List<String> stopWords;
        private Map<String, List<String>> categoryMapping;

        private String sentiment; // "GOOD" or "BAD"

        public enum DataSource {
            QUICK_TAGS,
            COMMENT,
            BOTH
        }
    }
}
