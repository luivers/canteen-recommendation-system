package com.school.canteen.service.impl;

import com.school.canteen.entity.*;
import com.school.canteen.repository.*;
import com.school.canteen.service.*;
import com.school.canteen.entity.PointLog;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/** 评价奖励服务实现类，处理评价积分奖励的计算与发放 */
@Service
@Slf4j
@RequiredArgsConstructor
public class ReviewRewardServiceImpl implements ReviewRewardService {

    private final ReviewRewardRuleRepository ruleRepository;
    private final ReviewRewardRecordRepository recordRepository;
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final UserService userService;

    // 简单的正面情感词库
    private static final List<String> POSITIVE_KEYWORDS = List.of(
        "好吃", "美味", "推荐", "不错", "喜欢", "棒", "赞", "鲜", "足", "实惠", 
        "clean", "good", "yummy", "excellent", "nice", "好评"
    );

    @Override
    @Transactional
    public void processReviewReward(Review review) {
        if (review == null || review.getId() == null) {
            return;
        }
        processReviewReward(review.getId());
    }

    @Override
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void processReviewReward(Long reviewId) {
        if (reviewId == null) {
            return;
        }

        Review review = reviewRepository.findById(reviewId).orElse(null);
        if (review == null) {
            log.warn("Skip review reward: review not found, reviewId={}", reviewId);
            return;
        }

        log.info("Processing reward for review: {}", review.getId());
        
        // 1. 评估质量并保存
        int qualityScore = assessQuality(review);
        review.setQualityScore(qualityScore);
        
        // 2. 获取所有激活的规则
        List<ReviewRewardRule> rules = ruleRepository.findAll();
        
        int totalPointsAwarded = 0;
        User user = review.getUser();
        
        for (ReviewRewardRule rule : rules) {
            if (!rule.isActive()) continue;
            
            // 检查规则条件
            if (!checkRuleCondition(rule, review, qualityScore)) continue;
            
            // 检查幂等性 (该评论是否已经触发过该规则)
            if (recordRepository.existsByReviewIdAndRuleId(review.getId(), rule.getId())) continue;
            
            // 检查每日上限
            if (rule.getDailyLimit() != null) {
                LocalDateTime startOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
                LocalDateTime endOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);
                long count = recordRepository.countByUserIdAndRuleIdAndCreateTimeBetween(
                        user.getId(), rule.getId(), startOfDay, endOfDay);
                if (count >= rule.getDailyLimit()) {
                    log.info("User {} hit daily limit for rule {}", user.getId(), rule.getRuleCode());
                    continue;
                }
            }
            
            // 计算积分 (考虑活动倍率)
            int points = rule.getPoints();
            if (isSpecialPeriod(rule)) {
                points = (int) (points * rule.getMultiplier());
            }
            
            // 发放奖励
            distributeReward(user, review, rule, points);
            totalPointsAwarded += points;
        }
        
        if (totalPointsAwarded > 0) {
            review.setRewarded(true);
            reviewRepository.save(review);
            
            try {
                notificationService.sendNotification(
                        user.getId(),
                        "评价奖励到账",
                        "感谢您的评价！您获得了 " + totalPointsAwarded + " 积分奖励。",
                        com.school.canteen.entity.Notification.NotificationType.COMMENT,
                        com.school.canteen.entity.Notification.NotificationScene.COMMENT_REPLY,
                        com.school.canteen.entity.Notification.BizType.REVIEW,
                        review.getId()
                );
            } catch (Exception e) {
                log.error("Failed to send notification", e);
            }
        } else {
             // 即使没有积分，也要保存质量评分
             reviewRepository.save(review);
        }
    }
    
    private boolean checkRuleCondition(ReviewRewardRule rule, Review review, int score) {
        switch (rule.getRuleCode()) {
            case "BASIC_REVIEW":
                return true; // 所有评论都有基础分
            case "IMAGE_REVIEW":
                return review.getImageUrls() != null && !review.getImageUrls().isEmpty();
            case "LONG_TEXT":
                return review.getComment() != null && review.getComment().length() > 50;
            case "HIGH_QUALITY":
                return score >= 80;
            default:
                return false;
        }
    }
    
    private boolean isSpecialPeriod(ReviewRewardRule rule) {
        if (rule.getStartTime() == null || rule.getEndTime() == null) return false;
        LocalDateTime now = LocalDateTime.now();
        return now.isAfter(rule.getStartTime()) && now.isBefore(rule.getEndTime());
    }
    
    private void distributeReward(User user, Review review, ReviewRewardRule rule, int points) {
        // 创建记录
        ReviewRewardRecord record = new ReviewRewardRecord();
        record.setUser(user);
        record.setReview(review);
        record.setRule(rule);
        record.setPointsAwarded(points);
        recordRepository.save(record);
        
        userService.addPoints(user.getId(), points);
        
        // 记录积分日志
        userService.logEarn(user, points, PointLog.PointSource.REVIEW_REWARD, 
            "评价奖励: " + rule.getRuleName());
        
        log.info("Awarded {} points to user {} for rule {}", points, user.getId(), rule.getRuleCode());
    }

    @Override
    public List<ReviewRewardRule> getAllRules() {
        return ruleRepository.findAll();
    }

    @Override
    @Transactional
    public ReviewRewardRule saveRule(ReviewRewardRule rule) {
        return ruleRepository.save(rule);
    }

    @Override
    @Transactional
    @jakarta.annotation.PostConstruct
    public void initDefaultRules() {
        createRuleIfAbsent("BASIC_REVIEW", "基础评价奖励", 10, 5, "完成评价即可获得");
        createRuleIfAbsent("IMAGE_REVIEW", "图文评价奖励", 20, 5, "包含图片的评价额外奖励");
        createRuleIfAbsent("LONG_TEXT", "长评奖励", 30, 3, "字数超过50字的评价额外奖励");
        createRuleIfAbsent("HIGH_QUALITY", "优质评价奖励", 50, 1, "综合质量评分超过80分的评价");
    }
    
    private void createRuleIfAbsent(String code, String name, int points, int limit, String desc) {
        if (ruleRepository.findByRuleCode(code).isEmpty()) {
            ReviewRewardRule rule = new ReviewRewardRule();
            rule.setRuleCode(code);
            rule.setRuleName(name);
            rule.setPoints(points);
            rule.setDailyLimit(limit);
            rule.setDescription(desc);
            ruleRepository.save(rule);
        }
    }

    private int assessQuality(Review review) {
        int score = 0;
        
        // 1. 基础分：有内容就给分
        if (review.getComment() != null && !review.getComment().trim().isEmpty()) {
            score += 20;
        } else {
            return 0; // 无内容直接0分
        }
        
        // 2. 长度分：鼓励多写 (最高40分)
        int length = review.getComment().length();
        if (length > 10) score += 10;
        if (length > 30) score += 10;
        if (length > 50) score += 20;
        
        // 3. 图片分：有图真相 (最高30分)
        if (review.getImageUrls() != null && !review.getImageUrls().isEmpty()) {
            score += 20;
            if (review.getImageUrls().size() >= 3) {
                score += 10;
            }
        }
        
        // 4. 情感/关键词分析 (简易版，最高10分)
        String comment = review.getComment();
        int keywordCount = 0;
        for (String keyword : POSITIVE_KEYWORDS) {
            if (comment.contains(keyword)) {
                keywordCount++;
            }
        }
        score += Math.min(keywordCount * 2, 10);
        
        // 上限100
        return Math.min(score, 100);
    }
}
