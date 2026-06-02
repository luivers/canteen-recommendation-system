package com.school.canteen.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

/** 用户实体 — 包含学号、角色（学生/窗口管理员/管理员）、口味偏好、积分等 */
@Entity
@Table(name = "users")
@Data
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String studentId; // 学号

    @Column(unique = true)
    private String miniappOpenid; // 微信小程序 openid
    
    @Column(nullable = false)
    private String username;
    
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(nullable = false)
    private String password;
    
    private String phone;
    private String email;

    @Column(columnDefinition = "TEXT")
    private String avatar;
    
    @Enumerated(EnumType.STRING)
    private UserRole role = UserRole.STUDENT; // 用户角色

    @Column(nullable = false)
    private String status = "active"; // 状态：active-正常, inactive-禁用
    
    // 口味偏好
    private Integer spicinessLevel = 3; // 辣度等级 1-5
    private Integer sweetnessLevel = 3; // 甜度等级 1-5
    private String dietaryRestrictions; // 忌口信息
    
    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private UserProfile userProfile;
    
    @Transient
    private Set<String> dietaryTags = new HashSet<>(); // 素食、健身餐、低脂等

    @Transient
    private Long totalOrders = 0L;

    @Transient
    private BigDecimal totalSpent = BigDecimal.ZERO;
    
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    
    // 积分相关字段
    private Integer points = 0; // 积分
    private LocalDateTime lastReviewTime; // 上次评价时间
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
        updateTime = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updateTime = LocalDateTime.now();
    }
    
    public enum UserRole {
        STUDENT, // 学生
        WINDOW_MANAGER, // 窗口负责人
        ADMIN // 管理员
    }
}
