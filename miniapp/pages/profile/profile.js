const { getToken, getCurrentUser } = require("../../utils/auth");
const { silentLogin } = require("../../utils/login");

Page({
  data: {
    hasToken: false,
    currentUser: null,
    loginMessage: "",
    loggingIn: false,
  },

  onShow() {
    this.refreshAuthState();
  },

  refreshAuthState() {
    this.setData({
      hasToken: !!getToken(),
      currentUser: getCurrentUser(),
    });
  },

  retryLogin() {
    if (this.data.loggingIn) return;
    this.setData({ loggingIn: true, loginMessage: "" });
    silentLogin()
      .then(() => {
        this.refreshAuthState();
        this.setData({ loginMessage: "登录成功" });
      })
      .catch((error) => {
        this.setData({
          loginMessage: error.message || "登录失败，请稍后重试",
        });
      })
      .finally(() => {
        this.setData({ loggingIn: false });
      });
  },
});
