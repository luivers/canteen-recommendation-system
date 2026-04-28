package com.school.canteen.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/** 积分变动日志实体 — 记录用户积分的获取和消费明细 */
@Entity
@Table(name = "point_logs")
@Data
public class PointLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnore
    private User user;

    @Column(nullable = false)
    private Integer points; // 变动值 (正数或负数)

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PointType type; // EARN, SPEND

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PointSource source; // REVIEW_REWARD, EXCHANGE, ORDER, OTHER

    private String description; // 描述 (e.g., "发布优质评论奖励", "兑换笔记本")

    private LocalDateTime createTime;

    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }

    public enum PointType {
        EARN, // 获取
        SPEND // 消费
    }

    public enum PointSource {
        REVIEW_REWARD, // 评论奖励
        EXCHANGE,      // 积分兑换
        ORDER,         // 订单消费 (可选)
        OTHER          // 其他
    }
}
