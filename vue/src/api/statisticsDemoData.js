const enabledValues = new Set(["1", "true", "yes", "on", "mock", "demo"]);

export const isAdminStatisticsDemoEnabled = () => {
  const value = String(import.meta.env.VITE_ADMIN_DEMO_DATA || "")
    .trim()
    .toLowerCase();
  return enabledValues.has(value);
};

const response = (data) =>
  Promise.resolve({
    data,
    status: 200,
    statusText: "OK",
    headers: {},
    config: { demo: true },
  });

const dishNames = [
  "香菇滑鸡饭",
  "番茄牛腩面",
  "黑椒鸡排",
  "清炒时蔬",
  "麻婆豆腐",
  "玉米排骨汤",
  "鸡蛋灌饼",
  "柠檬茶",
];

const categories = ["MAIN_DISH", "MEAT_DISH", "VEGETABLE", "SOUP", "SNACK", "DRINK"];

const buildDailyRows = (days = 14) => {
  const rows = [];
  const today = new Date();
  for (let i = days - 1; i >= 0; i -= 1) {
    const date = new Date(today);
    date.setDate(today.getDate() - i);
    const label = `${date.getMonth() + 1}-${date.getDate()}`;
    const base = days - i;
    rows.push({
      time: label,
      date: label,
      value: 900 + base * 86 + (base % 4) * 130,
      orderCount: 42 + base * 3 + (base % 3) * 7,
      orderAmount: 900 + base * 86 + (base % 4) * 130,
      MAIN_DISH: 420 + base * 18,
      MEAT_DISH: 360 + base * 22,
      VEGETABLE: 180 + base * 12,
      SOUP: 120 + base * 8,
      SNACK: 90 + base * 7,
      DRINK: 160 + base * 10,
    });
  }
  return rows;
};

const dailyRows = buildDailyRows();

const dishSalesByPeriod = dailyRows.slice(-7).map((row, index) => ({
  time: row.time,
  top: dishNames.slice(0, 6).map((name, dishIndex) => ({
    name,
    qty: 90 - dishIndex * 9 + index * 4,
    value: 90 - dishIndex * 9 + index * 4,
  })),
}));

const dishRatingRanking = dishNames.slice(0, 7).map((name, index) => ({
  name,
  value: Number((4.8 - index * 0.09).toFixed(1)),
  reviewCount: 88 - index * 6,
  ratingCount: 102 - index * 7,
}));

const dishTrendRanking = dishNames.slice(0, 6).map((name, index) => ({
  name,
  growthRate: [32, 26, 18, 12, -6, -11][index],
  current: 180 - index * 13,
  previous: 136 - index * 9,
}));

const dishCategoryRanking = [
  {
    category: "主食",
    top: [
      { name: "香菇滑鸡饭", value: 286 },
      { name: "番茄牛腩面", value: 241 },
      { name: "鸡蛋灌饼", value: 198 },
    ],
  },
  {
    category: "荤菜",
    top: [
      { name: "黑椒鸡排", value: 260 },
      { name: "糖醋里脊", value: 223 },
      { name: "红烧鸡腿", value: 204 },
    ],
  },
  {
    category: "素菜",
    top: [
      { name: "清炒时蔬", value: 190 },
      { name: "麻婆豆腐", value: 172 },
      { name: "蒜蓉西兰花", value: 151 },
    ],
  },
];

const activePeriods = Array.from({ length: 24 }, (_, hour) => {
  const peak =
    hour >= 11 && hour <= 13
      ? 180
      : hour >= 17 && hour <= 19
        ? 150
        : hour >= 7 && hour <= 8
          ? 86
          : 22;
  return { time: `${hour}-${hour + 1}`, value: peak + (hour % 3) * 8 };
});

const reviewKeywords = {
  totalReviews: 326,
  matchedReviews: 291,
  keywords: [
    { name: "好吃", value: 88 },
    { name: "分量足", value: 66 },
    { name: "出餐快", value: 52 },
    { name: "实惠", value: 48 },
    { name: "新鲜", value: 43 },
    { name: "偏咸", value: 24 },
    { name: "排队", value: 22 },
    { name: "香", value: 57 },
  ],
  sampleReviews: [],
};

const dishFeaturesWordcloud = {
  version: 2026060701,
  matchedReviews: 291,
  coveredDishes: 42,
  keywords: [
    { name: "鲜香", value: 88, category: "TASTE", breakdown: { reviewHits: 71 } },
    { name: "酱香", value: 64, category: "AROMA", breakdown: { reviewHits: 43 } },
    { name: "软糯", value: 52, category: "TEXTURE", breakdown: { reviewHits: 37 } },
    { name: "清爽", value: 48, category: "TASTE", breakdown: { reviewHits: 34 } },
    { name: "酥脆", value: 44, category: "TEXTURE", breakdown: { reviewHits: 29 } },
    { name: "番茄", value: 40, category: "INGREDIENT", breakdown: { reviewHits: 25 } },
    { name: "现炒", value: 36, category: "COOKING_METHOD", breakdown: { reviewHits: 21 } },
    { name: "新鲜", value: 34, category: "FRESHNESS", breakdown: { reviewHits: 20 } },
  ],
};

const featureDishes = [
  { name: "香菇滑鸡饭", windowName: "一食堂二楼", salesCount: 286, reviewHitCount: 42, averageRating: 4.7 },
  { name: "番茄牛腩面", windowName: "风味面档", salesCount: 241, reviewHitCount: 35, averageRating: 4.6 },
  { name: "黑椒鸡排", windowName: "铁板窗口", salesCount: 260, reviewHitCount: 38, averageRating: 4.5 },
];

const segmentation = {
  summary: {
    totalUsers: 1268,
    avgSpent: 68.4,
    avgOrders: 4.7,
    avgRecency: 5.8,
  },
  segments: [
    { code: "VIP", count: 128, metrics: { avgSpend: 188.5, avgOrders: 11.2, avgRecencyDays: 1.9 } },
    { code: "ACTIVE", count: 416, metrics: { avgSpend: 92.3, avgOrders: 6.4, avgRecencyDays: 3.8 } },
    { code: "NEW", count: 202, metrics: { avgSpend: 34.7, avgOrders: 2.1, avgRecencyDays: 2.4 } },
    { code: "RISK", count: 167, metrics: { avgSpend: 58.9, avgOrders: 3.2, avgRecencyDays: 18.6 } },
    { code: "NORMAL", count: 355, metrics: { avgSpend: 46.2, avgOrders: 3.0, avgRecencyDays: 8.4 } },
  ],
};

const segmentUsers = {
  content: [
    { username: "student_demo_01", totalSpent: 268.5, orderCount: 13, recencyDays: 1, lastTime: "2026-06-07T12:16:00" },
    { username: "student_demo_02", totalSpent: 218.0, orderCount: 10, recencyDays: 2, lastTime: "2026-06-06T18:40:00" },
    { username: "student_demo_03", totalSpent: 176.5, orderCount: 8, recencyDays: 3, lastTime: "2026-06-05T11:35:00" },
  ],
  totalElements: 3,
  total: 3,
};

const comparison = {
  metrics1: { revenue: 12860.5, orders: 586, avgOrderValue: 21.95 },
  metrics2: { revenue: 15180.0, orders: 674, avgOrderValue: 22.52 },
  metrics: {
    revenue: { deltaPct: 18.0 },
    orders: { deltaPct: 15.0 },
    avgOrderValue: { deltaPct: 2.6 },
  },
  breakdowns: {
    byCategory: [
      { name: "荤菜", a: 4200, b: 5100, delta: 900, deltaPct: 21.4 },
      { name: "主食", a: 3600, b: 4100, delta: 500, deltaPct: 13.9 },
      { name: "饮品", a: 1200, b: 980, delta: -220, deltaPct: -18.3 },
    ],
    byWindow: [
      { name: "一食堂二楼", a: 4600, b: 5300, delta: 700, deltaPct: 15.2 },
      { name: "风味面档", a: 3200, b: 3900, delta: 700, deltaPct: 21.9 },
    ],
    byDish: [
      { name: "香菇滑鸡饭", a: 1280, b: 1680, delta: 400, deltaPct: 31.3 },
      { name: "番茄牛腩面", a: 1160, b: 1420, delta: 260, deltaPct: 22.4 },
    ],
  },
};

const inventoryWarnings = [
  {
    dishName: "香菇滑鸡饭",
    date: "2026-06-07",
    sales: 182,
    stock: 18,
    totalSupply: 200,
    ratio: 0.91,
    alertMessage: "午餐高峰后库存偏低，建议晚餐前补货",
  },
  {
    dishName: "番茄牛腩面",
    date: "2026-06-07",
    sales: 146,
    stock: 34,
    totalSupply: 180,
    ratio: 0.81,
    alertMessage: "销量接近预警线",
  },
];

const associationRules = [
  { itemA: "香菇滑鸡饭", itemB: "柠檬茶", count: 86, support: 0.18, percentage: "18.0%" },
  { itemA: "番茄牛腩面", itemB: "鸡蛋灌饼", count: 64, support: 0.13, percentage: "13.0%" },
  { itemA: "黑椒鸡排", itemB: "玉米排骨汤", count: 58, support: 0.12, percentage: "12.0%" },
];

const dataByMethod = {
  getMyUserPreferences: {
    favoriteCategories: ["主食", "荤菜"],
    tastePreferences: ["鲜香", "微辣"],
  },
  getMyHealthRecommendations: [
    { title: "增加蔬菜摄入", description: "今天推荐搭配清炒时蔬或汤类。" },
    { title: "控制油炸菜品", description: "晚餐可优先选择蒸煮类菜品。" },
  ],
  getKeyMetrics: {
    revenue: 45280.5,
    revenueChange: 12.6,
    orders: 2038,
    ordersChange: 8.4,
    users: 1268,
    usersChange: 5.1,
    avgOrderValue: 22.22,
    avgOrderChange: 3.7,
  },
  getDashboardSummary: {
    totalUsers: 1268,
    todayOrders: 286,
    todayRevenue: 6420.5,
  },
  getRevenueTrend: dailyRows.map(({ time, value }) => ({ time, value })),
  getRevenueTrendDetail: { granularity: "day", data: dailyRows },
  getOrdersTrend: dailyRows.map(({ time, orderCount }) => ({ time, value: orderCount })),
  getDishSalesRanking: dishNames.map((name, index) => ({ name, value: 280 - index * 22 })),
  getDishSalesRankingByPeriod: dishSalesByPeriod,
  getDishRatingRanking: dishRatingRanking,
  getDishTrendRanking: dishTrendRanking,
  getDishCategoryRanking: dishCategoryRanking,
  getUserActivePeriods: activePeriods,
  getCategorySales: categories.map((name, index) => ({
    name,
    value: [5200, 4800, 2300, 1600, 1300, 1800][index],
  })),
  getCategoryTrend: dailyRows.map(({ time, date, MAIN_DISH, MEAT_DISH, VEGETABLE, SOUP, SNACK, DRINK }) => ({
    time,
    date,
    MAIN_DISH,
    MEAT_DISH,
    VEGETABLE,
    SOUP,
    SNACK,
    DRINK,
  })),
  getReviewKeywords: reviewKeywords,
  getReviewKeywordsPreview: reviewKeywords,
  getDishFeatures: dishFeaturesWordcloud.keywords,
  getDishFeaturesWordcloud: dishFeaturesWordcloud,
  getDishFeaturesWordcloudVersion: { version: dishFeaturesWordcloud.version },
  getDishFeaturesWordcloudDishes: featureDishes,
  getUserPreferences: {
    favoriteCategories: ["主食", "荤菜"],
    tastePreferences: ["鲜香", "微辣"],
  },
  getHealthRecommendations: [
    { title: "午餐均衡搭配", description: "主食、荤菜、素菜各一份更适合下午学习。" },
  ],
  getUserSegmentation: segmentation,
  getUserSegmentationAdvanced: segmentation,
  getUserSegmentationUsers: segmentUsers,
  getAssociationRules: associationRules,
  getAnomalyDetection: inventoryWarnings,
  getInventoryWarning: inventoryWarnings,
  getComparisonAnalysis: comparison,
  getReviewKeywordRules: [],
  createReviewKeywordRule: { success: true },
  updateReviewKeywordRule: { success: true },
  deleteReviewKeywordRule: { success: true },
};

export const getStatisticsDemoResponse = (methodName) => {
  if (!Object.prototype.hasOwnProperty.call(dataByMethod, methodName)) {
    return null;
  }
  const data = dataByMethod[methodName];
  return response(typeof data === "function" ? data() : data);
};
