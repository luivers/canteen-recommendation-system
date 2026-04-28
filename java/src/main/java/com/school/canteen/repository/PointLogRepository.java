package com.school.canteen.repository;

import com.school.canteen.entity.PointLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 积分记录数据访问层 */
@Repository
public interface PointLogRepository extends JpaRepository<PointLog, Long> {
    
    // 查询用户的积分记录，按时间倒序
    Page<PointLog> findByUserIdOrderByCreateTimeDesc(Long userId, Pageable pageable);
    
    // 根据来源查询
    List<PointLog> findByUserIdAndSource(Long userId, PointLog.PointSource source);
}
