package com.school.canteen.controller;

import com.school.canteen.dto.ReviewDTO;
import com.school.canteen.entity.Review;
import com.school.canteen.service.ReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import com.alibaba.excel.EasyExcel;
import com.school.canteen.dto.export.ReviewExportVO;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.time.format.DateTimeFormatter;
import org.springframework.beans.BeanUtils;

/** 评价控制器 — 评价 CRUD、食堂回复、负面评价预警、Excel 导出 */
@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {
    
    private final ReviewService reviewService;

    private Long getCurrentUserId() {
        return com.school.canteen.util.SecurityUtils.getCurrentUserId();
    }
    
    // 获取所有评价（支持筛选和分页）
    @GetMapping
    public ResponseEntity<?> getAllReviews(
            @RequestParam(required = false) String orderNumber,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endDate,
            @PageableDefault(size = 10, sort = "createTime", direction = org.springframework.data.domain.Sort.Direction.DESC) Pageable pageable) {
        try {
            Page<Review> reviews = reviewService.getAllReviews(orderNumber, username, rating, status, startDate, endDate, pageable);
            return ResponseEntity.ok(Map.of(
                    "data", reviews.getContent(),
                    "total", reviews.getTotalElements(),
                    "current", reviews.getNumber() + 1,
                    "size", reviews.getSize(),
                    "message", "获取评价列表成功",
                    "code", "REVIEWS_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取评价列表失败: " + e.getMessage(),
                    "code", "REVIEWS_FETCH_FAILED"
            ));
        }
    }

    // 创建评价
    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<?> createReview(@Valid @RequestPart("review") ReviewDTO.CreateRequest review, 
                                          @RequestPart(value = "images", required = false) MultipartFile[] images) {
        try {
            Long currentUserId = getCurrentUserId();
            Review createdReview = reviewService.createReview(review, images, currentUserId);
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                    "data", Map.of(
                            "id", createdReview.getId(),
                            "orderId", createdReview.getOrder() != null ? createdReview.getOrder().getId() : null
                    ),
                    "message", "评价创建成功",
                    "code", "REVIEW_CREATED"
            ));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REVIEW_CREATE_FAILED"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "message", "创建评价时发生错误",
                    "code", "INTERNAL_ERROR"
            ));
        }
    }
    
    // 更新评价
    @PutMapping(value = "/{reviewId}", consumes = {"multipart/form-data"})
    public ResponseEntity<?> updateReview(@PathVariable Long reviewId,
                                          @Valid @RequestPart("review") ReviewDTO.CreateRequest review,
                                          @RequestPart(value = "images", required = false) MultipartFile[] images) {
        try {
            Long currentUserId = getCurrentUserId();
            // 验证评价所有者
            Review existingReview = reviewService.getReviewById(reviewId);
            if (existingReview.getUser() == null || !existingReview.getUser().getId().equals(currentUserId)) {
                return ResponseEntity.status(403).body(Map.of(
                        "message", "无权修改此评价",
                        "code", "FORBIDDEN"
                ));
            }
            Review updatedReview = reviewService.updateReview(reviewId, review, images);
            return ResponseEntity.ok(Map.of(
                    "data", Map.of(
                            "id", updatedReview.getId(),
                            "orderId", updatedReview.getOrder() != null ? updatedReview.getOrder().getId() : null
                    ),
                    "message", "评价更新成功",
                    "code", "REVIEW_UPDATED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REVIEW_UPDATE_FAILED"
            ));
        }
    }

    // 删除评价
    @DeleteMapping("/{reviewId}")
    public ResponseEntity<?> deleteReview(@PathVariable Long reviewId) {
        try {
            Long currentUserId = getCurrentUserId();
            // 验证评价所有者（管理员可以删除任何评价）
            Review existingReview = reviewService.getReviewById(reviewId);
            // 检查当前用户是否是评价的所有者或管理员
            boolean isOwner = existingReview.getUser() != null && existingReview.getUser().getId().equals(currentUserId);
            // 获取当前用户来检查是否是管理员
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            boolean isAdmin = auth != null && auth.getAuthorities().stream()
                    .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()) || "ADMIN".equals(a.getAuthority()));
            if (!isOwner && !isAdmin) {
                return ResponseEntity.status(403).body(Map.of(
                        "message", "无权删除此评价",
                        "code", "FORBIDDEN"
                ));
            }
            reviewService.deleteReview(reviewId);
            return ResponseEntity.ok(Map.of(
                    "message", "评价删除成功",
                    "code", "REVIEW_DELETED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REVIEW_DELETE_FAILED"
            ));
        }
    }
    
    // 获取评价详情
    @GetMapping("/{reviewId}")
    public ResponseEntity<?> getReviewById(@PathVariable Long reviewId) {
        try {
            Review review = reviewService.getReviewById(reviewId);
            return ResponseEntity.ok(Map.of(
                    "data", review,
                    "message", "获取评价成功",
                    "code", "REVIEW_FETCHED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REVIEW_FETCH_FAILED"
            ));
        }
    }
    
    // 获取用户评价列表
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getReviewsByUserId(@PathVariable Long userId) {
        try {
            List<Review> reviews = reviewService.getReviewsByUserId(userId);
            return ResponseEntity.ok(Map.of(
                    "data", reviews,
                    "message", "获取用户评价成功",
                    "code", "USER_REVIEWS_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取用户评价失败",
                    "code", "USER_REVIEWS_FETCH_FAILED"
            ));
        }
    }
    
    // 获取订单评价
    @GetMapping("/order/{orderId}")
    public ResponseEntity<?> getReviewsByOrderId(@PathVariable Long orderId) {
        try {
            Optional<Review> review = reviewService.getReviewByOrderId(orderId);
            Map<String, Object> response = new HashMap<>();
            response.put("data", review.orElse(null));
            response.put("message", "获取订单评价成功");
            response.put("code", "ORDER_REVIEWS_FETCHED");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取订单评价失败",
                    "code", "ORDER_REVIEWS_FETCH_FAILED"
            ));
        }
    }

    // 获取菜品评价列表（基于订单评价明细衍生）
    @GetMapping("/dish/{dishId}")
    public ResponseEntity<?> getReviewsByDishId(@PathVariable Long dishId,
                                                @RequestParam(defaultValue = "createTime") String sortBy) {
        try {
            List<Map<String, Object>> reviews = reviewService.getDishReviewViews(dishId, sortBy);
            return ResponseEntity.ok(Map.of(
                    "data", reviews,
                    "message", "获取菜品评价成功",
                    "code", "REVIEWS_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取菜品评价失败",
                    "code", "REVIEWS_FETCH_FAILED"
            ));
        }
    }
    
    // 食堂回复评价
    @PostMapping("/{reviewId}/reply")
    public ResponseEntity<?> replyToReview(@PathVariable Long reviewId, 
                                         @RequestBody Map<String, String> replyData) {
        try {
            String reply = replyData.get("reply");
            if (reply == null || reply.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "message", "回复内容不能为空",
                        "code", "REPLY_CONTENT_EMPTY"
                ));
            }
            
            Review updatedReview = reviewService.replyToReview(reviewId, reply);
            return ResponseEntity.ok(Map.of(
                    "data", updatedReview,
                    "message", "回复成功",
                    "code", "REPLY_SUCCESS"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REPLY_FAILED"
            ));
        }
    }
    
    // 获取负面评价列表
    @GetMapping("/negative")
    public ResponseEntity<?> getNegativeReviews() {
        try {
            List<Review> reviews = reviewService.getNegativeReviews();
            return ResponseEntity.ok(Map.of(
                    "data", reviews,
                    "message", "获取负面评价成功",
                    "code", "NEGATIVE_REVIEWS_FETCHED"
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "获取负面评价失败",
                    "code", "NEGATIVE_REVIEWS_FETCH_FAILED"
            ));
        }
    }
    
    // 处理预警评价
    @PutMapping("/{reviewId}/warning")
    public ResponseEntity<?> processWarningReview(@PathVariable Long reviewId) {
        try {
            reviewService.processWarningReview(reviewId);
            return ResponseEntity.ok(Map.of(
                    "message", "处理预警评价成功",
                    "code", "WARNING_PROCESSED"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "WARNING_PROCESS_FAILED"
            ));
        }
    }

    // 更新评价状态
    @PutMapping("/{reviewId}/status")
    public ResponseEntity<?> updateReviewStatus(@PathVariable Long reviewId, @RequestBody Map<String, String> statusData) {
        try {
            String statusStr = statusData.get("status");
            if (statusStr == null || statusStr.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "message", "状态值不能为空",
                        "code", "STATUS_EMPTY"
                ));
            }
            
            Review.ReviewStatus status = Review.ReviewStatus.valueOf(statusStr.toUpperCase());
            reviewService.updateReviewStatus(reviewId, status);
            return ResponseEntity.ok(Map.of(
                    "message", "更新评价状态成功",
                    "code", "REVIEW_STATUS_UPDATED"
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "message", "无效的状态值",
                    "code", "INVALID_STATUS"
            ));
        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.badRequest().body(Map.of(
                    "message", e.getMessage(),
                    "code", "REVIEW_STATUS_UPDATE_FAILED"
            ));
        }
    }
    
    @PostMapping("/refill-comments")
    public ResponseEntity<?> refillCommentsChinese() {
        int updated = reviewService.refillCommentsChinese();
        return ResponseEntity.ok(Map.of(
                "updated", updated,
                "message", "已批量填充中文评价与回复",
                "code", "REVIEWS_REFILLED"
        ));
    }
    
    @PostMapping("/translate-tags")
    public ResponseEntity<?> translateTagsChinese() {
        int translated = reviewService.translateTagsChinese();
        return ResponseEntity.ok(Map.of(
                "translated", translated,
                "message", "已将标签中文化",
                "code", "TAGS_TRANSLATED"
        ));
    }

    @GetMapping("/export")
    public void exportReviews(
            @RequestParam(required = false) String orderNumber,
            @RequestParam(required = false) String username,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endDate,
            HttpServletResponse response) throws IOException {
        
        Pageable pageable = PageRequest.of(0, 10000);
        Page<Review> reviewPage = reviewService.getAllReviews(orderNumber, username, rating, status, startDate, endDate, pageable);
        
        List<ReviewExportVO> exportList = reviewPage.getContent().stream().map(this::convertToExportVO).toList();

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("评价列表_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")), "UTF-8").replaceAll("\\+", "%20");
        response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + fileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), ReviewExportVO.class).sheet("评价列表").doWrite(exportList);
    }

    private ReviewExportVO convertToExportVO(Review review) {
        ReviewExportVO vo = new ReviewExportVO();
        BeanUtils.copyProperties(review, vo);
        if (review.getOrder() != null) {
            vo.setOrderNumber(review.getOrder().getOrderNumber());
        }
        if (review.getUser() != null) {
            vo.setUsername(review.getUser().getUsername());
        }
        // 处理关联菜品
        if (review.getItems() != null) {
            String dishNames = review.getItems().stream()
                .map(item -> item.getDish() != null ? item.getDish().getName() : "未知")
                .distinct()
                .collect(java.util.stream.Collectors.joining(", "));
            vo.setDishNames(dishNames);
        }
        if (review.getStatus() != null) {
            vo.setStatus(review.getStatus().name());
        }
        if (review.getCreateTime() != null) {
            vo.setCreateTime(review.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        return vo;
    }
}
