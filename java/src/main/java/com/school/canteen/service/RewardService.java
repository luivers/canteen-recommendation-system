package com.school.canteen.service;

import com.school.canteen.entity.Reward;
import com.school.canteen.entity.RewardCategory;
import com.school.canteen.entity.RewardExchange;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** 积分商城奖品管理服务接口 */
public interface RewardService {
    // 奖励管理
    Reward createReward(Reward reward);
    Reward updateReward(Long rewardId, Reward reward);
    void deleteReward(Long rewardId);
    Reward getRewardById(Long rewardId);
    
    // 查询奖励
    List<Reward> getAvailableRewards();
    List<Reward> getRewardsByPoints(Integer points);
    List<Reward> searchRewardsByName(String name);

    Page<Reward> getRewardsPage(Long categoryId, String keyword, Reward.RewardStatus status, Boolean onlyRedeemable, Pageable pageable);

    List<RewardCategory> getEnabledCategories();
    
    // 奖励兑换
    RewardExchange exchangeReward(Long userId, Long rewardId);
    Map<String, Object> previewExchange(Long userId, Long rewardId);
    RewardExchange exchangeReward(Long userId, Long rewardId, String requestId);
    RewardExchange exchangeReward(Long userId, Long rewardId, String requestId, String receiverName, String receiverPhone, String receiverAddress);
    
    // 兑换记录管理
    List<RewardExchange> getUserExchanges(Long userId);
    List<RewardExchange> getExchangesByStatus(RewardExchange.ExchangeStatus status);
    void updateExchangeStatus(Long exchangeId, RewardExchange.ExchangeStatus status);
    Page<RewardExchange> getUserExchangesPage(Long userId, RewardExchange.ExchangeStatus status, LocalDateTime start, LocalDateTime end, Pageable pageable);
    
    // 统计
    Long countUserExchanges(Long userId, RewardExchange.ExchangeStatus status);
}
