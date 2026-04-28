<template>
  <div :style="{ height: height + 'px' }">
    <v-chart
      ref="chartRef"
      class="chart"
      :option="option"
      :loading="loading"
      :loading-options="loadingOptions"
      autoresize
    />
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from "vue";
import { statisticsApi } from "@/api/statistics";
import VChart from "vue-echarts";
import { use } from "echarts/core";
import { CanvasRenderer } from "echarts/renderers";
import { PieChart } from "echarts/charts";
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GraphicComponent,
} from "echarts/components";

use([
  CanvasRenderer,
  PieChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GraphicComponent,
]);

const props = defineProps({
  startDate: { type: String, default: "" },
  endDate: { type: String, default: "" },
  height: { type: Number, default: 360 },
  active: { type: Boolean, default: false },
  showLabels: { type: Boolean, default: false },
  refreshKey: { type: Number, default: 0 },
});

const chartRef = ref(null);
const loading = ref(false);
const option = ref({});
const lastData = ref([]);

// Loading 样式配置
const loadingOptions = {
  text: "加载中...",
  color: "#409EFF",
  textColor: "#666",
  maskColor: "rgba(255,255,255,0.6)",
};

defineExpose({
  getDataURL: (opts) => (chartRef.value ? chartRef.value.getDataURL(opts) : ""),
  resize: () => {
    if (chartRef.value) chartRef.value.resize();
  },
});

const CACHE_TTL_MS = 120000;
const cache = new Map();

const getCacheKey = () => `${props.startDate || ""}|${props.endDate || ""}`;

const getBaseOption = () => ({
  animation: true,
  animationDuration: 600,
  animationDurationUpdate: 500,
  color: [
    "#409EFF",
    "#67C23A",
    "#E6A23C",
    "#F56C6C",
    "#909399",
    "#8E44AD",
    "#16A085",
    "#2E86C1",
  ],
  tooltip: {
    trigger: "item",
    formatter: (p) =>
      `${p?.name || ""}<br/>金额：¥${Number(p?.value || 0).toFixed(2)}<br/>占比：${p?.percent ?? 0}%`,
  },
  legend: { top: 6, right: 10, type: "scroll" },
  series: [
    {
      name: "品类销售额",
      type: "pie",
      radius: ["35%", "70%"],
      center: ["50%", "55%"],
      avoidLabelOverlap: true,
      label: { show: false },
      labelLine: { show: false },
      data: [],
    },
  ],
});

// Initialize option
option.value = getBaseOption();

const showEmpty = (text) => {
  const base = getBaseOption();
  option.value = {
    ...base,
    graphic: [
      {
        id: "emptyText",
        type: "text",
        left: "center",
        top: "middle",
        style: { text: text || "暂无数据", fill: "#999", fontSize: 14 },
      },
    ],
  };
};

const mapCategoryLabel = (key) => {
  const k = (key == null ? "" : String(key)).trim();
  if (!k) return "其他";
  const map = {
    MAIN_DISH: "主食",
    MEAT_DISH: "荤菜",
    VEGETABLE: "素菜",
    SOUP: "汤类",
    SNACK: "小吃",
    DRINK: "饮品",
  };
  return map[k] || k;
};

const normalize = (raw) => {
  const list = Array.isArray(raw) ? raw : [];
  const categorySet = new Set();
  for (const row of list) {
    Object.keys(row || {}).forEach((k) => {
      if (k !== "date" && k !== "time" && k !== "label") categorySet.add(k);
    });
  }
  const rawCategories = Array.from(categorySet);
  const totals = new Map();
  for (const rawCat of rawCategories) {
    const label = mapCategoryLabel(rawCat);
    totals.set(label, 0);
  }
  for (const row of list) {
    for (const rawCat of rawCategories) {
      const label = mapCategoryLabel(rawCat);
      totals.set(label, (totals.get(label) || 0) + Number(row?.[rawCat] ?? 0));
    }
  }
  const data = Array.from(totals.entries())
    .map(([name, value]) => ({
      name,
      value: Number(Number(value || 0).toFixed(2)),
    }))
    .filter((x) => Number(x.value || 0) !== 0)
    .sort((a, b) => b.value - a.value);
  return { categories: data.map((x) => x.name), data };
};

const updateChart = (raw) => {
  const { categories, data } = normalize(raw);
  if (categories.length === 0 || data.length === 0) {
    showEmpty("暂无数据");
    return;
  }

  // Construct new option
  const base = getBaseOption();
  option.value = {
    ...base,
    legend: { ...base.legend, data: categories },
    series: [
      {
        ...base.series[0],
        data,
        label: {
          show: !!props.showLabels,
          formatter: (p) =>
            `${p?.name || ""}\n¥${Number(p?.value || 0).toFixed(0)} (${p?.percent ?? 0}%)`,
        },
        labelLine: { show: !!props.showLabels },
      },
    ],
  };
};

const cleanupCache = () => {
  for (const [k, v] of cache) {
    if (Date.now() - v.ts > CACHE_TTL_MS) cache.delete(k);
  }
};

const fetchData = async (options = {}) => {
  const { force = false, retry = 0 } = options;
  if (!props.active) return;
  if (!props.startDate || !props.endDate) return;

  const key = getCacheKey();
  const cached = cache.get(key);
  if (!force && cached && Date.now() - cached.ts <= CACHE_TTL_MS) {
    lastData.value = cached.data;
    updateChart(cached.data);
    return;
  }

  cleanupCache();
  loading.value = true;
  try {
    const res = await statisticsApi.getCategoryTrend(
      "custom",
      props.startDate,
      props.endDate,
    );
    const data = res?.data || [];
    cache.set(key, { ts: Date.now(), data });
    lastData.value = data;
    updateChart(data);
  } catch (e) {
    console.error("Fetch category trend failed:", e);
    if (retry < 1) {
      console.log("Retrying fetch category trend...");
      setTimeout(() => fetchData({ force, retry: retry + 1 }), 500);
    } else {
      showEmpty("加载失败");
    }
  } finally {
    loading.value = false;
  }
};

onMounted(async () => {
  await fetchData();
});

watch(
  () => [props.startDate, props.endDate, props.active],
  async () => {
    await fetchData();
  },
);

watch(
  () => props.showLabels,
  () => {
    updateChart(lastData.value);
  },
);

watch(
  () => props.refreshKey,
  async () => {
    await fetchData({ force: true });
  },
);
</script>

<style scoped>
.chart {
  height: 100%;
  width: 100%;
}
</style>
