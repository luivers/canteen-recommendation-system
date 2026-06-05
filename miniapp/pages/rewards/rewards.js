const { pointsApi, rewardsApi } = require("../../api/index");
const { getCurrentUser } = require("../../utils/auth");

Page({
  data: {
    balance: 0,
    categories: [],
    rewards: [],
    page: 0,
    size: 10,
    total: 0,
    hasMore: false,
    loading: false,
    loadingMore: false,
    exchanging: false,
    errorMessage: "",
    filters: {
      categoryId: "",
      keyword: "",
      onlyRedeemable: false,
    },
  },

  onLoad() {
    this.loadInitial();
  },

  onPullDownRefresh() {
    this.loadInitial().finally(() => wx.stopPullDownRefresh());
  },

  onReachBottom() {
    if (!this.data.hasMore || this.data.loading || this.data.loadingMore) return;
    this.loadRewards(false);
  },

  loadInitial() {
    this.setData({ loading: true, errorMessage: "" });
    return Promise.all([
      pointsApi.getBalance().catch(() => 0),
      rewardsApi.getCategories().catch(() => []),
    ])
      .then(([balance, categories]) => {
        this.setData({ balance, categories });
        return this.loadRewards(true);
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  loadRewards(reset) {
    const page = reset ? 0 : this.data.page + 1;
    const params = {
      page,
      size: this.data.size,
      onlyRedeemable: this.data.filters.onlyRedeemable,
    };
    if (this.data.filters.categoryId) params.categoryId = this.data.filters.categoryId;
    if (this.data.filters.keyword) params.keyword = this.data.filters.keyword;

    this.setData({
      loading: reset && !this.data.loading,
      loadingMore: !reset,
      errorMessage: "",
    });

    return rewardsApi
      .getRewardsPage(params, this.data.balance)
      .then((pageData) => {
        this.setData({
          rewards: reset ? pageData.items : this.data.rewards.concat(pageData.items),
          page: pageData.page,
          total: pageData.total,
          hasMore: pageData.hasMore,
          errorMessage: pageData.items.length || !reset ? "" : "暂无可兑换奖励",
        });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "积分商城加载失败",
          hasMore: false,
        });
      })
      .finally(() => {
        this.setData({ loading: false, loadingMore: false });
      });
  },

  selectCategory(event) {
    const categoryId = event.currentTarget.dataset.id || "";
    this.setData({ filters: { ...this.data.filters, categoryId } });
    this.loadRewards(true);
  },

  onKeywordInput(event) {
    this.setData({ filters: { ...this.data.filters, keyword: event.detail.value || "" } });
  },

  searchRewards() {
    this.loadRewards(true);
  },

  toggleRedeemable() {
    this.setData({
      filters: {
        ...this.data.filters,
        onlyRedeemable: !this.data.filters.onlyRedeemable,
      },
    });
    this.loadRewards(true);
  },

  exchange(event) {
    const rewardId = event.currentTarget.dataset.id;
    if (!rewardId || this.data.exchanging) return;

    this.setData({ exchanging: true });
    rewardsApi
      .previewExchange(rewardId)
      .then((preview) => {
        const content = `${preview.reward.name}\n当前 ${preview.balanceText}，兑换后 ${preview.afterBalanceText}`;
        if (!preview.canExchange) {
          wx.showToast({ title: preview.message || "当前不可兑换", icon: "none" });
          return Promise.reject({ handled: true });
        }

        return new Promise((resolve) => {
          wx.showModal({
            title: "确认兑换",
            content,
            confirmText: "兑换",
            success: resolve,
            fail: () => resolve({ confirm: false }),
          });
        }).then((result) => {
          if (!result.confirm) return Promise.reject({ handled: true });
          const user = getCurrentUser() || {};
          const requestId = `miniapp-${rewardId}-${Date.now()}-${Math.random().toString(16).slice(2)}`;
          return rewardsApi.exchangeReward({
            rewardId,
            requestId,
            receiverName: user.username || "",
            receiverPhone: user.phone || "",
            receiverAddress: "",
          });
        });
      })
      .then(() => {
        wx.showToast({ title: "兑换成功", icon: "success" });
        return pointsApi.getBalance().then((balance) => {
          this.setData({ balance });
          return this.loadRewards(true);
        });
      })
      .catch((error) => {
        if (error && error.handled) return;
        wx.showToast({ title: error.message || "兑换失败", icon: "none" });
      })
      .finally(() => {
        this.setData({ exchanging: false });
      });
  },

  openExchanges() {
    wx.navigateTo({ url: "/pages/exchanges/exchanges" });
  },

  openVouchers() {
    wx.navigateTo({ url: "/pages/vouchers/vouchers" });
  },
});
