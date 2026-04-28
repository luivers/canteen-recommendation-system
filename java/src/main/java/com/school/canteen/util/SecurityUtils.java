package com.school.canteen.util;

import com.school.canteen.entity.User;
import com.school.canteen.exception.BusinessException;
import com.school.canteen.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * 安全工具类 — 统一获取当前登录用户信息
 */
public final class SecurityUtils {

    private SecurityUtils() {}

    /**
     * 获取当前登录用户ID，未登录返回 null
     */
    public static Long getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()
                || auth instanceof AnonymousAuthenticationToken
                || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        Object principal = auth.getPrincipal();
        if (principal instanceof String str) {
            try {
                return Long.parseLong(str);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        try {
            return Long.parseLong(String.valueOf(principal));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * 获取当前登录用户ID，未登录直接抛 BusinessException(401)
     */
    public static Long requireCurrentUserId() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            throw new BusinessException("UNAUTHORIZED", HttpStatus.UNAUTHORIZED, "请先登录");
        }
        return userId;
    }

    /**
     * 获取当前登录用户实体，未登录返回 null
     */
    public static User getCurrentUser(UserRepository userRepository) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return null;
        }
        return userRepository.findById(userId).orElse(null);
    }

    /**
     * 获取当前登录用户实体，未登录直接抛 BusinessException(401)
     */
    public static User requireCurrentUser(UserRepository userRepository) {
        Long userId = requireCurrentUserId();
        return userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", HttpStatus.UNAUTHORIZED, "用户不存在"));
    }
}
