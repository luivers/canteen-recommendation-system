<template>
  <div class="dishes-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">菜品浏览</h1>
      <p class="page-subtitle">发现美味，满足味蕾</p>
    </div>

    <!-- 搜索和筛选区域 -->
    <el-card class="filter-card">
      <el-row :gutter="20">
        <el-col :span="5">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索菜品名称"
            prefix-icon="Search"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          />
        </el-col>
        <el-col :span="3">
          <el-select v-model="filterCategory" placeholder="菜品分类" clearable>
            <el-option
              v-for="category in categories"
              :key="category.value"
              :label="category.label"
              :value="category.value"
            />
          </el-select>
        </el-col>
        <el-col :span="3">
          <el-select v-model="filterCanteen" placeholder="食堂筛选" clearable>
            <el-option
              v-for="canteen in canteens"
              :key="canteen.id"
              :label="canteen.name"
              :value="canteen.id"
            />
          </el-select>
        </el-col>
        <el-col :span="3">
          <el-select v-model="filterWindow" placeholder="窗口筛选" clearable>
            <el-option
              v-for="window in windows"
              :key="window.id"
              :label="getWindowOptionLabel(window)"
              :value="window.id"
            />
          </el-select>
        </el-col>
        <el-col :span="3">
          <el-select v-model="filterTag" placeholder="口味标签" clearable>
            <el-option
              v-for="tag in tasteTags"
              :key="tag"
              :label="tag"
              :value="tag"
            />
          </el-select>
        </el-col>
        <el-col :span="3">
          <el-select v-model="sortBy" placeholder="排序方式">
            <el-option label="默认排序" value="default" />
            <el-option label="价格从低到高" value="price_asc" />
            <el-option label="价格从高到低" value="price_desc" />
            <el-option label="评分从高到低" value="rating_desc" />
            <el-option label="销量从高到低" value="sales_desc" />
          </el-select>
        </el-col>
        <el-col :span="4" class="button-group">
          <el-button type="primary" class="search-btn" @click="handleSearch"
            >搜索</el-button
          >
          <el-button class="reset-btn" @click="resetFilters">重置</el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 菜品列表 -->
    <div class="dishes-list">
      <el-row v-loading="loading" :gutter="20">
        <el-col
          v-for="dish in dishes"
          :key="dish.id"
          :span="6"
          class="dish-col"
        >
          <el-card class="dish-card" shadow="hover">
            <div class="dish-image">
              <el-image
                :src="dish.image"
                fit="cover"
                :alt="dish.name"
                @click="showDishDetail(dish)"
              >
                <template #error>
                  <div class="image-error">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
              <div v-if="isPromotionActive(dish)" class="promotion-badge">
                {{ getPromotionLabel(dish) }}
              </div>
            </div>

            <div class="dish-info">
              <h4 class="dish-name" @click="showDishDetail(dish)">
                {{ dish.name }}
              </h4>

              <div class="dish-price">
                <span class="current-price">¥{{ dish.price }}</span>
                <span
                  v-if="dish.isPromotion && dish.originalPrice !== dish.price"
                  class="original-price"
                  >¥{{ dish.originalPrice }}</span
                >
                <span
                  v-if="dish.isPromotion && dish.discount"
                  class="discount-info"
                  >{{ dish.discount }}折</span
                >
              </div>

              <div class="dish-rating">
                <el-rate
                  v-model="dish.rating"
                  disabled
                  show-score
                  text-color="#ff9900"
                  :precision="0.1"
                />
                <span class="sales-count">已售 {{ dish.salesCount }}</span>
              </div>

              <div class="dish-tags">
                <el-tag
                  v-for="tag in dish.tags"
                  :key="tag"
                  size="small"
                  type="info"
                >
                  {{ tag }}
                </el-tag>
              </div>

              <div class="dish-actions">
                <el-button
                  type="primary"
                  size="small"
                  :disabled="!dish.available"
                  @click="addToCart(dish)"
                >
                  {{ dish.available ? "加入购物车" : "已售罄" }}
                </el-button>
                <el-button size="small" @click="showDishDetail(dish)">
                  查看详情
                </el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[12, 24, 36, 48]"
          layout="total, sizes, prev, pager, next, jumper"
          @update:page-size="handleSizeChange"
          @update:current-page="handleCurrentChange"
        />
      </div>
    </div>

    <!-- 菜品详情对话框 -->
    <el-dialog v-model="detailVisible" :title="currentDish?.name" width="700px">
      <el-tabs type="border-card">
        <el-tab-pane label="菜品详情">
          <div v-if="currentDish" class="dish-detail">
            <el-image
              :src="currentDish.image"
              fit="cover"
              class="detail-image"
            />
            <div class="detail-info">
              <p><strong>价格：</strong>¥{{ currentDish.price }}</p>
              <p>
                <strong>分类：</strong
                >{{ getCategoryText(currentDish.dishCategory) }}
              </p>
              <p>
                <strong>食堂：</strong
                >{{ currentDish.canteenName || "未知食堂" }}
              </p>
              <p><strong>窗口：</strong>{{ currentDish.windowName }}</p>
              <p><strong>描述：</strong>{{ currentDish.description }}</p>
              <div class="nutrition-box">
                <p><strong>营养信息：</strong></p>
                <el-row :gutter="20">
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">热量</span>
                      <span class="value"
                        >{{ currentDish.calories || "--" }} kcal</span
                      >
                    </div>
                  </el-col>
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">蛋白质</span>
                      <span class="value"
                        >{{ currentDish.protein || "--" }} g</span
                      >
                    </div>
                  </el-col>
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">脂肪</span>
                      <span class="value">{{ currentDish.fat || "--" }} g</span>
                    </div>
                  </el-col>
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">碳水</span>
                      <span class="value">{{ currentDish.carbohydrate || "--" }} g</span>
                    </div>
                  </el-col>
                </el-row>
              </div>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="用户评价">
          <div v-loading="reviewsLoading" class="reviews-container">
            <div v-if="reviews.length === 0" class="no-reviews">暂无评价</div>
            <div v-else class="reviews-list">
              <div
                v-for="review in reviews"
                :key="review.id"
                class="review-item"
              >
                <div class="review-header">
                  <div class="user-info">
                    <el-avatar :size="30" :src="toImageUrl(review.user?.avatar)" :icon="UserFilled" />
                    <span class="username">{{
                      review.user?.username || "匿名用户"
                    }}</span>
                  </div>
                  <span class="time">{{ formatTime(review.createTime) }}</span>
                </div>

                <div class="rating-row">
                  <el-rate
                    v-model="review.overallRating"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template="{value}"
                  />
                  <div
                    v-if="review.quickTags && review.quickTags.length"
                    class="tags-container"
                  >
                    <el-tag
                      v-for="tag in review.quickTags"
                      :key="tag"
                      size="small"
                      type="info"
                      effect="plain"
                      >{{ tag }}</el-tag
                    >
                  </div>
                </div>

                <div class="review-content">{{ review.comment }}</div>

                <!-- 评价图片 -->
                <div
                  v-if="review.imageUrls && review.imageUrls.length"
                  class="review-images"
                >
                  <el-image
                    v-for="(url, idx) in review.imageUrls"
                    :key="idx"
                    :src="toImageUrl(url)"
                    :preview-src-list="toImageUrlList(review.imageUrls)"
                    fit="cover"
                    class="review-img"
                  />
                </div>

                <!-- 商家回复区域 -->
                <div v-if="review.canteenReply" class="merchant-reply">
                  <div class="reply-header">
                    <span class="reply-title">商家回复</span>
                    <span class="reply-time">{{
                      formatTime(review.replyTime)
                    }}</span>
                  </div>
                  <div class="reply-content">{{ review.canteenReply }}</div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>

      <template #footer>
        <el-button @click="detailVisible = false">取消</el-button>
        <el-button
          type="primary"
          :disabled="!currentDish?.available"
          @click="addToCart(currentDish)"
        >
          加入购物车
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, watch } from "vue";
import { ElMessage } from "element-plus";
import { Search, Picture, UserFilled } from "@element-plus/icons-vue";
import { dishApi } from "@/api/dish";
import { orderApi } from "@/api/order";
import { reviewApi } from "@/api/review";
import { windowApi } from "@/api/window";
import api from "@/api/index";

const loading = ref(false);
const dishes = ref([]);
const currentPage = ref(1);
const pageSize = ref(12);
const total = ref(0);

// 评价相关
const reviews = ref([]);
const reviewsLoading = ref(false);

// 时间格式化
const formatTime = (timeStr) => {
  if (!timeStr) return "";
  const date = new Date(timeStr);
  return date.toLocaleString();
};

const toImageUrl = (url) => {
  if (!url) return "";
  if (typeof url !== "string") return String(url);
  if (url.startsWith("http://") || url.startsWith("https://")) return url;
  if (url.startsWith("/")) return url;
  const base = api?.defaults?.baseURL || "";
  return `${base}/uploads/${url}`;
};

const toImageUrlList = (urls) => {
  if (!Array.isArray(urls)) return [];
  return urls.map(toImageUrl).filter(Boolean);
};

// 筛选条件
const searchKeyword = ref("");
const filterCanteen = ref("");
const filterWindow = ref("");
const filterCategory = ref("");
const filterSubCategory = ref("");
const filterTag = ref("");
const sortBy = ref("default");

// 分类和标签选项
const categories = ref([
  { label: "主食", value: "MAIN_DISH" },
  { label: "荤菜", value: "MEAT_DISH" },
  { label: "素菜", value: "VEGETABLE" },
  { label: "汤类", value: "SOUP" },
  { label: "小吃", value: "SNACK" },
  { label: "饮品", value: "BEVERAGE" },
]);
const tasteTags = ref(["酸", "甜", "辣", "咸", "清淡", "重口"]);

// 食堂和窗口选项
const canteens = ref([]);
const windows = ref([]);

// 详情对话框
const detailVisible = ref(false);
const currentDish = ref(null);

// 根据分类获取默认图片路径
const getDefaultImageByCategory = (category) => {
  const categoryMap = {
    主食: "/dishes/main_dish.svg",
    荤菜: "/dishes/meat_dish.svg",
    素菜: "/dishes/vegetable_dish.svg",
    汤类: "/dishes/soup_dish.svg",
    小吃: "/dishes/snack_dish.svg",
    饮品: "/dishes/drink_dish.svg",
    菜品: "/dishes/meat_dish.svg", // 默认菜品使用荤菜图标
  };
  return categoryMap[category] || "/dishes/main_dish.svg";
};

// 获取分类文本
const getCategoryText = (category) => {
  const texts = {
    main: "主食",
    meat: "荤菜",
    vegetable: "素菜",
    soup: "汤类",
    snack: "小吃",
    drink: "饮品",
    MAIN_DISH: "主食",
    MEAT_DISH: "荤菜",
    VEGETABLE: "素菜",
    SIDE_DISH: "菜品",
    SOUP: "汤类",
    SNACK: "小吃",
    BEVERAGE: "饮品",
  };

  // 如果category是字符串，尝试解析JSON
  if (typeof category === "string") {
    // 检查是否是JSON字符串（以[或{开头）
    if (
      (category.startsWith("[") && category.endsWith("]")) ||
      (category.startsWith("{") && category.endsWith("}"))
    ) {
      try {
        const categoryObj = JSON.parse(category);
        // 如果是数组，取第一个元素的name
        if (
          Array.isArray(categoryObj) &&
          categoryObj.length > 0 &&
          categoryObj[0].name
        ) {
          return categoryObj[0].name;
        }
        // 如果是对象，直接取name
        else if (typeof categoryObj === "object" && categoryObj.name) {
          return categoryObj.name;
        }
      } catch (e) {
        // 解析失败，使用原始字符串
        console.warn("解析分类JSON失败:", e);
      }
    }
  }

  // 如果是对象，直接取name
  if (typeof category === "object" && category !== null) {
    return category.name || JSON.stringify(category);
  }

  // 否则按原来的方式处理
  return texts[category] || category;
};

// 获取标签文本
const getTagText = (tag) => {
  const tags = {
    spicy: "辣",
    sweet: "甜",
    sour: "酸",
    salty: "咸",
    light: "清淡",
    strong: "重口",
    麻辣: "重口",
    香辣: "重口",
    酸甜: "酸甜",
  };
  return tags[tag] || tag;
};

// 检查促销是否在有效期内
const isPromotionActive = (dish) => {
  if (!dish.isPromotion) return false;

  // 检查促销状态（如果提供了状态字段）
  if (dish.promotionStatus) {
    // 只有active状态的促销才显示标签
    if (dish.promotionStatus !== 'active') return false;
  }

  // 如果没有设置时间范围，则认为促销有效
  if (!dish.promotionStart && !dish.promotionEnd) return true;

  const now = new Date();
  const start = dish.promotionStart ? new Date(dish.promotionStart) : null;
  const end = dish.promotionEnd ? new Date(dish.promotionEnd) : null;

  // 检查是否在有效期内
  if (start && now < start) return false;
  if (end && now > end) return false;

  return true;
};

// 根据促销类型获取标签文字
const getPromotionLabel = (dish) => {
  const type = dish.promotionType;
  switch (type) {
    case 'discount':
      return '折扣';
    case 'special':
      return '特价';
    case 'gift':
      return '买赠';
    case 'full_reduction':
      return '满减';
    case 'combo':
      return '套餐';
    case 'time_limit':
      return '限时';
    default:
      return '促销';
  }
};

// 监听食堂变化，更新窗口列表
watch(filterCanteen, (newValue) => {
  filterWindow.value = ""; // 清空窗口选择
  loadWindows(); // 根据选择的食堂重新加载窗口
});

// 定时刷新间隔（毫秒）
const REFRESH_INTERVAL = 30000; // 30秒
let refreshTimer = null;

// 定时刷新函数
const startAutoRefresh = () => {
  // 清除已有的定时器
  if (refreshTimer) {
    clearInterval(refreshTimer);
  }

  // 设置新的定时器
  refreshTimer = setInterval(() => {
    console.log("自动刷新菜品数据...");
    loadDishes();
  }, REFRESH_INTERVAL);
};

// 停止自动刷新
const stopAutoRefresh = () => {
  if (refreshTimer) {
    clearInterval(refreshTimer);
    refreshTimer = null;
  }
};

// 加载菜品列表
const loadDishes = async () => {
  console.log("===== 开始加载菜品数据 =====");
  try {
    loading.value = true;

    // 构建请求参数 - 只包含后端支持的参数
    const params = {
      page: currentPage.value - 1,
      size: pageSize.value,
    };
    const canteenId =
      filterCanteen.value === "" ? null : Number(filterCanteen.value);
    const windowId =
      filterWindow.value === "" ? null : Number(filterWindow.value);
    if (canteenId !== null && !Number.isNaN(canteenId))
      params.canteenId = canteenId;
    if (windowId !== null && !Number.isNaN(windowId))
      params.windowId = windowId;
    if (filterCategory.value) params.category = filterCategory.value;
    if (filterTag.value) params.tag = filterTag.value;

    let response;
    let responseData = [];
    let totalCount = 0;
    let serverPaged = false;

    // 根据不同条件调用不同的API接口
    if (searchKeyword.value) {
      console.log("调用API: dishApi.searchDishes()");
      console.log("搜索请求参数:", params);
      response = await dishApi.searchDishes(searchKeyword.value, params);
    } else {
      console.log("调用API: dishApi.getDishes() - 获取所有菜品");
      console.log("最终请求参数:", params);
      response = await dishApi.getDishes(params); // 传递所有筛选参数
    }

    console.log("API响应:", response);

    // 检查响应是否包含data属性
    if (response && typeof response === "object") {
      const payload = response.data ?? response;
      if (payload && payload.data && payload.data.totalElements !== undefined) {
        totalCount = payload.data.totalElements;
        responseData = payload.data.content || [];
        serverPaged = true;
        console.log("获取到分页数据，总计", totalCount, "条");
      } else if (payload && payload.totalElements !== undefined) {
        totalCount = payload.totalElements;
        responseData = payload.content || [];
        serverPaged = true;
        console.log("获取到分页数据，总计", totalCount, "条");
      } else if (Array.isArray(payload)) {
        responseData = payload;
        totalCount = responseData.length;
        console.log("直接使用数组数据，共", totalCount, "条");
      } else if (payload && Array.isArray(payload.data)) {
        responseData = payload.data;
        totalCount = responseData.length;
        console.log("直接使用response.data数组，共", totalCount, "条");
      } else if (
        payload &&
        payload.data &&
        (payload.data.items || payload.data.records)
      ) {
        responseData = payload.data.items || payload.data.records;
        totalCount = payload.data.total || responseData.length;
        console.log("检测到嵌套的data结构");
      }
    }

    // 从菜品数据中提取食堂和窗口信息
    // extractCanteensAndWindows(responseData); // 不再从当前页数据提取，改为独立加载

    // 格式化菜品数据，确保与管理端格式一致
    let formattedDishes = responseData.map((dish) => {
      // 处理状态字段的不同表示
      let isAvailable = true;
      if (dish.status !== undefined) {
        isAvailable =
          dish.status === "AVAILABLE" ||
          dish.status === "available" ||
          dish.status === "active" ||
          dish.status === true;
      } else if (dish.available !== undefined) {
        isAvailable = Boolean(dish.available);
      }

      // 处理价格字段
      const originalPrice = Number(dish.price) || 0;

      // 检查是否有促销信息，直接从dish对象获取促销字段
      // 确保isPromotion字段的处理正确，即使它为null
      const isPromotion = dish.isPromotion === true;
      // 确保promotionPrice字段的处理正确，即使它为null
      const promotionPrice =
        isPromotion && dish.promotionPrice
          ? Number(dish.promotionPrice)
          : originalPrice;

      // 计算折扣（保留一位小数）
      const discount =
        isPromotion && promotionPrice < originalPrice
          ? ((promotionPrice / originalPrice) * 10).toFixed(1)
          : null;

      // 处理评分字段 - 确保评分在合理范围内
      let rating = Number(dish.rating) || Number(dish.averageRating) || 0;
      // 如果没有评分数据且有一定销量，可以设置一个默认评分
      if (
        rating === 0 &&
        (Number(dish.sales) || Number(dish.salesCount) || 0) > 0
      ) {
        rating = 4.0; // 设置一个默认好评分数
      }
      // 限制评分范围在0-5之间
      rating = Math.max(0, Math.min(5, rating));
      // 处理分类字段
      const categoryText = dish.dishCategory || "未知分类";

      // 处理窗口名称 - 尝试从不同字段获取
      let windowName = "未知窗口";
      if (dish.windowName) {
        windowName = dish.windowName;
      } else if (dish.window && typeof dish.window === "object") {
        windowName = dish.window.name || "未知窗口";
      }

      return {
        ...dish,
        id: dish.id || dish.dishId,
        name: dish.name || "未命名菜品",
        price: promotionPrice, // 显示促销价格
        originalPrice: originalPrice, // 显示原价
        promotionPrice: promotionPrice,
        discount: discount, // 添加折扣信息
        category: categoryText,
        image:
          dish.image ||
          dish.imageUrl ||
          getDefaultImageByCategory(categoryText),
        // 正确处理后端返回的tasteTags字段
        tags: Array.isArray(dish.tasteTags)
          ? dish.tasteTags.map((tag) => getTagText(tag))
          : [],
        salesCount: Number(dish.sales) || Number(dish.salesCount) || 0,
        rating: rating,
        available: isAvailable,
        isPromotion: isPromotion,
        canteenName: dish.canteenName || "未知食堂",
        windowName: windowName, // 使用从不同字段获取的窗口名称
        windowLocation: dish.windowLocation || "未知位置",
        description: dish.description || "",
        nutritionInfo: dish.nutrition || dish.nutritionInfo || "", // 兼容不同的营养信息字段名
        calories: dish.calories,
        protein: dish.protein,
        fat: dish.fat,
        carbohydrate: dish.carbohydrate,
        stock: Number(dish.stock) || 0,
        categoryId: dish.categoryId || dish.dishCategory,
        // 保存原始分类和标签用于筛选
        originalCategory: dish.dishCategory || "",
        originalTags: Array.isArray(dish.tasteTags)
          ? dish.tasteTags
          : dish.tasteTags?.split(",") || [],
      };
    });

    // 确保formattedDishes是数组
    if (!Array.isArray(formattedDishes)) {
      formattedDishes = [];
      totalCount = 0;
      console.error("格式化后的数据不是数组:", formattedDishes);
    }

    // 如果有口味标签筛选，在前端进行筛选
    if (!serverPaged && filterTag.value) {
      console.log(`前端口味标签筛选：${filterTag.value}`);
      formattedDishes = formattedDishes.filter((dish) => {
        return dish.originalTags.some((tag) => {
          const tagMatch =
            tag.includes(filterTag.value) ||
            getTagText(tag) === filterTag.value;
          console.log(`菜品${dish.name} - 标签${tag}是否匹配: ${tagMatch}`);
          return tagMatch;
        });
      });
      totalCount = formattedDishes.length;
      console.log(`前端口味标签筛选后，剩余${totalCount}条菜品`);
    }

    if (sortBy.value !== "default" && formattedDishes.length > 0) {
      console.log("执行前端排序:", sortBy.value);
      switch (sortBy.value) {
        case "price_asc":
          formattedDishes.sort((a, b) => a.price - b.price);
          break;
        case "price_desc":
          formattedDishes.sort((a, b) => b.price - a.price);
          break;
        case "rating_desc":
          formattedDishes.sort((a, b) => b.rating - a.rating);
          break;
        case "sales_desc":
          formattedDishes.sort((a, b) => b.salesCount - a.salesCount);
          break;
      }
    }

    if (!serverPaged) {
      totalCount = formattedDishes.length;
    }
    total.value = totalCount;
    if (totalCount === 0) {
      currentPage.value = 1;
      dishes.value = [];
    } else {
      if (!serverPaged) {
        const totalPages = Math.ceil(totalCount / pageSize.value);
        if (currentPage.value > totalPages) currentPage.value = totalPages;
        const start = (currentPage.value - 1) * pageSize.value;
        const end = start + pageSize.value;
        dishes.value = formattedDishes.slice(start, end);
      } else {
        dishes.value = formattedDishes;
      }
    }

    console.log(
      "加载完成，共",
      dishes.value.length,
      "条菜品，总计",
      total.value,
      "条",
    );
  } catch (error) {
    console.error("加载菜品失败:", error);

    // 详细的错误信息处理
    let errorMessage = "加载菜品失败，请稍后重试";
    if (error.response) {
      // 服务器返回错误
      errorMessage =
        error.response.data?.message ||
        error.response.data?.error ||
        `服务器错误 (${error.response.status})`;
      console.error("API错误响应:", error.response.data);
    } else if (error.request) {
      // 请求发送失败
      errorMessage = "网络连接失败，请检查网络";
      console.error("网络请求失败:", error.request);
    }

    ElMessage.error(errorMessage);

    // 重置数据以确保界面一致性
    dishes.value = [];
    total.value = 0;
  } finally {
    loading.value = false;
    console.log("===== 菜品数据加载结束 =====");
  }
};

// 加载所有食堂
const loadCanteens = async () => {
  try {
    const res = await windowApi.getCanteens();
    // 兼容不同的数据返回格式
    if (res.data && Array.isArray(res.data)) {
      canteens.value = res.data;
    } else if (Array.isArray(res)) {
      canteens.value = res;
    } else if (res.data && res.data.data) {
      canteens.value = res.data.data;
    }
  } catch (error) {
    console.error("加载食堂列表失败:", error);
  }
};

// 加载窗口
const loadWindows = async () => {
  try {
    let res;
    if (filterCanteen.value) {
      res = await windowApi.getWindowsByCanteenId(filterCanteen.value);
    } else {
      res = await windowApi.getAllWindows();
    }
    
    // 兼容不同的数据返回格式
    if (res.data && Array.isArray(res.data)) {
      windows.value = res.data;
    } else if (Array.isArray(res)) {
      windows.value = res;
    } else if (res.data && res.data.data) {
      windows.value = res.data.data;
    }
  } catch (error) {
    console.error("加载窗口列表失败:", error);
  }
};

const getWindowOptionLabel = (w) => {
  if (!w) return "";
  const canteenName = (w.canteenName || "").trim();
  const location = (w.location || "").trim();
  const name = (w.name || "").trim();
  if (!name) return "";

  const suffix = name.includes("窗口") ? name : `${name}窗口`;
  return `${canteenName}${location}${suffix}`.trim();
};

// 搜索处理
const handleSearch = () => {
  currentPage.value = 1;
  loadDishes();
};

// 重置筛选条件
const resetFilters = () => {
  searchKeyword.value = "";
  filterCanteen.value = "";
  filterWindow.value = "";
  filterCategory.value = "";
  filterSubCategory.value = "";
  filterTag.value = "";
  sortBy.value = "default";
  currentPage.value = 1;
  loadDishes();
};

// 分页处理
const handleSizeChange = (size) => {
  pageSize.value = size;
  currentPage.value = 1;
  loadDishes();
};

const handleCurrentChange = (page) => {
  currentPage.value = page;
  loadDishes();
};

// 加载菜品评价
const loadDishReviews = async (dishId) => {
  try {
    reviewsLoading.value = true;
    const res = await reviewApi.getDishReviews(dishId);
    // 兼容不同的数据返回格式
    if (res.data && Array.isArray(res.data.data)) {
      reviews.value = res.data.data;
    } else if (Array.isArray(res.data)) {
      reviews.value = res.data;
    } else {
      reviews.value = [];
    }
  } catch (error) {
    console.error("加载评价失败:", error);
    ElMessage.error("加载评价失败");
  } finally {
    reviewsLoading.value = false;
  }
};

// 显示菜品详情
const showDishDetail = (dish) => {
  currentDish.value = dish;
  detailVisible.value = true;
  loadDishReviews(dish.id);
};

// 添加到购物车
const addToCart = async (dish) => {
  if (!dish.available) {
    ElMessage.warning("该菜品已售罄");
    return;
  }

  try {
    await orderApi.addToCart({ dishId: dish.id, quantity: 1 });

    const res = await orderApi.getCart();
    const serverCart = res?.data?.data ?? res?.data;
    const localRaw = (() => {
      try {
        return JSON.parse(localStorage.getItem("cart") || "[]");
      } catch {
        return [];
      }
    })();
    const comboItems = (Array.isArray(localRaw) ? localRaw : []).filter(
      (i) => i && i.type === "COMBO",
    );
    const merged = [
      ...comboItems,
      ...(Array.isArray(serverCart) ? serverCart : []),
    ];
    localStorage.setItem("cart", JSON.stringify(merged));
    window.dispatchEvent(new Event("storage"));
    ElMessage.success("已添加到购物车");
  } catch (error) {
    console.error("添加到购物车失败:", error);
    ElMessage.error("添加失败");
  }
};

onMounted(async () => {
  loadCanteens();
  loadWindows();
  loadDishes();
  // 启动自动刷新
  startAutoRefresh();
});

// 组件卸载时
onUnmounted(() => {
  // 停止自动刷新
  stopAutoRefresh();
});
</script>

<style scoped>
.dishes-container {
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

.filter-card {
  margin-bottom: 30px;
}

/* 按钮组样式 */
.button-group {
  display: flex;
  gap: 10px;
  justify-content: flex-start;
  align-items: center;
}

/* 搜索按钮样式 */
.search-btn {
  background-color: #409eff;
  border-color: #409eff;
  border-radius: 6px;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.search-btn:hover {
  background-color: #66b1ff;
  border-color: #66b1ff;
  box-shadow: 0 4px 8px rgba(64, 158, 255, 0.3);
  transform: translateY(-1px);
}

.search-btn:active {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(64, 158, 255, 0.2);
}

/* 重置按钮样式 */
.reset-btn {
  background-color: #ffffff;
  border-color: #dcdfe6;
  color: #606266;
  border-radius: 6px;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.reset-btn:hover {
  background-color: #f5f7fa;
  border-color: #c6e2ff;
  color: #409eff;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
  transform: translateY(-1px);
}

.reset-btn:active {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.dish-col {
  margin-bottom: 20px;
}

.dish-card {
  transition: transform 0.3s;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.dish-card:hover {
  transform: translateY(-2px);
}

.dish-image {
  position: relative;
  height: var(--dish-image-size);
  overflow: hidden;
  flex-shrink: 0;
}

.dish-image .el-image {
  width: 100%;
  height: 100%;
}

.image-error {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f5f5;
  color: #ccc;
}

.promotion-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #f56c6c;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.dish-info {
  padding: 15px;
  display: flex;
  flex-direction: column;
  flex: 1;
}

.dish-name {
  margin: 0 0 10px;
  font-size: 16px;
  color: #333;
  cursor: pointer;
  transition: color 0.3s;
  /* 限制为最多2行 */
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  height: 44px; /* 固定高度，约2行 */
}

.dish-name:hover {
  color: #409eff;
}

.dish-price {
  margin-bottom: 10px;
}

.current-price {
  font-size: 18px;
  color: #f56c6c;
  font-weight: bold;
  margin-right: 10px;
}

.original-price {
  font-size: 14px;
  color: #999;
  text-decoration: line-through;
}

.discount-info {
  font-size: 14px;
  color: #f56c6c;
  font-weight: bold;
  margin-left: 8px;
  background-color: rgba(245, 108, 108, 0.1);
  padding: 2px 6px;
  border-radius: 4px;
}

.dish-rating {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.sales-count {
  font-size: 12px;
  color: #999;
}

.dish-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-bottom: 15px;
  height: 24px; /* 固定高度，只显示一行或超出隐藏 */
  overflow: hidden;
}

.dish-actions {
  display: flex;
  gap: 10px;
  margin-top: auto; /* 将按钮推到底部 */
}

.pagination {
  margin-top: 30px;
  text-align: center;
}

.dish-detail {
  display: flex;
  gap: 20px;
}

.detail-image {
  width: var(--dish-image-size);
  height: var(--dish-image-size);
  border-radius: 8px;
  flex-shrink: 0;
}

.detail-info {
  flex: 1;
}

.detail-info p {
  margin-bottom: 10px;
  line-height: 1.6;
}

.nutrition-box {
  background-color: #f5f7fa;
  border-radius: 4px;
  padding: 10px;
  margin-top: 15px;
}

.nutrition-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: #fff;
  padding: 8px;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.nutrition-item .label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.nutrition-item .value {
  font-weight: bold;
  color: #409eff;
}

/* 评价列表样式 */
.reviews-container {
  min-height: 200px;
  max-height: 400px;
  overflow-y: auto;
}

.no-reviews {
  text-align: center;
  color: #999;
  padding: 40px 0;
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

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.username {
  font-weight: 500;
  color: #333;
}

.time {
  font-size: 12px;
  color: #999;
}

.rating-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
}

.review-content {
  font-size: 14px;
  color: #666;
  line-height: 1.5;
  margin-bottom: 10px;
}

.review-images {
  display: flex;
  gap: 8px;
  margin-bottom: 10px;
  flex-wrap: wrap;
}

.review-img {
  width: 80px;
  height: 80px;
  border-radius: 4px;
  cursor: pointer;
}

/* 商家回复样式 */
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
