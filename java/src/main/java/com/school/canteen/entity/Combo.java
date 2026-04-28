package com.school.canteen.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

/** 套餐组合实体 — 关联促销活动，包含多个菜品 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "combos")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Combo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "description", nullable = true, length = 500)
    private String description;

    @Column(name = "price", nullable = false)
    private Double price;

    @Column(name = "original_price", nullable = false)
    private Double originalPrice;

    @Column(name = "status", nullable = false, length = 20)
    private String status; // active, disabled

    // 多对一关系：一个套餐属于一个促销活动
    @ManyToOne
    @JoinColumn(name = "promotion_id", nullable = false)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private Promotion promotion;

    // 多对多关系：一个套餐包含多个菜品
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "combo_dishes",
        joinColumns = @JoinColumn(name = "combo_id"),
        inverseJoinColumns = @JoinColumn(name = "dish_id")
    )
    private List<Dish> dishes;

    @Transient
    public String getImageUrl() {
        if (dishes != null && !dishes.isEmpty()) {
            for (Dish dish : dishes) {
                if (dish.getImageUrl() != null && !dish.getImageUrl().isEmpty()) {
                    return dish.getImageUrl();
                }
            }
        }
        return "";
    }
}