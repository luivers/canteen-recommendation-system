package com.school.canteen.entity;

import lombok.Data;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/** 评价奖励发放记录实体 — 记录每次评价奖励的积分数和触发规则 */
@Entity
@Table(name = "review_reward_records")
@Data
public class ReviewRewardRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "review_id", nullable = false)
    private Review review;

    @ManyToOne
    @JoinColumn(name = "rule_id", nullable = false)
    private ReviewRewardRule rule;

    @Column(nullable = false)
    private Integer pointsAwarded; // 实际发放积分

    private LocalDateTime createTime;

    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
}
