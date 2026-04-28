package com.school.canteen.repository;

import com.school.canteen.entity.RewardCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 奖品分类数据访问层 */
@Repository
public interface RewardCategoryRepository extends JpaRepository<RewardCategory, Long> {
    List<RewardCategory> findByStatusOrderBySortOrderAsc(RewardCategory.CategoryStatus status);
}
