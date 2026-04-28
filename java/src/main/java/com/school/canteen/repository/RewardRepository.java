package com.school.canteen.repository;

import com.school.canteen.entity.Reward;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/** 积分商城奖品数据访问层 */
@Repository
public interface RewardRepository extends JpaRepository<Reward, Long>, JpaSpecificationExecutor<Reward> {
    
    // 根据状态查询奖励
    List<Reward> findByStatus(Reward.RewardStatus status);
    
    // 根据积分查询可兑换奖励
    @Query("SELECT r FROM Reward r WHERE r.pointsRequired <= :points AND r.status = :status ORDER BY r.pointsRequired ASC")
    List<Reward> findByPointsRequiredLessThanEqualAndStatusOrderByPointsRequiredAsc(
            @Param("points") Integer points, 
            @Param("status") Reward.RewardStatus status);
    
    // 根据名称模糊查询
    List<Reward> findByNameContainingIgnoreCase(String name);

    Optional<Reward> findFirstByTypeAndFaceValue(Reward.RewardType type, BigDecimal faceValue);

    @Modifying
    @Query("UPDATE Reward r SET r.stock = r.stock - 1 WHERE r.id = :rewardId AND r.status = :status AND r.stock > 0")
    int decrementStockIfAvailable(@Param("rewardId") Long rewardId, @Param("status") Reward.RewardStatus status);

    @Modifying
    @Query("UPDATE Reward r SET r.stock = r.stock + 1 WHERE r.id = :rewardId")
    int incrementStock(@Param("rewardId") Long rewardId);

    @Modifying
    @Query("UPDATE Reward r SET r.status = :outStatus WHERE r.id = :rewardId AND r.stock <= 0")
    int markOutOfStockIfNeeded(@Param("rewardId") Long rewardId, @Param("outStatus") Reward.RewardStatus outStatus);

    @Modifying
    @Query("UPDATE Reward r SET r.status = :availableStatus WHERE r.id = :rewardId AND r.stock > 0 AND r.status = :outStatus")
    int markAvailableIfRestocked(@Param("rewardId") Long rewardId, @Param("availableStatus") Reward.RewardStatus availableStatus, @Param("outStatus") Reward.RewardStatus outStatus);
}
