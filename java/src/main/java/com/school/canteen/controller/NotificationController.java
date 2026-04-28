package com.school.canteen.controller;

import com.school.canteen.entity.Notification;
import com.school.canteen.entity.User;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/** 通知消息控制器 — 用户通知列表、未读数、标记已读、管理员预警通知 */
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final UserRepository userRepository;

    private Long getCurrentUserId() {
        return com.school.canteen.util.SecurityUtils.getCurrentUserId();
    }

    /**
     * 判断是否为管理员
     */
    private boolean isAdmin(Long userId) {
        if (userId == null) {
            return false;
        }
        return userRepository.findById(userId)
                .map(user -> user.getRole() == User.UserRole.ADMIN || user.getRole() == User.UserRole.WINDOW_MANAGER)
                .orElse(false);
    }

    /**
     * 获取未读通知数量
     */
    @GetMapping("/unread-count")
    public ResponseEntity<?> getUnreadCount() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        long count = isAdmin(userId)
                ? notificationService.getUnreadCountExcludingWarnings(userId)
                : notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(Map.of("count", count, "message", "获取未读数成功", "code", "UNREAD_COUNT_FETCHED"));
    }

    /**
     * 获取管理员预警未读数量
     */
    @GetMapping("/admin/warnings/unread-count")
    public ResponseEntity<?> getAdminWarningUnreadCount() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        if (!isAdmin(userId)) {
            return ResponseEntity.status(403).body(Map.of("message", "无权限访问", "code", "FORBIDDEN"));
        }
        long count = notificationService.getAdminWarningUnreadCount(userId);
        return ResponseEntity.ok(Map.of("count", count, "message", "获取预警未读数成功", "code", "ADMIN_WARNING_UNREAD_COUNT_FETCHED"));
    }

    /**
     * 获取用户通知列表
     */
    @GetMapping
    public ResponseEntity<?> getUserNotifications(@RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "10") int size,
                                                  @RequestParam(required = false) Notification.NotificationType type) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        Page<?> p;
        if (type == null) {
            p = isAdmin(userId)
                    ? notificationService.getUserNotificationsExcludingWarnings(userId, PageRequest.of(page, size))
                    : notificationService.getUserNotifications(userId, PageRequest.of(page, size));
        } else {
            p = isAdmin(userId)
                    ? notificationService.getUserNotificationsByTypeExcludingWarnings(userId, type, PageRequest.of(page, size))
                    : notificationService.getUserNotificationsByType(userId, type, PageRequest.of(page, size));
        }
        return ResponseEntity.ok(Map.of(
                "data", p.getContent(),
                "totalElements", p.getTotalElements(),
                "totalPages", p.getTotalPages(),
                "page", p.getNumber(),
                "size", p.getSize(),
                "message", "获取通知列表成功",
                "code", "NOTIFICATIONS_FETCHED"
        ));
    }

    @GetMapping("/admin/warnings")
    public ResponseEntity<?> getAdminWarningNotifications(@RequestParam(defaultValue = "0") int page,
                                                          @RequestParam(defaultValue = "10") int size) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        if (!isAdmin(userId)) {
            return ResponseEntity.status(403).body(Map.of("message", "无权限访问", "code", "FORBIDDEN"));
        }
        Page<?> p = notificationService.getAdminWarningNotifications(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(Map.of(
                "data", p.getContent(),
                "totalElements", p.getTotalElements(),
                "totalPages", p.getTotalPages(),
                "page", p.getNumber(),
                "size", p.getSize(),
                "message", "获取预警通知成功",
                "code", "ADMIN_WARNING_NOTIFICATIONS_FETCHED"
        ));
    }

    /**
     * 标记单个通知为已读
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        notificationService.markAsRead(userId, id);
        return ResponseEntity.ok(Map.of("message", "标记已读成功", "code", "NOTIFICATION_MARKED_READ"));
    }

    /**
     * 删除所有已读通知
     */
    @DeleteMapping("/read")
    public ResponseEntity<?> deleteReadNotifications() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        notificationService.deleteReadNotifications(userId);
        return ResponseEntity.ok(Map.of("message", "已读消息删除成功", "code", "READ_NOTIFICATIONS_DELETED"));
    }

    /**
     * 标记所有通知为已读
     */
    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        if (isAdmin(userId)) {
            notificationService.markAllAsReadExcludingWarnings(userId);
        } else {
            notificationService.markAllAsRead(userId);
        }
        return ResponseEntity.ok(Map.of("message", "全部标记已读成功", "code", "NOTIFICATIONS_MARKED_ALL_READ"));
    }

    /**
     * 标记所有管理员预警为已读
     */
    @PutMapping("/admin/warnings/read-all")
    public ResponseEntity<?> markAdminWarningAllRead() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "未登录或认证信息无效", "code", "UNAUTHORIZED"));
        }
        if (!isAdmin(userId)) {
            return ResponseEntity.status(403).body(Map.of("message", "无权限访问", "code", "FORBIDDEN"));
        }
        notificationService.markAdminWarningAllRead(userId);
        return ResponseEntity.ok(Map.of("message", "预警通知全部标记已读成功", "code", "ADMIN_WARNING_MARKED_ALL_READ"));
    }
}
