package com.school.canteen.service;

import com.school.canteen.entity.Review;
import com.school.canteen.entity.ReviewRewardRule;
import java.util.List;

/** 评价奖励服务接口，处理评价后的积分奖励发放 */
public interface ReviewRewardService {
    /**
     * 计算并为评论发放奖励 (异步)
     */
    void processReviewReward(Review review);

    /**
     * 计算并为评论发放奖励（推荐使用：按ID触发，避免跨线程传递实体）
     */
    void processReviewReward(Long reviewId);

    /**
     * 获取所有奖励规则
     */
    List<ReviewRewardRule> getAllRules();
    
    /**
     * 创建/更新奖励规则
     */
    ReviewRewardRule saveRule(ReviewRewardRule rule);
    
    /**
     * 初始化默认规则
     */
    void initDefaultRules();
}
