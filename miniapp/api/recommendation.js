const { get } = require("../utils/request");

const getPersonalizedRecommendations = (limit = 6) => {
  return get("/api/recommendations/personalized", { limit });
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

module.exports = {
  getPersonalizedRecommendations,
  getRecommendationsByStrategy,
  getHealthGoalRecommendations,
  getRecentHealthGoalRecommendations,
};
