const { rewardsApi } = require("../../api/index");

Page({
  data: {
    tabs: [
      { value: "", label: "全部" },
      { value: "false", label: "未使用" },
      { value: "true", label: "已使用" },
    ],
    activeUsed: "",
    vouchers: [],
    page: 0,
    size: 20,
    total: 0,
    hasMore: false,
    loading: false,
    loadingMore: false,
    errorMessage: "",
  },

  onLoad() {
    this.loadVouchers(true);
  },

  onPullDownRefresh() {
    this.loadVouchers(true).finally(() => wx.stopPullDownRefresh());
  },

  onReachBottom() {
    if (!this.data.hasMore || this.data.loading || this.data.loadingMore) return;
    this.loadVouchers(false);
  },

  loadVouchers(reset) {
    const page = reset ? 0 : this.data.page + 1;
    const params = { page, size: this.data.size };
    if (this.data.activeUsed) params.used = this.data.activeUsed === "true";

    this.setData({ loading: reset, loadingMore: !reset, errorMessage: "" });
    return rewardsApi
      .getMyVouchersPage(params)
      .then((pageData) => {
        this.setData({
          vouchers: reset ? pageData.items : this.data.vouchers.concat(pageData.items),
          page: pageData.page,
          total: pageData.total,
          hasMore: pageData.hasMore,
          errorMessage: pageData.items.length || !reset ? "" : "暂无优惠券",
        });
      })
      .catch((error) => {
        this.setData({ errorMessage: error.message || "优惠券加载失败", hasMore: false });
      })
      .finally(() => {
        this.setData({ loading: false, loadingMore: false });
      });
  },

  selectUsed(event) {
    const value = event.currentTarget.dataset.value || "";
    if (value === this.data.activeUsed) return;
    this.setData({ activeUsed: value });
    this.loadVouchers(true);
  },
});
