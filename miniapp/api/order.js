const { get, post, put, delete: del } = require("../utils/request");

const getOrders = (params = {}) => get("/api/orders", params);
const getOrder = (orderId) => get(`/api/orders/${orderId}`);
const createOrder = (payload) => post("/api/orders", payload);
const cancelOrder = (orderId) => put(`/api/orders/${orderId}/cancel`);
const confirmPickup = (orderId) => put(`/api/orders/${orderId}/complete`);
const getCart = () => get("/api/orders/cart");
const addToCart = (payload) => post("/api/orders/cart", payload);
const updateCartItem = (itemId, quantity) => put(`/api/orders/cart/${itemId}`, { quantity });
const removeCartItem = (itemId) => del(`/api/orders/cart/${itemId}`);
const clearCart = () => del("/api/orders/cart");

module.exports = {
  addToCart,
  clearCart,
  getCart,
  getOrders,
  getOrder,
  createOrder,
  cancelOrder,
  confirmPickup,
  removeCartItem,
  updateCartItem,
};
