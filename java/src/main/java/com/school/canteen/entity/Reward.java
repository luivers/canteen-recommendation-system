package com.school.canteen.entity;

import lombok.Data;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/** 奖品/代金券实体 — 包含积分兑换所需积分、库存、面值、有效期等 */
@Entity
@Table(
        name = "rewards",
        indexes = {
                @Index(name = "idx_rewards_status_points", columnList = "status,points_required"),
                @Index(name = "idx_rewards_category", columnList = "category_id"),
                @Index(name = "idx_rewards_type", columnList = "type")
        }
)
@Data
public class Reward {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name; // 奖励名称
    
    @Column(name = "description")
    private String description; // 奖励描述
    
    @Column(name = "points_required", nullable = false)
    private Integer pointsRequired; // 所需积分
    
    @Column(name = "stock", nullable = false)
    private Integer stock; // 库存
    
    @Column(name = "image_url")
    private String imageUrl; // 奖励图片

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "category_id")
    private RewardCategory category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RewardType type = RewardType.VOUCHER;

    @Column(name = "face_value")
    private BigDecimal faceValue; // 代金券面值

    @Column(name = "min_order_amount")
    private BigDecimal minOrderAmount; // 使用门槛（最低消费）

    @Column(name = "valid_from")
    private LocalDateTime validFrom; // 有效期开始
    @Column(name = "valid_to")
    private LocalDateTime validTo; // 有效期结束

    @Column(name = "daily_limit")
    private Integer dailyLimit; // 每日可兑上限（按用户）
    @Column(name = "per_user_limit")
    private Integer perUserLimit; // 单用户可兑总数上限

    @Column(name = "exchange_enabled")
    private Boolean exchangeEnabled = true; // 是否允许兑换

    @Column(name = "attributes", columnDefinition = "TEXT")
    private String attributes; // JSON扩展字段

    @Version
    private Integer version;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private RewardStatus status = RewardStatus.AVAILABLE; // 奖励状态
    
    @Column(name = "create_time")
    private LocalDateTime createTime;
    @Column(name = "update_time")
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

    public enum RewardType {
        VOUCHER, // 代金券
        OTHER // 其他兑换物
    }
    
    // 奖励状态枚举
    public enum RewardStatus {
        AVAILABLE, // 可用
        OUT_OF_STOCK, // 缺货
        DISCONTINUED, // 已下架
        DELETED // 已删除
    }
}
