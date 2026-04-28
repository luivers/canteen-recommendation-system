package com.school.canteen.dto;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 奖品相关DTO聚合类
 */
public class VoucherDTO {

    @Data
    public static class UpsertRequest {
        @NotBlank(message = "名称不能为空")
        private String name;

        private String description;

        @NotNull(message = "所需积分不能为空")
        @Positive(message = "所需积分必须大于0")
        private Integer pointsRequired;

        @NotNull(message = "库存不能为空")
        @PositiveOrZero(message = "库存不能为负数")
        private Integer stock;

        private String imageUrl;

        private Long categoryId;

        private BigDecimal faceValue;

        private BigDecimal minOrderAmount;

        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        private LocalDateTime validFrom;

        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        private LocalDateTime validTo;

        @PositiveOrZero(message = "每日限额不能为负数")
        private Integer dailyLimit;

        @PositiveOrZero(message = "单用户限额不能为负数")
        private Integer perUserLimit;

        private Boolean exchangeEnabled;

        private String attributes;

        private String status;

        private String type; // VOUCHER or OTHER
    }

    @Data
    public static class CategoryRequest {
        @NotBlank(message = "分类名称不能为空")
        private String name;

        private Integer sortOrder;

        private String status;
    }

    @Data
    public static class ExchangeDeliveryRequest {
        @NotBlank(message = "发货状态不能为空")
        private String deliveryStatus;

        private String deliveryInfo;
    }

    @Data
    public static class ExchangeStatusRequest {
        @NotBlank(message = "订单状态不能为空")
        private String status;

        private String errorCode;
        private String errorMsg;
    }
}
