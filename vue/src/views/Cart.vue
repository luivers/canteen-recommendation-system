<template>
  <div class="cart-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">购物车</h1>
      <p class="page-subtitle">确认您的选购菜品</p>
    </div>

    <div class="cart-content">
      <!-- 购物车列表 -->
      <el-card v-loading="loading" class="cart-list">
        <template #header>
          <div class="cart-header">
            <span>购物车 ({{ cartItems.length }}件商品)</span>
            <el-button
              type="danger"
              size="small"
              :disabled="cartItems.length === 0"
              @click="clearCart"
            >
              清空购物车
            </el-button>
          </div>
        </template>

        <div v-if="cartItems.length === 0" class="empty-cart">
          <el-empty description="购物车为空">
            <el-button type="primary" @click="$router.push('/dishes')">
              去选购菜品
            </el-button>
          </el-empty>
        </div>

        <div v-else>
          <div v-for="item in cartItems" :key="item.id" class="cart-item">
            <div v-if="item.type === 'COMBO'" class="item-info">
              <el-image :src="toImageUrl(item.combo?.image)" class="item-image" fit="cover">
                <template #error>
                  <div class="image-error">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>

              <div class="item-details">
                <h4 class="item-name">{{ item.combo?.name }}</h4>
                <p v-if="item.combo?.description" class="item-description">
                  {{ item.combo.description }}
                </p>
                <p class="item-category">套餐</p>
                <p v-if="item.combo?.promotionName" class="item-window">
                  {{ item.combo.promotionName }}
                </p>
                <div class="item-tags">
                  <el-tag
                    v-for="n in (item.dishes || [])
                      .map((d) => d?.name)
                      .filter(Boolean)
                      .slice(0, 6)"
                    :key="n"
                    size="small"
                    type="info"
                  >
                    {{ n }}
                  </el-tag>
                </div>
              </div>
            </div>

            <div v-else class="item-info">
              <el-image :src="toImageUrl(item.dish?.imageUrl || item.dish?.image)" class="item-image" fit="cover">
                <template #error>
                  <div class="image-error">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>

              <div class="item-details">
                <h4 class="item-name">
                  {{ item.dish.name }}
                  <el-tag v-if="item.isGift" type="danger" size="small" effect="dark" style="margin-left: 5px">赠品</el-tag>
                </h4>
                <p
                  v-if="
                    item.dish.description &&
                    !item.dish.description.startsWith('{')
                  "
                  class="item-description"
                >
                  {{ item.dish.description }}
                </p>
                <p class="item-category">
                  {{
                    formatCategory(
                      item.dish?.dishCategory ||
                        item.dish?.category ||
                        item.dish?.categoryName ||
                        item.dish?.categoryLabel,
                    )
                  }}
                </p>
                <p class="item-window">{{ item.dish.windowName }}</p>
                <div class="item-tags">
                  <el-tag
                    v-for="tag in (item.dish?.tasteTags || item.dish?.tags || [])"
                    :key="tag"
                    size="small"
                    type="info"
                  >
                    {{ getTagText(tag) }}
                  </el-tag>
                </div>
              </div>
            </div>

            <div class="item-controls">
              <div class="quantity-control">
                <el-button
                  size="small"
                  :disabled="item.quantity <= 1"
                  @click="updateQuantity(item, item.quantity - 1)"
                >
                  -
                </el-button>
                <span class="quantity">{{ item.quantity }}</span>
                <el-button
                  size="small"
                  :disabled="item.type !== 'COMBO' && item.dish?.status && item.dish.status !== 'AVAILABLE'"
                  @click="updateQuantity(item, item.quantity + 1)"
                >
                  +
                </el-button>
              </div>

              <div class="item-price">
                <template v-if="item.type === 'COMBO'">
                  ¥{{
                    ((Number(item.combo?.price) || 0) * item.quantity).toFixed(
                      2,
                    )
                  }}
                </template>
                <template v-else>
                  ¥{{ ((item.price !== undefined && item.price !== null ? item.price : item.dish.price) * item.quantity).toFixed(2) }}
                </template>
              </div>

              <el-button
                type="danger"
                size="small"
                @click="removeItem(item.id)"
              >
                删除
              </el-button>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 订单摘要 -->
      <el-card v-if="cartItems.length > 0" class="order-summary">
        <template #header>
          <span>订单摘要</span>
        </template>

        <div class="summary-item">
          <span>商品总价：</span>
          <span>¥{{ totalAmount.toFixed(2) }}</span>
        </div>
        <div class="summary-item">
          <span>代金券：</span>
          <el-select
            v-model="selectedVoucherId"
            clearable
            placeholder="选择代金券"
            style="width: 170px"
            :loading="loadingVouchers"
          >
            <el-option
              v-for="v in voucherOptions"
              :key="v.id"
              :label="v.label"
              :value="v.id"
            />
          </el-select>
        </div>
        <div v-if="voucherDeduction > 0" class="summary-item">
          <span>代金券抵扣：</span>
          <span>-¥{{ voucherDeduction.toFixed(2) }}</span>
        </div>
        <div class="summary-item">
          <span>配送费：</span>
          <span>免费</span>
        </div>
        <div class="summary-item total">
          <span>应付金额：</span>
          <span class="total-amount">¥{{ payableAmount.toFixed(2) }}</span>
        </div>

        <div class="pickup-options">
          <h4>取餐方式</h4>
          <el-radio-group v-model="pickupType">
            <el-radio label="IMMEDIATE">立即取餐</el-radio>
            <el-radio label="RESERVATION">预约取餐</el-radio>
          </el-radio-group>

          <div v-if="pickupType === 'RESERVATION'" class="reservation-time">
            <el-date-picker
              v-model="reservationTime"
              type="datetime"
              placeholder="选择取餐时间"
              :disabled-date="disabledDate"
              :shortcuts="shortcuts"
            />
          </div>
        </div>

        <div class="checkout-actions">
          <el-button
            type="primary"
            size="large"
            class="checkout-btn"
            :loading="checkoutLoading"
            @click="handleCheckout"
          >
            立即下单
          </el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { Picture } from "@element-plus/icons-vue";
import { orderApi } from "@/api/order";
import { rewardsApi } from "@/api/rewards";
import api from "@/api/index";

const router = useRouter();

const loading = ref(false);
const checkoutLoading = ref(false);
const cartItems = ref([]);

// 取餐方式
const pickupType = ref("IMMEDIATE");
const reservationTime = ref("");

const loadingVouchers = ref(false);
const voucherOptions = ref([]);
const selectedVoucherId = ref(null);

// 时间选择器快捷选项
const shortcuts = [
  {
    text: "30分钟后",
    value: () => {
      const date = new Date();
      date.setTime(date.getTime() + 30 * 60 * 1000);
      return date;
    },
  },
  {
    text: "1小时后",
    value: () => {
      const date = new Date();
      date.setTime(date.getTime() + 60 * 60 * 1000);
      return date;
    },
  },
  {
    text: "2小时后",
    value: () => {
      const date = new Date();
      date.setTime(date.getTime() + 120 * 60 * 1000);
      return date;
    },
  },
];

// 格式化分类显示
const CATEGORY_MAP = {
  MAIN_DISH: "主食",
  MEAT_DISH: "荤菜",
  VEGETABLE: "素菜",
  VEGETABLE_DISH: "素菜",
  SOUP: "汤类",
  SNACK: "小吃",
  BEVERAGE: "饮品",
  SIDE_DISH: "菜品",
  MAIN: "主食",
  MEAT: "荤菜",
  DRINK: "饮品",
};

const getObjectCategoryValue = (obj) => {
  if (!obj || typeof obj !== "object") return "";
  const candidate = obj.name || obj.label || obj.text || obj.value || obj.code;
  if (candidate) return String(candidate);
  const nestedCandidate =
    obj.category ||
    obj.dishCategory ||
    obj.categoryName ||
    obj.categoryLabel ||
    "";
  return nestedCandidate ? String(nestedCandidate) : "";
};

const normalizeCategoryKey = (value) =>
  String(value || "")
    .trim()
    .replace(/[-\s]+/g, "_")
    .toUpperCase();

// 格式化分类显示（兼容枚举、对象、JSON 字符串、旧字段）
const formatCategory = (category) => {
  if (category == null || category === "") return "未知分类";

  if (Array.isArray(category)) {
    const first = category.find((v) => v != null && v !== "");
    return first == null ? "未知分类" : formatCategory(first);
  }

  if (typeof category === "object") {
    return formatCategory(getObjectCategoryValue(category));
  }

  const raw = String(category).trim();
  if (!raw) return "未知分类";

  if (
    (raw.startsWith("{") && raw.endsWith("}")) ||
    (raw.startsWith("[") && raw.endsWith("]"))
  ) {
    try {
      return formatCategory(JSON.parse(raw));
    } catch (e) {
      // JSON 解析失败时按普通字符串走映射
    }
  }

  const normalized = normalizeCategoryKey(raw);
  return CATEGORY_MAP[normalized] || raw;
};

const toImageUrl = (url) => {
  if (!url) return "";
  if (typeof url !== "string") return String(url);
  if (url.startsWith("http://") || url.startsWith("https://")) return url;
  if (url.startsWith("/")) return url;
  const base = api?.defaults?.baseURL || "";
  return `${base}/uploads/${url}`;
};

const getTagText = (tag) => {
  if (tag == null) return "";
  const raw = String(tag).trim();
  const key = raw.toLowerCase();
  const tags = {
    spicy: "辣",
    sweet: "甜",
    sour: "酸",
    salty: "咸",
    light: "清淡",
    strong: "重口味",
    麻辣: "麻辣",
    香辣: "香辣",
    酸甜: "酸甜",
  };
  return tags[key] || tags[raw] || raw;
};

// 计算总金额
const totalAmount = computed(() => {
  return cartItems.value.reduce((total, item) => {
    if (item?.type === "COMBO") {
      return (
        total + (Number(item.combo?.price) || 0) * Number(item.quantity || 0)
      );
    }
    const unitPrice = item.price !== undefined && item.price !== null ? item.price : item.dish.price;
    return total + unitPrice * item.quantity;
  }, 0);
});

const selectedVoucher = computed(() =>
  voucherOptions.value.find(
    (v) => Number(v.id) === Number(selectedVoucherId.value),
  ),
);

const voucherDeduction = computed(() => {
  const face = Number(selectedVoucher.value?.faceValue || 0);
  const goods = Number(totalAmount.value || 0);
  if (!face || face <= 0) return 0;
  return Math.max(0, Math.min(face, goods));
});

const payableAmount = computed(() => {
  return Math.max(
    0,
    Number(totalAmount.value || 0) - Number(voucherDeduction.value || 0),
  );
});

// 禁用过去的日期
const disabledDate = (time) => {
  return time.getTime() < Date.now() - 8.64e7; // 禁用今天之前的日期
};

// 加载购物车
const loadCart = async () => {
  try {
    loading.value = true;
    // 调用后端接口获取购物车数据
    const res = await orderApi.getCart();
    const data = res?.data?.data ?? res?.data;
    const serverItems = Array.isArray(data) ? data : [];
    const localItemsRaw = (() => {
      try {
        return JSON.parse(localStorage.getItem("cart") || "[]");
      } catch {
        return [];
      }
    })();
    const comboItems = (Array.isArray(localItemsRaw) ? localItemsRaw : []).filter(
      (i) => i && i.type === "COMBO",
    );
    cartItems.value = [...comboItems, ...serverItems];
    
    // 同步更新 localStorage，以备不时之需或保持同步（可选）
    localStorage.setItem("cart", JSON.stringify(cartItems.value));
  } catch (error) {
    console.error("加载购物车失败:", error);
    ElMessage.error("加载购物车失败");
    // 降级：如果API失败，尝试读取本地缓存
    try {
      const cartData = localStorage.getItem("cart");
      if (cartData) {
        cartItems.value = JSON.parse(cartData);
      }
    } catch (e) {
      cartItems.value = [];
    }
  } finally {
    loading.value = false;
  }
};

const loadUsableVouchers = async () => {
  loadingVouchers.value = true;
  try {
    const res = await rewardsApi.getUsableVouchers(
      Number(totalAmount.value || 0).toFixed(2),
    );
    const rows = Array.isArray(res?.data?.data) ? res.data.data : [];
    voucherOptions.value = rows
      .map((r) => {
        const faceValue = r?.faceValueSnapshot ?? r?.reward?.faceValue ?? 0;
        const name = r?.reward?.name || "代金券";
        return {
          id: r?.id,
          faceValue: Number(faceValue || 0),
          label: `${name}（¥${Number(faceValue || 0).toFixed(0)}）`,
        };
      })
      .filter((v) => v.id);
    if (
      selectedVoucherId.value &&
      !voucherOptions.value.some(
        (v) => Number(v.id) === Number(selectedVoucherId.value),
      )
    ) {
      selectedVoucherId.value = null;
    }
  } catch (e) {
    voucherOptions.value = [];
    selectedVoucherId.value = null;
  } finally {
    loadingVouchers.value = false;
  }
};

// 更新数量
const updateQuantity = async (item, newQuantity) => {
  if (newQuantity < 1) return;

  try {
    if (item?.type === "COMBO") {
      item.quantity = newQuantity;
      localStorage.setItem("cart", JSON.stringify(cartItems.value));
      return;
    }

    // 调用后端更新
    const res = await orderApi.updateCartItem(item.id, newQuantity);
    
    // 如果后端返回了最新的 item，使用它来更新本地数据（可能包含最新的价格）
    const updatedItem = res?.data?.data ?? res?.data;
    if (updatedItem) {
        // 保持原有的 dish 对象结构，如果后端只返回了简单的 dish 信息
        Object.assign(item, updatedItem);
    } else {
        item.quantity = newQuantity;
    }

    // 同步 localStorage
    localStorage.setItem("cart", JSON.stringify(cartItems.value));
  } catch (error) {
    ElMessage.error("更新数量失败");
    console.error(error);
  }
};

// 删除商品
const removeItem = async (itemId) => {
  try {
    await ElMessageBox.confirm("确定要删除该商品吗？", "提示", {
      type: "warning",
    });

    const existed = cartItems.value.find((i) => i?.id === itemId);
    if (existed?.type === "COMBO") {
      cartItems.value = cartItems.value.filter((item) => item.id !== itemId);
      localStorage.setItem("cart", JSON.stringify(cartItems.value));
      ElMessage.success("删除成功");
      return;
    }

    await orderApi.removeFromCart(itemId);

    // 更新本地数据
    cartItems.value = cartItems.value.filter((item) => item.id !== itemId);
    localStorage.setItem("cart", JSON.stringify(cartItems.value));

    ElMessage.success("删除成功");
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("删除失败");
      console.error(error);
    }
  }
};

// 清空购物车
const clearCart = async () => {
  try {
    await ElMessageBox.confirm("确定要清空购物车吗？", "提示", {
      type: "warning",
    });

    await orderApi.clearCart();

    // 更新本地数据
    cartItems.value = [];
    localStorage.removeItem("cart");

    ElMessage.success("购物车已清空");
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("清空失败");
      console.error(error);
    }
  }
};

// 下单
const handleCheckout = async () => {
  if (cartItems.value.length === 0) {
    ElMessage.warning("购物车为空");
    return;
  }

  // 检查预约时间
  if (pickupType.value === "RESERVATION" && !reservationTime.value) {
    ElMessage.warning("请选择预约取餐时间");
    return;
  }

  // 过滤有效商品
  const itemsMap = new Map();
  for (const item of cartItems.value) {
    const qty = Number(item?.quantity || 0);
    if (qty <= 0) continue;
    
    if (item?.type === "COMBO") {
      const comboId = Number(item?.combo?.id);
      if (!comboId) continue;
      const key = `combo_${comboId}`;
      const existing = itemsMap.get(key) || { comboId, quantity: 0, isGift: false };
      existing.quantity += qty;
      itemsMap.set(key, existing);
    } else {
      const dishId = Number(item?.dish?.id);
      if (!dishId) continue;
      const key = `dish_${dishId}_${item.isGift ? 'true' : 'false'}`;
      const existing = itemsMap.get(key) || { dishId, quantity: 0, isGift: item.isGift || false };
      existing.quantity += qty;
      itemsMap.set(key, existing);
    }
  }
  
  if (itemsMap.size === 0) {
    ElMessage.warning("购物车中没有有效商品");
    return;
  }

  try {
    checkoutLoading.value = true;

    const orderData = {
      items: Array.from(itemsMap.values()).map((item) => ({
        dishId: item.dishId ? Number(item.dishId) : null,
        comboId: item.comboId ? Number(item.comboId) : null,
        quantity: Number(item.quantity),
        isGift: Boolean(item.isGift)
      })),
      pickupType: pickupType.value,
      reservationTime:
        pickupType.value === "RESERVATION"
          ? reservationTime.value instanceof Date
            ? reservationTime.value.toISOString()
            : reservationTime.value
          : null,
      voucherExchangeId: selectedVoucherId.value || null,
    };

    const response = await orderApi.createOrder(orderData);
    const status = response?.data?.status || "SUCCESS";
    if (status !== "SUCCESS") {
      throw new Error("订单创建返回非成功状态");
    }
    ElMessage.success("下单成功");

    try {
      localStorage.removeItem("cart");
      await orderApi.clearCart();
      cartItems.value = [];
    } catch (clearErr) {
      console.error("清空购物车失败:", clearErr);
      ElMessage.warning("订单已创建，但购物车清空失败，请稍后重试");
    }

    router.push("/orders");
  } catch (error) {
    console.error("下单失败:", {
      status: error?.response?.status,
      data: error?.response?.data,
      message: error?.message,
    });

    // 特殊处理401错误（Token过期）
    if (error?.response?.status === 401) {
      ElMessage.warning("登录已过期，请重新登录");
      router.push("/login");
      return;
    }

    // 特殊处理400错误
    if (error?.response?.status === 400) {
      const errorMsg = error?.response?.data?.message || error?.response?.data?.error || "订单数据无效";
      // 如果是购物车数据过期，尝试重新加载
      if (errorMsg.includes("购物车") || errorMsg.includes("cart") || errorMsg.includes("过期")) {
        await loadCart();
        ElMessage.warning("购物车数据已更新，请重新确认订单");
        return;
      }
      ElMessage.error(errorMsg);
      return;
    }

    const msg =
      error?.response?.data?.message ||
      error?.response?.data?.error ||
      error?.message ||
      "下单失败，请稍后重试";
    ElMessage.error(msg);
  } finally {
    checkoutLoading.value = false;
  }
};

onMounted(() => {
  loadCart();
  loadUsableVouchers();
});

watch(
  () => totalAmount.value,
  () => {
    loadUsableVouchers();
  },
);
</script>

<style scoped>
.cart-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
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

.cart-content {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 30px;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.empty-cart {
  padding: 60px 0;
}

.cart-item {
  display: flex;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #f0f0f0;
}

.cart-item:last-child {
  border-bottom: none;
}

.item-info {
  display: flex;
  align-items: center;
  flex: 1;
}

.item-image {
  width: var(--dish-image-size);
  height: var(--dish-image-size);
  border-radius: 8px;
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

.item-details {
  flex: 1;
}

.item-name {
  margin: 0 0 5px;
  font-size: 16px;
  color: #333;
}

.item-category,
.item-window {
  margin: 0 0 5px;
  font-size: 14px;
  color: #666;
}

.item-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-top: 5px;
}

.item-controls {
  display: flex;
  align-items: center;
  gap: 20px;
}

.quantity-control {
  display: flex;
  align-items: center;
  gap: 10px;
}

.quantity {
  min-width: 30px;
  text-align: center;
  font-weight: bold;
}

.item-price {
  font-size: 18px;
  color: #f56c6c;
  font-weight: bold;
  min-width: 80px;
  text-align: right;
}

.order-summary {
  height: fit-content;
  position: sticky;
  top: 20px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f0f0f0;
}

.summary-item.total {
  border-bottom: none;
  font-size: 18px;
  font-weight: bold;
}

.total-amount {
  color: #f56c6c;
  font-size: 20px;
}

.pickup-options {
  margin: 20px 0;
}

.pickup-options h4 {
  margin-bottom: 15px;
  color: #333;
}

.reservation-time {
  margin-top: 15px;
}

.checkout-actions {
  margin-top: 20px;
}

.checkout-btn {
  width: 100%;
  height: 50px;
  font-size: 16px;
}

@media (max-width: 768px) {
  .cart-content {
    grid-template-columns: 1fr;
  }

  .cart-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .item-controls {
    width: 100%;
    justify-content: space-between;
    margin-top: 15px;
  }
}
</style>
