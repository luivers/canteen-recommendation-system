const { normalizeDish, unwrapData } = require("./dish");

const STATUS_LABELS = {
  PENDING: "待支付",
  PAID: "已支付",
  PREPARING: "制作中",
  READY: "待取餐",
  COMPLETED: "已完成",
  CANCELLED: "已取消",
};

const PICKUP_TYPE_LABELS = {
  IMMEDIATE: "立即取餐",
  RESERVATION: "预约取餐",
};

const toArray = (value) => {
  if (Array.isArray(value)) return value;
  if (!value) return [];
  return [value];
};

const toNumber = (value, fallback = 0) => {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
};

const formatPrice = (value) => {
  const number = Number(value);
  if (!Number.isFinite(number)) return "￥0.00";
  return `￥${number.toFixed(2)}`;
};

const formatDateTime = (value) => {
  if (!value) return "";
  const text = String(value).replace("T", " ");
  return text.length > 16 ? text.slice(0, 16) : text;
};

const normalizeCartItem = (rawItem = {}) => {
  const item = unwrapData(rawItem) || {};
  const source = item.dish || item.combo || {};
  const price = item.price !== undefined ? item.price : source.price;
  const quantity = toNumber(item.quantity, 1);
  const subtotal = toNumber(price, 0) * quantity;
  const dish = normalizeDish(source);
  const isCombo = !!item.combo;

  return {
    id: item.id,
    dishId: item.dish ? item.dish.id : null,
    comboId: item.combo ? item.combo.id : null,
    name: source.name || dish.name || "未命名商品",
    imageUrl: dish.imageUrl,
    hasImage: dish.hasImage,
    categoryLabel: isCombo ? "套餐" : dish.categoryLabel,
    canteenName: dish.canteenName,
    windowName: isCombo ? "套餐" : dish.windowName,
    price: toNumber(price, 0),
    priceText: formatPrice(price),
    quantity,
    subtotal,
    subtotalText: formatPrice(subtotal),
    available: isCombo || dish.available,
    stockText: isCombo ? "套餐" : dish.stockText,
    isGift: !!item.isGift,
  };
};

const normalizeCart = (response) => {
  const items = toArray(unwrapData(response)).map(normalizeCartItem);
  const totalAmount = items.reduce((sum, item) => sum + item.subtotal, 0);

  return {
    items,
    totalAmount,
    totalAmountText: formatPrice(totalAmount),
    totalQuantity: items.reduce((sum, item) => sum + item.quantity, 0),
  };
};

const normalizeOrderItem = (rawItem = {}) => {
  const item = rawItem || {};
  const dish = normalizeDish(item.dish || {});
  const name = item.dishName || dish.name || "未知商品";
  const quantity = toNumber(item.quantity, 1);
  const unitPrice = item.unitPrice !== undefined ? item.unitPrice : item.price;
  const subtotal = item.subtotal !== undefined ? item.subtotal : toNumber(unitPrice, 0) * quantity;

  return {
    id: item.id,
    dishId: item.dish && item.dish.id,
    name,
    imageUrl: dish.imageUrl,
    hasImage: dish.hasImage,
    categoryLabel: dish.categoryLabel,
    canteenName: dish.canteenName,
    windowName: dish.windowName,
    quantity,
    unitPrice: toNumber(unitPrice, 0),
    unitPriceText: formatPrice(unitPrice),
    subtotal: toNumber(subtotal, 0),
    subtotalText: formatPrice(subtotal),
  };
};

const normalizeOrder = (rawOrder = {}) => {
  const order = unwrapData(rawOrder) || {};
  const items = toArray(order.items || order.orderItems).map(normalizeOrderItem);
  const status = order.status || "PENDING";
  const payable = order.payableAmount !== undefined && order.payableAmount !== null
    ? order.payableAmount
    : order.totalAmount;

  return {
    id: order.id || order.orderId,
    orderNumber: order.orderNumber || "",
    status,
    statusLabel: STATUS_LABELS[status] || status,
    cancellable: status === "PENDING" || status === "PAID",
    canConfirmPickup: status === "READY",
    isPendingPayment: status === "PENDING",
    isFinished: status === "COMPLETED" || status === "CANCELLED",
    totalAmount: toNumber(order.totalAmount, 0),
    totalAmountText: formatPrice(order.totalAmount),
    payableAmount: toNumber(payable, 0),
    payableAmountText: formatPrice(payable),
    voucherDeductionText: formatPrice(order.voucherDeduction),
    pickupType: order.pickupType || "IMMEDIATE",
    pickupTypeLabel: PICKUP_TYPE_LABELS[order.pickupType] || "立即取餐",
    pickupTimeText: formatDateTime(order.pickupTime || order.reservationTime),
    createdAtText: formatDateTime(order.createdAt || order.createTime),
    updatedAtText: formatDateTime(order.updateTime || order.completedAt || order.paymentTime),
    paymentMethod: order.paymentMethod || "",
    paymentTransactionId: order.paymentTransactionId || "",
    canteenName: order.canteenName || (items[0] && items[0].canteenName) || "",
    windowName: order.windowName || (items[0] && items[0].windowName) || "",
    remarks: order.remarks || "",
    items,
    itemSummary: items.map((item) => `${item.name} x${item.quantity}`).join("、"),
  };
};

const normalizeOrderPage = (response, fallbackPage = 0, fallbackSize = 10) => {
  const payload = unwrapData(response) || {};
  const content = Array.isArray(payload) ? payload : payload.content || payload.items || payload.records || [];
  const items = toArray(content).map(normalizeOrder);
  const page = toNumber(payload.number !== undefined ? payload.number : payload.page, fallbackPage);
  const size = toNumber(payload.size, fallbackSize);
  const totalElements = toNumber(
    payload.totalElements !== undefined ? payload.totalElements : payload.total,
    items.length,
  );
  const totalPages = toNumber(
    payload.totalPages,
    size > 0 ? Math.ceil(totalElements / size) : 0,
  );

  return {
    items,
    page,
    size,
    totalElements,
    totalPages,
    hasMore: totalPages ? page + 1 < totalPages : items.length >= size,
  };
};

module.exports = {
  STATUS_LABELS,
  formatDateTime,
  formatPrice,
  normalizeCart,
  normalizeCartItem,
  normalizeOrder,
  normalizeOrderPage,
};
