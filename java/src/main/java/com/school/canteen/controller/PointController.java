package com.school.canteen.controller;

import com.school.canteen.entity.PointLog;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/** 积分控制器 — 查询积分余额和积分变动历史 */
@RestController
@RequestMapping("/api/points")
@RequiredArgsConstructor
public class PointController {

    private final UserService userService;

    @GetMapping("/balance")
    public ResponseEntity<?> getBalance() {
        Long userId = requireCurrentUserId();
        Integer points = userService.getPoints(userId);
        return ResponseEntity.ok(Map.of(
                "data", Map.of("points", points),
                "message", "获取积分余额成功",
                "code", "POINT_BALANCE_FETCHED"
        ));
    }

    @GetMapping("/history")
    public ResponseEntity<?> getUserPointHistory(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Pageable pageable = PageRequest.of(page, size);
            Page<PointLog> history = userService.getUserPointHistory(userId, pageable);
            return ResponseEntity.ok(Map.of(
                    "data", history.getContent(),
                    "total", history.getTotalElements(),
                    "totalPages", history.getTotalPages(),
                    "message", "获取积分历史成功",
                    "code", "POINT_HISTORY_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取积分历史失败: " + e.getMessage(),
                    "code", "POINT_HISTORY_FETCH_FAILED"
            ));
        }
    }

    @GetMapping("/history/me")
    public ResponseEntity<?> getMyPointHistory(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Long userId = requireCurrentUserId();
        Pageable pageable = PageRequest.of(page, size);
        Page<PointLog> history = userService.getUserPointHistory(userId, pageable);
        return ResponseEntity.ok(Map.of(
                "data", history.getContent(),
                "total", history.getTotalElements(),
                "totalPages", history.getTotalPages(),
                "message", "获取积分历史成功",
                "code", "POINT_HISTORY_FETCHED"
        ));
    }

    private Long requireCurrentUserId() {
        return com.school.canteen.util.SecurityUtils.requireCurrentUserId();
    }
}
