<template>
  <div class="orders-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">订单管理</h1>
      <div class="header-actions">
        <el-button @click="exportData">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="订单号">
          <el-input
            v-model="searchForm.orderNumber"
            placeholder="请输入订单号"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input
            v-model="searchForm.username"
            placeholder="请输入用户名"
            clearable
            style="width: 150px"
          />
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select
            v-model="searchForm.status"
            placeholder="请选择状态"
            clearable
            style="width: 120px"
          >
            <el-option label="待支付" value="PENDING" />
            <el-option label="已支付" value="PAID" />
            <el-option label="制作中" value="PREPARING" />
            <el-option label="待取餐" value="READY" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 订单列表 -->
    <el-card>
      <template #header>
        <span>订单列表</span>
      </template>

      <el-table
        v-loading="loading"
        :data="orders"
        style="width: 100%"
        @row-click="handleRowClick"
      >
        <el-table-column type="expand">
          <template #default="props">
            <div class="order-details">
              <h4>订单详情</h4>
              <el-table :data="props.row.items" size="small" border>
                <el-table-column label="菜品名称" prop="dishName" />
                <el-table-column label="单价" prop="price" width="100">
                  <template #default="scope">¥{{ scope.row.price }}</template>
                </el-table-column>
                <el-table-column label="数量" prop="quantity" width="80" />
                <el-table-column label="小计" width="100">
                  <template #default="scope"
                    >¥{{
                      (scope.row.price * scope.row.quantity).toFixed(2)
                    }}</template
                  >
                </el-table-column>
              </el-table>

              <div class="order-summary">
                <p>
                  <strong>商品总价:</strong> ¥{{
                    props.row.goodsAmount ?? props.row.totalAmount
                  }}
                </p>
                <p v-if="(props.row.voucherDeduction ?? 0) > 0">
                  <strong>代金券抵扣:</strong> -¥{{
                    props.row.voucherDeduction
                  }}
                </p>
                <p>
                  <strong>实付金额:</strong> ¥{{
                    props.row.payableAmount ?? props.row.totalAmount
                  }}
                </p>
                <p>
                  <strong>取餐方式:</strong>
                  {{
                    props.row.pickupType === "IMMEDIATE"
                      ? "立即取餐"
                      : "预约取餐"
                  }}
                </p>
                <p v-if="props.row.pickupTime">
                  <strong>预约时间:</strong>
                  {{ formatTime(props.row.pickupTime) }}
                </p>
                <p>
                  <strong>下单时间:</strong>
                  {{ formatTime(props.row.createdAt) }}
                </p>
                <p v-if="props.row.completedAt">
                  <strong>完成时间:</strong>
                  {{ formatTime(props.row.completedAt) }}
                </p>
              </div>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="orderNumber" label="订单号" width="180" />
        <el-table-column prop="username" label="用户" width="120" />
        <el-table-column prop="totalAmount" label="金额" width="100">
          <template #default="scope">
            ¥{{ scope.row.payableAmount ?? scope.row.totalAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="pickupType" label="取餐方式" width="120">
          <template #default="scope">
            {{ scope.row.pickupType === "IMMEDIATE" ? "立即取餐" : "预约取餐" }}
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="下单时间" width="180">
          <template #default="scope">
            {{ formatTime(scope.row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="300" fixed="right">
          <template #default="scope">
            <div class="table-actions">
              <el-button
                v-if="scope.row.status === 'PAID'"
                type="primary"
                text
                @click.stop="handlePrepare(scope.row)"
              >
                开始制作
              </el-button>
              <el-button
                v-if="scope.row.status === 'PREPARING'"
                type="success"
                text
                @click.stop="handleReady(scope.row)"
              >
                制作完成
              </el-button>
              <el-button
                v-if="scope.row.status === 'READY'"
                type="warning"
                text
                @click.stop="handleComplete(scope.row)"
              >
                确认取餐
              </el-button>
              <el-button
                v-if="['PENDING', 'PAID'].includes(scope.row.status)"
                type="danger"
                text
                @click.stop="handleCancel(scope.row)"
              >
                取消订单
              </el-button>
              <el-button
                type="danger"
                text
                @click.stop="handleDelete(scope.row)"
              >
                删除订单
              </el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.current"
          v-model:page-size="pagination.size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @update:page-size="handleSizeChange"
          @update:current-page="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="800px">
      <div v-if="currentOrder" class="order-detail">
        <el-descriptions title="基本信息" :column="2" border>
          <el-descriptions-item label="订单号">{{
            currentOrder.orderNumber
          }}</el-descriptions-item>
          <el-descriptions-item label="用户名">{{
            currentOrder.username
          }}</el-descriptions-item>
          <el-descriptions-item label="商品总价"
            >¥{{
              currentOrder.goodsAmount ?? currentOrder.totalAmount
            }}</el-descriptions-item
          >
          <el-descriptions-item
            v-if="(currentOrder.voucherDeduction ?? 0) > 0"
            label="代金券抵扣"
            >-¥{{ currentOrder.voucherDeduction }}</el-descriptions-item
          >
          <el-descriptions-item label="实付金额"
            >¥{{
              currentOrder.payableAmount ?? currentOrder.totalAmount
            }}</el-descriptions-item
          >
          <el-descriptions-item label="订单状态">
            <el-tag :type="getStatusType(currentOrder.status)">
              {{ getStatusText(currentOrder.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="取餐方式">
            {{
              currentOrder.pickupType === "IMMEDIATE" ? "立即取餐" : "预约取餐"
            }}
          </el-descriptions-item>
          <el-descriptions-item label="支付方式">
            {{ getPaymentMethodText(currentOrder.paymentMethod) }}
          </el-descriptions-item>
          <el-descriptions-item label="下单时间">{{
            formatTime(currentOrder.createdAt)
          }}</el-descriptions-item>
          <el-descriptions-item v-if="currentOrder.pickupTime" label="预约时间">
            {{ formatTime(currentOrder.pickupTime) }}
          </el-descriptions-item>
          <el-descriptions-item
            v-if="currentOrder.completedAt"
            label="完成时间"
          >
            {{ formatTime(currentOrder.completedAt) }}
          </el-descriptions-item>
        </el-descriptions>

        <h4 style="margin-top: 20px">菜品清单</h4>
        <el-table :data="currentOrder.items" border>
          <el-table-column label="菜品名称" prop="dishName" />
          <el-table-column label="单价" prop="price" width="100">
            <template #default="scope">¥{{ scope.row.price }}</template>
          </el-table-column>
          <el-table-column label="数量" prop="quantity" width="80" />
          <el-table-column label="小计" width="100">
            <template #default="scope"
              >¥{{
                (scope.row.price * scope.row.quantity).toFixed(2)
              }}</template
            >
          </el-table-column>
        </el-table>

        <div class="order-actions" style="margin-top: 20px; text-align: center">
          <el-button
            v-if="currentOrder.status === 'PAID'"
            type="primary"
            @click="handlePrepare(currentOrder)"
          >
            开始制作
          </el-button>
          <el-button
            v-if="currentOrder.status === 'PREPARING'"
            type="success"
            @click="handleReady(currentOrder)"
          >
            制作完成
          </el-button>
          <el-button
            v-if="currentOrder.status === 'READY'"
            type="warning"
            @click="handleComplete(currentOrder)"
          >
            确认取餐
          </el-button>
          <el-button
            v-if="['PENDING', 'PAID'].includes(currentOrder.status)"
            type="danger"
            @click="handleCancel(currentOrder)"
          >
            取消订单
          </el-button>
          <el-button type="danger" @click="handleDelete(currentOrder)">
            删除订单
          </el-button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Download } from "@element-plus/icons-vue";
import { orderApi } from "@/api/order";
import api from "@/api/index";

const loading = ref(false);
const detailDialogVisible = ref(false);
const currentOrder = ref(null);

const searchForm = reactive({
  orderNumber: "",
  username: "",
  status: "",
  dateRange: [],
});

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const orders = ref([]);

// 获取状态类型
const getStatusType = (status) => {
  const types = {
    PENDING: "warning",
    PAID: "info",
    PREPARING: "primary",
    READY: "success",
    COMPLETED: "success",
    CANCELLED: "danger",
  };
  return types[status] || "info";
};

// 获取状态文本
const getStatusText = (status) => {
  const texts = {
    PENDING: "待支付",
    PAID: "已支付",
    PREPARING: "制作中",
    READY: "待取餐",
    COMPLETED: "已完成",
    CANCELLED: "已取消",
  };
  return texts[status] || status;
};

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return "";
  return new Date(timeStr).toLocaleString("zh-CN");
};

// 获取支付方式文本
const getPaymentMethodText = (method) => {
  const map = {
    WECHAT: '微信支付',
    ALIPAY: '支付宝',
    CARD: '一卡通'
  };
  return map[method] || method || '未支付';
};

// 搜索订单
const handleSearch = () => {
  pagination.current = 1;
  loadOrders();
};

// 重置搜索
const handleReset = () => {
  Object.keys(searchForm).forEach((key) => {
    searchForm[key] = "";
  });
  searchForm.dateRange = [];
  pagination.current = 1;
  loadOrders();
};

// 加载订单列表
const loadOrders = async () => {
  loading.value = true;
  try {
    // 构建请求参数
    const params = {
      page: pagination.current - 1, // 后端使用0开始的页码
      size: pagination.size,
      status: searchForm.status,
      orderNumber: searchForm.orderNumber,
      username: searchForm.username,
      adminView: true,
    };

    // 只有当dateRange有值时才添加日期参数
    if (searchForm.dateRange && searchForm.dateRange[0]) {
      // 转换为本地时间字符串，避免时区偏差
      const startDate = new Date(searchForm.dateRange[0]);
      const offset = startDate.getTimezoneOffset() * 60000;
      const localStartDate = new Date(startDate.getTime() - offset);
      params.startDate = localStartDate.toISOString().slice(0, 19);
    }

    if (searchForm.dateRange && searchForm.dateRange[1]) {
      // 克隆结束日期对象，设置为当天的最后一刻
      const endDate = new Date(searchForm.dateRange[1]);
      endDate.setHours(23, 59, 59, 999);

      const offset = endDate.getTimezoneOffset() * 60000;
      const localEndDate = new Date(endDate.getTime() - offset);
      params.endDate = localEndDate.toISOString().slice(0, 19);
    }

    // 调用真实API获取订单数据
    const response = await orderApi.getOrders(params);

    // 更新订单列表和分页信息
    orders.value = response.data.content || [];
    pagination.total = response.data.totalElements || 0;

    // 为每个订单添加items属性，避免UI错误
    orders.value.forEach((order) => {
      if (!order.items) {
        order.items = [];
      }
    });
  } catch (error) {
    ElMessage.error("加载订单列表失败");
    console.error("加载订单列表失败:", error);
  } finally {
    loading.value = false;
  }
};

// 行点击事件
const handleRowClick = (row) => {
  currentOrder.value = row;
  detailDialogVisible.value = true;
};

// 开始制作
const handlePrepare = async (order) => {
  try {
    await ElMessageBox.confirm("确定开始制作这个订单吗？", "提示");

    // 调用真实API更新订单状态
    await orderApi.prepareOrder(order.id);

    // 刷新订单列表
    await loadOrders();

    ElMessage.success("订单状态已更新为制作中");
    detailDialogVisible.value = false;
  } catch {
    // 用户取消操作或API调用失败
  }
};

// 制作完成
const handleReady = async (order) => {
  try {
    await ElMessageBox.confirm("确认订单制作完成吗？", "提示");

    // 调用真实API更新订单状态
    await orderApi.readyOrder(order.id);

    // 刷新订单列表
    await loadOrders();

    ElMessage.success("订单状态已更新为待取餐");
    detailDialogVisible.value = false;
  } catch {
    // 用户取消操作或API调用失败
  }
};

// 确认取餐
const handleComplete = async (order) => {
  try {
    await ElMessageBox.confirm("确认用户已取餐吗？", "提示");

    // 调用真实API更新订单状态
    await orderApi.confirmPickup(order.id);

    // 刷新订单列表
    await loadOrders();

    ElMessage.success("订单已完成");
    detailDialogVisible.value = false;
  } catch {
    // 用户取消操作或API调用失败
  }
};

// 取消订单
const handleCancel = async (order) => {
  try {
    await ElMessageBox.confirm("确定要取消这个订单吗？", "提示", {
      type: "warning",
    });

    // 调用真实API更新订单状态
    await orderApi.cancelOrder(order.id);

    // 刷新订单列表
    await loadOrders();

    ElMessage.success("订单已取消");
    detailDialogVisible.value = false;
  } catch {
    // 用户取消操作或API调用失败
  }
};

const handleDelete = async (order) => {
  try {
    await ElMessageBox.confirm("删除后不可恢复，确定删除该订单吗？", "提示", {
      type: "warning",
    });
    await orderApi.deleteOrder(order.id);
    await loadOrders();
    ElMessage.success("订单已删除");
    detailDialogVisible.value = false;
  } catch {}
};

// 导出数据
const exportData = async () => {
  try {
    ElMessage.info("正在生成导出文件...");
    
    const params = {
      status: searchForm.status,
      orderNumber: searchForm.orderNumber,
      username: searchForm.username,
      adminView: true,
    };

    if (searchForm.dateRange && searchForm.dateRange[0]) {
      const startDate = new Date(searchForm.dateRange[0]);
      const offset = startDate.getTimezoneOffset() * 60000;
      const localStartDate = new Date(startDate.getTime() - offset);
      params.startDate = localStartDate.toISOString().slice(0, 19);
    }

    if (searchForm.dateRange && searchForm.dateRange[1]) {
      const endDate = new Date(searchForm.dateRange[1]);
      endDate.setHours(23, 59, 59, 999);
      const offset = endDate.getTimezoneOffset() * 60000;
      const localEndDate = new Date(endDate.getTime() - offset);
      params.endDate = localEndDate.toISOString().slice(0, 19);
    }

    const response = await api.get('/api/orders/export', {
      params,
      responseType: 'blob'
    });

    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    
    const contentDisposition = response.headers['content-disposition'];
    let fileName = `订单列表_${new Date().toISOString().slice(0,10)}.xlsx`;
    if (contentDisposition) {
      const fileNameMatch = contentDisposition.match(/filename\*=utf-8''(.+)/);
      if (fileNameMatch && fileNameMatch.length === 2) {
        fileName = decodeURIComponent(fileNameMatch[1]);
      }
    }
    
    link.setAttribute('download', fileName);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
    
    ElMessage.success("导出成功");
  } catch (error) {
    console.error("导出失败:", error);
    ElMessage.error("导出失败");
  }
};

// 分页大小改变
const handleSizeChange = (size) => {
  pagination.size = size;
  pagination.current = 1;
  loadOrders();
};

// 当前页改变
const handleCurrentChange = (current) => {
  pagination.current = current;
  loadOrders();
};

onMounted(() => {
  loadOrders();
});
</script>

<style scoped>
.orders-container {
  width: 100%;
  margin: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-title {
  font-size: 24px;
  color: #333;
  margin: 0;
}

.search-card {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.table-actions {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  white-space: nowrap;
}

.table-actions .el-button {
  margin-left: 0;
}

.order-details {
  padding: 20px;
}

.order-details h4 {
  margin-bottom: 15px;
  color: #333;
}

.order-summary {
  margin-top: 15px;
  padding: 15px;
  background: #f5f7fa;
  border-radius: 4px;
}

.order-summary p {
  margin: 5px 0;
}

.order-detail {
  max-height: 600px;
  overflow-y: auto;
}

.order-actions {
  padding: 20px 0;
}

:deep(.el-table__row) {
  cursor: pointer;
}

:deep(.el-table__row:hover) {
  background-color: #f5f7fa;
}
</style>
