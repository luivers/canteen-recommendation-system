<template>
  <div v-loading="loading" class="dashboard-container">
    <!-- 欢迎Banner和实时数据 -->
    <div class="welcome-section">
      <div class="welcome-banner">
        <h2>欢迎回来，管理员</h2>
        <p>这里是您的食堂管理控制台</p>
      </div>
      <el-row :gutter="20" class="live-metrics">
        <el-col :span="8">
          <el-card shadow="hover" class="live-card">
            <div class="live-content">
              <el-icon
                class="live-icon"
                style="background-color: #e6f7ff; color: #1890ff"
                ><User
              /></el-icon>
              <div class="live-info">
                <div class="live-label">总用户数量</div>
                <div class="live-value">{{ summary.totalUsers }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="live-card">
            <div class="live-content">
              <el-icon
                class="live-icon"
                style="background-color: #f6ffed; color: #52c41a"
                ><ShoppingCart
              /></el-icon>
              <div class="live-info">
                <div class="live-label">今日订单</div>
                <div class="live-value">{{ summary.todayOrders }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="live-card">
            <div class="live-content">
              <el-icon
                class="live-icon"
                style="background-color: #fff7e6; color: #fa8c16"
                ><Money
              /></el-icon>
              <div class="live-info">
                <div class="live-label">今日营收</div>
                <div class="live-value">¥{{ summary.todayRevenue }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">数据看板</h1>
      <div class="header-actions">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          unlink-panels
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          :shortcuts="shortcuts"
          :clearable="false"
          style="width: 320px"
          @change="handleDateChange"
        />
        <el-button type="primary" @click="refreshData">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </div>

    <!-- 关键指标 -->
    <div class="key-metrics">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card class="metric-card">
            <div class="metric-content">
              <div class="metric-icon revenue">
                <el-icon><Money /></el-icon>
              </div>
              <div class="metric-info">
                <div class="metric-value">¥{{ metrics.revenue }}</div>
                <div class="metric-label">总收入</div>
                <div
                  class="metric-change"
                  :class="metrics.revenueChange >= 0 ? 'positive' : 'negative'"
                >
                  <el-icon v-if="metrics.revenueChange >= 0"><Top /></el-icon>
                  <el-icon v-else><Bottom /></el-icon>
                  {{ Math.abs(metrics.revenueChange) }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="metric-card">
            <div class="metric-content">
              <div class="metric-icon orders">
                <el-icon><Document /></el-icon>
              </div>
              <div class="metric-info">
                <div class="metric-value">{{ metrics.orders }}</div>
                <div class="metric-label">总订单数</div>
                <div
                  class="metric-change"
                  :class="metrics.ordersChange >= 0 ? 'positive' : 'negative'"
                >
                  <el-icon v-if="metrics.ordersChange >= 0"><Top /></el-icon>
                  <el-icon v-else><Bottom /></el-icon>
                  {{ Math.abs(metrics.ordersChange) }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="metric-card">
            <div class="metric-content">
              <div class="metric-icon users">
                <el-icon><User /></el-icon>
              </div>
              <div class="metric-info">
                <div class="metric-value">{{ metrics.users }}</div>
                <div class="metric-label">活跃用户</div>
                <div
                  class="metric-change"
                  :class="metrics.usersChange >= 0 ? 'positive' : 'negative'"
                >
                  <el-icon v-if="metrics.usersChange >= 0"><Top /></el-icon>
                  <el-icon v-else><Bottom /></el-icon>
                  {{ Math.abs(metrics.usersChange) }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="metric-card">
            <div class="metric-content">
              <div class="metric-icon avg-order">
                <el-icon><TrendCharts /></el-icon>
              </div>
              <div class="metric-info">
                <div class="metric-value">¥{{ metrics.avgOrderValue }}</div>
                <div class="metric-label">客单价</div>
                <div
                  class="metric-change"
                  :class="metrics.avgOrderChange >= 0 ? 'positive' : 'negative'"
                >
                  <el-icon v-if="metrics.avgOrderChange >= 0"><Top /></el-icon>
                  <el-icon v-else><Bottom /></el-icon>
                  {{ Math.abs(metrics.avgOrderChange) }}%
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 图表区域 -->
    <div class="charts-section">
      <el-row :gutter="20">
        <el-col :span="24">
          <el-card>
            <template #header>
              <div class="card-header">
                <span>{{ chartTypeLabel }}</span>
                <div class="chart-actions">
                  <el-select
                    v-model="selectedChartType"
                    size="small"
                    style="width: 180px"
                  >
                    <el-option label="收入趋势" value="revenueTrend" />
                    <el-option label="订单趋势" value="ordersTrend" />
                    <el-option label="热门菜品排行" value="dishSalesRanking" />
                    <el-option label="用户活跃时段" value="userActivePeriods" />
                    <el-option label="品类销售趋势" value="categoryTrend" />
                    <el-option label="评论关键词" value="reviewKeywords" />
                    <el-option label="菜品特征词云" value="dishFeaturesCloud" />
                  </el-select>
                  <el-dropdown @command="handleRevenueExportCommand">
                    <el-button type="primary" plain> 导出 </el-button>
                    <template #dropdown>
                      <el-dropdown-menu>
                        <el-dropdown-item command="png"
                          >导出PNG</el-dropdown-item
                        >
                        <el-dropdown-item command="pdf"
                          >导出PDF</el-dropdown-item
                        >
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </div>
              </div>
            </template>
            <div
              v-show="isRevenueTrend"
              ref="revenueTrendChartRef"
              class="revenue-trend-chart"
              :style="{ height: chartHeight + 'px' }"
            ></div>
            <OrdersTrendChart
              v-if="isOrdersTrend"
              ref="ordersTrendChartComponentRef"
              :start-date="chartStartDate"
              :end-date="chartEndDate"
              :height="chartHeight"
              :active="isOrdersTrend"
              :show-labels="revenueChartShowLabels"
              :refresh-key="ordersTrendRefreshKey"
            />
            <HotDishRanking
              v-if="isDishSalesRanking"
              ref="dishSalesRankingComponentRef"
              :start-date="chartStartDate"
              :end-date="chartEndDate"
              :height="chartHeight"
              :active="isDishSalesRanking"
              :show-labels="revenueChartShowLabels"
              :refresh-key="dishSalesRankingRefreshKey"
            />
            <UserActivePeriods
              v-if="isUserActivePeriods"
              ref="userActivePeriodsComponentRef"
              :start-date="chartStartDate"
              :end-date="chartEndDate"
              :height="chartHeight"
              :active="isUserActivePeriods"
              :show-labels="revenueChartShowLabels"
              :refresh-key="userActivePeriodsRefreshKey"
            />
            <CategoryTrendChart
              v-if="isCategoryTrend"
              ref="categoryTrendChartComponentRef"
              :start-date="chartStartDate"
              :end-date="chartEndDate"
              :height="chartHeight"
              :active="isCategoryTrend"
              :show-labels="revenueChartShowLabels"
              :refresh-key="categoryTrendRefreshKey"
            />
            <ReviewKeywordsPanel
              v-if="isReviewKeywords"
              ref="reviewKeywordsPanelRef"
              :start-date="chartStartDate"
              :end-date="chartEndDate"
              :height="chartHeight"
              :active="isReviewKeywords"
              :refresh-key="reviewKeywordsRefreshKey"
            />
            <DishFeaturesWordCloud
              v-if="isDishFeaturesCloud"
              ref="dishFeaturesWordCloudRef"
              :start-date="chartStartDate"
              :end-date="chartEndDate"
              :height="chartHeight"
              :active="isDishFeaturesCloud"
              :refresh-key="dishFeaturesRefreshKey"
            />
            <div
              v-show="
                !isRevenueTrend &&
                !isOrdersTrend &&
                !isDishSalesRanking &&
                !isUserActivePeriods &&
                !isCategoryTrend &&
                !isReviewKeywords &&
                !isDishFeaturesCloud
              "
              class="chart-placeholder"
              :style="{ height: chartHeight + 'px' }"
            >
              <el-empty description="功能开发中" />
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 实时数据 -->
    <div class="real-time-data">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>今日实时订单</span>
            </template>
            <div class="real-time-list">
              <div
                v-for="order in realTimeOrders"
                :key="order.id"
                class="order-item"
              >
                <div class="order-info">
                  <span class="order-number">{{ order.orderNumber }}</span>
                  <span class="order-amount">¥{{ order.amount }}</span>
                </div>
                <div class="order-time">{{ order.time }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>系统状态</span>
            </template>
            <div class="system-status">
              <div class="status-item">
                <span class="status-label">服务器状态</span>
                <el-tag type="success">正常</el-tag>
              </div>
              <div class="status-item">
                <span class="status-label">数据库连接</span>
                <el-tag type="success">正常</el-tag>
              </div>
              <div class="status-item">
                <span class="status-label">推荐系统</span>
                <el-tag type="success">运行中</el-tag>
              </div>
              <div class="status-item">
                <span class="status-label">最后更新</span>
                <span class="status-value">{{ lastUpdateTime }}</span>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import {
  ref,
  computed,
  defineAsyncComponent,
  defineComponent,
  h,
  nextTick,
  onMounted,
  onUnmounted,
  watch,
} from "vue";
import { ElMessage, ElSkeleton } from "element-plus";
import {
  Refresh,
  Money,
  Document,
  User,
  TrendCharts,
  Top,
  Bottom,
  ShoppingCart,
} from "@element-plus/icons-vue";
import { statisticsApi } from "@/api/statistics";
import { orderApi } from "@/api/order";

const ChartLoading = defineComponent({
  name: "ChartLoading",
  props: {
    height: { type: Number, default: 360 },
  },
  setup(props) {
    return () =>
      h(
        "div",
        {
          class: "chart-async-loading",
          style: { height: `${props.height}px` },
        },
        [h(ElSkeleton, { rows: 6, animated: true })],
      );
  },
});

const createAsyncChart = (loader) =>
  defineAsyncComponent({
    loader,
    loadingComponent: ChartLoading,
    delay: 120,
    timeout: 30000,
  });

const OrdersTrendChart = createAsyncChart(() =>
  import("@/components/admin/OrdersTrendChart.vue"),
);
const HotDishRanking = createAsyncChart(() =>
  import("@/components/admin/HotDishRanking.vue"),
);
const UserActivePeriods = createAsyncChart(() =>
  import("@/components/admin/UserActivePeriods.vue"),
);
const CategoryTrendChart = createAsyncChart(() =>
  import("@/components/admin/CategoryTrendChart.vue"),
);
const ReviewKeywordsPanel = createAsyncChart(() =>
  import("@/components/admin/ReviewKeywordsPanel.vue"),
);
const DishFeaturesWordCloud = createAsyncChart(() =>
  import("@/components/admin/DishFeaturesWordCloud.vue"),
);

// 日期范围
const dateRange = ref([]);
const loading = ref(false);

// 快捷选项
const shortcuts = [
  {
    text: "今日",
    value: () => {
      const end = new Date();
      const start = new Date();
      return [start, end];
    },
  },
  {
    text: "本周",
    value: () => {
      const end = new Date();
      const start = new Date();
      const day = start.getDay() || 7;
      start.setDate(start.getDate() - day + 1);
      return [start, end];
    },
  },
  {
    text: "本月",
    value: () => {
      const start = new Date();
      start.setDate(1); // Start of this month

      const end = new Date(start);
      end.setMonth(end.getMonth() + 1);
      end.setDate(0); // End of this month

      return [start, end];
    },
  },
  {
    text: "本季度",
    value: () => {
      const start = new Date();
      const q = Math.floor(start.getMonth() / 3);
      start.setMonth(q * 3);
      start.setDate(1); // Start of this quarter

      const end = new Date(start);
      end.setMonth(end.getMonth() + 3);
      end.setDate(0); // End of this quarter

      return [start, end];
    },
  },
  {
    text: "本年",
    value: () => {
      const start = new Date();
      start.setMonth(0);
      start.setDate(1); // Start of this year

      const end = new Date(start);
      end.setFullYear(end.getFullYear() + 1);
      end.setDate(0); // End of this year

      return [start, end];
    },
  },
];

// 默认选中今日
const initDateRange = () => {
  const end = new Date();
  const start = new Date();
  dateRange.value = [start, end];
};

const metrics = ref({
  revenue: 0,
  revenueChange: 0,
  orders: 0,
  ordersChange: 0,
  users: 0,
  usersChange: 0,
  avgOrderValue: 0,
  avgOrderChange: 0,
});

const summary = ref({
  totalUsers: 0,
  todayOrders: 0,
  todayRevenue: 0,
});

const realTimeOrders = ref([]);
const lastUpdateTime = ref("");

const demoRealTimeOrders = [
  { id: "demo-1", orderNumber: "DEMO20260607001", amount: 32.5, time: "12:18:06" },
  { id: "demo-2", orderNumber: "DEMO20260607002", amount: 18.0, time: "12:10:42" },
  { id: "demo-3", orderNumber: "DEMO20260607003", amount: 26.8, time: "11:58:31" },
  { id: "demo-4", orderNumber: "DEMO20260607004", amount: 21.5, time: "11:45:19" },
  { id: "demo-5", orderNumber: "DEMO20260607005", amount: 15.0, time: "11:36:08" },
];

const revenueTrendChartRef = ref(null);
let revenueTrendChart = null;
let echartsModule = null;
let revenueTrendInitPromise = null;
let isUnmounted = false;
const revenueChartShowLabels = ref(true);
const revenueTrendRawData = ref([]);

const selectedChartType = ref("revenueTrend");
const chartTypeLabel = computed(() => {
  const map = {
    revenueTrend: "收入趋势",
    ordersTrend: "订单趋势",
    dishSalesRanking: "热门菜品排行",
    userActivePeriods: "用户活跃时段",
    categoryTrend: "品类销售趋势",
    reviewKeywords: "评论关键词",
    dishFeaturesCloud: "菜品特征词云",
  };
  return map[selectedChartType.value] || "收入趋势";
});

const isRevenueTrend = computed(
  () => selectedChartType.value === "revenueTrend",
);
const isOrdersTrend = computed(() => selectedChartType.value === "ordersTrend");
const isDishSalesRanking = computed(
  () => selectedChartType.value === "dishSalesRanking",
);
const isUserActivePeriods = computed(
  () => selectedChartType.value === "userActivePeriods",
);
const isCategoryTrend = computed(
  () => selectedChartType.value === "categoryTrend",
);
const isReviewKeywords = computed(
  () => selectedChartType.value === "reviewKeywords",
);
const isDishFeaturesCloud = computed(
  () => selectedChartType.value === "dishFeaturesCloud",
);

const chartHeight = 720;

const ordersTrendChartComponentRef = ref(null);
const ordersTrendRefreshKey = ref(0);
const dishSalesRankingComponentRef = ref(null);
const dishSalesRankingRefreshKey = ref(0);
const userActivePeriodsComponentRef = ref(null);
const userActivePeriodsRefreshKey = ref(0);
const categoryTrendChartComponentRef = ref(null);
const categoryTrendRefreshKey = ref(0);
const reviewKeywordsPanelRef = ref(null);
const reviewKeywordsRefreshKey = ref(0);
const dishFeaturesWordCloudRef = ref(null);
const dishFeaturesRefreshKey = ref(0);

const REVENUE_TREND_CACHE_TTL_MS = 120000;
const revenueTrendCache = new Map();

const getRevenueTrendCacheKey = (startDate, endDate) =>
  `${startDate || ""}|${endDate || ""}`;

const getRevenueTrendBaseOption = () => {
  return {
    animation: true,
    animationDuration: 600,
    animationDurationUpdate: 500,
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "line" },
      valueFormatter: (v) => `¥${Number(v || 0).toFixed(2)}`,
    },
    legend: {
      top: 6,
      right: 10,
      data: ["收入"],
    },
    grid: {
      left: 40,
      right: 20,
      top: 44,
      bottom: 52,
      containLabel: true,
    },
    xAxis: {
      type: "category",
      data: [],
      axisLabel: {
        interval: 0,
        color: "#666",
      },
      axisLine: {
        lineStyle: { color: "#E6E6E6" },
      },
    },
    yAxis: {
      type: "value",
      axisLabel: {
        color: "#666",
        formatter: (v) => `¥${v}`,
      },
      splitLine: {
        lineStyle: { color: "#F0F0F0" },
      },
    },
    dataZoom: [
      { type: "inside", throttle: 50 },
      { type: "slider", height: 18, bottom: 10 },
    ],
    series: [
      {
        name: "收入",
        type: "line",
        data: [],
        smooth: true,
        showSymbol: true,
        symbolSize: 6,
        lineStyle: { width: 3, color: "#409EFF" },
        itemStyle: { color: "#409EFF" },
        areaStyle: { color: "rgba(64, 158, 255, 0.15)" },
        label: {
          show: revenueChartShowLabels.value,
          formatter: (p) => `¥${Number(p?.value || 0).toFixed(0)}`,
        },
      },
    ],
  };
};

const loadEcharts = async () => {
  if (!echartsModule) {
    echartsModule = await import("echarts");
  }
  return echartsModule;
};

const initRevenueTrendChart = async () => {
  if (revenueTrendChart) return revenueTrendChart;
  if (revenueTrendInitPromise) return revenueTrendInitPromise;

  revenueTrendInitPromise = (async () => {
    await nextTick();
    if (isUnmounted || !revenueTrendChartRef.value) return null;

    const echarts = await loadEcharts();
    if (isUnmounted || !revenueTrendChartRef.value) return null;

    revenueTrendChart = echarts.init(revenueTrendChartRef.value);
    revenueTrendChart.setOption(getRevenueTrendBaseOption());
    return revenueTrendChart;
  })().finally(() => {
    revenueTrendInitPromise = null;
  });

  return revenueTrendInitPromise;
};

const ensureRevenueTrendChart = async () => {
  if (revenueTrendChart) return revenueTrendChart;
  return initRevenueTrendChart();
};

const disposeRevenueTrendChart = () => {
  if (revenueTrendChart) {
    revenueTrendChart.dispose();
    revenueTrendChart = null;
  }
};

const showRevenueTrendLoading = () => {
  if (!revenueTrendChart) return;
  revenueTrendChart.showLoading("default", {
    text: "加载中...",
    color: "#409EFF",
    textColor: "#666",
    maskColor: "rgba(255,255,255,0.6)",
  });
};

const hideRevenueTrendLoading = () => {
  if (!revenueTrendChart) return;
  revenueTrendChart.hideLoading();
};

const showRevenueTrendError = (text) => {
  if (!revenueTrendChart) return;
  revenueTrendChart.clear();
  revenueTrendChart.setOption(getRevenueTrendBaseOption());
  revenueTrendChart.setOption({
    graphic: [
      {
        type: "text",
        left: "center",
        top: "middle",
        style: {
          text: text || "加载失败",
          fill: "#999",
          fontSize: 14,
        },
      },
    ],
  });
};

const updateRevenueTrendChart = (rawData) => {
  if (!revenueTrendChart) return;
  const list = Array.isArray(rawData) ? rawData : [];
  const points = list
    .map((item) => {
      const time = item?.time ?? item?.t ?? item?.date ?? item?.label;
      const value = item?.value ?? item?.val ?? item?.revenue;
      return {
        time: time == null ? "" : String(time),
        value: Number(value || 0),
      };
    })
    .filter((p) => p.time);

  if (points.length === 0) {
    showRevenueTrendError("暂无数据");
    return;
  }

  const times = points.map((p) => p.time);
  const values = points.map((p) => p.value);

  revenueTrendChart.setOption({
    graphic: [],
    xAxis: { data: times },
    series: [
      {
        name: "收入",
        data: values,
        label: {
          show: revenueChartShowLabels.value,
          formatter: (p) => `¥${Number(p?.value || 0).toFixed(0)}`,
        },
      },
    ],
  });
};

const fetchRevenueTrend = async (timeRange, startDate, endDate) => {
  if (!startDate || !endDate) return;
  if (isRevenueTrend.value) {
    await ensureRevenueTrendChart();
  }
  const key = getRevenueTrendCacheKey(startDate, endDate);
  const cached = revenueTrendCache.get(key);
  if (cached && Date.now() - cached.ts <= REVENUE_TREND_CACHE_TTL_MS) {
    revenueTrendRawData.value = cached.data;
    updateRevenueTrendChart(cached.data);
    return;
  }

  showRevenueTrendLoading();
  try {
    for (const [k, v] of revenueTrendCache) {
      if (Date.now() - v.ts > REVENUE_TREND_CACHE_TTL_MS) {
        revenueTrendCache.delete(k);
      }
    }
    const res = await statisticsApi.getRevenueTrend(
      timeRange,
      startDate,
      endDate,
    );
    const data = res?.data || [];
    revenueTrendCache.set(key, { ts: Date.now(), data });
    revenueTrendRawData.value = data;
    updateRevenueTrendChart(data);
  } catch (e) {
    showRevenueTrendError("加载失败");
  } finally {
    hideRevenueTrendLoading();
  }
};

watch(revenueChartShowLabels, () => {
  updateRevenueTrendChart(revenueTrendRawData.value);
});

watch(selectedChartType, async (val) => {
  if (val !== "revenueTrend") return;
  await nextTick();
  await ensureRevenueTrendChart();
  if (revenueTrendChart) {
    revenueTrendChart.resize();
    updateRevenueTrendChart(revenueTrendRawData.value);
  }
});

// 日期格式化 helper
const formatDate = (date) => {
  if (!date) return null;
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
};

const chartStartDate = computed(() =>
  dateRange.value?.[0] ? formatDate(dateRange.value[0]) : "",
);
const chartEndDate = computed(() =>
  dateRange.value?.[1] ? formatDate(dateRange.value[1]) : "",
);

// 获取仪表盘摘要（欢迎Banner数据）
const fetchSummary = async () => {
  try {
    const res = await statisticsApi.getDashboardSummary();
    summary.value = res.data || {
      totalUsers: 0,
      todayOrders: 0,
      todayRevenue: 0,
    };
  } catch (error) {
    console.error("获取仪表盘摘要失败:", error);
  }
};

// 加载数据
const loadData = async () => {
  if (!dateRange.value || dateRange.value.length !== 2) return;

  loading.value = true;
  const startDate = formatDate(dateRange.value[0]);
  const endDate = formatDate(dateRange.value[1]);
  // Use 'custom' as timeRange placeholder, backend will prioritize startDate/endDate
  const timeRange = "custom";

  try {
    const metricsPromise = statisticsApi.getKeyMetrics(
      timeRange,
      startDate,
      endDate,
    );
    const revenuePromise = fetchRevenueTrend(timeRange, startDate, endDate);
    const ordersPromise = statisticsApi.isDemoEnabled()
      ? Promise.resolve({ data: { content: demoRealTimeOrders } })
      : orderApi.getOrders({
          page: 0,
          size: 5,
          sort: "createdAt,desc",
        });

    const [metricsResult, revenueResult, ordersResult] =
      await Promise.allSettled([metricsPromise, revenuePromise, ordersPromise]);

    let hasError = false;

    if (metricsResult.status === "fulfilled") {
      const metricsData = metricsResult.value?.data || {};
      metrics.value = {
        revenue: metricsData.revenue || 0,
        revenueChange: metricsData.revenueChange || 0,
        orders: metricsData.orders || 0,
        ordersChange: metricsData.ordersChange || 0,
        users: metricsData.users || 0,
        usersChange: metricsData.usersChange || 0,
        avgOrderValue: metricsData.avgOrderValue || 0,
        avgOrderChange: metricsData.avgOrderChange || 0,
      };
    } else {
      hasError = true;
    }

    if (revenueResult.status === "rejected") {
      hasError = true;
    }

    if (ordersResult.status === "fulfilled") {
      realTimeOrders.value = (ordersResult.value?.data?.content || []).map(
        (order) => ({
          id: order.id,
          orderNumber: order.orderNumber,
          amount: order.totalAmount ?? order.amount ?? 0,
          time: order.time || new Date(order.createdAt).toLocaleTimeString("zh-CN"),
        }),
      );
    } else {
      hasError = true;
    }

    lastUpdateTime.value = new Date().toLocaleString("zh-CN");
    if (hasError) {
      ElMessage.warning("部分数据加载失败");
    }
  } catch (error) {
    console.error("加载数据失败:", error);
    ElMessage.error("加载数据失败");
  } finally {
    loading.value = false;
  }
};

// 处理日期变更
const handleDateChange = () => {
  loadData();
};

// 刷新数据
const refreshData = () => {
  ordersTrendRefreshKey.value += 1;
  dishSalesRankingRefreshKey.value += 1;
  userActivePeriodsRefreshKey.value += 1;
  categoryTrendRefreshKey.value += 1;
  reviewKeywordsRefreshKey.value += 1;
  dishFeaturesRefreshKey.value += 1;
  loadData();
  ElMessage.success("数据已刷新");
};

const handleRevenueExportCommand = (command) => {
  const start = formatDate(dateRange.value?.[0]) || "";
  const end = formatDate(dateRange.value?.[1]) || "";
  const title = chartTypeLabel.value || "";

  const getActiveChartDataURL = () => {
    if (isRevenueTrend.value && revenueTrendChart) {
      return revenueTrendChart.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    if (isOrdersTrend.value && ordersTrendChartComponentRef.value?.getDataURL) {
      return ordersTrendChartComponentRef.value.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    if (
      isDishSalesRanking.value &&
      dishSalesRankingComponentRef.value?.getDataURL
    ) {
      return dishSalesRankingComponentRef.value.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    if (
      isUserActivePeriods.value &&
      userActivePeriodsComponentRef.value?.getDataURL
    ) {
      return userActivePeriodsComponentRef.value.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    if (
      isCategoryTrend.value &&
      categoryTrendChartComponentRef.value?.getDataURL
    ) {
      return categoryTrendChartComponentRef.value.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    if (isReviewKeywords.value && reviewKeywordsPanelRef.value?.getDataURL) {
      return reviewKeywordsPanelRef.value.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    if (
      isDishFeaturesCloud.value &&
      dishFeaturesWordCloudRef.value?.getDataURL
    ) {
      return dishFeaturesWordCloudRef.value.getDataURL({
        type: "png",
        pixelRatio: 2,
        backgroundColor: "#ffffff",
      });
    }
    return "";
  };

  const url = getActiveChartDataURL();
  if (!url) {
    ElMessage.warning("当前图表尚未加载完成，稍后再试");
    return;
  }

  if (command === "png") {
    const link = document.createElement("a");
    link.href = url;
    link.download = `${title}_${start}_${end}.png`;
    link.click();
  }
  if (command === "pdf") {
    const w = window.open("", "_blank");
    if (!w) return;
    w.document.write(`
      <html>
        <head>
          <title>${title}_${start}_${end}</title>
          <style>
            body { font-family: Arial, 'Microsoft YaHei', sans-serif; padding: 24px; }
            h2 { margin: 0 0 12px 0; }
            .meta { color: #666; margin-bottom: 16px; }
            img { width: 100%; max-width: 1000px; }
          </style>
        </head>
        <body>
          <h2>${title}</h2>
          <div class="meta">时间范围：${start} 至 ${end}</div>
          <img src="${url}" />
        </body>
      </html>
    `);
    w.document.close();
    w.addEventListener("load", () => {
      w.focus();
      w.print();
      w.close();
    });
  }
};

const handleResize = () => {
  if (isRevenueTrend.value && revenueTrendChart) {
    revenueTrendChart.resize();
    return;
  }

  const activeRef = [
    ordersTrendChartComponentRef,
    dishSalesRankingComponentRef,
    userActivePeriodsComponentRef,
    categoryTrendChartComponentRef,
    reviewKeywordsPanelRef,
    dishFeaturesWordCloudRef,
  ].find((item) => item.value?.resize);

  if (activeRef?.value?.resize) {
    activeRef.value.resize();
  }
};

onMounted(() => {
  isUnmounted = false;
  initDateRange(); // 初始化日期
  loadData();
  fetchSummary();
  window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
  isUnmounted = true;
  window.removeEventListener("resize", handleResize);
  disposeRevenueTrendChart();
});
</script>

<style scoped>
.dashboard-container {
  width: 100%;
  margin: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.key-metrics {
  margin-bottom: 30px;
}

.charts-section {
  margin-bottom: 30px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.chart-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.chart-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
}

.revenue-trend-chart {
  width: 100%;
}

.chart-async-loading {
  display: flex;
  align-items: center;
  padding: 24px;
}

.metric-card {
  margin-bottom: 20px;
}

.metric-content {
  display: flex;
  align-items: center;
  padding: 20px;
}

.metric-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  color: white;
  font-size: 24px;
}

.metric-icon.revenue {
  background: #67c23a;
}
.metric-icon.orders {
  background: #409eff;
}
.metric-icon.users {
  background: #e6a23c;
}
.metric-icon.avg-order {
  background: #f56c6c;
}

.metric-info {
  flex: 1;
}

.metric-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.metric-label {
  font-size: 14px;
  color: #666;
  margin-bottom: 5px;
}

.metric-change {
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 2px;
}

.metric-change.positive {
  color: #67c23a;
}

.metric-change.negative {
  color: #f56c6c;
}

.welcome-section {
  margin-bottom: 24px;
}

.welcome-banner {
  background: linear-gradient(135deg, #1890ff 0%, #36cfc9 100%);
  padding: 24px;
  border-radius: 8px;
  color: white;
  margin-bottom: 24px;
}

.welcome-banner h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 500;
}

.welcome-banner p {
  margin: 0;
  opacity: 0.9;
  font-size: 14px;
}

.live-card {
  height: 100px;
  transition: all 0.3s;
}

.live-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.live-content {
  display: flex;
  align-items: center;
  height: 100%;
}

.live-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  margin-right: 16px;
}

.live-info {
  flex: 1;
}

.live-label {
  color: #8c8c8c;
  font-size: 14px;
  margin-bottom: 4px;
}

.live-value {
  color: #262626;
  font-size: 24px;
  font-weight: 600;
  font-family:
    -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue",
    Arial;
}

.real-time-data {
  margin-bottom: 30px;
}

.real-time-list {
  max-height: 300px;
  overflow-y: auto;
}

.order-item {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.order-item:last-child {
  border-bottom: none;
}

.order-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;
}

.order-number {
  font-weight: 500;
  color: #333;
}

.order-amount {
  color: #409eff;
  font-weight: bold;
}

.order-time {
  font-size: 12px;
  color: #999;
}

.system-status {
  padding: 10px 0;
}

.status-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.status-item:last-child {
  border-bottom: none;
}

.status-label {
  color: #666;
}

.status-value {
  color: #999;
  font-size: 14px;
}
</style>
