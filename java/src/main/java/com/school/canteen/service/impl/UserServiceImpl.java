package com.school.canteen.service.impl;

import com.school.canteen.entity.Order;
import com.school.canteen.entity.PointLog;
import com.school.canteen.entity.User;
import com.school.canteen.entity.UserProfile;
import com.school.canteen.repository.OrderRepository;
import com.school.canteen.repository.PointLogRepository;
import com.school.canteen.repository.UserProfileRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.repository.CartItemRepository;
import com.school.canteen.repository.ReviewRepository;
import com.school.canteen.repository.RewardExchangeRepository;
import com.school.canteen.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import java.util.ArrayList;
import java.util.Optional;

/** 用户管理服务实现类 */
@Service
@Slf4j
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final PointLogRepository pointLogRepository;
    private final PasswordEncoder passwordEncoder;
    private final OrderRepository orderRepository;
    private final CartItemRepository cartItemRepository;
    private final ReviewRepository reviewRepository;
    private final RewardExchangeRepository rewardExchangeRepository;
    private final RedisTemplate<Object, Object> redisTemplate;

    // 协同过滤推荐缓存key前缀
    private static final String CF_REC_CACHE_KEY_PREFIX = "rec:cf:user:";

    private static final List<Order.OrderStatus> USER_ORDER_STATUSES = List.of(
            Order.OrderStatus.PAID,
            Order.OrderStatus.PREPARING,
            Order.OrderStatus.READY,
            Order.OrderStatus.COMPLETED
    );

    @Override
    public User login(String studentId, String password) {
        if (studentId == null || studentId.trim().isEmpty()) {
            throw new RuntimeException("学号不能为空");
        }
        if (password == null || password.isEmpty()) {
            throw new RuntimeException("密码不能为空");
        }

        User user = userRepository.findByStudentId(studentId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        if (user.getPassword() == null || !passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        if (user.getRole() == null) {
            throw new RuntimeException("权限不足");
        }

        // 检查用户状态
        if ("inactive".equals(user.getStatus())) {
            throw new RuntimeException("账户已被禁用，请联系管理员");
        }

        return Objects.requireNonNull(user, "登录成功后用户对象不应为null");
    }

    @Override
    public User registerStudent(String studentId, String username, String password, String phone, String email) {
        if (studentId == null || studentId.trim().isEmpty()) {
            throw new RuntimeException("学号不能为空");
        }
        if (username == null || username.trim().isEmpty()) {
            throw new RuntimeException("用户名不能为空");
        }
        if (password == null || password.isEmpty()) {
            throw new RuntimeException("密码不能为空");
        }

        if (userRepository.existsByStudentId(studentId)) {
            throw new RuntimeException("学号已存在");
        }

        if (userRepository.existsByUsername(username)) {
            throw new RuntimeException("用户名已存在");
        }

        User user = new User();
        user.setStudentId(studentId);
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setPhone(phone);
        user.setEmail(email);
        user.setRole(User.UserRole.STUDENT);
        // 注意：User实体类没有status字段，status相关代码已移除
        user.setCreateTime(java.time.LocalDateTime.now());
        user.setUpdateTime(java.time.LocalDateTime.now());

        return userRepository.save(user);
    }

    @Override
    public User updateUserPreferences(Long userId, Integer spicinessLevel, Integer sweetnessLevel,
                                     String dietaryRestrictions, Set<String> dietaryTags) {
        Objects.requireNonNull(userId, "用户ID不能为空");
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));

        // 清除协同过滤推荐缓存，确保用户偏好更新后推荐结果也更新
        clearRecommendationCache(userId);

        if (spicinessLevel != null) {
            user.setSpicinessLevel(spicinessLevel);
        }
        if (sweetnessLevel != null) {
            user.setSweetnessLevel(sweetnessLevel);
        }
        if (dietaryRestrictions != null) {
            user.setDietaryRestrictions(dietaryRestrictions);
        }

        java.time.LocalDateTime now = java.time.LocalDateTime.now();

        UserProfile profile = userProfileRepository.findByUser(user)
                .orElseGet(() -> {
                    UserProfile p = new UserProfile();
                    p.setUser(user);
                    p.setCreatedAt(now);
                    return p;
                });

        if (dietaryRestrictions != null) {
            profile.setDietaryRestrictions(dietaryRestrictions);
        }

        Set<String> explicitTags = sanitizeExplicitDietaryTags(dietaryTags, dietaryRestrictions);
        Set<String> tags = new HashSet<>(explicitTags);
        if (spicinessLevel != null) {
            tags.add("辣度:" + spicinessLevel);
            profile.setSpiceTolerance(spicinessLevel);
        }
        if (sweetnessLevel != null) {
            tags.add("甜度:" + sweetnessLevel);
        }
        if (dietaryRestrictions != null && !dietaryRestrictions.trim().isEmpty()) {
            tags.add(dietaryRestrictions);
        }

        profile.setFlavorPreferences(tags.isEmpty() ? null : String.join(",", tags));

        profile.setUpdatedAt(now);

        boolean vegetarian = tags.stream().anyMatch(tag -> tag.contains("素"));
        boolean halal = tags.stream().anyMatch(tag -> tag.contains("清真"));
        profile.setIsVegetarian(vegetarian);
        profile.setIsHalal(halal);

        user.setDietaryTags(explicitTags);
        user.setUserProfile(profile);
        user.setUpdateTime(now);

        userProfileRepository.save(profile);
        return userRepository.save(user);
    }

    private Set<String> sanitizeExplicitDietaryTags(Set<String> dietaryTags, String dietaryRestrictions) {
        if (dietaryTags == null || dietaryTags.isEmpty()) {
            return new HashSet<>();
        }

        String normalizedRestriction = dietaryRestrictions == null ? "" : dietaryRestrictions.trim();
        return dietaryTags.stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(tag -> !tag.isEmpty())
                .filter(tag -> !tag.startsWith("辣度:"))
                .filter(tag -> !tag.startsWith("甜度:"))
                .filter(tag -> normalizedRestriction.isEmpty() || !tag.equals(normalizedRestriction))
                .collect(Collectors.toCollection(HashSet::new));
    }

    @Override
    public List<User> getAllUsers() {
        List<User> users = userRepository.findAll();
        enrichUsers(users);
        return users;
    }

    @Override
    public List<User> getUsersByRole(User.UserRole role) {
        Objects.requireNonNull(role, "用户角色不能为空");
        List<User> users = userRepository.findByRole(role);
        enrichUsers(users);
        return users;
    }

    @Override
    public Optional<User> getUserByStudentId(String studentId) {
        return userRepository.findByStudentId(studentId);
    }

    @Override
    public Optional<User> getUserById(Long userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        userOpt.ifPresent(this::enrichUser);
        return userOpt;
    }

    @Override
    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        // 不能删除管理员用户
        if (User.UserRole.ADMIN.equals(user.getRole())) {
            throw new RuntimeException("管理员用户不能删除");
        }
        
        // 检查关键业务数据关联
        List<Order> orders = orderRepository.findByUserId(userId);
        if (!orders.isEmpty()) {
            throw new RuntimeException("该用户有 " + orders.size() + " 条历史订单，无法删除，请尝试禁用账户");
        }
        
        if (!reviewRepository.findByUserId(userId).isEmpty()) {
            throw new RuntimeException("该用户有已发布的评价，无法删除，请尝试禁用账户");
        }
        
        if (!rewardExchangeRepository.findByUserId(userId).isEmpty()) {
            throw new RuntimeException("该用户有兑换记录，无法删除，请尝试禁用账户");
        }
        
        // 清理非关键关联数据
        cartItemRepository.deleteByUser(user);
        
        try {
            userRepository.delete(user);
            userRepository.flush();
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
             throw new RuntimeException("删除失败：用户仍有关联数据（如通知、积分记录等），无法彻底删除，请禁用账户");
        }
    }

    @Override
    @Transactional
    public User createUser(User user) {
        if (user.getStudentId() == null || user.getStudentId().trim().isEmpty()) {
            throw new RuntimeException("学号不能为空");
        }
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        if (userRepository.existsByStudentId(user.getStudentId())) {
            throw new RuntimeException("学号已存在");
        }
        
        if (user.getPassword() == null || user.getPassword().trim().isEmpty()) {
            throw new RuntimeException("创建用户时必须传入初始密码");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword().trim()));
        if (user.getRole() == null) {
            user.setRole(User.UserRole.STUDENT);
        }
        if (user.getStatus() == null) {
            user.setStatus("active");
        }
        
        return userRepository.save(user);
    }

    @Override
    @Transactional
    public User updateUser(Long userId, User userUpdate) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        boolean recommendationRelevantChanged = false;
        
        // 更新用户信息
        if (userUpdate.getUsername() != null) {
            user.setUsername(userUpdate.getUsername());
        }
        if (userUpdate.getPhone() != null) {
            user.setPhone(userUpdate.getPhone());
        }
        if (userUpdate.getEmail() != null) {
            user.setEmail(userUpdate.getEmail());
        }
        if (userUpdate.getAvatar() != null) {
            user.setAvatar(userUpdate.getAvatar());
        }
        if (userUpdate.getRole() != null) {
            if (User.UserRole.ADMIN.equals(user.getRole())) {
                if (!User.UserRole.ADMIN.equals(userUpdate.getRole())) {
                    throw new RuntimeException("管理员角色不能修改");
                }
            } else {
                user.setRole(userUpdate.getRole());
            }
        }
        if (userUpdate.getStatus() != null) {
             // 不允许禁用管理员账户
            if (User.UserRole.ADMIN.equals(user.getRole()) && "inactive".equals(userUpdate.getStatus())) {
                throw new RuntimeException("管理员账户不能禁用");
            }
            user.setStatus(userUpdate.getStatus());
        }
        if (userUpdate.getDietaryTags() != null) {
            updateUserDietaryTags(user, userUpdate.getDietaryTags());
            recommendationRelevantChanged = true;
        }
        
        user.setUpdateTime(java.time.LocalDateTime.now());
        User saved = userRepository.save(user);
        if (recommendationRelevantChanged) {
            clearRecommendationCache(userId);
        }
        return saved;
    }

    @Override
    @Transactional
    public void resetPassword(Long userId, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdateTime(java.time.LocalDateTime.now());
        userRepository.save(user);
    }

    @Override
    @Transactional
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("原密码不正确");
        }
        if (newPassword == null || newPassword.trim().isEmpty() || newPassword.length() < 6) {
            throw new RuntimeException("新密码长度不能少于6位");
        }
        user.setPassword(passwordEncoder.encode(newPassword.trim()));
        user.setUpdateTime(java.time.LocalDateTime.now());
        userRepository.save(user);
    }

    @Override
    @Transactional
    public void updateUserStatus(Long userId, String status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        // 不允许禁用管理员账户
        if (User.UserRole.ADMIN.equals(user.getRole()) && "inactive".equals(status)) {
            throw new RuntimeException("管理员账户不能禁用");
        }
        
        user.setStatus(status);
        user.setUpdateTime(java.time.LocalDateTime.now());
        userRepository.save(user);
    }

    @Override
    public List<User> searchUsers(Map<String, Object> searchParams) {
        String username = (String) searchParams.get("username");
        // 处理role参数，可能是String也可能是UserRole枚举
        Object roleObj = searchParams.get("role");
        User.UserRole role = null;
        if (roleObj instanceof User.UserRole) {
            role = (User.UserRole) roleObj;
        } else if (roleObj instanceof String && !((String) roleObj).isEmpty()) {
            try {
                role = User.UserRole.valueOf(((String) roleObj).toUpperCase());
            } catch (IllegalArgumentException e) {
                // 忽略无效的角色字符串
            }
        }
        
        String status = (String) searchParams.get("status");
        
        final User.UserRole finalRole = role;
        
        List<User> users = userRepository.findAll((Specification<User>) (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            // 用户名查询 (模糊匹配)
            if (username != null && !username.trim().isEmpty()) {
                predicates.add(cb.like(root.get("username"), "%" + username.trim() + "%"));
            }
            
            // 角色查询
            if (finalRole != null) {
                predicates.add(cb.equal(root.get("role"), finalRole));
            }
            
            // 状态查询
            if (status != null && !status.trim().isEmpty()) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            
            return cb.and(predicates.toArray(new Predicate[0]));
        });
        enrichUsers(users);
        return users;
    }

    private void updateUserDietaryTags(User user, Set<String> dietaryTags) {
        java.time.LocalDateTime now = java.time.LocalDateTime.now();

        UserProfile profile = userProfileRepository.findByUser(user)
                .orElseGet(() -> {
                    UserProfile p = new UserProfile();
                    p.setUser(user);
                    p.setCreatedAt(now);
                    return p;
                });

        Set<String> tags = new LinkedHashSet<>();
        for (String tag : dietaryTags) {
            if (tag != null) {
                String trimmed = tag.trim();
                if (!trimmed.isEmpty()) {
                    tags.add(trimmed);
                }
            }
        }

        profile.setFlavorPreferences(tags.isEmpty() ? null : String.join(",", tags));
        profile.setUpdatedAt(now);
        profile.setIsVegetarian(tags.stream().anyMatch(t -> t.contains("素")));
        profile.setIsHalal(tags.stream().anyMatch(t -> t.contains("清真")));

        user.setDietaryTags(new LinkedHashSet<>(tags));
        user.setUserProfile(profile);

        userProfileRepository.save(profile);
    }

    private void enrichUser(User user) {
        if (user == null || user.getId() == null) return;
        userProfileRepository.findByUserId(user.getId()).ifPresent(profile -> {
            Set<String> tags = parseFlavorPreferences(profile.getFlavorPreferences());
            user.setDietaryTags(tags);
        });
        applyOrderStats(Collections.singletonList(user));
    }

    private void enrichUsers(List<User> users) {
        if (users == null || users.isEmpty()) return;

        List<Long> userIds = users.stream()
                .map(User::getId)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
        if (userIds.isEmpty()) return;

        Map<Long, UserProfile> profileByUserId = userProfileRepository.findByUserIds(userIds).stream()
                .filter(p -> p.getUser() != null && p.getUser().getId() != null)
                .collect(Collectors.toMap(p -> p.getUser().getId(), p -> p, (a, b) -> a));

        for (User user : users) {
            if (user == null || user.getId() == null) continue;
            UserProfile profile = profileByUserId.get(user.getId());
            if (profile == null) continue;
            Set<String> tags = parseFlavorPreferences(profile.getFlavorPreferences());
            user.setDietaryTags(tags);
        }
        applyOrderStats(users);
    }

    private void applyOrderStats(List<User> users) {
        if (users == null || users.isEmpty()) return;
        List<Long> userIds = users.stream()
                .map(User::getId)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
        if (userIds.isEmpty()) return;

        Map<Long, User> userById = users.stream()
                .filter(u -> u != null && u.getId() != null)
                .collect(Collectors.toMap(User::getId, u -> u, (a, b) -> a));

        for (User user : users) {
            if (user == null) continue;
            user.setTotalOrders(0L);
            user.setTotalSpent(BigDecimal.ZERO);
        }

        List<Object[]> rows = orderRepository.aggregateByUserIds(userIds, USER_ORDER_STATUSES);
        for (Object[] row : rows) {
            if (row == null || row.length < 3) continue;
            Long userId = row[0] instanceof Number ? ((Number) row[0]).longValue() : null;
            if (userId == null) continue;
            User user = userById.get(userId);
            if (user == null) continue;
            Long orderCount = row[1] instanceof Number ? ((Number) row[1]).longValue() : 0L;
            BigDecimal totalSpent = row[2] instanceof BigDecimal ? (BigDecimal) row[2] : new BigDecimal(row[2].toString());
            user.setTotalOrders(orderCount);
            user.setTotalSpent(totalSpent);
        }
    }

    private Set<String> parseFlavorPreferences(String flavorPreferences) {
        if (flavorPreferences == null || flavorPreferences.trim().isEmpty()) {
            return new LinkedHashSet<>();
        }
        String[] parts = flavorPreferences.split(",");
        Set<String> tags = new LinkedHashSet<>();
        for (String part : parts) {
            if (part == null) continue;
            String trimmed = part.trim();
            if (!trimmed.isEmpty()) tags.add(trimmed);
        }
        return tags;
    }

    @Override
    public Map<String, Long> getUserStatistics() {
        Map<String, Long> statistics = new HashMap<>();
        statistics.put("totalUsers", userRepository.count());
        statistics.put("studentCount", userRepository.countByRole(User.UserRole.STUDENT));
        statistics.put("adminCount", userRepository.countByRole(User.UserRole.ADMIN));
        statistics.put("windowManagerCount", userRepository.countByRole(User.UserRole.WINDOW_MANAGER));
        return statistics;
    }
    
    @Override
    public List<String> getAllDietaryTags() {
        List<UserProfile> profiles = userProfileRepository.findAll();
        Set<String> tags = new LinkedHashSet<>();
        for (UserProfile profile : profiles) {
            String flavorPreferences = profile.getFlavorPreferences();
            if (flavorPreferences != null && !flavorPreferences.isEmpty()) {
                String[] parts = flavorPreferences.split(",");
                for (String part : parts) {
                    String trimmed = part.trim();
                    if (!trimmed.isEmpty()) {
                        tags.add(trimmed);
                    }
                }
            }
        }
        return new ArrayList<>(tags);
    }
    
    @Override
    @Transactional
    public void addPoints(Long userId, Integer points) {
        Objects.requireNonNull(userId, "用户ID不能为空");
        Objects.requireNonNull(points, "积分不能为空");
        if (points <= 0) {
            throw new RuntimeException("积分必须大于0");
        }
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        int currentPoints = user.getPoints() != null ? user.getPoints() : 0;
        user.setPoints(currentPoints + points);
        user.setUpdateTime(java.time.LocalDateTime.now());
        
        userRepository.save(user);
    }
    
    @Override
    @Transactional
    public void deductPoints(Long userId, Integer points) {
        Objects.requireNonNull(userId, "用户ID不能为空");
        Objects.requireNonNull(points, "积分不能为空");
        if (points <= 0) {
            throw new RuntimeException("积分必须大于0");
        }
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        int currentPoints = user.getPoints() != null ? user.getPoints() : 0;
        if (currentPoints < points) {
            throw new RuntimeException("积分不足");
        }
        
        user.setPoints(currentPoints - points);
        user.setUpdateTime(java.time.LocalDateTime.now());
        
        userRepository.save(user);
    }
    
    @Override
    public Integer getPoints(Long userId) {
        Objects.requireNonNull(userId, "用户ID不能为空");
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        return user.getPoints() != null ? user.getPoints() : 0;
    }

    @Override
    @Transactional
    public void logEarn(User user, Integer points, PointLog.PointSource source, String description) {
        savePointLog(user, points, PointLog.PointType.EARN, source, description);
    }

    @Override
    @Transactional
    public void logSpend(User user, Integer points, PointLog.PointSource source, String description) {
        savePointLog(user, -Math.abs(points), PointLog.PointType.SPEND, source, description);
    }

    private void savePointLog(User user, Integer points, PointLog.PointType type, PointLog.PointSource source, String description) {
        try {
            PointLog logEntry = new PointLog();
            logEntry.setUser(user);
            logEntry.setPoints(points);
            logEntry.setType(type);
            logEntry.setSource(source);
            logEntry.setDescription(description);
            pointLogRepository.save(logEntry);
            log.info("Recorded point log: User={}, Points={}, Type={}, Source={}", user.getId(), points, type, source);
        } catch (Exception e) {
            log.error("Failed to record point log for user {}", user.getId(), e);
        }
    }

    @Override
    public Page<PointLog> getUserPointHistory(Long userId, Pageable pageable) {
        return pointLogRepository.findByUserIdOrderByCreateTimeDesc(userId, pageable);
    }

    /**
     * 清除用户推荐缓存
     * 当用户偏好更新时调用，确保推荐结果反映最新的用户偏好
     */
    private void clearRecommendationCache(Long userId) {
        try {
            String cacheKey = CF_REC_CACHE_KEY_PREFIX + userId;
            Boolean deleted = redisTemplate.delete(cacheKey);
            if (Boolean.TRUE.equals(deleted)) {
                log.info("Cleared recommendation cache for user {}", userId);
            }
        } catch (Exception e) {
            log.warn("Failed to clear recommendation cache for user {}: {}", userId, e.getMessage());
            // 缓存清除失败不影响主流程
        }
    }
}
