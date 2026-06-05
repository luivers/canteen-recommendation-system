const { pointsApi, userApi } = require("../../api/index");
const { getToken, getCurrentUser, setCurrentUser } = require("../../utils/auth");
const { silentLogin } = require("../../utils/login");

Page({
  data: {
    hasToken: false,
    currentUser: null,
    avatarLetter: "我",
    points: 0,
    loginMessage: "",
    loggingIn: false,
    loadingProfile: false,
    menuItems: [
      { title: "我的评价", desc: "查看历史评价和商家回复", url: "/pages/my-reviews/my-reviews" },
      { title: "积分流水", desc: "查看积分获取和消费明细", url: "/pages/points-history/points-history" },
      { title: "积分商城", desc: "用积分兑换优惠券和奖励", url: "/pages/rewards/rewards" },
      { title: "兑换记录", desc: "查看奖励兑换进度", url: "/pages/exchanges/exchanges" },
      { title: "我的优惠券", desc: "查看可用和已用优惠券", url: "/pages/vouchers/vouchers" },
    ],
  },

  onShow() {
    this.refreshAuthState();
    if (getToken()) {
      this.loadProfile();
    }
  },

  refreshAuthState() {
    const user = getCurrentUser();
    this.setData({
      hasToken: !!getToken(),
      currentUser: user,
      avatarLetter: this.getAvatarLetter(user),
    });
  },

  loadProfile() {
    this.setData({ loadingProfile: true, loginMessage: "" });
    return Promise.all([
      userApi.getCurrentUser().catch((error) => {
        if (error.statusCode === 401) throw error;
        return getCurrentUser();
      }),
      pointsApi.getBalance().catch(() => this.data.points),
    ])
      .then(([user, points]) => {
        if (user) {
          setCurrentUser(user);
        }
        this.setData({
          hasToken: !!getToken(),
          currentUser: user || getCurrentUser(),
          avatarLetter: this.getAvatarLetter(user || getCurrentUser()),
          points,
        });
      })
      .catch((error) => {
        this.setData({ loginMessage: error.message || "个人信息加载失败" });
      })
      .finally(() => {
        this.setData({ loadingProfile: false });
      });
  },

  retryLogin() {
    if (this.data.loggingIn) return;
    this.setData({ loggingIn: true, loginMessage: "" });
    silentLogin()
      .then(() => {
        this.refreshAuthState();
        this.setData({ loginMessage: "登录成功" });
        return this.loadProfile();
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

  openMenu(event) {
    const url = event.currentTarget.dataset.url;
    if (!url) return;
    if (!this.data.hasToken) {
      wx.showToast({ title: "请先登录", icon: "none" });
      return;
    }
    wx.navigateTo({ url });
  },

  getAvatarLetter(user) {
    const name = user && (user.username || user.nickname || user.studentId);
    return name ? String(name).slice(0, 1) : "我";
  },
});
