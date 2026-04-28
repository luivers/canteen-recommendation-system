<template>
  <div class="promotions-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">促销管理</h1>
      <div class="header-actions">
        <el-button type="primary" @click="handleCreatePromotion">
          <el-icon><Plus /></el-icon>
          创建促销
        </el-button>
        <el-button @click="handleRefresh">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </div>

    <!-- 促销统计 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #409eff">
              <el-icon><Discount /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.activePromotions }}</div>
              <div class="stat-label">进行中促销</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #67c23a">
              <el-icon><TrendCharts /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalOrders }}</div>
              <div class="stat-label">促销订单数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #e6a23c">
              <el-icon><Money /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">¥{{ formatInteger(stats.totalDiscount) }}</div>
              <div class="stat-label">总优惠金额</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #f56c6c">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.participationRate }}%</div>
              <div class="stat-label">参与率</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索筛选 -->
    <el-card class="filter-card">
      <el-form :model="filterForm" inline>
        <el-form-item label="促销名称">
          <el-input
            v-model="filterForm.name"
            placeholder="请输入促销名称"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="促销类型">
          <el-select
            v-model="filterForm.type"
            placeholder="请选择类型"
            clearable
            style="width: 120px"
          >
            <el-option label="折扣" value="discount" />
            <el-option label="满减" value="full_reduction" />
            <el-option label="组合优惠" value="combo" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="filterForm.status"
            placeholder="请选择状态"
            clearable
            style="width: 120px"
          >
            <el-option label="未开始" value="pending" />
            <el-option label="进行中" value="active" />
            <el-option label="已结束" value="ended" />
            <el-option label="已禁用" value="disabled" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="filterForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 促销列表 -->
    <el-card>
      <template #header>
        <span>促销列表</span>
      </template>

      <el-table v-loading="loading" :data="promotions">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column label="促销名称" min-width="150">
          <template #default="scope">
            <div class="promotion-name">
              <el-tag
                v-if="scope.row.isHot"
                type="danger"
                size="small"
                style="margin-right: 5px"
              >
                热
              </el-tag>
              {{ scope.row.name }}
            </div>
          </template>
        </el-table-column>
        <el-table-column label="促销类型" width="100">
          <template #default="scope">
            <el-tag :type="getPromotionType(scope.row.type)">
              {{ getPromotionTypeText(scope.row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="优惠内容" min-width="150">
          <template #default="scope">
            <div class="discount-content">
              {{ getDiscountContent(scope.row) }}
            </div>
          </template>
        </el-table-column>
        <el-table-column label="适用菜品" width="120">
          <template #default="scope">
            <span v-if="scope.row.targetType === 'all'">全部菜品</span>
            <span v-else-if="scope.row.targetType === 'category'"
              >分类菜品</span
            >
            <span v-else-if="scope.row.targetType === 'specific'"
              >指定菜品</span
            >
          </template>
        </el-table-column>
        <el-table-column label="时间范围" width="200">
          <template #default="scope">
            <div class="time-range">
              <div>{{ scope.row.startTime }}</div>
              <div>至 {{ scope.row.endTime }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="数据统计" width="150">
          <template #default="scope">
            <div class="stats-info">
              <div>订单: {{ scope.row.orderCount }}</div>
              <div>优惠: ¥{{ formatInteger(scope.row.totalDiscount) }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button
              size="small"
              :disabled="scope.row.status === 'ended'"
              @click="handleEdit(scope.row)"
            >
              编辑
            </el-button>
            <el-button
              size="small"
              :type="scope.row.status === 'active' ? 'warning' : 'success'"
              @click="handleToggleStatus(scope.row)"
            >
              {{ scope.row.status === "active" ? "禁用" : "启用" }}
            </el-button>
            <el-button
              size="small"
              type="danger"
              :disabled="scope.row.status === 'active'"
              @click="handleDelete(scope.row)"
            >
              删除
            </el-button>
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

    <!-- 创建/编辑促销对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="800px"
      :before-close="handleDialogClose"
    >
      <el-form
        ref="promotionFormRef"
        :model="promotionForm"
        :rules="promotionRules"
        label-width="120px"
      >
        <el-form-item label="促销名称" prop="name">
          <el-input v-model="promotionForm.name" placeholder="请输入促销名称" />
        </el-form-item>

        <el-form-item label="促销类型" prop="type">
          <el-select v-model="promotionForm.type" placeholder="请选择促销类型">
            <el-option label="折扣" value="discount" />
            <el-option label="满减" value="full_reduction" />
            <el-option label="组合优惠" value="combo" />
          </el-select>
        </el-form-item>

        <el-form-item label="优惠内容" prop="discountValue">
          <div v-if="promotionForm.type === 'discount'">
            <el-input-number
              v-model="promotionForm.discountValue"
              :min="0.1"
              :max="0.9"
              :step="0.1"
              :precision="1"
              controls-position="right"
            />
            <span style="margin-left: 10px">折</span>
          </div>
          <div v-else-if="promotionForm.type === 'full_reduction'">
            <el-input-number
              v-model="promotionForm.fullAmount"
              :min="0"
              :step="1"
              controls-position="right"
              placeholder="满"
            />
            <span style="margin: 0 10px">减</span>
            <el-input-number
              v-model="promotionForm.reduceAmount"
              :min="0"
              :step="1"
              controls-position="right"
              placeholder="减"
            />
          </div>
          <div v-else-if="promotionForm.type === 'combo'">
            <el-button type="primary" size="small" @click="handleAddCombo"
              >添加套餐</el-button
            >
            <el-table
              :data="promotionForm.combos"
              style="margin-top: 10px"
              border
              size="small"
            >
              <el-table-column prop="name" label="套餐名称" />
              <el-table-column prop="price" label="价格" width="100">
                <template #default="{ row }">¥{{ row.price }}</template>
              </el-table-column>
              <el-table-column label="操作" width="120">
                <template #default="{ $index, row }">
                  <el-button
                    link
                    type="primary"
                    @click="handleEditCombo($index, row)"
                    >编辑</el-button
                  >
                  <el-button
                    link
                    type="danger"
                    @click="handleRemoveCombo($index)"
                    >删除</el-button
                  >
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-form-item>

        <el-form-item label="适用菜品" prop="targetType">
          <el-radio-group v-model="promotionForm.targetType">
            <el-radio value="all">全部菜品</el-radio>
            <el-radio value="category">分类菜品</el-radio>
            <el-radio value="specific">指定菜品</el-radio>
          </el-radio-group>

          <!-- 分类菜品选择 -->
          <el-select
            v-if="promotionForm.targetType === 'category'"
            v-model="promotionForm.targetDishCategories"
            multiple
            placeholder="请选择包含的菜品分类"
            style="width: 100%; margin-top: 10px"
          >
            <el-option label="主食" value="MAIN_DISH" />
            <el-option label="荤菜" value="MEAT_DISH" />
            <el-option label="素菜" value="VEGETABLE" />
            <el-option label="汤类" value="SOUP" />
            <el-option label="小吃" value="SNACK" />
            <el-option label="饮品" value="BEVERAGE" />
          </el-select>

          <!-- 指定菜品选择 -->
          <el-select
            v-if="promotionForm.targetType === 'specific'"
            v-model="promotionForm.dishes"
            multiple
            placeholder="请选择包含的菜品"
            style="width: 100%; margin-top: 10px"
            value-key="id"
            filterable
          >
            <el-option
              v-for="dish in dishList"
              :key="dish.id"
              :label="dish.name"
              :value="dish"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="时间范围" prop="timeRange">
          <el-date-picker
            v-model="promotionForm.timeRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="是否热门" prop="isHot">
          <el-switch v-model="promotionForm.isHot" />
        </el-form-item>

        <el-form-item label="促销描述" prop="description">
          <el-input
            v-model="promotionForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入促销描述"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="handleDialogClose">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 套餐编辑对话框 -->
    <el-dialog
      v-model="comboDialogVisible"
      :title="currentCombo.index > -1 ? '编辑套餐' : '添加套餐'"
      width="600px"
      append-to-body
      :before-close="handleComboDialogClose"
    >
      <el-form :model="currentCombo" label-width="100px">
        <el-form-item label="套餐名称" required>
          <el-input v-model="currentCombo.name" placeholder="请输入套餐名称" />
        </el-form-item>
        <el-form-item label="套餐描述">
          <el-input
            v-model="currentCombo.description"
            type="textarea"
            placeholder="请输入套餐描述"
          />
        </el-form-item>
        <el-form-item label="价格" required>
          <el-input-number
            v-model="currentCombo.price"
            :min="0"
            :precision="2"
            controls-position="right"
          />
        </el-form-item>
        <el-form-item label="原价">
          <el-input-number
            v-model="currentCombo.originalPrice"
            :min="0"
            :precision="2"
            controls-position="right"
          />
        </el-form-item>
        <el-form-item label="包含菜品">
          <el-select
            v-model="currentCombo.dishes"
            multiple
            placeholder="请选择包含的菜品"
            style="width: 100%"
            value-key="id"
            filterable
          >
            <el-option
              v-for="dish in dishList"
              :key="dish.id"
              :label="dish.name"
              :value="dish"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="handleComboDialogClose">取消</el-button>
        <el-button type="primary" @click="saveCombo">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  Plus,
  Refresh,
  Discount,
  TrendCharts,
  Money,
  User,
} from "@element-plus/icons-vue";
import { promotionsAPI } from "@/api/promotions";
import { dishApi } from "@/api/dish";
import api from "@/api"; // 导入通用API实例用于获取分类

const formatInteger = (value) => {
  if (value === null || value === undefined) return 0;
  return Math.round(Number(value));
};

const loading = ref(false);
const dialogVisible = ref(false);
const comboDialogVisible = ref(false);
const promotionFormRef = ref();

const filterForm = reactive({
  name: "",
  type: "",
  status: "",
  dateRange: [],
});

const stats = reactive({
  activePromotions: 0,
  totalOrders: 0,
  totalDiscount: 0,
  participationRate: 0,
});

const promotions = ref([]);
const dishList = ref([]);

const pagination = reactive({
  current: 1,
  size: 10,
  total: 0,
});

const promotionForm = reactive({
  id: "",
  name: "",
  type: "discount",
  discountValue: 0.8,
  fullAmount: 0,
  reduceAmount: 0,
  targetType: "all",
  description: "",
  timeRange: [],
  dishes: [],
  targetDishCategories: [], // 分类菜品字段
  combos: [],
});

const currentCombo = reactive({
  index: -1,
  name: "",
  description: "",
  price: 0,
  originalPrice: 0,
  dishes: [],
});

const promotionRules = {
  name: [{ required: true, message: "请输入促销名称", trigger: "blur" }],
  type: [{ required: true, message: "请选择促销类型", trigger: "change" }],
  timeRange: [{ required: true, message: "请选择时间范围", trigger: "change" }],
};

const dialogTitle = computed(() => {
  return promotionForm.id ? "编辑促销" : "创建促销";
});

// 获取促销类型
const getPromotionType = (type) => {
  const types = {
    discount: "primary",
    full_reduction: "success",
    gift: "warning",
    time_limit: "info",
    combo: "danger",
  };
  return types[type] || "info";
};

// 获取促销类型文本
const getPromotionTypeText = (type) => {
  const texts = {
    discount: "折扣",
    full_reduction: "满减",
    gift: "买赠",
    time_limit: "限时优惠",
    combo: "组合优惠",
  };
  return texts[type] || type;
};

// 获取优惠内容
const getDiscountContent = (promotion) => {
  switch (promotion.type) {
    case "discount":
      return `${(promotion.discountValue * 10).toFixed(1)}折`;
    case "full_reduction":
      return `满${promotion.fullAmount}减${promotion.reduceAmount}`;
    case "time_limit":
      return "限时优惠";
    case "combo":
      return "组合优惠";
    default:
      return promotion.type;
  }
};

// 获取状态类型
const getStatusType = (status) => {
  const types = {
    pending: "info",
    active: "success",
    ended: "warning",
    disabled: "danger",
  };
  return types[status] || "info";
};

// 获取状态文本
const getStatusText = (status) => {
  const texts = {
    pending: "未开始",
    active: "进行中",
    ended: "已结束",
    disabled: "已禁用",
  };
  return texts[status] || status;
};

// 加载数据
const loadData = async () => {
  loading.value = true;
  try {
    // 加载统计数据
    const statsResponse = await promotionsAPI.getStats();
    if (statsResponse.status === 200) {
      const statsData = statsResponse.data;
      stats.activePromotions = statsData.activePromotions || 0;
      stats.totalOrders = statsData.totalOrders || 0;
      stats.totalDiscount = statsData.totalDiscount || 0;
      stats.participationRate = statsData.participationRate || 0;
    }

    // 加载促销活动列表
    const params = {
      page: pagination.current,
      size: pagination.size,
    };

    // 检查是否有搜索条件
    let hasSearch = false;
    const searchParams = { ...params };

    if (filterForm.name) {
      searchParams.name = filterForm.name;
      hasSearch = true;
    }
    if (filterForm.type) {
      searchParams.type = filterForm.type;
      hasSearch = true;
    }
    if (filterForm.status) {
      searchParams.status = filterForm.status;
      hasSearch = true;
    }
    if (filterForm.dateRange && filterForm.dateRange.length === 2) {
      searchParams.startTime = filterForm.dateRange[0] + " 00:00:00";
      searchParams.endTime = filterForm.dateRange[1] + " 23:59:59";
      hasSearch = true;
    }

    let promotionsResponse;
    if (hasSearch) {
      const { page, size, ...searchBody } = searchParams;
      promotionsResponse = await promotionsAPI.searchPromotions(searchBody, {
        page,
        size,
      });
    } else {
      promotionsResponse = await promotionsAPI.getPromotions(params);
    }
    if (promotionsResponse.status === 200) {
      const promotionsData = promotionsResponse.data;
      promotions.value = promotionsData.content || [];
      pagination.total = promotionsData.totalElements || 0;
    }
  } catch (error) {
    ElMessage.error("加载数据失败");
    console.error("加载促销数据失败:", error);
  } finally {
    loading.value = false;
  }
};

// 搜索
const handleSearch = () => {
  pagination.current = 1;
  loadData();
};

// 重置搜索
const handleReset = () => {
  Object.keys(filterForm).forEach((key) => {
    if (Array.isArray(filterForm[key])) {
      filterForm[key] = [];
    } else {
      filterForm[key] = "";
    }
  });
  handleSearch();
};

// 创建促销
const handleCreatePromotion = async () => {
  // 确保菜品列表和分类列表已加载
  if (dishList.value.length === 0) {
    await loadDishes();
  }
  Object.keys(promotionForm).forEach((key) => {
    if (Array.isArray(promotionForm[key])) {
      promotionForm[key] = [];
    } else if (typeof promotionForm[key] === "boolean") {
      promotionForm[key] = false;
    } else {
      promotionForm[key] = "";
    }
  });
  promotionForm.type = "discount";
  promotionForm.discountValue = 0.8;
  promotionForm.targetType = "all";
  dialogVisible.value = true;
};

// 编辑促销
const handleEdit = async (row) => {
  // 确保菜品列表和分类列表已加载
  if (dishList.value.length === 0) {
    await loadDishes();
  }
  Object.assign(promotionForm, row);
  promotionForm.timeRange = [row.startTime, row.endTime];
  if (!promotionForm.dishes) promotionForm.dishes = [];
  if (!promotionForm.targetDishCategories) promotionForm.targetDishCategories = [];
  if (!promotionForm.combos) promotionForm.combos = [];
  dialogVisible.value = true;
};

// 切换状态
const handleToggleStatus = async (row) => {
  try {
    const newStatus = row.status === "active" ? "disabled" : "active";
    const action = newStatus === "active" ? "启用" : "禁用";

    await ElMessageBox.confirm(`确定要${action}这个促销吗？`, "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    const response = await promotionsAPI.togglePromotionStatus(row.id);
    if (response.status === 200) {
      const updatedPromotion = response.data;
      Object.assign(row, updatedPromotion);
      ElMessage.success(`${action}成功`);
    } else {
      ElMessage.error(`${action}失败`);
    }
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("操作失败");
      console.error("切换促销状态失败:", error);
    }
  }
};

onMounted(() => {
  loadData();
  loadDishes();
});

const loadDishes = async () => {
  try {
    // 使用与Dishes.vue相同的逻辑加载菜品
    // 注意：后端可能没有分页参数支持size=1000，这里假设getDishes返回所有或支持size
    const response = await dishApi.getDishes();

    let dishesData = [];
    if (Array.isArray(response)) {
      dishesData = response;
    } else if (response.data) {
      if (Array.isArray(response.data)) {
        dishesData = response.data;
      } else if (response.data.items || response.data.records) {
        dishesData = response.data.items || response.data.records;
      }
    }

    dishList.value = dishesData || [];
    console.log("已加载菜品列表:", dishList.value.length);
  } catch (error) {
    console.error("加载菜品失败", error);
    ElMessage.warning("加载菜品列表失败，部分功能可能受限");
  }
};

const handleAddCombo = async () => {
  // 确保菜品列表已加载
  if (dishList.value.length === 0) {
    await loadDishes();
  }
  currentCombo.index = -1;
  currentCombo.name = "";
  currentCombo.description = "";
  currentCombo.price = 0;
  currentCombo.originalPrice = 0;
  currentCombo.dishes = [];
  comboDialogVisible.value = true;
};

const handleEditCombo = async (index, row) => {
  // 确保菜品列表已加载
  if (dishList.value.length === 0) {
    await loadDishes();
  }
  currentCombo.index = index;
  Object.assign(currentCombo, row);
  // Ensure dishes is an array of objects
  if (!currentCombo.dishes) currentCombo.dishes = [];
  comboDialogVisible.value = true;
};

const handleRemoveCombo = (index) => {
  promotionForm.combos.splice(index, 1);
};

const saveCombo = () => {
  if (!currentCombo.name) {
    ElMessage.warning("请输入套餐名称");
    return;
  }

  const comboData = {
    name: currentCombo.name,
    description: currentCombo.description,
    price: currentCombo.price,
    originalPrice: currentCombo.originalPrice,
    dishes: currentCombo.dishes,
  };

  if (currentCombo.index > -1) {
    promotionForm.combos[currentCombo.index] = comboData;
  } else {
    promotionForm.combos.push(comboData);
  }
  comboDialogVisible.value = false;
};

const handleComboDialogClose = () => {
  comboDialogVisible.value = false;
};

// 删除促销
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      "确定要删除这个促销吗？删除后无法恢复。",
      "警告",
      {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      },
    );

    // 调用API删除促销
    const response = await promotionsAPI.deletePromotion(row.id);
    if (response.status === 204) {
      // 从列表中移除
      promotions.value = promotions.value.filter((p) => p.id !== row.id);
      ElMessage.success("删除成功");
      // 更新分页总数
      pagination.total--;
    } else {
      ElMessage.error("删除失败");
    }
  } catch (error) {
    if (error !== "cancel") {
      ElMessage.error("操作失败");
      console.error("删除促销失败:", error);
    }
    // 用户取消操作
  }
};

// 提交表单
const handleSubmit = async () => {
  if (!promotionFormRef.value) return;

  try {
    await promotionFormRef.value.validate();

    // 准备提交数据
    const submitData = {
      ...promotionForm,
      startTime: promotionForm.timeRange[0],
      endTime: promotionForm.timeRange[1],
    };

    // 移除不必要的字段
    delete submitData.timeRange;

    let response;
    if (promotionForm.id) {
      // 编辑促销活动
      response = await promotionsAPI.updatePromotion(
        promotionForm.id,
        submitData,
      );
    } else {
      // 创建促销活动
      response = await promotionsAPI.createPromotion(submitData);
    }

    if (response.status === 200 || response.status === 201) {
      ElMessage.success(promotionForm.id ? "编辑成功" : "创建成功");
      dialogVisible.value = false;
      loadData();
    } else {
      ElMessage.error(promotionForm.id ? "编辑失败" : "创建失败");
    }
  } catch (error) {
    ElMessage.error("操作失败");
    console.error("提交促销表单失败:", error);
  }
};

// 关闭对话框
const handleDialogClose = () => {
  dialogVisible.value = false;
  promotionFormRef.value?.resetFields();
};

// 分页大小变化
const handleSizeChange = (size) => {
  pagination.size = size;
  pagination.current = 1;
  loadData();
};

// 当前页变化
const handleCurrentChange = (current) => {
  pagination.current = current;
  loadData();
};

// 刷新数据
const handleRefresh = () => {
  loadData();
  ElMessage.success("数据已刷新");
};

// 初始化加载数据
loadData();
</script>

<style scoped>
.promotions-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
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

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  padding: 20px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  color: white;
  font-size: 24px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #666;
}

.filter-card {
  margin-bottom: 20px;
}

.promotion-name {
  display: flex;
  align-items: center;
}

.discount-content {
  font-weight: 500;
  color: #e6a23c;
}

.time-range {
  font-size: 12px;
  color: #666;
}

.stats-info {
  font-size: 12px;
  color: #666;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
