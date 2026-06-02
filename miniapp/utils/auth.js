const storage = require("./storage");

const TOKEN_KEY = "canteen_miniapp_token";
const USER_KEY = "canteen_miniapp_user";

const getToken = () => storage.get(TOKEN_KEY, "");

const setToken = (token) => {
  storage.set(TOKEN_KEY, token || "");
};

const clearToken = () => {
  storage.remove(TOKEN_KEY);
};

const getCurrentUser = () => storage.get(USER_KEY, null);

const setCurrentUser = (user) => {
  storage.set(USER_KEY, user || null);
};

const saveAuthState = (token, user) => {
  setToken(token);
  setCurrentUser(user);
};

const clearAuth = () => {
  clearToken();
  storage.remove(USER_KEY);
};

const getAuthHeader = () => {
  const token = getToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
};

module.exports = {
  TOKEN_KEY,
  USER_KEY,
  getToken,
  setToken,
  clearToken,
  getCurrentUser,
  setCurrentUser,
  saveAuthState,
  clearAuth,
  getAuthHeader,
};
