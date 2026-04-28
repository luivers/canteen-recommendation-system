package com.school.canteen.controller;

import com.school.canteen.dto.ReviewDTO;
import com.school.canteen.service.StatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Map;
import java.util.List;

/** 数据统计控制器 — 营收趋势、销量排行、用户分群、关联规则、异常检测、对比分析等 */
@RestController
@RequestMapping("/api/statistics")
public class StatisticsController {

    @Autowired
    private StatisticsService statisticsService;

    @Autowired
    private com.school.canteen.repository.UserRepository userRepository;

    private Long getCurrentUserId() {
        return com.school.canteen.util.SecurityUtils.getCurrentUserId();
    }

    // 获取仪表盘摘要
    @GetMapping("/dashboard-summary")
    public ResponseEntity<Map<String, Object>> getDashboardSummary() {
        return ResponseEntity.ok(statisticsService.getDashboardSummary());
    }

    // Helper to resolve date range from parameters
    private LocalDateTime[] resolveDateRange(String timeRange, LocalDate startDate, LocalDate endDate) {
        LocalDateTime start, end;
        if (startDate != null && endDate != null) {
            start = startDate.atStartOfDay();
            end = endDate.atTime(LocalTime.MAX);
        } else {
            // Default to today if timeRange is null (though defaultValue handles it usually)
            if (timeRange == null) timeRange = "today";
            start = statisticsService.getStartDateByTimeRange(timeRange);
            end = LocalDateTime.now();
        }
        return new LocalDateTime[]{start, end};
    }

    // 获取关键指标
    @GetMapping("/metrics")
    public ResponseEntity<Map<String, Object>> getKeyMetrics(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getKeyMetrics(range[0], range[1]));
    }

    // 获取收入趋势
    @GetMapping("/revenue-trend")
    public ResponseEntity<List<Map<String, Object>>> getRevenueTrend(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getRevenueTrend(range[0], range[1]));
    }

    @GetMapping("/revenue-trend-detail")
    public ResponseEntity<Map<String, Object>> getRevenueTrendDetail(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getRevenueTrendWithGranularity(range[0], range[1]));
    }

    // 获取订单趋势
    @GetMapping("/orders-trend")
    public ResponseEntity<List<Map<String, Object>>> getOrdersTrend(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getOrdersTrend(range[0], range[1]));
    }

    // 获取菜品销量排行
    @GetMapping("/dish-sales-ranking")
    public ResponseEntity<List<Map<String, Object>>> getDishSalesRanking(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishSalesRanking(range[0], range[1]));
    }

    @GetMapping("/dish-rating-ranking")
    public ResponseEntity<List<Map<String, Object>>> getDishRatingRanking(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Integer minReviews,
            @RequestParam(required = false) Integer limit) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishRatingRanking(range[0], range[1], minReviews, limit));
    }

    @GetMapping("/dish-trend-ranking")
    public ResponseEntity<List<Map<String, Object>>> getDishTrendRanking(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "sales") String metric,
            @RequestParam(required = false) Integer limit) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishTrendRanking(range[0], range[1], metric, limit));
    }

    @GetMapping("/dish-category-ranking")
    public ResponseEntity<List<Map<String, Object>>> getDishCategoryRanking(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "sales") String metric,
            @RequestParam(required = false) Integer limit) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishCategoryRanking(range[0], range[1], category, metric, limit));
    }

    @GetMapping("/dish-sales-ranking-by-period")
    public ResponseEntity<List<Map<String, Object>>> getDishSalesRankingByPeriod(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishSalesRankingByPeriod(range[0], range[1]));
    }

    // 获取用户活跃时段
    @GetMapping("/user-active-periods")
    public ResponseEntity<List<Map<String, Object>>> getUserActivePeriods(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getUserActivePeriods(range[0], range[1]));
    }

    // 获取品类销售占比
    @GetMapping("/category-sales")
    public ResponseEntity<List<Map<String, Object>>> getCategorySales(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getCategorySales(range[0], range[1]));
    }

    // 获取品类销售趋势
    @GetMapping("/category-trend")
    public ResponseEntity<List<Map<String, Object>>> getCategoryTrend(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getCategoryTrend(range[0], range[1]));
    }

    // 获取评价关键词
    @GetMapping("/review-keywords")
    public ResponseEntity<Map<String, Object>> getReviewKeywords(
            @RequestParam(required = false) Integer days,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        
        LocalDateTime start, end;
        if (startDate != null && endDate != null) {
            start = startDate.atStartOfDay();
            end = endDate.atTime(LocalTime.MAX);
        } else {
            int d = (days != null) ? days : 7;
            start = LocalDateTime.now().minusDays(d);
            end = LocalDateTime.now();
        }
        return ResponseEntity.ok(statisticsService.getReviewKeywords(start, end));
    }

    // 预览评价关键词（基于规则）
    @PostMapping("/review-keywords/preview")
    public ResponseEntity<Map<String, Object>> getReviewKeywordsPreview(@RequestBody ReviewDTO.KeywordFilter filter) {
        return ResponseEntity.ok(statisticsService.getReviewKeywordsPreview(filter));
    }

    // 获取菜品特征词云
    @GetMapping("/dish-features")
    public ResponseEntity<Map<String, Object>> getDishFeatures() {
        return ResponseEntity.ok(statisticsService.getDishFeatures());
    }

    @GetMapping("/dish-features/wordcloud")
    public ResponseEntity<Map<String, Object>> getDishFeaturesWordcloud(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(required = false) Integer topN,
            @RequestParam(required = false) Integer minWordLength,
            @RequestParam(required = false) Integer minFrequency,
            @RequestParam(required = false) Double wReviews,
            @RequestParam(required = false) Double wSales
    ) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishFeaturesWordcloud(
                range[0], range[1],
                canteenId, windowId,
                topN, minWordLength, minFrequency,
                wReviews, wSales
        ));
    }

    @GetMapping("/dish-features/wordcloud/version")
    public ResponseEntity<Map<String, Object>> getDishFeaturesWordcloudVersion(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(required = false) Double wSales
    ) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        boolean includeSales = wSales != null && wSales > 0;
        long version = statisticsService.getDishFeaturesWordcloudVersion(range[0], range[1], canteenId, windowId, includeSales);
        return ResponseEntity.ok(Map.of("version", version));
    }

    @GetMapping("/dish-features/wordcloud/dishes")
    public ResponseEntity<List<Map<String, Object>>> getDishFeaturesWordcloudDishes(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam String keyword
    ) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getDishFeaturesWordcloudDishes(range[0], range[1], canteenId, windowId, keyword)
                .stream()
                .map(d -> {
                    Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("id", d.getId());
                    m.put("name", d.getName());
                    m.put("price", d.getPrice());
                    m.put("dishCategory", d.getDishCategory());
                    m.put("canteenId", d.getCanteenId());
                    m.put("canteenName", d.getCanteenName());
                    m.put("windowId", d.getWindowId());
                    m.put("windowName", d.getWindowName());
                    m.put("salesCount", d.getSalesCount());
                    m.put("reviewHitCount", d.getReviewHitCount());
                    m.put("averageRating", d.getAverageRating());
                    m.put("hitSources", d.getHitSources());
                    return m;
                })
                .toList());
    }

    // 获取用户偏好
    @GetMapping("/user-preferences")
    public ResponseEntity<Map<String, Object>> getUserPreferences(@RequestParam Long userId) {
        return ResponseEntity.ok(statisticsService.getUserPreferences(userId));
    }

    // 获取健康饮食建议
    @GetMapping("/health-recommendations")
    public ResponseEntity<List<Map<String, Object>>> getHealthRecommendations(@RequestParam Long userId) {
        return ResponseEntity.ok(statisticsService.getHealthRecommendations(userId));
    }

    @GetMapping("/me/user-preferences")
    public ResponseEntity<Map<String, Object>> getMyUserPreferences() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.ok(Map.of());
        }
        return ResponseEntity.ok(statisticsService.getUserPreferences(userId));
    }

    @GetMapping("/me/health-recommendations")
    public ResponseEntity<List<Map<String, Object>>> getMyHealthRecommendations() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.ok(List.of());
        }
        return ResponseEntity.ok(statisticsService.getHealthRecommendations(userId));
    }

    // 获取关联规则
    @GetMapping("/association-rules")
    public ResponseEntity<List<Map<String, Object>>> getAssociationRules(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) Double minSupport,
            @RequestParam(required = false) Double minConfidence,
            @RequestParam(required = false) Double minLift,
            @RequestParam(required = false) Integer topN,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        // 使用新的搭配模式接口
        return ResponseEntity.ok(statisticsService.getDishPairings(
                range[0], range[1],
                minSupport,
                topN, level,
                canteenId, windowId
        ));
    }

    // 获取用户分群
    @GetMapping("/user-segmentation")
    public ResponseEntity<List<Map<String, Object>>> getUserSegmentation() {
        return ResponseEntity.ok(statisticsService.getUserSegmentation());
    }

    @GetMapping("/user-segmentation/advanced")
    public ResponseEntity<Map<String, Object>> getUserSegmentationAdvanced(
            @RequestParam(required = false) Integer windowDays,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId) {
        return ResponseEntity.ok(statisticsService.getUserSegmentationAdvanced(windowDays, canteenId, windowId));
    }

    @GetMapping("/user-segmentation/users")
    public ResponseEntity<Map<String, Object>> getUserSegmentationUsers(
            @RequestParam String segmentCode,
            @RequestParam(required = false) Integer windowDays,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(statisticsService.getUserSegmentationUsers(segmentCode, windowDays, canteenId, windowId, page, size));
    }

    // 获取异常检测结果
    @GetMapping("/anomaly-detection")
    public ResponseEntity<List<Map<String, Object>>> getAnomalyDetection(
            @RequestParam(defaultValue = "today") String timeRange,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String metric,
            @RequestParam(required = false) String dimensionType,
            @RequestParam(required = false) Integer sigma,
            @RequestParam(required = false) Long canteenId,
            @RequestParam(required = false) Long windowId,
            @RequestParam(required = false) Long dishId,
            @RequestParam(required = false) String category) {
        LocalDateTime[] range = resolveDateRange(timeRange, startDate, endDate);
        return ResponseEntity.ok(statisticsService.getAnomalyDetection(
                range[0], range[1],
                metric,
                dimensionType,
                sigma,
                canteenId,
                windowId,
                dishId,
                category
        ));
    }

    // 库存预警 (新增)
    @GetMapping("/inventory-warning")
    public ResponseEntity<List<Map<String, Object>>> getInventoryWarning(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(required = false) String dishName) {
        return ResponseEntity.ok(statisticsService.getInventoryWarning(date, dishName));
    }

    // 获取对比分析
    @GetMapping("/comparison-analysis")
    public ResponseEntity<Map<String, Object>> getComparisonAnalysis(
            @RequestParam String timeRange1,
            @RequestParam String timeRange2,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate1,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate1,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate2,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate2,
            @RequestParam(required = false) Long canteenId1,
            @RequestParam(required = false) Long windowId1,
            @RequestParam(required = false) Long canteenId2,
            @RequestParam(required = false) Long windowId2,
            @RequestParam(required = false) Boolean includeBreakdowns,
            @RequestParam(required = false) Integer topN
    ) {
        if (startDate1 != null && endDate1 != null && startDate2 != null && endDate2 != null) {
            LocalDateTime start1 = startDate1.atStartOfDay();
            LocalDateTime end1 = endDate1.atTime(LocalTime.MAX);
            LocalDateTime start2 = startDate2.atStartOfDay();
            LocalDateTime end2 = endDate2.atTime(LocalTime.MAX);
            return ResponseEntity.ok(statisticsService.getComparisonAnalysis(start1, end1, start2, end2, includeBreakdowns, topN, canteenId1, windowId1, canteenId2, windowId2));
        }

        LocalDateTime[] ranges = statisticsService.resolveComparisonRanges(timeRange1, timeRange2);
        return ResponseEntity.ok(statisticsService.getComparisonAnalysis(ranges[0], ranges[1], ranges[2], ranges[3], includeBreakdowns, topN, canteenId1, windowId1, canteenId2, windowId2));
    }
}
