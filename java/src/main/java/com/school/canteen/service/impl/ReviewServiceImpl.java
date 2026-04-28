package com.school.canteen.service.impl;

import com.school.canteen.dto.ReviewDTO;
import com.school.canteen.entity.Dish;
import com.school.canteen.entity.Order;
import com.school.canteen.entity.OrderItem;
import com.school.canteen.entity.Review;
import com.school.canteen.entity.ReviewItem;
import com.school.canteen.listener.ReviewCreatedEvent;
import com.school.canteen.repository.DishRepository;
import com.school.canteen.repository.ReviewItemRepository;
import com.school.canteen.repository.ReviewRepository;
import com.school.canteen.repository.ReviewRewardRecordRepository;
import com.school.canteen.repository.UserRepository;
import com.school.canteen.service.ReviewService;
import com.school.canteen.service.ReviewRewardService;
import com.school.canteen.service.NotificationService;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/** 评价管理服务实现类 */
@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {
    
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final DishRepository dishRepository;
    private final com.school.canteen.repository.OrderRepository orderRepository;
    private final ReviewItemRepository reviewItemRepository;
    private final ReviewRewardService reviewRewardService;
    private final ReviewRewardRecordRepository reviewRewardRecordRepository;
    private final ApplicationEventPublisher eventPublisher;
    
    @Autowired
    private NotificationService notificationService;
    
    @Value("${file.upload-dir}")
    private String uploadDir;
    
    @Override
    @Transactional
    public Review createReview(ReviewDTO.CreateRequest request, MultipartFile[] images, Long currentUserId) {
        if (request == null) {
            throw new RuntimeException("评价数据不能为空");
        }
        if (request.getOrderId() == null) {
            throw new RuntimeException("订单ID不能为空");
        }

        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("订单不存在"));

        if (order.getUser() == null || order.getUser().getId() == null) {
            throw new RuntimeException("订单用户数据异常");
        }
        if (currentUserId == null || !order.getUser().getId().equals(currentUserId)) {
            throw new RuntimeException("无权限评价该订单");
        }
        if (order.getStatus() != Order.OrderStatus.COMPLETED) {
            throw new RuntimeException("订单未完成，无法评价");
        }
        if (reviewRepository.existsByOrder_Id(order.getId())) {
            throw new RuntimeException("该订单已评价");
        }

        Review review = new Review();
        review.setOrder(order);
        review.setUser(order.getUser());
        review.setTasteRating(request.getTasteRating());
        review.setPortionRating(request.getPortionRating());
        review.setPriceRating(request.getPriceRating());
        review.setHygieneRating(request.getHygieneRating());
        review.setComment(request.getComment());
        review.setQuickTags(request.getQuickTags() != null ? request.getQuickTags() : new ArrayList<>());

        Map<Long, Dish> orderDishMap = new HashMap<>();
        if (order.getOrderItems() != null) {
            for (OrderItem item : order.getOrderItems()) {
                if (item != null && item.getDish() != null && item.getDish().getId() != null) {
                    orderDishMap.put(item.getDish().getId(), item.getDish());
                }
            }
        }

        Set<Long> ratedDishIds = new HashSet<>();
        List<ReviewDTO.ItemRequest> itemRequests = request.getItems() != null ? request.getItems() : List.of();
        for (ReviewDTO.ItemRequest itemReq : itemRequests) {
            Long dishId = itemReq.getDishId();
            if (dishId == null) {
                throw new RuntimeException("菜品ID不能为空");
            }
            if (!orderDishMap.containsKey(dishId)) {
                throw new RuntimeException("菜品不属于该订单，无法评价");
            }
            if (!ratedDishIds.add(dishId)) {
                throw new RuntimeException("同一菜品不能重复评分");
            }
            ReviewItem ri = new ReviewItem();
            ri.setReview(review);
            ri.setDish(orderDishMap.get(dishId));
            ri.setRating(itemReq.getRating());
            review.getItems().add(ri);
        }
        
        List<String> imageUrls = new ArrayList<>();
        if (images != null && images.length > 0) {
            try {
                for (MultipartFile image : images) {
                    if (!image.isEmpty()) {
                        String filename = saveImage(image);
                        imageUrls.add(filename);
                    }
                }
            } catch (IOException e) {
                throw new RuntimeException("图片上传失败: " + e.getMessage());
            }
        }
        review.setImageUrls(imageUrls);
        
        Review savedReview = reviewRepository.save(review);
        
        eventPublisher.publishEvent(new ReviewCreatedEvent(savedReview.getId()));

        for (Long dishId : ratedDishIds) {
            updateDishRating(dishId);
        }

        return savedReview;
    }
    
    @Override
    @Transactional
    public Review updateReview(Long reviewId, ReviewDTO.CreateRequest request, MultipartFile[] images) {
        Review existingReview = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("评价不存在"));

        Set<Long> affectedDishIds = new HashSet<>();
        if (existingReview.getItems() != null) {
            for (ReviewItem ri : existingReview.getItems()) {
                if (ri != null && ri.getDish() != null && ri.getDish().getId() != null) {
                    affectedDishIds.add(ri.getDish().getId());
                }
            }
        }

        existingReview.setTasteRating(request.getTasteRating());
        existingReview.setPortionRating(request.getPortionRating());
        existingReview.setPriceRating(request.getPriceRating());
        existingReview.setHygieneRating(request.getHygieneRating());
        existingReview.setComment(request.getComment());
        existingReview.setQuickTags(request.getQuickTags() != null ? request.getQuickTags() : new ArrayList<>());
        existingReview.setOverallRating((request.getTasteRating() + request.getPortionRating() +
                request.getPriceRating() + request.getHygieneRating()) / 4.0);

        Map<Long, Dish> orderDishMap = new HashMap<>();
        if (existingReview.getOrder() != null && existingReview.getOrder().getOrderItems() != null) {
            for (OrderItem item : existingReview.getOrder().getOrderItems()) {
                if (item != null && item.getDish() != null && item.getDish().getId() != null) {
                    orderDishMap.put(item.getDish().getId(), item.getDish());
                }
            }
        }

        existingReview.getItems().clear();
        Set<Long> ratedDishIds = new HashSet<>();
        List<ReviewDTO.ItemRequest> itemRequests = request.getItems() != null ? request.getItems() : List.of();
        for (ReviewDTO.ItemRequest itemReq : itemRequests) {
            Long dishId = itemReq.getDishId();
            if (dishId == null) {
                throw new RuntimeException("菜品ID不能为空");
            }
            if (!orderDishMap.containsKey(dishId)) {
                throw new RuntimeException("菜品不属于该订单，无法评价");
            }
            if (!ratedDishIds.add(dishId)) {
                throw new RuntimeException("同一菜品不能重复评分");
            }
            ReviewItem ri = new ReviewItem();
            ri.setReview(existingReview);
            ri.setDish(orderDishMap.get(dishId));
            ri.setRating(itemReq.getRating());
            existingReview.getItems().add(ri);
        }
        affectedDishIds.addAll(ratedDishIds);
        
        if (images != null && images.length > 0) {
            try {
                deleteImages(existingReview.getImageUrls());
                
                List<String> imageUrls = new ArrayList<>();
                for (MultipartFile image : images) {
                    if (!image.isEmpty()) {
                        String filename = saveImage(image);
                        imageUrls.add(filename);
                    }
                }
                existingReview.setImageUrls(imageUrls);
            } catch (IOException e) {
                throw new RuntimeException("图片上传失败: " + e.getMessage());
            }
        }
        
        Review updatedReview = reviewRepository.save(existingReview);
        for (Long dishId : affectedDishIds) {
            updateDishRating(dishId);
        }
        
        return updatedReview;
    }
    
    @Override
    @Transactional
    public void deleteReview(Long reviewId) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("评价不存在"));
        Set<Long> dishIds = new HashSet<>();
        if (review.getItems() != null) {
            for (ReviewItem ri : review.getItems()) {
                if (ri != null && ri.getDish() != null && ri.getDish().getId() != null) {
                    dishIds.add(ri.getDish().getId());
                }
            }
        }
        deleteImages(review.getImageUrls());
        reviewRewardRecordRepository.deleteByReviewId(reviewId);
        reviewRepository.delete(review);
        for (Long dishId : dishIds) {
            updateDishRating(dishId);
        }
    }
    
    @Override
    public Review getReviewById(Long reviewId) {
        return reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("评价不存在"));
    }
    
    @Override
    public Page<Review> getAllReviews(String orderNumber, String username, Integer rating, String status, LocalDateTime startDate, LocalDateTime endDate, Pageable pageable) {
        Specification<Review> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (orderNumber != null && !orderNumber.isEmpty()) {
                predicates.add(cb.like(root.get("order").get("orderNumber"), "%" + orderNumber + "%"));
            }
            if (username != null && !username.isEmpty()) {
                predicates.add(cb.like(root.get("user").get("username"), "%" + username + "%"));
            }
            if (status != null && !status.isEmpty()) {
                try {
                    Review.ReviewStatus statusEnum = Review.ReviewStatus.valueOf(status.toUpperCase());
                    predicates.add(cb.equal(root.get("status"), statusEnum));
                } catch (IllegalArgumentException e) {
                    // ignore invalid status
                }
            }
            if (rating != null) {
                double baseRating = rating.doubleValue();
                double halfRating = Math.min(baseRating + 0.5, 5.0);

                var overallRating = root.get("overallRating").as(Double.class);
                var roundedHalf = cb.quot(
                        cb.function("round", Double.class, cb.prod(overallRating, cb.literal(2.0))),
                        cb.literal(2.0)
                ).as(Double.class);

                var in = cb.in(roundedHalf);
                in.value(baseRating);
                if (halfRating > baseRating) {
                    in.value(halfRating);
                }
                predicates.add(in);
            }
            if (startDate != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createTime"), startDate));
            }
            if (endDate != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("createTime"), endDate));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        return reviewRepository.findAll(spec, pageable);
    }

    @Override
    public int refillCommentsChinese() {
        return 0; 
    }

    @Override
    public int translateTagsChinese() {
        return 0;
    }
    
    @Override
    @Transactional
    public void replyReview(Long reviewId, String reply) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("评价不存在"));
        review.setCanteenReply(reply);
        review.setReplyTime(LocalDateTime.now());
        reviewRepository.save(review);
        
        if (review.getUser() != null) {
            notificationService.sendNotification(
                review.getUser().getId(),
                "您的评价有新回复",
                "食堂回复了您的评价：" + (reply.length() > 20 ? reply.substring(0, 20) + "..." : reply),
                com.school.canteen.entity.Notification.NotificationType.COMMENT,
                com.school.canteen.entity.Notification.NotificationScene.COMMENT_REPLY,
                com.school.canteen.entity.Notification.BizType.REVIEW,
                review.getId()
            );
        }
    }

    private String saveImage(MultipartFile image) throws IOException {
        String filename = UUID.randomUUID().toString() + "_" + image.getOriginalFilename();
        Path path = Paths.get(uploadDir, filename);
        if (!Files.exists(path.getParent())) {
            Files.createDirectories(path.getParent());
        }
        Files.write(path, image.getBytes());
        return "/uploads/" + filename;
    }

    private void deleteImages(List<String> imageUrls) {
        if (imageUrls == null) return;
        for (String url : imageUrls) {
            try {
                String filename = url;
                if (url.startsWith("/uploads/")) {
                    filename = url.substring("/uploads/".length());
                }
                Path path = Paths.get(uploadDir, filename);
                Files.deleteIfExists(path);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public List<Review> getReviewsByUserId(Long userId) {
        return reviewRepository.findByUserId(userId);
    }

    @Override
    public Optional<Review> getReviewByOrderId(Long orderId) {
        return reviewRepository.findByOrder_Id(orderId);
    }

    @Override
    public List<Map<String, Object>> getDishReviewViews(Long dishId, String sortBy) {
        List<ReviewItem> items = reviewItemRepository.findByDishIdAndReviewStatus(dishId, Review.ReviewStatus.NORMAL);
        if (items == null || items.isEmpty()) {
            return List.of();
        }
        return items.stream()
                .sorted((a, b) -> {
                    if ("rating".equalsIgnoreCase(sortBy)) {
                        Integer ar = a.getRating() == null ? 0 : a.getRating();
                        Integer br = b.getRating() == null ? 0 : b.getRating();
                        int c = br.compareTo(ar);
                        if (c != 0) return c;
                    }
                    LocalDateTime at = a.getReview() != null ? a.getReview().getCreateTime() : null;
                    LocalDateTime bt = b.getReview() != null ? b.getReview().getCreateTime() : null;
                    if (at == null && bt == null) return 0;
                    if (at == null) return 1;
                    if (bt == null) return -1;
                    return bt.compareTo(at);
                })
                .map(ri -> {
                    Review r = ri.getReview();
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", r != null ? r.getId() : null);
                    map.put("user", r != null ? r.getUser() : null);
                    // 确保返回用户头像
                    if (r != null && r.getUser() != null) {
                        Map<String, Object> userMap = new HashMap<>();
                        userMap.put("id", r.getUser().getId());
                        userMap.put("username", r.getUser().getUsername());
                        userMap.put("avatar", r.getUser().getAvatar());
                        map.put("user", userMap);
                    }
                    map.put("overallRating", ri.getRating() != null ? ri.getRating().doubleValue() : 0.0);
                    map.put("comment", r != null ? r.getComment() : null);
                    map.put("quickTags", r != null ? r.getQuickTags() : List.of());
                    map.put("imageUrls", r != null ? r.getImageUrls() : List.of());
                    map.put("createTime", r != null ? r.getCreateTime() : null);
                    map.put("canteenReply", r != null ? r.getCanteenReply() : null);
                    map.put("replyTime", r != null ? r.getReplyTime() : null);
                    map.put("status", r != null ? r.getStatus() : null);
                    return map;
                })
                .collect(Collectors.toList());
    }

    @Override
    public Review replyToReview(Long reviewId, String reply) {
        replyReview(reviewId, reply);
        return reviewRepository.findById(reviewId).orElse(null);
    }

    @Override
    public void updateReviewStatus(Long reviewId, Review.ReviewStatus status) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("评价不存在"));
        review.setStatus(status);
        reviewRepository.save(review);
        if (review.getItems() != null) {
            for (ReviewItem ri : review.getItems()) {
                if (ri != null && ri.getDish() != null && ri.getDish().getId() != null) {
                    updateDishRating(ri.getDish().getId());
                }
            }
        }
    }

    @Override
    public List<Review> getNegativeReviews() {
        return reviewRepository.findNegativeReviews(
                3.0,
                List.of(Review.ReviewStatus.NORMAL, Review.ReviewStatus.WARNING)
        );
    }

    @Override
    public void processWarningReview(Long reviewId) {
        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("评价不存在"));
        if (!Review.ReviewStatus.WARNING.equals(review.getStatus())) {
            updateReviewStatus(reviewId, Review.ReviewStatus.WARNING);
        }
        List<com.school.canteen.entity.User> admins = userRepository.findByRole(com.school.canteen.entity.User.UserRole.ADMIN);
        if (admins == null || admins.isEmpty()) {
            return;
        }
        String ratingText = review.getOverallRating() != null ? String.format("%.1f", review.getOverallRating()) : "-";
        String comment = review.getComment() != null ? review.getComment().trim() : "";
        String snippet = comment.length() > 30 ? comment.substring(0, 30) + "..." : comment;
        String content = "检测到低评分或负面关键词评价，评价ID：" + reviewId + "，评分：" + ratingText +
                (snippet.isEmpty() ? "" : "，评价内容：" + snippet);
        for (com.school.canteen.entity.User admin : admins) {
            if (admin == null || admin.getId() == null) {
                continue;
            }
            notificationService.sendNotification(
                    admin.getId(),
                    "评价预警",
                    content,
                    com.school.canteen.entity.Notification.NotificationType.COMMENT,
                    com.school.canteen.entity.Notification.NotificationScene.COMMENT_REPLY,
                    com.school.canteen.entity.Notification.BizType.REVIEW,
                    reviewId
            );
        }
    }

    @Autowired
    private org.springframework.cache.CacheManager cacheManager;

    private void updateDishRating(Long dishId) {
        Dish dish = dishRepository.findById(dishId).orElse(null);
        if (dish == null) return;
        List<ReviewItem> items = reviewItemRepository.findByDishIdAndReviewStatus(dishId, Review.ReviewStatus.NORMAL);
        if (items.isEmpty()) {
            dish.setAverageRating(0.0);
            dish.setRatingCount(0);
        } else {
            double avg = items.stream()
                    .mapToDouble(r -> r.getRating() != null ? r.getRating() : 0.0)
                    .average()
                    .orElse(0.0);
            dish.setAverageRating(Math.round(avg * 10.0) / 10.0);
            dish.setRatingCount(items.size());
        }
        dishRepository.save(dish);
        
        // 清除菜品缓存，确保前端能获取到最新的评分
        org.springframework.cache.Cache cache = cacheManager.getCache("dishes_v7");
        if (cache != null) {
            cache.clear();
        }
        org.springframework.cache.Cache recommendationsCache = cacheManager.getCache("recommendations");
        if (recommendationsCache != null) {
            recommendationsCache.clear();
        }
    }

    @Override
    public void rewardReview(Long reviewId) {
        reviewRewardService.processReviewReward(reviewId);
    }
}
