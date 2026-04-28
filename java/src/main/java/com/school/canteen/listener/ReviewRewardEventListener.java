package com.school.canteen.listener;

import com.school.canteen.entity.Review;
import com.school.canteen.repository.ReviewRepository;
import com.school.canteen.service.ReviewRewardService;
import com.school.canteen.service.ReviewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.transaction.event.TransactionPhase;

import java.util.List;

/** 评价事件监听器，处理评价创建后的奖励发放和差评预警 */
@Component
@Slf4j
@RequiredArgsConstructor
public class ReviewRewardEventListener {

    private final ReviewRewardService reviewRewardService;
    private final ReviewRepository reviewRepository;
    private final ReviewService reviewService;

    private static final double WARNING_MAX_RATING = 3.0;
    private static final List<String> BAD_KEYWORDS = List.of(
            "难吃", "腥", "不新鲜", "慢", "恶劣", "不划算", "吃不饱",
            "脏", "乱", "不卫生", "虫", "异物", "吵", "太油",
            "太咸", "死咸", "齁咸", "咸了", "过咸",
            "太淡", "没味", "淡了", "没盐",
            "饭凉", "菜凉", "凉了",
            "量少", "太少", "很少", "分量少",
            "等太久", "很久", "排队久",
            "服务差", "态度差", "环境差", "卫生差", "体验差", "口感差", "味道差", "质量差",
            "太贵", "很贵", "死贵", "不值"
    );

    @Async
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onReviewCreated(ReviewCreatedEvent event) {
        if (event == null || event.reviewId() == null) {
            return;
        }
        try {
            reviewRewardService.processReviewReward(event.reviewId());
        } catch (Exception e) {
            log.error("Failed to process review reward, reviewId={}", event.reviewId(), e);
        }
        try {
            handleWarning(event.reviewId());
        } catch (Exception e) {
            log.error("Failed to process review warning, reviewId={}", event.reviewId(), e);
        }
    }

    private void handleWarning(Long reviewId) {
        Review review = reviewRepository.findById(reviewId).orElse(null);
        if (review == null) {
            return;
        }
        if (!shouldWarn(review)) {
            return;
        }
        reviewService.processWarningReview(reviewId);
    }

    private boolean shouldWarn(Review review) {
        Double rating = review.getOverallRating();
        boolean lowRating = rating != null && rating <= WARNING_MAX_RATING;
        return lowRating || containsBadKeywords(review.getComment(), review.getQuickTags());
    }

    private boolean containsBadKeywords(String comment, List<String> quickTags) {
        if (comment != null) {
            String text = comment.toLowerCase();
            for (String keyword : BAD_KEYWORDS) {
                if (text.contains(keyword)) {
                    return true;
                }
            }
        }
        if (quickTags != null && !quickTags.isEmpty()) {
            for (String tag : quickTags) {
                if (tag == null) {
                    continue;
                }
                String t = tag.toLowerCase();
                for (String keyword : BAD_KEYWORDS) {
                    if (t.contains(keyword)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
