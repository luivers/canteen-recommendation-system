import api from "./index";

export const dishApi = {
  // 获取菜品列表
  getDishes: (params) => {
    return api.get("/api/dishes", { params });
  },

  // 获取菜品详情
  getDish: (dishId) => {
    return api.get(`/api/dishes/${dishId}`);
  },

  // 创建菜品（管理员）
  createDish: (dishData) => {
    return api.post("/api/dishes", dishData);
  },

  // 更新菜品（管理员）
  updateDish: (dishId, dishData) => {
    return api.put(`/api/dishes/${dishId}`, dishData);
  },

  // 删除菜品（管理员）
  deleteDish: (dishId) => {
    return api.delete(`/api/dishes/${dishId}`);
  },

  // 获取菜品分类
  getCategories: () => {
    return api.get("/api/dishes/categories");
  },

  // 获取热门菜品
  getHotDishes: (limit = 10) => {
    // 调用热门菜品接口，确保参数正确
    return api.get("/api/dishes/hot", { params: { limit } });
  },

  // 搜索菜品
  searchDishes: (keyword, params) => {
    return api.get("/api/dishes/search", {
      params: { keyword, ...params },
    });
  },

  // 更新菜品库存（管理员）
  updateStock: (dishId, quantity, add = false) => {
    return api.put(`/api/dishes/${dishId}/stock`, null, {
      params: { quantity, add }
    });
  },

  // 设置菜品促销（管理员）
  setPromotion: (dishId, promotionData) => {
    return api.put(`/api/dishes/${dishId}/promotion`, promotionData);
  },

  // 更新菜品状态（管理员）- 简单切换状态，不需要传额外参数
  updateDishStatus: (dishId, available) => {
    return api.put(`/api/dishes/${dishId}/status`, { available });
  },

  // 更新菜品促销信息
  updateDishPromotion: (dishId, promotionData) => {
    return api.patch(`/api/dishes/${dishId}/promotion`, promotionData);
  },

  // 获取菜品评分详情
  getDishRatings: (dishId) => {
    return api.get(`/api/dishes/${dishId}/ratings`);
  },

  getPromotionDishes: () => {
    return api.get("/api/dishes/promotions");
  },

  getActivePromotionDishes: () => {
    return api.get("/api/dishes/promotions/active");
  },

  // 获取当前正在进行的促销菜品，按价格升序排序
  getActivePromotionDishesOrderByPriceAsc: () => {
    return api.get("/api/dishes/promotions/active/price-asc");
  },

  // 获取当前正在进行的促销菜品，按评分降序排序
  getActivePromotionDishesOrderByRatingDesc: () => {
    return api.get("/api/dishes/promotions/active/rating-desc");
  },
};
