const { rewardsApi } = require("../../api/index");

Page({
  data: {
    statusTabs: [
      { value: "", label: "全部" },
      { value: "PENDING", label: "处理中" },
      { value: "COMPLETED", label: "已完成" },
      { value: "FAILED", label: "失败" },
    ],
    activeStatus: "",
    exchanges: [],
    page: 0,
    size: 20,
    total: 0,
    hasMore: false,
    loading: false,
    loadingMore: false,
    errorMessage: "",
  },

  onLoad() {
    this.loadExchanges(true);
  },

  onPullDownRefresh() {
    this.loadExchanges(true).finally(() => wx.stopPullDownRefresh());
  },

  onReachBottom() {
    if (!this.data.hasMore || this.data.loading || this.data.loadingMore) return;
    this.loadExchanges(false);
  },

  loadExchanges(reset) {
    const page = reset ? 0 : this.data.page + 1;
    const params = { page, size: this.data.size };
    if (this.data.activeStatus) params.status = this.data.activeStatus;

    this.setData({ loading: reset, loadingMore: !reset, errorMessage: "" });
    return rewardsApi
      .getMyExchangesPage(params)
      .then((pageData) => {
        this.setData({
          exchanges: reset ? pageData.items : this.data.exchanges.concat(pageData.items),
          page: pageData.page,
          total: pageData.total,
          hasMore: pageData.hasMore,
          errorMessage: pageData.items.length || !reset ? "" : "暂无兑换记录",
        });
      })
      .catch((error) => {
        this.setData({ errorMessage: error.message || "兑换记录加载失败", hasMore: false });
      })
      .finally(() => {
        this.setData({ loading: false, loadingMore: false });
      });
  },

  selectStatus(event) {
    const value = event.currentTarget.dataset.value || "";
    if (value === this.data.activeStatus) return;
    this.setData({ activeStatus: value });
    this.loadExchanges(true);
  },
});
