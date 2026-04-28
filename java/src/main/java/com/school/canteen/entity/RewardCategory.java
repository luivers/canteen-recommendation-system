package com.school.canteen.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

/** 奖品分类实体 — 对奖品/代金券进行分类管理 */
@Entity
@Table(
        name = "reward_categories",
        indexes = {
                @Index(name = "idx_reward_categories_status_sort", columnList = "status,sortOrder")
        }
)
@Data
public class RewardCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    private Integer sortOrder = 0;

    @Enumerated(EnumType.STRING)
    private CategoryStatus status = CategoryStatus.ENABLED;

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

    public enum CategoryStatus {
        ENABLED,
        DISABLED
    }
}
