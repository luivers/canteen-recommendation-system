const { get, post } = require("../utils/request");

const createPayment = (orderId, payload = {}) => {
  return post(`/api/payments/orders/${orderId}/create`, payload);
};

const queryPaymentStatus = (orderId) => {
  return get(`/api/payments/orders/${orderId}/status`);
};

const completeMockPayment = (orderId, payload = {}) => {
  return post(`/api/payments/orders/${orderId}/success`, payload);
};

module.exports = {
  createPayment,
  queryPaymentStatus,
  completeMockPayment,
};
