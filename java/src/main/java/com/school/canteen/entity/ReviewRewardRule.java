package com.school.canteen.entity;

import lombok.Data;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/** 评价奖励规则实体 — 定义不同评价行为对应的积分奖励规则 */
@Entity
@Table(name = "review_reward_rules")
@Data
public class ReviewRewardRule {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String ruleCode; // 规则代码 (e.g., BASIC_REVIEW, IMAGE_REVIEW, LONG_TEXT)

    @Column(nullable = false)
    private String ruleName; // 规则名称

    @Column(nullable = false)
    private Integer points; // 奖励积分基础值

    private Integer dailyLimit; // 每日触发上限 (次数)，null表示不限

    private String description;

    private boolean isActive = true;
    
    // 特殊时段配置 (活动期间)
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    
    // 权重/倍率 (用于活动期间)
    private Double multiplier = 1.0;

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
