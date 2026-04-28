package com.school.canteen.repository;

import com.school.canteen.entity.RewardExchange;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/** 奖品兑换记录数据访问层 */
@Repository
public interface RewardExchangeRepository extends JpaRepository<RewardExchange, Long>, JpaSpecificationExecutor<RewardExchange> {
    
    // 根据用户ID查询兑换记录
    List<RewardExchange> findByUserId(Long userId);
    
    // 根据状态查询兑换记录
    List<RewardExchange> findByStatus(RewardExchange.ExchangeStatus status);
    
    // 统计用户的兑换数量
    Long countByUserIdAndStatus(Long userId, RewardExchange.ExchangeStatus status);
    
    // 根据状态和用户ID查询兑换记录
    List<RewardExchange> findByUserIdAndStatus(Long userId, RewardExchange.ExchangeStatus status);

    Optional<RewardExchange> findByRequestId(String requestId);

    long countByUserIdAndRewardIdAndExchangeTimeBetween(Long userId, Long rewardId, LocalDateTime start, LocalDateTime end);

    long countByUserIdAndRewardId(Long userId, Long rewardId);

    boolean existsByRewardId(Long rewardId);

    void deleteByRewardId(Long rewardId);

    long countByExchangeTimeBetween(LocalDateTime start, LocalDateTime end);

    @Query("SELECT COALESCE(SUM(e.pointsUsed), 0) FROM RewardExchange e WHERE e.exchangeTime BETWEEN :start AND :end AND e.status <> :cancelStatus")
    long sumPointsUsedBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end, @Param("cancelStatus") RewardExchange.ExchangeStatus cancelStatus);

    @Query("SELECT COALESCE(SUM(e.faceValueSnapshot), 0) FROM RewardExchange e WHERE e.exchangeTime BETWEEN :start AND :end AND e.status <> :cancelStatus")
    BigDecimal sumFaceValueBetween(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end, @Param("cancelStatus") RewardExchange.ExchangeStatus cancelStatus);

    @Modifying
    @Query("""
            UPDATE RewardExchange e
            SET e.used = true, e.usedTime = :usedTime, e.usedOrderId = :orderId, e.deductionAmount = :deductionAmount
            WHERE e.id = :exchangeId
              AND e.user.id = :userId
              AND e.status = :completedStatus
              AND (e.used IS NULL OR e.used = false)
            """)
    int consumeVoucher(
            @Param("exchangeId") Long exchangeId,
            @Param("userId") Long userId,
            @Param("orderId") Long orderId,
            @Param("usedTime") LocalDateTime usedTime,
            @Param("deductionAmount") BigDecimal deductionAmount,
            @Param("completedStatus") RewardExchange.ExchangeStatus completedStatus
    );

    @Modifying
    @Query("""
            UPDATE RewardExchange e
            SET e.used = false, e.usedTime = NULL, e.usedOrderId = NULL, e.deductionAmount = NULL
            WHERE e.id = :exchangeId
              AND e.usedOrderId = :orderId
              AND e.used = true
            """)
    int releaseVoucher(@Param("exchangeId") Long exchangeId, @Param("orderId") Long orderId);
}
