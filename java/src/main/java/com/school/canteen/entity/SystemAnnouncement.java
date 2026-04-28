package com.school.canteen.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/** 系统公告实体 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "system_announcements")
public class SystemAnnouncement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, length = 4000)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AnnouncementStatus status = AnnouncementStatus.DRAFT;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(nullable = false)
    private Integer priority = 0;

    @Column(name = "creator_id")
    private Long creatorId;

    @Column(name = "target_role", length = 20)
    private String targetRole;

    @Column(name = "target_canteen_id")
    private Long targetCanteenId;

    @Column(name = "target_window_id")
    private Long targetWindowId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

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

    public enum AnnouncementStatus {
        DRAFT,
        PUBLISHED,
        OFFLINE
    }
}

