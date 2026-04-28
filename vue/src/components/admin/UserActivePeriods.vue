<template>
  <div class="active-periods-wrapper">
    <div class="active-periods-summary">
      <span>总活跃量：{{ totalActive }}</span>
    </div>
    <div ref="chartRef" :style="{ height: chartHeight + 'px' }"></div>
    <el-table
      :data="tableRows"
      size="small"
      style="width: 100%; margin-top: 12px"
    >
      <el-table-column prop="time" label="时段" width="120" />
      <el-table-column prop="value" label="活跃量" width="120" />
      <el-table-column prop="percent" label="占比" />
    </el-table>
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

const chartHeight = computed(() =>
  Math.max(260, Number(props.height || 0) - 240),
);
const chartRef = ref(null);
let chart = null;

defineExpose({
  getDataURL: (opts) => (chart ? chart.getDataURL(opts) : ""),
  resize: () => {
    if (chart) chart.resize();
  },
});

const CACHE_TTL_MS = 120000;
const cache = new Map();

const rawData = ref([]);

const normalized = computed(() => {
  const list = Array.isArray(rawData.value) ? rawData.value : [];
  const map = new Map();
  for (const item of list) {
    const time = item?.time == null ? "" : String(item.time);
    const value = Number(item?.value ?? 0);
    if (time) map.set(time, value);
  }
  const rows = [];
  for (let i = 0; i < 24; i++) {
    const key = `${i}-${i + 1}`;
    rows.push({ time: key, value: map.get(key) ?? 0 });
  }
  return rows;
});

const totalActive = computed(() =>
  normalized.value.reduce((s, r) => s + Number(r.value || 0), 0),
);

const tableRows = computed(() => {
  const total = totalActive.value || 0;
  return normalized.value.map((r) => ({
    time: r.time,
    value: r.value,
    percent: total > 0 ? `${((r.value / total) * 100).toFixed(1)}%` : "0.0%",
  }));
});

const getCacheKey = () => `${props.startDate || ""}|${props.endDate || ""}`;

const getBaseOption = () => {
  return {
    animation: true,
    animationDuration: 600,
    animationDurationUpdate: 500,
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "shadow" },
    },
    grid: {
      left: 40,
      right: 20,
      top: 20,
      bottom: 30,
      containLabel: true,
    },
    xAxis: {
      type: "category",
      data: [],
      axisLabel: { color: "#666", interval: 1 },
      axisLine: { lineStyle: { color: "#E6E6E6" } },
    },
    yAxis: {
      type: "value",
      axisLabel: { color: "#666" },
      splitLine: { lineStyle: { color: "#F0F0F0" } },
    },
    series: [
      {
        name: "活跃量",
        type: "bar",
        data: [],
        barMaxWidth: 18,
        itemStyle: { color: "#409EFF" },
        label: { show: false, position: "top" },
      },
    ],
  };
};

const initChart = () => {
  if (!chartRef.value || chart) return;
  chart = echarts.init(chartRef.value);
  chart.setOption(getBaseOption());
};

const showLoading = () => {
  if (!chart) return;
  chart.showLoading("default", {
    text: "加载中...",
    color: "#409EFF",
    textColor: "#666",
    maskColor: "rgba(255,255,255,0.6)",
  });
};

const hideLoading = () => {
  if (!chart) return;
  chart.hideLoading();
};

const showEmpty = (text) => {
  if (!chart) return;
  chart.clear();
  chart.setOption(getBaseOption());
  chart.setOption({
    graphic: [
      {
        id: "emptyText",
        type: "text",
        left: "center",
        top: "middle",
        style: { text: text || "暂无数据", fill: "#999", fontSize: 14 },
      },
    ],
  });
};

const updateChart = () => {
  if (!chart) return;
  const rows = normalized.value;
  const values = rows.map((r) => r.value);
  const hasAny = values.some((v) => Number(v || 0) > 0);
  if (!hasAny) {
    showEmpty("暂无数据");
    return;
  }
  chart.setOption({
    graphic: [{ id: "emptyText", $action: "remove" }],
    xAxis: { data: rows.map((r) => r.time) },
    series: [
      {
        name: "活跃量",
        data: values,
        label: { show: !!props.showLabels },
      },
    ],
  });
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
  initChart();

  const key = getCacheKey();
  const cached = cache.get(key);
  if (!force && cached && Date.now() - cached.ts <= CACHE_TTL_MS) {
    rawData.value = cached.data;
    updateChart();
    return;
  }

  cleanupCache();
  showLoading();
  try {
    const res = await statisticsApi.getUserActivePeriods(
      "custom",
      props.startDate,
      props.endDate,
    );
    const data = res?.data || [];
    cache.set(key, { ts: Date.now(), data });
    rawData.value = data;
    updateChart();
  } catch (e) {
    console.error("Fetch user active periods failed:", e);
    if (retry < 1) {
      console.log("Retrying fetch user active periods...");
      setTimeout(() => fetchData({ force, retry: retry + 1 }), 500);
    } else {
      showEmpty("加载失败");
    }
  } finally {
    hideLoading();
  }
};

const handleResize = () => {
  if (chart) chart.resize();
};

onMounted(async () => {
  initChart();
  await nextTick();
  handleResize();
  await fetchData();
  window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
  window.removeEventListener("resize", handleResize);
  if (chart) chart.dispose();
  chart = null;
});

watch(
  () => [props.startDate, props.endDate, props.active],
  async () => {
    if (props.active) {
      await nextTick();
      handleResize();
      // Ensure resize happens after transition
      setTimeout(() => {
        handleResize();
      }, 200);
    }
    await fetchData();
  },
);

watch(
  () => props.showLabels,
  () => {
    updateChart();
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
.active-periods-wrapper {
  width: 100%;
}

.active-periods-summary {
  height: 28px;
  display: flex;
  align-items: center;
  color: #666;
  font-size: 13px;
}
</style>
