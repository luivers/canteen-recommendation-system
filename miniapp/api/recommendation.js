const { get } = require("../utils/request");

const getPersonalizedRecommendations = (limit = 6) => {
  return get("/api/recommendations/personalized", { limit });
};

const getPersonalizedRecommendationsWithReason = (limit = 6) => {
  return get("/api/recommendations/personalized/reasons", { limit });
};

const getRecommendationsByStrategy = (strategy, limit = 6) => {
  return get(`/api/recommendations/strategy/${strategy}`, { limit });
};

const getHealthGoalRecommendations = (goal, limit = 6) => {
  return get("/api/recommendations/health", { goal, limit });
};

const getRecentHealthGoalRecommendations = (limit = 6, refreshToken) => {
  return get("/api/recommendations/health-goals", { limit, refreshToken });
};

const getDiscoveryRecommendations = (limit = 6) => {
  return get("/api/recommendations/discovery", { limit });
};

const getTodayNewDishes = (limit = 6) => {
  return get("/api/recommendations/today-new", { limit });
};

const getTodayPersonalizedHotDishes = (limit = 6) => {
  return get("/api/recommendations/today-personalized-hot", { limit });
};

module.exports = {
  getPersonalizedRecommendations,
  getPersonalizedRecommendationsWithReason,
  getRecommendationsByStrategy,
  getHealthGoalRecommendations,
  getRecentHealthGoalRecommendations,
  getDiscoveryRecommendations,
  getTodayNewDishes,
  getTodayPersonalizedHotDishes,
};
