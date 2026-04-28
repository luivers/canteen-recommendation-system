import api from "./index";

export default {
  // 获取个性化推荐
  getPersonalizedRecommendations(limit = 10) {
    return api.get("/api/recommendations/personalized", {
      params: { limit },
    });
  },

  // 获取带推荐理由的个性化推荐
  getPersonalizedRecommendationsWithReason(limit = 10) {
    return api.get("/api/recommendations/personalized/reasons", {
      params: { limit },
    });
  },

  // 获取特定策略的推荐
  getRecommendationsByStrategy(strategyType, limit = 10) {
    return api.get(`/api/recommendations/strategy/${strategyType}`, {
      params: { limit },
    });
  },

  // 获取健康目标推荐
  getHealthRecommendations(goal, limit = 10) {
    return api.get("/api/recommendations/health", {
      params: { goal, limit },
    });
  },

  // 获取智能健康目标推荐（最近7天画像）
  getHealthGoalRecommendations(limit = 6, refreshToken) {
    return api.get("/api/recommendations/health-goals", {
      params: { limit, refreshToken },
    });
  },

  // 获取新菜品发现推荐
  getDiscoveryRecommendations(limit = 10) {
    return api.get("/api/recommendations/discovery", {
      params: { limit },
    });
  },

  // 获取今日上新菜品
  getTodayNewDishes(limit = 10) {
    return api.get("/api/recommendations/today-new", {
      params: { limit },
    });
  },

  // 获取今日个性化热门菜品
  getTodayPersonalizedHotDishes(limit = 10) {
    return api.get("/api/recommendations/today-personalized-hot", {
      params: { limit },
    });
  },

  // 获取综合推荐
  getComprehensiveRecommendations() {
    return api.get("/api/recommendations/comprehensive");
  },
};
