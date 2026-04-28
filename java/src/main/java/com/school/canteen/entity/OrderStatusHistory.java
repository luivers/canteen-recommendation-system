package com.school.canteen.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

/** 订单状态变更历史实体 — 记录订单每次状态流转 */
@Entity
@Table(name = "order_status_history")
@Data
public class OrderStatusHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Enumerated(EnumType.STRING)
    private Order.OrderStatus fromStatus;

    @Enumerated(EnumType.STRING)
    private Order.OrderStatus toStatus;

    @Column(nullable = false)
    private LocalDateTime changeTime = LocalDateTime.now();

    private String note;
}
