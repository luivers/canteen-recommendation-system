package com.school.canteen.dto;

import lombok.Data;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.List;

/** 菜品创建/更新请求DTO */
@Data
public class DishDTO {
    private Long id;

    @NotBlank(message = "菜品名称不能为空")
    private String name;

    private String description;

    @NotNull(message = "价格不能为空")
    @DecimalMin(value = "0.0", message = "价格不能小于0")
    private BigDecimal price;

    private String imageUrl;
    
    private List<String> tasteTags;

    // 兼容前端可能传过来的旧枚举值 VEGETABLE_DISH，以及新的 VEGETABLE
    // 在 Controller 中会统一处理
    private String dishCategory; // MAIN_DISH, VEGETABLE, etc.
    
    private String category; // 兼容前端字段
    
    // 食堂和窗口信息
    private Long canteenId;
    private String canteenName;
    @NotNull(message = "所属窗口不能为空")
    private Long windowId;
    private String windowName;
    private String windowLocation;
    
    // 营养信息
    @Min(value = 0, message = "卡路里不能小于0")
    private Integer calories;
    
    @DecimalMin(value = "0.0", message = "蛋白质含量不能小于0")
    private BigDecimal protein;
    
    @DecimalMin(value = "0.0", message = "脂肪含量不能小于0")
    private BigDecimal fat;
    
    @DecimalMin(value = "0.0", message = "碳水化合物含量不能小于0")
    private BigDecimal carbohydrate;
    
    @Min(value = 0, message = "库存不能小于0")
    private Integer stock;
    
    @Min(value = 0, message = "每日限量不能小于0")
    private Integer dailyLimit;
    
    private String status; // AVAILABLE, SOLD_OUT, etc.
}
