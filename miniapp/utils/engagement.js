const { formatDateTime, formatPrice } = require("./order");

const unwrapData = (response) => {
  if (response && response.data !== undefined) return response.data;
  return response || {};
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

const normalizePage = (response, mapper, fallbackPage = 0, fallbackSize = 20) => {
  const payload = unwrapData(response) || {};
  const content = Array.isArray(payload) ? payload : payload.content || payload.items || payload.records || payload.data || [];
  const items = toArray(content).map(mapper);
  const page = toNumber(payload.number !== undefined ? payload.number : payload.page, fallbackPage);
  const size = toNumber(payload.size, fallbackSize);
  const total = toNumber(
    payload.totalElements !== undefined ? payload.totalElements : payload.total,
    response && response.total !== undefined ? response.total : items.length,
  );
  const totalPages = toNumber(
    payload.totalPages !== undefined ? payload.totalPages : response && response.totalPages,
    size > 0 ? Math.ceil(total / size) : 0,
  );

  return {
    items,
    page,
    size,
    total,
    totalPages,
    hasMore: totalPages ? page + 1 < totalPages : items.length >= size,
  };
};

const REVIEW_STATUS_LABELS = {
  PENDING: "待审核",
  APPROVED: "已展示",
  REJECTED: "未通过",
  HIDDEN: "已隐藏",
};

const EXCHANGE_STATUS_LABELS = {
  PENDING: "处理中",
  COMPLETED: "已完成",
  CANCELLED: "已取消",
  FAILED: "失败",
};

const REWARD_STATUS_LABELS = {
  AVAILABLE: "可兑换",
  OUT_OF_STOCK: "缺货",
  DISCONTINUED: "已下架",
  DELETED: "已删除",
};

const POINT_SOURCE_LABELS = {
  REVIEW_REWARD: "评价奖励",
  EXCHANGE: "积分兑换",
  ORDER: "订单消费",
  OTHER: "其他",
};

const averageRating = (review = {}) => {
  const ratings = [
    review.tasteRating,
    review.portionRating,
    review.priceRating,
    review.hygieneRating,
    review.rating,
  ].map((value) => Number(value)).filter((value) => Number.isFinite(value) && value > 0);
  if (!ratings.length) return 0;
  return Math.round((ratings.reduce((sum, value) => sum + value, 0) / ratings.length) * 10) / 10;
};

const normalizeReview = (rawReview = {}) => {
  const review = unwrapData(rawReview) || {};
  const order = review.order || {};
  const user = review.user || {};
  const rating = averageRating(review);
  const comment = review.comment || review.content || "";
  const status = review.status || "";

  return {
    id: review.id || review.reviewId,
    orderId: review.orderId || order.id,
    orderNumber: review.orderNumber || order.orderNumber || "",
    username: review.username || user.username || "",
    rating,
    ratingText: rating ? `${rating} 分` : "未评分",
    tasteRating: toNumber(review.tasteRating, rating || 5),
    portionRating: toNumber(review.portionRating, rating || 5),
    priceRating: toNumber(review.priceRating, rating || 5),
    hygieneRating: toNumber(review.hygieneRating, rating || 5),
    comment,
    summary: comment || "暂无文字评价",
    quickTags: toArray(review.quickTags),
    quickTagsText: toArray(review.quickTags).join("、"),
    reply: review.reply || review.merchantReply || "",
    status,
    statusLabel: REVIEW_STATUS_LABELS[status] || status || "已提交",
    createdAtText: formatDateTime(review.createTime || review.createdAt),
  };
};

const normalizePointBalance = (response) => {
  const data = unwrapData(response) || {};
  return toNumber(data.points !== undefined ? data.points : data.balance, 0);
};

const normalizePointLog = (rawLog = {}) => {
  const log = unwrapData(rawLog) || {};
  const points = toNumber(log.points, 0);
  const type = log.type || (points < 0 ? "SPEND" : "EARN");
  const source = log.source || "OTHER";

  return {
    id: log.id,
    points,
    pointsText: `${points > 0 ? "+" : ""}${points}`,
    isEarn: type === "EARN" || points > 0,
    type,
    source,
    sourceLabel: POINT_SOURCE_LABELS[source] || source,
    description: log.description || POINT_SOURCE_LABELS[source] || "积分变动",
    createdAtText: formatDateTime(log.createTime || log.createdAt),
  };
};

const normalizeRewardCategory = (rawCategory = {}) => {
  const category = unwrapData(rawCategory) || {};
  return {
    id: category.id || category.categoryId,
    name: category.name || category.categoryName || "未分类",
  };
};

const normalizeReward = (rawReward = {}, currentPoints = 0) => {
  const reward = unwrapData(rawReward) || {};
  const category = reward.category || {};
  const pointsRequired = toNumber(reward.pointsRequired, 0);
  const stock = toNumber(reward.stock, 0);
  const status = reward.status || "AVAILABLE";
  const exchangeEnabled = reward.exchangeEnabled !== false;
  const canExchange = status === "AVAILABLE" && exchangeEnabled && stock > 0 && toNumber(currentPoints, 0) >= pointsRequired;

  return {
    id: reward.id || reward.rewardId,
    name: reward.name || "未命名奖励",
    description: reward.description || "",
    imageUrl: reward.imageUrl || "",
    hasImage: !!reward.imageUrl,
    categoryName: category.name || reward.categoryName || "未分类",
    type: reward.type || "VOUCHER",
    typeLabel: reward.type === "OTHER" ? "实物/其他" : "代金券",
    pointsRequired,
    pointsText: `${pointsRequired} 积分`,
    stock,
    stockText: stock > 0 ? `库存 ${stock}` : "已兑完",
    faceValue: reward.faceValue,
    faceValueText: reward.faceValue !== undefined && reward.faceValue !== null ? formatPrice(reward.faceValue) : "",
    minOrderAmountText: reward.minOrderAmount !== undefined && reward.minOrderAmount !== null ? `满 ${formatPrice(reward.minOrderAmount)} 可用` : "无门槛",
    validText: reward.validTo ? `有效至 ${formatDateTime(reward.validTo)}` : "长期有效",
    status,
    statusLabel: REWARD_STATUS_LABELS[status] || status,
    exchangeEnabled,
    canExchange,
  };
};

const normalizeExchange = (rawExchange = {}) => {
  const exchange = unwrapData(rawExchange) || {};
  const reward = normalizeReward(exchange.reward || {});
  const status = exchange.status || "PENDING";

  return {
    id: exchange.id || exchange.exchangeId,
    rewardId: reward.id,
    rewardName: reward.name,
    reward,
    status,
    statusLabel: EXCHANGE_STATUS_LABELS[status] || status,
    pointsUsed: toNumber(exchange.pointsUsed, reward.pointsRequired),
    pointsText: `${toNumber(exchange.pointsUsed, reward.pointsRequired)} 积分`,
    used: !!exchange.used,
    usedText: exchange.used ? "已使用" : "未使用",
    faceValueText: exchange.faceValueSnapshot !== undefined && exchange.faceValueSnapshot !== null
      ? formatPrice(exchange.faceValueSnapshot)
      : reward.faceValueText,
    deductionAmountText: exchange.deductionAmount !== undefined && exchange.deductionAmount !== null
      ? formatPrice(exchange.deductionAmount)
      : "",
    exchangeTimeText: formatDateTime(exchange.exchangeTime || exchange.createTime),
    completeTimeText: formatDateTime(exchange.completeTime),
    receiverName: exchange.receiverName || "",
    receiverPhone: exchange.receiverPhone || "",
  };
};

const normalizeExchangePreview = (response) => {
  const data = unwrapData(response) || {};
  const reward = normalizeReward(data.reward || data);
  const balance = toNumber(data.balance !== undefined ? data.balance : data.currentPoints, 0);
  const afterBalance = toNumber(data.afterBalance !== undefined ? data.afterBalance : balance - reward.pointsRequired, balance);
  const canExchange = data.canExchange !== undefined ? !!data.canExchange : afterBalance >= 0 && reward.stock > 0;

  return {
    reward,
    balance,
    balanceText: `${balance} 积分`,
    afterBalance,
    afterBalanceText: `${afterBalance} 积分`,
    canExchange,
    message: data.message || (canExchange ? "" : "当前不可兑换"),
  };
};

module.exports = {
  normalizeExchange,
  normalizeExchangePreview,
  normalizePage,
  normalizePointBalance,
  normalizePointLog,
  normalizeReview,
  normalizeReward,
  normalizeRewardCategory,
  toArray,
  toNumber,
  unwrapData,
};
