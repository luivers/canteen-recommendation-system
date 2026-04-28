package com.school.canteen.service.impl;

import com.school.canteen.entity.Reward;
import com.school.canteen.entity.RewardCategory;
import com.school.canteen.entity.RewardExchange;
import com.school.canteen.entity.User;
import com.school.canteen.entity.PointLog;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.RewardCategoryRepository;
import com.school.canteen.repository.RewardExchangeRepository;
import com.school.canteen.repository.RewardRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.RewardService;
import com.school.canteen.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/** 积分商城奖品管理服务实现类 */
@Service
@RequiredArgsConstructor
public class RewardServiceImpl implements RewardService {
    
    private final RewardRepository rewardRepository;
    private final RewardExchangeRepository rewardExchangeRepository;
    private final RewardCategoryRepository rewardCategoryRepository;
    private final UserRepository userRepository;
    private final UserService userService;

    @Override
    @Transactional
    public Reward createReward(Reward reward) {
        Objects.requireNonNull(reward.getName(), "奖励名称不能为空");
        Objects.requireNonNull(reward.getPointsRequired(), "所需积分不能为空");
        Objects.requireNonNull(reward.getStock(), "库存不能为空");

        if (reward.getName().trim().isEmpty()) {
            throw new RuntimeException("奖励名称不能为空");
        }
        
        if (reward.getPointsRequired() <= 0) {
            throw new RuntimeException("所需积分必须大于0");
        }
        if (reward.getStock() < 0) {
            throw new RuntimeException("库存不能为负数");
        }
        
        if (reward.getStatus() == null) {
            reward.setStatus(Reward.RewardStatus.AVAILABLE);
        }
        if (reward.getExchangeEnabled() == null) {
            reward.setExchangeEnabled(true);
        }
        if (reward.getType() == null) {
            reward.setType(Reward.RewardType.VOUCHER);
        }
        
        return rewardRepository.save(reward);
    }
    
    @Override
    @Transactional
    public Reward updateReward(Long rewardId, Reward reward) {
        Reward existingReward = rewardRepository.findById(rewardId)
                .orElseThrow(() -> new RuntimeException("奖励不存在"));
        
        // 更新字段
        if (reward.getName() != null) {
            if (reward.getName().trim().isEmpty()) {
                throw new RuntimeException("奖励名称不能为空");
            }
            existingReward.setName(reward.getName());
        }
        if (reward.getDescription() != null) existingReward.setDescription(reward.getDescription());
        if (reward.getPointsRequired() != null) {
            if (reward.getPointsRequired() <= 0) {
                throw new RuntimeException("所需积分必须大于0");
            }
            existingReward.setPointsRequired(reward.getPointsRequired());
        }
        if (reward.getStock() != null) {
            if (reward.getStock() < 0) {
                throw new RuntimeException("库存不能为负数");
            }
            existingReward.setStock(reward.getStock());
        }
        if (reward.getImageUrl() != null) existingReward.setImageUrl(reward.getImageUrl());
        if (reward.getStatus() != null) existingReward.setStatus(reward.getStatus());
        if (reward.getCategory() != null) existingReward.setCategory(reward.getCategory());
        if (reward.getType() != null) existingReward.setType(reward.getType());
        if (reward.getFaceValue() != null) existingReward.setFaceValue(reward.getFaceValue());
        if (reward.getMinOrderAmount() != null) existingReward.setMinOrderAmount(reward.getMinOrderAmount());
        if (reward.getValidFrom() != null) existingReward.setValidFrom(reward.getValidFrom());
        if (reward.getValidTo() != null) existingReward.setValidTo(reward.getValidTo());
        if (reward.getDailyLimit() != null) existingReward.setDailyLimit(reward.getDailyLimit());
        if (reward.getPerUserLimit() != null) existingReward.setPerUserLimit(reward.getPerUserLimit());
        if (reward.getExchangeEnabled() != null) existingReward.setExchangeEnabled(reward.getExchangeEnabled());
        if (reward.getAttributes() != null) existingReward.setAttributes(reward.getAttributes());
        
        return rewardRepository.save(existingReward);
    }
    
    @Override
    @Transactional
    public void deleteReward(Long rewardId) {
        Reward reward = rewardRepository.findById(rewardId)
                .orElseThrow(() -> new RuntimeException("奖励不存在"));
        
        // Soft delete: update status to DELETED
        reward.setStatus(Reward.RewardStatus.DELETED);
        rewardRepository.save(reward);
    }
    
    @Override
    public Reward getRewardById(Long rewardId) {
        return rewardRepository.findById(rewardId)
                .orElseThrow(() -> new RuntimeException("奖励不存在"));
    }
    
    @Override
    public List<Reward> getAvailableRewards() {
        return rewardRepository.findByStatus(Reward.RewardStatus.AVAILABLE);
    }
    
    @Override
    public List<Reward> getRewardsByPoints(Integer points) {
        return rewardRepository.findByPointsRequiredLessThanEqualAndStatusOrderByPointsRequiredAsc(
                points, Reward.RewardStatus.AVAILABLE);
    }
    
    @Override
    public List<Reward> searchRewardsByName(String name) {
        return rewardRepository.findByNameContainingIgnoreCase(name);
    }
    
    @Override
    @Transactional
    public RewardExchange exchangeReward(Long userId, Long rewardId) {
        return exchangeReward(userId, rewardId, null);
    }

    @Override
    public Map<String, Object> previewExchange(Long userId, Long rewardId) {
        Reward reward = rewardRepository.findById(rewardId).orElseThrow(() -> new BusinessException("REWARD_NOT_FOUND", "奖励不存在"));
        Integer points = userRepository.findById(userId).map(User::getPoints).orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "用户不存在"));

        Map<String, Object> data = new HashMap<>();
        data.put("rewardId", reward.getId());
        data.put("rewardName", reward.getName());
        data.put("pointsRequired", reward.getPointsRequired());
        data.put("userPoints", points == null ? 0 : points);
        data.put("stock", reward.getStock());

        boolean enabled = reward.getExchangeEnabled() == null || reward.getExchangeEnabled();
        boolean statusOk = Reward.RewardStatus.AVAILABLE.equals(reward.getStatus());
        boolean stockOk = reward.getStock() != null && reward.getStock() > 0;
        boolean pointsOk = (points != null ? points : 0) >= reward.getPointsRequired();
        boolean timeOk = isWithinValidTime(reward, LocalDateTime.now());

        boolean allowed = enabled && statusOk && stockOk && pointsOk && timeOk;
        data.put("exchangeEnabled", enabled);
        data.put("validNow", timeOk);
        data.put("allowed", allowed);

        String blockReason = null;
        if (!enabled) blockReason = "当前不可兑换";
        else if (!statusOk) blockReason = "当前不可兑换";
        else if (!timeOk) blockReason = "已过期或未到可用时间";
        else if (!stockOk) blockReason = "库存不足";
        else if (!pointsOk) blockReason = "积分不足";
        data.put("blockReason", blockReason);

        Integer dailyLimit = reward.getDailyLimit();
        if (dailyLimit != null && dailyLimit > 0) {
            LocalDate today = LocalDate.now();
            long cnt = rewardExchangeRepository.countByUserIdAndRewardIdAndExchangeTimeBetween(
                    userId, rewardId, today.atStartOfDay(), today.atTime(LocalTime.MAX));
            data.put("dailyLimit", dailyLimit);
            data.put("todayExchangedCount", cnt);
            data.put("dailyRemaining", Math.max(0, dailyLimit - cnt));
        }

        Integer perUserLimit = reward.getPerUserLimit();
        if (perUserLimit != null && perUserLimit > 0) {
            long totalCnt = rewardExchangeRepository.countByUserIdAndRewardId(userId, rewardId);
            data.put("perUserLimit", perUserLimit);
            data.put("totalExchangedCount", totalCnt);
            data.put("totalRemaining", Math.max(0, perUserLimit - totalCnt));
        }

        return data;
    }

    @Override
    @Transactional
    public RewardExchange exchangeReward(Long userId, Long rewardId, String requestId) {
        return exchangeReward(userId, rewardId, requestId, null, null, null);
    }

    @Override
    @Transactional
    public RewardExchange exchangeReward(Long userId, Long rewardId, String requestId, String receiverName, String receiverPhone, String receiverAddress) {
        if (requestId != null && !requestId.isBlank()) {
            Optional<RewardExchange> existing = rewardExchangeRepository.findByRequestId(requestId);
            if (existing.isPresent()) {
                RewardExchange ex = existing.get();
                if (ex.getUser() != null && ex.getUser().getId() != null && ex.getUser().getId().equals(userId)) {
                    return ex;
                }
                throw new BusinessException("DUPLICATE_REQUEST", HttpStatus.CONFLICT, "请求已处理");
            }
        }

        Reward reward = rewardRepository.findById(rewardId).orElseThrow(() -> new BusinessException("REWARD_NOT_FOUND", "奖励不存在"));
        if (!Reward.RewardStatus.AVAILABLE.equals(reward.getStatus())) {
            throw new BusinessException("REWARD_UNAVAILABLE", "该奖励不可用");
        }
        if (reward.getExchangeEnabled() != null && !reward.getExchangeEnabled()) {
            throw new BusinessException("REWARD_UNAVAILABLE", "该奖励不可兑换");
        }
        if (!isWithinValidTime(reward, LocalDateTime.now())) {
            throw new BusinessException("REWARD_EXPIRED", "该奖励已过期或未到可用时间");
        }

        // 实物奖品校验收货信息
        if (Reward.RewardType.OTHER.equals(reward.getType())) {
            if (receiverName == null || receiverName.isBlank() || 
                receiverPhone == null || receiverPhone.isBlank() || 
                receiverAddress == null || receiverAddress.isBlank()) {
                throw new BusinessException("MISSING_DELIVERY_INFO", "请填写完整的收货信息");
            }
        }

        Integer dailyLimit = reward.getDailyLimit();
        if (dailyLimit != null && dailyLimit > 0) {
            LocalDate today = LocalDate.now();
            long cnt = rewardExchangeRepository.countByUserIdAndRewardIdAndExchangeTimeBetween(
                    userId, rewardId, today.atStartOfDay(), today.atTime(LocalTime.MAX));
            if (cnt >= dailyLimit) {
                throw new BusinessException("LIMIT_EXCEEDED", "已达到今日兑换上限");
            }
        }
        Integer perUserLimit = reward.getPerUserLimit();
        if (perUserLimit != null && perUserLimit > 0) {
            long totalCnt = rewardExchangeRepository.countByUserIdAndRewardId(userId, rewardId);
            if (totalCnt >= perUserLimit) {
                throw new BusinessException("LIMIT_EXCEEDED", "已达到兑换上限");
            }
        }

        int pointsRequired = reward.getPointsRequired();
        int deducted = userRepository.deductPoints(userId, pointsRequired);
        if (deducted <= 0) {
            throw new BusinessException("INSUFFICIENT_POINTS", "积分不足");
        }

        int stockUpdated = rewardRepository.decrementStockIfAvailable(rewardId, Reward.RewardStatus.AVAILABLE);
        if (stockUpdated <= 0) {
            userRepository.addPoints(userId, pointsRequired);
            throw new BusinessException("OUT_OF_STOCK", "库存不足");
        }
        rewardRepository.markOutOfStockIfNeeded(rewardId, Reward.RewardStatus.OUT_OF_STOCK);

        User user = userRepository.findById(userId).orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "用户不存在"));

        RewardExchange exchange = new RewardExchange();
        exchange.setUser(user);
        exchange.setReward(reward);
        
        // 保存收货信息
        if (receiverName != null) exchange.setReceiverName(receiverName);
        if (receiverPhone != null) exchange.setReceiverPhone(receiverPhone);
        if (receiverAddress != null) exchange.setReceiverAddress(receiverAddress);

        if (Reward.RewardType.VOUCHER.equals(reward.getType())) {
            exchange.setStatus(RewardExchange.ExchangeStatus.COMPLETED);
            exchange.setDeliveryStatus(RewardExchange.DeliveryStatus.DELIVERED);
            exchange.setDeliveryInfo("系统自动发放");
            exchange.setCompleteTime(LocalDateTime.now());
        } else {
            exchange.setStatus(RewardExchange.ExchangeStatus.PENDING);
            exchange.setDeliveryStatus(RewardExchange.DeliveryStatus.PENDING);
        }
        exchange.setRequestId((requestId == null || requestId.isBlank()) ? null : requestId);
        exchange.setPointsUsed(pointsRequired);
        exchange.setFaceValueSnapshot(reward.getFaceValue());
        exchange.setConditionsSnapshot(reward.getAttributes());

        RewardExchange saved = rewardExchangeRepository.save(exchange);
        userService.logSpend(user, pointsRequired, PointLog.PointSource.EXCHANGE, "兑换奖励: " + reward.getName());
        return saved;
    }
    
    @Override
    public List<RewardExchange> getUserExchanges(Long userId) {
        return rewardExchangeRepository.findByUserId(userId);
    }
    
    @Override
    public List<RewardExchange> getExchangesByStatus(RewardExchange.ExchangeStatus status) {
        return rewardExchangeRepository.findByStatus(status);
    }
    
    @Override
    @Transactional
    public void updateExchangeStatus(Long exchangeId, RewardExchange.ExchangeStatus status) {
        RewardExchange exchange = rewardExchangeRepository.findById(exchangeId)
                .orElseThrow(() -> new RuntimeException("兑换记录不存在"));
        
        // 如果状态从PENDING变为CANCELLED，返回积分和库存
        if (RewardExchange.ExchangeStatus.PENDING.equals(exchange.getStatus()) &&
                (RewardExchange.ExchangeStatus.CANCELLED.equals(status) || RewardExchange.ExchangeStatus.FAILED.equals(status))) {
            
            User user = exchange.getUser();
            Reward reward = exchange.getReward();
            
            int pointsToRefund = exchange.getPointsUsed() != null ? exchange.getPointsUsed() : reward.getPointsRequired();
            userRepository.addPoints(user.getId(), pointsToRefund);
            
            // 记录积分返还日志
            String desc = RewardExchange.ExchangeStatus.CANCELLED.equals(status) ? "兑换取消返还: " : "兑换失败返还: ";
            userService.logEarn(user, pointsToRefund, PointLog.PointSource.EXCHANGE, desc + reward.getName());
            
            // 返回奖励库存
            rewardRepository.incrementStock(reward.getId());
            rewardRepository.markAvailableIfRestocked(reward.getId(), Reward.RewardStatus.AVAILABLE, Reward.RewardStatus.OUT_OF_STOCK);
        }
        
        // 如果状态变为COMPLETED，更新完成时间
        if (RewardExchange.ExchangeStatus.COMPLETED.equals(status)) {
            exchange.setCompleteTime(LocalDateTime.now());
        }
        
        // 更新兑换状态
        exchange.setStatus(status);
        rewardExchangeRepository.save(exchange);
    }
    
    @Override
    public Long countUserExchanges(Long userId, RewardExchange.ExchangeStatus status) {
        return rewardExchangeRepository.countByUserIdAndStatus(userId, status);
    }

    @Override
    public Page<Reward> getRewardsPage(Long categoryId, String keyword, Reward.RewardStatus status, Boolean onlyRedeemable, Pageable pageable) {
        Specification<Reward> spec = (root, query, cb) -> {
            var predicates = cb.conjunction();
            if (categoryId != null) {
                predicates = cb.and(predicates, cb.equal(root.get("category").get("id"), categoryId));
            }
            if (keyword != null && !keyword.isBlank()) {
                predicates = cb.and(predicates, cb.like(cb.lower(root.get("name")), "%" + keyword.trim().toLowerCase() + "%"));
            }
            if (status != null) {
                predicates = cb.and(predicates, cb.equal(root.get("status"), status));
            } else {
                // If status not specified, exclude DELETED
                predicates = cb.and(predicates, cb.notEqual(root.get("status"), Reward.RewardStatus.DELETED));
            }
            // predicates = cb.and(predicates, cb.equal(root.get("type"), Reward.RewardType.VOUCHER));
            if (Boolean.TRUE.equals(onlyRedeemable)) {
                predicates = cb.and(predicates, cb.equal(root.get("status"), Reward.RewardStatus.AVAILABLE));
                predicates = cb.and(predicates, cb.greaterThan(root.get("stock"), 0));
                predicates = cb.and(predicates, cb.or(cb.isNull(root.get("exchangeEnabled")), cb.isTrue(root.get("exchangeEnabled"))));
                LocalDateTime now = LocalDateTime.now();
                predicates = cb.and(predicates, cb.or(cb.isNull(root.get("validFrom")), cb.lessThanOrEqualTo(root.get("validFrom"), now)));
                predicates = cb.and(predicates, cb.or(cb.isNull(root.get("validTo")), cb.greaterThanOrEqualTo(root.get("validTo"), now)));
            }
            return predicates;
        };
        return rewardRepository.findAll(spec, pageable);
    }

    @Override
    public List<RewardCategory> getEnabledCategories() {
        return rewardCategoryRepository.findByStatusOrderBySortOrderAsc(RewardCategory.CategoryStatus.ENABLED);
    }

    @Override
    public Page<RewardExchange> getUserExchangesPage(Long userId, RewardExchange.ExchangeStatus status, LocalDateTime start, LocalDateTime end, Pageable pageable) {
        Specification<RewardExchange> spec = (root, query, cb) -> {
            var predicates = cb.conjunction();
            predicates = cb.and(predicates, cb.equal(root.get("user").get("id"), userId));
            if (status != null) {
                predicates = cb.and(predicates, cb.equal(root.get("status"), status));
            }
            if (start != null) {
                predicates = cb.and(predicates, cb.greaterThanOrEqualTo(root.get("exchangeTime"), start));
            }
            if (end != null) {
                predicates = cb.and(predicates, cb.lessThanOrEqualTo(root.get("exchangeTime"), end));
            }
            return predicates;
        };
        return rewardExchangeRepository.findAll(spec, pageable);
    }

    private boolean isWithinValidTime(Reward reward, LocalDateTime now) {
        if (reward.getValidFrom() != null && now.isBefore(reward.getValidFrom())) return false;
        if (reward.getValidTo() != null && now.isAfter(reward.getValidTo())) return false;
        return true;
    }
}
