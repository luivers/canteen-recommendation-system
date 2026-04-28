<template>
  <div class="orders-trend-wrapper">
    <div ref="countChartRef" :style="{ height: subChartHeight + 'px' }"></div>
    <div class="orders-trend-gap"></div>
    <div ref="amountChartRef" :style="{ height: subChartHeight + 'px' }"></div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref, watch, nextTick, computed } from "vue";
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

const countChartRef = ref(null);
const amountChartRef = ref(null);

let countChart = null;
let amountChart = null;

const GAP_PX = 12;
const subChartHeight = computed(() =>
  Math.max(200, Math.floor((Number(props.height || 0) - GAP_PX) / 2)),
);

defineExpose({
  getDataURL: (opts) => (countChart ? countChart.getDataURL(opts) : ""),
  resize: () => {
    if (countChart) countChart.resize();
    if (amountChart) amountChart.resize();
  },
});

const CACHE_TTL_MS = 120000;
const cache = new Map();

const getCacheKey = () => `${props.startDate || ""}|${props.endDate || ""}`;

const getCountOption = () => {
  return {
    animation: true,
    animationDuration: 600,
    animationDurationUpdate: 500,
    tooltip: {
      trigger: "axis",
      axisPointer: { type: "line" },
    },
    legend: {
      top: 6,
      right: 10,
      data: ["订单数量"],
    },
    grid: {
      left: 46,
      right: 20,
      top: 44,
      bottom: 22,
      containLabel: true,
    },
    xAxis: {
      type: "category",
      data: [],
      axisLabel: { color: "#666" },
      axisLine: { lineStyle: { color: "#E6E6E6" } },
    },
    yAxis: {
      type: "value",
      name: "订单数量",
      axisLabel: { color: "#666" },
      splitLine: { lineStyle: { color: "#F0F0F0" } },
    },
    dataZoom: [{ type: "inside", throttle: 50 }],
    series: [
      {
        name: "订单数量",
        type: "line",
        smooth: true,
        showSymbol: true,
        symbolSize: 6,
        data: [],
        lineStyle: { width: 3, color: "#409EFF" },
        itemStyle: { color: "#409EFF" },
        label: { show: false },
      },
    ],
  };
};

const getAmountOption = () => {
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
      data: ["订单金额"],
    },
    grid: {
      left: 46,
      right: 20,
      top: 44,
      bottom: 52,
      containLabel: true,
    },
    xAxis: {
      type: "category",
      data: [],
      axisLabel: { color: "#666" },
      axisLine: { lineStyle: { color: "#E6E6E6" } },
    },
    yAxis: {
      type: "value",
      name: "订单金额(¥)",
      axisLabel: { color: "#666", formatter: (v) => `¥${v}` },
      splitLine: { lineStyle: { color: "#F0F0F0" } },
    },
    dataZoom: [
      { type: "inside", throttle: 50 },
      { type: "slider", height: 18, bottom: 10 },
    ],
    series: [
      {
        name: "订单金额",
        type: "line",
        smooth: true,
        showSymbol: true,
        symbolSize: 6,
        data: [],
        lineStyle: { width: 3, color: "#67C23A" },
        itemStyle: { color: "#67C23A" },
        label: { show: false },
      },
    ],
  };
};

const initCharts = () => {
  if (!countChart && countChartRef.value) {
    countChart = echarts.init(countChartRef.value);
    countChart.setOption(getCountOption());
  }
  if (!amountChart && amountChartRef.value) {
    amountChart = echarts.init(amountChartRef.value);
    amountChart.setOption(getAmountOption());
  }

  if (countChart && amountChart) {
    let syncing = false;
    countChart.off("datazoom");
    amountChart.off("datazoom");

    const getZoomActionPayload = (batch, dataZoomIndex) => {
      if (!batch) return null;
      const payload = { type: "dataZoom", dataZoomIndex };
      if (batch.start != null && batch.end != null) {
        payload.start = batch.start;
        payload.end = batch.end;
      } else if (batch.startValue != null && batch.endValue != null) {
        payload.startValue = batch.startValue;
        payload.endValue = batch.endValue;
      } else {
        return null;
      }
      return payload;
    };

    const pickUsableBatch = (e) => {
      const batches = Array.isArray(e?.batch) ? e.batch : [];
      for (const b of batches) {
        if (
          (b?.start != null && b?.end != null) ||
          (b?.startValue != null && b?.endValue != null)
        ) {
          return b;
        }
      }
      return null;
    };

    const syncToCount = (e) => {
      if (syncing) return;
      const batch = pickUsableBatch(e);
      const payload = getZoomActionPayload(batch, 0);
      if (!payload) return;
      syncing = true;
      countChart.dispatchAction(payload);
      syncing = false;
    };

    const syncToAmount = (e) => {
      if (syncing) return;
      const batch = pickUsableBatch(e);
      const payload0 = getZoomActionPayload(batch, 0);
      const payload1 = getZoomActionPayload(batch, 1);
      if (!payload0) return;
      syncing = true;
      amountChart.dispatchAction(payload0);
      if (payload1) amountChart.dispatchAction(payload1);
      syncing = false;
    };

    amountChart.on("datazoom", syncToCount);
    countChart.on("datazoom", syncToAmount);
  }
};

const showLoading = () => {
  if (countChart) {
    countChart.showLoading("default", {
      text: "加载中...",
      color: "#409EFF",
      textColor: "#666",
      maskColor: "rgba(255,255,255,0.6)",
    });
  }
  if (amountChart) {
    amountChart.showLoading("default", {
      text: "加载中...",
      color: "#67C23A",
      textColor: "#666",
      maskColor: "rgba(255,255,255,0.6)",
    });
  }
};

const hideLoading = () => {
  if (countChart) countChart.hideLoading();
  if (amountChart) amountChart.hideLoading();
};

const showEmpty = (text) => {
  const msg = text || "暂无数据";
  if (countChart) {
    countChart.clear();
    countChart.setOption(getCountOption());
    countChart.setOption({
      graphic: [
        {
          type: "text",
          left: "center",
          top: "middle",
          style: { text: msg, fill: "#999", fontSize: 14 },
        },
      ],
    });
  }
  if (amountChart) {
    amountChart.clear();
    amountChart.setOption(getAmountOption());
    amountChart.setOption({
      graphic: [
        {
          type: "text",
          left: "center",
          top: "middle",
          style: { text: msg, fill: "#999", fontSize: 14 },
        },
      ],
    });
  }
};

const clearGraphics = () => {
  if (countChart) countChart.setOption({ graphic: [] });
  if (amountChart) amountChart.setOption({ graphic: [] });
};

const setSeriesLabelState = () => {
  if (countChart) {
    countChart.setOption({
      series: [{ name: "订单数量", label: { show: !!props.showLabels } }],
    });
  }
  if (amountChart) {
    amountChart.setOption({
      series: [{ name: "订单金额", label: { show: !!props.showLabels } }],
    });
  }
};

const updateCharts = (raw, granularity = "day") => {
  if (!countChart || !amountChart) return;
  const rows = normalizeRows(raw);
  if (rows.length === 0) {
    showEmpty("暂无数据");
    return;
  }

  const times = rows.map((r) => r.time);
  const counts = rows.map((r) => r.orderCount);
  const amounts = rows.map((r) => Number(r.orderAmount.toFixed(2)));

  let chartType = "line";
  let areaStyle = null;
  let barWidth = null;

  if (granularity === "day") {
    chartType = "line";
    areaStyle = { opacity: 0.2 };
  } else if (["week", "month", "quarter", "year"].includes(granularity)) {
    chartType = "bar";
    barWidth = "40%";
  }

  clearGraphics();
  countChart.setOption({
    xAxis: { data: times },
    tooltip: {
      formatter: (params) => {
        const list = Array.isArray(params) ? params : [];
        const header = list[0]?.axisValueLabel || "";
        const val = list[0]?.data ?? 0;
        return `${header}<br/>订单数量：${val}`;
      },
    },
    series: [
      {
        name: "订单数量",
        type: chartType,
        areaStyle: areaStyle,
        barWidth: barWidth,
        data: counts,
        label: { show: !!props.showLabels },
      },
    ],
  });

  amountChart.setOption({
    xAxis: { data: times },
    tooltip: {
      formatter: (params) => {
        const list = Array.isArray(params) ? params : [];
        const header = list[0]?.axisValueLabel || "";
        const val = list[0]?.data ?? 0;
        return `${header}<br/>订单金额：¥${Number(val || 0).toFixed(2)}`;
      },
    },
    series: [
      {
        name: "订单金额",
        type: chartType,
        areaStyle: areaStyle,
        barWidth: barWidth,
        data: amounts,
        label: { show: !!props.showLabels },
      },
    ],
  });
};

const normalizeRows = (raw) => {
  const arr = Array.isArray(raw) ? raw : [];
  return arr
    .map((r) => ({
      time: r?.time == null ? "" : String(r.time),
      orderCount: Number(r?.orderCount ?? r?.count ?? r?.value ?? r?.val ?? 0),
      orderAmount: Number(r?.orderAmount ?? r?.amount ?? 0),
    }))
    .filter((x) => x.time);
};

const cleanupCache = () => {
  for (const [k, v] of cache) {
    if (Date.now() - v.ts > CACHE_TTL_MS) {
      cache.delete(k);
    }
  }
};

const fetchData = async ({ force } = { force: false }) => {
  if (!props.active) return;
  if (!props.startDate || !props.endDate) return;
  initCharts();

  const key = getCacheKey();
  const cached = cache.get(key);
  if (!force && cached && Date.now() - cached.ts <= CACHE_TTL_MS) {
    updateCharts(cached.data, cached.granularity);
    return;
  }

  cleanupCache();
  showLoading();
  try {
    const res = await statisticsApi.getRevenueTrendDetail(
      "custom",
      props.startDate,
      props.endDate,
    );
    const payload = res?.data || {};
    const data = payload.data || [];
    const granularity = payload.granularity || "day";

    cache.set(key, { ts: Date.now(), data, granularity });
    updateCharts(data, granularity);
  } catch (e) {
    showEmpty("加载失败");
  } finally {
    hideLoading();
  }
};

const handleResize = () => {
  if (countChart) countChart.resize();
  if (amountChart) amountChart.resize();
};

onMounted(async () => {
  initCharts();
  await nextTick();
  handleResize();
  setSeriesLabelState();
  await fetchData();
  window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
  window.removeEventListener("resize", handleResize);
  if (countChart) countChart.dispose();
  if (amountChart) amountChart.dispose();
  countChart = null;
  amountChart = null;
});

watch(
  () => [props.startDate, props.endDate, props.active],
  async () => {
    await nextTick();
    if (props.active) handleResize();
    await fetchData();
  },
);

watch(
  () => props.showLabels,
  () => {
    setSeriesLabelState();
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
.orders-trend-wrapper {
  display: flex;
  flex-direction: column;
}

.orders-trend-gap {
  height: 12px;
}
</style>
