<template>
  <div v-loading="loading" class="dish-features-panel">
    <div class="panel-header">
      <div v-if="stats" class="stats">
        <span>命中评价: {{ stats.matchedReviews }}</span>
        <el-divider direction="vertical" />
        <span>覆盖菜品: {{ stats.coveredDishes }}</span>
      </div>
    </div>

    <div class="legend">
      <span v-for="item in legendItems" :key="item.key" class="legend-item">
        <span class="dot" :style="{ background: item.color }"></span>
        {{ item.label }}
      </span>
    </div>

    <div
      ref="chartRef"
      :style="{ height: height - 78 + 'px', width: '100%' }"
    ></div>

    <el-drawer
      v-model="drawerVisible"
      :with-header="true"
      title="关联菜品"
      size="45%"
    >
      <div style="margin-bottom: 10px">
        <el-tag type="info">{{ currentKeyword }}</el-tag>
      </div>
      <el-table
        v-loading="drawerLoading"
        :data="drawerRows"
        size="small"
        style="width: 100%"
      >
        <el-table-column prop="name" label="菜品" min-width="160" />
        <el-table-column prop="windowName" label="窗口" min-width="120" />
        <el-table-column prop="salesCount" label="销量" width="90" />
        <el-table-column prop="reviewHitCount" label="命中评价" width="110" />
        <el-table-column prop="averageRating" label="评分" width="90" />
      </el-table>
    </el-drawer>
  </div>
</template>

<script setup>
import { nextTick, onMounted, onUnmounted, ref, watch } from "vue";
import * as echarts from "echarts";
import "echarts-wordcloud";
import { statisticsApi } from "@/api/statistics";

const props = defineProps({
  startDate: { type: String, default: "" },
  endDate: { type: String, default: "" },
  height: { type: Number, default: 360 },
  active: { type: Boolean, default: false },
  refreshKey: { type: Number, default: 0 },
});

const chartRef = ref(null);
let chart = null;

const loading = ref(false);
const drawerVisible = ref(false);
const drawerLoading = ref(false);
const drawerRows = ref([]);
const currentKeyword = ref("");

const stats = ref({
  version: 0,
  matchedReviews: 0,
  coveredDishes: 0,
  keywords: [],
});

const legendItems = [
  { key: "TASTE", label: "口味", color: "#E74C3C" },
  { key: "AROMA", label: "气味", color: "#9B59B6" },
  { key: "TEXTURE", label: "口感", color: "#3498DB" },
  { key: "APPEARANCE", label: "外观", color: "#F39C12" },
  { key: "INGREDIENT", label: "食材", color: "#27AE60" },
  { key: "COOKING_METHOD", label: "做法", color: "#16A085" },
  { key: "FRESHNESS", label: "新鲜度", color: "#2ECC71" },
];

const categoryColor = (category, name) => {
  const item = legendItems.find((x) => x.key === category);
  if (item) return item.color;
  let hash = 0;
  const text = name || "";
  for (let i = 0; i < text.length; i += 1)
    hash = (hash * 31 + text.charCodeAt(i)) >>> 0;
  const r = 60 + (hash & 0x7f);
  const g = 60 + ((hash >> 7) & 0x7f);
  const b = 60 + ((hash >> 14) & 0x7f);
  return `rgb(${r},${g},${b})`;
};

const createSeededRandom = (seed) => {
  let state = seed % 2147483647;
  if (state <= 0) state += 2147483646;
  return () => {
    state = (state * 16807) % 2147483647;
    return (state - 1) / 2147483646;
  };
};

const initChart = () => {
  if (!chartRef.value || chart) return;
  chart = echarts.init(chartRef.value);
  chart.on("click", (params) => {
    const kw = params?.name;
    if (!kw) return;
    openDrawer(kw);
  });
};

const buildParams = () => {
  const hasCustom = !!props.startDate && !!props.endDate;
  return {
    timeRange: hasCustom ? "custom" : "today",
    startDate: props.startDate || undefined,
    endDate: props.endDate || undefined,
    topN: 60,
    minWordLength: 2,
    minFrequency: 1,
    wReviews: 1.0,
    wSales: 0.0,
  };
};

const renderWordcloud = () => {
  if (!chart) return;
  const keywords = Array.isArray(stats.value?.keywords)
    ? stats.value.keywords
    : [];
  if (keywords.length === 0) {
    chart.clear();
    chart.setOption({
      graphic: [
        {
          id: "emptyText",
          type: "text",
          left: "center",
          top: "middle",
          style: { text: "暂无数据", fill: "#999", fontSize: 14 },
        },
      ],
    });
    return;
  }

  const seed = Number(stats.value?.version || 1);
  const random = createSeededRandom(seed || 1);
  chart.clear();
  chart.setOption(
    {
      tooltip: {
        show: true,
        formatter: (p) => {
          const d = p?.data || {};
          const reviewHits =
            d?.breakdown?.reviewHits ?? d?.breakdown?.reviewhits ?? "";
          const salesBoost = d?.breakdown?.salesBoost;
          const parts = [];
          if (reviewHits !== "") parts.push(`评价命中：${reviewHits}`);
          if (salesBoost != null) parts.push(`销量加成：${salesBoost}`);
          return `${p?.name || ""}<br/>权重：${p?.value ?? ""}${parts.length ? "<br/>" + parts.join("<br/>") : ""}`;
        },
      },
      series: [
        {
          type: "wordCloud",
          shape: "circle",
          left: "center",
          top: "center",
          width: "86%",
          height: "86%",
          sizeRange: [16, 72],
          rotationRange: [-45, 90],
          rotationStep: 45,
          gridSize: 10,
          drawOutOfBound: false,
          layoutAnimation: true,
          random,
          textStyle: {
            fontFamily: "sans-serif",
            fontWeight: "bold",
            color: (p) => categoryColor(p?.data?.category, p?.name),
          },
          emphasis: {
            focus: "self",
            textStyle: { shadowBlur: 10, shadowColor: "#333" },
          },
          data: keywords.map((k) => ({ ...k, name: k.name, value: k.value })),
        },
      ],
    },
    { notMerge: true, lazyUpdate: false },
  );
};

const fetchData = async () => {
  if (!props.active) return;
  loading.value = true;
  try {
    const res = await statisticsApi.getDishFeaturesWordcloud(buildParams());
    const data = res?.data || {};
    stats.value = {
      version: data.version || 0,
      matchedReviews: data.matchedReviews || 0,
      coveredDishes: data.coveredDishes || 0,
      keywords: data.keywords || [],
    };
    renderWordcloud();
  } finally {
    loading.value = false;
  }
};

const fetchVersion = async () => {
  if (!props.active) return null;
  try {
    const res =
      await statisticsApi.getDishFeaturesWordcloudVersion(buildParams());
    return res?.data?.version ?? null;
  } catch (e) {
    return null;
  }
};

let versionTimer = null;
const startVersionPolling = () => {
  stopVersionPolling();
  versionTimer = setInterval(async () => {
    const v = await fetchVersion();
    if (v == null) return;
    if (Number(v) !== Number(stats.value?.version || 0)) {
      await fetchData();
      if (drawerVisible.value && currentKeyword.value) {
        await loadDrawerRows(currentKeyword.value);
      }
    }
  }, 15000);
};

const stopVersionPolling = () => {
  if (versionTimer) clearInterval(versionTimer);
  versionTimer = null;
};

const loadDrawerRows = async (kw) => {
  drawerLoading.value = true;
  try {
    const params = buildParams();
    const res = await statisticsApi.getDishFeaturesWordcloudDishes({
      ...params,
      keyword: kw,
    });
    drawerRows.value = res?.data || [];
  } finally {
    drawerLoading.value = false;
  }
};

const openDrawer = async (kw) => {
  currentKeyword.value = kw;
  drawerVisible.value = true;
  await loadDrawerRows(kw);
};

const handleResize = () => {
  if (chart) chart.resize();
};

watch(
  () => [props.startDate, props.endDate, props.active, props.refreshKey],
  async () => {
    if (props.active) {
      await nextTick();
      handleResize();
      setTimeout(() => {
        handleResize();
      }, 200);
      await fetchData();
      startVersionPolling();
    } else {
      stopVersionPolling();
    }
  },
);

onMounted(async () => {
  initChart();
  await nextTick();
  handleResize();
  if (props.active) {
    await fetchData();
    startVersionPolling();
  }
  window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
  stopVersionPolling();
  window.removeEventListener("resize", handleResize);
  if (chart) chart.dispose();
  chart = null;
});

defineExpose({
  getDataURL: (opts) => (chart ? chart.getDataURL(opts) : ""),
  resize: handleResize,
});
</script>

<style scoped>
.dish-features-panel {
  position: relative;
  width: 100%;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 10px 6px 10px;
}

.stats {
  font-size: 14px;
  color: #666;
  display: flex;
  align-items: center;
  gap: 10px;
}

.legend {
  padding: 0 10px 6px 10px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.legend-item {
  font-size: 12px;
  color: #666;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
}
</style>
