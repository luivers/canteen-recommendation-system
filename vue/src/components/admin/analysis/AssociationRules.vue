<template>
  <div class="analysis-panel">
    <!-- 筛选工具栏 -->
    <div class="filter-toolbar">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="时间范围">
          <el-select v-model="filters.timeRange" style="width: 120px">
            <el-option label="今天" value="today" />
            <el-option label="近7天" value="week" />
            <el-option label="近30天" value="month" />
            <el-option label="自定义" value="custom" />
          </el-select>
        </el-form-item>
        
        <el-form-item v-if="filters.timeRange === 'custom'">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>

        <el-form-item label="层级">
          <el-select v-model="filters.level" style="width: 100px">
            <el-option label="菜品" value="dish" />
            <el-option label="品类" value="category" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="fetchData" :loading="loading">分析</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 数据表格 -->
    <el-table :data="rules" style="width: 100%" v-loading="loading" border>
      <el-table-column prop="pairName" label="菜品搭配组合" min-width="300">
        <template #default="scope">
           <el-tag effect="plain">{{ scope.row.itemA }}</el-tag> 
           <span class="mx-2">+</span> 
           <el-tag effect="plain">{{ scope.row.itemB }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="count" label="搭配订单数" width="150" sortable />
      <el-table-column prop="support" label="占总订单比例" width="250" sortable>
        <template #default="scope">
          <div class="flex items-center">
            <el-progress 
              :percentage="Math.min(scope.row.support * 100, 100)" 
              :format="() => scope.row.percentage"
              style="width: 150px; margin-right: 10px"
            />
          </div>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue';
import { statisticsApi } from '@/api/statistics';
import { ElMessage } from 'element-plus';

const loading = ref(false);
const rules = ref([]);
const dateRange = ref([]);

const filters = reactive({
  timeRange: 'week',
  minSupport: 0.01, // 默认1%
  topN: 50,
  level: 'dish'
});

const resetFilters = () => {
  filters.timeRange = 'week';
  filters.minSupport = 0.01;
  filters.topN = 50;
  filters.level = 'dish';
  dateRange.value = [];
  rules.value = [];
  fetchData();
};

const fetchData = async () => {
  loading.value = true;
  try {
    let startDate = null;
    let endDate = null;
    if (filters.timeRange === 'custom' && dateRange.value && dateRange.value.length === 2) {
      startDate = dateRange.value[0];
      endDate = dateRange.value[1];
    }

    const res = await statisticsApi.getAssociationRules(
      filters.timeRange,
      startDate,
      endDate,
      filters.minSupport,
      null, // minConfidence not used
      null, // minLift not used
      filters.topN,
      filters.level
    );
    
    // 后端现在返回 List<Map>，包含 itemA, itemB, count, support, percentage
    rules.value = Array.isArray(res?.data) ? res.data : [];

  } catch (error) {
    console.error('Failed to fetch pairings:', error);
    ElMessage.error('获取菜品搭配数据失败');
  } finally {
    setTimeout(() => {
      loading.value = false;
    }, 100);
  }
};

onMounted(() => {
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
.filter-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.mx-2 {
  margin: 0 8px;
  color: #909399;
  font-weight: bold;
}
.flex {
  display: flex;
}
.items-center {
  align-items: center;
}
</style>
