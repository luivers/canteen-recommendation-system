const { apiBaseUrl } = require("./config/env");
const { getToken, getCurrentUser } = require("./utils/auth");

App({
  globalData: {
    apiBaseUrl,
    token: "",
    currentUser: null,
  },

  onLaunch() {
    this.globalData.token = getToken();
    this.globalData.currentUser = getCurrentUser();
  },

  setAuthState(token, user) {
    this.globalData.token = token || "";
    this.globalData.currentUser = user || null;
  },
});
