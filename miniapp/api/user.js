const { get, post, put } = require("../utils/request");

const loginByCode = (code) => post("/api/miniapp/login", { code });
const getCurrentUser = () => get("/api/users/me");
const updatePreferences = (userId, payload = {}) => put(`/api/users/${userId}/preferences`, payload);

module.exports = {
  getCurrentUser,
  loginByCode,
  updatePreferences,
};
