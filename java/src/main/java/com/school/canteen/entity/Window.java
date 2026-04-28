package com.school.canteen.entity;

import lombok.Data;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/** 食堂窗口实体 — 属于某个食堂，包含窗口名称、位置、负责人等 */
@Entity
@Table(name = "windows")
@Data
public class Window {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String name;
    
    @Column(length = 255)
    private String location;
    
    @Column(name = "manager_id")
    private Long managerId;
    
    @Column(name = "manager_name")
    private String managerName;
    
    @Column(name = "operating_hours", length = 100)
    private String operatingHours;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private WindowStatus status = WindowStatus.OPEN;
    
    @Column(name = "canteen_id")
    private Long canteenId;
    
    @Column(name = "canteen_name")
    private String canteenName;
    
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
    
    public enum WindowStatus {
        OPEN, CLOSED, MAINTENANCE
    }
}