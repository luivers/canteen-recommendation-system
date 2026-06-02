const { apiBaseUrl } = require("./config/env");
const { getToken, getCurrentUser } = require("./utils/auth");
const { silentLogin } = require("./utils/login");

App({
  globalData: {
    apiBaseUrl,
    token: "",
    currentUser: null,
  },

  onLaunch() {
    this.globalData.token = getToken();
    this.globalData.currentUser = getCurrentUser();
    if (!this.globalData.token) {
      silentLogin()
        .then((authState) => {
          this.setAuthState(authState.token, authState.user);
        })
        .catch((error) => {
          console.warn("[miniapp login]", error.message || error);
        });
    }
  },

  setAuthState(token, user) {
    this.globalData.token = token || "";
    this.globalData.currentUser = user || null;
  },
});
