import api from "./index";
import {
  getStatisticsDemoResponse,
  isAdminStatisticsDemoEnabled,
} from "./statisticsDemoData";

const statisticsRequest = (methodName, realRequest) => {
  if (isAdminStatisticsDemoEnabled()) {
    const demoResponse = getStatisticsDemoResponse(methodName);
    if (demoResponse) return demoResponse;
  }
  return realRequest();
};

// 统计相关API
export const statisticsApi = {
  isDemoEnabled: isAdminStatisticsDemoEnabled,

  // 获取当前用户偏好
  getMyUserPreferences: () => {
    return statisticsRequest("getMyUserPreferences", () =>
      api.get("/api/statistics/me/user-preferences"),
    );
  },

  // 获取当前用户健康建议
  getMyHealthRecommendations: () => {
    return statisticsRequest("getMyHealthRecommendations", () =>
      api.get("/api/statistics/me/health-recommendations"),
    );
  },

  // 获取关键指标
  getKeyMetrics: (timeRange, startDate, endDate) => {
    return statisticsRequest("getKeyMetrics", () =>
      api.get("/api/statistics/metrics", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取仪表盘摘要
  getDashboardSummary: () => {
    return statisticsRequest("getDashboardSummary", () =>
      api.get("/api/statistics/dashboard-summary"),
    );
  },

  // 获取收入趋势
  getRevenueTrend: (timeRange, startDate, endDate) => {
    return statisticsRequest("getRevenueTrend", () =>
      api.get("/api/statistics/revenue-trend", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取收入趋势详情（含粒度信息）
  getRevenueTrendDetail: (timeRange, startDate, endDate) => {
    return statisticsRequest("getRevenueTrendDetail", () =>
      api.get("/api/statistics/revenue-trend-detail", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取订单趋势
  getOrdersTrend: (timeRange, startDate, endDate) => {
    return statisticsRequest("getOrdersTrend", () =>
      api.get("/api/statistics/orders-trend", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取菜品销量排行
  getDishSalesRanking: (timeRange, startDate, endDate) => {
    return statisticsRequest("getDishSalesRanking", () =>
      api.get("/api/statistics/dish-sales-ranking", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  getDishSalesRankingByPeriod: (timeRange, startDate, endDate) => {
    return statisticsRequest("getDishSalesRankingByPeriod", () =>
      api.get("/api/statistics/dish-sales-ranking-by-period", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取菜品评分排行
  getDishRatingRanking: (timeRange, startDate, endDate, minReviews, limit) => {
    return statisticsRequest("getDishRatingRanking", () =>
      api.get("/api/statistics/dish-rating-ranking", {
        params: { timeRange, startDate, endDate, minReviews, limit },
      }),
    );
  },

  // 获取菜品趋势排行
  getDishTrendRanking: (timeRange, startDate, endDate, metric, limit) => {
    return statisticsRequest("getDishTrendRanking", () =>
      api.get("/api/statistics/dish-trend-ranking", {
        params: { timeRange, startDate, endDate, metric, limit },
      }),
    );
  },

  // 获取菜品分类排行
  getDishCategoryRanking: (timeRange, startDate, endDate, limit) => {
    return statisticsRequest("getDishCategoryRanking", () =>
      api.get("/api/statistics/dish-category-ranking", {
        params: { timeRange, startDate, endDate, limit },
      }),
    );
  },

  // 获取用户活跃时段
  getUserActivePeriods: (timeRange, startDate, endDate) => {
    return statisticsRequest("getUserActivePeriods", () =>
      api.get("/api/statistics/user-active-periods", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取品类销售占比
  getCategorySales: (timeRange, startDate, endDate) => {
    return statisticsRequest("getCategorySales", () =>
      api.get("/api/statistics/category-sales", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取关联规则
  getAssociationRules: (
    timeRange,
    startDate,
    endDate,
    minSupport,
    minConfidence,
    minLift,
    topN,
    level,
    canteenId,
    windowId
  ) => {
    return statisticsRequest("getAssociationRules", () =>
      api.get("/api/statistics/association-rules", {
        params: {
          timeRange,
          startDate,
          endDate,
          minSupport,
          minConfidence,
          minLift,
          topN,
          level,
          canteenId,
          windowId,
        },
      }),
    );
  },

  // 获取用户分群（高级）
  getUserSegmentationAdvanced: (windowDays, canteenId, windowId) => {
    return statisticsRequest("getUserSegmentationAdvanced", () =>
      api.get("/api/statistics/user-segmentation/advanced", {
        params: { windowDays, canteenId, windowId },
      }),
    );
  },

  // 获取用户分群用户列表
  getUserSegmentationUsers: (
    segmentCode,
    windowDays,
    canteenId,
    windowId,
    page,
    size
  ) => {
    return statisticsRequest("getUserSegmentationUsers", () =>
      api.get("/api/statistics/user-segmentation/users", {
        params: { segmentCode, windowDays, canteenId, windowId, page, size },
      }),
    );
  },

  // 获取异常检测
  getAnomalyDetection: (
    timeRange,
    startDate,
    endDate,
    metric,
    dimensionType,
    sigma,
    canteenId,
    windowId,
    dishId,
    category
  ) => {
    return statisticsRequest("getAnomalyDetection", () =>
      api.get("/api/statistics/anomaly-detection", {
        params: {
          timeRange,
          startDate,
          endDate,
          metric,
          dimensionType,
          sigma,
          canteenId,
          windowId,
          dishId,
          category,
        },
      }),
    );
  },

  // 获取库存预警
  getInventoryWarning: (date, dishName) => {
    return statisticsRequest("getInventoryWarning", () =>
      api.get("/api/statistics/inventory-warning", {
        params: { date, dishName },
      }),
    );
  },

  // 获取对比分析
  getComparisonAnalysis: (
    timeRange1,
    timeRange2,
    startDate1,
    endDate1,
    startDate2,
    endDate2,
    includeBreakdowns,
    topN,
    canteenId1,
    windowId1,
    canteenId2,
    windowId2
  ) => {
    return statisticsRequest("getComparisonAnalysis", () =>
      api.get("/api/statistics/comparison-analysis", {
        params: {
          timeRange1,
          timeRange2,
          startDate1,
          endDate1,
          startDate2,
          endDate2,
          includeBreakdowns,
          topN,
          canteenId1,
          windowId1,
          canteenId2,
          windowId2,
        },
      }),
    );
  },

  // 获取品类销售趋势
  getCategoryTrend: (timeRange, startDate, endDate) => {
    return statisticsRequest("getCategoryTrend", () =>
      api.get("/api/statistics/category-trend", {
        params: { timeRange, startDate, endDate },
      }),
    );
  },

  // 获取评价关键词
  getReviewKeywords: (days, startDate, endDate) => {
    return statisticsRequest("getReviewKeywords", () =>
      api.get("/api/statistics/review-keywords", {
        params: { days, startDate, endDate },
      }),
    );
  },

  // 获取菜品特征词云
  getDishFeatures: () => {
    return statisticsRequest("getDishFeatures", () =>
      api.get("/api/statistics/dish-features"),
    );
  },

  getDishFeaturesWordcloud: (params) => {
    return statisticsRequest("getDishFeaturesWordcloud", () =>
      api.get("/api/statistics/dish-features/wordcloud", { params }),
    );
  },

  getDishFeaturesWordcloudVersion: (params) => {
    return statisticsRequest("getDishFeaturesWordcloudVersion", () =>
      api.get("/api/statistics/dish-features/wordcloud/version", {
        params,
      }),
    );
  },

  getDishFeaturesWordcloudDishes: (params) => {
    return statisticsRequest("getDishFeaturesWordcloudDishes", () =>
      api.get("/api/statistics/dish-features/wordcloud/dishes", {
        params,
      }),
    );
  },

  // 获取用户偏好
  getUserPreferences: (userId) => {
    return statisticsRequest("getUserPreferences", () =>
      api.get("/api/statistics/user-preferences", { params: { userId } }),
    );
  },

  // 获取健康饮食建议
  getHealthRecommendations: (userId) => {
    return statisticsRequest("getHealthRecommendations", () =>
      api.get("/api/statistics/health-recommendations", {
        params: { userId },
      }),
    );
  },

  // 获取用户分群
  getUserSegmentation: () => {
    return statisticsRequest("getUserSegmentation", () =>
      api.get("/api/statistics/user-segmentation"),
    );
  },

  // 预览评价关键词
  getReviewKeywordsPreview: (filter) => {
    return statisticsRequest("getReviewKeywordsPreview", () =>
      api.post("/api/statistics/review-keywords/preview", filter),
    );
  },

  // 规则相关
  getReviewKeywordRules: () => {
    return statisticsRequest("getReviewKeywordRules", () =>
      api.get("/api/admin/statistics/review-keyword-rules"),
    );
  },
  createReviewKeywordRule: (rule) => {
    return statisticsRequest("createReviewKeywordRule", () =>
      api.post("/api/admin/statistics/review-keyword-rules", rule),
    );
  },
  updateReviewKeywordRule: (id, rule) => {
    return statisticsRequest("updateReviewKeywordRule", () =>
      api.put(`/api/admin/statistics/review-keyword-rules/${id}`, rule),
    );
  },
  deleteReviewKeywordRule: (id) => {
    return statisticsRequest("deleteReviewKeywordRule", () =>
      api.delete(`/api/admin/statistics/review-keyword-rules/${id}`),
    );
  },
};
