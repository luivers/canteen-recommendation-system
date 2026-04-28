package com.school.canteen.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 购物车项实体 — 记录用户添加到购物车的菜品及数量 */
@Entity
@Table(name = "cart_items")
@Data
public class CartItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;
    
    @ManyToOne
    @JoinColumn(name = "dish_id", nullable = true)
    private Dish dish;

    @ManyToOne
    @JoinColumn(name = "combo_id", nullable = true)
    private Combo combo;
    
    @Column(nullable = false)
    private Integer quantity;
    
    @Column(nullable = false)
    private BigDecimal price;
    
    private Boolean isGift = false;

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
}