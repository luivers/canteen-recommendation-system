import api from "./index";

// 促销活动相关API
export const promotionsAPI = {
  // 获取促销统计数据
  getStats: () => api.get("/api/promotions/stats"),

  // 获取促销活动列表（分页）
  getPromotions: (params) => api.get("/api/promotions/page", { params }),

  // 搜索促销活动
  searchPromotions: (data, params) =>
    api.post("/api/promotions/search", data, { params }),

  // 根据ID获取促销活动
  getPromotionById: (id) => api.get(`/api/promotions/${id}`),

  // 创建促销活动
  createPromotion: (data) => api.post("/api/promotions", data),

  // 更新促销活动
  updatePromotion: (id, data) => api.put(`/api/promotions/${id}`, data),

  // 删除促销活动
  deletePromotion: (id) => api.delete(`/api/promotions/${id}`),

  // 切换促销活动状态
  togglePromotionStatus: (id) =>
    api.patch(`/api/promotions/${id}/toggle-status`),

  // 获取活跃的促销活动
  getActivePromotions: () => api.get("/api/promotions/active"),
};

// 套餐组合相关API
export const combosAPI = {
  // 获取套餐列表
  getCombos: () => api.get("/api/combos"),

  getActiveCombos: () => api.get("/api/combos/active"),

  // 根据促销ID获取套餐列表
  getCombosByPromotionId: (promotionId) =>
    api.get(`/api/combos/promotion/${promotionId}`),

  getActiveCombosByPromotionId: (promotionId) =>
    api.get(`/api/combos/promotion/${promotionId}/active`),

  // 获取套餐详情
  getComboById: (id) => api.get(`/api/combos/${id}`),

  // 创建套餐
  createCombo: (data) => api.post("/api/combos", data),

  // 更新套餐
  updateCombo: (id, data) => api.put(`/api/combos/${id}`, data),

  // 删除套餐
  deleteCombo: (id) => api.delete(`/api/combos/${id}`),

  // 切换套餐状态
  toggleComboStatus: (id) => api.patch(`/api/combos/${id}/toggle-status`),
};
