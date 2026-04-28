<template>
  <div class="analysis-panel">
    <!-- 筛选工具栏 -->
    <div class="filter-toolbar">
      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="日期">
          <el-date-picker
            v-model="filters.date"
            type="date"
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
            :clearable="false"
            style="width: 150px"
          />
        </el-form-item>

        <el-form-item label="菜品名称">
           <el-input v-model="filters.dishName" placeholder="输入菜品名称" clearable style="width: 200px" @keyup.enter="fetchData" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="fetchData" :loading="loading">检测</el-button>
          <el-button @click="resetFilters" :disabled="loading">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 异常列表 -->
    <el-table :data="anomalies" style="width: 100%" v-loading="loading" border>
      <el-table-column prop="dishName" label="菜品名称" min-width="150" sortable />
      <el-table-column prop="date" label="日期" width="120" sortable />
      <el-table-column prop="sales" label="今日销量" width="120" sortable />
      <el-table-column label="总供应量(库存+销量)" width="180">
        <template #default="scope">
          {{ scope.row.totalSupply }}
          <span v-if="scope.row.stock !== null" class="text-gray-400 text-xs">
             (剩余: {{ scope.row.stock }})
          </span>
        </template>
      </el-table-column>
      <el-table-column label="销售占比" width="200">
        <template #default="scope">
           <el-progress 
             :percentage="Math.min(scope.row.ratio * 100, 100)" 
             :status="scope.row.ratio >= 0.9 ? 'exception' : (scope.row.ratio >= 0.8 ? 'warning' : 'success')"
             :format="percentage => (scope.row.ratio * 100).toFixed(1) + '%'"
           />
        </template>
      </el-table-column>
      <el-table-column prop="alertMessage" label="预警信息" min-width="200" show-overflow-tooltip>
        <template #default="scope">
          <span v-if="scope.row.alertMessage" class="text-red-500 font-bold">{{ scope.row.alertMessage }}</span>
          <span v-else class="text-gray-400">-</span>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { statisticsApi } from '@/api/statistics';
import { ElMessage } from 'element-plus';

const loading = ref(false);
const anomalies = ref([]);

const getToday = () => {
  const date = new Date();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

const filters = reactive({
  date: getToday(),
  dishName: ''
});

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await statisticsApi.getInventoryWarning(
      filters.date,
      filters.dishName
    );
    anomalies.value = res.data;
    if (anomalies.value.length === 0) {
        // Optional: show info only if user manually clicked search, or just keep silent to avoid noise on load
    }
  } catch (error) {
    console.error('Failed to fetch inventory warning:', error);
    ElMessage.error('获取库存预警失败');
  } finally {
    loading.value = false;
  }
};

const resetFilters = () => {
  filters.date = getToday();
  filters.dishName = '';
  fetchData();
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
.text-gray-400 {
    color: #9ca3af;
}
.text-xs {
    font-size: 0.75rem;
}
.text-red-500 {
    color: #ef4444;
}
.font-bold {
    font-weight: 700;
}
</style>
