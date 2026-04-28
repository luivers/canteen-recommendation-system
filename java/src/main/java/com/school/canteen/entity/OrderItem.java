package com.school.canteen.entity;

import com.school.canteen.entity.Combo;
import com.school.canteen.entity.Dish;
import com.fasterxml.jackson.annotation.JsonBackReference;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 订单明细项实体 — 记录订单中每道菜品的数量、单价、小计等 */
@Entity
@Table(name = "order_items")
@Data
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    @JsonBackReference
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Order order;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "dish_id", nullable = true)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Dish dish;

    @ManyToOne
    @JoinColumn(name = "combo_id", nullable = true)
    private Combo combo;
    
    @Column(nullable = false)
    private Integer quantity; // 数量
    
    @Column(nullable = false)
    private BigDecimal unitPrice; // 单价
    
    @Column(nullable = false)
    private BigDecimal subtotal; // 小计

    private Boolean isGift = false; // 是否为赠品

    // 窗口信息
    private Long windowId; // 所属窗口ID
    private String windowName; // 所属窗口名称
    private String windowLocation; // 窗口位置
    
    // 取餐方式
    @Enumerated(EnumType.STRING)
    private Order.PickupType pickupType;
    
    private LocalDateTime pickupTime; // 取餐时间
    
    private String remarks; // 备注
    
    // 支付信息
    private String paymentMethod; // 支付方式，如 WECHAT、ALIPAY、CARD
    private String paymentTransactionId; // 支付交易流水号
    private LocalDateTime paymentTime; // 支付时间
    
    @Column(name = "create_time", nullable = false, updatable = false)
    private LocalDateTime createTime;
    
    @Column(name = "update_time", nullable = false)
    private LocalDateTime updateTime;

    @PrePersist
    protected void onCreate() {
        if (createTime == null) {
            createTime = LocalDateTime.now();
        }
        updateTime = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updateTime = LocalDateTime.now();
    }
}
