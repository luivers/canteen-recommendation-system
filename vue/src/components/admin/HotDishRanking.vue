<template>
  <div class="hot-dish-ranking-wrapper">
    <el-tabs v-model="activeTab" class="ranking-tabs" @tab-change="handleTabChange">
      <!-- 销量排行 -->
      <el-tab-pane label="销量排行" name="sales">
        <div class="tab-content">
          <div class="toolbar">
            <span class="label">周期:</span>
            <el-select
              v-model="salesPeriod"
              size="small"
              style="width: 220px"
              :disabled="salesPeriods.length === 0"
              @change="updateSalesChart"
            >
              <el-option v-for="p in salesPeriods" :key="p" :label="p" :value="p" />
            </el-select>
          </div>
          <div ref="salesChartRef" :style="{ height: chartHeight + 'px' }"></div>
        </div>
      </el-tab-pane>

      <!-- 评分排行 -->
      <el-tab-pane label="综合评分排行" name="rating">
        <div class="tab-content">
          <div class="toolbar">
            <span class="label">最少评价数:</span>
            <el-input-number 
              v-model="minReviews" 
              :min="0" 
              :step="5" 
              size="small" 
              style="width: 100px" 
              @change="fetchRatingData"
            />
          </div>
          <div ref="ratingChartRef" :style="{ height: chartHeight + 'px' }"></div>
        </div>
      </el-tab-pane>

      <!-- 趋势排行 -->
      <el-tab-pane label="趋势变化排行" name="trend">
        <div class="tab-content">
          <div class="toolbar">
            <span class="label">指标:</span>
            <el-select v-model="trendMetric" size="small" style="width: 120px" @change="fetchTrendData">
              <el-option label="销量" value="sales" />
              <el-option label="评分" value="rating" />
            </el-select>
          </div>
          <div ref="trendChartRef" :style="{ height: chartHeight + 'px' }"></div>
        </div>
      </el-tab-pane>

      <!-- 分类排行 -->
      <el-tab-pane label="分类排行" name="category">
        <div class="tab-content">
          <div class="toolbar">
            <span class="label">选择品类:</span>
            <el-select
              v-model="selectedCategory"
              size="small"
              style="width: 200px"
              filterable
              placeholder="请选择品类"
              @change="updateCategoryChart"
            >
              <el-option
                v-for="cat in categoryList"
                :key="cat.category"
                :label="cat.category"
                :value="cat.category"
              />
            </el-select>
          </div>
          <div ref="categoryChartRef" :style="{ height: chartHeight + 'px' }"></div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import * as echarts from "echarts";
import { statisticsApi } from "@/api/statistics";

const props = defineProps({
  startDate: { type: String, default: "" },
  endDate: { type: String, default: "" },
  height: { type: Number, default: 360 },
  active: { type: Boolean, default: false },
  showLabels: { type: Boolean, default: false },
  refreshKey: { type: Number, default: 0 },
});

const activeTab = ref("sales");
const TOOLBAR_HEIGHT = 55; // Approx height including tabs header and toolbar
const chartHeight = computed(() =>
  Math.max(220, Number(props.height || 0) - TOOLBAR_HEIGHT),
);

// --- Sales Ranking Logic ---
const salesChartRef = ref(null);
let salesChart = null;
const salesPeriod = ref("");
const salesPeriods = ref([]);
const salesPeriodToTop = ref(new Map());

// --- Rating Ranking Logic ---
const ratingChartRef = ref(null);
let ratingChart = null;
const minReviews = ref(5);

// --- Trend Ranking Logic ---
const trendChartRef = ref(null);
let trendChart = null;
const trendMetric = ref("sales");

// --- Category Ranking Logic ---
const categoryChartRef = ref(null);
let categoryChart = null;
const categoryList = ref([]);
const selectedCategory = ref("");

defineExpose({
    getDataURL: (opts) => {
        const activeChart = {
            sales: salesChart,
            rating: ratingChart,
            trend: trendChart,
            category: categoryChart,
        }[activeTab.value];
        return activeChart ? activeChart.getDataURL(opts) : "";
    },
    resize: () => {
        handleResize();
    },
});

// Common chart options
const getBarOption = (title, xName, yName, data, color = "#409EFF", labelFormatter = null) => {
  return {
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "shadow" },
    },
    grid: {
      left: 20,
      right: 40,
      top: 30,
      bottom: 30,
      containLabel: true,
    },
    xAxis: {
      type: "value",
      name: xName,
      axisLabel: { color: "#666" },
      splitLine: { lineStyle: { color: "#F0F0F0" } },
    },
    yAxis: {
      type: "category",
      data: data.map(i => i.name),
      inverse: true,
      axisLabel: { color: "#666", width: 140, overflow: "truncate" },
      axisLine: { lineStyle: { color: "#E6E6E6" } },
    },
    series: [
      {
        name: title,
        type: "bar",
        data: data.map(i => i.value),
        barMaxWidth: 26,
        itemStyle: { color: color },
        label: { 
            show: props.showLabels, 
            position: "right",
            formatter: labelFormatter
        },
      },
    ],
  };
};

const hasRenderableRows = (rows) =>
  Array.isArray(rows) && rows.some((item) => item.name && Number.isFinite(Number(item.value)));

const showChartEmpty = (chartInstance, text = "暂无数据") => {
  if (!chartInstance) return;
  chartInstance.clear();
  chartInstance.setOption({
    ...getBarOption("暂无数据", "", "", [], "#909399"),
    graphic: [
      {
        id: "emptyText",
        type: "text",
        left: "center",
        top: "middle",
        style: { text, fill: "#999", fontSize: 14 },
      },
    ],
  });
};

const renderBarChart = (chartInstance, option) => {
  if (!chartInstance) return;
  chartInstance.clear();
  chartInstance.setOption(option);
};

const normalizeRankingRows = (list, valueKeys) => {
  const rows = Array.isArray(list) ? list : [];
  return rows
    .map((item) => {
      const valueKey = valueKeys.find((key) => item?.[key] != null);
      return {
        ...item,
        name: String(item?.name ?? item?.dishName ?? item?.category ?? "").trim(),
        value: Number(valueKey ? item?.[valueKey] : 0),
      };
    })
    .filter((item) => item.name && Number.isFinite(item.value));
};

// --- Initialization ---

const initCharts = () => {
    if (activeTab.value === 'sales' && salesChartRef.value && !salesChart) {
        salesChart = echarts.init(salesChartRef.value);
    }
    if (activeTab.value === 'rating' && ratingChartRef.value && !ratingChart) {
        ratingChart = echarts.init(ratingChartRef.value);
    }
    if (activeTab.value === 'trend' && trendChartRef.value && !trendChart) {
        trendChart = echarts.init(trendChartRef.value);
    }
    if (activeTab.value === 'category' && categoryChartRef.value && !categoryChart) {
        categoryChart = echarts.init(categoryChartRef.value);
    }
}

// --- Data Fetching ---

const fetchSalesData = async () => {
    if (!props.startDate || !props.endDate) return;
    if (salesChart) salesChart.showLoading();
    try {
        const res = await statisticsApi.getDishSalesRankingByPeriod("custom", props.startDate, props.endDate);
        const list = Array.isArray(res?.data) ? res.data : [];
        const pList = [];
        const pMap = new Map();
        for (const item of list) {
            const t = item?.time == null ? "" : String(item.time);
            if (!t) continue;
            pList.push(t);
            pMap.set(t, Array.isArray(item?.top) ? item.top : []);
        }
        salesPeriods.value = pList;
        salesPeriodToTop.value = pMap;
        if (!salesPeriod.value || !pMap.has(salesPeriod.value)) {
            salesPeriod.value = pList[0] || "";
        }
        updateSalesChart();
    } catch (e) {
        console.error(e);
    } finally {
        if (salesChart) salesChart.hideLoading();
    }
};

const updateSalesChart = () => {
    if (!salesChart) return;
    const topList = salesPeriodToTop.value.get(salesPeriod.value) || [];
    const data = normalizeRankingRows(topList, ["qty", "value", "sales"]);
    if (!hasRenderableRows(data)) {
        showChartEmpty(salesChart, "暂无销量排行数据");
        return;
    }
    renderBarChart(salesChart, getBarOption("销量", "销量", "菜品", data, "#409EFF"));
};

const fetchRatingData = async () => {
    if (!props.startDate || !props.endDate) return;
    if (!ratingChart) ratingChart = echarts.init(ratingChartRef.value);
    ratingChart.showLoading();
    try {
        const res = await statisticsApi.getDishRatingRanking("custom", props.startDate, props.endDate, minReviews.value, 10);
        const list = Array.isArray(res?.data) ? res.data : [];
        const data = normalizeRankingRows(list, ["value", "avgRating", "averageRating"]).map(item => ({
            name: item.name,
            value: item.value,
            reviewCount: item.reviewCount,
            ratingCount: item.ratingCount
        }));
        if (!hasRenderableRows(data)) {
            showChartEmpty(ratingChart, "暂无评分排行数据");
            return;
        }
        
        const option = {
            tooltip: {
                trigger: "axis",
                axisPointer: { type: "shadow" },
                formatter: (params) => {
                    const item = data[params[0].dataIndex];
                    return `${item.name}<br/>
                            平均评分: ${Number(item.value).toFixed(1)}<br/>
                            评分次数: ${item.ratingCount}<br/>
                            评论总数: ${item.reviewCount}`;
                }
            },
            grid: {
                left: 20,
                right: 40,
                top: 30,
                bottom: 30,
                containLabel: true,
            },
            xAxis: {
                type: "value",
                name: "评分",
                max: 5,
                axisLabel: { color: "#666" },
                splitLine: { lineStyle: { color: "#F0F0F0" } },
            },
            yAxis: {
                type: "category",
                data: data.map(i => i.name),
                inverse: true,
                axisLabel: { color: "#666", width: 140, overflow: "truncate" },
                axisLine: { lineStyle: { color: "#E6E6E6" } },
            },
            series: [
                {
                    name: "评分",
                    type: "bar",
                    data: data.map(i => i.value),
                    barMaxWidth: 26,
                    itemStyle: { color: "#E6A23C" },
                    label: { 
                        show: props.showLabels, 
                        position: "right",
                        formatter: '{c}'
                    },
                },
            ],
        };
        renderBarChart(ratingChart, option);
    } catch (e) {
        console.error(e);
    } finally {
        ratingChart.hideLoading();
    }
};

const fetchTrendData = async () => {
    if (!props.startDate || !props.endDate) return;
    if (!trendChart) trendChart = echarts.init(trendChartRef.value);
    trendChart.showLoading();
    try {
        const res = await statisticsApi.getDishTrendRanking("custom", props.startDate, props.endDate, trendMetric.value, 10);
        const list = Array.isArray(res?.data) ? res.data : [];
        const data = normalizeRankingRows(list, ["growthRate", "value", "deltaPct"]).map(item => ({
            name: item.name,
            value: item.value,
            current: item.current,
            previous: item.previous
        }));
        if (!hasRenderableRows(data)) {
            showChartEmpty(trendChart, "暂无趋势排行数据");
            return;
        }
        
        // Custom option for trend to show growth rate and maybe actual values in tooltip
        const option = {
            tooltip: {
                trigger: 'axis',
                formatter: (params) => {
                    const item = list[params[0].dataIndex];
                    return `${item.name}<br/>
                            当前: ${item.current}<br/>
                            上期: ${item.previous}<br/>
                            增长率: ${item.growthRate}%`;
                }
            },
             grid: {
                left: 20,
                right: 40,
                top: 30,
                bottom: 30,
                containLabel: true,
            },
            xAxis: { type: 'value', name: '增长率(%)' },
            yAxis: { 
                type: 'category', 
                data: data.map(i => i.name),
                inverse: true,
                axisLabel: { width: 140, overflow: 'truncate' }
            },
            series: [{
                name: '增长率',
                type: 'bar',
                data: data.map(i => i.value),
                itemStyle: {
                    color: (params) => {
                        return params.value >= 0 ? '#67C23A' : '#F56C6C';
                    }
                },
                 label: { 
                    show: props.showLabels, 
                    position: "right",
                    formatter: '{c}%'
                },
            }]
        };
        renderBarChart(trendChart, option);
    } catch (e) {
        console.error(e);
    } finally {
        trendChart.hideLoading();
    }
};

const fetchCategoryData = async () => {
    if (!props.startDate || !props.endDate) return;
    if (categoryChart) categoryChart.showLoading();
    try {
        const res = await statisticsApi.getDishCategoryRanking("custom", props.startDate, props.endDate, 10);
        categoryList.value = Array.isArray(res?.data) ? res.data : [];
        if (categoryList.value.length > 0) {
            // Default to first category if none selected or selected not in list
            const exists = categoryList.value.find(c => c.category === selectedCategory.value);
            if (!selectedCategory.value || !exists) {
                selectedCategory.value = categoryList.value[0].category;
            }
        } else {
            selectedCategory.value = "";
        }
        updateCategoryChart();
    } catch (e) {
        console.error(e);
        categoryList.value = [];
    } finally {
        if (categoryChart) categoryChart.hideLoading();
    }
};

const updateCategoryChart = () => {
    if (!categoryChart) return;
    
    let data = [];
    if (selectedCategory.value) {
        const catData = categoryList.value.find(c => c.category === selectedCategory.value);
        if (catData && Array.isArray(catData.top)) {
            data = normalizeRankingRows(catData.top, ["value", "qty", "sales"]);
        }
    }

    if (!hasRenderableRows(data)) {
        showChartEmpty(categoryChart, "暂无分类排行数据");
        return;
    }
    renderBarChart(categoryChart, getBarOption(`${selectedCategory.value} TOP10`, "销量", "菜品", data, "#409EFF"));
};

const handleTabChange = async (tab) => {
    await nextTick();
    if (tab === 'sales') {
        if (!salesChart) initCharts();
        if (salesPeriods.value.length === 0) fetchSalesData();
        else updateSalesChart();
    } else if (tab === 'rating') {
        fetchRatingData();
    } else if (tab === 'trend') {
        fetchTrendData();
    } else if (tab === 'category') {
        if (!categoryChart) initCharts();
        if (categoryList.value.length === 0) fetchCategoryData();
        else updateCategoryChart();
    }
    handleResize();
};

const handleResize = () => {
    if (salesChart) salesChart.resize();
    if (ratingChart) ratingChart.resize();
    if (trendChart) trendChart.resize();
    if (categoryChart) categoryChart.resize();
};

const fetchData = async () => {
    if (!props.active) return;
    // Always fetch sales data first as it's default
    if (activeTab.value === 'sales') await fetchSalesData();
    else handleTabChange(activeTab.value);
};

onMounted(async () => {
    await nextTick();
    initCharts();
    handleResize();
    await fetchData();
    window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
    window.removeEventListener("resize", handleResize);
    if (salesChart) salesChart.dispose();
    if (ratingChart) ratingChart.dispose();
    if (trendChart) trendChart.dispose();
    if (categoryChart) categoryChart.dispose();
});

watch(
  () => [props.startDate, props.endDate, props.active],
  async (newVal, oldVal) => {
    const [newStart, newEnd, newActive] = newVal;
    const [oldStart, oldEnd] = oldVal || [];

    // If dates changed, clear caches to force refetch
    if (newStart !== oldStart || newEnd !== oldEnd) {
        salesPeriods.value = [];
        categoryList.value = [];
    }

    await nextTick();
    if (newActive) {
        handleResize();
        await fetchData();
    }
  },
);

watch(() => props.refreshKey, async () => {
    await fetchData();
});

watch(() => props.showLabels, () => {
    // Force update current chart
    handleTabChange(activeTab.value);
});
</script>

<style scoped>
.hot-dish-ranking-wrapper {
  display: flex;
  flex-direction: column;
}

.ranking-tabs :deep(.el-tabs__header) {
  margin-bottom: 10px;
}

.tab-content {
  display: flex;
  flex-direction: column;
}

.toolbar {
  height: 40px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding-left: 5px;
}

.label {
  font-size: 14px;
  color: #606266;
}
</style>
