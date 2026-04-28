package com.school.canteen.repository;

import com.school.canteen.entity.ReviewItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/** 评价子项数据访问层 */
@Repository
public interface ReviewItemRepository extends JpaRepository<ReviewItem, Long> {
    @Query("SELECT ri FROM ReviewItem ri WHERE ri.review.id = :reviewId")
    List<ReviewItem> findByReviewId(@Param("reviewId") Long reviewId);

    @Query("SELECT ri FROM ReviewItem ri WHERE ri.dish.id = :dishId")
    List<ReviewItem> findByDishId(@Param("dishId") Long dishId);

    @Query("SELECT ri FROM ReviewItem ri WHERE ri.dish.id = :dishId AND ri.review.status = :status")
    List<ReviewItem> findByDishIdAndReviewStatus(@Param("dishId") Long dishId, @Param("status") com.school.canteen.entity.Review.ReviewStatus status);
}
