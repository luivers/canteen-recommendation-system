package com.school.canteen.repository;

import com.school.canteen.entity.ReviewRewardRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

/** 评价奖励记录数据访问层 */
@Repository
public interface ReviewRewardRecordRepository extends JpaRepository<ReviewRewardRecord, Long> {
    
    // 统计某用户在指定时间段内触发某规则的次数
    @Query("SELECT COUNT(r) FROM ReviewRewardRecord r WHERE r.user.id = :userId AND r.rule.id = :ruleId AND r.createTime >= :startTime AND r.createTime <= :endTime")
    long countByUserIdAndRuleIdAndCreateTimeBetween(
            @Param("userId") Long userId, 
            @Param("ruleId") Long ruleId, 
            @Param("startTime") LocalDateTime startTime, 
            @Param("endTime") LocalDateTime endTime);
            
    // 检查该评论是否已经发放过某规则的奖励
    boolean existsByReviewIdAndRuleId(Long reviewId, Long ruleId);

    void deleteByReviewId(Long reviewId);
}
