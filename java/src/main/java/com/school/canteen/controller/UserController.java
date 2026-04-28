package com.school.canteen.controller;

import com.school.canteen.config.JwtUtils;
import com.school.canteen.entity.User;
import com.school.canteen.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.Objects;

import com.alibaba.excel.EasyExcel;
import com.school.canteen.dto.export.UserExportVO;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.time.format.DateTimeFormatter;
import java.time.LocalDateTime;
import org.springframework.beans.BeanUtils;

import com.school.canteen.service.DishService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** 用户控制器 — 注册、登录、用户信息管理、口味偏好设置、管理员用户管理 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);
    
    private final UserService userService;
    private final JwtUtils jwtUtils;
    private final DishService dishService;

    private User getAuthenticatedUserEntity() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return null;
        }
        try {
            Long userId = Long.parseLong(auth.getName());
            return userService.getUserById(userId).orElse(null);
        } catch (Exception e) {
            return null;
        }
    }

    private boolean isAdmin(User user) {
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }

    private boolean isSelfOrAdmin(User currentUser, Long targetUserId) {
        return isAdmin(currentUser) || (currentUser != null && Objects.equals(currentUser.getId(), targetUserId));
    }
    
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "未登录", "code", "UNAUTHORIZED"));
        }
        try {
            Long userId = Long.parseLong(auth.getName());
            return userService.getUserById(userId)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (NumberFormatException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "无效的用户ID", "code", "INVALID_USER_ID"));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        try {
            // 只支持使用学号登录
            String studentId = credentials.get("studentId");
            String password = credentials.get("password");
            
            // 确保学号和密码不为空
            if (studentId == null || studentId.isEmpty()) {
                return ResponseEntity.status(400).body(Map.of("message", "学号不能为空", "code", "STUDENT_ID_EMPTY"));
            }
            
            if (password == null || password.isEmpty()) {
                return ResponseEntity.status(400).body(Map.of("message", "密码不能为空", "code", "PASSWORD_EMPTY"));
            }
            
            // 使用学号进行登录
            User user = userService.login(studentId, password);
            
            // 如果是管理员登录，尝试触发每日库存重置检查（8点后且未重置过）
            if (user.getRole() == User.UserRole.ADMIN) {
                try {
                    // 只有当前时间在早上8点之后才进行检查
                    if (java.time.LocalTime.now().isAfter(java.time.LocalTime.of(8, 0))) {
                        dishService.checkAndResetDailyInventory();
                    }
                } catch (Exception e) {
                    logger.error("登录触发库存重置失败", e);
                    // 记录错误但不影响登录流程
                }
            }
            
            // 生成JWT token
            String token = jwtUtils.generateToken(user.getId(), user.getUsername(), user.getRole().name());
            
            // 返回包含token的用户信息，符合前端期望的格式
            Map<String, Object> response = new HashMap<>();
            response.put("id", user.getId());
            response.put("studentId", user.getStudentId());
            response.put("username", user.getUsername());
            response.put("role", user.getRole().name());
            response.put("token", token);
            
            // 将响应包装在data字段中，符合前端期望的结构
            Map<String, Object> dataResponse = new HashMap<>();
            dataResponse.put("data", response);
            
            return ResponseEntity.ok(dataResponse);
        } catch (RuntimeException e) {
            // 根据不同的错误类型返回不同的状态码和消息
            String message = e.getMessage();
            if ("用户不存在".equals(message)) {
                return ResponseEntity.status(401).body(Map.of("message", "用户不存在，请检查学号和密码", "code", "USER_NOT_FOUND"));
            } else if ("密码错误".equals(message)) {
                return ResponseEntity.status(401).body(Map.of("message", "密码错误，请检查密码", "code", "INVALID_PASSWORD"));
            } else if ("权限不足".equals(message)) {
                return ResponseEntity.status(403).body(Map.of("message", "权限不足", "code", "INSUFFICIENT_PERMISSIONS"));
            } else {
                return ResponseEntity.status(401).body(Map.of("message", message + "，登录失败，请检查学号和密码", "code", "LOGIN_FAILED"));
            }
        }
    }
    
    @PostMapping("/register")
    public ResponseEntity<?> registerStudent(@RequestBody Map<String, String> registrationData) {
        try {
            String studentId = registrationData.get("studentId");
            String username = registrationData.get("username");
            String password = registrationData.get("password");
            String phone = registrationData.get("phone");
            String email = registrationData.get("email");

            if (studentId == null || username == null || password == null) {
                return ResponseEntity.badRequest().body(Map.of("message", "缺少必要的注册信息", "code", "MISSING_REQUIRED_FIELDS"));
            }

            User user = userService.registerStudent(studentId, username, password, phone, email);
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            String message = e.getMessage();
            return ResponseEntity.badRequest().body(Map.of("message", message != null ? message : "注册失败", "code", "REGISTRATION_FAILED"));
        }
    }
    
    @PutMapping("/{userId}/preferences")
    @PreAuthorize("hasRole('ADMIN') or #userId.toString() == authentication.name")
    public ResponseEntity<?> updatePreferences(
            @PathVariable Long userId,
            @RequestBody Map<String, Object> preferencesData) {
        try {
            // 验证userId
            if (userId == null) {
                return ResponseEntity.badRequest().body(Map.of("message", "用户ID不能为空", "code", "USER_ID_EMPTY"));
            }
            
            // 安全获取各字段值
            Integer spicinessLevel = null;
            if (preferencesData.containsKey("spicinessLevel")) {
                Object spicinessObj = preferencesData.get("spicinessLevel");
                if (spicinessObj instanceof Number) {
                    spicinessLevel = ((Number) spicinessObj).intValue();
                } else if (spicinessObj instanceof String) {
                    try {
                        spicinessLevel = Integer.parseInt((String) spicinessObj);
                    } catch (NumberFormatException e) {
                        // 忽略无效的数值字符串
                    }
                }
            }
            
            Integer sweetnessLevel = null;
            if (preferencesData.containsKey("sweetnessLevel")) {
                Object sweetnessObj = preferencesData.get("sweetnessLevel");
                if (sweetnessObj instanceof Number) {
                    sweetnessLevel = ((Number) sweetnessObj).intValue();
                } else if (sweetnessObj instanceof String) {
                    try {
                        sweetnessLevel = Integer.parseInt((String) sweetnessObj);
                    } catch (NumberFormatException e) {
                        // 忽略无效的数值字符串
                    }
                }
            }
            
            String dietaryRestrictions = preferencesData.containsKey("dietaryRestrictions") ? (String) preferencesData.get("dietaryRestrictions") : null;
            
            // 处理饮食标签，将前端传递的字符串列表转换为Set<String>
            Set<String> dietaryTags = new HashSet<>();
            if (preferencesData.containsKey("dietaryTags")) {
                Object tagsObj = preferencesData.get("dietaryTags");
                if (tagsObj instanceof List) {
                    List<?> tagList = (List<?>) tagsObj;
                    for (Object tagItem : tagList) {
                        if (tagItem instanceof String) {
                            dietaryTags.add((String) tagItem);
                        }
                    }
                } else if (tagsObj instanceof String) {
                    // 处理前端可能传递的逗号分隔字符串
                    String[] tagArray = ((String) tagsObj).split(",");
                    for (String tag : tagArray) {
                        dietaryTags.add(tag.trim());
                    }
                }
            }
            
            User user = userService.updateUserPreferences(userId, spicinessLevel, sweetnessLevel, 
                    dietaryRestrictions, dietaryTags);
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage(), "code", "UPDATE_FAILED"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", "服务器内部错误: " + e.getMessage(), "code", "INTERNAL_ERROR"));
        }
    }
    
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<User>> getAllUsers(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status) {
        
        if (username != null || role != null || status != null) {
            Map<String, Object> searchParams = new HashMap<>();
            searchParams.put("username", username);
            searchParams.put("role", role);
            searchParams.put("status", status);
            List<User> users = userService.searchUsers(searchParams);
            return ResponseEntity.ok(users);
        }
        
        List<User> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/role/{role}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<User>> getUsersByRole(@PathVariable User.UserRole role) {
        List<User> users = userService.getUsersByRole(role);
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<User> getUserByStudentId(@PathVariable String studentId) {
        return userService.getUserByStudentId(studentId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteUser(@PathVariable Long userId) {
        try {
            userService.deleteUser(userId);
            return ResponseEntity.ok(Map.of("message", "用户删除成功", "code", "USER_DELETED"));
        } catch (RuntimeException e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("用户不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", msg != null ? msg : "删除失败",
                    "code", "USER_DELETE_FAILED"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "message", "系统错误: " + e.getMessage(),
                    "code", "INTERNAL_ERROR"
            ));
        }
    }
    
    // 测试接口，用于检查服务和数据库连接状态
    @GetMapping("/test-connection")
    public ResponseEntity<?> testConnection() {
        try {
            // 尝试获取用户列表，验证数据库连接
            List<User> users = userService.getAllUsers();
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "服务和数据库连接正常");
            response.put("userCount", users.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("status", "error");
            response.put("message", "数据库连接失败: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    // 管理员用户管理API接口
    @GetMapping("/{userId}")
    @PreAuthorize("hasRole('ADMIN') or #userId.toString() == authentication.name")
    public ResponseEntity<User> getUserById(@PathVariable Long userId) {
        try {
            Optional<User> user = userService.getUserById(userId);
            return user.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> createUser(@RequestBody User user) {
        try {
            User createdUser = userService.createUser(user);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "用户创建成功");
            response.put("user", createdUser);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PutMapping("/{userId}")
    @PreAuthorize("hasRole('ADMIN') or #userId.toString() == authentication.name")
    public ResponseEntity<Map<String, Object>> updateUser(@PathVariable Long userId, @RequestBody Map<String, Object> updateData) {
        try {
            User currentUser = getAuthenticatedUserEntity();
            boolean adminOperator = isAdmin(currentUser);
            if (!adminOperator) {
                updateData.remove("role");
                updateData.remove("status");
            }

            User userUpdate = new User();
            userUpdate.setRole(null);
            userUpdate.setStatus(null);

            if (updateData.containsKey("username")) {
                userUpdate.setUsername((String) updateData.get("username"));
            }
            if (updateData.containsKey("phone")) {
                userUpdate.setPhone((String) updateData.get("phone"));
            }
            if (updateData.containsKey("email")) {
                userUpdate.setEmail((String) updateData.get("email"));
            }
            if (updateData.containsKey("status")) {
                userUpdate.setStatus((String) updateData.get("status"));
            }
            if (updateData.containsKey("avatar")) {
                userUpdate.setAvatar((String) updateData.get("avatar"));
            }
            if (updateData.containsKey("role")) {
                Object roleObj = updateData.get("role");
                if (roleObj instanceof String && !((String) roleObj).isEmpty()) {
                    userUpdate.setRole(User.UserRole.valueOf(((String) roleObj).toUpperCase()));
                } else if (roleObj instanceof User.UserRole) {
                    userUpdate.setRole((User.UserRole) roleObj);
                }
            }
            if (updateData.containsKey("dietaryTags")) {
                Set<String> dietaryTags = new HashSet<>();
                Object tagsObj = updateData.get("dietaryTags");
                if (tagsObj instanceof List) {
                    for (Object item : (List<?>) tagsObj) {
                        if (item instanceof String) {
                            String trimmed = ((String) item).trim();
                            if (!trimmed.isEmpty()) dietaryTags.add(trimmed);
                        }
                    }
                } else if (tagsObj instanceof String) {
                    String[] parts = ((String) tagsObj).split(",");
                    for (String part : parts) {
                        String trimmed = part.trim();
                        if (!trimmed.isEmpty()) dietaryTags.add(trimmed);
                    }
                }
                userUpdate.setDietaryTags(dietaryTags);
            }

            User updatedUser = userService.updateUser(userId, userUpdate);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "用户更新成功");
            response.put("user", updatedUser);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PutMapping("/{userId}/reset-password")
    @PreAuthorize("hasRole('ADMIN') or #userId.toString() == authentication.name")
    public ResponseEntity<Map<String, Object>> resetPassword(@PathVariable Long userId, @RequestBody Map<String, String> passwordData) {
        try {
            String newPassword = passwordData.get("newPassword");
            if (newPassword == null || newPassword.isEmpty()) {
                Map<String, Object> error = new HashMap<>();
                error.put("message", "新密码不能为空");
                return ResponseEntity.badRequest().body(error);
            }
            userService.resetPassword(userId, newPassword);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "密码重置成功");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PutMapping("/{userId}/change-password")
    @PreAuthorize("#userId.toString() == authentication.name")
    public ResponseEntity<Map<String, Object>> changePassword(@PathVariable Long userId, @RequestBody Map<String, String> passwordData) {
        try {
            String oldPassword = passwordData.get("oldPassword");
            String newPassword = passwordData.get("newPassword");
            
            if (oldPassword == null || oldPassword.isEmpty()) {
                Map<String, Object> error = new HashMap<>();
                error.put("message", "原密码不能为空");
                return ResponseEntity.badRequest().body(error);
            }
            if (newPassword == null || newPassword.isEmpty()) {
                Map<String, Object> error = new HashMap<>();
                error.put("message", "新密码不能为空");
                return ResponseEntity.badRequest().body(error);
            }
            
            userService.changePassword(userId, oldPassword, newPassword);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "密码修改成功");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PutMapping("/{userId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> updateUserStatus(@PathVariable Long userId, @RequestBody Map<String, String> statusData) {
        try {
            String status = statusData.get("status");
            if (status == null || (!"active".equals(status) && !"inactive".equals(status))) {
                Map<String, Object> error = new HashMap<>();
                error.put("message", "无效的状态值，应为active或inactive");
                return ResponseEntity.badRequest().body(error);
            }
            userService.updateUserStatus(userId, status);
            Map<String, Object> response = new HashMap<>();
            response.put("message", "状态更新成功");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, Object> error = new HashMap<>();
            error.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<User>> searchUsers(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status) {
        try {
            Map<String, Object> searchParams = new HashMap<>();
            if (username != null && !username.isEmpty()) {
                searchParams.put("username", username);
            }
            if (role != null && !role.isEmpty()) {
                searchParams.put("role", User.UserRole.valueOf(role.toUpperCase()));
            }
            if (status != null && !status.isEmpty()) {
                searchParams.put("status", status);
            }
            List<User> users = userService.searchUsers(searchParams);
            return ResponseEntity.ok(users);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/statistics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Long>> getUserStatistics() {
        try {
            Map<String, Long> statistics = userService.getUserStatistics();
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    /**
     * 获取所有可用的饮食标签
     */
    @GetMapping("/dietary-tags")
    public ResponseEntity<List<String>> getAllDietaryTags() {
        try {
            List<String> dietaryTags = userService.getAllDietaryTags();
            return ResponseEntity.ok(dietaryTags);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/export")
    @PreAuthorize("hasRole('ADMIN')")
    public void exportUsers(
            @RequestParam(required = false) String username,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status,
            HttpServletResponse response) throws IOException {
        
        List<User> users;
        if (username != null || role != null || status != null) {
            Map<String, Object> searchParams = new HashMap<>();
            searchParams.put("username", username);
            if (role != null && !role.isEmpty()) {
                try {
                    searchParams.put("role", User.UserRole.valueOf(role.toUpperCase()));
                } catch (IllegalArgumentException ignored) {}
            }
            searchParams.put("status", status);
            users = userService.searchUsers(searchParams);
        } else {
            users = userService.getAllUsers();
        }

        List<UserExportVO> exportList = users.stream().map(this::convertToExportVO).toList();

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("用户列表_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")), "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), UserExportVO.class).sheet("用户列表").doWrite(exportList);
    }

    private UserExportVO convertToExportVO(User user) {
        UserExportVO vo = new UserExportVO();
        BeanUtils.copyProperties(user, vo);
        if (user.getRole() != null) {
            vo.setRole(user.getRole().name());
        }
        if (user.getCreateTime() != null) {
            vo.setCreateTime(user.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        return vo;
    }
}
