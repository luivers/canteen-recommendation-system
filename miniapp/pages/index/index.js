const { dishApi, recommendationApi } = require("../../api/index");
const {
  normalizeDishList,
  normalizeRecommendationWithReasons,
} = require("../../utils/dish");

const settle = (promise) => {
  return promise
    .then((data) => ({ ok: true, data }))
    .catch((error) => ({ ok: false, error }));
};

Page({
  data: {
    loading: false,
    errorMessage: "",
    hotDishes: [],
    personalizedDishes: [],
    healthDishes: [],
  },

  onLoad() {
    this.loadHome();
  },

  loadHome() {
    this.setData({ loading: true, errorMessage: "" });

    Promise.all([
      settle(dishApi.getHotDishes(6)),
      settle(recommendationApi.getPersonalizedRecommendationsWithReason(6)),
      settle(recommendationApi.getPersonalizedRecommendations(6)),
      settle(recommendationApi.getRecentHealthGoalRecommendations(4)),
    ])
      .then(([hotResult, reasonResult, personalizedResult, healthResult]) => {
        const personalizedWithReason = reasonResult.ok
          ? normalizeRecommendationWithReasons(reasonResult.data)
          : [];
        const personalizedFallback = personalizedResult.ok
          ? normalizeDishList(personalizedResult.data)
          : [];
        const hotDishes = hotResult.ok ? normalizeDishList(hotResult.data) : [];
        const personalizedDishes = personalizedWithReason.length
          ? personalizedWithReason
          : personalizedFallback;
        const healthDishes = healthResult.ok ? normalizeDishList(healthResult.data) : [];
        const hasAnyData = hotDishes.length || personalizedDishes.length || healthDishes.length;

        this.setData({
          hotDishes,
          personalizedDishes,
          healthDishes,
          errorMessage: hasAnyData ? "" : "暂时没有可展示的推荐",
        });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "首页数据加载失败",
        });
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  openDishes() {
    wx.switchTab({ url: "/pages/dishes/dishes" });
  },

  openDish(event) {
    const id = event.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/dish-detail/dish-detail?id=${id}` });
  },
});
