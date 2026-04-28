package com.school.canteen.service;

import com.school.canteen.dto.ReviewDTO;
import com.school.canteen.entity.Review;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Map;

/** 评价管理服务接口 */
public interface ReviewService {
    // CRUD操作
    Review createReview(ReviewDTO.CreateRequest request, MultipartFile[] images, Long currentUserId);
    Review updateReview(Long reviewId, ReviewDTO.CreateRequest request, MultipartFile[] images);
    void deleteReview(Long reviewId);
    Review getReviewById(Long reviewId);
    
    // 查询操作
    Page<Review> getAllReviews(String orderNumber, String username, Integer rating, String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable);
    List<Review> getReviewsByUserId(Long userId);
    Optional<Review> getReviewByOrderId(Long orderId);

    List<Map<String, Object>> getDishReviewViews(Long dishId, String sortBy);
    
    // 食堂回复
    Review replyToReview(Long reviewId, String reply);
    
    // 评价奖励
    void rewardReview(Long reviewId);
    
    // 评价状态管理
    void updateReviewStatus(Long reviewId, Review.ReviewStatus status);
    
    // 负面评价预警
    List<Review> getNegativeReviews();
    void processWarningReview(Long reviewId);
    
    int refillCommentsChinese();
    int translateTagsChinese();
    // 食堂回复
    void replyReview(Long reviewId, String reply);
}
