const { get, post, put, delete: del } = require("../utils/request");
const { silentLogin } = require("../utils/login");

const isAuthError = (error) => error && (error.statusCode === 401 || error.statusCode === 403);

const withAuthRetry = (operation) => {
  return operation().catch((error) => {
    if (!isAuthError(error)) {
      throw error;
    }
    return silentLogin().then(() => operation());
  });
};

const getOrders = (params = {}) => withAuthRetry(() => get("/api/orders", params));
const getOrder = (orderId) => withAuthRetry(() => get(`/api/orders/${orderId}`));
const createOrder = (payload) => withAuthRetry(() => post("/api/orders", payload));
const cancelOrder = (orderId) => withAuthRetry(() => put(`/api/orders/${orderId}/cancel`));
const confirmPickup = (orderId) => withAuthRetry(() => put(`/api/orders/${orderId}/complete`));
const getCart = () => withAuthRetry(() => get("/api/orders/cart"));
const addToCart = (payload) => withAuthRetry(() => post("/api/orders/cart", payload));
const updateCartItem = (itemId, quantity) => withAuthRetry(() => put(`/api/orders/cart/${itemId}`, { quantity }));
const removeCartItem = (itemId) => withAuthRetry(() => del(`/api/orders/cart/${itemId}`));
const clearCart = () => withAuthRetry(() => del("/api/orders/cart"));

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
