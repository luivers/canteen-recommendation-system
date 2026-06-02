const CATEGORY_LABELS = {
  MAIN_DISH: "主食",
  MEAT_DISH: "荤菜",
  VEGETABLE: "素菜",
  VEGETABLE_DISH: "素菜",
  SOUP: "汤类",
  SNACK: "小吃",
  BEVERAGE: "饮品",
  SIDE_DISH: "菜品",
};

const STATUS_LABELS = {
  AVAILABLE: "在售",
  SOLD_OUT: "售罄",
  DISCONTINUED: "下架",
  DELETED: "已删除",
};

const CATEGORY_VALUES_BY_LABEL = {
  主食: "MAIN_DISH",
  荤菜: "MEAT_DISH",
  素菜: "VEGETABLE",
  菜品: "SIDE_DISH",
  汤类: "SOUP",
  小吃: "SNACK",
  饮品: "BEVERAGE",
};

const unwrapData = (response) => {
  if (!response || typeof response !== "object") return response;
  if (Object.prototype.hasOwnProperty.call(response, "data")) {
    return response.data;
  }
  return response;
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
  if (value === null || value === undefined || value === "") return "价格待定";
  const number = Number(value);
  if (!Number.isFinite(number)) return `￥${value}`;
  return `￥${number.toFixed(2)}`;
};

const normalizeCategory = (dish) => {
  const raw = dish.dishCategory || dish.category || "";
  return {
    value: raw,
    label: CATEGORY_LABELS[raw] || raw || "未分类",
  };
};

const normalizeStatus = (status) => {
  const value = status || "AVAILABLE";
  return {
    value,
    label: STATUS_LABELS[value] || value,
    available: value === "AVAILABLE",
  };
};

const normalizeTags = (dish) => {
  const tags = dish.healthTags && dish.healthTags.length ? dish.healthTags : dish.tasteTags;
  return toArray(tags).filter(Boolean).slice(0, 4);
};

const normalizeDish = (rawDish = {}, extra = {}) => {
  const dish = unwrapData(rawDish) || {};
  const category = normalizeCategory(dish);
  const status = normalizeStatus(dish.status);
  const promotionPrice = dish.promotionPrice;
  const hasPromotion = promotionPrice !== null && promotionPrice !== undefined && promotionPrice !== "";
  const stock = dish.stock;
  const salesCount = toNumber(
    dish.salesCount !== undefined ? dish.salesCount : dish.sales,
    0,
  );
  const averageRating = toNumber(dish.averageRating, 0);
  const ratingCount = toNumber(dish.ratingCount, 0);
  const tags = normalizeTags(dish);
  const reasonText =
    extra.reasonText ||
    dish.reasonLabel ||
    dish.reason ||
    dish.recommendReason ||
    (tags.length ? tags.join(" / ") : "");

  return {
    id: dish.id,
    name: dish.name || "未命名菜品",
    description: dish.description || "暂无菜品介绍",
    imageUrl: dish.imageUrl || "",
    hasImage: !!dish.imageUrl,
    price: dish.price,
    priceText: formatPrice(hasPromotion ? promotionPrice : dish.price),
    originalPriceText: hasPromotion ? formatPrice(dish.price) : "",
    hasPromotion,
    category: category.value,
    categoryLabel: category.label,
    canteenName: dish.canteenName || "食堂待定",
    windowName: dish.windowName || "窗口待定",
    windowLocation: dish.windowLocation || "",
    tags,
    status: status.value,
    statusLabel: status.label,
    available: status.available && stock !== 0,
    stock,
    stockText: stock === null || stock === undefined ? "库存待定" : stock > 0 ? `库存 ${stock}` : "已售罄",
    salesCount,
    salesText: salesCount > 0 ? `月售 ${salesCount}` : "暂无销量",
    averageRating,
    ratingText: averageRating > 0 ? averageRating.toFixed(1) : "暂无评分",
    ratingCount,
    calories: dish.calories,
    protein: dish.protein,
    fat: dish.fat,
    carbohydrate: dish.carbohydrate,
    caloriesText: dish.calories ? `${dish.calories} kcal` : "待补充",
    proteinText: dish.protein ? `${dish.protein}g` : "待补充",
    fatText: dish.fat ? `${dish.fat}g` : "待补充",
    carbohydrateText: dish.carbohydrate ? `${dish.carbohydrate}g` : "待补充",
    fitPercent: dish.fitPercent,
    fitPercentText: dish.fitPercent ? `${dish.fitPercent}% 匹配` : "",
    nutritionScore: dish.nutritionScore,
    reasonText,
  };
};

const normalizeDishPage = (response, fallbackPage = 0, fallbackSize = 12) => {
  const payload = unwrapData(response);
  const pageData = Array.isArray(payload) ? { content: payload } : payload || {};
  const content = pageData.content || pageData.items || pageData.records || pageData.list || [];
  const items = toArray(content).map((dish) => normalizeDish(dish));
  const page = toNumber(pageData.number !== undefined ? pageData.number : pageData.page, fallbackPage);
  const size = toNumber(pageData.size, fallbackSize);
  const totalElements = toNumber(
    pageData.totalElements !== undefined ? pageData.totalElements : pageData.total,
    items.length,
  );
  const totalPages = toNumber(
    pageData.totalPages,
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

const normalizeDishList = (response) => {
  const payload = unwrapData(response);
  if (Array.isArray(payload)) return payload.map((dish) => normalizeDish(dish));
  if (payload && Array.isArray(payload.recommendations)) {
    return payload.recommendations.map((dish) => normalizeDish(dish));
  }
  if (payload && Array.isArray(payload.content)) return payload.content.map((dish) => normalizeDish(dish));
  return [];
};

const normalizeRecommendationWithReasons = (response) => {
  const payload = unwrapData(response);
  return toArray(payload).map((item) => {
    const dish = item.dish || item;
    const reasonText = item.reasonLabel || item.reason || item.recommendReason || dish.reasonLabel || "";
    return normalizeDish(dish, { reasonText });
  });
};

const normalizeCategories = (response) => {
  const categories = toArray(unwrapData(response));
  return categories
    .filter(Boolean)
    .map((category) => ({
      value: CATEGORY_VALUES_BY_LABEL[category] || category,
      label: CATEGORY_LABELS[category] || category,
    }));
};

module.exports = {
  CATEGORY_LABELS,
  normalizeCategories,
  normalizeDish,
  normalizeDishList,
  normalizeDishPage,
  normalizeRecommendationWithReasons,
  unwrapData,
};
