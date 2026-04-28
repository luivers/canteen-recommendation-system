import api from "./index";

export const orderApi = {
  // 创建订单
  createOrder: (orderData) => {
    return api.post("/api/orders", orderData);
  },

  // 获取订单列表
  getOrders: (params) => {
    return api.get("/api/orders", { params });
  },

  // 获取订单详情
  getOrder: (orderId) => {
    return api.get(`/api/orders/${orderId}`);
  },

  deleteOrder: (orderId) => {
    return api.delete(`/api/orders/${orderId}`);
  },

  // 取消订单
  cancelOrder: (orderId) => {
    return api.put(`/api/orders/${orderId}/cancel`);
  },

  // 确认取餐
  confirmPickup: (orderOrId) => {
    const resolvedId =
      typeof orderOrId === "object"
        ? (orderOrId?.id ?? orderOrId?.orderId ?? orderOrId?.order?.id)
        : orderOrId;
    if (resolvedId == null || resolvedId === "") {
      return Promise.reject(new Error("订单ID缺失"));
    }
    return api
      .put(`/api/orders/${resolvedId}/confirm-pickup`)
      .catch((error) => {
        if (error?.response?.status === 404) {
          return api.put(`/api/orders/${resolvedId}/confirmPickup`);
        }
        throw error;
      });
  },

  // 开始制作
  prepareOrder: (orderId) => {
    return api.put(`/api/orders/${orderId}/prepare`);
  },

  // 制作完成
  readyOrder: (orderId) => {
    return api.put(`/api/orders/${orderId}/ready`);
  },

  // 标记订单已支付（前端主动调用）
  markPaid: (orderId, payload) => {
    return api.post(`/api/payments/orders/${orderId}/success`, payload);
  },

  // 获取购物车
  getCart: () => {
    return api.get("/api/orders/cart");
  },

  // 添加菜品到购物车
  addToCart: (cartItem) => {
    return api.post("/api/orders/cart", cartItem);
  },

  // 更新购物车项
  updateCartItem: (itemId, quantity) => {
    return api.put(`/api/orders/cart/${itemId}`, { quantity });
  },

  // 删除购物车项
  removeFromCart: (itemId) => {
    return api.delete(`/api/orders/cart/${itemId}`);
  },

  // 清空购物车
  clearCart: () => {
    return api.delete("/api/orders/cart");
  },
};
