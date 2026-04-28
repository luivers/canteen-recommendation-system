<template>
  <div class="analysis-panel">
    <!-- 筛选工具栏 -->
    <div class="filter-toolbar">
      <el-form :inline="true" class="filter-form">
        <el-form-item label="食堂">
          <el-select v-model="canteenId" placeholder="所有食堂" clearable style="width: 140px">
            <el-option v-for="canteen in canteens" :key="canteen.id" :label="canteen.name" :value="canteen.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="窗口">
          <el-select v-model="windowId" placeholder="所有窗口" clearable :disabled="!canteenId" style="width: 140px">
            <el-option v-for="win in windows" :key="win.id" :label="win.name" :value="win.id" />
          </el-select>
        </el-form-item>

        <el-form-item label="分析窗口">
          <el-select v-model="windowDays" style="width: 120px">
            <el-option label="近30天" :value="30" />
            <el-option label="近60天" :value="60" />
            <el-option label="近90天" :value="90" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData" :loading="loading">分析</el-button>
          <el-button @click="resetFilters" :disabled="loading">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 概览卡片 -->
    <el-row :gutter="20" style="margin-bottom: 20px" v-if="summary">
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>总用户数</template>
          <div class="summary-value">{{ summary.totalUsers }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>平均消费</template>
          <div class="summary-value">¥{{ summary.avgSpent }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>平均订单数</template>
          <div class="summary-value">{{ summary.avgOrders }}</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>平均最近一次消费</template>
          <div class="summary-value">{{ summary.avgRecency }} 天前</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 分群列表 -->
    <el-table :data="segments" style="width: 100%" v-loading="loading" border>
      <el-table-column prop="segmentCode" label="分群类型" width="150">
        <template #default="scope">
          <el-tag :type="getSegmentTagType(scope.row.segmentCode)">{{ getSegmentName(scope.row.segmentCode) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="userCount" label="用户数" width="120" sortable />
      <el-table-column prop="avgSpent" label="平均消费金额" width="150" sortable>
        <template #default="scope">¥{{ scope.row.avgSpent.toFixed(2) }}</template>
      </el-table-column>
      <el-table-column prop="avgOrders" label="平均订单数" width="150" sortable>
        <template #default="scope">{{ scope.row.avgOrders.toFixed(1) }}</template>
      </el-table-column>
      <el-table-column prop="avgRecency" label="平均未消费天数" width="150" sortable>
        <template #default="scope">{{ scope.row.avgRecency.toFixed(1) }} 天</template>
      </el-table-column>
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button link type="primary" @click="viewUsers(scope.row)">查看用户</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 用户列表弹窗 -->
    <el-dialog v-model="dialogVisible" title="分群用户详情" width="70%">
      <el-table :data="userList" v-loading="usersLoading" border height="400">
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="totalSpent" label="总消费" width="120">
          <template #default="scope">¥{{ scope.row.totalSpent.toFixed(2) }}</template>
        </el-table-column>
        <el-table-column prop="orderCount" label="订单数" width="100" />
        <el-table-column prop="recencyDays" label="未消费天数" width="120" />
        <el-table-column prop="lastTime" label="最近消费时间" min-width="160">
           <template #default="scope">{{ formatDateTime(scope.row.lastTime) }}</template>
        </el-table-column>
      </el-table>
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total="totalUsers"
          layout="total, prev, pager, next"
          @current-change="handlePageChange"
        />
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { statisticsApi } from '@/api/statistics';
import canteenApi from '@/api/canteen';
import { windowApi } from '@/api/window';
import { ElMessage } from 'element-plus';

const loading = ref(false);
const windowDays = ref(30);
const canteenId = ref(null);
const windowId = ref(null);
const segments = ref([]);
const summary = ref(null);
const canteens = ref([]);
const windows = ref([]);

const dialogVisible = ref(false);
const usersLoading = ref(false);
const userList = ref([]);
const currentSegment = ref('');
const currentPage = ref(1);
const pageSize = ref(20);
const totalUsers = ref(0);

const getSegmentTagType = (code) => {
  const map = {
    'VIP': 'danger',
    'ACTIVE': 'success',
    'NEW': 'info',
    'RISK': 'warning',
    'DORMANT': 'warning',
    'NORMAL': 'info'
  };
  const key = (code || '').toUpperCase();
  return map[key];
};

const getSegmentName = (code) => {
  const map = {
    'VIP': '高价值活跃学生',
    'ACTIVE': '活跃学生',
    'NEW': '新入学生',
    'RISK': '流失风险学生',
    'DORMANT': '沉默学生',
    'NORMAL': '普通学生'
  };
  const key = (code || '').toUpperCase();
  return map[key] || code;
};

const formatDateTime = (str) => {
  if(!str) return '';
  return new Date(str).toLocaleString();
}

const fetchCanteens = async () => {
  try {
    const res = await canteenApi.getAll();
    canteens.value = res.data;
  } catch (error) {
    console.error('Failed to fetch canteens:', error);
  }
};

const fetchWindows = async () => {
  if (!canteenId.value) {
    windows.value = [];
    windowId.value = null;
    return;
  }
  try {
    const res = await windowApi.getWindowsByCanteenId(canteenId.value);
    windows.value = res.data;
  } catch (error) {
    console.error('Failed to fetch windows:', error);
  }
};

watch(canteenId, () => {
  windowId.value = null;
  fetchWindows();
});

const fetchData = async () => {
  loading.value = true;
  try {
    const res = await statisticsApi.getUserSegmentationAdvanced(
      windowDays.value,
      canteenId.value,
      windowId.value
    );
    const rawSegments = Array.isArray(res?.data?.segments) ? res.data.segments : [];
    segments.value = rawSegments.map((item) => {
      const metrics = item?.metrics || {};
      return {
        segmentCode: item?.code || item?.segmentCode || '',
        userCount: Number(item?.count ?? item?.userCount ?? 0),
        avgSpent: Number(metrics?.avgSpend ?? item?.avgSpent ?? 0),
        avgOrders: Number(metrics?.avgOrders ?? item?.avgOrders ?? 0),
        avgRecency: Number(metrics?.avgRecencyDays ?? item?.avgRecency ?? 0)
      };
    });
    summary.value = res?.data?.summary || null;
  } catch (error) {
    console.error('Failed to fetch user segmentation:', error);
    ElMessage.error('获取用户分群失败');
  } finally {
    loading.value = false;
  }
};

const resetFilters = () => {
  windowDays.value = 30;
  canteenId.value = null;
  windowId.value = null;
  fetchData();
};

const viewUsers = (row) => {
  currentSegment.value = row.segmentCode;
  currentPage.value = 1;
  dialogVisible.value = true;
  fetchUsers();
};

const fetchUsers = async () => {
  usersLoading.value = true;
  try {
    const res = await statisticsApi.getUserSegmentationUsers(
      currentSegment.value,
      windowDays.value,
      canteenId.value,
      windowId.value,
      currentPage.value - 1, // backend uses 0-based page
      pageSize.value
    );
    const rawUsers = Array.isArray(res?.data?.content) ? res.data.content : [];
    userList.value = rawUsers.map((item) => ({
      username: item?.username ?? '未知用户',
      totalSpent: Number(item?.spend ?? item?.totalSpent ?? 0),
      orderCount: Number(item?.orders ?? item?.orderCount ?? 0),
      recencyDays: Number(item?.recencyDays ?? 0),
      lastTime: item?.lastOrderAt ?? item?.lastTime ?? null
    }));
    totalUsers.value = Number(res?.data?.total ?? res?.data?.totalElements ?? 0);
  } catch (error) {
    console.error('Failed to fetch segment users:', error);
    ElMessage.error('获取用户列表失败');
  } finally {
    usersLoading.value = false;
  }
};

const handlePageChange = (val) => {
  currentPage.value = val;
  fetchUsers();
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
.summary-value {
  font-size: 24px;
  font-weight: bold;
  text-align: center;
  color: #409EFF;
}
.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
