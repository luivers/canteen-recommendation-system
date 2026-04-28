package com.school.canteen.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** 用户画像扩展实体 — 存储用户的详细个人信息（身高、体重、生日等） */
@Entity
@Table(name = "user_profile")
@Data
public class UserProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "dietary_restrictions", columnDefinition = "TEXT")
    private String dietaryRestrictions;

    @Column(name = "flavor_preferences", columnDefinition = "TEXT")
    private String flavorPreferences;

    @Column(name = "allergies", columnDefinition = "TEXT")
    private String allergies;

    @Column(name = "birthday")
    private LocalDate birthday;

    @Column(name = "is_vegetarian")
    private Boolean isVegetarian;

    @Column(name = "is_halal")
    private Boolean isHalal;

    @Column(name = "spice_tolerance")
    private Integer spiceTolerance;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

