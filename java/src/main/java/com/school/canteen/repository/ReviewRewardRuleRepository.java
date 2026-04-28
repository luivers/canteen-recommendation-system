package com.school.canteen.repository;

import com.school.canteen.entity.ReviewRewardRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/** 评价奖励规则数据访问层 */
@Repository
public interface ReviewRewardRuleRepository extends JpaRepository<ReviewRewardRule, Long> {
    Optional<ReviewRewardRule> findByRuleCode(String ruleCode);
}
