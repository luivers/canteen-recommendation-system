package com.school.canteen.repository;

import com.school.canteen.entity.Promotion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 促销活动数据访问层 */
@Repository
public interface PromotionRepository extends JpaRepository<Promotion, Long>, JpaSpecificationExecutor<Promotion> {

    // 根据状态查询促销活动
    List<Promotion> findByStatus(String status);

    // 根据类型查询促销活动
    List<Promotion> findByType(String type);

    // 查询热门促销活动
    List<Promotion> findByIsHotTrueAndStatus(String status);

    // 查询当前活跃的促销活动（根据时间和状态）
    @Query("SELECT p FROM Promotion p WHERE p.status = 'active' AND p.startTime <= CURRENT_TIMESTAMP AND p.endTime >= CURRENT_TIMESTAMP")
    List<Promotion> findActivePromotions();
}