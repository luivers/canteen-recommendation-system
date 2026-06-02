const { get, post, put } = require("../utils/request");

const getOrders = (params = {}) => get("/api/orders", params);
const getOrder = (orderId) => get(`/api/orders/${orderId}`);
const createOrder = (payload) => post("/api/orders", payload);
const cancelOrder = (orderId) => put(`/api/orders/${orderId}/cancel`);
const confirmPickup = (orderId) => put(`/api/orders/${orderId}/complete`);

module.exports = {
  getOrders,
  getOrder,
  createOrder,
  cancelOrder,
  confirmPickup,
};
