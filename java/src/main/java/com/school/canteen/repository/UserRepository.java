package com.school.canteen.repository;

import com.school.canteen.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

/** 用户数据访问层 */
@Repository
public interface UserRepository extends JpaRepository<User, Long>, JpaSpecificationExecutor<User> {
    
    Optional<User> findByStudentId(String studentId);
    
    Optional<User> findByUsername(String username);
    
    boolean existsByStudentId(String studentId);
    
    boolean existsByUsername(String username);
    
    List<User> findByRole(User.UserRole role);
    
    Long countByRole(User.UserRole role);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("UPDATE User u SET u.points = COALESCE(u.points, 0) + :points WHERE u.id = :userId")
    int addPoints(@org.springframework.data.repository.query.Param("userId") Long userId, @org.springframework.data.repository.query.Param("points") Integer points);

    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.data.jpa.repository.Query("UPDATE User u SET u.points = COALESCE(u.points, 0) - :points WHERE u.id = :userId AND COALESCE(u.points, 0) >= :points")
    int deductPoints(@org.springframework.data.repository.query.Param("userId") Long userId, @org.springframework.data.repository.query.Param("points") Integer points);
}
