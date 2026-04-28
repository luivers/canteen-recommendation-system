package com.school.canteen.repository;

import com.school.canteen.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/** 评价数据访问层 */
@Repository
public interface ReviewRepository extends JpaRepository<Review, Long>, JpaSpecificationExecutor<Review> {
    
    @Query("SELECT r FROM Review r WHERE r.user.id = :userId")
    List<Review> findByUserId(@Param("userId") Long userId);

    boolean existsByUser_Id(Long userId);
    
    // 获取负面评价
    @Query("SELECT r FROM Review r WHERE r.overallRating <= :maxRating AND r.status IN :statuses")
    List<Review> findNegativeReviews(@Param("maxRating") Double maxRating,
                                     @Param("statuses") List<Review.ReviewStatus> statuses);
    
    // 按状态查询评价
    List<Review> findByStatus(Review.ReviewStatus status);
    
    // 按订单查询评价
    Optional<Review> findByOrder_Id(Long orderId);

    boolean existsByOrder_Id(Long orderId);
}
