const { reviewApi } = require("../../api/index");
const { getCurrentUser } = require("../../utils/auth");

Page({
  data: {
    reviews: [],
    loading: false,
    errorMessage: "",
  },

  onLoad() {
    this.loadReviews();
  },

  onPullDownRefresh() {
    this.loadReviews().finally(() => wx.stopPullDownRefresh());
  },

  loadReviews() {
    const user = getCurrentUser() || {};
    if (!user.id) {
      this.setData({ reviews: [], errorMessage: "请先完成登录" });
      return Promise.resolve();
    }

    this.setData({ loading: true, errorMessage: "" });
    return reviewApi
      .getUserReviews(user.id)
      .then((reviews) => {
        this.setData({
          reviews,
          errorMessage: reviews.length ? "" : "暂无评价",
        });
      })
      .catch((error) => {
        this.setData({ errorMessage: error.message || "评价加载失败" });
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  openOrder(event) {
    const id = event.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/order-detail/order-detail?id=${id}` });
  },
});
