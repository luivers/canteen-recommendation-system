<template>
  <div class="exchange-page">
    <div class="page-header">
      <div class="header-left">
        <el-button text @click="goBack">返回</el-button>
        <h2 class="page-title">兑换中心</h2>
      </div>
      <div class="header-right">
        <span class="points-text">当前积分：{{ currentPoints }}</span>
        <el-button
          type="primary"
          plain
          size="small"
          :loading="loadingPoints"
          @click="loadPointBalance"
          >刷新</el-button
        >
      </div>
    </div>

    <el-tabs v-model="activeTab" class="tabs">
      <el-tab-pane label="奖励列表" name="redeem">
        <div class="filter-toolbar">
          <el-input
            v-model="filterParams.keyword"
            placeholder="搜索奖励名称"
            clearable
            style="width: 200px"
            @keyup.enter="handleSearch"
          />
          <el-select
            v-model="filterParams.categoryId"
            placeholder="全部分类"
            clearable
            style="width: 160px"
            @change="handleSearch"
          >
            <el-option
              v-for="cat in categories"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
          <el-select
            v-model="filterParams.status"
            placeholder="全部状态"
            clearable
            style="width: 140px"
            @change="handleSearch"
          >
            <el-option label="可兑换" value="AVAILABLE" />
            <el-option label="缺货" value="OUT_OF_STOCK" />
            <el-option label="已下架" value="DISCONTINUED" />
          </el-select>
          <el-button
            type="primary"
            :loading="loadingRewards"
            @click="handleSearch"
            >查询</el-button
          >
          <el-button :disabled="loadingRewards" @click="resetFilters"
            >重置</el-button
          >
        </div>

        <div v-loading="loadingRewards" class="vouchers">
          <el-empty
            v-if="rewardPool.length === 0 && !loadingRewards"
            description="暂无相关奖励"
          />
          <el-card
            v-for="item in rewardPool"
            :key="item.id"
            class="voucher-card"
            shadow="hover"
            :body-style="{ padding: '0px' }"
          >
            <div class="card-image-wrapper">
              <el-image
                :src="item.imageUrl"
                fit="cover"
                class="card-image"
                loading="lazy"
              >
                <template #error>
                  <div class="image-placeholder">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
              <div v-if="item.status !== 'AVAILABLE'" class="card-status-tag">
                <el-tag :type="getStatusType(item.status)" effect="dark">{{
                  getStatusText(item.status)
                }}</el-tag>
              </div>
            </div>

            <div class="card-content">
              <div class="card-top">
                <div class="voucher-name" :title="item.name">
                  {{ item.name }}
                </div>
                <div class="voucher-points">{{ item.pointsRequired }} 积分</div>
              </div>

              <div class="voucher-desc" :title="item.description">
                {{ item.description || "暂无描述" }}
              </div>

              <div class="card-meta">
                <div class="meta-row">
                  <span class="meta-label">库存</span>
                  <span
                    class="meta-value"
                    :class="{ 'stock-low': item.stock <= 5 }"
                    >{{ item.stock > 0 ? item.stock : "缺货" }}</span
                  >
                </div>
                <div v-if="item.validTo" class="meta-row">
                  <span class="meta-label">有效期</span>
                  <span class="meta-value text-xs">{{
                    formatTime(item.validTo).split(" ")[0]
                  }}</span>
                </div>
              </div>

              <div class="card-actions">
                <el-button
                  type="primary"
                  class="exchange-btn"
                  :disabled="!canExchange(item)"
                  @click="openExchange(item)"
                >
                  {{ getActionButtonText(item) }}
                </el-button>
              </div>
            </div>
          </el-card>
        </div>

        <div v-if="rewardPagination.total > 0" class="pagination">
          <el-pagination
            v-model:current-page="rewardPagination.page"
            background
            layout="prev, pager, next"
            :total="rewardPagination.total"
            :page-size="rewardPagination.size"
            @current-change="loadRewards"
          />
        </div>
      </el-tab-pane>

      <el-tab-pane label="我的兑换" name="mine">
        <div class="mine-toolbar">
          <el-select
            v-model="mineFilter.used"
            clearable
            placeholder="使用状态"
            style="width: 160px"
            @change="reloadMyVouchers"
          >
            <el-option label="可用" value="false" />
            <el-option label="已使用" value="true" />
          </el-select>
          <el-select
            v-model="mineFilter.status"
            clearable
            placeholder="兑换状态"
            style="width: 160px"
            @change="reloadMyVouchers"
          >
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="待处理" value="PENDING" />
            <el-option label="已取消" value="CANCELLED" />
            <el-option label="失败" value="FAILED" />
          </el-select>
          <el-button
            type="primary"
            plain
            size="small"
            :loading="loadingMine"
            @click="reloadMyVouchers"
            >刷新</el-button
          >
        </div>

        <el-table
          v-loading="loadingMine"
          :data="myVouchers"
          size="small"
          style="width: 100%"
        >
          <el-table-column label="奖励名称" min-width="180">
            <template #default="scope">
              {{ scope.row.reward?.name || "-" }}
            </template>
          </el-table-column>
          <el-table-column label="面值" width="100">
            <template #default="scope">
              <span v-if="scope.row.faceValueSnapshot != null"
                >¥{{ formatMoney(scope.row.faceValueSnapshot) }}</span
              >
              <span v-else-if="scope.row.reward?.faceValue != null"
                >¥{{ formatMoney(scope.row.reward.faceValue) }}</span
              >
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="110">
            <template #default="scope">
              <span v-if="scope.row.used">已使用</span>
              <span v-else-if="isExpired(scope.row)">已过期</span>
              <span v-else>
                <el-tag
                  size="small"
                  :type="getExchangeStatusType(scope.row.status)"
                  >{{ getExchangeStatusText(scope.row.status) }}</el-tag
                >
              </span>
            </template>
          </el-table-column>
          <el-table-column label="有效期" min-width="210">
            <template #default="scope">
              <span v-if="scope.row.reward?.validTo"
                >{{ formatTime(scope.row.reward?.validFrom) }} ~
                {{ formatTime(scope.row.reward?.validTo) }}</span
              >
              <span v-else>-</span>
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
          <el-table-column label="关联订单" width="120">
            <template #default="scope">
              {{ scope.row.usedOrderId ?? "-" }}
            </template>
          </el-table-column>
        </el-table>

        <div v-if="minePagination.total > 0" class="pagination">
          <el-pagination
            v-model:current-page="minePagination.page"
            background
            layout="prev, pager, next"
            :total="minePagination.total"
            :page-size="minePagination.size"
            @current-change="loadMyVouchers"
          />
        </div>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="exchangeDialogVisible" title="兑换确认" width="520px">
      <div v-if="selectedReward" v-loading="loadingPreview">
        <div class="preview-row">
          <span class="preview-label">奖励名称</span>
          <span class="preview-value">{{
            previewData.rewardName || selectedReward.name || "-"
          }}</span>
        </div>
        <div class="preview-row">
          <span class="preview-label">所需积分</span>
          <span class="preview-value">{{
            previewData.pointsRequired ?? selectedReward.pointsRequired ?? "-"
          }}</span>
        </div>
        <div class="preview-row">
          <span class="preview-label">当前积分</span>
          <span class="preview-value">{{ previewData.userPoints ?? "-" }}</span>
        </div>
        <div v-if="previewData.stock != null" class="preview-row">
          <span class="preview-label">剩余库存</span>
          <span class="preview-value">{{ previewData.stock }}</span>
        </div>

        <div
          v-if="selectedReward.type === 'OTHER'"
          class="delivery-form-container"
          style="margin-top: 20px"
        >
          <el-divider content-position="left">收货信息</el-divider>
          <el-form :model="deliveryForm" label-width="80px" size="small">
            <el-form-item label="收货人" required style="margin-bottom: 12px">
              <el-input
                v-model="deliveryForm.name"
                placeholder="请输入收货人姓名"
              />
            </el-form-item>
            <el-form-item label="联系电话" required style="margin-bottom: 12px">
              <el-input
                v-model="deliveryForm.phone"
                placeholder="请输入联系电话"
              />
            </el-form-item>
            <el-form-item label="收货地址" required style="margin-bottom: 12px">
              <el-input
                v-model="deliveryForm.address"
                type="textarea"
                :rows="2"
                placeholder="请输入详细收货地址"
              />
            </el-form-item>
          </el-form>
        </div>

        <el-alert
          v-if="previewData.blockReason"
          :title="previewData.blockReason"
          type="warning"
          show-icon
          :closable="false"
          style="margin-top: 12px"
        />
      </div>
      <template #footer>
        <el-button @click="exchangeDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="submitting"
          :disabled="!previewData.allowed"
          @click="submitExchange"
          >确认兑换</el-button
        >
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch, reactive } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Picture } from "@element-plus/icons-vue";
import dayjs from "dayjs";
import { rewardsApi } from "@/api/rewards";

const router = useRouter();
const loadingRewards = ref(false);
const currentPoints = ref(0);
const loadingPoints = ref(false);

const activeTab = ref("redeem");
const rewardPool = ref([]);
const categories = ref([]);

const filterParams = ref({
  categoryId: null,
  keyword: "",
  status: "AVAILABLE", // 默认显示可兑换
});

const rewardPagination = ref({
  page: 1,
  size: 20,
  total: 0,
});

const loadingMine = ref(false);
const myVouchers = ref([]);
const mineFilter = ref({
  used: "",
  status: "",
});
const minePagination = ref({
  page: 1,
  size: 10,
  total: 0,
});

const exchangeDialogVisible = ref(false);
const selectedReward = ref(null);
const previewData = ref({});
const loadingPreview = ref(false);
const submitting = ref(false);

const formatTime = (time) => {
  if (!time) return "-";
  return dayjs(time).format("YYYY-MM-DD HH:mm");
};

const formatMoney = (v) => {
  const n = Number(v);
  if (Number.isNaN(n)) return v;
  return n.toFixed(2);
};

const isExpired = (row) => {
  const to = row?.reward?.validTo;
  if (!to) return false;
  return dayjs(to).isBefore(dayjs());
};

const getStatusType = (status) => {
  switch (status) {
    case "AVAILABLE":
      return "success";
    case "OUT_OF_STOCK":
      return "warning";
    case "DISCONTINUED":
      return "info";
    default:
      return "";
  }
};

const getStatusText = (status) => {
  switch (status) {
    case "AVAILABLE":
      return "可兑换";
    case "OUT_OF_STOCK":
      return "缺货";
    case "DISCONTINUED":
      return "已下架";
    default:
      return status;
  }
};

const getExchangeStatusType = (status) => {
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

const getExchangeStatusText = (status) => {
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

const canExchange = (item) => {
  return item.status === "AVAILABLE" && item.stock > 0;
};

const getActionButtonText = (item) => {
  if (item.status === "OUT_OF_STOCK") return "缺货";
  if (item.status === "DISCONTINUED") return "已下架";
  if (item.stock <= 0) return "库存不足";
  return "兑换";
};

const goBack = () => {
  router.push("/profile");
};

const getRequestId = () => {
  if (typeof crypto !== "undefined" && crypto.randomUUID)
    return crypto.randomUUID();
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`;
};

const loadPointBalance = async () => {
  loadingPoints.value = true;
  try {
    const res = await rewardsApi.getPointBalance();
    const points = res?.data?.data?.points;
    currentPoints.value =
      typeof points === "number" ? points : Number(points || 0);
  } finally {
    loadingPoints.value = false;
  }
};

const loadCategories = async () => {
  try {
    const res = await rewardsApi.getCategories();
    categories.value = res?.data?.data || [];
  } catch (e) {
    console.error("Failed to load categories", e);
  }
};

const loadRewards = async () => {
  loadingRewards.value = true;
  try {
    const rawCategoryId = filterParams.value.categoryId;
    const categoryId =
      rawCategoryId === "" || rawCategoryId == null
        ? undefined
        : Number(rawCategoryId);
    const params = {
      page: rewardPagination.value.page - 1,
      size: rewardPagination.value.size,
      categoryId,
      keyword: filterParams.value.keyword || undefined,
      status: filterParams.value.status || undefined,
    };

    // 如果没有选状态，且没有搜索关键字，默认只看可兑换（如果用户想要看所有，可以选全部）
    // 这里为了用户体验，默认是AVAILABLE，但如果用户清空了状态选择（选了全部），则传undefined
    // 上面 filterParams.status 默认为 'AVAILABLE'

    // 如果状态是 AVAILABLE，我们可以传 onlyRedeemable=true 也可以传 status=AVAILABLE
    // 为了兼容性，我们可以都传，或者只传 status。
    // 后端逻辑：if status != null, filter by status.
    // if onlyRedeemable=true, filter by status=AVAILABLE AND valid time AND stock > 0.
    // 所以 onlyRedeemable 还会检查时间和库存。单纯 status=AVAILABLE 可能只是状态字段。
    // 用户一般想看 "可兑换" 的，意味着 stock>0 且未过期。
    // 如果用户选 "缺货"，那就是 status=OUT_OF_STOCK。
    // 如果用户选 "全部"，那就是 undefined。

    // Let's refine logic:
    // If status is AVAILABLE, user probably wants "Redeemable" (stock > 0, time valid).
    // But if we just filter status=AVAILABLE, we might see out of stock items if the scheduled task hasn't run, or items that are technically AVAILABLE but 0 stock (though backend should handle this).
    // Let's pass status as is. And maybe onlyRedeemable=false unless we want that strict check.
    // Actually, let's trust the status filter.

    const res = await rewardsApi.getRewardsPage(params);
    const data = res?.data?.data || {};
    rewardPool.value = Array.isArray(data.content) ? data.content : [];
    rewardPagination.value.total = data.total || 0;
  } catch (e) {
    rewardPool.value = [];
    rewardPagination.value.total = 0;
    ElMessage.error("加载奖励列表失败");
  } finally {
    loadingRewards.value = false;
  }
};

const handleSearch = () => {
  rewardPagination.value.page = 1;
  loadRewards();
};

const resetFilters = () => {
  filterParams.value = {
    categoryId: null,
    keyword: "",
    status: "AVAILABLE",
  };
  rewardPagination.value.page = 1;
  loadRewards();
};

const loadMyVouchers = async () => {
  loadingMine.value = true;
  try {
    const status = mineFilter.value.status || undefined;
    const res = await rewardsApi.getMyExchangesPage({
      page: minePagination.value.page - 1,
      size: minePagination.value.size,
      status,
    });
    const data = res?.data?.data || {};
    myVouchers.value = data.content || [];
    minePagination.value.total = data.total || 0;
  } catch (e) {
    myVouchers.value = [];
    minePagination.value.total = 0;
    ElMessage.error("加载我的兑换记录失败");
  } finally {
    loadingMine.value = false;
  }
};

const reloadMyVouchers = () => {
  minePagination.value.page = 1;
  loadMyVouchers();
};

watch(
  () => activeTab.value,
  async (v) => {
    if (v === "mine") {
      await loadMyVouchers();
    } else {
      await loadRewards();
    }
  },
);

const deliveryForm = reactive({
  name: "",
  phone: "",
  address: "",
});

const openExchange = async (reward) => {
  if (!reward) return;
  selectedReward.value = reward;
  exchangeDialogVisible.value = true;

  // 重置收货表单
  deliveryForm.name = "";
  deliveryForm.phone = "";
  deliveryForm.address = "";

  previewData.value = {};
  loadingPreview.value = true;
  try {
    const res = await rewardsApi.previewExchange(reward.id);
    previewData.value = res?.data?.data || {};
  } catch (e) {
    previewData.value = { allowed: false, blockReason: "获取兑换确认信息失败" };
  } finally {
    loadingPreview.value = false;
  }
};

const submitExchange = async () => {
  if (!selectedReward.value) return;
  submitting.value = true;
  try {
    const extraData = {};
    if (selectedReward.value.type === "OTHER") {
      if (
        !deliveryForm.name?.trim() ||
        !deliveryForm.phone?.trim() ||
        !deliveryForm.address?.trim()
      ) {
        ElMessage.warning("请填写完整的收货信息");
        submitting.value = false;
        return;
      }
      extraData.receiverName = deliveryForm.name;
      extraData.receiverPhone = deliveryForm.phone;
      extraData.receiverAddress = deliveryForm.address;
    }

    const requestId = getRequestId();
    await rewardsApi.exchange(selectedReward.value.id, requestId, extraData);
    ElMessage.success("兑换成功");
    exchangeDialogVisible.value = false;
    await loadPointBalance();
    await loadRewards();
    if (activeTab.value === "mine") {
      await loadMyVouchers();
    }
  } catch (e) {
    const msg = e?.response?.data?.message || "兑换失败";
    ElMessage.error(msg);
  } finally {
    submitting.value = false;
  }
};

onMounted(async () => {
  await loadCategories();
  await loadPointBalance();
  await loadRewards();
});
</script>

<style scoped>
.exchange-page {
  padding: 18px 18px 24px 18px;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.page-title {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.points-text {
  color: #666;
  font-size: 14px;
}

.tabs {
  margin-top: 6px;
}

.filter-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 16px;
  padding: 12px;
  background-color: #f8f9fa;
  border-radius: 8px;
}

.vouchers {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 12px;
}

.voucher-card {
  border-radius: 12px;
  transition: all 0.3s;
  overflow: hidden;
  border: none;
  background: #fff;
  display: flex;
  flex-direction: column;
}

.voucher-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 20px rgba(0, 0, 0, 0.08);
}

.card-image-wrapper {
  position: relative;
  width: 100%;
  height: 160px;
  background-color: #f5f7fa;
  overflow: hidden;
}

.card-image {
  width: 100%;
  height: 100%;
  transition: transform 0.5s;
}

.voucher-card:hover .card-image {
  transform: scale(1.05);
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  color: #c0c4cc;
  font-size: 32px;
}

.card-status-tag {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 2;
}

.card-content {
  padding: 16px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.voucher-name {
  font-weight: bold;
  font-size: 16px;
  color: #303133;
  line-height: 1.4;
  flex: 1;
  margin-right: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
}

.voucher-points {
  font-size: 16px;
  font-weight: bold;
  color: #f56c6c;
  white-space: nowrap;
}

.voucher-desc {
  font-size: 13px;
  color: #909399;
  margin-bottom: 16px;
  height: 36px;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.card-meta {
  font-size: 13px;
  color: #606266;
  margin-bottom: 16px;
  background: #f9fafe;
  padding: 8px 12px;
  border-radius: 6px;
}

.meta-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.meta-row:last-child {
  margin-bottom: 0;
}

.meta-value.stock-low {
  color: #e6a23c;
  font-weight: bold;
}

.text-xs {
  font-size: 12px;
}

.card-actions {
  margin-top: auto;
}

.exchange-btn {
  width: 100%;
  border-radius: 20px;
  font-weight: bold;
}

.mine-toolbar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.preview-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px dashed #eee;
}

.preview-label {
  color: #666;
}

.preview-value {
  font-weight: bold;
  color: #333;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}
</style>
