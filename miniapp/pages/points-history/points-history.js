const { pointsApi } = require("../../api/index");

Page({
  data: {
    logs: [],
    page: 0,
    size: 20,
    total: 0,
    hasMore: false,
    loading: false,
    loadingMore: false,
    errorMessage: "",
  },

  onLoad() {
    this.loadLogs(true);
  },

  onPullDownRefresh() {
    this.loadLogs(true).finally(() => wx.stopPullDownRefresh());
  },

  onReachBottom() {
    if (!this.data.hasMore || this.data.loading || this.data.loadingMore) return;
    this.loadLogs(false);
  },

  loadLogs(reset) {
    const page = reset ? 0 : this.data.page + 1;
    this.setData({
      loading: reset,
      loadingMore: !reset,
      errorMessage: "",
    });

    return pointsApi
      .getMyHistory({ page, size: this.data.size })
      .then((pageData) => {
        this.setData({
          logs: reset ? pageData.items : this.data.logs.concat(pageData.items),
          page: pageData.page,
          total: pageData.total,
          hasMore: pageData.hasMore,
          errorMessage: pageData.items.length || !reset ? "" : "暂无积分流水",
        });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "积分流水加载失败",
          hasMore: false,
        });
      })
      .finally(() => {
        this.setData({ loading: false, loadingMore: false });
      });
  },
});
