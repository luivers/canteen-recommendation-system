<template>
  <div v-loading="loading" class="review-keywords-panel">
    <div class="panel-header">
      <div class="left-controls">
        <el-radio-group
          v-model="currentSentiment"
          size="small"
          @change="handleSentimentChange"
        >
          <el-radio-button label="ALL">全部</el-radio-button>
          <el-radio-button label="GOOD">好评</el-radio-button>
          <el-radio-button label="BAD">差评</el-radio-button>
        </el-radio-group>
      </div>
      <div v-if="stats" class="stats">
        <span>总评论: {{ stats.totalReviews }}</span>
        <el-divider direction="vertical" />
        <span>命中: {{ stats.matchedReviews }}</span>
      </div>
    </div>

    <div
      ref="chartRef"
      :style="{ height: height - 40 + 'px', width: '100%' }"
    ></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from "vue";
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
const currentSentiment = ref("ALL"); // ALL, GOOD, BAD

const stats = ref({
  totalReviews: 0,
  matchedReviews: 0,
  keywords: [],
  sampleReviews: [],
});

const defaultCategoryMapping = {
  色香味: [
    "好吃",
    "美味",
    "香",
    "鲜",
    "味道好",
    "口感好",
    "色泽",
    "不错",
    "绝",
    "赞",
    "难吃",
    "咸",
    "淡",
    "凉",
    "腥",
    "不新鲜",
  ],
  卫生: ["干净", "卫生", "异物", "脏", "乱", "不卫生", "虫", "舒适", "整洁"],
  服务: ["服务好", "态度好", "热情", "慢", "快", "恶劣", "周到"],
  价格: ["实惠", "便宜", "贵", "性价比", "划算", "不划算"],
  环境: ["环境好", "吵", "安静", "舒适", "整洁"],
  分量: ["分量足", "量大", "量少", "吃不饱", "撑", "少"],
  速度: ["出餐快", "慢", "久", "排队"],
};

const filter = ref({
  dataSource: "BOTH",
  minRating: 0,
  includeKeywords: [],
  excludeKeywords: [],
  minWordLength: 2,
  minFrequency: 1,
  topN: 50,
  stopWords: [],
  categoryMapping: { ...defaultCategoryMapping },
  sentiment: "ALL",
});

const initChart = () => {
  if (!chartRef.value || chart) return;
  chart = echarts.init(chartRef.value);
};

const createSeededRandom = (seed) => {
  let state = seed % 2147483647;
  if (state <= 0) state += 2147483646;
  return () => {
    state = (state * 16807) % 2147483647;
    return (state - 1) / 2147483646;
  };
};

const hashToColor = (text) => {
  let hash = 0;
  for (let i = 0; i < text.length; i += 1) {
    hash = (hash * 31 + text.charCodeAt(i)) >>> 0;
  }
  const r = 60 + (hash & 0x7f);
  const g = 60 + ((hash >> 7) & 0x7f);
  const b = 60 + ((hash >> 14) & 0x7f);
  return `rgb(${r},${g},${b})`;
};

const updateChart = (keywords) => {
  if (!chart) return;
  chart.clear();

  const seed =
    currentSentiment.value === "GOOD"
      ? 2
      : currentSentiment.value === "BAD"
        ? 3
        : 1;
  const seededRandom = createSeededRandom(seed);

  const option = {
    tooltip: {
      show: true,
      formatter: "{b}: {c}",
    },
    series: [
      {
        type: "wordCloud",
        shape: "circle",
        left: "center",
        top: "center",
        width: "80%",
        height: "80%",
        sizeRange: [16, 70],
        rotationRange: [-45, 90],
        rotationStep: 45,
        gridSize: 10,
        drawOutOfBound: false,
        layoutAnimation: true,
        random: seededRandom,
        textStyle: {
          fontFamily: "sans-serif",
          fontWeight: "bold",
          color: (params) => hashToColor(params.name),
        },
        emphasis: {
          focus: "self",
          textStyle: {
            shadowBlur: 10,
            shadowColor: "#333",
          },
        },
        data: keywords,
      },
    ],
  };

  chart.setOption(option, { notMerge: true, lazyUpdate: false });
};

const fetchData = async () => {
  if (!props.active) return;
  loading.value = true;
  try {
    const payload = {
      startDate: props.startDate,
      endDate: props.endDate,
      ...filter.value,
      sentiment: currentSentiment.value,
    };
    const res = await statisticsApi.getReviewKeywordsPreview(payload);
    const data = res.data;
    stats.value = data;
    updateChart(data.keywords);
  } catch (e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

const handleSentimentChange = () => {
  fetchData();
};

watch(
  () => [props.startDate, props.endDate, props.active, props.refreshKey],
  () => {
    if (props.active) {
      nextTick(() => {
        if (chart) chart.resize();
      });
    }
    fetchData();
  },
);

onMounted(async () => {
  initChart();
  await nextTick();
  if (chart) chart.resize();
  fetchData();
  window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
  window.removeEventListener("resize", handleResize);
  if (chart) chart.dispose();
});

const handleResize = () => {
  if (chart) chart.resize();
};

defineExpose({
  getDataURL: (opts) => (chart ? chart.getDataURL(opts) : ""),
  resize: handleResize,
});
</script>

<style scoped>
.review-keywords-panel {
  position: relative;
  width: 100%;
}
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 10px 10px 10px;
}
.stats {
  font-size: 14px;
  color: #666;
  display: flex;
  align-items: center;
  gap: 10px;
}
</style>
