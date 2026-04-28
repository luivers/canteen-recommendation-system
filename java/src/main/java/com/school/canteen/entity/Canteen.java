package com.school.canteen.entity;

import lombok.Data;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/** 食堂实体 */
@Entity
@Table(name = "canteens")
@Data
public class Canteen {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String name; // 食堂名称
    
    private String location; // 食堂位置
    
    private String description; // 食堂描述
    
    private Integer floorCount; // 楼层数
    
    private LocalDateTime createTime;
    
    private LocalDateTime updateTime;
    
    // 关联窗口 - 暂时移除，因为Window实体不再是JPA实体

    
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