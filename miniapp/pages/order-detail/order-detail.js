const { orderApi, paymentApi, reviewApi } = require("../../api/index");
const { normalizeOrder } = require("../../utils/order");

const POLLING_INTERVAL = 5000;

const PAYMENT_METHOD_LABELS = {
  WECHAT: "微信支付",
  WECHAT_PAY: "微信支付",
  ALIPAY: "支付宝",
  CARD: "校园卡",
};

const PAYMENT_STATUS_LABELS = {
  CREATED: "支付已创建",
  PENDING: "待支付",
  PAID: "已支付",
  FAILED: "支付失败",
  CANCELLED: "已取消",
  UNKNOWN: "状态待确认",
};

const ORDER_STATUS_LABELS = {
  PENDING: "待支付",
  PAID: "已支付",
  PREPARING: "制作中",
  READY: "待取餐",
  COMPLETED: "已完成",
  CANCELLED: "已取消",
};

const unwrapData = (response) => {
  if (response && response.data !== undefined) return response.data;
  return response || {};
};

const firstValue = (...values) => {
  for (const value of values) {
    if (value !== undefined && value !== null && String(value).trim() !== "") {
      return value;
    }
  }
  return "";
};

const normalizeText = (value) => {
  if (value === undefined || value === null) return "";
  return String(value).trim();
};

const normalizePayParams = (payload = {}) => {
  const params = unwrapData(payload.miniProgramParams || payload.paymentParams || payload.payParams || {});
  const timeStamp = firstValue(params.timeStamp, params.timestamp, payload.timeStamp, payload.timestamp);
  const nonceStr = firstValue(params.nonceStr, params.nonce, payload.nonceStr, payload.nonce);
  const packageValue = firstValue(params.package, params.packageValue, params.prepayPackage, payload.package, payload.packageValue);
  const signType = firstValue(params.signType, payload.signType, "MD5");
  const paySign = firstValue(params.paySign, params.sign, payload.paySign, payload.sign);

  return {
    timeStamp: normalizeText(timeStamp),
    nonceStr: normalizeText(nonceStr),
    package: normalizeText(packageValue),
    signType: normalizeText(signType),
    paySign: normalizeText(paySign),
  };
};

const hasWechatPayParams = (params = {}) => {
  return !!(params.timeStamp && params.nonceStr && params.package && params.signType && params.paySign);
};

const normalizePaymentCreate = (response) => {
  const payload = unwrapData(response);
  const paramsSource = unwrapData(payload.miniProgramParams || payload.paymentParams || payload.payParams || {});
  const payParams = normalizePayParams(payload);
  const mode = normalizeText(payload.mode || paramsSource.mode).toLowerCase();
  const provider = normalizeText(payload.provider || paramsSource.provider);
  const isMock = paramsSource.mock === true || mode === "mock" || provider.toUpperCase() === "MOCK";

  return {
    raw: payload,
    mode,
    provider,
    orderNumber: normalizeText(payload.orderNumber || paramsSource.orderNumber),
    paymentMethod: normalizeText(payload.paymentMethod || paramsSource.paymentMethod || "WECHAT"),
    transactionId: normalizeText(payload.transactionId || paramsSource.transactionId),
    providerStatus: normalizeText(payload.status || payload.providerStatus),
    localStatus: normalizeText(payload.localStatus),
    payParams,
    hasWechatParams: hasWechatPayParams(payParams),
    isMock,
  };
};

const normalizePaymentQuery = (response, fallback = {}) => {
  const payload = unwrapData(response);
  return {
    mode: normalizeText(payload.mode || fallback.mode),
    provider: normalizeText(payload.provider || fallback.provider),
    orderNumber: normalizeText(payload.orderNumber || fallback.orderNumber),
    paymentMethod: normalizeText(payload.paymentMethod || fallback.paymentMethod),
    transactionId: normalizeText(payload.transactionId || fallback.transactionId),
    providerStatus: normalizeText(payload.providerStatus || fallback.providerStatus),
    localStatus: normalizeText(payload.localStatus || fallback.localStatus),
  };
};

const toPaymentSummary = (payment = {}) => {
  const providerStatus = normalizeText(payment.providerStatus);
  const localStatus = normalizeText(payment.localStatus);
  const paymentMethod = normalizeText(payment.paymentMethod);
  const provider = normalizeText(payment.provider);
  const mode = normalizeText(payment.mode);
  const localStatusText = ORDER_STATUS_LABELS[localStatus] || localStatus;
  const providerStatusText = PAYMENT_STATUS_LABELS[providerStatus] || providerStatus;

  return {
    statusText: localStatusText || providerStatusText,
    providerStatusText,
    showProviderStatus: !!providerStatusText && providerStatusText !== (localStatusText || providerStatusText),
    providerText: provider || (mode ? mode.toUpperCase() : ""),
    paymentMethodText: PAYMENT_METHOD_LABELS[paymentMethod] || paymentMethod,
    transactionId: normalizeText(payment.transactionId),
    localStatusText,
  };
};

const isPaymentCancel = (error = {}) => {
  const message = normalizeText(error.errMsg || error.message || error);
  return /cancel|取消/i.test(message);
};

const requestWechatPayment = (params) => {
  return new Promise((resolve, reject) => {
    wx.requestPayment({
      ...params,
      success: resolve,
      fail: (error) => {
        reject({
          cancelled: isPaymentCancel(error),
          message: isPaymentCancel(error) ? "已取消支付" : (error.errMsg || "支付失败"),
        });
      },
    });
  });
};

const showConfirmModal = (options) => {
  return new Promise((resolve) => {
    wx.showModal({
      ...options,
      success: resolve,
      fail: () => resolve({ confirm: false, cancel: true }),
    });
  });
};

Page({
  data: {
    id: "",
    order: null,
    loading: false,
    acting: false,
    errorMessage: "",
    lastPolledAt: "",
    paymentSummary: null,
    review: null,
    canReview: false,
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

    return Promise.all([
      orderApi.getOrder(this.data.id),
      reviewApi.getOrderReview(this.data.id).catch(() => null),
    ])
      .then(([response, review]) => {
        const order = normalizeOrder(response);
        const hasReview = !!(review && review.id);
        this.setData({
          order,
          review: hasReview ? review : null,
          canReview: ["PAID", "READY", "COMPLETED"].includes(order.status) && !hasReview,
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
    const order = this.data.order;
    if (!order || !order.isPendingPayment || this.data.acting) return;

    this.setData({ acting: true });
    paymentApi
      .createPayment(order.id, { paymentMethod: "WECHAT" })
      .then((response) => {
        const payment = normalizePaymentCreate(response);
        this.setData({ paymentSummary: toPaymentSummary(payment) });

        if (payment.hasWechatParams && !payment.isMock) {
          return this.handleWechatPayment(payment);
        }

        return this.handleMockPayment(payment);
      })
      .catch((error) => this.handlePaymentError(error))
      .finally(() => {
        this.setData({ acting: false });
      });
  },

  handleWechatPayment(payment) {
    return requestWechatPayment(payment.payParams)
      .then(() => {
        wx.showToast({ title: "支付完成", icon: "success" });
        return this.refreshPaymentStatus(payment);
      })
      .catch((error) => {
        if (error.cancelled) {
          wx.showToast({ title: "已取消支付", icon: "none" });
          return this.loadOrder(true);
        }
        throw error;
      });
  },

  handleMockPayment(payment) {
    if (!payment.isMock) {
      throw new Error("支付参数缺失，请稍后重试");
    }

    return showConfirmModal({
      title: "演示支付",
      content: "当前为 mock 支付，确认后将完成这笔订单支付。",
      confirmText: "确认支付",
      cancelText: "取消",
    }).then((result) => {
      if (!result.confirm) {
        throw { cancelled: true, message: "已取消支付" };
      }

      return paymentApi
        .completeMockPayment(this.data.order.id, {
          paymentMethod: payment.paymentMethod || "WECHAT",
          transactionId: payment.transactionId,
          paidAt: new Date().toISOString(),
        })
        .then((completion) => {
          const completedPayment = normalizePaymentQuery(completion, {
            ...payment,
            providerStatus: "PAID",
            localStatus: "PAID",
          });
          this.setData({ paymentSummary: toPaymentSummary(completedPayment) });
          wx.showToast({ title: "支付成功", icon: "success" });
          return this.refreshPaymentStatus(completedPayment);
        });
    });
  },

  refreshPaymentStatus(fallback = {}) {
    return paymentApi
      .queryPaymentStatus(this.data.order.id)
      .then((response) => {
        const payment = normalizePaymentQuery(response, fallback);
        this.setData({ paymentSummary: toPaymentSummary(payment) });
      })
      .catch((error) => {
        wx.showToast({
          title: error.message || "支付状态待确认",
          icon: "none",
        });
      })
      .then(() => this.loadOrder(true));
  },

  handlePaymentError(error = {}) {
    if (error.cancelled) {
      wx.showToast({
        title: error.message || "已取消支付",
        icon: "none",
      });
      this.loadOrder(true);
      return;
    }

    wx.showToast({
      title: error.message || "支付失败，请重试",
      icon: "none",
    });
  },

  reload() {
    this.loadOrder();
  },

  goReview() {
    if (!this.data.order || !this.data.canReview) return;
    wx.navigateTo({ url: `/pages/review-submit/review-submit?id=${this.data.order.id}` });
  },

  formatClock(date) {
    const pad = (value) => String(value).padStart(2, "0");
    return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
  },
});
