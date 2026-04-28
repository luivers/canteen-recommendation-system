package com.school.canteen.entity;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;
import jakarta.persistence.*;
import com.school.canteen.config.StringListJsonConverter;
import java.time.LocalDateTime;
import java.util.List;

/** 评价实体 — 支持多维度评分（口味、分量、价格、卫生）、图片、快捷标签、食堂回复 */
@Entity
@Table(name = "reviews")
@Data
public class Review {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private User user;
    
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "order_id", nullable = false, unique = true)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Order order;
    
    // 多维度评分
    private Integer tasteRating; // 口味评分 1-5
    private Integer portionRating; // 分量评分 1-5
    private Integer priceRating; // 价格评分 1-5
    private Integer hygieneRating; // 卫生评分 1-5
    
    private Double overallRating; // 综合评分
    
    private String comment; // 文字评价
    
    // 多张图片支持
    @Convert(converter = StringListJsonConverter.class)
    @Column(name = "image_url", columnDefinition = "TEXT")
    private List<String> imageUrls = new java.util.ArrayList<>(); // 评价图片列表
    
    // 快捷标签
    @ElementCollection
    @CollectionTable(name = "review_quick_tags")
    @Column(name = "quick_tag")
    private List<String> quickTags = new java.util.ArrayList<>(); // "太咸"、"分量足"等
    
    // 食堂回复
    private String canteenReply;
    private LocalDateTime replyTime;

    @OneToMany(mappedBy = "review", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<ReviewItem> items = new java.util.ArrayList<>();
    
    // 评价状态
    @Enumerated(EnumType.STRING)
    private ReviewStatus status = ReviewStatus.NORMAL; // 评价状态
    
    // 奖励系统字段
    private Integer qualityScore; // 质量评分 0-100
    private boolean isRewarded = false; // 是否已发放奖励
    
    private LocalDateTime createTime;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
        // 计算综合评分
        if (tasteRating != null && portionRating != null && 
            priceRating != null && hygieneRating != null) {
            overallRating = (tasteRating + portionRating + priceRating + hygieneRating) / 4.0;
        }
    }
    
    // 评价状态枚举
    public enum ReviewStatus {
        NORMAL, // 正常
        SPAM, // 垃圾评价
        REMOVED, // 已删除
        WARNING, // 预警
        HIDDEN // 已隐藏
    }
}
