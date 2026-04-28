import api from "./index";

export const reviewApi = {
  // 获取所有评价（管理员）
  getAllReviews: (params) => {
    return api.get("/api/reviews", { params });
  },

  // 创建评价
  createReview: (reviewData) => {
    // 检查 reviewData 是否已经是 FormData
    if (reviewData instanceof FormData) {
      return api.post("/api/reviews", reviewData);
    }
    
    // 如果是普通对象，需要转换为 FormData
    // 注意：这里假设调用者已经处理了图片文件，或者调用者应该直接传递 FormData
    // 为了兼容性，我们发出警告并尝试转换，但不处理文件
    console.warn("createReview: 建议直接传递 FormData 对象以支持图片上传");
    
    const formData = new FormData();
    formData.append("review", new Blob([JSON.stringify(reviewData)], { type: "application/json" }));
    return api.post("/api/reviews", formData);
  },

  // 获取菜品评价列表
  getDishReviews: (dishId, params) => {
    return api.get(`/api/reviews/dish/${dishId}`, { params });
  },

  // 获取用户评价列表
  getUserReviews: (userId, params) => {
    return api.get(`/api/reviews/user/${userId}`, { params });
  },

  // 获取订单评价列表
  getOrderReviews: (orderId) => {
    return api.get(`/api/reviews/order/${orderId}`);
  },

  // 获取评价详情
  getReview: (reviewId) => {
    return api.get(`/api/reviews/${reviewId}`);
  },

  // 更新评价
  updateReview: (reviewId, reviewData) => {
    // 检查 reviewData 是否已经是 FormData
    if (reviewData instanceof FormData) {
      return api.put(`/api/reviews/${reviewId}`, reviewData);
    }
    
    // 如果是普通对象，需要转换为 FormData
    console.warn("updateReview: 建议直接传递 FormData 对象以支持图片上传");
    
    const formData = new FormData();
    formData.append("review", new Blob([JSON.stringify(reviewData)], { type: "application/json" }));
    return api.put(`/api/reviews/${reviewId}`, formData);
  },

  // 删除评价
  deleteReview: (reviewId) => {
    return api.delete(`/api/reviews/${reviewId}`);
  },

  // 食堂回复评价
  replyToReview: (reviewId, reply) => {
    return api.post(`/api/reviews/${reviewId}/reply`, { reply });
  },

  // 更新评价状态
  updateReviewStatus: (reviewId, status) => {
    return api.put(`/api/reviews/${reviewId}/status`, { status });
  },

  // 获取评价统计
  getReviewStats: (dishId) => {
    return api.get(`/api/reviews/stats/${dishId}`);
  },

  // 获取热门标签
  getPopularTags: (limit = 20) => {
    return api.get("/api/reviews/tags/popular", { params: { limit } });
  },
};
