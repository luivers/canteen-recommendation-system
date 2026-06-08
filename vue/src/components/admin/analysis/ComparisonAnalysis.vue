<template>
  <div class="analysis-panel">
    <!-- 筛选工具栏 -->
    <div class="filter-toolbar">
      <el-form :inline="true" class="filter-form">
        <!-- Group 1 -->
        <el-form-item label="食堂1">
          <el-select v-model="canteenId1" placeholder="所有食堂" clearable style="width: 120px">
            <el-option v-for="canteen in canteens" :key="canteen.id" :label="canteen.name" :value="canteen.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="窗口1">
          <el-select v-model="windowId1" placeholder="所有窗口" clearable :disabled="!canteenId1" style="width: 120px">
            <el-option v-for="win in windows1" :key="win.id" :label="win.name" :value="win.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="时段1">
          <el-select v-model="timeRange1" style="width: 120px">
             <el-option label="今天" value="today" />
            <el-option label="昨天" value="yesterday" />
            <el-option label="本周" value="week" />
            <el-option label="上周" value="last_week" />
             <el-option label="本月" value="month" />
             <el-option label="上月" value="last_month" />
          </el-select>
        </el-form-item>
        
        <!-- Group 2 -->
        <el-form-item label="食堂2">
          <el-select v-model="canteenId2" placeholder="所有食堂" clearable style="width: 120px">
            <el-option v-for="canteen in canteens" :key="canteen.id" :label="canteen.name" :value="canteen.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="窗口2">
          <el-select v-model="windowId2" placeholder="所有窗口" clearable :disabled="!canteenId2" style="width: 120px">
            <el-option v-for="win in windows2" :key="win.id" :label="win.name" :value="win.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="时段2">
           <el-select v-model="timeRange2" style="width: 120px">
             <el-option label="今天" value="today" />
            <el-option label="昨天" value="yesterday" />
            <el-option label="本周" value="week" />
            <el-option label="上周" value="last_week" />
             <el-option label="本月" value="month" />
             <el-option label="上月" value="last_month" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-checkbox v-model="includeBreakdowns">包含细分数据</el-checkbox>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="fetchData" :loading="loading">对比</el-button>
          <el-button @click="resetFilters" :disabled="loading">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 对比结果 -->
    <div v-if="result" class="comparison-content">
      <el-row :gutter="20">
        <!-- 营收对比 -->
        <el-col :span="8">
          <el-card shadow="hover" class="metric-card">
            <template #header>总营收</template>
            <div class="metric-row">
              <span class="label">时段1:</span>
              <span class="value">¥{{ Number(result.metrics1.revenue || 0).toFixed(2) }}</span>
            </div>
            <div class="metric-row">
              <span class="label">时段2:</span>
              <span class="value">¥{{ Number(result.metrics2.revenue || 0).toFixed(2) }}</span>
            </div>
            <el-divider />
            <div class="metric-change" :class="getChangeClass(result.metrics.revenue.deltaPct)">
              环比增长: {{ Number(result.metrics.revenue.deltaPct || 0).toFixed(1) }}%
              <el-icon v-if="result.metrics.revenue.deltaPct >= 0"><Top /></el-icon>
              <el-icon v-else><Bottom /></el-icon>
            </div>
          </el-card>
        </el-col>

        <!-- 订单数对比 -->
        <el-col :span="8">
          <el-card shadow="hover" class="metric-card">
            <template #header>总订单数</template>
            <div class="metric-row">
              <span class="label">时段1:</span>
              <span class="value">{{ Number(result.metrics1.orders || 0) }}</span>
            </div>
            <div class="metric-row">
              <span class="label">时段2:</span>
              <span class="value">{{ Number(result.metrics2.orders || 0) }}</span>
            </div>
             <el-divider />
            <div class="metric-change" :class="getChangeClass(result.metrics.orders.deltaPct)">
              环比增长: {{ Number(result.metrics.orders.deltaPct || 0).toFixed(1) }}%
               <el-icon v-if="result.metrics.orders.deltaPct >= 0"><Top /></el-icon>
              <el-icon v-else><Bottom /></el-icon>
            </div>
          </el-card>
        </el-col>

        <!-- 客单价对比 -->
        <el-col :span="8">
          <el-card shadow="hover" class="metric-card">
            <template #header>平均客单价</template>
            <div class="metric-row">
              <span class="label">时段1:</span>
              <span class="value">¥{{ Number(result.metrics1.avgOrderValue || 0).toFixed(2) }}</span>
            </div>
            <div class="metric-row">
              <span class="label">时段2:</span>
              <span class="value">¥{{ Number(result.metrics2.avgOrderValue || 0).toFixed(2) }}</span>
            </div>
             <el-divider />
            <div class="metric-change" :class="getChangeClass(result.metrics.avgOrderValue.deltaPct)">
              环比增长: {{ Number(result.metrics.avgOrderValue.deltaPct || 0).toFixed(1) }}%
               <el-icon v-if="result.metrics.avgOrderValue.deltaPct >= 0"><Top /></el-icon>
              <el-icon v-else><Bottom /></el-icon>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 细分数据表格 -->
      <div v-if="result.breakdowns" class="breakdown-section">
        <el-divider content-position="left">详细对比数据</el-divider>
        
        <el-tabs type="border-card">
          <!-- 品类对比 -->
          <el-tab-pane label="按品类">
            <el-table
              :data="result.breakdowns.byCategory"
              stripe
              style="width: 100%"
              :default-sort="{ prop: 'delta', order: 'descending' }"
              empty-text="暂无品类对比数据"
            >
              <el-table-column prop="name" label="品类名称" />
              <el-table-column prop="a" label="时段1销量" sortable>
                <template #default="scope">¥{{ Number(scope.row.a || 0).toFixed(2) }}</template>
              </el-table-column>
              <el-table-column prop="b" label="时段2销量" sortable>
                <template #default="scope">¥{{ Number(scope.row.b || 0).toFixed(2) }}</template>
              </el-table-column>
              <el-table-column prop="delta" label="变化量" sortable>
                <template #default="scope">
                  <span :class="getChangeClass(scope.row.delta)">
                    {{ scope.row.delta > 0 ? '+' : '' }}{{ Number(scope.row.delta || 0).toFixed(2) }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column prop="deltaPct" label="变化率" sortable>
                <template #default="scope">
                  <span :class="getChangeClass(scope.row.deltaPct)" v-if="scope.row.deltaPct !== null">
                    {{ Number(scope.row.deltaPct || 0).toFixed(1) }}%
                  </span>
                  <span v-else>-</span>
                </template>
              </el-table-column>
            </el-table>
          </el-tab-pane>

          <!-- 窗口对比 -->
          <el-tab-pane label="按窗口">
            <el-table
              :data="result.breakdowns.byWindow"
              stripe
              style="width: 100%"
              :default-sort="{ prop: 'delta', order: 'descending' }"
              empty-text="暂无窗口对比数据"
            >
              <el-table-column prop="name" label="窗口名称" />
              <el-table-column prop="a" label="时段1销量" sortable>
                <template #default="scope">¥{{ Number(scope.row.a || 0).toFixed(2) }}</template>
              </el-table-column>
              <el-table-column prop="b" label="时段2销量" sortable>
                <template #default="scope">¥{{ Number(scope.row.b || 0).toFixed(2) }}</template>
              </el-table-column>
              <el-table-column prop="delta" label="变化量" sortable>
                <template #default="scope">
                  <span :class="getChangeClass(scope.row.delta)">
                    {{ scope.row.delta > 0 ? '+' : '' }}{{ Number(scope.row.delta || 0).toFixed(2) }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column prop="deltaPct" label="变化率" sortable>
                <template #default="scope">
                  <span :class="getChangeClass(scope.row.deltaPct)" v-if="scope.row.deltaPct !== null">
                    {{ Number(scope.row.deltaPct || 0).toFixed(1) }}%
                  </span>
                  <span v-else>-</span>
                </template>
              </el-table-column>
            </el-table>
          </el-tab-pane>

          <!-- 菜品对比 -->
          <el-tab-pane label="按菜品">
            <el-table
              :data="result.breakdowns.byDish"
              stripe
              style="width: 100%"
              :default-sort="{ prop: 'delta', order: 'descending' }"
              empty-text="暂无菜品对比数据"
            >
              <el-table-column prop="name" label="菜品名称" />
              <el-table-column prop="a" label="时段1销量" sortable>
                <template #default="scope">¥{{ Number(scope.row.a || 0).toFixed(2) }}</template>
              </el-table-column>
              <el-table-column prop="b" label="时段2销量" sortable>
                <template #default="scope">¥{{ Number(scope.row.b || 0).toFixed(2) }}</template>
              </el-table-column>
              <el-table-column prop="delta" label="变化量" sortable>
                <template #default="scope">
                  <span :class="getChangeClass(scope.row.delta)">
                    {{ scope.row.delta > 0 ? '+' : '' }}{{ Number(scope.row.delta || 0).toFixed(2) }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column prop="deltaPct" label="变化率" sortable>
                <template #default="scope">
                  <span :class="getChangeClass(scope.row.deltaPct)" v-if="scope.row.deltaPct !== null">
                    {{ Number(scope.row.deltaPct || 0).toFixed(1) }}%
                  </span>
                  <span v-else>-</span>
                </template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
        </el-tabs>
      </div>
    </div>
    <el-empty v-else-if="!loading" description="暂无对比分析数据" />
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { statisticsApi } from '@/api/statistics';
import canteenApi from '@/api/canteen';
import { windowApi } from '@/api/window';
import { ElMessage } from 'element-plus';
import { Top, Bottom } from '@element-plus/icons-vue';

const loading = ref(false);
const timeRange1 = ref('last_week');
const timeRange2 = ref('week');
const includeBreakdowns = ref(false);
const result = ref(null);

const canteenId1 = ref(null);
const windowId1 = ref(null);
const canteenId2 = ref(null);
const windowId2 = ref(null);

const canteens = ref([]);
const windows1 = ref([]);
const windows2 = ref([]);

const emptyMetricDelta = { delta: 0, deltaPct: 0 };

const normalizeMetricDelta = (raw) => ({
  delta: Number(raw?.delta ?? 0),
  deltaPct: Number(raw?.deltaPct ?? 0),
});

const normalizeBreakdownRows = (rows) => {
  const list = Array.isArray(rows) ? rows : [];
  return list
    .map((item) => ({
      name: String(item?.name ?? item?.label ?? '-').trim() || '-',
      a: Number(item?.a ?? item?.valueA ?? item?.first ?? 0),
      b: Number(item?.b ?? item?.valueB ?? item?.second ?? 0),
      delta: Number(item?.delta ?? 0),
      deltaPct: item?.deltaPct == null ? null : Number(item.deltaPct),
    }));
};

const normalizeComparisonResult = (raw) => {
  const data = raw || {};
  const metrics1 = data.metrics1 || {};
  const metrics2 = data.metrics2 || {};
  const metrics = data.metrics || {};
  const breakdowns = data.breakdowns || {};
  return {
    metrics1: {
      revenue: Number(metrics1?.revenue ?? 0),
      orders: Number(metrics1?.orders ?? 0),
      avgOrderValue: Number(metrics1?.avgOrderValue ?? 0),
    },
    metrics2: {
      revenue: Number(metrics2?.revenue ?? 0),
      orders: Number(metrics2?.orders ?? 0),
      avgOrderValue: Number(metrics2?.avgOrderValue ?? 0),
    },
    metrics: {
      revenue: normalizeMetricDelta(metrics?.revenue || emptyMetricDelta),
      orders: normalizeMetricDelta(metrics?.orders || emptyMetricDelta),
      avgOrderValue: normalizeMetricDelta(metrics?.avgOrderValue || emptyMetricDelta),
    },
    breakdowns:
      data.breakdowns || includeBreakdowns.value
        ? {
            byCategory: normalizeBreakdownRows(breakdowns?.byCategory),
            byWindow: normalizeBreakdownRows(breakdowns?.byWindow),
            byDish: normalizeBreakdownRows(breakdowns?.byDish),
          }
        : null,
  };
};

const fetchCanteens = async () => {
  try {
    const res = await canteenApi.getAll();
    canteens.value = Array.isArray(res?.data) ? res.data : [];
  } catch (error) {
    console.error('Failed to fetch canteens:', error);
  }
};

const fetchWindows1 = async () => {
  if (!canteenId1.value) {
    windows1.value = [];
    windowId1.value = null;
    return;
  }
  try {
    const res = await windowApi.getWindowsByCanteenId(canteenId1.value);
    windows1.value = Array.isArray(res?.data) ? res.data : [];
  } catch (error) {
    console.error('Failed to fetch windows 1:', error);
  }
};

const fetchWindows2 = async () => {
  if (!canteenId2.value) {
    windows2.value = [];
    windowId2.value = null;
    return;
  }
  try {
    const res = await windowApi.getWindowsByCanteenId(canteenId2.value);
    windows2.value = Array.isArray(res?.data) ? res.data : [];
  } catch (error) {
    console.error('Failed to fetch windows 2:', error);
  }
};

watch(canteenId1, () => {
  windowId1.value = null;
  fetchWindows1();
});

watch(canteenId2, () => {
  windowId2.value = null;
  fetchWindows2();
});

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await statisticsApi.getComparisonAnalysis(
      timeRange1.value,
      timeRange2.value,
      null, null, null, null, // dates
      includeBreakdowns.value,
      10, // topN
      canteenId1.value,
      windowId1.value,
      canteenId2.value,
      windowId2.value
    );
    result.value = normalizeComparisonResult(res?.data);
  } catch (error) {
    console.error('Failed to fetch comparison analysis:', error);
    ElMessage.error('对比分析失败');
  } finally {
    loading.value = false;
  }
};

const resetFilters = () => {
  timeRange1.value = 'last_week';
  timeRange2.value = 'week';
  includeBreakdowns.value = false;
  canteenId1.value = null;
  windowId1.value = null;
  canteenId2.value = null;
  windowId2.value = null;
  fetchData();
};

const getChangeClass = (val) => {
  return val >= 0 ? 'positive' : 'negative';
};

onMounted(() => {
  fetchCanteens();
  fetchData();
});
</script>

<style scoped>
.analysis-panel {
  padding: 20px;
}
.filter-toolbar {
  margin-bottom: 20px;
  background-color: #f5f7fa;
  padding: 15px;
  border-radius: 4px;
}
.metric-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 16px;
}
.metric-change {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  font-weight: bold;
}
.positive {
  color: #67C23A;
}
.negative {
  color: #F56C6C;
}
.breakdown-section {
  margin-top: 30px;
}
</style>
