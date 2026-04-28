package com.school.canteen.repository;

import com.school.canteen.entity.User;
import com.school.canteen.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/** 用户画像数据访问层 */
@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    Optional<UserProfile> findByUser(User user);

    @Query("SELECT up FROM UserProfile up WHERE up.user.id = :userId")
    Optional<UserProfile> findByUserId(@Param("userId") Long userId);

    @Query("SELECT up FROM UserProfile up WHERE up.user.id IN :userIds")
    List<UserProfile> findByUserIds(@Param("userIds") List<Long> userIds);
}
