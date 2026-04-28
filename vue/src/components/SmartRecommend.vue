<template>
  <div class="smart-recommend-container">
    <div class="section-header">
      <h2 class="section-title">情景智能推荐</h2>
      <p class="section-subtitle">根据时间、天气和季节智能推荐</p>
    </div>
    <el-card class="context-card" shadow="hover">
      <div class="context-header">
        <div class="context-item">
          <el-icon :size="24" class="icon"><Timer /></el-icon>
          <span class="label">{{ timeContext.period }}</span>
          <span class="sub-label">{{ timeContext.greeting }}</span>
        </div>
        <div class="divider"></div>
        <div class="context-item">
          <el-icon :size="24" class="icon">
            <component :is="weatherContext.icon" />
          </el-icon>
          <span class="label"
            >{{ weatherContext.city }} {{ weatherContext.condition }}</span
          >
          <span class="sub-label">
            {{ Math.round(weatherContext.temperature) }}°C
            <span v-if="weatherContext.minTemp !== null"
              >({{ Math.round(weatherContext.minTemp) }}~{{
                Math.round(weatherContext.maxTemp)
              }}°C)</span
            >
          </span>
        </div>
        <div class="divider"></div>
        <div class="context-item">
          <el-icon :size="24" class="icon"><Sunny /></el-icon>
          <!-- 季节图标 -->
          <span class="label">{{ seasonContext.season }}</span>
          <span class="sub-label">{{ seasonContext.desc }}</span>
        </div>
        <el-button
          class="refresh-btn"
          circle
          :icon="Refresh"
          :loading="loading"
          @click="fetchRecommendations"
        />
      </div>

      <div v-loading="loading" class="recommend-content">
        <div v-if="dishes.length === 0" class="empty-state">
          暂无智能推荐，请稍后再试
        </div>
        <el-row v-else :gutter="15">
          <el-col
            v-for="dish in dishes"
            :key="dish.id"
            :xs="24"
            :sm="12"
            :md="6"
            :lg="6"
          >
            <el-card
              class="recommend-dish-card"
              :body-style="{ padding: '0px' }"
              shadow="hover"
              @click="showDetail(dish)"
            >
              <div class="dish-img-wrapper">
                <el-image :src="dish.image" fit="cover" class="dish-img">
                  <template #error>
                    <div class="image-placeholder">
                      <el-icon><Food /></el-icon>
                    </div>
                  </template>
                </el-image>
                <div class="recommend-reason-tag">
                  {{ getRecommendReason(dish) }}
                </div>
              </div>
              <div class="dish-info">
                <h4 class="dish-name">{{ dish.name }}</h4>
                <div class="dish-meta">
                  <span class="price">¥{{ dish.price }}</span>
                  <span v-if="dish.calories" class="calories"
                    >{{ dish.calories }} kcal</span
                  >
                </div>
                <div class="dish-actions">
                  <el-button
                    type="primary"
                    size="small"
                    :disabled="!dish.available"
                    @click.stop="addToCart(dish)"
                  >
                    {{ dish.available ? "加入购物车" : "已售罄" }}
                  </el-button>
                  <el-button size="small" @click.stop="showDetail(dish)">
                    查看详情
                  </el-button>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import {
  Timer,
  Sunny,
  Cloudy,
  Lightning,
  Pouring,
  Refresh,
  Food,
} from "@element-plus/icons-vue";
import recommendationApi from "@/api/recommendation";
import api from "@/api";
import { ElMessage } from "element-plus";

const loading = ref(false);
const dishes = ref([]);
const emit = defineEmits(["show-detail", "add-to-cart"]);

// --- 1. 时间维度 ---
const timeContext = reactive({
  period: "用餐时间",
  greeting: "美好的一天",
});

const updateTimeContext = () => {
  const hour = new Date().getHours();
  if (hour >= 6 && hour < 10) {
    timeContext.period = "早餐时段";
    timeContext.greeting = "元气满满的开始";
  } else if (hour >= 10 && hour < 14) {
    timeContext.period = "午餐时段";
    timeContext.greeting = "补充能量时刻";
  } else if (hour >= 14 && hour < 17) {
    timeContext.period = "下午茶";
    timeContext.greeting = "享受惬意时光";
  } else if (hour >= 17 && hour < 21) {
    timeContext.period = "晚餐时段";
    timeContext.greeting = "犒劳辛苦的自己";
  } else {
    timeContext.period = "夜宵时刻";
    timeContext.greeting = "深夜食堂营业中";
  }
};

// --- 2. 季节维度 ---
const seasonContext = reactive({
  season: "当季",
  desc: "应季美食",
});

const updateSeasonContext = () => {
  const month = new Date().getMonth() + 1; // 1-12
  if (month >= 3 && month <= 5) {
    seasonContext.season = "春季";
    seasonContext.desc = "万物复苏 尝鲜";
  } else if (month >= 6 && month <= 8) {
    seasonContext.season = "夏季";
    seasonContext.desc = "清热解暑 爽口";
  } else if (month >= 9 && month <= 11) {
    seasonContext.season = "秋季";
    seasonContext.desc = "滋补润燥 丰收";
  } else {
    seasonContext.season = "冬季";
    seasonContext.desc = "暖胃驱寒 滋补";
  }
};

// --- 3. 天气维度 ---
const weatherContext = reactive({
  condition: "晴",
  temperature: 25,
  minTemp: null,
  maxTemp: null,
  city: "定位中...",
  icon: "Sunny",
});

const fetchWeather = async () => {
  try {
    let lat = null;
    let lon = null;
    let cityName = "当前位置";

    // 1. 尝试 GPS 定位
    if (navigator.geolocation) {
      try {
        const position = await new Promise((resolve, reject) => {
          navigator.geolocation.getCurrentPosition(resolve, reject, {
            timeout: 3000,
            maximumAge: 600000,
          });
        });
        lat = position.coords.latitude;
        lon = position.coords.longitude;
        console.log("GPS定位成功:", lat, lon);
      } catch (err) {
        console.warn("GPS定位失败或超时:", err);
      }
    }

    // 2. 调用后端天气API (后端处理Open-Meteo调用与降级)
    const res = await api.get("/api/weather/current", {
      params: { lat, lon },
    });

    const w = res.data;
    if (w) {
      weatherContext.city = w.city || cityName;
      if (w.temperature !== undefined && w.temperature !== null)
        weatherContext.temperature = w.temperature;
      if (w.condition) weatherContext.condition = w.condition;
      weatherContext.icon = w.icon || "Sunny";
      weatherContext.maxTemp = w.maxTemp ?? null;
      weatherContext.minTemp = w.minTemp ?? null;
    }
  } catch (e) {
    console.warn("天气获取失败，使用默认值", e);
    weatherContext.city = "默认位置";
    weatherContext.condition = "晴";
    weatherContext.temperature = 26;
    weatherContext.minTemp = null;
    weatherContext.maxTemp = null;
    weatherContext.icon = "Sunny";
  }
};

// --- 辅助函数：格式化菜品数据 ---
// 获取分类文本
const getCategoryText = (category) => {
  const texts = {
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
    if (
      (category.startsWith("[") && category.endsWith("]")) ||
      (category.startsWith("{") && category.endsWith("}"))
    ) {
      try {
        const categoryObj = JSON.parse(category);
        if (
          Array.isArray(categoryObj) &&
          categoryObj.length > 0 &&
          categoryObj[0].name
        ) {
          return categoryObj[0].name;
        } else if (typeof categoryObj === "object" && categoryObj.name) {
          return categoryObj.name;
        }
      } catch (e) {}
    }
  }

  if (typeof category === "object" && category !== null) {
    return category.name || JSON.stringify(category);
  }

  return texts[category] || category;
};

// 根据分类获取默认图片路径
const getDefaultImageByCategory = (categoryText) => {
  const categoryMap = {
    主食: "/dishes/main_dish.svg",
    荤菜: "/dishes/meat_dish.svg",
    素菜: "/dishes/vegetable_dish.svg",
    汤类: "/dishes/soup_dish.svg",
    小吃: "/dishes/snack_dish.svg",
    饮品: "/dishes/drink_dish.svg",
    菜品: "/dishes/meat_dish.svg",
  };
  return categoryMap[categoryText] || "/dishes/main_dish.svg";
};

// 格式化菜品数据
const formatDishData = (responseData) => {
  return responseData.map((dish) => {
    // 处理状态字段
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

    // 处理价格
    const originalPrice = Number(dish.price) || 0;
    const isPromotion = Boolean(dish.isPromotion);
    const promotionPrice =
      isPromotion && dish.promotionPrice
        ? Number(dish.promotionPrice)
        : originalPrice;

    // 处理分类
    const categoryText = dish.dishCategory || "未知分类";
    const displayCategory = getCategoryText(categoryText);

    // 处理图片
    const imagePath =
      dish.image || dish.imageUrl || getDefaultImageByCategory(displayCategory);

    return {
      ...dish,
      id: dish.id || dish.dishId,
      name: dish.name || "未命名菜品",
      price: promotionPrice,
      originalPrice: originalPrice,
      isPromotion: isPromotion,
      promotionPrice: promotionPrice,
      category: displayCategory,
      originalCategory: dish.dishCategory, // 保留原始分类用于逻辑判断
      image: imagePath,
      available: isAvailable,
      calories: dish.calories,
      tasteTags: dish.tasteTags,
    };
  });
};

// --- 核心：获取推荐 ---
const fetchRecommendations = async () => {
  loading.value = true;
  try {
    // 调用后端上下文感知推荐策略
    const res = await recommendationApi.getRecommendationsByStrategy(
      "context",
      4,
    );
    if (res && (res.data || Array.isArray(res))) {
      const list = Array.isArray(res) ? res : res.data || [];
      dishes.value = formatDishData(list);
    }
  } catch (e) {
    ElMessage.error("智能推荐加载失败");
  } finally {
    loading.value = false;
  }
};

// 智能生成推荐理由
const getRecommendReason = (dish) => {
  // 简单规则匹配，模拟智能分析结果
  // 检查原始分类或格式化后的分类
  const cat = dish.originalCategory || dish.dishCategory;
  const displayCat = dish.category;

  if (
    weatherContext.temperature < 10 &&
    (cat === "SOUP" || displayCat === "汤类")
  )
    return "寒冬暖胃";
  if (
    weatherContext.temperature > 30 &&
    (cat === "BEVERAGE" || displayCat === "饮品")
  )
    return "酷暑解渴";
  if (
    timeContext.period.includes("早") &&
    (cat === "SNACK" || displayCat === "小吃")
  )
    return "元气早餐";
  if (
    timeContext.period.includes("晚") &&
    (cat === "MAIN_DISH" || displayCat === "主食")
  )
    return "丰盛晚餐";
  if (seasonContext.season === "夏季" && dish.tasteTags?.includes("凉"))
    return "夏日清凉";
  return "智能优选";
};

const showDetail = (dish) => {
  // 由于是子组件，需要emit事件给父组件处理详情展示
  // 或者如果Home.vue传了方法进来，可以直接调用
  // 这里简化处理，直接触发一个全局事件或使用emit
  emit("show-detail", dish);
};

const addToCart = (dish) => {
  emit("add-to-cart", dish);
};

onMounted(() => {
  updateTimeContext();
  updateSeasonContext();
  fetchWeather();
  fetchRecommendations();
});
</script>

<style scoped>
.smart-recommend-container {
  margin-bottom: 30px;
}

.section-header {
  text-align: center;
  margin-bottom: 20px;
}

.section-title {
  font-size: 24px;
  color: #333;
  margin-bottom: 10px;
  display: inline-block;
  padding-bottom: 10px;
  border-bottom: 2px solid #409EFF;
}

.section-subtitle {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.context-card {
  border-radius: 12px;
  background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);
}

.context-header {
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding-bottom: 20px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  margin-bottom: 20px;
}

.context-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  color: #606266;
}

.context-item .icon {
  color: #409eff;
  margin-bottom: 4px;
}

.context-item .label {
  font-weight: bold;
  font-size: 16px;
  color: #303133;
}

.context-item .sub-label {
  font-size: 12px;
  color: #909399;
}

.divider {
  width: 1px;
  height: 40px;
  background-color: #dcdfe6;
}

.refresh-btn {
  margin-left: 10px;
}

.recommend-content {
  min-height: 200px;
}

.recommend-dish-card {
  cursor: pointer;
  transition: all 0.3s;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 10px;
}

.recommend-dish-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.dish-img-wrapper {
  position: relative;
  height: var(--dish-image-size);
  overflow: hidden;
}

.dish-img {
  width: 100%;
  height: 100%;
  transition: transform 0.3s;
}

.recommend-dish-card:hover .dish-img {
  transform: scale(1.1);
}

.recommend-reason-tag {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
  backdrop-filter: blur(4px);
}

.dish-info {
  padding: 10px;
}

.dish-name {
  margin: 0;
  font-size: 15px;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.dish-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
  margin-bottom: 12px;
}

.dish-actions {
  display: flex;
  justify-content: space-between;
  gap: 8px;
}

.dish-actions .el-button {
  flex: 1;
}

.price {
  color: #f56c6c;
  font-weight: bold;
}

.calories {
  font-size: 12px;
  color: #909399;
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #f0f2f5;
  color: #c0c4cc;
}
</style>
