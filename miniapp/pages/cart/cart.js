const { orderApi } = require("../../api/index");
const { normalizeCart } = require("../../utils/order");

Page({
  data: {
    cartItems: [],
    totalAmountText: "￥0.00",
    totalQuantity: 0,
    pickupType: "IMMEDIATE",
    reservationTime: "",
    remarks: "",
    loading: false,
    submitting: false,
    errorMessage: "",
  },

  onShow() {
    this.loadCart();
  },

  onPullDownRefresh() {
    this.loadCart().finally(() => {
      wx.stopPullDownRefresh();
    });
  },

  loadCart() {
    this.setData({ loading: true, errorMessage: "" });
    return orderApi
      .getCart()
      .then((response) => {
        const cart = normalizeCart(response);
        this.setData({
          cartItems: cart.items,
          totalAmountText: cart.totalAmountText,
          totalQuantity: cart.totalQuantity,
          errorMessage: cart.items.length ? "" : "购物车还是空的",
        });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "购物车加载失败",
        });
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  updateQuantity(event) {
    const id = event.currentTarget.dataset.id;
    const nextQuantity = Number(event.currentTarget.dataset.quantity);
    if (!id || !Number.isFinite(nextQuantity) || nextQuantity <= 0) return;

    orderApi
      .updateCartItem(id, nextQuantity)
      .then(() => this.loadCart())
      .catch((error) => {
        wx.showToast({
          title: error.message || "数量更新失败",
          icon: "none",
        });
      });
  },

  removeItem(event) {
    const id = event.currentTarget.dataset.id;
    if (!id) return;

    wx.showModal({
      title: "移除商品",
      content: "确定从购物车移除这件商品吗？",
      success: (result) => {
        if (!result.confirm) return;
        orderApi
          .removeCartItem(id)
          .then(() => this.loadCart())
          .catch((error) => {
            wx.showToast({
              title: error.message || "移除失败",
              icon: "none",
            });
          });
      },
    });
  },

  clearCart() {
    if (!this.data.cartItems.length) return;

    wx.showModal({
      title: "清空购物车",
      content: "确定清空全部商品吗？",
      success: (result) => {
        if (!result.confirm) return;
        orderApi
          .clearCart()
          .then(() => this.loadCart())
          .catch((error) => {
            wx.showToast({
              title: error.message || "清空失败",
              icon: "none",
            });
          });
      },
    });
  },

  setPickupType(event) {
    this.setData({
      pickupType: event.currentTarget.dataset.type || "IMMEDIATE",
    });
  },

  onReservationTimeChange(event) {
    this.setData({ reservationTime: event.detail.value });
  },

  onRemarksInput(event) {
    this.setData({ remarks: event.detail.value });
  },

  createOrder() {
    if (!this.data.cartItems.length || this.data.submitting) return;

    const payload = {
      pickupType: this.data.pickupType,
      remarks: this.data.remarks.trim(),
      items: this.data.cartItems.map((item) => {
        const payloadItem = {
          quantity: item.quantity,
          isGift: item.isGift,
        };
        if (item.comboId) {
          payloadItem.comboId = item.comboId;
        } else {
          payloadItem.dishId = item.dishId;
        }
        return payloadItem;
      }),
    };

    if (this.data.pickupType === "RESERVATION" && this.data.reservationTime) {
      const now = new Date();
      const pad = (value) => String(value).padStart(2, "0");
      const date = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
      payload.reservationTime = `${date} ${this.data.reservationTime}`;
    }

    this.setData({ submitting: true });
    orderApi
      .createOrder(payload)
      .then((response) => {
        const orderId = response.orderId || response.id;
        wx.showToast({
          title: "下单成功",
          icon: "success",
        });
        orderApi.clearCart().finally(() => {
          if (orderId) {
            wx.navigateTo({ url: `/pages/order-detail/order-detail?id=${orderId}` });
          } else {
            wx.switchTab({ url: "/pages/orders/orders" });
          }
        });
      })
      .catch((error) => {
        wx.showToast({
          title: error.message || "下单失败",
          icon: "none",
        });
      })
      .finally(() => {
        this.setData({ submitting: false });
      });
  },

  goDishes() {
    wx.switchTab({ url: "/pages/dishes/dishes" });
  },
});
