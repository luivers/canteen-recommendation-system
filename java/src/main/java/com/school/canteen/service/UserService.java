package com.school.canteen.service;

import com.school.canteen.entity.PointLog;
import com.school.canteen.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

/** 用户管理服务接口 */
public interface UserService {
    
    User login(String studentId, String password);
    
    User registerStudent(String studentId, String username, String password, String phone, String email);
    
    User updateUserPreferences(Long userId, Integer spicinessLevel, Integer sweetnessLevel, 
                             String dietaryRestrictions, Set<String> dietaryTags);
    
    List<User> getAllUsers();
    
    List<User> getUsersByRole(User.UserRole role);
    
    Optional<User> getUserById(Long userId);
    
    Optional<User> getUserByStudentId(String studentId);
    
    User createUser(User user);
    
    User updateUser(Long userId, User userUpdate);
    
    void deleteUser(Long userId);
    
    void resetPassword(Long userId, String newPassword);
    
    void changePassword(Long userId, String oldPassword, String newPassword);
    
    void updateUserStatus(Long userId, String status);
    
    List<User> searchUsers(Map<String, Object> searchParams);
    
    Map<String, Long> getUserStatistics();
    
    List<String> getAllDietaryTags();
    
    // 积分管理方法
    void addPoints(Long userId, Integer points);
    void deductPoints(Long userId, Integer points);
    Integer getPoints(Long userId);
    
    // 积分日志方法
    void logEarn(User user, Integer points, PointLog.PointSource source, String description);
    void logSpend(User user, Integer points, PointLog.PointSource source, String description);
    Page<PointLog> getUserPointHistory(Long userId, Pageable pageable);
}