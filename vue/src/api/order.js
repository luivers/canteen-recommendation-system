import api from "./index";

const toPositiveInteger = (value, fieldName) => {
  const numberValue = Number(value);
  if (!Number.isInteger(numberValue) || numberValue <= 0) {
    throw new Error(`${fieldName} must be a positive integer`);
  }
  return numberValue;
};

const normalizeCartPayload = ({ dishId, comboId, quantity = 1 } = {}) => {
  const resolvedQuantity = toPositiveInteger(quantity, "quantity");
  const hasDishId = dishId !== undefined && dishId !== null && dishId !== "";
  const hasComboId = comboId !== undefined && comboId !== null && comboId !== "";

  if (hasDishId === hasComboId) {
    throw new Error("cart item must contain exactly one of dishId or comboId");
  }

  if (hasComboId) {
    return {
      comboId: toPositiveInteger(comboId, "comboId"),
      quantity: resolvedQuantity,
    };
  }

  return {
    dishId: toPositiveInteger(dishId, "dishId"),
    quantity: resolvedQuantity,
  };
};

export const normalizeOrderListResponse = (response) => {
  const payload = response?.data?.data ?? response?.data ?? response;

  if (Array.isArray(payload)) {
    return {
      rows: payload,
      totalElements: payload.length,
    };
  }

  if (payload && Array.isArray(payload.content)) {
    return {
      rows: payload.content,
      totalElements: Number(payload.totalElements ?? payload.content.length),
    };
  }

  if (payload && Array.isArray(payload.records)) {
    return {
      rows: payload.records,
      totalElements: Number(payload.total ?? payload.records.length),
    };
  }

  if (payload && Array.isArray(payload.rows)) {
    return {
      rows: payload.rows,
      totalElements: Number(payload.total ?? payload.rows.length),
    };
  }

  return {
    rows: [],
    totalElements: 0,
  };
};

export const orderApi = {
  createOrder: (orderData) => {
    return api.post("/api/orders", orderData);
  },

  getOrders: (params) => {
    return api.get("/api/orders", { params });
  },

  getOrder: (orderId) => {
    return api.get(`/api/orders/${orderId}`);
  },

  deleteOrder: (orderId) => {
    return api.delete(`/api/orders/${orderId}`);
  },

  cancelOrder: (orderId) => {
    return api.put(`/api/orders/${orderId}/cancel`);
  },

  confirmPickup: (orderOrId) => {
    const resolvedId =
      typeof orderOrId === "object"
        ? (orderOrId?.id ?? orderOrId?.orderId ?? orderOrId?.order?.id)
        : orderOrId;
    if (resolvedId == null || resolvedId === "") {
      return Promise.reject(new Error("Order id is required"));
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

  prepareOrder: (orderId) => {
    return api.put(`/api/orders/${orderId}/prepare`);
  },

  readyOrder: (orderId) => {
    return api.put(`/api/orders/${orderId}/ready`);
  },

  markPaid: (orderId, payload) => {
    return api.post(`/api/payments/orders/${orderId}/success`, payload);
  },

  createPayment: (orderId, payload) => {
    return api.post(`/api/payments/orders/${orderId}/create`, payload);
  },

  getCart: () => {
    return api.get("/api/orders/cart");
  },

  addToCart: (cartItem) => {
    return api.post("/api/orders/cart", normalizeCartPayload(cartItem));
  },

  addDishToCart: (dishId, quantity = 1) => {
    return api.post(
      "/api/orders/cart",
      normalizeCartPayload({ dishId, quantity }),
    );
  },

  addComboToCart: (comboId, quantity = 1) => {
    return api.post(
      "/api/orders/cart",
      normalizeCartPayload({ comboId, quantity }),
    );
  },

  updateCartItem: (itemId, quantity) => {
    return api.put(`/api/orders/cart/${itemId}`, {
      quantity: toPositiveInteger(quantity, "quantity"),
    });
  },

  removeFromCart: (itemId) => {
    return api.delete(`/api/orders/cart/${itemId}`);
  },

  clearCart: () => {
    return api.delete("/api/orders/cart");
  },

  normalizeOrderListResponse,
};
