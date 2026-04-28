package com.school.canteen.entity;

import lombok.Data;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 奖品兑换记录实体 — 记录用户积分兑换奖品的订单信息、发货状态等 */
@Entity
@Table(
        name = "reward_exchanges",
        indexes = {
                @Index(name = "idx_reward_exchanges_user_time", columnList = "user_id,exchangeTime"),
                @Index(name = "idx_reward_exchanges_status_time", columnList = "status,exchangeTime"),
                @Index(name = "idx_reward_exchanges_request_id", columnList = "request_id")
        },
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_reward_exchanges_request_id", columnNames = {"request_id"})
        }
)
@Data
public class RewardExchange {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user; // 兑换用户
    
    @ManyToOne
    @JoinColumn(name = "reward_id", nullable = false)
    private Reward reward; // 兑换奖励
    
    @Enumerated(EnumType.STRING)
    private ExchangeStatus status = ExchangeStatus.PENDING; // 兑换状态

    @Column(name = "request_id", unique = true)
    private String requestId;

    private Integer pointsUsed;

    private BigDecimal faceValueSnapshot;

    @Column(columnDefinition = "TEXT")
    private String conditionsSnapshot;

    private Boolean used = false;

    private LocalDateTime usedTime;

    private Long usedOrderId;

    private BigDecimal deductionAmount;

    @Enumerated(EnumType.STRING)
    private DeliveryStatus deliveryStatus = DeliveryStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String deliveryInfo;
    
    // 收货信息字段
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;

    private String errorCode;

    @Column(columnDefinition = "TEXT")
    private String errorMsg;

    private Long operatorId;
    
    private LocalDateTime exchangeTime; // 兑换时间
    private LocalDateTime completeTime; // 完成时间
    private LocalDateTime updateTime;
    
    @PrePersist
    protected void onCreate() {
        exchangeTime = LocalDateTime.now();
        updateTime = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updateTime = LocalDateTime.now();
    }
    
    // 兑换状态枚举
    public enum ExchangeStatus {
        PENDING, // 待处理
        COMPLETED, // 已完成
        CANCELLED, // 已取消
        FAILED // 失败
    }

    public enum DeliveryStatus {
        PENDING,
        SHIPPED,
        DELIVERED,
        FAILED
    }
}
