const { orderApi } = require("../../api/index");
const { normalizeOrderPage } = require("../../utils/order");

Page({
  data: {
    statusTabs: [
      { value: "", label: "全部" },
      { value: "PENDING", label: "待支付" },
      { value: "PAID", label: "已支付" },
      { value: "READY", label: "待取餐" },
      { value: "COMPLETED", label: "已完成" },
    ],
    activeStatus: "",
    orders: [],
    page: 0,
    size: 10,
    totalElements: 0,
    hasMore: false,
    loading: false,
    loadingMore: false,
    errorMessage: "",
  },

  onShow() {
    this.loadOrders(true);
  },

  onPullDownRefresh() {
    this.loadOrders(true).finally(() => {
      wx.stopPullDownRefresh();
    });
  },

  onReachBottom() {
    if (!this.data.hasMore || this.data.loading || this.data.loadingMore) return;
    this.loadOrders(false);
  },

  loadOrders(reset) {
    const page = reset ? 0 : this.data.page + 1;
    const params = {
      page,
      size: this.data.size,
    };
    if (this.data.activeStatus) {
      params.status = this.data.activeStatus;
    }

    this.setData({
      loading: reset,
      loadingMore: !reset,
      errorMessage: "",
    });

    return orderApi
      .getOrders(params)
      .then((response) => {
        const pageData = normalizeOrderPage(response, page, this.data.size);
        this.setData({
          orders: reset ? pageData.items : this.data.orders.concat(pageData.items),
          page: pageData.page,
          totalElements: pageData.totalElements,
          hasMore: pageData.hasMore,
          errorMessage: pageData.items.length || !reset ? "" : "暂无订单",
        });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "订单加载失败",
          hasMore: false,
        });
      })
      .finally(() => {
        this.setData({
          loading: false,
          loadingMore: false,
        });
      });
  },

  selectStatus(event) {
    const value = event.currentTarget.dataset.value || "";
    if (value === this.data.activeStatus) return;
    this.setData({ activeStatus: value });
    this.loadOrders(true);
  },

  openOrder(event) {
    const id = event.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/order-detail/order-detail?id=${id}` });
  },
});
