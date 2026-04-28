package com.school.canteen.controller;

import com.school.canteen.exception.BusinessException;
import com.school.canteen.entity.Reward;
import com.school.canteen.entity.RewardCategory;
import com.school.canteen.entity.RewardExchange;
import com.school.canteen.repository.RewardExchangeRepository;
import com.school.canteen.service.RewardService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

/** 奖品/代金券控制器（用户端） — 奖品浏览、积分兑换、我的代金券、可用代金券查询 */
@RestController
@RequestMapping("/api/rewards")
@RequiredArgsConstructor
public class RewardController {
    
    private final RewardService rewardService;
    private final RewardExchangeRepository rewardExchangeRepository;
    
    // 创建奖励
    @PostMapping
    public ResponseEntity<?> createReward(@RequestBody Reward reward) {
        try {
            Reward createdReward = rewardService.createReward(reward);
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                    "data", createdReward,
                    "message", "奖励创建成功",
                    "code", "REWARD_CREATED"
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REWARD_CREATE_FAILED"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "message", "创建奖励时发生错误",
                    "code", "INTERNAL_ERROR"
            ));
        }
    }
    
    // 更新奖励
    @PutMapping("/{rewardId}")
    public ResponseEntity<?> updateReward(@PathVariable Long rewardId, @RequestBody Reward reward) {
        try {
            Reward updatedReward = rewardService.updateReward(rewardId, reward);
            return ResponseEntity.ok(Map.of(
                    "data", updatedReward,
                    "message", "奖励更新成功",
                    "code", "REWARD_UPDATED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REWARD_UPDATE_FAILED"
            ));
        }
    }
    
    // 删除奖励
    @DeleteMapping("/{rewardId}")
    public ResponseEntity<?> deleteReward(@PathVariable Long rewardId) {
        try {
            rewardService.deleteReward(rewardId);
            return ResponseEntity.ok(Map.of(
                    "message", "奖励删除成功",
                    "code", "REWARD_DELETED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REWARD_DELETE_FAILED"
            ));
        }
    }
    
    // 获取奖励详情
    @GetMapping("/{rewardId}")
    public ResponseEntity<?> getRewardById(@PathVariable Long rewardId) {
        try {
            Reward reward = rewardService.getRewardById(rewardId);
            return ResponseEntity.ok(Map.of(
                    "data", reward,
                    "message", "获取奖励成功",
                    "code", "REWARD_FETCHED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REWARD_FETCH_FAILED"
            ));
        }
    }
    
    // 获取可用奖励列表
    @GetMapping
    public ResponseEntity<?> getAvailableRewards() {
        try {
            List<Reward> rewards = rewardService.getAvailableRewards();
            return ResponseEntity.ok(Map.of(
                    "data", rewards,
                    "message", "获取可用奖励成功",
                    "code", "AVAILABLE_REWARDS_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取可用奖励失败",
                    "code", "AVAILABLE_REWARDS_FETCH_FAILED"
            ));
        }
    }

    @GetMapping("/categories")
    public ResponseEntity<?> getEnabledCategories() {
        List<RewardCategory> categories = rewardService.getEnabledCategories();
        return ResponseEntity.ok(Map.of(
                "data", categories,
                "message", "获取分类成功",
                "code", "REWARD_CATEGORIES_FETCHED"
        ));
    }

    @GetMapping("/page")
    public ResponseEntity<?> getRewardsPage(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Reward.RewardStatus status,
            @RequestParam(required = false) Boolean onlyRedeemable) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Reward> rewards = rewardService.getRewardsPage(categoryId, keyword, status, onlyRedeemable, pageable);
        return ResponseEntity.ok(Map.of(
                "data", Map.of(
                        "content", rewards.getContent(),
                        "total", rewards.getTotalElements(),
                        "totalPages", rewards.getTotalPages()
                ),
                "message", "获取可兑换列表成功",
                "code", "REWARDS_PAGE_FETCHED"
        ));
    }
    
    // 根据积分获取可兑换奖励
    @GetMapping("/by-points/{points}")
    public ResponseEntity<?> getRewardsByPoints(@PathVariable Integer points) {
        try {
            List<Reward> rewards = rewardService.getRewardsByPoints(points);
            return ResponseEntity.ok(Map.of(
                    "data", rewards,
                    "message", "获取可兑换奖励成功",
                    "code", "REWARDS_BY_POINTS_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取可兑换奖励失败",
                    "code", "REWARDS_BY_POINTS_FETCH_FAILED"
            ));
        }
    }
    
    // 根据名称搜索奖励
    @GetMapping("/search")
    public ResponseEntity<?> searchRewardsByName(@RequestParam String name) {
        try {
            List<Reward> rewards = rewardService.searchRewardsByName(name);
            return ResponseEntity.ok(Map.of(
                    "data", rewards,
                    "message", "搜索奖励成功",
                    "code", "REWARDS_SEARCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "搜索奖励失败",
                    "code", "REWARDS_SEARCH_FAILED"
            ));
        }
    }
    
    // 兑换奖励
    @PostMapping("/exchange")
    public ResponseEntity<?> exchangeReward(@RequestBody Map<String, Object> exchangeData) {
        try {
            Object rewardIdObj = exchangeData.get("rewardId");
            Long rewardId = (rewardIdObj instanceof Number) ? ((Number) rewardIdObj).longValue() : null;

            Object requestIdObj = exchangeData.get("requestId");
            String requestId = requestIdObj == null ? null : String.valueOf(requestIdObj);
            
            String receiverName = (String) exchangeData.get("receiverName");
            String receiverPhone = (String) exchangeData.get("receiverPhone");
            String receiverAddress = (String) exchangeData.get("receiverAddress");

            if (rewardId == null) {
                return ResponseEntity.badRequest().body(Map.of(
                        "message", "奖励ID不能为空",
                        "code", "MISSING_REQUIRED_PARAMS"
                ));
            }

            Long userId = requireCurrentUserId();
            RewardExchange exchange = rewardService.exchangeReward(userId, rewardId, requestId, receiverName, receiverPhone, receiverAddress);
            return ResponseEntity.ok(Map.of(
                    "data", exchange,
                    "message", "兑换成功",
                    "code", "REWARD_EXCHANGED"
            ));
        } catch (BusinessException e) {
            return ResponseEntity.status(e.getHttpStatus() != null ? e.getHttpStatus() : HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "message", e.getMessage(),
                    "code", e.getCode()
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REWARD_EXCHANGE_FAILED"
            ));
        }
    }

    @PostMapping("/exchange/preview")
    public ResponseEntity<?> previewExchange(@RequestBody Map<String, Long> payload) {
        Long rewardId = payload.get("rewardId");
        if (rewardId == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "奖励ID不能为空",
                    "code", "MISSING_REQUIRED_PARAMS"
            ));
        }
        Long userId = requireCurrentUserId();
        Map<String, Object> data = rewardService.previewExchange(userId, rewardId);
        return ResponseEntity.ok(Map.of(
                "data", data,
                "message", "兑换确认信息获取成功",
                "code", "EXCHANGE_PREVIEW_FETCHED"
        ));
    }

    @GetMapping("/exchanges/page")
    public ResponseEntity<?> getMyExchangesPage(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long userId = requireCurrentUserId();
        RewardExchange.ExchangeStatus exchangeStatus = null;
        if (status != null && !status.isBlank()) {
            exchangeStatus = RewardExchange.ExchangeStatus.valueOf(status.trim().toUpperCase());
        }
        LocalDateTime start = startDate == null ? null : startDate.atStartOfDay();
        LocalDateTime end = endDate == null ? null : endDate.atTime(LocalTime.MAX);
        Pageable pageable = PageRequest.of(page, size);
        Page<RewardExchange> p = rewardService.getUserExchangesPage(userId, exchangeStatus, start, end, pageable);
        return ResponseEntity.ok(Map.of(
                "data", Map.of(
                        "content", p.getContent(),
                        "total", p.getTotalElements(),
                        "totalPages", p.getTotalPages()
                ),
                "message", "获取兑换记录成功",
                "code", "EXCHANGES_PAGE_FETCHED"
        ));
    }

    @GetMapping("/vouchers/my")
    public ResponseEntity<?> getMyVouchersPage(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Boolean used,
            @RequestParam(required = false) String status
    ) {
        Long userId = requireCurrentUserId();
        final RewardExchange.ExchangeStatus st = (status != null && !status.isBlank()) 
                ? RewardExchange.ExchangeStatus.valueOf(status.trim().toUpperCase()) 
                : null;
        
        Pageable pageable = PageRequest.of(page, size);
        Page<RewardExchange> p = rewardExchangeRepository.findAll((root, query, cb) -> {
            var predicates = cb.conjunction();
            predicates = cb.and(predicates, cb.equal(root.get("user").get("id"), userId));
            predicates = cb.and(predicates, cb.equal(root.get("reward").get("type"), Reward.RewardType.VOUCHER));
            if (used != null) {
                if (used) {
                    predicates = cb.and(predicates, cb.isTrue(root.get("used")));
                } else {
                    predicates = cb.and(predicates, cb.or(cb.isFalse(root.get("used")), cb.isNull(root.get("used"))));
                }
            }
            if (st != null) {
                predicates = cb.and(predicates, cb.equal(root.get("status"), st));
            }
            return predicates;
        }, pageable);
        return ResponseEntity.ok(Map.of(
                "data", Map.of("content", p.getContent(), "total", p.getTotalElements(), "totalPages", p.getTotalPages()),
                "message", "获取我的代金券成功",
                "code", "MY_VOUCHERS_FETCHED"
        ));
    }

    @GetMapping("/vouchers/usable")
    public ResponseEntity<?> getUsableVouchers(@RequestParam BigDecimal amount) {
        Long userId = requireCurrentUserId();
        BigDecimal orderAmount = amount == null ? BigDecimal.ZERO : amount;
        LocalDateTime now = LocalDateTime.now();
        List<RewardExchange> rows = rewardExchangeRepository.findAll((root, query, cb) -> {
            var predicates = cb.conjunction();
            predicates = cb.and(predicates, cb.equal(root.get("user").get("id"), userId));
            predicates = cb.and(predicates, cb.equal(root.get("reward").get("type"), Reward.RewardType.VOUCHER));
            predicates = cb.and(predicates, cb.equal(root.get("status"), RewardExchange.ExchangeStatus.COMPLETED));
            predicates = cb.and(predicates, cb.or(cb.isFalse(root.get("used")), cb.isNull(root.get("used"))));

            var reward = root.get("reward");
            predicates = cb.and(predicates, cb.or(cb.isNull(reward.get("validFrom")), cb.lessThanOrEqualTo(reward.get("validFrom"), now)));
            predicates = cb.and(predicates, cb.or(cb.isNull(reward.get("validTo")), cb.greaterThanOrEqualTo(reward.get("validTo"), now)));
            predicates = cb.and(predicates, cb.or(cb.isNull(reward.get("minOrderAmount")), cb.lessThanOrEqualTo(reward.get("minOrderAmount"), orderAmount)));

            return predicates;
        });

        rows = rows.stream()
                .filter(e -> e.getReward() != null && Reward.RewardType.VOUCHER.equals(e.getReward().getType()))
                .filter(e -> e.getFaceValueSnapshot() != null || (e.getReward() != null && e.getReward().getFaceValue() != null))
                .toList();

        return ResponseEntity.ok(Map.of(
                "data", rows,
                "message", "获取可用代金券成功",
                "code", "USABLE_VOUCHERS_FETCHED"
        ));
    }
    
    // 获取用户兑换记录
    @GetMapping("/exchanges/user/{userId}")
    public ResponseEntity<?> getUserExchanges(@PathVariable Long userId) {
        try {
            List<RewardExchange> exchanges = rewardService.getUserExchanges(userId);
            return ResponseEntity.ok(Map.of(
                    "data", exchanges,
                    "message", "获取用户兑换记录成功",
                    "code", "USER_EXCHANGES_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取用户兑换记录失败",
                    "code", "USER_EXCHANGES_FETCH_FAILED"
            ));
        }
    }
    
    // 根据状态获取兑换记录
    @GetMapping("/exchanges/status/{status}")
    public ResponseEntity<?> getExchangesByStatus(@PathVariable String status) {
        try {
            RewardExchange.ExchangeStatus exchangeStatus = RewardExchange.ExchangeStatus.valueOf(status.toUpperCase());
            List<RewardExchange> exchanges = rewardService.getExchangesByStatus(exchangeStatus);
            return ResponseEntity.ok(Map.of(
                    "data", exchanges,
                    "message", "获取兑换记录成功",
                    "code", "EXCHANGES_BY_STATUS_FETCHED"
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "无效的状态值",
                    "code", "INVALID_STATUS"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取兑换记录失败",
                    "code", "EXCHANGES_FETCH_FAILED"
            ));
        }
    }
    
    // 更新兑换状态
    @PutMapping("/exchanges/{exchangeId}/status")
    public ResponseEntity<?> updateExchangeStatus(@PathVariable Long exchangeId, 
                                                @RequestBody Map<String, String> statusData) {
        try {
            String statusStr = statusData.get("status");
            if (statusStr == null || statusStr.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "message", "状态值不能为空",
                        "code", "STATUS_EMPTY"
                ));
            }
            
            RewardExchange.ExchangeStatus status = RewardExchange.ExchangeStatus.valueOf(statusStr.toUpperCase());
            rewardService.updateExchangeStatus(exchangeId, status);
            return ResponseEntity.ok(Map.of(
                    "message", "更新兑换状态成功",
                    "code", "EXCHANGE_STATUS_UPDATED"
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "无效的状态值",
                    "code", "INVALID_STATUS"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "EXCHANGE_STATUS_UPDATE_FAILED"
            ));
        }
    }

    private Long requireCurrentUserId() {
        return com.school.canteen.util.SecurityUtils.requireCurrentUserId();
    }
    
    // 统计用户兑换数量
    @GetMapping("/exchanges/count/{userId}/{status}")
    public ResponseEntity<?> countUserExchanges(@PathVariable Long userId, @PathVariable String status) {
        try {
            RewardExchange.ExchangeStatus exchangeStatus = RewardExchange.ExchangeStatus.valueOf(status.toUpperCase());
            Long count = rewardService.countUserExchanges(userId, exchangeStatus);
            return ResponseEntity.ok(Map.of(
                    "data", count,
                    "message", "获取兑换数量成功",
                    "code", "EXCHANGE_COUNT_FETCHED"
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "无效的状态值",
                    "code", "INVALID_STATUS"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取兑换数量失败",
                    "code", "EXCHANGE_COUNT_FETCH_FAILED"
            ));
        }
    }
}
