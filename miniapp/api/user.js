const { get, post } = require("../utils/request");

const loginByCode = (code) => post("/api/miniapp/login", { code });
const getCurrentUser = () => get("/api/users/me");

module.exports = {
  loginByCode,
  getCurrentUser,
};
