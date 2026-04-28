<template>
  <div class="page">
    <el-card class="filter-card">
      <template #header>
        <div class="card-header">
          <span>兑换订单</span>
          <el-button type="primary" @click="loadStats">刷新统计</el-button>
        </div>
      </template>

      <div v-loading="loadingStats" class="stats">
        <el-statistic title="订单数" :value="stats.total" />
        <el-statistic title="消耗积分" :value="stats.pointsUsed" />
        <el-statistic
          title="代金券面值合计"
          :value="formatMoney(stats.faceValue)"
        />
      </div>

      <el-form :inline="true" :model="filters" class="filter-form">
        <el-form-item label="状态">
          <el-select
            v-model="filters.status"
            clearable
            style="width: 120px"
            @change="reload"
          >
            <el-option label="待处理" value="PENDING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
            <el-option label="失败" value="FAILED" />
          </el-select>
        </el-form-item>
        <el-form-item label="用户名称">
          <el-input
            v-model="filters.username"
            placeholder="用户名称"
            style="width: 140px"
            @keyup.enter="reload"
          />
        </el-form-item>
        <el-form-item label="分类">
          <el-select
            v-model="filters.categoryId"
            clearable
            style="width: 140px"
            placeholder="选择分类"
            @change="reload"
          >
            <el-option
              v-for="c in categories"
              :key="c.id"
              :label="c.name"
              :value="c.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="奖品名称">
          <el-input
            v-model="filters.rewardName"
            placeholder="奖品名称"
            style="width: 140px"
            @keyup.enter="reload"
          />
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="filters.range"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始"
            end-placeholder="结束"
            @change="reload"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="reload">查询</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card>
      <el-table v-loading="loading" :data="rows" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column label="用户" width="120">
          <template #default="scope">
            {{ scope.row.user?.username || scope.row.user?.id || "-" }}
          </template>
        </el-table-column>
        <el-table-column label="奖品" min-width="160">
          <template #default="scope">
            {{ scope.row.reward?.name || "-" }}
          </template>
        </el-table-column>
        <el-table-column label="分类" width="100">
          <template #default="scope">
            {{ scope.row.reward?.category?.name || "-" }}
          </template>
        </el-table-column>
        <el-table-column label="积分" width="90">
          <template #default="scope">
            {{
              scope.row.pointsUsed ?? scope.row.reward?.pointsRequired ?? "-"
            }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="110">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">{{
              getStatusText(scope.row.status)
            }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="发货状态" width="120">
          <template #default="scope">
            <el-tag
              :type="getDeliveryStatusType(scope.row.deliveryStatus)"
              effect="plain"
              >{{ getDeliveryStatusText(scope.row.deliveryStatus) }}</el-tag
            >
          </template>
        </el-table-column>
        <el-table-column label="已使用" width="90">
          <template #default="scope">
            {{ scope.row.used ? "是" : "否" }}
          </template>
        </el-table-column>
        <el-table-column label="抵扣金额" width="110">
          <template #default="scope">
            <span v-if="scope.row.deductionAmount != null"
              >¥{{ formatMoney(scope.row.deductionAmount) }}</span
            >
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="关联订单" width="120">
          <template #default="scope">
            {{ scope.row.usedOrderId ?? "-" }}
          </template>
        </el-table-column>
        <el-table-column label="兑换时间" width="170">
          <template #default="scope">
            {{ formatTime(scope.row.exchangeTime) }}
          </template>
        </el-table-column>
        <el-table-column label="使用时间" width="170">
          <template #default="scope">
            {{ formatTime(scope.row.usedTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="210" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="openDelivery(scope.row)"
              >发货状态</el-button
            >
            <el-button size="small" @click="openStatus(scope.row)"
              >订单状态</el-button
            >
          </template>
        </el-table-column>
      </el-table>

      <div v-if="pagination.total > 0" class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          background
          layout="prev, pager, next"
          :total="pagination.total"
          :page-size="pagination.size"
          @current-change="loadData"
        />
      </div>
    </el-card>

    <el-dialog
      v-model="deliveryDialogVisible"
      title="更新发货状态"
      width="520px"
    >
      <el-form :model="deliveryForm" label-width="110px">
        <el-form-item label="发货状态">
          <el-select v-model="deliveryForm.deliveryStatus" style="width: 220px">
            <el-option label="待处理" value="PENDING" />
            <el-option label="已发货" value="SHIPPED" />
            <el-option label="已送达" value="DELIVERED" />
            <el-option label="失败" value="FAILED" />
          </el-select>
        </el-form-item>
        <el-form-item label="发货信息">
          <el-input
            v-model="deliveryForm.deliveryInfo"
            type="textarea"
            :rows="3"
            placeholder="快递公司/单号/备注等"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="deliveryDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="saveDelivery"
          >保存</el-button
        >
      </template>
    </el-dialog>

    <el-dialog v-model="statusDialogVisible" title="更新订单状态" width="520px">
      <el-form :model="statusForm" label-width="110px">
        <el-form-item label="订单状态">
          <el-select v-model="statusForm.status" style="width: 220px">
            <el-option label="待处理" value="PENDING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
            <el-option label="失败" value="FAILED" />
          </el-select>
        </el-form-item>
        <el-form-item label="错误码">
          <el-input v-model="statusForm.errorCode" />
        </el-form-item>
        <el-form-item label="错误信息">
          <el-input v-model="statusForm.errorMsg" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="statusDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="saveStatus"
          >保存</el-button
        >
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { ElMessage } from "element-plus";
import dayjs from "dayjs";
import { rewardsApi } from "@/api/rewards";

const loading = ref(false);
const saving = ref(false);
const loadingStats = ref(false);

const filters = reactive({
  status: "",
  username: "",
  rewardName: "",
  categoryId: "",
  range: [],
});

const categories = ref([]);

const pagination = reactive({
  page: 1,
  size: 10,
  total: 0,
});

const rows = ref([]);

const stats = reactive({
  total: 0,
  pointsUsed: 0,
  faceValue: 0,
});

const selectedRow = ref(null);
const deliveryDialogVisible = ref(false);
const statusDialogVisible = ref(false);

const deliveryForm = reactive({
  deliveryStatus: "PENDING",
  deliveryInfo: "",
});

const statusForm = reactive({
  status: "PENDING",
  errorCode: "",
  errorMsg: "",
});

const formatTime = (time) => {
  if (!time) return "-";
  return dayjs(time).format("YYYY-MM-DD HH:mm");
};

const formatMoney = (v) => {
  const n = Number(v);
  if (Number.isNaN(n)) return v;
  return n.toFixed(2);
};

const getStatusType = (status) => {
  switch (status) {
    case "COMPLETED":
      return "success";
    case "PENDING":
      return "warning";
    case "CANCELLED":
      return "info";
    case "FAILED":
      return "danger";
    default:
      return "";
  }
};

const getStatusText = (status) => {
  switch (status) {
    case "COMPLETED":
      return "已完成";
    case "PENDING":
      return "待处理";
    case "CANCELLED":
      return "已取消";
    case "FAILED":
      return "失败";
    default:
      return status;
  }
};

const getDeliveryStatusType = (status) => {
  switch (status) {
    case "DELIVERED":
      return "success";
    case "SHIPPED":
      return "primary";
    case "PENDING":
      return "info";
    case "FAILED":
      return "danger";
    default:
      return "info";
  }
};

const getDeliveryStatusText = (status) => {
  switch (status) {
    case "DELIVERED":
      return "已送达";
    case "SHIPPED":
      return "已发货";
    case "PENDING":
      return "待发货";
    case "FAILED":
      return "失败";
    default:
      return "待发货";
  }
};

const loadCategories = async () => {
  try {
    const res = await rewardsApi.admin.listCategories();
    categories.value = res?.data?.data || [];
  } catch (e) {
    console.error(e);
  }
};

const loadData = async () => {
  loading.value = true;
  try {
    const startDate =
      Array.isArray(filters.range) && filters.range.length === 2
        ? filters.range[0]
        : undefined;
    const endDate =
      Array.isArray(filters.range) && filters.range.length === 2
        ? filters.range[1]
        : undefined;
    const res = await rewardsApi.admin.pageExchanges({
      page: pagination.page - 1,
      size: pagination.size,
      status: filters.status || undefined,
      username: filters.username || undefined,
      rewardName: filters.rewardName || undefined,
      categoryId: filters.categoryId || undefined,
      startDate,
      endDate,
    });
    const data = res?.data?.data || {};
    rows.value = data.content || [];
    pagination.total = data.total || 0;
  } catch (e) {
    rows.value = [];
    pagination.total = 0;
    ElMessage.error("加载兑换订单失败");
  } finally {
    loading.value = false;
  }
};

const reload = () => {
  pagination.page = 1;
  loadData();
  loadStats();
};

const resetFilters = () => {
  filters.status = "";
  filters.username = "";
  filters.rewardName = "";
  filters.categoryId = "";
  filters.range = [];
  reload();
};

const loadStats = async () => {
  loadingStats.value = true;
  try {
    const startDate =
      Array.isArray(filters.range) && filters.range.length === 2
        ? filters.range[0]
        : undefined;
    const endDate =
      Array.isArray(filters.range) && filters.range.length === 2
        ? filters.range[1]
        : undefined;
    const res = await rewardsApi.admin.getExchangeStats({ startDate, endDate });
    const data = res?.data?.data || {};
    stats.total = data.total || 0;
    stats.pointsUsed = data.pointsUsed || 0;
    stats.faceValue = data.faceValue || 0;
  } catch (e) {
  } finally {
    loadingStats.value = false;
  }
};

const openDelivery = (row) => {
  selectedRow.value = row;
  deliveryForm.deliveryStatus = row.deliveryStatus || "PENDING";
  deliveryForm.deliveryInfo = row.deliveryInfo || "";
  deliveryDialogVisible.value = true;
};

const openStatus = (row) => {
  selectedRow.value = row;
  statusForm.status = row.status || "PENDING";
  statusForm.errorCode = row.errorCode || "";
  statusForm.errorMsg = row.errorMsg || "";
  statusDialogVisible.value = true;
};

const saveDelivery = async () => {
  if (!selectedRow.value) return;
  saving.value = true;
  try {
    await rewardsApi.admin.updateExchangeDelivery(selectedRow.value.id, {
      deliveryStatus: deliveryForm.deliveryStatus,
      deliveryInfo: deliveryForm.deliveryInfo,
    });
    ElMessage.success("更新成功");
    deliveryDialogVisible.value = false;
    await loadData();
    await loadStats();
  } catch (e) {
    const msg = e?.response?.data?.message || "更新失败";
    ElMessage.error(msg);
  } finally {
    saving.value = false;
  }
};

const saveStatus = async () => {
  if (!selectedRow.value) return;
  saving.value = true;
  try {
    await rewardsApi.admin.updateExchangeStatus(selectedRow.value.id, {
      status: statusForm.status,
      errorCode: statusForm.errorCode,
      errorMsg: statusForm.errorMsg,
    });
    ElMessage.success("更新成功");
    statusDialogVisible.value = false;
    await loadData();
    await loadStats();
  } catch (e) {
    const msg = e?.response?.data?.message || "更新失败";
    ElMessage.error(msg);
  } finally {
    saving.value = false;
  }
};

onMounted(async () => {
  await loadCategories();
  await loadData();
  await loadStats();
});
</script>

<style scoped>
.page {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 12px;
}

.pagination {
  margin-top: 10px;
  display: flex;
  justify-content: flex-end;
}
</style>
