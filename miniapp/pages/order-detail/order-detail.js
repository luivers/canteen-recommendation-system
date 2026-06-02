const { orderApi } = require("../../api/index");
const { normalizeOrder } = require("../../utils/order");

const POLLING_INTERVAL = 5000;

Page({
  data: {
    id: "",
    order: null,
    loading: false,
    acting: false,
    errorMessage: "",
    lastPolledAt: "",
  },

  pollTimer: null,

  onLoad(options = {}) {
    if (!options.id) {
      this.setData({ errorMessage: "缺少订单 ID" });
      return;
    }

    this.setData({ id: options.id });
    this.loadOrder();
  },

  onShow() {
    this.startPolling();
  },

  onHide() {
    this.stopPolling();
  },

  onUnload() {
    this.stopPolling();
  },

  onPullDownRefresh() {
    this.loadOrder().finally(() => {
      wx.stopPullDownRefresh();
    });
  },

  loadOrder(silent = false) {
    if (!this.data.id) return Promise.resolve();
    if (!silent) {
      this.setData({ loading: true, errorMessage: "" });
    }

    return orderApi
      .getOrder(this.data.id)
      .then((response) => {
        const order = normalizeOrder(response);
        this.setData({
          order,
          lastPolledAt: this.formatClock(new Date()),
          errorMessage: "",
        });
        if (order.isFinished) {
          this.stopPolling();
        } else {
          this.startPolling();
        }
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "订单详情加载失败",
        });
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  startPolling() {
    if (!this.data.id || this.pollTimer) return;
    this.pollTimer = setInterval(() => {
      this.loadOrder(true);
    }, POLLING_INTERVAL);
  },

  stopPolling() {
    if (!this.pollTimer) return;
    clearInterval(this.pollTimer);
    this.pollTimer = null;
  },

  cancelOrder() {
    if (!this.data.order || !this.data.order.cancellable || this.data.acting) return;

    wx.showModal({
      title: "取消订单",
      content: "确定取消这笔订单吗？",
      success: (result) => {
        if (!result.confirm) return;
        this.setData({ acting: true });
        orderApi
          .cancelOrder(this.data.order.id)
          .then(() => this.loadOrder())
          .catch((error) => {
            wx.showToast({
              title: error.message || "取消失败",
              icon: "none",
            });
          })
          .finally(() => {
            this.setData({ acting: false });
          });
      },
    });
  },

  confirmPickup() {
    if (!this.data.order || !this.data.order.canConfirmPickup || this.data.acting) return;

    this.setData({ acting: true });
    orderApi
      .confirmPickup(this.data.order.id)
      .then(() => this.loadOrder())
      .catch((error) => {
        wx.showToast({
          title: error.message || "确认失败",
          icon: "none",
        });
      })
      .finally(() => {
        this.setData({ acting: false });
      });
  },

  goPay() {
    wx.showToast({
      title: "支付会在 ST-015 接入",
      icon: "none",
    });
  },

  reload() {
    this.loadOrder();
  },

  formatClock(date) {
    const pad = (value) => String(value).padStart(2, "0");
    return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
  },
});
