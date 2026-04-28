package com.school.canteen.controller;

import com.school.canteen.dto.VoucherDTO;
import com.school.canteen.entity.RewardExchange;
import com.school.canteen.entity.Notification;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.RewardExchangeRepository;
import com.school.canteen.service.RewardService;
import com.school.canteen.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.Month;
import java.util.Map;

/** 兑换订单管理控制器（管理端） — 兑换订单查询、发货状态更新、统计 */
@RestController
@RequestMapping("/api/admin/voucher-exchanges")
@RequiredArgsConstructor
public class AdminVoucherExchangeController {
    private final RewardExchangeRepository rewardExchangeRepository;
    private final RewardService rewardService;
    private final NotificationService notificationService;

    @GetMapping("/page")
    public ResponseEntity<?> page(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Long rewardId,
            @RequestParam(required = false) String rewardName,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Pageable pageable = PageRequest.of(page, size);
        final RewardExchange.ExchangeStatus st = (status != null && !status.isBlank()) ? RewardExchange.ExchangeStatus.valueOf(status.trim().toUpperCase()) : null;
        LocalDateTime start = startDate == null ? null : startDate.atStartOfDay();
        LocalDateTime end = endDate == null ? null : endDate.atTime(LocalTime.MAX);

        Page<RewardExchange> p = rewardExchangeRepository.findAll((root, query, cb) -> {
            var predicates = cb.conjunction();
            if (st != null) predicates = cb.and(predicates, cb.equal(root.get("status"), st));
            if (userId != null) predicates = cb.and(predicates, cb.equal(root.get("user").get("id"), userId));
            if (username != null && !username.isBlank()) predicates = cb.and(predicates, cb.like(root.get("user").get("username"), "%" + username + "%"));
            if (rewardId != null) predicates = cb.and(predicates, cb.equal(root.get("reward").get("id"), rewardId));
            if (rewardName != null && !rewardName.isBlank()) predicates = cb.and(predicates, cb.like(root.get("reward").get("name"), "%" + rewardName + "%"));
            if (categoryId != null) predicates = cb.and(predicates, cb.equal(root.get("reward").get("category").get("id"), categoryId));
            if (start != null) predicates = cb.and(predicates, cb.greaterThanOrEqualTo(root.get("exchangeTime"), start));
            if (end != null) predicates = cb.and(predicates, cb.lessThanOrEqualTo(root.get("exchangeTime"), end));
            return predicates;
        }, pageable);

        return ResponseEntity.ok(Map.of(
                "data", Map.of("content", p.getContent(), "total", p.getTotalElements(), "totalPages", p.getTotalPages()),
                "message", "获取兑换订单成功",
                "code", "VOUCHER_EXCHANGES_PAGE_FETCHED"
        ));
    }

    @PutMapping("/{id}/delivery")
    public ResponseEntity<?> updateDelivery(@PathVariable Long id, @Valid @RequestBody VoucherDTO.ExchangeDeliveryRequest req) {
        RewardExchange exchange = rewardExchangeRepository.findById(id).orElseThrow(() -> new BusinessException("NOT_FOUND", "订单不存在"));
        RewardExchange.DeliveryStatus ds = RewardExchange.DeliveryStatus.valueOf(req.getDeliveryStatus().trim().toUpperCase());
        exchange.setDeliveryStatus(ds);
        exchange.setDeliveryInfo(req.getDeliveryInfo());
        if (RewardExchange.DeliveryStatus.DELIVERED.equals(ds)) {
            exchange.setStatus(RewardExchange.ExchangeStatus.COMPLETED);
            exchange.setCompleteTime(LocalDateTime.now());
        }
        rewardExchangeRepository.save(exchange);

        // 发送通知
        if (exchange.getUser() != null) {
            if (RewardExchange.DeliveryStatus.SHIPPED.equals(ds)) {
                String deliveryInfo = exchange.getDeliveryInfo();
                String content = "您的奖品【" + exchange.getReward().getName() + "】已经发货啦！" + 
                                (deliveryInfo != null && !deliveryInfo.isBlank() ? "物流信息：" + deliveryInfo : "");
                notificationService.sendNotification(
                        exchange.getUser().getId(),
                        "奖品已发货",
                        content,
                        Notification.NotificationType.REWARD,
                        Notification.NotificationScene.REWARD_DELIVERY,
                        Notification.BizType.REWARD_EXCHANGE,
                        exchange.getId()
                );
            } else if (RewardExchange.DeliveryStatus.DELIVERED.equals(ds)) {
                notificationService.sendNotification(
                        exchange.getUser().getId(),
                        "奖品已送达",
                        "您的奖品【" + exchange.getReward().getName() + "】已送达，请注意查收。",
                        Notification.NotificationType.REWARD,
                        Notification.NotificationScene.REWARD_DELIVERY,
                        Notification.BizType.REWARD_EXCHANGE,
                        exchange.getId()
                );
            }
        }

        return ResponseEntity.ok(Map.of("message", "更新发货状态成功", "code", "VOUCHER_EXCHANGE_DELIVERY_UPDATED"));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateStatus(@PathVariable @org.springframework.lang.NonNull Long id, @Valid @RequestBody VoucherDTO.ExchangeStatusRequest req) {
        RewardExchange.ExchangeStatus st = RewardExchange.ExchangeStatus.valueOf(req.getStatus().trim().toUpperCase());
        RewardExchange exchange = rewardExchangeRepository.findById(id).orElseThrow(() -> new BusinessException("NOT_FOUND", "订单不存在"));
        exchange.setErrorCode(req.getErrorCode());
        exchange.setErrorMsg(req.getErrorMsg());
        rewardExchangeRepository.save(exchange);
        rewardService.updateExchangeStatus(id, st);
        return ResponseEntity.ok(Map.of("message", "更新订单状态成功", "code", "VOUCHER_EXCHANGE_STATUS_UPDATED"));
    }

    @GetMapping("/stats")
    public ResponseEntity<?> stats(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        // 未传时间时按“全量历史数据”统计，避免旧数据被默认时间窗口排除
        LocalDateTime start = startDate == null
                ? LocalDate.of(1970, Month.JANUARY, 1).atStartOfDay()
                : startDate.atStartOfDay();
        LocalDateTime end = endDate == null
                ? LocalDate.now().atTime(LocalTime.MAX)
                : endDate.atTime(LocalTime.MAX);

        long total = rewardExchangeRepository.countByExchangeTimeBetween(start, end);
        long pointsUsed = rewardExchangeRepository.sumPointsUsedBetween(start, end, RewardExchange.ExchangeStatus.CANCELLED);
        BigDecimal faceValue = rewardExchangeRepository.sumFaceValueBetween(start, end, RewardExchange.ExchangeStatus.CANCELLED);

        return ResponseEntity.ok(Map.of(
                "data", Map.of("total", total, "pointsUsed", pointsUsed, "faceValue", faceValue),
                "message", "获取兑换统计成功",
                "code", "VOUCHER_EXCHANGE_STATS_FETCHED"
        ));
    }
}
