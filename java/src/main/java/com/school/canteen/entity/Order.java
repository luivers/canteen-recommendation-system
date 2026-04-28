package com.school.canteen.entity;


import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import java.math.BigDecimal;
import java.util.List;

/** 订单实体 — 包含订单号、用户、订单项、金额、代金券抵扣、状态等 */
@Entity
@Table(name = "orders")
@Data
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String orderNumber; // 订单号
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user; // 下单用户
    
    // 订单项
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<OrderItem> orderItems;
    
    @Column(nullable = false)
    private BigDecimal totalAmount; // 总金额

    private BigDecimal goodsAmount;

    private BigDecimal voucherDeduction;

    private BigDecimal payableAmount;

    private Long voucherExchangeId;
    
    // 订单状态
    @Enumerated(EnumType.STRING)
    private OrderStatus status = OrderStatus.PENDING;
    
    @PrePersist
    protected void onCreate() {
        // 只有在orderNumber未设置时才生成
        if (orderNumber == null || orderNumber.isEmpty()) {
            orderNumber = generateOrderNumber();
        }
    }
    
    private String generateOrderNumber() {
        return "ORD" + System.currentTimeMillis();
    }
    
    public enum PickupType {
        IMMEDIATE, // 即时取餐
        RESERVATION // 预约取餐
    }
    
    public enum OrderStatus {
        PENDING, // 待支付
        PAID, // 已支付
        PREPARING, // 准备中
        READY, // 已就绪
        COMPLETED, // 已完成
        CANCELLED // 已取消
    }
}
