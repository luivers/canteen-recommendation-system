<template>
  <div class="orders-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">我的订单</h1>
      <p class="page-subtitle">查看和管理您的订单</p>
    </div>
    <div v-if="supportBanner.visible" class="data-warning-banner">
      <el-alert
        title="系统提示"
        :description="supportBanner.text"
        type="warning"
        show-icon
        closable
        @close="supportBanner.visible = false"
      />
      <div class="banner-actions">
        <el-button size="small" @click="loadOrders">手动刷新</el-button>
        <el-link :href="'tel:' + supportBanner.contact" type="primary"
          >联系客服</el-link
        >
      </div>
    </div>
    <div v-if="paymentBanner.visible" class="payment-success-banner">
      <el-alert
        title="支付成功"
        :description="paymentBanner.text"
        type="success"
        show-icon
        closable
        @close="paymentBanner.visible = false"
      />
    </div>

    <!-- 订单筛选 -->
    <el-card class="filter-card">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-select
            v-model="filterStatus"
            placeholder="订单状态"
            clearable
            @change="handleSearch"
          >
            <el-option label="全部" value="" />
            <el-option label="待支付" value="PENDING" />
            <el-option label="已支付" value="PAID" />
            <el-option label="制作中" value="PREPARING" />
            <el-option label="待取餐" value="READY" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
        </el-col>
        <el-col :span="6">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            @change="handleSearch"
          />
        </el-col>
        <el-col :span="6">
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetFilters">重置</el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 订单列表 -->
    <div class="orders-list">
      <el-card v-loading="loading">
        <template #header>
          <span>订单列表</span>
        </template>

        <div v-if="orders.length === 0" class="empty-orders">
          <el-empty description="暂无订单">
            <el-button type="primary" @click="$router.push('/dishes')">
              去选购菜品
            </el-button>
          </el-empty>
        </div>

        <div v-else>
          <div v-for="order in orders" :key="order.id" class="order-item">
            <div class="order-header">
              <div class="order-info">
                <span class="order-number"
                  >订单号: {{ order.orderNumber }}</span
                >
                <span class="order-time">{{
                  formatTime(order.createdAt)
                }}</span>
              </div>
              <div class="order-status">
                <el-tag :type="getStatusType(order.status)">
                  {{ getStatusText(order.status) }}
                </el-tag>
              </div>
            </div>

            <div class="order-content">
              <div class="order-items">
                <div
                  v-for="item in order.items"
                  :key="item.id"
                  class="order-item-detail"
                >
                  <el-image
                    :src="getImageUrl(item.dish?.imageUrl || item.dish?.image)"
                    class="item-image"
                    fit="cover"
                  >
                    <template #error>
                      <div class="image-error">
                        <el-icon><Picture /></el-icon>
                      </div>
                    </template>
                  </el-image>

                  <div class="item-info">
                    <h4 class="item-name">
                      {{ item.dish.name }}
                      <el-tag v-if="item.isGift" type="danger" size="small" effect="dark" style="margin-left: 5px">赠品</el-tag>
                    </h4>
                    <p class="item-price">
                      ¥{{ item.unitPrice ?? item.dish.price }} × {{ item.quantity }}
                    </p>
                  </div>

                  <div class="item-subtotal">
                    ¥{{ (item.subtotal ?? ((item.unitPrice ?? item.dish.price) * item.quantity)).toFixed(2) }}
                  </div>
                </div>
              </div>

              <div class="order-summary">
                <div class="summary-row">
                  <span>商品总价:</span>
                  <span
                    >¥{{
                      (order.goodsAmount ?? order.totalAmount).toFixed(2)
                    }}</span
                  >
                </div>
                <div
                  v-if="(order.voucherDeduction ?? 0) > 0"
                  class="summary-row"
                >
                  <span>代金券抵扣:</span>
                  <span>-¥{{ (order.voucherDeduction ?? 0).toFixed(2) }}</span>
                </div>
                <div class="summary-row">
                  <span>配送费:</span>
                  <span>免费</span>
                </div>
                <div class="summary-row total">
                  <span>实付金额:</span>
                  <span class="total-amount"
                    >¥{{
                      (order.payableAmount ?? order.totalAmount).toFixed(2)
                    }}</span
                  >
                </div>
              </div>
            </div>

            <div class="order-footer">
              <div class="pickup-info">
                <p>
                  <strong>取餐方式:</strong>
                  {{ getPickupTypeText(order.pickupType) }}
                </p>
                <p v-if="order.reservationTime">
                  <strong>预约时间:</strong>
                  {{ formatTime(order.reservationTime) }}
                </p>
                <p>
                  <strong>取餐窗口:</strong>
                  {{ formatPickupLocation(order) }}
                </p>
                <p v-if="order.paymentTime">
                  <strong>支付时间:</strong> {{ formatTime(order.paymentTime) }}
                </p>
                <p v-if="order.paymentMethod">
                  <strong>支付方式:</strong> {{ getPaymentMethodText(order.paymentMethod) }}
                </p>
                <p v-if="order.paymentTransactionId">
                  <strong>交易号:</strong> {{ order.paymentTransactionId }}
                </p>
              </div>

              <div class="order-actions">
                <el-button
                  v-if="order.status === 'PENDING'"
                  type="primary"
                  size="small"
                  @click="payOrder(order)"
                >
                  立即支付
                </el-button>
                <el-button
                  v-if="order.status === 'PENDING'"
                  type="danger"
                  size="small"
                  @click="cancelOrder(order)"
                >
                  取消订单
                </el-button>
                <el-button
                  v-if="order.status === 'READY'"
                  type="success"
                  size="small"
                  @click="confirmPickup(order)"
                >
                  确认取餐
                </el-button>
                <el-button
                  type="default"
                  size="small"
                  @click="viewOrderDetail(order)"
                >
                  查看详情
                </el-button>
                <el-button
                  v-if="order.status === 'COMPLETED'"
                  type="primary"
                  size="small"
                  @click="reviewOrder(order)"
                >
                  评价菜品
                </el-button>
              </div>
            </div>
          </div>
        </div>

        <!-- 分页 -->
        <div class="pagination">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :total="total"
            :page-sizes="[10, 20, 30, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            @update:page-size="handleSizeChange"
            @update:current-page="handleCurrentChange"
          />
        </div>
      </el-card>
    </div>

    <!-- 订单详情对话框 -->
    <el-dialog
      v-model="detailVisible"
      :title="'订单详情 - ' + (currentOrder?.orderNumber || '')"
      width="700px"
    >
      <div v-if="currentOrder" class="order-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单状态">
            <el-tag :type="getStatusType(currentOrder.status)">
              {{ getStatusText(currentOrder.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="下单时间">
            {{ formatTime(currentOrder.createdAt) }}
          </el-descriptions-item>
          <el-descriptions-item label="取餐方式">
            {{ getPickupTypeText(currentOrder.pickupType) }}
          </el-descriptions-item>
          <el-descriptions-item
            v-if="currentOrder.reservationTime"
            label="预约时间"
          >
            {{ formatTime(currentOrder.reservationTime) }}
          </el-descriptions-item>
          <el-descriptions-item label="取餐窗口">
            {{ formatPickupLocation(currentOrder) }}
          </el-descriptions-item>
          <el-descriptions-item label="商品总价">
            ¥{{
              (currentOrder.goodsAmount ?? currentOrder.totalAmount).toFixed(2)
            }}
          </el-descriptions-item>
          <el-descriptions-item
            v-if="(currentOrder.voucherDeduction ?? 0) > 0"
            label="代金券抵扣"
          >
            -¥{{ (currentOrder.voucherDeduction ?? 0).toFixed(2) }}
          </el-descriptions-item>
          <el-descriptions-item label="实付金额">
            ¥{{
              (currentOrder.payableAmount ?? currentOrder.totalAmount).toFixed(
                2,
              )
            }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentOrder.paymentMethod" label="支付方式">
            {{ getPaymentMethodText(currentOrder.paymentMethod) }}
          </el-descriptions-item>
        </el-descriptions>

        <h4>订单菜品</h4>
        <el-table :data="currentOrder.items" style="width: 100%">
          <el-table-column prop="dish.name" label="菜品名称" />
          <el-table-column prop="dish.price" label="单价" width="100">
            <template #default="scope"> ¥{{ scope.row.dish.price }} </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="80" />
          <el-table-column label="取餐方式" width="110">
            <template #default="scope">
              {{ getPickupTypeText(scope.row.pickupType || currentOrder.pickupType) }}
            </template>
          </el-table-column>
          <el-table-column label="小计" width="100">
            <template #default="scope">
              ¥{{ (scope.row.subtotal ?? ((scope.row.unitPrice ?? scope.row.dish.price) * scope.row.quantity)).toFixed(2) }}
            </template>
          </el-table-column>
        </el-table>

        <!-- 评价显示区域 -->
        <div class="order-reviews-section">
          <h4>我的评价 & 商家回复</h4>
          <div v-loading="orderReviewsLoading" class="reviews-list">
            <div v-if="orderReview" class="review-item">
              <div class="review-header">
                <span class="dish-name-tag">订单评价</span>
                <span class="time">{{
                  formatTime(orderReview.createTime)
                }}</span>
              </div>

              <div class="rating-row">
                <el-rate
                  v-model="orderReview.overallRating"
                  disabled
                  show-score
                  text-color="#ff9900"
                  score-template="{value}"
                />
              </div>

              <div class="review-content">{{ orderReview.comment }}</div>

              <div
                v-if="orderReview.imageUrls && orderReview.imageUrls.length"
                class="review-images"
              >
                <el-image
                  v-for="(url, index) in orderReview.imageUrls"
                  :key="index"
                  :src="getImageUrl(url)"
                  :preview-src-list="orderReview.imageUrls.map(getImageUrl)"
                  fit="cover"
                  class="review-image"
                  :initial-index="index"
                  preview-teleported
                />
              </div>

              <div
                v-if="orderReview.items && orderReview.items.length"
                class="order-item-ratings"
              >
                <div
                  v-for="it in orderReview.items"
                  :key="it.id || it.dish?.id"
                  class="order-item-rating-row"
                >
                  <span class="item-name">{{ it.dish?.name }}</span>
                  <el-rate
                    :model-value="it.rating"
                    disabled
                    text-color="#ff9900"
                  />
                </div>
              </div>

              <div v-if="orderReview.canteenReply" class="merchant-reply">
                <div class="reply-header">
                  <span class="reply-title">商家回复</span>
                  <span class="reply-time">{{
                    formatTime(orderReview.replyTime)
                  }}</span>
                </div>
                <div class="reply-content">{{ orderReview.canteenReply }}</div>
              </div>
            </div>
            <div v-else class="no-review-message">暂无评价</div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 评价对话框 -->
    <el-dialog
      v-model="reviewVisible"
      :title="'评价订单 - ' + (reviewOrderData?.orderNumber || '')"
      width="600px"
    >
      <div v-if="reviewOrderData" class="review-form">
        <el-form :model="reviewForm" label-width="80px">
          <el-form-item label="菜品评分">
            <div class="dish-ratings">
              <div
                v-for="item in reviewOrderData.items"
                :key="item.id"
                class="dish-rating-row"
              >
                <!-- 如果是套餐，遍历显示其包含的子菜品 -->
                <template v-if="item.dish && item.dish.subDishes && item.dish.subDishes.length > 0">
                   <div v-for="subDish in item.dish.subDishes" :key="subDish.id" style="margin-bottom: 10px;">
                      <span class="dish-name">{{ subDish.name }} (套餐内)</span>
                      <el-rate
                        v-model="reviewForm.itemRatings[subDish.id]"
                        show-score
                      />
                   </div>
                </template>
                <!-- 否则显示普通菜品 -->
                <template v-else-if="item.dish && item.dish.id">
                  <span class="dish-name">{{ item.dish.name }}</span>
                  <el-rate
                    v-model="reviewForm.itemRatings[item.dish.id]"
                    show-score
                  />
                </template>
              </div>
            </div>
          </el-form-item>
          <el-form-item label="口味评分">
            <el-rate v-model="reviewForm.tasteRating" show-score />
          </el-form-item>
          <el-form-item label="分量评分">
            <el-rate v-model="reviewForm.portionRating" show-score />
          </el-form-item>
          <el-form-item label="价格评分">
            <el-rate v-model="reviewForm.priceRating" show-score />
          </el-form-item>
          <el-form-item label="卫生评分">
            <el-rate v-model="reviewForm.hygieneRating" show-score />
          </el-form-item>
          <el-form-item label="文字评价">
            <el-input
              v-model="reviewForm.comment"
              type="textarea"
              :rows="4"
              placeholder="请写下您的用餐体验..."
            />
          </el-form-item>
          <el-form-item label="快捷标签">
            <div class="tags-section">
              <el-checkbox-group v-model="reviewForm.tags">
                <el-checkbox label="色泽诱人" />
                <el-checkbox label="香气扑鼻" />
                <el-checkbox label="味道好" />
                <el-checkbox label="口感鲜美" />
                <el-checkbox label="分量足" />
                <el-checkbox label="食材新鲜" />
                <el-checkbox label="太咸" />
                <el-checkbox label="上菜速度慢" />
                <el-checkbox label="服务好" />
                <el-checkbox label="价格实惠" />
              </el-checkbox-group>
              <div class="custom-tag-input">
                <el-input
                  v-model="customTag"
                  placeholder="自定义标签 (最多2个)"
                  size="small"
                  style="width: 150px; margin-right: 10px"
                  :disabled="reviewForm.customTags.length >= 2"
                  @keyup.enter="addCustomTag"
                />
                <el-button
                  type="primary"
                  size="small"
                  :disabled="reviewForm.customTags.length >= 2 || !customTag"
                  @click="addCustomTag"
                >
                  添加
                </el-button>
              </div>
              <div class="selected-custom-tags">
                <el-tag
                  v-for="(tag, index) in reviewForm.customTags"
                  :key="index"
                  closable
                  style="margin-right: 5px; margin-top: 5px"
                  @close="removeCustomTag(index)"
                >
                  {{ tag }}
                </el-tag>
              </div>
            </div>
          </el-form-item>

          <el-form-item label="上传图片">
            <el-upload
              v-model:file-list="fileList"
              action="#"
              list-type="picture-card"
              :auto-upload="false"
              :limit="5"
              :on-exceed="handleExceed"
              :on-change="handleFileChange"
              :on-remove="handleRemove"
              accept=".jpg,.jpeg,.png"
            >
              <el-icon><Plus /></el-icon>
              <template #tip>
                <div class="el-upload__tip">
                  只能上传jpg/png文件，且不超过5MB，最多5张
                </div>
              </template>
            </el-upload>
            <el-dialog v-model="previewVisible">
              <img
                w-full
                :src="previewImage"
                alt="Preview Image"
                style="width: 100%"
              />
            </el-dialog>
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="reviewVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReview">提交评价</el-button>
      </template>
    </el-dialog>

    <!-- 支付方式选择对话框 -->
    <el-dialog
      v-model="paymentDialogVisible"
      title="选择支付方式"
      width="400px"
      append-to-body
    >
      <div class="payment-methods">
        <div
          class="payment-method-item"
          :class="{ active: selectedPaymentMethod === 'WECHAT' }"
          @click="selectedPaymentMethod = 'WECHAT'"
        >
          <el-icon class="payment-icon wechat"><ChatDotRound /></el-icon>
          <span class="method-name">微信支付</span>
          <el-icon v-if="selectedPaymentMethod === 'WECHAT'" class="check-icon"><Select /></el-icon>
        </div>
        <div
          class="payment-method-item"
          :class="{ active: selectedPaymentMethod === 'ALIPAY' }"
          @click="selectedPaymentMethod = 'ALIPAY'"
        >
          <el-icon class="payment-icon alipay"><Wallet /></el-icon>
          <span class="method-name">支付宝</span>
          <el-icon v-if="selectedPaymentMethod === 'ALIPAY'" class="check-icon"><Select /></el-icon>
        </div>
        <div
          class="payment-method-item"
          :class="{ active: selectedPaymentMethod === 'CARD' }"
          @click="selectedPaymentMethod = 'CARD'"
        >
          <el-icon class="payment-icon card"><CreditCard /></el-icon>
          <span class="method-name">校园一卡通</span>
          <el-icon v-if="selectedPaymentMethod === 'CARD'" class="check-icon"><Select /></el-icon>
        </div>
      </div>
      <template #footer>
        <el-button @click="paymentDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmPayment" :loading="paying">
          确认支付 ¥{{ (payingOrder?.payableAmount ?? payingOrder?.totalAmount ?? 0).toFixed(2) }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import { Picture, Plus, ChatDotRound, Wallet, CreditCard, Select } from "@element-plus/icons-vue";
import { orderApi } from "@/api/order";
import { reviewApi } from "@/api/review";
import api, { buildApiUrl } from "@/api/index";

const loading = ref(false);
const orders = ref([]);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);
const paymentBanner = ref({ visible: false, text: "" });
const supportBanner = ref({
  visible: false,
  text: "系统数据可能不同步，请手动刷新或联系客服：400-800-1234",
  contact: "4008001234",
});
let orderEventSource = null;
let orderPollTimer = null;

// 筛选条件
const filterStatus = ref("");
const dateRange = ref([]);

// 对话框控制
const detailVisible = ref(false);
const reviewVisible = ref(false);
const currentOrder = ref(null);
const reviewOrderData = ref(null);

// 订单评价数据
const orderReview = ref(null);
const orderReviewsLoading = ref(false);

// 图片上传相关
const fileList = ref([]);
const previewVisible = ref(false);
const previewImage = ref("");
const customTag = ref("");

// 支付相关
const paymentDialogVisible = ref(false);
const selectedPaymentMethod = ref('WECHAT');
const payingOrder = ref(null);
const paying = ref(false);

// 评价表单
const reviewForm = reactive({
  tasteRating: 5,
  portionRating: 5,
  priceRating: 5,
  hygieneRating: 5,
  comment: "",
  tags: [],
  customTags: [],
  itemRatings: {},
});

// 图片处理方法
const handleExceed = (files) => {
  ElMessage.warning("最多只能上传 5 张图片");
};

const handleFileChange = (uploadFile, uploadFiles) => {
  const isLt5M = uploadFile.size / 1024 / 1024 < 5;
  if (!isLt5M) {
    ElMessage.error("上传图片大小不能超过 5MB!");
    const index = fileList.value.indexOf(uploadFile);
    if (index !== -1) fileList.value.splice(index, 1);
    return false;
  }
};

const handleRemove = () => {};

// 标签处理方法
const addCustomTag = () => {
  if (customTag.value && reviewForm.customTags.length < 2) {
    if (
      reviewForm.customTags.includes(customTag.value) ||
      reviewForm.tags.includes(customTag.value)
    ) {
      ElMessage.warning("标签已存在");
      return;
    }
    reviewForm.customTags.push(customTag.value);
    customTag.value = "";
  }
};

const removeCustomTag = (index) => {
  reviewForm.customTags.splice(index, 1);
};

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return "";
  return new Date(timeStr).toLocaleString("zh-CN");
};

// 获取图片URL
const getImageUrl = (url) => {
  if (!url) return "";
  if (typeof url !== "string") return String(url);
  if (url.startsWith("http://") || url.startsWith("https://")) return url;
  if (url.startsWith("/")) return url;
  const base = api?.defaults?.baseURL || "";
  return `${base}/uploads/${url}`;
};

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

// 获取取餐方式文本
const getPickupTypeText = (type) => {
  const texts = {
    IMMEDIATE: "立即取餐",
    RESERVATION: "预约取餐",
  };
  return texts[type] || type || "立即取餐";
};

  // 获取支付方式文本
const getPaymentMethodText = (method) => {
  const texts = {
    WECHAT: "微信支付",
    ALIPAY: "支付宝",
    CARD: "校园一卡通",
  };
  return texts[method] || method;
};

// 格式化取餐位置（食堂-窗口）
const formatPickupLocation = (order) => {
  const firstItem = order.items?.[0];
  const dish = firstItem?.dish;

  // 优先从菜品信息中获取
  const canteenName = dish?.canteenName || firstItem?.canteenName || '';
  const windowName = dish?.windowName || order.windowName || '';

  // 组合显示
  if (canteenName && windowName) {
    return `${canteenName} - ${windowName}`;
  } else if (windowName) {
    return windowName;
  } else if (canteenName) {
    return canteenName;
  }
  return '未知位置';
};

const toLocalDateTimeParam = (value, endOfDay = false) => {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  if (endOfDay) date.setHours(23, 59, 59, 999);
  const offset = date.getTimezoneOffset() * 60000;
  return new Date(date.getTime() - offset).toISOString().slice(0, 19);
};

const buildOrderQueryParams = () => {
  const params = {
    page: Math.max(0, Number(currentPage.value || 1) - 1),
    size: Number(pageSize.value || 10),
  };

  if (filterStatus.value) {
    params.status = filterStatus.value;
  }

  const startDate = toLocalDateTimeParam(dateRange.value?.[0]);
  const endDate = toLocalDateTimeParam(dateRange.value?.[1], true);
  if (startDate) params.startDate = startDate;
  if (endDate) params.endDate = endDate;

  return params;
};

// 加载订单列表
const loadOrders = async (silent = false) => {
  try {
    if (!silent) loading.value = true;
    const response = await orderApi.getOrders(buildOrderQueryParams());
    const { rows, totalElements } = orderApi.normalizeOrderListResponse(response);
    orders.value = rows;
    total.value = Number(totalElements || 0);
  } catch (error) {
    orders.value = [];
    total.value = 0;
    ElMessage.error("加载订单失败");
    console.error("加载订单失败:", error);
  } finally {
    if (!silent) loading.value = false;
  }
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  loadOrders();
};

// 重置筛选条件
const resetFilters = () => {
  filterStatus.value = "";
  dateRange.value = [];
  handleSearch();
};

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size;
  currentPage.value = 1;
  loadOrders();
};

const handleCurrentChange = (page) => {
  currentPage.value = page;
  loadOrders();
};

// 支付订单
const payOrder = (order) => {
  payingOrder.value = order;
  selectedPaymentMethod.value = "WECHAT";
  paymentDialogVisible.value = true;
};

const unwrapApiPayload = (response) => response?.data?.data ?? response?.data ?? response;

const buildMockCompletionPayload = (paymentCreateResult) => {
  if (!paymentCreateResult?.transactionId) {
    throw new Error("Payment transaction id is required");
  }
  return {
    paymentMethod: paymentCreateResult.paymentMethod || selectedPaymentMethod.value,
    transactionId: paymentCreateResult.transactionId,
    paidAt: new Date().toISOString(),
  };
};

// 确认支付
const confirmPayment = async () => {
  if (!payingOrder.value) return;
  paying.value = true;
  let paymentCreateResult = null;
  try {
    const createRes = await orderApi.createPayment(payingOrder.value.id, {
      paymentMethod: selectedPaymentMethod.value,
    });
    paymentCreateResult = unwrapApiPayload(createRes);
    const res = await orderApi.markPaid(
      payingOrder.value.id,
      buildMockCompletionPayload(paymentCreateResult),
    );
    const completedPayment = unwrapApiPayload(res);
    paymentBanner.value = {
      visible: true,
      text: `订单号 ${completedPayment.orderNumber} 已支付成功`,
    };
    paymentDialogVisible.value = false;
    await loadOrders();
    const updated = orders.value.find((o) => o.id === payingOrder.value.id);
    if (!updated || updated.status !== "PAID") {
      supportBanner.value = {
        visible: true,
        text: `订单号 ${payingOrder.value.orderNumber} 支付成功，但页面未同步，请手动刷新或联系客服：400-800-1234`,
        contact: "4008001234",
      };
    }
  } catch (error) {
    ElMessage.error("支付失败，正在重试...");
    for (let i = 0; i < 2; i++) {
      try {
        await new Promise((r) => setTimeout(r, 1000 * (i + 1)));
        if (!paymentCreateResult?.transactionId) {
          const retryCreateRes = await orderApi.createPayment(payingOrder.value.id, {
            paymentMethod: selectedPaymentMethod.value,
          });
          paymentCreateResult = unwrapApiPayload(retryCreateRes);
        }
        await orderApi.markPaid(
          payingOrder.value.id,
          buildMockCompletionPayload(paymentCreateResult),
        );
        paymentBanner.value = {
          visible: true,
          text: `订单号 ${payingOrder.value.orderNumber} 支付成功（重试）`,
        };
        paymentDialogVisible.value = false;
        await loadOrders();
        return;
      } catch (e) {}
    }
    ElMessage.error("支付失败，请手动刷新或联系客服");
    supportBanner.value = {
      visible: true,
      text: "支付失败或未同步，请手动刷新或联系客服：400-800-1234",
      contact: "4008001234",
    };
  } finally {
    paying.value = false;
  }
};

const startPolling = () => {
  if (orderPollTimer) clearTimeout(orderPollTimer);
  orderPollTimer = setTimeout(async () => {
    if (!orderPollTimer) return; // 已卸载
    await loadOrders(true);
    if (orderPollTimer) startPolling(); // 继续轮询
  }, 5000);
};

const subscribeOrderEvents = () => {
  if (orderEventSource) return;
  try {
    const token = localStorage.getItem("token");
    orderEventSource = new EventSource(
      buildApiUrl("/api/orders/events", { token }),
      { withCredentials: true },
    );
    orderEventSource.addEventListener("order-update", (evt) => {
      try {
        const data = JSON.parse(evt.data);
        const idx = orders.value.findIndex((o) => o.id === data.id);
        if (idx !== -1) {
          const old = orders.value[idx];
          orders.value[idx] = {
            ...old,
            status: data.status,
            paymentMethod: data.paymentMethod,
            paymentTransactionId: data.transactionId,
            paymentTime: data.paymentTime,
          };
        }
      } catch (e) {}
    });
    orderEventSource.onerror = () => {
      if (orderEventSource) {
        orderEventSource.close();
        orderEventSource = null;
      }
      supportBanner.value = {
        visible: true,
        text: "实时同步异常，已切换为轮询；若仍不同步请联系客服：400-800-1234",
        contact: "4008001234",
      };
      startPolling();
    };
  } catch (e) {
    supportBanner.value = {
      visible: true,
      text: "实时订阅不可用，已切换为轮询；若仍不同步请联系客服：400-800-1234",
      contact: "4008001234",
    };
    startPolling();
  }
};

// 取消订单
const cancelOrder = async (order) => {
  try {
    await ElMessageBox.confirm("确定要取消该订单吗？", "提示", {
      type: "warning",
    });

    await orderApi.cancelOrder(order.id);
    ElMessage.success("订单已取消");
    await loadOrders(); // 重新加载订单列表
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("取消订单失败");
    }
  }
};

// 确认取餐
const confirmPickup = async (order) => {
  try {
    await orderApi.confirmPickup(order.id);
    ElMessage.success("取餐确认成功");
    await loadOrders(); // 重新加载订单列表
  } catch (error) {
    ElMessage.error("确认取餐失败");
  }
};

// 查看订单详情
const viewOrderDetail = (order) => {
  currentOrder.value = order;
  orderReview.value = null;
  detailVisible.value = true;
  loadOrderReviews(order.id);
};

// 加载订单评价
const loadOrderReviews = async (orderId) => {
  orderReview.value = null;
  if (orderId == null || orderId === "") {
    orderReviewsLoading.value = false;
    return;
  }
  try {
    orderReviewsLoading.value = true;
    const res = await reviewApi.getOrderReviews(orderId);
    orderReview.value = res?.data?.data || null;
  } catch (error) {
    console.error("加载订单评价失败:", error);
    orderReview.value = null;
  } finally {
    orderReviewsLoading.value = false;
  }
};

// 评价订单
const reviewOrder = (order) => {
  reviewOrderData.value = order;
  reviewVisible.value = true;

  // 重置评价表单
  Object.assign(reviewForm, {
    tasteRating: 5,
    portionRating: 5,
    priceRating: 5,
    hygieneRating: 5,
    comment: "",
    tags: [],
    customTags: [],
    itemRatings: {},
  });
  if (order?.items && Array.isArray(order.items)) {
    order.items.forEach((it) => {
      // 检查是否是套餐（带有 subDishes）
      if (it?.dish?.subDishes && Array.isArray(it.dish.subDishes)) {
        it.dish.subDishes.forEach(subDish => {
            if (subDish?.id) {
                reviewForm.itemRatings[subDish.id] = 5;
            }
        });
      } else if (it?.dish?.id) {
        reviewForm.itemRatings[it.dish.id] = 5;
      }
    });
  }
  fileList.value = [];
  customTag.value = "";
};

// 提交评价
const submitReview = async () => {
  try {
    const combinedTags = [...reviewForm.tags, ...reviewForm.customTags];

    const items = [];
    
    (reviewOrderData.value?.items || []).forEach(it => {
        if (it?.dish?.subDishes && Array.isArray(it.dish.subDishes)) {
            // 套餐：添加子菜品评分
            it.dish.subDishes.forEach(subDish => {
                if (subDish.id) {
                    items.push({
                        dishId: subDish.id,
                        rating: Number(reviewForm.itemRatings[subDish.id] || 5)
                    });
                }
            });
        } else if (it?.dish?.id) {
            // 普通菜品
             items.push({
                dishId: it.dish.id,
                rating: Number(reviewForm.itemRatings[it.dish.id] || 5)
            });
        }
    });

    const formData = new FormData();
    const reviewData = {
      orderId: reviewOrderData.value.id,
      tasteRating: reviewForm.tasteRating,
      portionRating: reviewForm.portionRating,
      priceRating: reviewForm.priceRating,
      hygieneRating: reviewForm.hygieneRating,
      comment: reviewForm.comment,
      quickTags: combinedTags,
      items,
    };

    formData.append(
      "review",
      new Blob([JSON.stringify(reviewData)], { type: "application/json" }),
    );
    fileList.value.forEach((file) => {
      if (file.raw) {
        formData.append("images", file.raw);
      }
    });

    await reviewApi.createReview(formData);

    ElMessage.success("评价提交成功");
    reviewVisible.value = false;
    loadOrders(); // 刷新订单状态
  } catch (error) {
    ElMessage.error("评价提交失败");
    console.error("评价提交失败:", error);
  }
};

onMounted(() => {
  loadOrders();
  subscribeOrderEvents();
});

onUnmounted(() => {
  if (orderEventSource) {
    orderEventSource.close();
    orderEventSource = null;
  }
  if (orderPollTimer) {
    clearTimeout(orderPollTimer);
    orderPollTimer = null;
  }
});
</script>

<style scoped>
.orders-container {
  max-width: 1200px;
  margin: 0 auto;
}
.payment-success-banner {
  margin: 16px 0;
}
.data-warning-banner {
  margin: 16px 0;
}

.payment-methods {
  display: flex;
  flex-direction: column;
  gap: 15px;
  padding: 10px 0;
}

.payment-method-item {
  display: flex;
  align-items: center;
  padding: 15px;
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
}

.payment-method-item:hover {
  border-color: #409eff;
  background-color: #ecf5ff;
}

.payment-method-item.active {
  border-color: #409eff;
  background-color: #ecf5ff;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.payment-icon {
  font-size: 24px;
  margin-right: 15px;
}

.payment-icon.wechat {
  color: #09bb07;
}

.payment-icon.alipay {
  color: #1678ff;
}

.payment-icon.card {
  color: #e6a23c;
}

.method-name {
  flex: 1;
  font-size: 16px;
  font-weight: 500;
}

.check-icon {
  color: #409eff;
  font-size: 20px;
}

.banner-actions {
  margin-top: 8px;
}

.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 28px;
  color: #333;
  margin-bottom: 10px;
}

.page-subtitle {
  font-size: 16px;
  color: #666;
}

.filter-card {
  margin-bottom: 30px;
}

.order-item {
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  margin-bottom: 20px;
  padding: 20px;
  background: white;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.order-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.order-number {
  font-weight: bold;
  color: #333;
}

.order-time {
  font-size: 14px;
  color: #666;
}

.order-content {
  margin-bottom: 15px;
}

.order-items {
  margin-bottom: 15px;
}

.order-item-detail {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f5f5f5;
}

.order-item-detail:last-child {
  border-bottom: none;
}

.item-image {
  width: 60px;
  height: 60px;
  border-radius: 6px;
  margin-right: 15px;
}

.image-error {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #ccc;
}

.item-info {
  flex: 1;
}

.item-name {
  margin: 0 0 5px;
  font-size: 14px;
  color: #333;
}

.item-price {
  margin: 0;
  font-size: 12px;
  color: #666;
}

.item-subtotal {
  font-weight: bold;
  color: #f56c6c;
}

.order-summary {
  text-align: right;
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
}

.summary-row.total {
  font-weight: bold;
  font-size: 16px;
  border-top: 1px solid #f0f0f0;
  padding-top: 8px;
  margin-top: 8px;
}

.total-amount {
  color: #f56c6c;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.pickup-info p {
  margin: 5px 0;
  font-size: 14px;
  color: #666;
}

.order-actions {
  display: flex;
  gap: 10px;
}

.pagination {
  margin-top: 30px;
  text-align: center;
}

.empty-orders {
  padding: 60px 0;
}

.order-detail h4 {
  margin: 20px 0 15px;
  color: #333;
}

.review-form {
  padding: 0 20px;
}

@media (max-width: 768px) {
  .order-footer {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }

  .order-actions {
    width: 100%;
    justify-content: flex-end;
  }
}

.order-reviews-section {
  margin-top: 20px;
  border-top: 1px solid #eee;
  padding-top: 10px;
}

.review-item {
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0;
}

.review-item:last-child {
  border-bottom: none;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.dish-name-tag {
  font-weight: bold;
  color: #333;
  background-color: #f0f9eb;
  color: #67c23a;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 12px;
}

.rating-row {
  margin-bottom: 8px;
}

.review-content {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  margin-bottom: 10px;
}

.review-images {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
}

.review-image {
  width: 80px;
  height: 80px;
  border-radius: 4px;
  border: 1px solid #eee;
}

.merchant-reply {
  background-color: #f5f7fa;
  border-radius: 4px;
  padding: 10px;
  margin-top: 10px;
  border-left: 3px solid #409eff;
}

.reply-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
}

.reply-title {
  font-weight: bold;
  color: #409eff;
  font-size: 13px;
}

.reply-time {
  font-size: 12px;
  color: #999;
}

.reply-content {
  font-size: 13px;
  color: #606266;
  line-height: 1.5;
}
</style>
