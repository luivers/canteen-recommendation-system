package com.school.canteen.repository;

import com.school.canteen.entity.SystemAnnouncement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/** 系统公告数据访问层 */
@Repository
public interface SystemAnnouncementRepository extends JpaRepository<SystemAnnouncement, Long> {

    @Query("""
        SELECT a FROM SystemAnnouncement a
        WHERE a.status = :status
          AND (:now BETWEEN COALESCE(a.startTime, :now) AND COALESCE(a.endTime, :now))
        ORDER BY a.priority DESC, a.updatedAt DESC
    """)
    List<SystemAnnouncement> findEffectiveAnnouncements(@Param("status") SystemAnnouncement.AnnouncementStatus status, @Param("now") LocalDateTime now);

    @Query("""
        SELECT a FROM SystemAnnouncement a
        WHERE (:keyword IS NULL OR :keyword = '' 
           OR LOWER(a.title) LIKE LOWER(CONCAT('%', :keyword, '%')) 
           OR LOWER(a.content) LIKE LOWER(CONCAT('%', :keyword, '%')))
        ORDER BY a.updatedAt DESC
    """)
    List<SystemAnnouncement> searchForAdmin(@Param("keyword") String keyword, Pageable pageable);

    Page<SystemAnnouncement> findByStatusOrderByUpdatedAtDesc(SystemAnnouncement.AnnouncementStatus status, Pageable pageable);
}
