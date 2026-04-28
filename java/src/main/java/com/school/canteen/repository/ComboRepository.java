package com.school.canteen.repository;

import com.school.canteen.entity.Combo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 套餐数据访问层 */
@Repository
public interface ComboRepository extends JpaRepository<Combo, Long> {

    // 根据促销活动ID查询套餐
    List<Combo> findByPromotionId(Long promotionId);

    // 根据状态查询套餐
    List<Combo> findByStatus(String status);

    // 根据促销活动ID和状态查询套餐
    List<Combo> findByPromotionIdAndStatus(Long promotionId, String status);
}