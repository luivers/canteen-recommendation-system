package com.school.canteen.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/** 促销活动实体 — 支持折扣、特价、买赠等多种促销类型 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "promotions")
public class Promotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "type", nullable = false, length = 50)
    private String type; // discount, full_reduction, time_limit, combo

    @Column(name = "discount_value", nullable = true)
    private Double discountValue; // 折扣值，如0.8表示8折

    @Column(name = "full_amount", nullable = true)
    private Double fullAmount; // 满减的满额

    @Column(name = "reduce_amount", nullable = true)
    private Double reduceAmount; // 满减的减额

    @Column(name = "target_type", nullable = false, length = 20)
    private String targetType; // all, category, specific

    @Column(name = "description", nullable = true, length = 500)
    private String description;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;

    @Column(name = "status", nullable = false, length = 20)
    private String status; // pending, active, ended, disabled

    @Column(name = "is_hot", nullable = false)
    private Boolean isHot = false;

    @Column(name = "order_count", nullable = false)
    private Integer orderCount = 0;

    @Column(name = "total_discount", nullable = false)
    private Double totalDiscount = 0.0;

    // 多对多关系：一个促销可以关联多个菜品
    @ManyToMany
    @JoinTable(
        name = "promotion_dishes",
        joinColumns = @JoinColumn(name = "promotion_id"),
        inverseJoinColumns = @JoinColumn(name = "dish_id")
    )
    private List<Dish> dishes;

    // 多对多关系：一个促销可以关联多个分类 (使用 DishCategory 枚举字符串)
    @ElementCollection
    @CollectionTable(
        name = "promotion_dish_categories",
        joinColumns = @JoinColumn(name = "promotion_id")
    )
    @Column(name = "dish_category")
    private List<String> targetDishCategories;

    // 一对多关系：一个促销可以有多个套餐组合
    @OneToMany(mappedBy = "promotion", cascade = CascadeType.ALL, fetch = FetchType.LAZY, orphanRemoval = true)
    private List<Combo> combos;
}