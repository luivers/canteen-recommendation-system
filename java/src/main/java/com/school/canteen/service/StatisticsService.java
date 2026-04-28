package com.school.canteen.service;

import com.school.canteen.dto.DishFeatureDTO;
import com.school.canteen.dto.ReviewDTO;
import com.school.canteen.util.DishFeatureKeywordEngine;
import com.school.canteen.util.KeywordProcessor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;
import java.time.DayOfWeek;
import java.util.concurrent.ConcurrentHashMap;

import com.school.canteen.entity.DailyDishStatistic;
import com.school.canteen.repository.DailyDishStatisticRepository;
import org.springframework.transaction.annotation.Transactional;

/** 数据统计与分析服务，提供订单趋势、菜品排行、用户画像等统计功能 */
@Service
public class StatisticsService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private DailyDishStatisticRepository dailyDishStatisticRepository;

    @Autowired
    private com.school.canteen.service.NotificationService notificationService;

    @Autowired
    private com.school.canteen.repository.UserRepository userRepository;

    private static final String VALID_ORDER_STATUSES = "('PAID', 'PREPARING', 'READY', 'COMPLETED')";

    private static final long DISH_FEATURE_WORDCLOUD_CACHE_TTL_MS = 30_000;
    private final Map<String, CachedDishFeatureWordcloud> dishFeatureWordcloudCache = new ConcurrentHashMap<>();

    private static class CachedDishFeatureWordcloud {
        final long ts;
        final long version;
        final Map<String, Object> data;

        private CachedDishFeatureWordcloud(long ts, long version, Map<String, Object> data) {
            this.ts = ts;
            this.version = version;
            this.data = data;
        }
    }

    // Helper: Determine granularity based on time range duration
    private String determineGranularity(LocalDateTime start, LocalDateTime end) {
        long hours = ChronoUnit.HOURS.between(start, end);
        if (hours <= 30) return "hour"; // <= 30 hours -> Hourly
        long days = ChronoUnit.DAYS.between(start, end);
        if (days <= 7) return "day"; // <= 7 days -> Daily
        if (days <= 32) return "week"; // <= 32 days (~1 month) -> Weekly
        if (days <= 100) return "month"; // <= 100 days (~1 quarter) -> Monthly
        if (days <= 730) return "quarter"; // <= 730 days (~2 years) -> Quarterly
        return "year"; // > 730 days -> Yearly
    }

    // 预览评价关键词（基于规则）
    public Map<String, Object> getReviewKeywordsPreview(ReviewDTO.KeywordFilter filter) {
        LocalDateTime startDate = filter.getStartDate() != null ? filter.getStartDate().atStartOfDay() : LocalDateTime.now().minusDays(7);
        LocalDateTime endDate = filter.getEndDate() != null ? filter.getEndDate().atTime(LocalTime.MAX) : LocalDateTime.now();

        // 1. Fetch Reviews
        StringBuilder sql = new StringBuilder("SELECT id, comment, overall_rating FROM reviews WHERE create_time >= ? AND create_time <= ? AND status = 'NORMAL'");
        List<Object> params = new ArrayList<>();
        params.add(startDate);
        params.add(endDate);

        if (filter.getMinRating() != null) {
            sql.append(" AND overall_rating >= ?");
            params.add(filter.getMinRating());
        }

        List<Map<String, Object>> reviews = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        
        // 2. Fetch Quick Tags
        Map<Long, List<String>> reviewTags = new HashMap<>();
        if (filter.getDataSource() == null || filter.getDataSource() == ReviewDTO.KeywordFilter.DataSource.QUICK_TAGS || filter.getDataSource() == ReviewDTO.KeywordFilter.DataSource.BOTH) {
            if (!reviews.isEmpty()) {
                StringBuilder tagSql = new StringBuilder("SELECT qt.review_id, qt.quick_tag FROM review_quick_tags qt " +
                        "JOIN reviews r ON qt.review_id = r.id " +
                        "WHERE r.create_time >= ? AND r.create_time <= ? AND r.status = 'NORMAL'");
                if (filter.getMinRating() != null) {
                    tagSql.append(" AND r.overall_rating >= ?");
                }
                
                List<Map<String, Object>> tagRows = jdbcTemplate.queryForList(tagSql.toString(), params.toArray());
                for (Map<String, Object> row : tagRows) {
                    Long rId = ((Number) row.get("review_id")).longValue();
                    String tag = (String) row.get("quick_tag");
                    reviewTags.computeIfAbsent(rId, k -> new ArrayList<>()).add(tag);
                }
            }
        }
        
        List<String> comments = new ArrayList<>();
        List<List<String>> tagsList = new ArrayList<>();
        
        for (Map<String, Object> r : reviews) {
            Long id = ((Number) r.get("id")).longValue();
            comments.add((String) r.get("comment"));
            tagsList.add(reviewTags.get(id));
        }

        return KeywordProcessor.process(comments, tagsList, filter);
    }

    // Helper: Get start date of the previous period with same duration
    private LocalDateTime getPreviousPeriodStartDate(LocalDateTime start, LocalDateTime end) {
        long seconds = ChronoUnit.SECONDS.between(start, end);
        if (seconds <= 0) return start.minusDays(1);
        return start.minusSeconds(seconds);
    }

    // 获取关键指标
    public Map<String, Object> getKeyMetrics(LocalDateTime startDate, LocalDateTime endDate) {
        Map<String, Object> metrics = new HashMap<>();

        // 1. Current Period
        Map<String, Object> currentMetrics = getPeriodMetrics(startDate, endDate);
        
        metrics.put("revenue", currentMetrics.get("revenue"));
        metrics.put("orders", currentMetrics.get("orders"));
        metrics.put("users", currentMetrics.get("users"));
        metrics.put("avgOrderValue", currentMetrics.get("avgOrderValue"));

        // 2. Previous Period (Same duration)
        LocalDateTime previousStartDate = getPreviousPeriodStartDate(startDate, endDate);
        LocalDateTime previousEndDate = startDate; // End of previous is Start of current
        
        Map<String, Object> previousMetrics = getPeriodMetrics(previousStartDate, previousEndDate);
        
        // Calculate Change Rates
        metrics.put("revenueChange", calculateChangeRate((BigDecimal)metrics.get("revenue"), (BigDecimal)previousMetrics.get("revenue")));
        metrics.put("ordersChange", calculateChangeRate((Long)metrics.get("orders"), (Long)previousMetrics.get("orders")));
        metrics.put("usersChange", calculateChangeRate((Long)metrics.get("users"), (Long)previousMetrics.get("users")));
        metrics.put("avgOrderChange", calculateChangeRate((BigDecimal)metrics.get("avgOrderValue"), (BigDecimal)previousMetrics.get("avgOrderValue")));

        return metrics;
    }

    public Map<String, Object> getKeyMetricsFiltered(LocalDateTime startDate, LocalDateTime endDate, Long canteenId, Long windowId) {
        Map<String, Object> metrics = new HashMap<>();
        Map<String, Object> currentMetrics = getPeriodMetricsFiltered(startDate, endDate, canteenId, windowId);
        metrics.put("revenue", currentMetrics.get("revenue"));
        metrics.put("orders", currentMetrics.get("orders"));
        metrics.put("users", currentMetrics.get("users"));
        metrics.put("avgOrderValue", currentMetrics.get("avgOrderValue"));

        LocalDateTime previousStartDate = getPreviousPeriodStartDate(startDate, endDate);
        LocalDateTime previousEndDate = startDate;
        Map<String, Object> previousMetrics = getPeriodMetricsFiltered(previousStartDate, previousEndDate, canteenId, windowId);

        metrics.put("revenueChange", calculateChangeRate((BigDecimal) metrics.get("revenue"), (BigDecimal) previousMetrics.get("revenue")));
        metrics.put("ordersChange", calculateChangeRate((Long) metrics.get("orders"), (Long) previousMetrics.get("orders")));
        metrics.put("usersChange", calculateChangeRate((Long) metrics.get("users"), (Long) previousMetrics.get("users")));
        metrics.put("avgOrderChange", calculateChangeRate((BigDecimal) metrics.get("avgOrderValue"), (BigDecimal) previousMetrics.get("avgOrderValue")));
        return metrics;
    }
    
    // 获取仪表盘摘要数据（总用户、今日订单、今日营收）
    public Map<String, Object> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDateTime.now();

        try {
            // 1. 总用户数量
            String totalUsersSql = "SELECT COUNT(*) FROM users";
            Long totalUsers = jdbcTemplate.queryForObject(totalUsersSql, Long.class);
            summary.put("totalUsers", totalUsers != null ? totalUsers : 0L);

            // 2. 今日订单 (所有订单)
            String todayOrdersSql = "SELECT COUNT(DISTINCT o.id) FROM orders o " +
                    "JOIN order_items oi ON o.id = oi.order_id " +
                    "WHERE oi.create_time >= ? AND oi.create_time <= ?";
            Long todayOrders = jdbcTemplate.queryForObject(todayOrdersSql, Long.class, startOfDay, endOfDay);
            summary.put("todayOrders", todayOrders != null ? todayOrders : 0L);

            // 3. 今日营收 (有效订单)
            String todayRevenueSql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders " +
                    "WHERE status IN " + VALID_ORDER_STATUSES + " " +
                    "AND id IN (SELECT DISTINCT order_id FROM order_items WHERE create_time >= ? AND create_time <= ?) " +
                    "AND total_amount > 0";
            BigDecimal todayRevenue = jdbcTemplate.queryForObject(todayRevenueSql, BigDecimal.class, startOfDay, endOfDay);
            summary.put("todayRevenue", todayRevenue != null ? todayRevenue : BigDecimal.ZERO);

        } catch (Exception e) {
            e.printStackTrace();
            summary.put("totalUsers", 0L);
            summary.put("todayOrders", 0L);
            summary.put("todayRevenue", BigDecimal.ZERO);
        }

        return summary;
    }

    // 辅助方法：获取指定时间段的聚合指标
    private Map<String, Object> getPeriodMetrics(LocalDateTime start, LocalDateTime end) {
        Map<String, Object> result = new HashMap<>();
        
        // 1. 有效订单条件 (用于计算收入、客单价、活跃用户)
        String validWhereClause = "WHERE status IN " + VALID_ORDER_STATUSES + " " +
                             "AND id IN (SELECT DISTINCT order_id FROM order_items WHERE create_time >= ? AND create_time <= ?) " +
                             "AND total_amount > 0";

        try {
            // 1. 总收入 (有效订单)
            String revenueSql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders " + validWhereClause;
            BigDecimal revenue = jdbcTemplate.queryForObject(revenueSql, BigDecimal.class, start, end);
            
            // 2. 订单数 (所有订单 - 基于 create_time)
            String countSql = "SELECT COUNT(DISTINCT o.id) FROM orders o " +
                              "JOIN order_items oi ON o.id = oi.order_id " +
                              "WHERE oi.create_time >= ? AND oi.create_time <= ?";
            Long count = jdbcTemplate.queryForObject(countSql, Long.class, start, end);
            
            // 3. 有效订单数 (用于计算客单价)
            String validCountSql = "SELECT COUNT(*) FROM orders " + validWhereClause;
            Long validCount = jdbcTemplate.queryForObject(validCountSql, Long.class, start, end);
            
            // 4. 活跃用户数 (有效订单)
            String userSql = "SELECT COUNT(DISTINCT user_id) FROM orders " + validWhereClause + " AND user_id IS NOT NULL";
            Long users = jdbcTemplate.queryForObject(userSql, Long.class, start, end);
            
            // 5. 客单价 (总收入 / 有效订单数)
            BigDecimal avgOrderValue = (validCount != null && validCount > 0) ? revenue.divide(BigDecimal.valueOf(validCount), 2, RoundingMode.HALF_UP) : BigDecimal.ZERO;
            
            result.put("revenue", revenue);
            result.put("orders", count != null ? count : 0L);
            result.put("users", users != null ? users : 0L);
            result.put("avgOrderValue", avgOrderValue);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("revenue", BigDecimal.ZERO);
            result.put("orders", 0L);
            result.put("users", 0L);
            result.put("avgOrderValue", BigDecimal.ZERO);
        }
        
        return result;
    }

    private Map<String, Object> getPeriodMetricsFiltered(LocalDateTime start, LocalDateTime end, Long canteenId, Long windowId) {
        Map<String, Object> result = new HashMap<>();
        try {
            StringBuilder base = new StringBuilder();
            List<Object> params = new ArrayList<>();
            base.append("FROM orders o ")
                    .append("JOIN order_items oi ON o.id = oi.order_id ")
                    .append("JOIN dishes d ON oi.dish_id = d.id ")
                    .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                    .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                    .append("AND o.total_amount > 0 ");
            params.add(start);
            params.add(end);
            if (canteenId != null) {
                base.append("AND d.canteen_id = ? ");
                params.add(canteenId);
            }
            if (windowId != null) {
                base.append("AND d.window_id = ? ");
                params.add(windowId);
            }

            String revenueSql = "SELECT COALESCE(SUM(oi.subtotal), 0) " + base;
            BigDecimal revenue = jdbcTemplate.queryForObject(revenueSql, BigDecimal.class, params.toArray());
            String countSql = "SELECT COUNT(DISTINCT o.id) " + base;
            Long count = jdbcTemplate.queryForObject(countSql, Long.class, params.toArray());
            String userSql = "SELECT COUNT(DISTINCT o.user_id) " + base + " AND o.user_id IS NOT NULL";
            Long users = jdbcTemplate.queryForObject(userSql, Long.class, params.toArray());

            long orderCount = count == null ? 0L : count;
            BigDecimal avgOrderValue = orderCount > 0 ? revenue.divide(BigDecimal.valueOf(orderCount), 2, RoundingMode.HALF_UP) : BigDecimal.ZERO;
            result.put("revenue", revenue == null ? BigDecimal.ZERO : revenue);
            result.put("orders", orderCount);
            result.put("users", users == null ? 0L : users);
            result.put("avgOrderValue", avgOrderValue);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("revenue", BigDecimal.ZERO);
            result.put("orders", 0L);
            result.put("users", 0L);
            result.put("avgOrderValue", BigDecimal.ZERO);
        }
        return result;
    }

    // 计算变化率
    private double calculateChangeRate(BigDecimal current, BigDecimal previous) {
        if (previous == null || previous.compareTo(BigDecimal.ZERO) == 0) {
            return (current != null && current.compareTo(BigDecimal.ZERO) > 0) ? 100.0 : 0.0;
        }
        return Math.round(current.subtract(previous)
                .divide(previous, 5, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .doubleValue() * 10) / 10.0;
    }
    
    private double calculateChangeRate(Long current, Long previous) {
        if (previous == null || previous == 0) {
            return (current != null && current > 0) ? 100.0 : 0.0;
        }
        return Math.round(((double)(current - previous) / previous) * 1000) / 10.0;
    }

    // 获取收入趋势数据
    public List<Map<String, Object>> getRevenueTrend(LocalDateTime startDate, LocalDateTime endDate) {
        return getTrendData(startDate, endDate, true);
    }

    public Map<String, Object> getRevenueTrendWithGranularity(LocalDateTime startDate, LocalDateTime endDate) {
        String granularity = determineGranularity(startDate, endDate);
        List<Map<String, Object>> data = getOrdersTrend(startDate, endDate);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("granularity", granularity);
        result.put("data", data);
        return result;
    }

    // 获取订单趋势数据
    public List<Map<String, Object>> getOrdersTrend(LocalDateTime startDate, LocalDateTime endDate) {
        String granularity = determineGranularity(startDate, endDate);

        String timeExpr;
        String alias;

        if ("hour".equals(granularity)) {
            timeExpr = "HOUR(t.order_time)";
            alias = "h";
        } else if ("week".equals(granularity)) {
            timeExpr = "YEARWEEK(t.order_time, 1)";
            alias = "w";
        } else if ("month".equals(granularity)) {
            timeExpr = "DATE_FORMAT(t.order_time, '%Y-%m')";
            alias = "m";
        } else if ("quarter".equals(granularity)) {
            timeExpr = "CONCAT(YEAR(t.order_time), '-Q', QUARTER(t.order_time))";
            alias = "q";
        } else if ("year".equals(granularity)) {
            timeExpr = "YEAR(t.order_time)";
            alias = "y";
        } else {
            timeExpr = "DATE(t.order_time)";
            alias = "d";
        }

        String sql = "SELECT " + timeExpr + " as " + alias + ", " +
                "COUNT(o.id) as order_count, " +
                "COALESCE(SUM(CASE WHEN o.status IN " + VALID_ORDER_STATUSES + " AND o.total_amount > 0 THEN o.total_amount ELSE 0 END), 0) as order_amount " +
                "FROM orders o " +
                "JOIN (SELECT order_id, MIN(create_time) as order_time FROM order_items GROUP BY order_id) t ON o.id = t.order_id " +
                "WHERE t.order_time >= ? AND t.order_time <= ? " +
                "GROUP BY " + alias + " ORDER BY " + alias;

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startDate, endDate);
        return formatOrdersTrendData(rows, granularity, startDate, endDate);
    }
    
    // Unified Trend Data Method
    private List<Map<String, Object>> getTrendData(LocalDateTime startDate, LocalDateTime endDate, boolean isRevenue) {
        String granularity = determineGranularity(startDate, endDate);
        
        String timeExpr;
        String alias;
        
        if ("hour".equals(granularity)) {
            timeExpr = "HOUR(t.order_time)";
            alias = "h";
        } else if ("week".equals(granularity)) {
            timeExpr = "YEARWEEK(t.order_time, 1)";
            alias = "w";
        } else if ("month".equals(granularity)) {
            timeExpr = "DATE_FORMAT(t.order_time, '%Y-%m')";
            alias = "m";
        } else if ("quarter".equals(granularity)) {
            timeExpr = "CONCAT(YEAR(t.order_time), '-Q', QUARTER(t.order_time))";
            alias = "q";
        } else if ("year".equals(granularity)) {
            timeExpr = "YEAR(t.order_time)";
            alias = "y";
        } else {
            timeExpr = "DATE(t.order_time)";
            alias = "d";
        }
        
        String aggExpr = isRevenue ? "SUM(o.total_amount)" : "COUNT(o.id)";
        String statusClause = isRevenue ? "AND o.status IN " + VALID_ORDER_STATUSES + " AND o.total_amount > 0 " : "";

        String sql = "SELECT " + timeExpr + " as " + alias + ", " + aggExpr + " as val " +
                     "FROM orders o " +
                     "JOIN (SELECT order_id, MIN(create_time) as order_time FROM order_items GROUP BY order_id) t ON o.id = t.order_id " +
                     "WHERE t.order_time >= ? AND t.order_time <= ? " +
                     statusClause +
                     "GROUP BY " + alias + " ORDER BY " + alias;

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startDate, endDate);
        return formatTrendData(rows, granularity, startDate, endDate);
    }
    
    private List<Map<String, Object>> formatTrendData(List<Map<String, Object>> rows, String granularity, LocalDateTime startDate, LocalDateTime endDate) {
        List<Map<String, Object>> trend = new ArrayList<>();
        
        if ("hour".equals(granularity)) {
            Map<Integer, BigDecimal> dataMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                dataMap.put(((Number)row.get("h")).intValue(), new BigDecimal(row.get("val").toString()));
            }
            LocalDateTime curr = startDate.withMinute(0).withSecond(0).withNano(0);
            while (!curr.isAfter(endDate)) {
                 int hour = curr.getHour();
                 BigDecimal val = dataMap.getOrDefault(hour, BigDecimal.ZERO);
                 
                 Map<String, Object> item = new HashMap<>();
                 item.put("time", hour + "时");
                 item.put("value", val);
                 trend.add(item);
                 
                 curr = curr.plusHours(1);
                 if (trend.size() >= 24) break; 
            }
        } else if ("week".equals(granularity)) {
            Map<String, BigDecimal> dataMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                dataMap.put(row.get("w").toString(), new BigDecimal(row.get("val").toString()));
            }
            LocalDateTime curr = startDate;
            while (!curr.isAfter(endDate)) {
                int year = curr.get(java.time.temporal.WeekFields.ISO.weekBasedYear());
                int week = curr.get(java.time.temporal.WeekFields.ISO.weekOfWeekBasedYear());
                String key = String.format("%d%02d", year, week);
                
                Map<String, Object> item = new HashMap<>();
                item.put("time", week + "周");
                item.put("value", dataMap.getOrDefault(key, BigDecimal.ZERO));
                trend.add(item);
                
                curr = curr.plusWeeks(1);
            }
        } else if ("day".equals(granularity)) {
            Map<LocalDate, BigDecimal> dataMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                java.sql.Date sqlDate = (java.sql.Date) row.get("d");
                dataMap.put(sqlDate.toLocalDate(), new BigDecimal(row.get("val").toString()));
            }
            
            LocalDate curr = startDate.toLocalDate();
            LocalDate end = endDate.toLocalDate();
            
            while (!curr.isAfter(end)) {
                Map<String, Object> item = new HashMap<>();
                item.put("time", curr.format(DateTimeFormatter.ofPattern("MM-dd")));
                item.put("value", dataMap.getOrDefault(curr, BigDecimal.ZERO));
                trend.add(item);
                curr = curr.plusDays(1);
            }
        } else if ("month".equals(granularity)) {
            Map<String, BigDecimal> dataMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                dataMap.put((String)row.get("m"), new BigDecimal(row.get("val").toString()));
            }
            
            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            
            while (!curr.isAfter(end)) {
                String key = curr.format(DateTimeFormatter.ofPattern("yyyy-MM"));
                Map<String, Object> item = new HashMap<>();
                item.put("time", curr.format(DateTimeFormatter.ofPattern("yy年M月")));
                item.put("value", dataMap.getOrDefault(key, BigDecimal.ZERO));
                trend.add(item);
                curr = curr.plusMonths(1);
            }
        } else if ("quarter".equals(granularity)) {
            Map<String, BigDecimal> dataMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                dataMap.put((String)row.get("q"), new BigDecimal(row.get("val").toString()));
            }
            
            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            
            while (!curr.isAfter(end)) {
                int q = (curr.getMonthValue() - 1) / 3 + 1;
                String key = curr.getYear() + "-Q" + q;
                
                Map<String, Object> item = new HashMap<>();
                item.put("time", curr.getYear() + "年Q" + q);
                item.put("value", dataMap.getOrDefault(key, BigDecimal.ZERO));
                trend.add(item);
                
                // Move to next quarter
                curr = curr.plusMonths(3);
            }
        } else if ("year".equals(granularity)) {
            Map<Integer, BigDecimal> dataMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                dataMap.put(((Number)row.get("y")).intValue(), new BigDecimal(row.get("val").toString()));
            }
            
            int startYear = startDate.getYear();
            int endYear = endDate.getYear();
            
            for (int y = startYear; y <= endYear; y++) {
                Map<String, Object> item = new HashMap<>();
                item.put("time", y + "年");
                item.put("value", dataMap.getOrDefault(y, BigDecimal.ZERO));
                trend.add(item);
            }
        }
        
        return trend;
    }

    private List<Map<String, Object>> formatOrdersTrendData(List<Map<String, Object>> rows, String granularity, LocalDateTime startDate, LocalDateTime endDate) {
        List<Map<String, Object>> trend = new ArrayList<>();

        if ("hour".equals(granularity)) {
            Map<Integer, Long> countMap = new HashMap<>();
            Map<Integer, BigDecimal> amountMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                int hour = ((Number) row.get("h")).intValue();
                countMap.put(hour, ((Number) row.get("order_count")).longValue());
                amountMap.put(hour, new BigDecimal(row.get("order_amount").toString()));
            }

            LocalDateTime curr = startDate.withMinute(0).withSecond(0).withNano(0);
            while (!curr.isAfter(endDate)) {
                int hour = curr.getHour();

                Map<String, Object> item = new HashMap<>();
                item.put("time", hour + "时");
                item.put("orderCount", countMap.getOrDefault(hour, 0L));
                item.put("orderAmount", amountMap.getOrDefault(hour, BigDecimal.ZERO));
                trend.add(item);

                curr = curr.plusHours(1);
                if (trend.size() >= 24) break;
            }
        } else if ("week".equals(granularity)) {
            Map<String, Long> countMap = new HashMap<>();
            Map<String, BigDecimal> amountMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                String key = row.get("w").toString();
                countMap.put(key, ((Number) row.get("order_count")).longValue());
                amountMap.put(key, new BigDecimal(row.get("order_amount").toString()));
            }

            LocalDateTime curr = startDate;
            while (!curr.isAfter(endDate)) {
                int year = curr.get(java.time.temporal.WeekFields.ISO.weekBasedYear());
                int week = curr.get(java.time.temporal.WeekFields.ISO.weekOfWeekBasedYear());
                String key = String.format("%d%02d", year, week);

                Map<String, Object> item = new HashMap<>();
                item.put("time", week + "周");
                item.put("orderCount", countMap.getOrDefault(key, 0L));
                item.put("orderAmount", amountMap.getOrDefault(key, BigDecimal.ZERO));
                trend.add(item);

                curr = curr.plusWeeks(1);
            }
        } else if ("day".equals(granularity)) {
            Map<LocalDate, Long> countMap = new HashMap<>();
            Map<LocalDate, BigDecimal> amountMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                java.sql.Date sqlDate = (java.sql.Date) row.get("d");
                LocalDate date = sqlDate.toLocalDate();
                countMap.put(date, ((Number) row.get("order_count")).longValue());
                amountMap.put(date, new BigDecimal(row.get("order_amount").toString()));
            }

            LocalDate curr = startDate.toLocalDate();
            LocalDate end = endDate.toLocalDate();
            while (!curr.isAfter(end)) {
                Map<String, Object> item = new HashMap<>();
                item.put("time", curr.format(DateTimeFormatter.ofPattern("MM-dd")));
                item.put("orderCount", countMap.getOrDefault(curr, 0L));
                item.put("orderAmount", amountMap.getOrDefault(curr, BigDecimal.ZERO));
                trend.add(item);
                curr = curr.plusDays(1);
            }
        } else if ("month".equals(granularity)) {
            Map<String, Long> countMap = new HashMap<>();
            Map<String, BigDecimal> amountMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                String key = (String) row.get("m");
                countMap.put(key, ((Number) row.get("order_count")).longValue());
                amountMap.put(key, new BigDecimal(row.get("order_amount").toString()));
            }

            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            while (!curr.isAfter(end)) {
                String key = curr.format(DateTimeFormatter.ofPattern("yyyy-MM"));

                Map<String, Object> item = new HashMap<>();
                item.put("time", curr.format(DateTimeFormatter.ofPattern("yy年M月")));
                item.put("orderCount", countMap.getOrDefault(key, 0L));
                item.put("orderAmount", amountMap.getOrDefault(key, BigDecimal.ZERO));
                trend.add(item);

                curr = curr.plusMonths(1);
            }
        } else if ("quarter".equals(granularity)) {
            Map<String, Long> countMap = new HashMap<>();
            Map<String, BigDecimal> amountMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                String key = (String) row.get("q");
                countMap.put(key, ((Number) row.get("order_count")).longValue());
                amountMap.put(key, new BigDecimal(row.get("order_amount").toString()));
            }

            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            while (!curr.isAfter(end)) {
                int q = (curr.getMonthValue() - 1) / 3 + 1;
                String key = curr.getYear() + "-Q" + q;

                Map<String, Object> item = new HashMap<>();
                item.put("time", curr.getYear() + "年Q" + q);
                item.put("orderCount", countMap.getOrDefault(key, 0L));
                item.put("orderAmount", amountMap.getOrDefault(key, BigDecimal.ZERO));
                trend.add(item);

                curr = curr.plusMonths(3);
            }
        } else if ("year".equals(granularity)) {
            Map<Integer, Long> countMap = new HashMap<>();
            Map<Integer, BigDecimal> amountMap = new HashMap<>();
            for (Map<String, Object> row : rows) {
                int y = ((Number) row.get("y")).intValue();
                countMap.put(y, ((Number) row.get("order_count")).longValue());
                amountMap.put(y, new BigDecimal(row.get("order_amount").toString()));
            }

            int startYear = startDate.getYear();
            int endYear = endDate.getYear();

            for (int y = startYear; y <= endYear; y++) {
                Map<String, Object> item = new HashMap<>();
                item.put("time", y + "年");
                item.put("orderCount", countMap.getOrDefault(y, 0L));
                item.put("orderAmount", amountMap.getOrDefault(y, BigDecimal.ZERO));
                trend.add(item);
            }
        }

        return trend;
    }

    // 获取菜品销量排行
    public List<Map<String, Object>> getDishSalesRanking(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT d.name, SUM(oi.quantity) as total_qty " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.id " +
                     "JOIN dishes d ON oi.dish_id = d.id " +
                     "WHERE o.status = 'COMPLETED' AND oi.create_time >= ? AND oi.create_time <= ? " +
                     "GROUP BY d.id, d.name " +
                     "ORDER BY total_qty DESC " +
                     "LIMIT 10";
                     
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            map.put("name", rs.getString("name"));
            map.put("value", rs.getLong("total_qty"));
            return map;
        }, startDate, endDate);
    }

    public List<Map<String, Object>> getDishRatingRanking(LocalDateTime startDate, LocalDateTime endDate, Integer minReviews, Integer limit) {
        int safeLimit = safeLimit(limit);
        int min = minReviews == null ? 0 : Math.max(0, minReviews);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT d.id, d.name, AVG(ri.rating) as avg_rating, COUNT(*) as review_count, COUNT(ri.rating) as rating_count ");
        sql.append("FROM review_items ri ");
        sql.append("JOIN reviews r ON ri.review_id = r.id ");
        sql.append("JOIN dishes d ON ri.dish_id = d.id ");
        sql.append("WHERE r.status = 'NORMAL' AND ri.rating IS NOT NULL AND r.create_time >= ? AND r.create_time <= ? ");
        sql.append("GROUP BY d.id, d.name ");
        if (min > 0) {
            sql.append("HAVING COUNT(*) >= ? ");
        }
        sql.append("ORDER BY avg_rating DESC, review_count DESC ");
        sql.append("LIMIT ").append(safeLimit);

        List<Object> params = new ArrayList<>();
        params.add(startDate);
        params.add(endDate);
        if (min > 0) {
            params.add(min);
        }

        try {
            return jdbcTemplate.query(sql.toString(), (rs, rowNum) -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getLong("id"));
                map.put("name", rs.getString("name"));
                double avgRating = rs.getDouble("avg_rating");
                double rounded = Math.round(avgRating * 10.0) / 10.0;
                map.put("rating", rounded);
                map.put("avgRating", rounded);
                map.put("value", rounded);
                long reviewCount = rs.getLong("review_count");
                map.put("reviewCount", reviewCount);
                map.put("ratingCount", rs.getLong("rating_count"));
                return map;
            }, params.toArray());
        } catch (Exception e) {
            try {
                StringBuilder legacySql = new StringBuilder();
                legacySql.append("SELECT d.id, d.name, AVG(r.overall_rating) as avg_rating, COUNT(*) as review_count, COUNT(r.overall_rating) as rating_count ");
                legacySql.append("FROM reviews r ");
                legacySql.append("JOIN dishes d ON r.dish_id = d.id ");
                legacySql.append("WHERE r.status = 'NORMAL' AND r.overall_rating IS NOT NULL AND r.create_time >= ? AND r.create_time <= ? ");
                legacySql.append("GROUP BY d.id, d.name ");
                if (min > 0) {
                    legacySql.append("HAVING COUNT(*) >= ? ");
                }
                legacySql.append("ORDER BY avg_rating DESC, review_count DESC ");
                legacySql.append("LIMIT ").append(safeLimit);

                List<Object> legacyParams = new ArrayList<>();
                legacyParams.add(startDate);
                legacyParams.add(endDate);
                if (min > 0) {
                    legacyParams.add(min);
                }

                return jdbcTemplate.query(legacySql.toString(), (rs, rowNum) -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getLong("id"));
                    map.put("name", rs.getString("name"));
                    double avgRating = rs.getDouble("avg_rating");
                    double rounded = Math.round(avgRating * 10.0) / 10.0;
                    map.put("rating", rounded);
                    map.put("avgRating", rounded);
                    map.put("value", rounded);
                    long reviewCount = rs.getLong("review_count");
                    map.put("reviewCount", reviewCount);
                    map.put("ratingCount", rs.getLong("rating_count"));
                    return map;
                }, legacyParams.toArray());
            } catch (Exception ignored) {
                return new ArrayList<>();
            }
        }
    }

    public List<Map<String, Object>> getDishTrendRanking(LocalDateTime startDate, LocalDateTime endDate, String metric, Integer limit) {
        int safeLimit = safeLimit(limit);
        LocalDateTime prevStart = getPreviousPeriodStartDate(startDate, endDate);
        LocalDateTime prevEnd = startDate.minusNanos(1);
        boolean ratingMetric = "rating".equalsIgnoreCase(metric);

        Map<Long, Number> current = ratingMetric
                ? getDishRatingAggregate(startDate, endDate)
                : getDishSalesAggregate(startDate, endDate);
        Map<Long, Number> previous = ratingMetric
                ? getDishRatingAggregate(prevStart, prevEnd)
                : getDishSalesAggregate(prevStart, prevEnd);
        Map<Long, String> names = getDishNamesUnion(current, previous);

        List<Map<String, Object>> list = new ArrayList<>();
        for (Map.Entry<Long, String> entry : names.entrySet()) {
            Long id = entry.getKey();
            double currVal = current.getOrDefault(id, 0).doubleValue();
            double prevVal = previous.getOrDefault(id, 0).doubleValue();
            double delta = currVal - prevVal;
            double deltaRate = prevVal == 0 ? (currVal == 0 ? 0 : 1) : delta / prevVal;
            double growthRate = (prevVal == 0 ? (currVal == 0 ? 0 : 100) : deltaRate * 100);
            double growthRounded = Math.round(growthRate * 10.0) / 10.0;

            Map<String, Object> item = new HashMap<>();
            item.put("id", id);
            item.put("name", entry.getValue());
            item.put("current", currVal);
            item.put("previous", prevVal);
            item.put("delta", delta);
            item.put("deltaRate", deltaRate);
            item.put("growthRate", growthRounded);
            list.add(item);
        }

        list.sort((a, b) -> {
            int cmp = Double.compare(((Number) b.get("deltaRate")).doubleValue(), ((Number) a.get("deltaRate")).doubleValue());
            if (cmp != 0) return cmp;
            return Double.compare(((Number) b.get("delta")).doubleValue(), ((Number) a.get("delta")).doubleValue());
        });
        if (list.size() > safeLimit) {
            return new ArrayList<>(list.subList(0, safeLimit));
        }
        return list;
    }

    public List<Map<String, Object>> getDishCategoryRanking(LocalDateTime startDate, LocalDateTime endDate, String category, String metric, Integer limit) {
        int safeLimit = safeLimit(limit);
        boolean ratingMetric = "rating".equalsIgnoreCase(metric);

        List<Map<String, Object>> rows = ratingMetric
                ? queryDishCategoryRating(startDate, endDate, category)
                : queryDishCategorySales(startDate, endDate, category);

        Map<String, List<Map<String, Object>>> categoryToItems = new LinkedHashMap<>();
        Map<String, Double> categoryTotals = new HashMap<>();

        for (Map<String, Object> row : rows) {
            String catName = mapCategoryName(row.get("dish_category"));
            
            // 已经在SQL中过滤，这里只需处理映射后的分类名是否匹配（如果是枚举名查询）
            // 如果前端传的是中文名，而数据库存的是枚举，SQL过滤可能需要枚举值
            // 为保险起见，保留内存过滤作为二次检查，但SQL层面的过滤是性能关键
            if (category != null && !category.isBlank()) {
                String c = category.trim();
                // 如果catName是中文，c也是中文，则匹配
                // 如果c是枚举名，catName是中文，这里不匹配，但在SQL层已经过滤了枚举
                // 所以这里的检查主要用于确保结果的准确性
                if (!c.equalsIgnoreCase(catName) && !c.equalsIgnoreCase(String.valueOf(row.get("dish_category")))) {
                    continue;
                }
            }

            double v = row.get("metric_value") == null ? 0 : ((Number) row.get("metric_value")).doubleValue();
            Long dishId = row.get("dish_id") == null ? null : ((Number) row.get("dish_id")).longValue();
            String dishName = row.get("dish_name") == null ? "" : String.valueOf(row.get("dish_name"));

            Map<String, Object> item = new HashMap<>();
            item.put("id", dishId);
            item.put("name", dishName);
            item.put("value", v);
            if (ratingMetric) {
                item.put("rating", Math.round(v * 10.0) / 10.0);
            } else {
                item.put("sales", Math.round(v));
                item.put("qty", Math.round(v));
            }

            categoryToItems.computeIfAbsent(catName, k -> new ArrayList<>()).add(item);
            categoryTotals.put(catName, categoryTotals.getOrDefault(catName, 0.0) + v);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        List<Map.Entry<String, List<Map<String, Object>>>> entries = new ArrayList<>(categoryToItems.entrySet());
        entries.sort((a, b) -> Double.compare(categoryTotals.getOrDefault(b.getKey(), 0.0), categoryTotals.getOrDefault(a.getKey(), 0.0)));

        for (Map.Entry<String, List<Map<String, Object>>> entry : entries) {
            List<Map<String, Object>> items = entry.getValue();
            items.sort((a, b) -> Double.compare(((Number) b.get("value")).doubleValue(), ((Number) a.get("value")).doubleValue()));
            if (items.size() > safeLimit) {
                items = new ArrayList<>(items.subList(0, safeLimit));
            }
            Map<String, Object> cat = new HashMap<>();
            cat.put("category", entry.getKey());
            cat.put("top", items);
            result.add(cat);
        }

        return result;
    }

    public List<Map<String, Object>> getDishSalesRankingByPeriod(LocalDateTime startDate, LocalDateTime endDate) {
        String granularity = determineGranularity(startDate, endDate);

        String timeExpr;
        String alias;

        if ("hour".equals(granularity)) {
            timeExpr = "HOUR(oi.create_time)";
            alias = "h";
        } else if ("week".equals(granularity)) {
            timeExpr = "YEARWEEK(oi.create_time, 1)";
            alias = "w";
        } else if ("month".equals(granularity)) {
            timeExpr = "DATE_FORMAT(oi.create_time, '%Y-%m')";
            alias = "m";
        } else if ("quarter".equals(granularity)) {
            timeExpr = "CONCAT(YEAR(oi.create_time), '-Q', QUARTER(oi.create_time))";
            alias = "q";
        } else {
            timeExpr = "DATE(oi.create_time)";
            alias = "d";
        }

        String sql = "SELECT " + timeExpr + " as " + alias + ", d.name as dish_name, SUM(oi.quantity) as total_qty " +
                "FROM order_items oi " +
                "JOIN orders o ON oi.order_id = o.id " +
                "JOIN dishes d ON oi.dish_id = d.id " +
                "WHERE o.status = 'COMPLETED' AND oi.create_time >= ? AND oi.create_time <= ? " +
                "GROUP BY " + alias + ", d.id, d.name";

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startDate, endDate);

        Map<String, List<Map<String, Object>>> periodToItems = new HashMap<>();
        for (Map<String, Object> row : rows) {
            String key = extractTimeBucketKey(row, alias);
            if (key == null) continue;
            String name = String.valueOf(row.get("dish_name"));
            long qty = ((Number) row.get("total_qty")).longValue();

            Map<String, Object> item = new HashMap<>();
            item.put("name", name);
            item.put("qty", qty);

            periodToItems.computeIfAbsent(key, k -> new ArrayList<>()).add(item);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (TimeBucket bucket : buildTimeBuckets(granularity, startDate, endDate)) {
            List<Map<String, Object>> items = periodToItems.getOrDefault(bucket.key(), new ArrayList<>());
            items.sort((a, b) -> Long.compare(((Number) b.get("qty")).longValue(), ((Number) a.get("qty")).longValue()));
            if (items.size() > 10) {
                items = new ArrayList<>(items.subList(0, 10));
            }

            Map<String, Object> period = new HashMap<>();
            period.put("time", bucket.label());
            period.put("top", items);
            result.add(period);
        }

        return result;
    }

    private int safeLimit(Integer limit) {
        int safe = limit == null ? 10 : limit;
        if (safe < 1) safe = 1;
        if (safe > 50) safe = 50;
        return safe;
    }

    private Map<Long, Number> getDishSalesAggregate(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT d.id, SUM(oi.quantity) as total_qty " +
                "FROM order_items oi " +
                "JOIN orders o ON oi.order_id = o.id " +
                "JOIN dishes d ON oi.dish_id = d.id " +
                "WHERE o.status = 'COMPLETED' AND oi.create_time >= ? AND oi.create_time <= ? " +
                "GROUP BY d.id";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startDate, endDate);
        Map<Long, Number> result = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Long id = ((Number) row.get("id")).longValue();
            result.put(id, ((Number) row.get("total_qty")).doubleValue());
        }
        return result;
    }

    private Map<Long, Number> getDishRatingAggregate(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT d.id, AVG(ri.rating) as avg_rating " +
                "FROM review_items ri " +
                "JOIN reviews r ON ri.review_id = r.id " +
                "JOIN dishes d ON ri.dish_id = d.id " +
                "WHERE r.status = 'NORMAL' AND ri.rating IS NOT NULL AND r.create_time >= ? AND r.create_time <= ? " +
                "GROUP BY d.id";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startDate, endDate);
        Map<Long, Number> result = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Long id = ((Number) row.get("id")).longValue();
            result.put(id, ((Number) row.get("avg_rating")).doubleValue());
        }
        return result;
    }

    private List<Map<String, Object>> queryDishCategorySalesSummary(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT d.dish_category as dish_category, SUM(oi.quantity) as metric_value " +
                "FROM order_items oi " +
                "JOIN orders o ON oi.order_id = o.id " +
                "JOIN dishes d ON oi.dish_id = d.id " +
                "WHERE o.status = 'COMPLETED' AND oi.create_time >= ? AND oi.create_time <= ? " +
                "GROUP BY d.dish_category";
        return jdbcTemplate.queryForList(sql, startDate, endDate);
    }

    private List<Map<String, Object>> queryDishCategoryRatingSummary(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT d.dish_category as dish_category, AVG(ri.rating) as metric_value, COUNT(ri.rating) as rating_count " +
                "FROM review_items ri " +
                "JOIN reviews r ON ri.review_id = r.id " +
                "JOIN dishes d ON ri.dish_id = d.id " +
                "WHERE r.status = 'NORMAL' AND ri.rating IS NOT NULL AND r.create_time >= ? AND r.create_time <= ? " +
                "GROUP BY d.dish_category";
        return jdbcTemplate.queryForList(sql, startDate, endDate);
    }

    private Map<Long, String> getDishNamesUnion(Map<Long, Number> current, Map<Long, Number> previous) {
        Set<Long> ids = new HashSet<>();
        ids.addAll(current.keySet());
        ids.addAll(previous.keySet());
        if (ids.isEmpty()) return new HashMap<>();

        String placeholders = ids.stream().map(i -> "?").collect(Collectors.joining(","));
        String sql = "SELECT id, name FROM dishes WHERE id IN (" + placeholders + ")";
        List<Object> params = new ArrayList<>(ids);
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, params.toArray());
        Map<Long, String> result = new HashMap<>();
        for (Map<String, Object> row : rows) {
            result.put(((Number) row.get("id")).longValue(), String.valueOf(row.get("name")));
        }
        for (Long id : ids) {
            result.putIfAbsent(id, String.valueOf(id));
        }
        return result;
    }

    private List<Map<String, Object>> queryDishCategorySales(LocalDateTime startDate, LocalDateTime endDate, String category) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        
        sql.append("SELECT d.dish_category as dish_category, d.id as dish_id, d.name as dish_name, SUM(oi.quantity) as metric_value ")
           .append("FROM order_items oi ")
           .append("JOIN orders o ON oi.order_id = o.id ")
           .append("JOIN dishes d ON oi.dish_id = d.id ")
           .append("WHERE o.status = 'COMPLETED' AND oi.create_time >= ? AND oi.create_time <= ? ");
        
        params.add(startDate);
        params.add(endDate);
        
        if (category != null && !category.isBlank()) {
            // 尝试映射中文到枚举
            String enumName = mapCategoryToEnum(category);
            if (enumName != null) {
                sql.append("AND d.dish_category = ? ");
                params.add(enumName);
            } else {
                // 如果不是标准枚举，尝试直接匹配（兼容旧数据或非标准输入）
                sql.append("AND d.dish_category = ? ");
                params.add(category);
            }
        }
        
        sql.append("GROUP BY d.dish_category, d.id, d.name");
        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }

    private List<Map<String, Object>> queryDishCategoryRating(LocalDateTime startDate, LocalDateTime endDate, String category) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        
        sql.append("SELECT d.dish_category as dish_category, d.id as dish_id, d.name as dish_name, AVG(ri.rating) as metric_value ")
           .append("FROM review_items ri ")
           .append("JOIN reviews r ON ri.review_id = r.id ")
           .append("JOIN dishes d ON ri.dish_id = d.id ")
           .append("WHERE r.status = 'NORMAL' AND r.create_time >= ? AND r.create_time <= ? ");
           
        params.add(startDate);
        params.add(endDate);
        
        if (category != null && !category.isBlank()) {
            String enumName = mapCategoryToEnum(category);
            if (enumName != null) {
                sql.append("AND d.dish_category = ? ");
                params.add(enumName);
            } else {
                sql.append("AND d.dish_category = ? ");
                params.add(category);
            }
        }
        
        sql.append("GROUP BY d.dish_category, d.id, d.name");
        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }
    
    // 辅助方法：中文分类转枚举名
    private String mapCategoryToEnum(String cnName) {
        if (cnName == null) return null;
        String s = cnName.trim();
        switch (s) {
            case "主食": return "MAIN_DISH";
            case "荤菜": return "MEAT_DISH";
            case "素菜": return "VEGETABLE";
            case "汤类": return "SOUP";
            case "小吃": return "SNACK";
            case "饮品": return "BEVERAGE"; // BEVERAGE or DRINK
            case "配菜": return "SIDE_DISH";
            default: return null;
        }
    }

    private String extractTimeBucketKey(Map<String, Object> row, String alias) {
        Object v = row.get(alias);
        if (v == null) return null;
        if ("d".equals(alias) && v instanceof java.sql.Date) {
            return ((java.sql.Date) v).toLocalDate().toString();
        }
        return String.valueOf(v);
    }

    private record TimeBucket(String key, String label) {
    }

    private List<TimeBucket> buildTimeBuckets(String granularity, LocalDateTime startDate, LocalDateTime endDate) {
        List<TimeBucket> buckets = new ArrayList<>();

        if ("hour".equals(granularity)) {
            LocalDateTime curr = startDate.withMinute(0).withSecond(0).withNano(0);
            while (!curr.isAfter(endDate)) {
                int hour = curr.getHour();
                buckets.add(new TimeBucket(String.valueOf(hour), hour + "时"));
                curr = curr.plusHours(1);
                if (buckets.size() >= 24) break;
            }
            return buckets;
        }

        if ("week".equals(granularity)) {
            LocalDateTime curr = startDate;
            while (!curr.isAfter(endDate)) {
                int year = curr.get(java.time.temporal.WeekFields.ISO.weekBasedYear());
                int week = curr.get(java.time.temporal.WeekFields.ISO.weekOfWeekBasedYear());
                String key = String.format("%d%02d", year, week);
                buckets.add(new TimeBucket(key, week + "周"));
                curr = curr.plusWeeks(1);
            }
            return buckets;
        }

        if ("month".equals(granularity)) {
            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            while (!curr.isAfter(end)) {
                String key = curr.format(DateTimeFormatter.ofPattern("yyyy-MM"));
                String label = curr.format(DateTimeFormatter.ofPattern("yy年M月"));
                buckets.add(new TimeBucket(key, label));
                curr = curr.plusMonths(1);
            }
            return buckets;
        }

        if ("quarter".equals(granularity)) {
            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            while (!curr.isAfter(end)) {
                int q = (curr.getMonthValue() - 1) / 3 + 1;
                String key = curr.getYear() + "-Q" + q;
                String label = curr.getYear() + "年Q" + q;
                buckets.add(new TimeBucket(key, label));
                curr = curr.plusMonths(3);
            }
            return buckets;
        }

        LocalDate curr = startDate.toLocalDate();
        LocalDate end = endDate.toLocalDate();
        while (!curr.isAfter(end)) {
            buckets.add(new TimeBucket(curr.toString(), curr.format(DateTimeFormatter.ofPattern("MM-dd"))));
            curr = curr.plusDays(1);
        }
        return buckets;
    }

    // 获取用户活跃时段
    public List<Map<String, Object>> getUserActivePeriods(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT HOUR(t.order_time) as hour_of_day, COUNT(o.id) as order_count " +
                     "FROM orders o " +
                     "JOIN (SELECT order_id, MIN(create_time) as order_time FROM order_items GROUP BY order_id) t ON o.id = t.order_id " +
                     "WHERE o.status IN " + VALID_ORDER_STATUSES + " AND t.order_time >= ? AND t.order_time <= ? " +
                     "GROUP BY HOUR(t.order_time) " +
                     "ORDER BY hour_of_day";
                     
        List<Map<String, Object>> dbResult = jdbcTemplate.queryForList(sql, startDate, endDate);
        Map<Integer, Long> hourMap = new HashMap<>();
        
        for (Map<String, Object> row : dbResult) {
            hourMap.put(((Number)row.get("hour_of_day")).intValue(), ((Number)row.get("order_count")).longValue());
        }
        
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < 24; i++) {
            Map<String, Object> period = new HashMap<>();
            period.put("time", i + "-" + (i + 1));
            period.put("value", hourMap.getOrDefault(i, 0L));
            result.add(period);
        }
        return result;
    }

    // 获取品类销售占比
    public List<Map<String, Object>> getCategorySales(LocalDateTime startDate, LocalDateTime endDate) {
        String sql = "SELECT d.dish_category, SUM(oi.quantity) as total_qty " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.id " +
                     "JOIN dishes d ON oi.dish_id = d.id " +
                     "WHERE o.status = 'COMPLETED' AND oi.create_time >= ? AND oi.create_time <= ? " +
                     "GROUP BY d.dish_category";
                     
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new HashMap<>();
            String categoryName = mapCategoryName(rs.getObject("dish_category"));
            map.put("name", categoryName);
            map.put("value", rs.getLong("total_qty"));
            return map;
        }, startDate, endDate);
    }

    // 获取品类销售趋势（按日统计各品类销售额）
    public List<Map<String, Object>> getCategoryTrend(LocalDateTime startDate, LocalDateTime endDate) {
        String granularity = determineGranularity(startDate, endDate);

        String timeExpr;
        if ("hour".equals(granularity)) {
            timeExpr = "HOUR(oi.create_time)";
        } else if ("week".equals(granularity)) {
            timeExpr = "YEARWEEK(oi.create_time, 1)";
        } else if ("month".equals(granularity)) {
            timeExpr = "DATE_FORMAT(oi.create_time, '%Y-%m')";
        } else if ("quarter".equals(granularity)) {
            timeExpr = "CONCAT(YEAR(oi.create_time), '-Q', QUARTER(oi.create_time))";
        } else {
            timeExpr = "DATE(oi.create_time)";
        }

        String sql = "SELECT " + timeExpr + " as t, d.dish_category, " +
                     "SUM(oi.quantity * d.price) as amount " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.id " +
                     "JOIN dishes d ON oi.dish_id = d.id " +
                     "WHERE o.status IN " + VALID_ORDER_STATUSES + " AND oi.create_time >= ? AND oi.create_time <= ? " +
                     "GROUP BY " + timeExpr + ", d.dish_category";

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startDate, endDate);

        // Parse rows: Time -> { Category -> Amount }
        Map<String, Map<String, BigDecimal>> rawData = new HashMap<>();
        Set<String> allCategories = new HashSet<>();

        for (Map<String, Object> row : rows) {
            String timeKey = row.get("t").toString();
            String catName = mapCategoryName(row.get("dish_category"));
            allCategories.add(catName);

            rawData.putIfAbsent(timeKey, new HashMap<>());
            rawData.get(timeKey).put(catName, new BigDecimal(row.get("amount").toString()));
        }

        List<Map<String, Object>> result = new ArrayList<>();

        if ("hour".equals(granularity)) { 
            // Similar to formatTrendData for hour
             for (int i = 0; i < 24; i++) {
                LocalDateTime curr = startDate.withHour(i);
                if (curr.isAfter(endDate)) break; // Though startDate might not be today
                Map<String, Object> item = new HashMap<>();
                item.put("date", i + "时");
                fillCategories(item, String.valueOf(i), rawData, allCategories);
                result.add(item);
            }
        } else if ("week".equals(granularity)) {
            LocalDateTime curr = startDate;
            while (!curr.isAfter(endDate)) {
                 int year = curr.get(java.time.temporal.WeekFields.ISO.weekBasedYear());
                 int week = curr.get(java.time.temporal.WeekFields.ISO.weekOfWeekBasedYear());
                 String key = String.format("%d%02d", year, week);
                 
                 Map<String, Object> item = new HashMap<>();
                 item.put("date", week + "周");
                 fillCategories(item, key, rawData, allCategories);
                 result.add(item);
                 
                 curr = curr.plusWeeks(1);
            }
        } else if ("day".equals(granularity)) {
            LocalDate curr = startDate.toLocalDate();
            LocalDate end = endDate.toLocalDate();
            while (!curr.isAfter(end)) {
                Map<String, Object> item = new HashMap<>();
                item.put("date", curr.format(DateTimeFormatter.ofPattern("MM-dd")));
                fillCategories(item, curr.toString(), rawData, allCategories);
                result.add(item);
                curr = curr.plusDays(1);
            }
        } else if ("month".equals(granularity)) {
            LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
            LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
            while (!curr.isAfter(end)) {
                String key = curr.format(DateTimeFormatter.ofPattern("yyyy-MM"));
                Map<String, Object> item = new HashMap<>();
                item.put("date", curr.format(DateTimeFormatter.ofPattern("yy年M月")));
                fillCategories(item, key, rawData, allCategories);
                result.add(item);
                curr = curr.plusMonths(1);
            }
        } else if ("quarter".equals(granularity)) {
             LocalDate curr = startDate.toLocalDate().withDayOfMonth(1);
             LocalDate end = endDate.toLocalDate().withDayOfMonth(1);
             while (!curr.isAfter(end)) {
                 int q = (curr.getMonthValue() - 1) / 3 + 1;
                 String key = curr.getYear() + "-Q" + q;
                 
                 Map<String, Object> item = new HashMap<>();
                 item.put("date", curr.getYear() + "年Q" + q);
                 fillCategories(item, key, rawData, allCategories);
                 result.add(item);
                 
                 curr = curr.plusMonths(3);
             }
        }

        return result;
    }

    private void fillCategories(Map<String, Object> item, String key, Map<String, Map<String, BigDecimal>> rawData, Set<String> allCategories) {
        Map<String, BigDecimal> data = rawData.getOrDefault(key, new HashMap<>());
        for (String cat : allCategories) {
            item.put(cat, data.getOrDefault(cat, BigDecimal.ZERO));
        }
    }
    
    // 辅助方法：映射分类名称
    private String mapCategoryName(Object categoryObj) {
        if (categoryObj == null) return "未知";
        String s = categoryObj.toString().trim();
        
        // 尝试解析数字索引（兼容旧数据）
        if (s.matches("\\d+")) {
            try {
                int catIndex = Integer.parseInt(s);
                String[] names = {"主食", "荤菜", "素菜", "汤类", "小吃", "饮品"};
                if (catIndex >= 0 && catIndex < names.length) {
                    return names[catIndex];
                }
            } catch (NumberFormatException ignored) {}
        }

        // 映射枚举字符串
        if ("MAIN_DISH".equalsIgnoreCase(s)) return "主食";
        if ("MEAT_DISH".equalsIgnoreCase(s)) return "荤菜";
        if ("VEGETABLE".equalsIgnoreCase(s)) return "素菜";
        if ("SOUP".equalsIgnoreCase(s)) return "汤类";
        if ("SNACK".equalsIgnoreCase(s)) return "小吃";
        if ("BEVERAGE".equalsIgnoreCase(s) || "DRINK".equalsIgnoreCase(s)) return "饮品";
        if ("SIDE_DISH".equalsIgnoreCase(s)) return "配菜";
        
        return s;
    }

    // 获取评价关键词
    public Map<String, Object> getReviewKeywords(LocalDateTime startDate, LocalDateTime endDate) {
        // 尝试从 review_quick_tags 统计
        try {
            String sql = "SELECT quick_tag, COUNT(*) as cnt FROM review_quick_tags qt " +
                         "JOIN reviews r ON qt.review_id = r.id " +
                         "WHERE r.create_time >= ? AND r.create_time <= ? AND r.status = 'NORMAL' " +
                         "GROUP BY quick_tag ORDER BY cnt DESC LIMIT 20";
            
            List<Map<String, Object>> tags = jdbcTemplate.queryForList(sql, startDate, endDate);
            if (!tags.isEmpty()) {
                Map<String, Integer> keywords = new HashMap<>();
                for (Map<String, Object> row : tags) {
                    keywords.put((String)row.get("quick_tag"), ((Number)row.get("cnt")).intValue());
                }
                Map<String, Object> result = new HashMap<>();
                result.put("keywords", keywords);
                result.put("totalReviews", tags.stream().mapToInt(m -> ((Number)m.get("cnt")).intValue()).sum());
                return result;
            }
        } catch (Exception e) {
            // ignore
        }

        // 降级：从评论文本统计
        String sql = "SELECT comment FROM reviews WHERE create_time >= ? AND create_time <= ? AND status = 'NORMAL'";
        List<String> comments = jdbcTemplate.queryForList(sql, String.class, startDate, endDate);
        
        Map<String, Integer> wordCounts = new HashMap<>();
        List<String> stopWords = Arrays.asList("的", "了", "是", "我", "你", "他", "在", "就", "不", "也", "很", "非常", "这个", "那个", "味道", "感觉");
        
        for (String comment : comments) {
            if (comment != null && !comment.isEmpty()) {
                String[] words = comment.split("[^\\u4e00-\\u9fa5]+");
                for (String w : words) {
                    if (w.length() > 1 && !stopWords.contains(w)) {
                        wordCounts.put(w, wordCounts.getOrDefault(w, 0) + 1);
                    }
                }
            }
        }
        
        Map<String, Integer> topKeywords = wordCounts.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                .limit(20)
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue, (e1, e2) -> e1, LinkedHashMap::new));
                
        Map<String, Object> result = new HashMap<>();
        result.put("keywords", topKeywords);
        result.put("totalReviews", comments.size());
        return result;
    }

    // 获取菜品特征词云
    public Map<String, Object> getDishFeatures() {
        Map<String, Integer> features = new HashMap<>();

        String quickTagSql = "SELECT qt.quick_tag FROM review_quick_tags qt " +
                             "JOIN reviews r ON qt.review_id = r.id " +
                             "WHERE r.status = 'NORMAL'";
        List<String> quickTags = jdbcTemplate.queryForList(quickTagSql, String.class);
        
        for (String tag : quickTags) {
            if (tag == null) continue;
            String t = tag.trim();
            if (!t.isEmpty()) {
                features.put(t, features.getOrDefault(t, 0) + 1);
            }
        }

        String sql = "SELECT comment FROM reviews WHERE comment IS NOT NULL AND comment <> '' AND status = 'NORMAL'";
        List<String> comments = jdbcTemplate.queryForList(sql, String.class);

        List<String> keywords = Arrays.asList(
                "好吃", "美味", "推荐", "不错", "一般", "分量足", "分量少", "量大", "量小",
                "实惠", "偏甜", "太甜", "偏咸", "太咸", "鲜", "香", "辣", "清淡", "油腻",
                "酥脆", "软嫩", "入口", "热", "冷",
                "色泽诱人", "卖相好", "香气扑鼻", "味道好", "口感好", "食材新鲜", "干净卫生", "服务好", "环境好"
        );
        List<String> stopWords = Arrays.asList("的", "了", "是", "我", "你", "他", "在", "就", "不", "也", "很", "非常", "这个", "那个", "味道", "感觉");

        for (String comment : comments) {
            if (comment == null || comment.isEmpty()) continue;
            for (String kw : keywords) {
                if (comment.contains(kw)) {
                    features.put(kw, features.getOrDefault(kw, 0) + 1);
                }
            }
            String[] words = comment.split("[^\\u4e00-\\u9fa5]+");
            for (String w : words) {
                if (w.length() > 1 && !stopWords.contains(w)) {
                    features.put(w, features.getOrDefault(w, 0) + 1);
                }
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("features", features);
        return result;
    }

    public Map<String, Object> getDishFeaturesWordcloud(LocalDateTime startDate, LocalDateTime endDate,
                                                        Long canteenId, Long windowId,
                                                        Integer topN, Integer minWordLength, Integer minFrequency,
                                                        Double wReviews, Double wSales) {
        DishFeatureKeywordEngine.Params params = new DishFeatureKeywordEngine.Params(
                topN == null ? 50 : topN,
                minWordLength == null ? 2 : minWordLength,
                minFrequency == null ? 1 : minFrequency,
                wReviews == null ? 1.0 : wReviews,
                wSales == null ? 0.0 : wSales
        );
        long version = getDishFeaturesWordcloudVersion(startDate, endDate, canteenId, windowId, params.wSales() > 0);
        String cacheKey = buildDishFeatureCacheKey(startDate, endDate, canteenId, windowId, params);
        CachedDishFeatureWordcloud cached = dishFeatureWordcloudCache.get(cacheKey);
        if (cached != null && (System.currentTimeMillis() - cached.ts) <= DISH_FEATURE_WORDCLOUD_CACHE_TTL_MS && cached.version == version) {
            return cached.data;
        }

        Map<Long, Integer> dishSales = params.wSales() > 0 ? queryDishSalesCount(startDate, endDate, canteenId, windowId) : Collections.emptyMap();
        List<DishFeatureKeywordEngine.DishReviewDoc> docs = queryDishReviewDocs(startDate, endDate, canteenId, windowId);
        DishFeatureKeywordEngine.Result computed = DishFeatureKeywordEngine.compute(docs, dishSales, version, params);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("version", computed.getVersion());
        result.put("keywords", computed.getKeywords());
        result.put("matchedReviews", computed.getMatchedReviews());
        result.put("coveredDishes", computed.getCoveredDishes());

        dishFeatureWordcloudCache.put(cacheKey, new CachedDishFeatureWordcloud(System.currentTimeMillis(), version, result));
        cleanupDishFeatureCache();
        return result;
    }

    public long getDishFeaturesWordcloudVersion(LocalDateTime startDate, LocalDateTime endDate,
                                                Long canteenId, Long windowId, boolean includeSales) {
        long v1 = queryMaxReviewTime(startDate, endDate, canteenId, windowId);
        long v2 = includeSales ? queryMaxOrderItemTime(startDate, endDate, canteenId, windowId) : 0;
        return Math.max(v1, v2);
    }

    private void cleanupDishFeatureCache() {
        long now = System.currentTimeMillis();
        Iterator<Map.Entry<String, CachedDishFeatureWordcloud>> it = dishFeatureWordcloudCache.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<String, CachedDishFeatureWordcloud> e = it.next();
            if (now - e.getValue().ts > DISH_FEATURE_WORDCLOUD_CACHE_TTL_MS) it.remove();
        }
    }

    private String buildDishFeatureCacheKey(LocalDateTime startDate, LocalDateTime endDate, Long canteenId, Long windowId, DishFeatureKeywordEngine.Params params) {
        return String.join("|",
                startDate == null ? "" : startDate.toString(),
                endDate == null ? "" : endDate.toString(),
                canteenId == null ? "" : String.valueOf(canteenId),
                windowId == null ? "" : String.valueOf(windowId),
                String.valueOf(params.topN()),
                String.valueOf(params.minWordLength()),
                String.valueOf(params.minFrequency()),
                String.valueOf(params.wReviews()),
                String.valueOf(params.wSales())
        );
    }

    private List<DishFeatureKeywordEngine.DishReviewDoc> queryDishReviewDocs(LocalDateTime startDate, LocalDateTime endDate, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT ri.dish_id, ri.review_id, r.comment ")
                .append("FROM review_items ri ")
                .append("JOIN reviews r ON ri.review_id = r.id ");
        if (canteenId != null || windowId != null) {
            sql.append("JOIN dishes d ON ri.dish_id = d.id ");
        }
        sql.append("WHERE r.status = 'NORMAL' AND r.create_time >= ? AND r.create_time <= ? ");
        params.add(startDate);
        params.add(endDate);
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());

        Map<String, String> commentByKey = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            Long dishId = row.get("dish_id") == null ? null : ((Number) row.get("dish_id")).longValue();
            Long reviewId = row.get("review_id") == null ? null : ((Number) row.get("review_id")).longValue();
            if (dishId == null || reviewId == null) continue;
            String key = dishId + "|" + reviewId;
            commentByKey.putIfAbsent(key, (String) row.get("comment"));
        }

        StringBuilder tagSql = new StringBuilder();
        List<Object> tagParams = new ArrayList<>();
        tagSql.append("SELECT ri.dish_id, ri.review_id, qt.quick_tag ")
                .append("FROM review_items ri ")
                .append("JOIN reviews r ON ri.review_id = r.id ")
                .append("JOIN review_quick_tags qt ON qt.review_id = r.id ");
        if (canteenId != null || windowId != null) {
            tagSql.append("JOIN dishes d ON ri.dish_id = d.id ");
        }
        tagSql.append("WHERE r.status = 'NORMAL' AND r.create_time >= ? AND r.create_time <= ? ");
        tagParams.add(startDate);
        tagParams.add(endDate);
        if (canteenId != null) {
            tagSql.append("AND d.canteen_id = ? ");
            tagParams.add(canteenId);
        }
        if (windowId != null) {
            tagSql.append("AND d.window_id = ? ");
            tagParams.add(windowId);
        }
        List<Map<String, Object>> tagRows = jdbcTemplate.queryForList(tagSql.toString(), tagParams.toArray());
        Map<String, List<String>> tagsByKey = new HashMap<>();
        for (Map<String, Object> row : tagRows) {
            Long dishId = row.get("dish_id") == null ? null : ((Number) row.get("dish_id")).longValue();
            Long reviewId = row.get("review_id") == null ? null : ((Number) row.get("review_id")).longValue();
            if (dishId == null || reviewId == null) continue;
            String tag = (String) row.get("quick_tag");
            String key = dishId + "|" + reviewId;
            tagsByKey.computeIfAbsent(key, k -> new ArrayList<>()).add(tag);
        }

        List<DishFeatureKeywordEngine.DishReviewDoc> docs = new ArrayList<>();
        for (Map.Entry<String, String> e : commentByKey.entrySet()) {
            String[] parts = e.getKey().split("\\|", 2);
            Long dishId = Long.parseLong(parts[0]);
            docs.add(new DishFeatureKeywordEngine.DishReviewDoc(dishId, e.getValue(), tagsByKey.getOrDefault(e.getKey(), Collections.emptyList())));
        }
        return docs;
    }

    private Map<Long, Integer> queryDishSalesCount(LocalDateTime startDate, LocalDateTime endDate, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT oi.dish_id, SUM(oi.quantity) AS qty ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN " + VALID_ORDER_STATUSES + " ");
        params.add(startDate);
        params.add(endDate);
        if (canteenId != null) {
            sql.append(" AND d.canteen_id = ?");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append(" AND d.window_id = ?");
            params.add(windowId);
        }
        sql.append(" GROUP BY oi.dish_id");
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        Map<Long, Integer> map = new HashMap<>();
        for (Map<String, Object> r : rows) {
            Long dishId = r.get("dish_id") == null ? null : ((Number) r.get("dish_id")).longValue();
            if (dishId == null) continue;
            map.put(dishId, ((Number) r.get("qty")).intValue());
        }
        return map;
    }

    public Map<Long, Integer> getDishSalesCount(Long canteenId, Long windowId) {
        LocalDateTime startDate = LocalDateTime.of(1970, 1, 1, 0, 0);
        LocalDateTime endDate = LocalDateTime.now();
        return queryDishSalesCount(startDate, endDate, canteenId, windowId);
    }

    private long queryMaxReviewTime(LocalDateTime startDate, LocalDateTime endDate, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT MAX(r.create_time) AS max_time ")
                .append("FROM reviews r ")
                .append("JOIN review_items ri ON ri.review_id = r.id ");
        if (canteenId != null || windowId != null) {
            sql.append("JOIN dishes d ON ri.dish_id = d.id ");
        }
        sql.append("WHERE r.status = 'NORMAL' AND r.create_time >= ? AND r.create_time <= ? ");
        params.add(startDate);
        params.add(endDate);
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        Timestamp ts = jdbcTemplate.queryForObject(sql.toString(), Timestamp.class, params.toArray());
        return ts == null ? 0 : ts.getTime();
    }

    private long queryMaxOrderItemTime(LocalDateTime startDate, LocalDateTime endDate, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT MAX(oi.create_time) AS max_time ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN " + VALID_ORDER_STATUSES + " ");
        params.add(startDate);
        params.add(endDate);
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        Timestamp ts = jdbcTemplate.queryForObject(sql.toString(), Timestamp.class, params.toArray());
        return ts == null ? 0 : ts.getTime();
    }

    public List<DishFeatureDTO.RelatedDish> getDishFeaturesWordcloudDishes(LocalDateTime startDate, LocalDateTime endDate,
                                                                   Long canteenId, Long windowId, String keyword) {
        if (keyword == null || keyword.isBlank()) return Collections.emptyList();
        String kw = keyword.trim();
        Map<Long, Integer> sales = queryDishSalesCount(startDate, endDate, canteenId, windowId);

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT ri.dish_id, COUNT(DISTINCT ri.review_id) AS hit_cnt ")
                .append("FROM review_items ri ")
                .append("JOIN reviews r ON ri.review_id = r.id ")
                .append("LEFT JOIN review_quick_tags qt ON qt.review_id = r.id ")
                .append("JOIN dishes d ON ri.dish_id = d.id ")
                .append("WHERE r.status = 'NORMAL' AND r.create_time >= ? AND r.create_time <= ? ")
                .append("AND (r.comment LIKE ? OR qt.quick_tag LIKE ?) ");
        params.add(startDate);
        params.add(endDate);
        params.add("%" + kw + "%");
        params.add("%" + kw + "%");
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        sql.append("GROUP BY ri.dish_id ORDER BY hit_cnt DESC LIMIT 50");

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        if (rows.isEmpty()) return Collections.emptyList();

        List<Long> dishIds = rows.stream()
                .map(r -> ((Number) r.get("dish_id")).longValue())
                .collect(Collectors.toList());
        Map<Long, Integer> hitCount = new HashMap<>();
        for (Map<String, Object> r : rows) {
            hitCount.put(((Number) r.get("dish_id")).longValue(), ((Number) r.get("hit_cnt")).intValue());
        }

        String in = dishIds.stream().map(id -> "?").collect(Collectors.joining(","));
        List<Object> dishParams = new ArrayList<>(dishIds);
        String dishSql = "SELECT id, name, price, dish_category, canteen_id, canteen_name, window_id, window_name, average_rating " +
                "FROM dishes WHERE id IN (" + in + ")";
        List<Map<String, Object>> dishRows = jdbcTemplate.queryForList(dishSql, dishParams.toArray());
        Map<Long, DishFeatureDTO.RelatedDish> dtoMap = new HashMap<>();
        for (Map<String, Object> r : dishRows) {
            DishFeatureDTO.RelatedDish dto = new DishFeatureDTO.RelatedDish();
            Long id = ((Number) r.get("id")).longValue();
            dto.setId(id);
            dto.setName((String) r.get("name"));
            dto.setPrice((BigDecimal) r.get("price"));
            dto.setDishCategory(r.get("dish_category") == null ? null : String.valueOf(r.get("dish_category")));
            dto.setCanteenId(r.get("canteen_id") == null ? null : ((Number) r.get("canteen_id")).longValue());
            dto.setCanteenName(r.get("canteen_name") == null ? null : String.valueOf(r.get("canteen_name")));
            dto.setWindowId(r.get("window_id") == null ? null : ((Number) r.get("window_id")).longValue());
            dto.setWindowName(r.get("window_name") == null ? null : String.valueOf(r.get("window_name")));
            dto.setAverageRating(r.get("average_rating") == null ? null : ((Number) r.get("average_rating")).doubleValue());
            dtoMap.put(id, dto);
        }

        List<DishFeatureDTO.RelatedDish> result = new ArrayList<>();
        for (Long dishId : dishIds) {
            DishFeatureDTO.RelatedDish dto = dtoMap.get(dishId);
            if (dto == null) continue;
            dto.setSalesCount(sales.getOrDefault(dishId, 0));
            dto.setReviewHitCount(hitCount.getOrDefault(dishId, 0));
            dto.setHitSources(Arrays.asList("REVIEW"));
            result.add(dto);
        }
        result.sort((a, b) -> {
            int cmp = Integer.compare(b.getReviewHitCount() == null ? 0 : b.getReviewHitCount(), a.getReviewHitCount() == null ? 0 : a.getReviewHitCount());
            if (cmp != 0) return cmp;
            return Integer.compare(b.getSalesCount() == null ? 0 : b.getSalesCount(), a.getSalesCount() == null ? 0 : a.getSalesCount());
        });
        return result;
    }

    // 获取用户偏好
    public Map<String, Object> getUserPreferences(Long userId) {
        Map<String, Object> preferences = new HashMap<>();
        
        String catSql = "SELECT d.dish_category as dish_category, COUNT(*) as cnt " +
                        "FROM order_items oi " +
                        "JOIN orders o ON oi.order_id = o.id " +
                        "JOIN dishes d ON oi.dish_id = d.id " +
                        "WHERE o.user_id = ? AND o.status IN " + VALID_ORDER_STATUSES + " " +
                        "GROUP BY d.dish_category ORDER BY cnt DESC LIMIT 1";
        
        try {
            List<Map<String, Object>> catResult = jdbcTemplate.queryForList(catSql, userId);
            if (!catResult.isEmpty()) {
                preferences.put("favoriteCategory", mapCategoryName(catResult.get(0).get("dish_category")));
            } else {
                preferences.put("favoriteCategory", "暂无数据");
            }
        } catch (Exception e) {
            preferences.put("favoriteCategory", "暂无数据");
        }

        String dishSql = "SELECT d.name, COUNT(*) as cnt " +
                         "FROM order_items oi " +
                         "JOIN orders o ON oi.order_id = o.id " +
                         "JOIN dishes d ON oi.dish_id = d.id " +
                         "WHERE o.user_id = ? AND o.status IN " + VALID_ORDER_STATUSES + " " +
                         "GROUP BY d.name ORDER BY cnt DESC LIMIT 3";
                         
        List<String> favDishes = jdbcTemplate.query(dishSql, (rs, rowNum) -> rs.getString("name"), userId);
        preferences.put("favoriteDishes", favDishes);
        
        String avgSql = "SELECT AVG(total_amount) FROM orders WHERE user_id = ? AND status IN " + VALID_ORDER_STATUSES;
        BigDecimal avgSpend = jdbcTemplate.queryForObject(avgSql, BigDecimal.class, userId);
        preferences.put("averageSpending", avgSpend != null ? avgSpend.setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO);
        
        String timeSql = "SELECT HOUR(t.order_time) as h, COUNT(*) as cnt " +
                         "FROM orders o " +
                         "JOIN (SELECT order_id, MIN(create_time) as order_time FROM order_items GROUP BY order_id) t ON o.id = t.order_id " +
                         "WHERE user_id = ? GROUP BY h ORDER BY cnt DESC LIMIT 1";
        try {
            List<Map<String, Object>> timeResult = jdbcTemplate.queryForList(timeSql, userId);
            if (!timeResult.isEmpty()) {
                int hour = ((Number)timeResult.get(0).get("h")).intValue();
                String timePeriod;
                if (hour >= 6 && hour < 10) timePeriod = "早餐";
                else if (hour >= 10 && hour < 14) timePeriod = "午餐";
                else if (hour >= 14 && hour < 17) timePeriod = "下午茶";
                else if (hour >= 17 && hour < 21) timePeriod = "晚餐";
                else timePeriod = "夜宵";
                preferences.put("frequentTime", timePeriod);
            } else {
                preferences.put("frequentTime", "暂无数据");
            }
        } catch (Exception e) {
             preferences.put("frequentTime", "暂无数据");
        }

        fillUserPreferenceDetails(preferences, userId);
        return preferences;
    }

    private void fillUserPreferenceDetails(Map<String, Object> preferences, Long userId) {
        try {
            String userSql = "SELECT spiciness_level, sweetness_level, dietary_restrictions FROM users WHERE id = ?";
            List<Map<String, Object>> userRows = jdbcTemplate.queryForList(userSql, userId);
            if (!userRows.isEmpty()) {
                Map<String, Object> row = userRows.get(0);
                Integer spicy = row.get("spiciness_level") == null ? null : ((Number) row.get("spiciness_level")).intValue();
                Integer sweet = row.get("sweetness_level") == null ? null : ((Number) row.get("sweetness_level")).intValue();
                String restrictions = row.get("dietary_restrictions") == null ? null : String.valueOf(row.get("dietary_restrictions"));
                if (spicy != null) {
                    preferences.put("spicinessLevel", spicy);
                    preferences.put("spiceLevel", mapSpicinessLevel(spicy));
                }
                if (sweet != null) {
                    preferences.put("sweetnessLevel", sweet);
                    preferences.put("sweetnessText", mapSweetnessLevel(sweet));
                }
                if (restrictions != null && !restrictions.isBlank()) {
                    preferences.put("dietaryRestrictions", restrictions);
                }
            }
        } catch (Exception ignored) {
        }

        LinkedHashSet<String> tags = new LinkedHashSet<>();
        try {
            String profileSql = "SELECT flavor_preferences, dietary_restrictions FROM user_profile WHERE user_id = ?";
            List<Map<String, Object>> profileRows = jdbcTemplate.queryForList(profileSql, userId);
            if (!profileRows.isEmpty()) {
                Map<String, Object> row = profileRows.get(0);
                Object flavor = row.get("flavor_preferences");
                if (flavor != null) {
                    String[] parts = String.valueOf(flavor).split(",");
                    for (String part : parts) {
                        String trimmed = part.trim();
                        if (!trimmed.isEmpty() && !trimmed.startsWith("辣度:") && !trimmed.startsWith("甜度:")) {
                            tags.add(trimmed);
                        }
                    }
                }
                if (!preferences.containsKey("dietaryRestrictions")) {
                    Object restrictions = row.get("dietary_restrictions");
                    if (restrictions != null && !String.valueOf(restrictions).isBlank()) {
                        preferences.put("dietaryRestrictions", String.valueOf(restrictions));
                    }
                }
            }
        } catch (Exception ignored) {
        }

        if (!tags.isEmpty()) {
            preferences.put("dietaryTags", new ArrayList<>(tags));
        }

        try {
            String tagSql = "SELECT dt.taste_tag as tag, COUNT(*) as cnt " +
                    "FROM order_items oi " +
                    "JOIN orders o ON oi.order_id = o.id " +
                    "JOIN dish_taste_tags dt ON oi.dish_id = dt.dish_id " +
                    "WHERE o.user_id = ? AND o.status IN " + VALID_ORDER_STATUSES + " " +
                    "GROUP BY dt.taste_tag ORDER BY cnt DESC LIMIT 6";
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(tagSql, userId);
            List<Map<String, Object>> topTags = new ArrayList<>();
            for (Map<String, Object> row : rows) {
                Map<String, Object> item = new HashMap<>();
                item.put("tag", row.get("tag"));
                item.put("count", row.get("cnt"));
                topTags.add(item);
            }
            if (!topTags.isEmpty()) {
                preferences.put("topTasteTags", topTags);
            }
        } catch (Exception ignored) {
        }
    }

    private String mapSpicinessLevel(Integer level) {
        if (level == null) return "适中";
        return switch (level) {
            case 1 -> "不辣";
            case 2 -> "微辣";
            case 4 -> "很辣";
            case 5 -> "爆辣";
            default -> "适中";
        };
    }

    private String mapSweetnessLevel(Integer level) {
        if (level == null) return "适中";
        return switch (level) {
            case 1 -> "不甜";
            case 2 -> "微甜";
            case 4 -> "很甜";
            case 5 -> "超甜";
            default -> "适中";
        };
    }

    // 获取健康饮食建议
    public List<Map<String, Object>> getHealthRecommendations(Long userId) {
        // Keep as is
        List<Map<String, Object>> recommendations = new ArrayList<>();
        
        // 分析用户最近20单
        String sql = "SELECT d.dish_category, d.name " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.id " +
                     "JOIN dishes d ON oi.dish_id = d.id " +
                     "WHERE o.user_id = ? AND o.status = 'COMPLETED' " +
                     "ORDER BY oi.create_time DESC LIMIT 20";
                     
        List<Map<String, Object>> history = jdbcTemplate.queryForList(sql, userId);
        
        long meatCount = history.stream().filter(m -> mapCategoryName(m.get("dish_category")).equals("荤菜")).count();
        long vegCount = history.stream().filter(m -> mapCategoryName(m.get("dish_category")).equals("素菜")).count();
        
        if (meatCount > vegCount * 2) {
            Map<String, Object> rec = new HashMap<>();
            rec.put("type", "饮食平衡");
            rec.put("content", "您最近肉类摄入较多，建议多吃蔬菜，推荐：清炒时蔬、西兰花。");
            recommendations.add(rec);
        }
        
        if (vegCount > meatCount * 3) {
            Map<String, Object> rec = new HashMap<>();
            rec.put("type", "营养补充");
            rec.put("content", "您最近素食为主，注意补充蛋白质，推荐：红烧肉、蒸鱼。");
            recommendations.add(rec);
        }
        
        if (recommendations.isEmpty()) {
             Map<String, Object> rec = new HashMap<>();
            rec.put("type", "健康保持");
            rec.put("content", "您的饮食结构很均衡，请继续保持！");
            recommendations.add(rec);
        }
        
        return recommendations;
    }

    // 获取关联规则 (简化Apriori)
    public List<Map<String, Object>> getAssociationRules(LocalDateTime startDate, LocalDateTime endDate) {
        return getAssociationRules(startDate, endDate, null, null, null, null, null, null, null);
    }

    public List<Map<String, Object>> getAssociationRules(
            LocalDateTime startDate,
            LocalDateTime endDate,
            Double minSupport,
            Double minConfidence,
            Double minLift,
            Integer topN,
            String level,
            Long canteenId,
            Long windowId
    ) {
        LocalDateTime start = startDate == null ? LocalDateTime.now().minusDays(7) : startDate;
        LocalDateTime end = endDate == null ? LocalDateTime.now() : endDate;
        if (end.isBefore(start)) {
            LocalDateTime tmp = start;
            start = end;
            end = tmp;
        }

        double supportThreshold = clampDouble(minSupport, 0.01, 0.0, 1.0);
        double confidenceThreshold = clampDouble(minConfidence, 0.2, 0.0, 1.0);
        double liftThreshold = clampDouble(minLift, 1.05, 0.0, 1000.0);
        int limit = safeIntRange(topN, 20, 1, 100);
        String resolvedLevel = (level == null || level.isBlank()) ? "DISH" : level.trim().toUpperCase();
        if (!resolvedLevel.equals("DISH") && !resolvedLevel.equals("CATEGORY")) {
            resolvedLevel = "DISH";
        }

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT oi.order_id, d.name AS dish_name, d.dish_category AS dish_category ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                .append("AND o.total_amount > 0 ")
                .append("AND (oi.is_gift IS NULL OR oi.is_gift = false) ");
        params.add(start);
        params.add(end);
        
        // 食堂和窗口过滤逻辑已移除，进行全量分析
        
        sql.append("ORDER BY oi.order_id");

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        if (rows == null || rows.isEmpty()) return new ArrayList<>();

        Map<Long, LinkedHashSet<String>> orderToTokens = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            Object orderIdObj = row.get("order_id");
            if (orderIdObj == null) continue;
            Long orderId = ((Number) orderIdObj).longValue();
            String token = toAssociationToken(resolvedLevel, row);
            if (token == null || token.isBlank()) continue;
            orderToTokens.computeIfAbsent(orderId, k -> new LinkedHashSet<>()).add(token);
        }

        int orderCount = orderToTokens.size();
        if (orderCount <= 0) return new ArrayList<>();

        Map<String, Integer> singleCount = new HashMap<>();
        Map<String, Integer> pairCount = new HashMap<>();

        for (LinkedHashSet<String> set : orderToTokens.values()) {
            if (set == null || set.isEmpty()) continue;
            List<String> tokens = new ArrayList<>(set);
            for (String t : tokens) {
                singleCount.put(t, singleCount.getOrDefault(t, 0) + 1);
            }
            tokens.sort(String::compareTo);
            for (int i = 0; i < tokens.size(); i++) {
                for (int j = i + 1; j < tokens.size(); j++) {
                    String a = tokens.get(i);
                    String b = tokens.get(j);
                    String key = a + "|||" + b;
                    pairCount.put(key, pairCount.getOrDefault(key, 0) + 1);
                }
            }
        }

        List<Map<String, Object>> rules = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : pairCount.entrySet()) {
            String key = entry.getKey();
            int count = entry.getValue() == null ? 0 : entry.getValue();
            if (count <= 0) continue;
            String[] parts = key.split("\\|\\|\\|", 2);
            if (parts.length != 2) continue;
            String a = parts[0];
            String b = parts[1];
            Integer aCount = singleCount.get(a);
            Integer bCount = singleCount.get(b);
            if (aCount == null || aCount <= 0 || bCount == null || bCount <= 0) continue;

            double support = (double) count / (double) orderCount;
            if (support < supportThreshold) continue;

            addDirectedAssociationRule(rules, a, b, count, orderCount, aCount, bCount, support, confidenceThreshold, liftThreshold, resolvedLevel);
            addDirectedAssociationRule(rules, b, a, count, orderCount, bCount, aCount, support, confidenceThreshold, liftThreshold, resolvedLevel);
        }

        rules.sort((x, y) -> {
            int byLift = Double.compare(((Number) y.getOrDefault("lift", 0.0)).doubleValue(), ((Number) x.getOrDefault("lift", 0.0)).doubleValue());
            if (byLift != 0) return byLift;
            int byConfidence = Double.compare(((Number) y.getOrDefault("confidence", 0.0)).doubleValue(), ((Number) x.getOrDefault("confidence", 0.0)).doubleValue());
            if (byConfidence != 0) return byConfidence;
            return Integer.compare(((Number) y.getOrDefault("weight", 0)).intValue(), ((Number) x.getOrDefault("weight", 0)).intValue());
        });

        if (rules.size() > limit) {
            return new ArrayList<>(rules.subList(0, limit));
        }
        return rules;
    }

    // 获取菜品搭配模式 (无向关联)
    public List<Map<String, Object>> getDishPairings(
            LocalDateTime startDate,
            LocalDateTime endDate,
            Double minSupport,
            Integer topN,
            String level,
            Long canteenId,
            Long windowId
    ) {
        LocalDateTime start = startDate == null ? LocalDateTime.now().minusDays(7) : startDate;
        LocalDateTime end = endDate == null ? LocalDateTime.now() : endDate;
        if (end.isBefore(start)) {
            LocalDateTime tmp = start;
            start = end;
            end = tmp;
        }

        double supportThreshold = clampDouble(minSupport, 0.01, 0.0, 1.0);
        int limit = safeIntRange(topN, 20, 1, 100);
        String resolvedLevel = (level == null || level.isBlank()) ? "DISH" : level.trim().toUpperCase();
        if (!resolvedLevel.equals("DISH") && !resolvedLevel.equals("CATEGORY")) {
            resolvedLevel = "DISH";
        }

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT oi.order_id, d.name AS dish_name, d.dish_category AS dish_category ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                .append("AND o.total_amount > 0 ")
                .append("AND (oi.is_gift IS NULL OR oi.is_gift = false) ");
        params.add(start);
        params.add(end);
        
        // 食堂和窗口过滤逻辑已移除，进行全量分析
        
        sql.append("ORDER BY oi.order_id");

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        if (rows == null || rows.isEmpty()) return new ArrayList<>();

        Map<Long, LinkedHashSet<String>> orderToTokens = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            Object orderIdObj = row.get("order_id");
            if (orderIdObj == null) continue;
            Long orderId = ((Number) orderIdObj).longValue();
            String token = toAssociationToken(resolvedLevel, row);
            if (token == null || token.isBlank()) continue;
            orderToTokens.computeIfAbsent(orderId, k -> new LinkedHashSet<>()).add(token);
        }

        int orderCount = orderToTokens.size();
        if (orderCount <= 0) return new ArrayList<>();

        Map<String, Integer> pairCount = new HashMap<>();

        for (LinkedHashSet<String> set : orderToTokens.values()) {
            if (set == null || set.isEmpty()) continue;
            List<String> tokens = new ArrayList<>(set);
            tokens.sort(String::compareTo);
            for (int i = 0; i < tokens.size(); i++) {
                for (int j = i + 1; j < tokens.size(); j++) {
                    String a = tokens.get(i);
                    String b = tokens.get(j);
                    String key = a + "|||" + b;
                    pairCount.put(key, pairCount.getOrDefault(key, 0) + 1);
                }
            }
        }

        List<Map<String, Object>> pairings = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : pairCount.entrySet()) {
            String key = entry.getKey();
            int count = entry.getValue() == null ? 0 : entry.getValue();
            if (count <= 0) continue;
            
            double support = (double) count / (double) orderCount;
            if (support < supportThreshold) continue;

            String[] parts = key.split("\\|\\|\\|", 2);
            if (parts.length != 2) continue;
            String itemA = parts[0];
            String itemB = parts[1];

            Map<String, Object> m = new LinkedHashMap<>();
            m.put("itemA", itemA);
            m.put("itemB", itemB);
            m.put("pairName", itemA + " + " + itemB);
            m.put("count", count);
            m.put("totalOrders", orderCount);
            m.put("support", roundDouble(support, 4));
            m.put("percentage", roundDouble(support * 100, 2) + "%");
            m.put("level", resolvedLevel);
            pairings.add(m);
        }

        pairings.sort((a, b) -> Integer.compare(((Number) b.getOrDefault("count", 0)).intValue(), ((Number) a.getOrDefault("count", 0)).intValue()));

        if (pairings.size() > limit) {
            return new ArrayList<>(pairings.subList(0, limit));
        }
        return pairings;
    }

    private String toAssociationToken(String level, Map<String, Object> row) {
        if ("CATEGORY".equalsIgnoreCase(level)) {
            return mapCategoryName(row.get("dish_category"));
        }
        Object dishName = row.get("dish_name");
        return dishName == null ? null : String.valueOf(dishName).trim();
    }

    private void addDirectedAssociationRule(
            List<Map<String, Object>> out,
            String source,
            String target,
            int count,
            int orderCount,
            int sourceCount,
            int targetCount,
            double support,
            double confidenceThreshold,
            double liftThreshold,
            String level
    ) {
        double confidence = (double) count / (double) sourceCount;
        if (confidence < confidenceThreshold) return;
        double targetSupport = (double) targetCount / (double) orderCount;
        if (targetSupport <= 0) return;
        double lift = confidence / targetSupport;
        if (lift < liftThreshold) return;

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("source", source);
        m.put("target", target);
        m.put("pair", source + " + " + target);
        m.put("patternType", "DISH_PAIRING");
        m.put("weight", count);
        m.put("count", count);
        m.put("orderCount", orderCount);
        m.put("lhsCount", sourceCount);
        m.put("rhsCount", targetCount);
        m.put("support", roundDouble(support, 6));
        m.put("confidence", roundDouble(confidence, 6));
        m.put("lift", roundDouble(lift, 6));
        m.put("level", level);
        Map<String, Object> pattern = new LinkedHashMap<>();
        pattern.put("baseDish", source);
        pattern.put("pairDish", target);
        pattern.put("type", "搭配购买");
        m.put("pattern", pattern);
        out.add(m);
    }

    private double roundDouble(double v, int scale) {
        if (scale < 0) return v;
        BigDecimal bd = BigDecimal.valueOf(v);
        return bd.setScale(scale, RoundingMode.HALF_UP).doubleValue();
    }

    private double clampDouble(Double v, double defaultValue, double min, double max) {
        double val = v == null ? defaultValue : v.doubleValue();
        if (Double.isNaN(val) || Double.isInfinite(val)) val = defaultValue;
        if (val < min) return min;
        if (val > max) return max;
        return val;
    }

    private int safeIntRange(Integer v, int defaultValue, int min, int max) {
        int val = v == null ? defaultValue : v;
        if (val < min) return min;
        if (val > max) return max;
        return val;
    }

    // 获取用户分群 —— 基于RFM模型的简化版
    public List<Map<String, Object>> getUserSegmentation() {
        // Keep as is
        String sql = "SELECT user_id, SUM(total_amount) as total_spent, COUNT(*) as order_count " +
                     "FROM orders WHERE status = 'COMPLETED' GROUP BY user_id";
                     
        List<Map<String, Object>> userStats = jdbcTemplate.queryForList(sql);
        
        int highValueCount = 0;
        int loyalCount = 0;
        int casualCount = 0;
        
        BigDecimal totalRevenue = BigDecimal.ZERO;
        for (Map<String, Object> stat : userStats) {
            BigDecimal spent = (BigDecimal) stat.get("total_spent");
            totalRevenue = totalRevenue.add(spent);
        }
        
        BigDecimal avgSpent = userStats.isEmpty() ? BigDecimal.ZERO : 
            totalRevenue.divide(BigDecimal.valueOf(userStats.size()), 2, RoundingMode.HALF_UP);
            
        for (Map<String, Object> stat : userStats) {
            BigDecimal spent = (BigDecimal) stat.get("total_spent");
            long count = ((Number) stat.get("order_count")).longValue();
            
            if (spent.compareTo(avgSpent.multiply(BigDecimal.valueOf(1.5))) > 0) {
                highValueCount++;
            } else if (count > 5) {
                loyalCount++;
            } else {
                casualCount++;
            }
        }
        
        List<Map<String, Object>> segments = new ArrayList<>();
        segments.add(createSegment("高价值学生", highValueCount));
        segments.add(createSegment("忠诚学生", loyalCount));
        segments.add(createSegment("普通学生", casualCount));
        
        return segments;
    }

    public Map<String, Object> getUserSegmentationAdvanced(Integer windowDays, Long canteenId, Long windowId) {
        int days = safeIntRange(windowDays, 30, 7, 365);
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(days);

        List<UserSegRow> rows = queryUserSegmentationRows(start, end, canteenId, windowId);
        if (rows.isEmpty()) {
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("windowDays", days);
            out.put("start", start.toString());
            out.put("end", end.toString());
            out.put("segments", List.of());
            out.put("profiles", List.of());
            return out;
        }

        List<Integer> recencyDays = new ArrayList<>();
        List<Long> freq = new ArrayList<>();
        List<Long> monetaryCents = new ArrayList<>();

        for (UserSegRow r : rows) {
            if (r.lastTime() != null) {
                recencyDays.add((int) ChronoUnit.DAYS.between(r.lastTime(), end));
            } else {
                recencyDays.add(days);
            }
            freq.add(r.orderCount());
            BigDecimal spend = r.totalSpent() == null ? BigDecimal.ZERO : r.totalSpent();
            monetaryCents.add(spend.multiply(BigDecimal.valueOf(100)).longValue());
        }

        int[] rCuts = quantileCutsInt(recencyDays);
        long[] fCuts = quantileCutsLong(freq);
        long[] mCuts = quantileCutsLong(monetaryCents);

        Map<Long, UserSegComputed> computed = new HashMap<>();
        for (UserSegRow r : rows) {
            int rVal = r.lastTime() == null ? days : (int) ChronoUnit.DAYS.between(r.lastTime(), end);
            int rScore = scoreLowerBetter(rVal, rCuts);
            int fScore = scoreHigherBetter(r.orderCount(), fCuts);
            long mVal = (r.totalSpent() == null ? BigDecimal.ZERO : r.totalSpent()).multiply(BigDecimal.valueOf(100)).longValue();
            int mScore = scoreHigherBetter(mVal, mCuts);
            String code = segmentCode(rScore, fScore, mScore);
            computed.put(r.userId(), new UserSegComputed(r.userId(), r.totalSpent(), r.orderCount(), r.lastTime(), rScore, fScore, mScore, rVal, code));
        }

        Map<String, SegmentAgg> segmentAgg = new LinkedHashMap<>();
        for (UserSegComputed c : computed.values()) {
            SegmentAgg agg = segmentAgg.computeIfAbsent(c.segmentCode(), k -> new SegmentAgg(segmentName(k)));
            agg.count++;
            agg.totalSpend = agg.totalSpend.add(c.totalSpent() == null ? BigDecimal.ZERO : c.totalSpent());
            agg.totalOrders += c.orderCount();
            agg.totalRecencyDays += c.recencyDays();
        }

        int totalUsers = computed.size();
        List<Map<String, Object>> segments = new ArrayList<>();
        for (Map.Entry<String, SegmentAgg> e : segmentAgg.entrySet()) {
            String code = e.getKey();
            SegmentAgg agg = e.getValue();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("code", code);
            m.put("name", agg.name);
            m.put("count", agg.count);
            m.put("ratio", totalUsers == 0 ? 0.0 : roundDouble((double) agg.count / (double) totalUsers, 6));
            Map<String, Object> metrics = new LinkedHashMap<>();
            metrics.put("avgSpend", agg.count == 0 ? BigDecimal.ZERO : agg.totalSpend.divide(BigDecimal.valueOf(agg.count), 2, RoundingMode.HALF_UP));
            metrics.put("avgOrders", agg.count == 0 ? 0.0 : roundDouble((double) agg.totalOrders / (double) agg.count, 6));
            metrics.put("avgRecencyDays", agg.count == 0 ? 0.0 : roundDouble((double) agg.totalRecencyDays / (double) agg.count, 6));
            m.put("metrics", metrics);
            segments.add(m);
        }

        segments.sort((a, b) -> Integer.compare(((Number) b.getOrDefault("count", 0)).intValue(), ((Number) a.getOrDefault("count", 0)).intValue()));

        List<Map<String, Object>> profiles = buildSegmentationProfiles(start, end, computed, canteenId, windowId);

        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("totalUsers", totalUsers);
        if (totalUsers > 0) {
            BigDecimal totalSpentAll = computed.values().stream()
                    .map(UserSegComputed::totalSpent)
                    .filter(Objects::nonNull)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            long totalOrdersAll = computed.values().stream().mapToLong(UserSegComputed::orderCount).sum();
            long totalRecencyAll = computed.values().stream().mapToLong(UserSegComputed::recencyDays).sum();
            
            summary.put("avgSpent", totalSpentAll.divide(BigDecimal.valueOf(totalUsers), 2, RoundingMode.HALF_UP));
            summary.put("avgOrders", roundDouble((double) totalOrdersAll / totalUsers, 1));
            summary.put("avgRecency", roundDouble((double) totalRecencyAll / totalUsers, 1));
        } else {
            summary.put("avgSpent", BigDecimal.ZERO);
            summary.put("avgOrders", 0.0);
            summary.put("avgRecency", 0.0);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("windowDays", days);
        out.put("start", start.toString());
        out.put("end", end.toString());
        out.put("segments", segments);
        out.put("profiles", profiles);
        out.put("summary", summary);
        return out;
    }

    public Map<String, Object> getUserSegmentationUsers(String segmentCode, Integer windowDays, Long canteenId, Long windowId, int page, int size) {
        String code = segmentCode == null ? "" : segmentCode.trim().toUpperCase();
        int days = safeIntRange(windowDays, 30, 7, 365);
        int safePage = Math.max(0, page);
        int safeSize = safeIntRange(size, 20, 1, 100);
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(days);

        List<UserSegRow> rows = queryUserSegmentationRows(start, end, canteenId, windowId);
        if (rows.isEmpty()) {
            return Map.of(
                    "page", safePage,
                    "size", safeSize,
                    "total", 0,
                    "content", List.of()
            );
        }

        List<Integer> recencyDays = new ArrayList<>();
        List<Long> freq = new ArrayList<>();
        List<Long> monetaryCents = new ArrayList<>();
        for (UserSegRow r : rows) {
            if (r.lastTime() != null) {
                recencyDays.add((int) ChronoUnit.DAYS.between(r.lastTime(), end));
            } else {
                recencyDays.add(days);
            }
            freq.add(r.orderCount());
            BigDecimal spend = r.totalSpent() == null ? BigDecimal.ZERO : r.totalSpent();
            monetaryCents.add(spend.multiply(BigDecimal.valueOf(100)).longValue());
        }
        int[] rCuts = quantileCutsInt(recencyDays);
        long[] fCuts = quantileCutsLong(freq);
        long[] mCuts = quantileCutsLong(monetaryCents);

        List<UserSegComputed> all = new ArrayList<>();
        for (UserSegRow r : rows) {
            int rVal = r.lastTime() == null ? days : (int) ChronoUnit.DAYS.between(r.lastTime(), end);
            int rScore = scoreLowerBetter(rVal, rCuts);
            int fScore = scoreHigherBetter(r.orderCount(), fCuts);
            long mVal = (r.totalSpent() == null ? BigDecimal.ZERO : r.totalSpent()).multiply(BigDecimal.valueOf(100)).longValue();
            int mScore = scoreHigherBetter(mVal, mCuts);
            String sc = segmentCode(rScore, fScore, mScore);
            all.add(new UserSegComputed(r.userId(), r.totalSpent(), r.orderCount(), r.lastTime(), rScore, fScore, mScore, rVal, sc));
        }

        List<UserSegComputed> filtered = all.stream().filter(x -> x.segmentCode().equalsIgnoreCase(code)).collect(Collectors.toList());
        filtered.sort((a, b) -> {
            BigDecimal sa = a.totalSpent() == null ? BigDecimal.ZERO : a.totalSpent();
            BigDecimal sb = b.totalSpent() == null ? BigDecimal.ZERO : b.totalSpent();
            int cmp = sb.compareTo(sa);
            if (cmp != 0) return cmp;
            return Long.compare(b.orderCount(), a.orderCount());
        });

        int total = filtered.size();
        int from = Math.min(total, safePage * safeSize);
        int to = Math.min(total, from + safeSize);
        List<UserSegComputed> pageItems = from >= to ? List.of() : filtered.subList(from, to);

        Map<Long, String> usernames = fetchUsernames(pageItems.stream().map(UserSegComputed::userId).filter(Objects::nonNull).collect(Collectors.toList()));

        List<Map<String, Object>> content = new ArrayList<>();
        for (UserSegComputed c : pageItems) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("username", usernames.getOrDefault(c.userId(), String.valueOf(c.userId())));
            m.put("orders", c.orderCount());
            m.put("spend", c.totalSpent() == null ? BigDecimal.ZERO : c.totalSpent());
            m.put("lastOrderAt", c.lastTime() == null ? null : c.lastTime().toString());
            m.put("recencyDays", c.recencyDays());
            m.put("segmentCode", c.segmentCode());
            content.add(m);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("page", safePage);
        out.put("size", safeSize);
        out.put("total", total);
        out.put("content", content);
        return out;
    }

    private List<UserSegRow> queryUserSegmentationRows(LocalDateTime start, LocalDateTime end, Long canteenId, Long windowId) {
        StringBuilder tSql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        tSql.append("SELECT oi.order_id AS order_id, MIN(oi.create_time) AS order_time ")
                .append("FROM order_items oi ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ");
        params.add(start);
        params.add(end);
        if (canteenId != null) {
            tSql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            tSql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        tSql.append("GROUP BY oi.order_id");

        String sql = "SELECT o.user_id AS user_id, SUM(o.total_amount) AS total_spent, COUNT(*) AS order_count, MAX(t.order_time) AS last_time " +
                "FROM orders o JOIN (" + tSql + ") t ON o.id = t.order_id " +
                "WHERE o.user_id IS NOT NULL " +
                "AND o.status IN " + VALID_ORDER_STATUSES + " " +
                "AND o.total_amount > 0 " +
                "GROUP BY o.user_id";

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, params.toArray());
        if (rows == null || rows.isEmpty()) return List.of();
        List<UserSegRow> out = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            Long userId = r.get("user_id") == null ? null : ((Number) r.get("user_id")).longValue();
            if (userId == null) continue;
            BigDecimal spent = r.get("total_spent") instanceof BigDecimal ? (BigDecimal) r.get("total_spent") : safeBigDecimal(r.get("total_spent"));
            long cnt = r.get("order_count") == null ? 0 : ((Number) r.get("order_count")).longValue();
            LocalDateTime last = null;
            Object lastObj = r.get("last_time");
            if (lastObj instanceof java.sql.Timestamp) {
                last = ((java.sql.Timestamp) lastObj).toLocalDateTime();
            } else if (lastObj instanceof LocalDateTime) {
                last = (LocalDateTime) lastObj;
            }
            out.add(new UserSegRow(userId, spent, cnt, last));
        }
        return out;
    }

    private Map<Long, String> fetchUsernames(List<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) return new HashMap<>();
        List<Long> ids = userIds.stream().filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (ids.isEmpty()) return new HashMap<>();
        String placeholders = ids.stream().map(x -> "?").collect(Collectors.joining(","));
        String sql = "SELECT id, username FROM users WHERE id IN (" + placeholders + ")";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, ids.toArray());
        Map<Long, String> out = new HashMap<>();
        for (Map<String, Object> r : rows) {
            Long id = r.get("id") == null ? null : ((Number) r.get("id")).longValue();
            if (id == null) continue;
            out.put(id, r.get("username") == null ? String.valueOf(id) : String.valueOf(r.get("username")));
        }
        for (Long id : ids) {
            out.putIfAbsent(id, String.valueOf(id));
        }
        return out;
    }

    private List<Map<String, Object>> buildSegmentationProfiles(LocalDateTime start, LocalDateTime end, Map<Long, UserSegComputed> computed, Long canteenId, Long windowId) {
        if (computed == null || computed.isEmpty()) return List.of();

        Map<Long, String> userToSeg = new HashMap<>();
        for (UserSegComputed c : computed.values()) {
            userToSeg.put(c.userId(), c.segmentCode());
        }

        StringBuilder tSql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        tSql.append("SELECT oi.order_id AS order_id, MIN(oi.create_time) AS order_time ")
                .append("FROM order_items oi ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ");
        params.add(start);
        params.add(end);
        if (canteenId != null) {
            tSql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            tSql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        tSql.append("GROUP BY oi.order_id");

        String sql = "SELECT o.user_id AS user_id, d.dish_category AS dish_category, HOUR(t.order_time) AS h " +
                "FROM orders o " +
                "JOIN (" + tSql + ") t ON o.id = t.order_id " +
                "JOIN order_items oi ON oi.order_id = o.id " +
                "JOIN dishes d ON d.id = oi.dish_id " +
                "WHERE o.user_id IS NOT NULL " +
                "AND o.status IN " + VALID_ORDER_STATUSES + " " +
                "AND o.total_amount > 0";

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, params.toArray());
        if (rows == null || rows.isEmpty()) return List.of();

        Map<String, Map<String, Integer>> segToCat = new HashMap<>();
        Map<String, Map<String, Integer>> segToTime = new HashMap<>();

        for (Map<String, Object> r : rows) {
            Object uidObj = r.get("user_id");
            if (uidObj == null) continue;
            Long uid = ((Number) uidObj).longValue();
            String seg = userToSeg.get(uid);
            if (seg == null) continue;

            String cat = mapCategoryName(r.get("dish_category"));
            segToCat.computeIfAbsent(seg, k -> new HashMap<>()).put(cat, segToCat.get(seg).getOrDefault(cat, 0) + 1);

            int hour = r.get("h") == null ? -1 : ((Number) r.get("h")).intValue();
            String tp = hourToTimePeriod(hour);
            segToTime.computeIfAbsent(seg, k -> new HashMap<>()).put(tp, segToTime.get(seg).getOrDefault(tp, 0) + 1);
        }

        List<Map<String, Object>> profiles = new ArrayList<>();
        for (String seg : segToCat.keySet()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("code", seg);
            m.put("name", segmentName(seg));
            m.put("topCategories", topNCounts(segToCat.getOrDefault(seg, Map.of()), 5));
            m.put("topTimes", topNCounts(segToTime.getOrDefault(seg, Map.of()), 5));
            profiles.add(m);
        }

        profiles.sort((a, b) -> String.valueOf(a.get("code")).compareTo(String.valueOf(b.get("code"))));
        return profiles;
    }

    private List<Map<String, Object>> topNCounts(Map<String, Integer> counts, int n) {
        if (counts == null || counts.isEmpty()) return List.of();
        List<Map.Entry<String, Integer>> list = new ArrayList<>(counts.entrySet());
        list.sort((a, b) -> Integer.compare(b.getValue(), a.getValue()));
        if (list.size() > n) list = list.subList(0, n);
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map.Entry<String, Integer> e : list) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("name", e.getKey());
            m.put("value", e.getValue());
            out.add(m);
        }
        return out;
    }

    private String hourToTimePeriod(int hour) {
        if (hour >= 6 && hour < 10) return "早餐";
        if (hour >= 10 && hour < 14) return "午餐";
        if (hour >= 14 && hour < 17) return "下午茶";
        if (hour >= 17 && hour < 21) return "晚餐";
        return "夜宵";
    }

    private String segmentCode(int r, int f, int m) {
        if (r >= 4 && f >= 4 && m >= 4) return "VIP";
        if (r >= 4 && (f >= 3 || m >= 3)) return "ACTIVE";
        if (r == 5 && f <= 2 && m <= 2) return "NEW";
        if (r <= 2 && (f >= 3 || m >= 3)) return "RISK";
        if (r <= 2 && f <= 2 && m <= 2) return "DORMANT";
        return "NORMAL";
    }

    private String segmentName(String code) {
        if (code == null) return "普通学生";
        return switch (code.toUpperCase()) {
            case "VIP" -> "高价值活跃学生";
            case "ACTIVE" -> "活跃学生";
            case "NEW" -> "新入学生";
            case "RISK" -> "流失风险学生";
            case "DORMANT" -> "沉默学生";
            default -> "普通学生";
        };
    }

    private int[] quantileCutsInt(List<Integer> values) {
        if (values == null || values.isEmpty()) return new int[]{0, 0, 0, 0};
        List<Integer> sorted = values.stream().filter(Objects::nonNull).sorted().collect(Collectors.toList());
        int n = sorted.size();
        return new int[]{
                sorted.get((int) Math.floor(0.2 * (n - 1))),
                sorted.get((int) Math.floor(0.4 * (n - 1))),
                sorted.get((int) Math.floor(0.6 * (n - 1))),
                sorted.get((int) Math.floor(0.8 * (n - 1)))
        };
    }

    private long[] quantileCutsLong(List<Long> values) {
        if (values == null || values.isEmpty()) return new long[]{0, 0, 0, 0};
        List<Long> sorted = values.stream().filter(Objects::nonNull).sorted().collect(Collectors.toList());
        int n = sorted.size();
        return new long[]{
                sorted.get((int) Math.floor(0.2 * (n - 1))),
                sorted.get((int) Math.floor(0.4 * (n - 1))),
                sorted.get((int) Math.floor(0.6 * (n - 1))),
                sorted.get((int) Math.floor(0.8 * (n - 1)))
        };
    }

    private int scoreHigherBetter(long value, long[] cuts) {
        if (cuts == null || cuts.length < 4) return 3;
        if (value <= cuts[0]) return 1;
        if (value <= cuts[1]) return 2;
        if (value <= cuts[2]) return 3;
        if (value <= cuts[3]) return 4;
        return 5;
    }

    private int scoreLowerBetter(int value, int[] cuts) {
        if (cuts == null || cuts.length < 4) return 3;
        if (value <= cuts[0]) return 5;
        if (value <= cuts[1]) return 4;
        if (value <= cuts[2]) return 3;
        if (value <= cuts[3]) return 2;
        return 1;
    }

    private BigDecimal safeBigDecimal(Object v) {
        if (v == null) return BigDecimal.ZERO;
        if (v instanceof BigDecimal) return (BigDecimal) v;
        if (v instanceof Number) return BigDecimal.valueOf(((Number) v).doubleValue());
        try {
            return new BigDecimal(String.valueOf(v));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private record UserSegRow(Long userId, BigDecimal totalSpent, long orderCount, LocalDateTime lastTime) {
    }

    private record UserSegComputed(Long userId, BigDecimal totalSpent, long orderCount, LocalDateTime lastTime, int rScore, int fScore, int mScore, int recencyDays, String segmentCode) {
    }

    private static class SegmentAgg {
        final String name;
        int count = 0;
        BigDecimal totalSpend = BigDecimal.ZERO;
        long totalOrders = 0;
        long totalRecencyDays = 0;

        private SegmentAgg(String name) {
            this.name = name;
        }
    }
    
    private Map<String, Object> createSegment(String name, int value) {
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("value", value);
        return map;
    }

    // 获取异常检测结果 (3-Sigma)
    public List<Map<String, Object>> getAnomalyDetection(LocalDateTime startDate, LocalDateTime endDate) {
        return getAnomalyDetection(startDate, endDate, null, null, null, null, null, null, null);
    }

    public List<Map<String, Object>> getAnomalyDetection(
            LocalDateTime startDate,
            LocalDateTime endDate,
            String metric,
            String dimensionType,
            Integer sigma,
            Long canteenId,
            Long windowId,
            Long dishId,
            String category
    ) {
        LocalDateTime start = startDate == null ? LocalDateTime.now().minusDays(7) : startDate;
        LocalDateTime end = endDate == null ? LocalDateTime.now() : endDate;
        if (end.isBefore(start)) {
            LocalDateTime tmp = start;
            start = end;
            end = tmp;
        }

        String resolvedMetric = (metric == null || metric.isBlank()) ? "sales" : metric.trim().toLowerCase();
        int resolvedSigma = safeIntRange(sigma, 2, 1, 10);

        ResolvedDimension dim = resolveDimension(dimensionType, canteenId, windowId, dishId, category);
        if ("DISH".equals(dim.type) && dim.dishId == null) {
            if (!"sales".equals(resolvedMetric)) return new ArrayList<>();
            List<Map<String, Object>> anomalies = detectDishSalesAnomalies(start, end, resolvedSigma, dim);
            if (!anomalies.isEmpty()) {
                sendSalesAnomalyNotifications(anomalies);
            }
            return anomalies;
        }
        LocalDateTime baseStart = start.minusDays(30);
        List<AnomalyPoint> points = queryDailyMetricSeries(baseStart, end, resolvedMetric, dim);
        if (points.size() < 2) return new ArrayList<>();

        List<BigDecimal> values = points.stream().map(AnomalyPoint::value).filter(Objects::nonNull).collect(Collectors.toList());
        if (values.size() < 2) return new ArrayList<>();

        List<Map<String, Object>> anomalies = detectAnomaliesZScore(points, values, start.toLocalDate(), resolvedMetric, dim, resolvedSigma);

        // 检测到销量异常时，发送通知给管理员
        if (!anomalies.isEmpty()) {
            sendSalesAnomalyNotifications(anomalies);
        }

        return anomalies;
    }

    private List<Map<String, Object>> detectDishSalesAnomalies(
            LocalDateTime start,
            LocalDateTime end,
            int sigma,
            ResolvedDimension dim
    ) {
        LocalDateTime baseStart = start.minusDays(30);
        Map<Long, String> dishNames = new HashMap<>();
        Map<Long, Map<LocalDate, BigDecimal>> dishDaily = queryDishDailySalesSeries(baseStart, end, dim, dishNames);
        if (dishDaily.isEmpty()) return new ArrayList<>();

        List<LocalDate> days = buildDateRange(baseStart.toLocalDate(), end.toLocalDate());
        LocalDate detectStart = start.toLocalDate();
        List<Map<String, Object>> out = new ArrayList<>();
        int minTotalSales = 10;
        double minAvgSales = 1.0;

        for (Map.Entry<Long, Map<LocalDate, BigDecimal>> entry : dishDaily.entrySet()) {
            Long dishId = entry.getKey();
            String dishName = dishNames.getOrDefault(dishId, String.valueOf(dishId));
            Map<LocalDate, BigDecimal> dayMap = entry.getValue();
            List<AnomalyPoint> points = new ArrayList<>();
            BigDecimal total = BigDecimal.ZERO;
            for (LocalDate day : days) {
                BigDecimal v = dayMap.getOrDefault(day, BigDecimal.ZERO);
                points.add(new AnomalyPoint(day, v));
                total = total.add(v);
            }
            double avg = total.doubleValue() / Math.max(1, points.size());
            if (total.compareTo(BigDecimal.valueOf(minTotalSales)) < 0 && avg < minAvgSales) {
                continue;
            }
            List<Map<String, Object>> anomalies = detectDishZScore(points, detectStart, sigma, dishId, dishName);
            if (!anomalies.isEmpty()) {
                out.addAll(anomalies);
            }
        }
        return out;
    }

    private List<Map<String, Object>> detectDishZScore(
            List<AnomalyPoint> points,
            LocalDate detectStart,
            int sigma,
            Long dishId,
            String dishName
    ) {
        List<BigDecimal> values = points.stream().map(AnomalyPoint::value).collect(Collectors.toList());
        if (values.size() < 2) return new ArrayList<>();

        BigDecimal sum = values.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal avg = sum.divide(BigDecimal.valueOf(values.size()), 8, RoundingMode.HALF_UP);
        double variance = values.stream().mapToDouble(v -> {
            double d = v.subtract(avg).doubleValue();
            return d * d;
        }).sum() / (double) values.size();
        double stdDev = Math.sqrt(variance);
        if (stdDev <= 0) return new ArrayList<>();

        List<Map<String, Object>> anomalies = new ArrayList<>();
        for (AnomalyPoint p : points) {
            if (p.date().isBefore(detectStart)) continue;
            BigDecimal v = p.value();
            double z = (v.subtract(avg)).doubleValue() / stdDev;
            if (Math.abs(z) <= sigma) continue;

            String anomalyKind = z > 0 ? "SPIKE" : "DROP";
            String alertMessage = buildDishAlertMessage(p.date(), v, avg, anomalyKind, dishName);

            Map<String, Object> m = new LinkedHashMap<>();
            m.put("type", "销量异常");
            m.put("metric", "sales");
            m.put("dimensionType", "DISH");
            m.put("dimensionValue", dishName);
            m.put("date", p.date().toString());
            m.put("value", v);
            m.put("baseline", avg.setScale(2, RoundingMode.HALF_UP));
            m.put("score", roundDouble(z, 6));
            m.put("deviationPct", deviationPct(v, avg));
            m.put("method", "Z_SCORE");
            m.put("alertLevel", anomalyAlertLevel(Math.abs(z), sigma));
            m.put("alertMessage", alertMessage);
            m.put("anomalyKind", anomalyKind);
            m.put("dishId", dishId);
            m.put("dishName", dishName);
            anomalies.add(m);
        }
        return anomalies;
    }

    private String buildDishAlertMessage(LocalDate date, BigDecimal value, BigDecimal baseline, String anomalyKind, String dishName) {
        Double pct = deviationPct(value, baseline);
        String pctText = pct == null ? "-" : roundDouble(pct, 2) + "%";
        String baseText = baseline == null ? "-" : baseline.setScale(2, RoundingMode.HALF_UP).toString();
        if ("SPIKE".equals(anomalyKind)) {
            return dishName + " 在 " + date + " 销量异常增多（实际" + value + "，基线" + baseText + "，偏离" + pctText + "）。可能原因：促销活动效果显著、获得推荐位曝光、或价格调整吸引了流量。";
        }
        return dishName + " 在 " + date + " 销量异常低迷（实际" + value + "，基线" + baseText + "，偏离" + pctText + "）。可能原因：食材缺货、菜品已下架、窗口暂停营业、或近期收到差评影响。";
    }

    // --- Daily Snapshot Generation ---
    @Transactional
    public void generateDailySnapshot(LocalDate date) {
        if (dailyDishStatisticRepository.existsByDate(date)) {
            return;
        }

        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);

        // Query sales and stock data
        // Note: This logic assumes it's running before inventory reset for the target date's 'end stock'
        // If we are snapshotting yesterday, and we haven't reset yet, 'stock' is yesterday's end stock.
        
        String sql = "SELECT d.id, d.name, d.daily_limit, d.stock, " +
                "COALESCE(sales_table.sold_qty, 0) as daily_sales " +
                "FROM dishes d " +
                "LEFT JOIN ( " +
                "  SELECT oi.dish_id, SUM(oi.quantity) as sold_qty " +
                "  FROM order_items oi " +
                "  JOIN orders o ON oi.order_id = o.id " +
                "  WHERE o.status IN " + VALID_ORDER_STATUSES + " " +
                "  AND oi.create_time >= ? AND oi.create_time <= ? " +
                "  GROUP BY oi.dish_id " +
                ") sales_table ON d.id = sales_table.dish_id " +
                "WHERE d.status IN ('AVAILABLE', 'SOLD_OUT')";

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, startOfDay, endOfDay);
        List<DailyDishStatistic> statistics = new ArrayList<>();

        for (Map<String, Object> row : rows) {
            Long dishId = ((Number) row.get("id")).longValue();
            String dishName = (String) row.get("name");
            int dailyLimit = row.get("daily_limit") == null ? 0 : ((Number) row.get("daily_limit")).intValue();
            int currentStock = row.get("stock") == null ? 0 : ((Number) row.get("stock")).intValue();
            int sales = ((Number) row.get("daily_sales")).intValue();

            // Calculate total supply
            int totalSupply = dailyLimit > 0 ? dailyLimit : (sales + currentStock);
            
            String alertLevel = "NORMAL";
            String alertMessage = null;

            // Alert logic (same as getInventoryWarning)
            if (currentStock == 0) {
                alertLevel = "CRITICAL";
                alertMessage = "库存已耗尽（剩余 0 份），需要立即补货";
            } else if (currentStock > 0) {
                double ratio = (double) sales / currentStock;
                if (ratio >= 0.8) {
                    alertLevel = "CRITICAL";
                    alertMessage = "库存极低（剩余 " + currentStock + " 份，销量已达剩余库存的80%），请立即补货";
                } else if (ratio >= 0.5) {
                    alertLevel = "WARNING";
                    alertMessage = "库存紧张（剩余 " + currentStock + " 份，销量已达剩余库存的50%），请注意补货";
                }
            }

            DailyDishStatistic stat = new DailyDishStatistic();
            stat.setDishId(dishId);
            stat.setDishName(dishName);
            stat.setDate(date);
            stat.setDailyLimit(dailyLimit);
            stat.setTotalSupply(totalSupply);
            stat.setSales(sales);
            stat.setEndStock(currentStock);
            stat.setAlertLevel(alertLevel);
            stat.setAlertMessage(alertMessage);
            
            statistics.add(stat);
        }

        dailyDishStatisticRepository.saveAll(statistics);
    }

    // --- Inventory Warning (Added) ---
    public List<Map<String, Object>> getInventoryWarning(LocalDate date, String dishNameFilter) {
        if (date == null) {
            date = LocalDate.now();
        }
        
        // 1. Try to fetch from snapshots if not today
        if (!date.equals(LocalDate.now())) {
            List<DailyDishStatistic> snapshots = dailyDishStatisticRepository.findByDate(date);
            if (!snapshots.isEmpty()) {
                return snapshots.stream()
                        .filter(s -> dishNameFilter == null || dishNameFilter.isBlank() || s.getDishName().contains(dishNameFilter.trim()))
                        .filter(s -> !"NORMAL".equals(s.getAlertLevel())) // Only return warnings
                        .map(s -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("dishId", s.getDishId());
                            map.put("dishName", s.getDishName());
                            map.put("date", s.getDate().toString());
                            map.put("sales", s.getSales());
                            map.put("stock", s.getEndStock());
                            map.put("totalSupply", s.getTotalSupply());
                            map.put("alertLevel", s.getAlertLevel());
                            map.put("alertMessage", s.getAlertMessage());
                            if (s.getTotalSupply() != null && s.getTotalSupply() > 0) {
                                map.put("ratio", (double) s.getSales() / s.getTotalSupply());
                            } else {
                                map.put("ratio", 0.0);
                            }
                            return map;
                        })
                        .collect(Collectors.toList());
            }
        }

        // 2. Fallback to real-time calculation (for today or if snapshot missing)
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);

        // Query Sales for the day
        // Group by dish_id, sum quantity
        // Also join with dishes table to get name, daily_limit, stock
        String sql = "SELECT d.id, d.name, d.daily_limit, d.stock, COALESCE(SUM(oi.quantity), 0) as daily_sales " +
                     "FROM dishes d " +
                     "LEFT JOIN order_items oi ON d.id = oi.dish_id AND oi.create_time >= ? AND oi.create_time <= ? " +
                     "LEFT JOIN orders o ON oi.order_id = o.id " +
                     "WHERE d.status = 'AVAILABLE' ";
        
        List<Object> params = new ArrayList<>();
        params.add(startOfDay);
        params.add(endOfDay);

        if (dishNameFilter != null && !dishNameFilter.trim().isEmpty()) {
            sql += "AND d.name LIKE ? ";
            params.add("%" + dishNameFilter.trim() + "%");
        }

        // Only include valid orders for sales count
        // Note: We need to handle the case where there are no orders for a dish (LEFT JOIN ensures dish is present)
        // But the join condition on orders needs to be careful.
        // Better approach: Subquery for sales or just filter valid orders in the join.
        // If we join orders, we must ensure we don't filter out dishes with zero sales if we want to show them (though warning is for high sales).
        // Actually, for warning, if sales is 0, ratio is 0, so no warning.
        // However, we might want to check all available dishes.
        
        // Correct SQL structure:
        // Main table: dishes
        // Left join to sales aggregation
        
        sql = "SELECT d.id, d.name, d.daily_limit, d.stock, " +
              "COALESCE(sales_table.sold_qty, 0) as daily_sales " +
              "FROM dishes d " +
              "LEFT JOIN ( " +
              "  SELECT oi.dish_id, SUM(oi.quantity) as sold_qty " +
              "  FROM order_items oi " +
              "  JOIN orders o ON oi.order_id = o.id " +
              "  WHERE o.status IN " + VALID_ORDER_STATUSES + " " +
              "  AND oi.create_time >= ? AND oi.create_time <= ? " +
              "  GROUP BY oi.dish_id " +
              ") sales_table ON d.id = sales_table.dish_id " +
              "WHERE d.status IN ('AVAILABLE', 'SOLD_OUT') ";
        
        params.clear();
        params.add(startOfDay);
        params.add(endOfDay);
        
        if (dishNameFilter != null && !dishNameFilter.trim().isEmpty()) {
            sql += "AND d.name LIKE ? ";
            params.add("%" + dishNameFilter.trim() + "%");
        }
        
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, params.toArray());
        List<Map<String, Object>> result = new ArrayList<>();
        
        boolean isToday = date.equals(LocalDate.now());

        for (Map<String, Object> row : rows) {
            Long dishId = ((Number) row.get("id")).longValue();
            String dishName = (String) row.get("name");
            int dailyLimit = row.get("daily_limit") == null ? 0 : ((Number) row.get("daily_limit")).intValue();
            int currentStock = row.get("stock") == null ? 0 : ((Number) row.get("stock")).intValue();
            int sales = ((Number) row.get("daily_sales")).intValue();
            
            int totalSupply;
            if (dailyLimit > 0) {
                totalSupply = dailyLimit;
            } else if (isToday) {
                // If no limit and is today, approximate total supply as sales + current stock
                totalSupply = sales + currentStock;
            } else {
                // Historical date with no limit: cannot calculate ratio accurately
                totalSupply = 0;
            }
            
            // 特殊处理：库存为0的情况（无论销量如何都应报警）
            if (isToday && currentStock == 0) {
                Map<String, Object> item = new HashMap<>();
                item.put("dishId", dishId);
                item.put("dishName", dishName);
                item.put("date", date.toString());
                item.put("sales", sales);
                item.put("stock", 0);
                item.put("totalSupply", totalSupply > 0 ? totalSupply : sales);
                item.put("ratio", totalSupply > 0 ? (double) sales / totalSupply : 1.0);
                item.put("alertLevel", "CRITICAL");
                item.put("alertMessage", "库存已耗尽（剩余 0 份），需要立即补货");
                result.add(item);
                continue; // 关键：不需要继续执行后续的 ratio 判断了
            }

            // 优先使用销量占比预警 (仅适用于今日)
            if (isToday) {
                if (currentStock > 0) {
                    double ratio = (double) sales / currentStock;
                    if (ratio >= 0.8) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("dishId", dishId);
                        item.put("dishName", dishName);
                        item.put("date", date.toString());
                        item.put("sales", sales);
                        item.put("stock", currentStock);
                        item.put("totalSupply", totalSupply);
                        item.put("ratio", ratio);
                        item.put("alertLevel", "CRITICAL");
                        item.put("alertMessage", "库存极低（剩余 " + currentStock + " 份，销量已达剩余库存的80%），请立即补货");
                        item.put("anomalyKind", "STOCK_LOW_80");
                        result.add(item);
                    } else if (ratio >= 0.5) {
                        Map<String, Object> item = new HashMap<>();
                        item.put("dishId", dishId);
                        item.put("dishName", dishName);
                        item.put("date", date.toString());
                        item.put("sales", sales);
                        item.put("stock", currentStock);
                        item.put("totalSupply", totalSupply);
                        item.put("ratio", ratio);
                        item.put("alertLevel", "WARNING");
                        item.put("alertMessage", "库存紧张（剩余 " + currentStock + " 份，销量已达剩余库存的50%），请注意补货");
                        item.put("anomalyKind", "STOCK_LOW_50");
                        result.add(item);
                    }
                }
            } 
            // 对于历史日期，使用销量占比作为参考
            else if (totalSupply > 0) {
                 double ratio = (double) sales / totalSupply;
                 if (ratio >= 0.9) {
                     Map<String, Object> item = new HashMap<>();
                     item.put("dishId", dishId);
                     item.put("dishName", dishName);
                     item.put("date", date.toString());
                     item.put("sales", sales);
                     item.put("stock", null);
                     item.put("totalSupply", totalSupply);
                     item.put("ratio", ratio);
                     item.put("alertLevel", "CRITICAL");
                     
                     String pct = String.format("%.1f%%", ratio * 100);
                     item.put("alertMessage", "历史数据显示当日销量占比达 " + pct + "，可能曾出现缺货");
                     
                     result.add(item);
                 }
            }
        }

        // 检测到库存预警时，发送通知给管理员
        if (!result.isEmpty() && date.equals(LocalDate.now())) {
            sendInventoryWarningNotifications(result);
        }

        return result;
    }

    /**
     * 发送库存预警通知给管理员
     */
    private List<com.school.canteen.entity.User> getWarningReceivers() {
        Map<Long, com.school.canteen.entity.User> receivers = new LinkedHashMap<>();

        List<com.school.canteen.entity.User> admins =
                userRepository.findByRole(com.school.canteen.entity.User.UserRole.ADMIN);
        if (admins != null) {
            for (com.school.canteen.entity.User user : admins) {
                if (user != null && user.getId() != null) {
                    receivers.put(user.getId(), user);
                }
            }
        }

        List<com.school.canteen.entity.User> windowManagers =
                userRepository.findByRole(com.school.canteen.entity.User.UserRole.WINDOW_MANAGER);
        if (windowManagers != null) {
            for (com.school.canteen.entity.User user : windowManagers) {
                if (user != null && user.getId() != null) {
                    receivers.put(user.getId(), user);
                }
            }
        }

        return new ArrayList<>(receivers.values());
    }

    private void sendInventoryWarningNotifications(List<Map<String, Object>> warnings) {
        if (warnings.isEmpty()) return;

        // 获取所有管理员用户
        List<com.school.canteen.entity.User> admins = getWarningReceivers();
        if (admins == null || admins.isEmpty()) return;

        for (Map<String, Object> warning : warnings) {
            String dishName = (String) warning.get("dishName");
            String alertLevel = (String) warning.get("alertLevel");
            String alertMessage = (String) warning.get("alertMessage");
            Long dishId = warning.get("dishId") != null ? ((Number) warning.get("dishId")).longValue() : null;
            String anomalyKind = (String) warning.get("anomalyKind");

            // 检查是否已经发送过相同的通知（避免重复发送）
            String title = "库存预警";
            if ("SPIKE".equals(anomalyKind)) {
                title = "销量激增预警";
            }
            
            for (com.school.canteen.entity.User admin : admins) {
                if (admin == null || admin.getId() == null) continue;

                // 避免同一天内重复发送同一个菜品的同一类预警
                boolean alreadySent = notificationService.hasNotification(
                    admin.getId(),
                    title,
                    dishId
                );
                
                // 如果是按比例预警，我们可以允许升级（比如从黄警升到红警）
                // 但是如果已经发过相同级别的，就不再发
                if (alreadySent && alertMessage != null && !alertMessage.contains("80%")) {
                    continue;
                }
                
                // 发送通知
                notificationService.sendNotification(
                    admin.getId(),
                    title,
                    "【" + dishName + "】" + alertMessage,
                    com.school.canteen.entity.Notification.NotificationType.WARNING,
                    com.school.canteen.entity.Notification.NotificationScene.INVENTORY_WARNING,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    dishId
                );
            }
        }
    }

    /**
     * 发送销量异常通知给管理员
     */
    private void sendSalesAnomalyNotifications(List<Map<String, Object>> anomalies) {
        if (anomalies.isEmpty()) return;

        // 获取所有管理员用户
        List<com.school.canteen.entity.User> admins = getWarningReceivers();
        if (admins == null || admins.isEmpty()) return;

        for (Map<String, Object> anomaly : anomalies) {
            String dishName = (String) anomaly.get("dishName");
            if (dishName == null) dishName = (String) anomaly.get("dimensionValue");
            String date = (String) anomaly.get("date");
            String alertMessage = (String) anomaly.get("alertMessage");
            String anomalyKind = (String) anomaly.get("anomalyKind");
            Long dishId = anomaly.get("dishId") != null ? ((Number) anomaly.get("dishId")).longValue() : null;

            // 根据异常类型确定标题
            String title = "SPIKE".equals(anomalyKind) ? "销量激增预警" : "销量低迷预警";

            for (com.school.canteen.entity.User admin : admins) {
                if (admin == null || admin.getId() == null) continue;

                // 销量异常使用销量专用的BizType，避免和普通评价预警混淆
                // 发送通知
                notificationService.sendNotification(
                    admin.getId(),
                    title,
                    alertMessage != null ? alertMessage : "菜品【" + dishName + "】在 " + date + " 出现销量异常",
                    com.school.canteen.entity.Notification.NotificationType.WARNING,
                    com.school.canteen.entity.Notification.NotificationScene.INVENTORY_WARNING,
                    com.school.canteen.entity.Notification.BizType.DISH,
                    dishId
                );
            }
        }
    }

    private List<LocalDate> buildDateRange(LocalDate start, LocalDate end) {
        List<LocalDate> days = new ArrayList<>();
        LocalDate cur = start;
        while (!cur.isAfter(end)) {
            days.add(cur);
            cur = cur.plusDays(1);
        }
        return days;
    }

    private Map<Long, Map<LocalDate, BigDecimal>> queryDishDailySalesSeries(
            LocalDateTime start,
            LocalDateTime end,
            ResolvedDimension dim,
            Map<Long, String> dishNames
    ) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT d.id AS dish_id, d.name AS dish_name, DATE(oi.create_time) AS d, SUM(oi.quantity) AS sales ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                .append("AND o.total_amount > 0 ");
        params.add(start);
        params.add(end);
        if (dim.canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(dim.canteenId);
        }
        if (dim.windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(dim.windowId);
        }
        if (dim.categoryKey != null && !dim.categoryKey.isBlank()) {
            sql.append("AND d.dish_category = ? ");
            params.add(dim.categoryKey);
        }
        sql.append("GROUP BY d.id, d.name, DATE(oi.create_time) ORDER BY d");

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        Map<Long, Map<LocalDate, BigDecimal>> result = new HashMap<>();
        if (rows == null || rows.isEmpty()) return result;
        for (Map<String, Object> r : rows) {
            Long dishId = r.get("dish_id") == null ? null : ((Number) r.get("dish_id")).longValue();
            if (dishId == null) continue;
            Object dObj = r.get("d");
            LocalDate d = null;
            if (dObj instanceof java.sql.Date) {
                d = ((java.sql.Date) dObj).toLocalDate();
            }
            if (d == null) continue;
            BigDecimal v = BigDecimal.valueOf(((Number) r.getOrDefault("sales", 0)).longValue());
            String dishName = r.get("dish_name") == null ? String.valueOf(dishId) : String.valueOf(r.get("dish_name"));
            dishNames.putIfAbsent(dishId, dishName);
            result.computeIfAbsent(dishId, k -> new HashMap<>()).put(d, v);
        }
        return result;
    }

    private List<Map<String, Object>> detectAnomaliesZScore(
            List<AnomalyPoint> points,
            List<BigDecimal> values,
            LocalDate startDate,
            String metric,
            ResolvedDimension dim,
            int sigma
    ) {
        BigDecimal sum = values.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal avg = sum.divide(BigDecimal.valueOf(values.size()), 8, RoundingMode.HALF_UP);
        double variance = values.stream().mapToDouble(v -> {
            double d = v.subtract(avg).doubleValue();
            return d * d;
        }).sum() / (double) values.size();
        double stdDev = Math.sqrt(variance);
        if (stdDev <= 0) {
            // 如果方差为0，但我们确实有数据点，这可能意味着所有数据都一样
            // 在这种情况下，如果有数据点与平均值不符（理论上不可能，除非浮点误差），或者我们希望至少返回空列表而不是报错
            return new ArrayList<>();
        }

        List<Map<String, Object>> anomalies = new ArrayList<>();
        for (AnomalyPoint p : points) {
            if (p.date().isBefore(startDate)) continue;
            BigDecimal v = p.value();
            if (v == null) continue;
            double z = (v.subtract(avg)).doubleValue() / stdDev;
            if (Math.abs(z) <= sigma) continue;

            Map<String, Object> m = new LinkedHashMap<>();
            m.put("type", metricLabel(metric) + "异常");
            m.put("metric", metric);
            m.put("dimensionType", dim.type);
            m.put("dimensionValue", dim.value);
            m.put("date", p.date().toString());
            m.put("value", v);
            m.put("baseline", avg.setScale(2, RoundingMode.HALF_UP));
            m.put("score", roundDouble(z, 6));
            m.put("deviationPct", deviationPct(v, avg));
            String alertLevel = anomalyAlertLevel(Math.abs(z), sigma);
            m.put("method", "Z_SCORE");
            m.put("alertLevel", alertLevel);
            m.put("alertMessage", metricLabel(metric) + "异常波动预警");
            anomalies.add(m);
        }
        return anomalies;
    }

    private Double deviationPct(BigDecimal value, BigDecimal baseline) {
        if (baseline == null) return null;
        if (baseline.compareTo(BigDecimal.ZERO) == 0) return null;
        double pct = (value.subtract(baseline)).doubleValue() / baseline.doubleValue() * 100.0;
        return roundDouble(pct, 6);
    }

    private String metricLabel(String metric) {
        return switch (metric) {
            case "sales" -> "销量";
            case "orders" -> "订单数";
            case "users" -> "用户数";
            case "avgordervalue", "avg_order_value", "avgorder" -> "客单价";
            default -> "销售额";
        };
    }

    private String anomalyAlertLevel(double scoreAbs, int sigma) {
        double highThreshold = sigma * 1.5;
        if (scoreAbs >= highThreshold) return "HIGH";
        return "MEDIUM";
    }

    private record ResolvedDimension(String type, String value, Long canteenId, Long windowId, Long dishId, String categoryKey) {
    }

    private ResolvedDimension resolveDimension(String dimensionType, Long canteenId, Long windowId, Long dishId, String category) {
        String dt = dimensionType == null ? "" : dimensionType.trim().toUpperCase();
        if (dishId != null) {
            return new ResolvedDimension("DISH", String.valueOf(dishId), null, null, dishId, null);
        }
        if (windowId != null) {
            return new ResolvedDimension("WINDOW", String.valueOf(windowId), null, windowId, null, null);
        }
        if (canteenId != null) {
            return new ResolvedDimension("CANTEEN", String.valueOf(canteenId), canteenId, null, null, null);
        }
        if (category != null && !category.isBlank()) {
            String key = normalizeDishCategoryKey(category);
            return new ResolvedDimension("CATEGORY", key, null, null, null, key);
        }
        if (!dt.isEmpty()) {
            return new ResolvedDimension(dt, null, null, null, null, null);
        }
        return new ResolvedDimension("GLOBAL", null, null, null, null, null);
    }

    private String normalizeDishCategoryKey(String category) {
        if (category == null) return null;
        String c = category.trim();
        if (c.isEmpty()) return null;
        if (c.equals("主食")) return "MAIN_DISH";
        if (c.equals("荤菜")) return "MEAT_DISH";
        if (c.equals("素菜")) return "VEGETABLE";
        if (c.equals("汤类")) return "SOUP";
        if (c.equals("小吃")) return "SNACK";
        if (c.equals("饮品")) return "BEVERAGE";
        if (c.equals("配菜") || c.equals("菜品")) return "SIDE_DISH";
        return c.toUpperCase();
    }

    private record AnomalyPoint(LocalDate date, BigDecimal value) {
    }

    private List<AnomalyPoint> queryDailyMetricSeries(LocalDateTime start, LocalDateTime end, String metric, ResolvedDimension dim) {
        StringBuilder tSql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        tSql.append("SELECT oi.order_id AS order_id, MIN(oi.create_time) AS order_time ")
                .append("FROM order_items oi ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ");
        params.add(start);
        params.add(end);
        if (dim.canteenId != null) {
            tSql.append("AND d.canteen_id = ? ");
            params.add(dim.canteenId);
        }
        if (dim.windowId != null) {
            tSql.append("AND d.window_id = ? ");
            params.add(dim.windowId);
        }
        if (dim.dishId != null) {
            tSql.append("AND d.id = ? ");
            params.add(dim.dishId);
        }
        if (dim.categoryKey != null && !dim.categoryKey.isBlank()) {
            tSql.append("AND d.dish_category = ? ");
            params.add(dim.categoryKey);
        }
        tSql.append("GROUP BY oi.order_id");

        String sql;
        if ("sales".equals(metric)) {
            // 注意：这里需要确保只统计符合维度条件的order_items
            // 如果dim是GLOBAL，则tSql已经选出了时间范围内的订单，JOIN order_items会统计该订单所有菜品
            // 如果dim指定了Canteen/Window，tSql选出了包含该Canteen/Window菜品的订单
            // 但JOIN order_items oi ON o.id = oi.order_id 会把该订单中 *其他窗口* 的菜品也统计进来！这是错误的。
            // 应该再次JOIN dishes并应用维度过滤，或者复用tSql中的过滤逻辑
            // 修正逻辑：直接查询order_items并关联dishes，按日期聚合
            StringBuilder directSql = new StringBuilder();
            List<Object> directParams = new ArrayList<>();
            directSql.append("SELECT DATE(oi.create_time) AS d, SUM(oi.quantity) AS sales ")
                    .append("FROM order_items oi ")
                    .append("JOIN dishes d ON oi.dish_id = d.id ")
                    .append("JOIN orders o ON oi.order_id = o.id ") // 需要检查订单状态
                    .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ");
            directParams.add(start);
            directParams.add(end);
            
            directSql.append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ");
            
            if (dim.canteenId != null) {
                directSql.append("AND d.canteen_id = ? ");
                directParams.add(dim.canteenId);
            }
            if (dim.windowId != null) {
                directSql.append("AND d.window_id = ? ");
                directParams.add(dim.windowId);
            }
            if (dim.dishId != null) {
                directSql.append("AND d.id = ? ");
                directParams.add(dim.dishId);
            }
            if (dim.categoryKey != null && !dim.categoryKey.isBlank()) {
                directSql.append("AND d.dish_category = ? ");
                directParams.add(dim.categoryKey);
            }
            
            directSql.append("GROUP BY DATE(oi.create_time) ORDER BY d");
            
            sql = directSql.toString();
            params = directParams; // Replace params completely
            
        } else {
            sql = "SELECT DATE(t.order_time) AS d, " +
                    "SUM(o.total_amount) AS revenue, " +
                    "COUNT(*) AS orders, " +
                    "COUNT(DISTINCT o.user_id) AS users, " +
                    "AVG(o.total_amount) AS avg_order_value " +
                    "FROM orders o JOIN (" + tSql + ") t ON o.id = t.order_id " +
                    "WHERE o.status IN " + VALID_ORDER_STATUSES + " " +
                    "AND o.total_amount > 0 " +
                    "GROUP BY DATE(t.order_time) " +
                    "ORDER BY d";
        }

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, params.toArray());
        if (rows == null || rows.isEmpty()) return List.of();
        List<AnomalyPoint> out = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            Object dObj = r.get("d");
            LocalDate d = null;
            if (dObj instanceof java.sql.Date) {
                d = ((java.sql.Date) dObj).toLocalDate();
            }
            if (d == null) continue;
            BigDecimal v;
            if ("sales".equals(metric)) {
                v = BigDecimal.valueOf(((Number) r.getOrDefault("sales", 0)).longValue());
            } else if ("orders".equals(metric)) {
                v = BigDecimal.valueOf(((Number) r.getOrDefault("orders", 0)).longValue());
            } else if ("users".equals(metric)) {
                v = BigDecimal.valueOf(((Number) r.getOrDefault("users", 0)).longValue());
            } else if ("avgordervalue".equals(metric) || "avg_order_value".equals(metric) || "avgorder".equals(metric)) {
                v = safeBigDecimal(r.get("avg_order_value"));
            } else {
                v = safeBigDecimal(r.get("revenue"));
            }
            out.add(new AnomalyPoint(d, v));
        }
        return out;
    }

    // 获取对比分析
    public Map<String, Object> getComparisonAnalysis(LocalDateTime start1, LocalDateTime end1, LocalDateTime start2, LocalDateTime end2) {
        return getComparisonAnalysis(start1, end1, start2, end2, false, null, null, null, null, null);
    }

    public Map<String, Object> getComparisonAnalysis(LocalDateTime start1, LocalDateTime end1, LocalDateTime start2, LocalDateTime end2, Boolean includeBreakdowns, Integer topN) {
        return getComparisonAnalysis(start1, end1, start2, end2, includeBreakdowns, topN, null, null, null, null);
    }

    public Map<String, Object> getComparisonAnalysis(LocalDateTime start1, LocalDateTime end1, LocalDateTime start2, LocalDateTime end2, Boolean includeBreakdowns, Integer topN, Long canteenId1, Long windowId1, Long canteenId2, Long windowId2) {
        LocalDateTime s1 = start1 == null ? LocalDateTime.now().minusDays(7) : start1;
        LocalDateTime e1 = end1 == null ? LocalDateTime.now() : end1;
        if (e1.isBefore(s1)) {
            LocalDateTime tmp = s1;
            s1 = e1;
            e1 = tmp;
        }

        LocalDateTime s2 = start2 == null ? LocalDateTime.now().minusDays(14) : start2;
        LocalDateTime e2 = end2 == null ? LocalDateTime.now().minusDays(7) : end2;
        if (e2.isBefore(s2)) {
            LocalDateTime tmp = s2;
            s2 = e2;
            e2 = tmp;
        }

        Map<String, Object> metrics1 = (canteenId1 == null && windowId1 == null) ? getKeyMetrics(s1, e1) : getKeyMetricsFiltered(s1, e1, canteenId1, windowId1);
        Map<String, Object> metrics2 = (canteenId2 == null && windowId2 == null) ? getKeyMetrics(s2, e2) : getKeyMetricsFiltered(s2, e2, canteenId2, windowId2);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("metrics1", metrics1);
        result.put("metrics2", metrics2);
        result.put("periodA", Map.of("start", s1.toString(), "end", e1.toString()));
        result.put("periodB", Map.of("start", s2.toString(), "end", e2.toString()));
        result.put("metrics", buildComparisonKpis(metrics1, metrics2));

        boolean withBreakdowns = includeBreakdowns != null && includeBreakdowns;
        if (withBreakdowns) {
            int limit = safeIntRange(topN, 10, 1, 50);
            result.put("breakdowns", buildComparisonBreakdowns(s1, e1, s2, e2, limit, canteenId1, windowId1, canteenId2, windowId2));
        }
        return result;
    }

    public LocalDateTime[] resolveComparisonRanges(String timeRange1, String timeRange2) {
        LocalDateTime now = LocalDateTime.now();
        String r1 = timeRange1 == null ? "" : timeRange1.trim();
        String r2 = timeRange2 == null ? "" : timeRange2.trim();
        if (!r1.isEmpty() && r1.equalsIgnoreCase(r2)) {
            Integer days = tryParseDays(r1);
            if (days != null && days > 0) {
                LocalDateTime end1 = now;
                LocalDateTime start1 = now.minusDays(days);
                LocalDateTime end2 = start1;
                LocalDateTime start2 = end2.minusDays(days);
                return new LocalDateTime[]{start1, end1, start2, end2};
            }

            LocalDateTime start1 = getStartDateByTimeRange(r1.toLowerCase());
            LocalDateTime end1 = now;
            java.time.Duration dur = java.time.Duration.between(start1, end1);
            LocalDateTime end2 = start1;
            LocalDateTime start2 = end2.minus(dur);
            return new LocalDateTime[]{start1, end1, start2, end2};
        }

        LocalDateTime start1 = getStartDateByTimeRange(r1.toLowerCase());
        LocalDateTime end1 = now;
        LocalDateTime start2 = getStartDateByTimeRange(r2.toLowerCase());
        LocalDateTime end2 = now;
        return new LocalDateTime[]{start1, end1, start2, end2};
    }

    private Integer tryParseDays(String timeRange) {
        if (timeRange == null) return null;
        String s = timeRange.trim();
        if (s.isEmpty()) return null;
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Map<String, Object> buildComparisonKpis(Map<String, Object> a, Map<String, Object> b) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("revenue", kpiRow(safeBigDecimal(a.get("revenue")), safeBigDecimal(b.get("revenue"))));
        out.put("orders", kpiRow(((Number) a.getOrDefault("orders", 0L)).longValue(), ((Number) b.getOrDefault("orders", 0L)).longValue()));
        out.put("users", kpiRow(((Number) a.getOrDefault("users", 0L)).longValue(), ((Number) b.getOrDefault("users", 0L)).longValue()));
        out.put("avgOrderValue", kpiRow(safeBigDecimal(a.get("avgOrderValue")), safeBigDecimal(b.get("avgOrderValue"))));
        return out;
    }

    private Map<String, Object> kpiRow(BigDecimal a, BigDecimal b) {
        BigDecimal aa = a == null ? BigDecimal.ZERO : a;
        BigDecimal bb = b == null ? BigDecimal.ZERO : b;
        BigDecimal delta = aa.subtract(bb);
        Double deltaPct = bb.compareTo(BigDecimal.ZERO) == 0 ? null : roundDouble(delta.divide(bb, 8, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).doubleValue(), 6);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("a", aa);
        m.put("b", bb);
        m.put("delta", delta);
        m.put("deltaPct", deltaPct);
        return m;
    }

    private Map<String, Object> kpiRow(long a, long b) {
        long delta = a - b;
        Double deltaPct = b == 0 ? null : roundDouble(((double) delta / (double) b) * 100.0, 6);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("a", a);
        m.put("b", b);
        m.put("delta", delta);
        m.put("deltaPct", deltaPct);
        return m;
    }

    private Map<String, Object> buildComparisonBreakdowns(LocalDateTime s1, LocalDateTime e1, LocalDateTime s2, LocalDateTime e2, int limit) {
        return buildComparisonBreakdowns(s1, e1, s2, e2, limit, null, null, null, null);
    }

    private Map<String, Object> buildComparisonBreakdowns(LocalDateTime s1, LocalDateTime e1, LocalDateTime s2, LocalDateTime e2, int limit, Long canteenId1, Long windowId1, Long canteenId2, Long windowId2) {
        Map<String, BigDecimal> aCat = querySubtotalByCategory(s1, e1, limit, canteenId1, windowId1);
        Map<String, BigDecimal> bCat = querySubtotalByCategory(s2, e2, limit, canteenId2, windowId2);
        Map<String, BigDecimal> aWin = querySubtotalByWindow(s1, e1, limit, canteenId1, windowId1);
        Map<String, BigDecimal> bWin = querySubtotalByWindow(s2, e2, limit, canteenId2, windowId2);
        Map<String, BigDecimal> aDish = querySubtotalByDish(s1, e1, limit, canteenId1, windowId1);
        Map<String, BigDecimal> bDish = querySubtotalByDish(s2, e2, limit, canteenId2, windowId2);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("byCategory", buildDeltaList(aCat, bCat, limit));
        out.put("byWindow", buildDeltaList(aWin, bWin, limit));
        out.put("byDish", buildDeltaList(aDish, bDish, limit));
        return out;
    }

    private List<Map<String, Object>> buildDeltaList(Map<String, BigDecimal> a, Map<String, BigDecimal> b, int limit) {
        Set<String> keys = new HashSet<>();
        if (a != null) keys.addAll(a.keySet());
        if (b != null) keys.addAll(b.keySet());
        List<Map<String, Object>> out = new ArrayList<>();
        for (String k : keys) {
            BigDecimal aa = a == null ? BigDecimal.ZERO : a.getOrDefault(k, BigDecimal.ZERO);
            BigDecimal bb = b == null ? BigDecimal.ZERO : b.getOrDefault(k, BigDecimal.ZERO);
            BigDecimal delta = aa.subtract(bb);
            Double deltaPct = bb.compareTo(BigDecimal.ZERO) == 0 ? null : roundDouble(delta.divide(bb, 8, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100)).doubleValue(), 6);
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("name", k);
            m.put("a", aa);
            m.put("b", bb);
            m.put("delta", delta);
            m.put("deltaPct", deltaPct);
            out.add(m);
        }
        out.sort((x, y) -> {
            BigDecimal dx = safeBigDecimal(x.get("delta")).abs();
            BigDecimal dy = safeBigDecimal(y.get("delta")).abs();
            return dy.compareTo(dx);
        });
        if (out.size() > limit) return new ArrayList<>(out.subList(0, limit));
        return out;
    }

    private Map<String, BigDecimal> querySubtotalByCategory(LocalDateTime start, LocalDateTime end, int limit) {
        return querySubtotalByCategory(start, end, limit, null, null);
    }

    private Map<String, BigDecimal> querySubtotalByCategory(LocalDateTime start, LocalDateTime end, int limit, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT d.dish_category AS k, SUM(oi.subtotal) AS v ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                .append("AND o.total_amount > 0 ");
        params.add(start);
        params.add(end);
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        sql.append("GROUP BY d.dish_category ORDER BY v DESC LIMIT ?");
        params.add(limit);
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        Map<String, BigDecimal> out = new LinkedHashMap<>();
        for (Map<String, Object> r : rows) {
            String key = mapCategoryName(r.get("k"));
            out.put(key, safeBigDecimal(r.get("v")));
        }
        return out;
    }

    private Map<String, BigDecimal> querySubtotalByWindow(LocalDateTime start, LocalDateTime end, int limit) {
        return querySubtotalByWindow(start, end, limit, null, null);
    }

    private Map<String, BigDecimal> querySubtotalByWindow(LocalDateTime start, LocalDateTime end, int limit, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT d.window_id AS wid, MAX(d.window_name) AS wname, SUM(oi.subtotal) AS v ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                .append("AND o.total_amount > 0 ");
        params.add(start);
        params.add(end);
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        sql.append("GROUP BY d.window_id ORDER BY v DESC LIMIT ?");
        params.add(limit);
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        Map<String, BigDecimal> out = new LinkedHashMap<>();
        for (Map<String, Object> r : rows) {
            Object wid = r.get("wid");
            String name = r.get("wname") == null ? (wid == null ? "未知窗口" : String.valueOf(wid)) : String.valueOf(r.get("wname"));
            out.put(name, safeBigDecimal(r.get("v")));
        }
        return out;
    }

    private Map<String, BigDecimal> querySubtotalByDish(LocalDateTime start, LocalDateTime end, int limit) {
        return querySubtotalByDish(start, end, limit, null, null);
    }

    private Map<String, BigDecimal> querySubtotalByDish(LocalDateTime start, LocalDateTime end, int limit, Long canteenId, Long windowId) {
        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();
        sql.append("SELECT d.id AS did, d.name AS dname, SUM(oi.subtotal) AS v ")
                .append("FROM order_items oi ")
                .append("JOIN orders o ON oi.order_id = o.id ")
                .append("JOIN dishes d ON oi.dish_id = d.id ")
                .append("WHERE oi.create_time >= ? AND oi.create_time <= ? ")
                .append("AND o.status IN ").append(VALID_ORDER_STATUSES).append(" ")
                .append("AND o.total_amount > 0 ");
        params.add(start);
        params.add(end);
        if (canteenId != null) {
            sql.append("AND d.canteen_id = ? ");
            params.add(canteenId);
        }
        if (windowId != null) {
            sql.append("AND d.window_id = ? ");
            params.add(windowId);
        }
        sql.append("GROUP BY d.id, d.name ORDER BY v DESC LIMIT ?");
        params.add(limit);
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql.toString(), params.toArray());
        Map<String, BigDecimal> out = new LinkedHashMap<>();
        for (Map<String, Object> r : rows) {
            String name = r.get("dname") == null ? String.valueOf(r.get("did")) : String.valueOf(r.get("dname"));
            out.put(name, safeBigDecimal(r.get("v")));
        }
        return out;
    }
    
    // Public helper for Controller to resolve dates
    public LocalDateTime getStartDateByTimeRange(String timeRange) {
        LocalDateTime now = LocalDateTime.now();
        switch (timeRange) {
            case "today":
                return LocalDateTime.of(now.toLocalDate(), LocalTime.MIN);
            case "week":
                // 本周一
                return now.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).with(LocalTime.MIN);
            case "month":
                // 本月1日
                return now.with(TemporalAdjusters.firstDayOfMonth()).with(LocalTime.MIN);
            case "quarter":
                // 本季度首月1日
                int currentMonth = now.getMonthValue();
                int firstMonthOfQuarter = currentMonth - (currentMonth - 1) % 3;
                return LocalDateTime.of(now.getYear(), firstMonthOfQuarter, 1, 0, 0);
            case "year":
                // 本年1月1日
                return now.with(TemporalAdjusters.firstDayOfYear()).with(LocalTime.MIN);
            default:
                try {
                    int days = Integer.parseInt(timeRange);
                    return now.minusDays(days);
                } catch (NumberFormatException e) {
                    return now.minusDays(7);
                }
        }
    }
}
