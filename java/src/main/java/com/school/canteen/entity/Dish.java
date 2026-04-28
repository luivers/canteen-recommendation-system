package com.school.canteen.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import jakarta.persistence.*;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/** 菜品实体 — 包含价格、营养信息、口味标签、促销信息、评分等 */
@Entity
@Table(name = "dishes")
@Data
@JsonIgnoreProperties(value = {"hibernateLazyInitializer", "handler"}, ignoreUnknown = true)
public class Dish implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name; // 菜品名称
    
    private String description; // 菜品描述
    
    @Column(nullable = false)
    private BigDecimal price; // 价格
    
    private String imageUrl; // 菜品图片
    
    // 口味标签
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "dish_taste_tags")
    @Column(name = "taste_tag")
    @org.hibernate.annotations.BatchSize(size = 50)
    private List<String> tasteTags; // 辣、甜、咸等
    
    // 分类信息
    // category_id 外键已移除
    
    // 食堂和窗口信息
    private Long canteenId; // 所属食堂ID
    private String canteenName; // 所属食堂名称
    private Long windowId; // 所属窗口ID
    private String windowName; // 所属窗口名称
    private String windowLocation; // 窗口位置
    
    // 营养信息
    private Integer calories; // 卡路里
    private BigDecimal protein; // 蛋白质
    private BigDecimal fat; // 脂肪
    private BigDecimal carbohydrate; // 碳水化合物
    
    // 菜品类型
    @Enumerated(EnumType.STRING)
    private DishCategory dishCategory; // 菜品类型：主食、菜品、汤类、小吃、饮品
    
    // 菜品状态
    @Enumerated(EnumType.STRING)
    private DishStatus status = DishStatus.AVAILABLE;
    
    private Integer stock; // 库存数量
    private Integer dailyLimit; // 每日限量
    
    // 促销信息
    private Boolean isPromotion = false;
    private String promotionType; // discount, special, gift
    private Long giftDishId; // 赠品菜品ID
    private BigDecimal promotionPrice;
    private LocalDateTime promotionStart;
    private LocalDateTime promotionEnd;
    
    // 评分信息
    private Double averageRating = 0.0;
    private Integer ratingCount = 0;

    @Transient
    private Integer salesCount;
    
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
        updateTime = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updateTime = LocalDateTime.now();
    }
    
    public enum DishCategory {
        MAIN_DISH, // 主食
        MEAT_DISH, // 荤菜
        VEGETABLE, // 素菜
        SOUP, // 汤类
        SNACK, // 小吃
        BEVERAGE, // 饮品
        SIDE_DISH // 兼容旧数据
    }
    
    public enum DishStatus {
        AVAILABLE, // 在售
        SOLD_OUT, // 售罄
        DISCONTINUED, // 下架
        DELETED // 已删除
    }
}
