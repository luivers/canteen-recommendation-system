package com.school.canteen.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/** 通知消息实体 — 支持多种通知类型（订单、评价、奖励、系统公告、预警等） */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(
        name = "notifications",
        indexes = {
                @Index(name = "idx_notifications_user_read_time", columnList = "user_id,is_read,create_time")
        }
)
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "content", nullable = false, length = 2000)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 30)
    private NotificationType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "scene", nullable = false, length = 50)
    private NotificationScene scene;

    @Enumerated(EnumType.STRING)
    @Column(name = "biz_type", nullable = false, length = 30)
    private BizType bizType;

    @Column(name = "biz_id")
    private Long bizId;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @Column(name = "create_time", nullable = false)
    private LocalDateTime createTime;

    @Column(name = "read_time")
    private LocalDateTime readTime;

    @Column(name = "deleted", nullable = false)
    private Boolean deleted = false;

    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }

    public enum NotificationType {
        DISH,
        PROMOTION,
        RESERVATION,
        COMMENT,
        REWARD,
        WARNING
    }

    public enum NotificationScene {
        DISH_ON_SHELF,
        PROMOTION_START,
        ORDER_STATUS_CHANGE,
        COMMENT_REPLY,
        REWARD_DELIVERY,
        INVENTORY_WARNING
    }

    public enum BizType {
        DISH,
        PROMOTION,
        ORDER,
        REVIEW,
        REWARD_EXCHANGE
    }
}
