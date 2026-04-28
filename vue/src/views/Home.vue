<template>
  <div class="home-container">
    <div class="container">
      <NotificationBar />

      <!-- 数据看板：口味偏好与健康建议 -->
      <DataDashboard />

      <!-- 情景智能推荐 -->
      <SmartRecommend @show-detail="showDishDetail" @add-to-cart="addToCart" />

      <div class="recommendation-section section-health-goals">
        <div class="health-header">
          <h2 class="section-title">智能健康目标推荐</h2>
          <el-button
            size="small"
            type="primary"
            plain
            :loading="healthLoading"
            @click="refreshHealthRecommendations"
          >
            换一批
          </el-button>
        </div>

        <el-card class="health-panel" shadow="never">
          <div v-loading="healthLoading">
            <div v-if="healthGoals.length > 0" class="health-goals">
              <div class="health-goals-title">你的健康目标</div>
              <div class="health-goals-tags">
                <el-tag
                  v-for="g in healthGoals"
                  :key="g.code"
                  size="small"
                  type="success"
                  effect="plain"
                >
                  {{ g.title }}
                </el-tag>
              </div>
              <div class="health-goals-desc">
                <div v-for="g in healthGoals" :key="g.code + '_d'" class="health-goal-item">
                  <span class="goal-name">{{ g.title }}</span>
                  <span class="goal-desc">{{ g.description }}</span>
                </div>
              </div>
            </div>

            <el-row v-if="healthRecs.length > 0" :gutter="20" class="health-recs">
              <el-col
                v-for="dish in healthRecs"
                :key="dish.id"
                :span="6"
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
                    <div class="health-badges">
                      <span class="health-badge health-score">{{ dish.nutritionScore }}分</span>
                      <span class="health-badge health-fit">契合{{ dish.fitPercent }}%</span>
                    </div>
                  </div>
                  <div class="dish-info">
                    <h4 class="dish-name" @click="showDishDetail(dish)">{{ dish.name }}</h4>
                    <p class="dish-price">¥{{ dish.price }}</p>
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
                    <div class="health-nutrition">
                      <span>热量 {{ dish.calories ?? '-' }}kcal</span>
                      <span>蛋白 {{ dish.protein ?? '-' }}g</span>
                      <span>脂肪 {{ dish.fat ?? '-' }}g</span>
                      <span>碳水 {{ dish.carbohydrate ?? '-' }}g</span>
                    </div>
                    <div class="dish-actions">
                      <el-button
                        type="primary"
                        size="small"
                        :disabled="!dish.available"
                        @click="addToCart(dish)"
                      >
                        {{ dish.available ? '加入购物车' : '已售罄' }}
                      </el-button>
                      <el-button size="small" @click="showDishDetail(dish)">查看详情</el-button>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>

            <el-empty
              v-else
              description="暂无可用的健康推荐，稍后再试"
            />
          </div>
        </el-card>
      </div>

      <div class="recommendation-section section-today-new">
        <h2 class="section-title">今日上新推荐</h2>
        <el-row :gutter="20" v-loading="loading">
          <el-col 
            v-for="dish in newDishes" 
            :key="dish.id" 
            :span="6"
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
                <div class="new-badge">新品</div>
              </div>
              <div class="dish-info">
                <h4 class="dish-name" @click="showDishDetail(dish)">{{ dish.name }}</h4>
                <p class="dish-price">¥{{ dish.price }}</p>
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
                    {{ dish.available ? '加入购物车' : '已售罄' }}
                  </el-button>
                  <el-button 
                    size="small"
                    @click="showDishDetail(dish)"
                  >
                    查看详情
                  </el-button>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <div class="recommendation-section section-you-may-like">
        <div class="section-header">
          <h2 class="section-title">猜你喜欢</h2>
          <p class="section-subtitle">根据你的历史行为智能推荐</p>
        </div>
        <div class="youmaylike-scroll" v-loading="loading">
          <div class="youmaylike-inner">
            <div 
              class="youmaylike-item"
              v-for="dish in personalizedDishes"
              :key="dish.id"
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
                  <div class="reason-badge">{{ dish.recommendReason || '根据你的历史行为推荐' }}</div>
                </div>
                <div class="dish-info">
                  <h4 class="dish-name" @click="showDishDetail(dish)">{{ dish.name }}</h4>
                  <p class="dish-price">¥{{ dish.price }}</p>
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
                      {{ dish.available ? '加入购物车' : '已售罄' }}
                    </el-button>
                    <el-button 
                      size="small"
                      @click="showDishDetail(dish)"
                    >
                      查看详情
                    </el-button>
                  </div>
                </div>
              </el-card>
            </div>
          </div>
        </div>
      </div>

      <div class="recommendation-section">
        <div class="section-header">
          <h2 class="section-title">今日个性化热门</h2>
          <p class="section-subtitle">优先展示符合你口味偏好的热门菜品</p>
        </div>
        <el-row :gutter="20" v-loading="loading">
          <el-col 
            v-for="dish in hotDishes" 
            :key="dish.id" 
            :span="6"
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
              </div>
              <div class="dish-info">
                <h4 class="dish-name" @click="showDishDetail(dish)">{{ dish.name }}</h4>
                <p class="dish-price">¥{{ dish.price }}</p>
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
                    {{ dish.available ? '加入购物车' : '已售罄' }}
                  </el-button>
                  <el-button 
                    size="small"
                    @click="showDishDetail(dish)"
                  >
                    查看详情
                  </el-button>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <div class="recommendation-section" v-if="promoCombos.length > 0 || discountDishes.length > 0">
        <h2 class="section-title">促销栏</h2>
        <el-tabs v-model="promotionTab">
          <el-tab-pane label="促销菜品" name="dish">
            <el-row v-if="discountDishes.length > 0" :gutter="20" v-loading="loading">
              <el-col 
                v-for="dish in discountDishes" 
                :key="dish.id" 
                :span="6"
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
                    <div class="discount-badge">{{ getPromotionLabel(dish) }}</div>
                  </div>
                  <div class="dish-info">
                    <h4 class="dish-name" @click="showDishDetail(dish)">{{ dish.name }}</h4>
                    <p class="dish-price">
                      <span class="current-price">¥{{ dish.promotionPrice || dish.price }}</span>
                      <span v-if="dish.promotionPrice" class="original-price">¥{{ dish.price }}</span>
                    </p>
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
                        {{ dish.available ? '加入购物车' : '已售罄' }}
                      </el-button>
                      <el-button 
                        size="small"
                        @click="showDishDetail(dish)"
                      >
                        查看详情
                      </el-button>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
            <el-empty v-else description="暂无促销菜品" />
          </el-tab-pane>
          <el-tab-pane label="套餐促销" name="combo">
            <el-row v-if="promoCombos.length > 0" :gutter="20" v-loading="loading">
              <el-col v-for="combo in promoCombos" :key="combo.id" :span="6">
                <el-card class="dish-card" shadow="hover" @click="showComboDetail(combo)">
                  <div class="dish-image">
                    <el-image
                      :src="combo.image"
                      fit="cover"
                      :alt="combo.name"
                    >
                      <template #error>
                        <div class="image-error">
                          <el-icon><Picture /></el-icon>
                        </div>
                      </template>
                    </el-image>
                    <div class="discount-badge">套餐</div>
                  </div>
                  <div class="dish-info">
                    <h4 class="dish-name">{{ combo.name }}</h4>
                    <p class="dish-price">
                      <span class="current-price">¥{{ combo.price }}</span>
                      <span v-if="combo.originalPrice" class="original-price">¥{{ combo.originalPrice }}</span>
                    </p>
                    <div class="dish-tags">
                      <el-tag v-if="combo.promotionName" size="small" type="info">
                        {{ combo.promotionName }}
                      </el-tag>
                      <el-tag v-for="n in combo.dishNames" :key="n" size="small" type="info">
                        {{ n }}
                      </el-tag>
                    </div>
                    <div class="dish-actions">
                      <el-button type="primary" size="small" @click.stop="addComboToCart(combo)">加入购物车</el-button>
                      <el-button size="small" @click.stop="showComboDetail(combo)">查看详情</el-button>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
            <el-empty v-else description="暂无套餐促销" />
          </el-tab-pane>
        </el-tabs>
      </div>
    </div>

    <!-- 菜品详情对话框 -->
    <el-dialog
      v-model="detailVisible"
      :title="currentDish?.name"
      width="700px"
    >
      <el-tabs type="border-card">
        <el-tab-pane label="菜品详情">
          <div v-if="currentDish" class="dish-detail">
            <el-image :src="currentDish.image" fit="cover" class="detail-image" />
            <div class="detail-info">
              <p><strong>价格：</strong>¥{{ currentDish.price }}</p>
              <p><strong>分类：</strong>{{ getCategoryText(currentDish.category) }}</p>
              <p><strong>食堂：</strong>{{ currentDish.canteenName || '未知食堂' }}</p>
              <p><strong>窗口：</strong>{{ currentDish.windowName || '未知窗口' }}</p>
              <p><strong>描述：</strong>{{ currentDish.description }}</p>
              <div class="nutrition-box">
                <p><strong>营养信息：</strong></p>
                <el-row :gutter="20">
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">热量</span>
                      <span class="value">{{ currentDish.calories || '--' }} kcal</span>
                    </div>
                  </el-col>
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">蛋白质</span>
                      <span class="value">{{ currentDish.protein || '--' }} g</span>
                    </div>
                  </el-col>
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">脂肪</span>
                      <span class="value">{{ currentDish.fat || '--' }} g</span>
                    </div>
                  </el-col>
                  <el-col :span="6">
                    <div class="nutrition-item">
                      <span class="label">碳水</span>
                      <span class="value">{{ currentDish.carbohydrate || '--' }} g</span>
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

    <el-dialog
      v-model="comboDetailVisible"
      :title="currentCombo?.name"
      width="800px"
    >
      <div v-if="currentCombo" class="dish-detail">
        <div class="detail-info">
          <p><strong>套餐价：</strong>¥{{ currentCombo.price }}</p>
          <p v-if="currentCombo.originalPrice"><strong>原价：</strong>¥{{ currentCombo.originalPrice }}</p>
          <p v-if="currentCombo.promotionName"><strong>活动：</strong>{{ currentCombo.promotionName }}</p>
          <p v-if="currentCombo.description"><strong>描述：</strong>{{ currentCombo.description }}</p>
          <p><strong>包含菜品：</strong></p>
          <el-row :gutter="20">
            <el-col v-for="dish in comboDishes" :key="dish.id" :span="24" style="margin-bottom: 12px;">
              <el-card shadow="never">
                <div style="display:flex; gap: 12px;">
                  <el-image :src="dish.image" fit="cover" class="combo-dish-image" />
                  <div style="flex:1;">
                    <div style="font-weight: 600; margin-bottom: 6px;">{{ dish.name }}</div>
                    <div class="combo-dish-meta">
                      <div class="combo-dish-row">
                        <span class="combo-dish-label">价格</span>
                        <span class="combo-dish-value">
                          ¥{{ dish.promotionPrice || dish.price }}
                          <span v-if="dish.originalPrice && dish.originalPrice !== (dish.promotionPrice || dish.price)" class="combo-dish-original">
                            ¥{{ dish.originalPrice }}
                          </span>
                        </span>
                      </div>
                      <div class="combo-dish-row">
                        <span class="combo-dish-label">分类</span>
                        <span class="combo-dish-value">{{ getCategoryText(dish.category) }}</span>
                      </div>
                      <div class="combo-dish-row">
                        <span class="combo-dish-label">窗口</span>
                        <span class="combo-dish-value">{{ dish.windowName || '未知窗口' }}</span>
                      </div>
                      <div class="combo-dish-row">
                        <span class="combo-dish-label">描述</span>
                        <span class="combo-dish-value combo-dish-desc">{{ dish.description || '暂无描述' }}</span>
                      </div>
                      <div class="combo-dish-row">
                        <span class="combo-dish-label">营养</span>
                        <span class="combo-dish-value">
                          {{ dish.calories ?? '--' }} kcal /
                          {{ dish.protein ?? '--' }} g /
                          {{ dish.fat ?? '--' }} g /
                          {{ dish.carbohydrate ?? '--' }} g
                        </span>
                      </div>
                    </div>
                    <div class="combo-actions">
                      <el-button type="primary" size="small" :disabled="!dish.available" @click="addToCart(dish)">
                        {{ dish.available ? '加入购物车' : '已售罄' }}
                      </el-button>
                      <el-button size="small" @click="showDishDetail(dish)">查看详情</el-button>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </div>
      <template #footer>
        <el-button @click="comboDetailVisible = false">关闭</el-button>
        <el-button type="primary" @click="addComboToCart(currentCombo)">加入购物车</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Food, Picture, Document, ShoppingCart, UserFilled
} from '@element-plus/icons-vue'
import { dishApi } from '@/api/dish'
import { orderApi } from '@/api/order'
import { reviewApi } from "@/api/review";
import api from "@/api/index";

import recommendationApi from '@/api/recommendation'
import { promotionsAPI, combosAPI } from '@/api/promotions'
import NotificationBar from '@/components/NotificationBar.vue'
import SmartRecommend from '@/components/SmartRecommend.vue'
import DataDashboard from '@/components/DataDashboard.vue'

const loading = ref(false)
const personalizedDishes = ref([])
const hotDishes = ref([])
const newDishes = ref([])
const discountDishes = ref([])
const promoCombos = ref([])
const promotionTab = ref('dish')
let midnightTimer = null

const healthLoading = ref(false)
const healthGoals = ref([])
const healthRecs = ref([])
let orderEventSource = null
let healthRefreshTimer = null
let personalizedRefreshTimer = null

// 详情对话框
const detailVisible = ref(false)
const currentDish = ref(null)
const comboDetailVisible = ref(false)
const currentCombo = ref(null)
const comboDishes = ref([])
const reviews = ref([])
const reviewsLoading = ref(false)

// 时间格式化
const formatTime = (timeStr) => {
  if (!timeStr) return "";
  const date = new Date(timeStr);
  return date.toLocaleString();
};

const toImageUrl = (url) => {
  if (!url) return "";
  if (typeof url !== "string") return String(url);
  const s = url.trim();
  if (s.startsWith("http://") || s.startsWith("https://")) return s;
  const base = (api?.defaults?.baseURL || "").replace(/\/$/, "");
  // 上传图片存为 /uploads/xxx，须走后端 baseURL，否则会变成当前前端域下的相对路径导致 404
  if (s.startsWith("/uploads/")) {
    return base ? `${base}${s}` : s;
  }
  if (s.startsWith("/")) return s;
  return base ? `${base}/uploads/${s}` : `/uploads/${s}`;
};

const toImageUrlList = (urls) => {
  if (!Array.isArray(urls)) return [];
  return urls.map(toImageUrl).filter(Boolean);
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

// 根据分类获取默认图片路径
const getDefaultImageByCategory = (category) => {
  const categoryMap = {
    '主食': '/dishes/main_dish.svg',
    '荤菜': '/dishes/meat_dish.svg',
    '素菜': '/dishes/vegetable_dish.svg',
    '汤类': '/dishes/soup_dish.svg',
    '小吃': '/dishes/snack_dish.svg',
    '饮品': '/dishes/drink_dish.svg',
    '菜品': '/dishes/meat_dish.svg' // 默认菜品使用荤菜图标
  }
  return categoryMap[category] || '/dishes/main_dish.svg'
}

// 获取分类文本
const getCategoryText = (category) => {
  const texts = {
    'main': '主食',
    'meat': '荤菜', 
    'vegetable': '素菜',
    'soup': '汤类',
    'snack': '小吃',
    'drink': '饮品',
    'MAIN_DISH': '主食',
    'MEAT_DISH': '荤菜',
    'VEGETABLE': '素菜',
    'SIDE_DISH': '菜品',
    'SOUP': '汤类',
    'SNACK': '小吃',
    'BEVERAGE': '饮品'
  }
  
  // 如果category是字符串，尝试解析JSON
  if (typeof category === 'string') {
    // 检查是否是JSON字符串（以[或{开头）
    if ((category.startsWith('[') && category.endsWith(']')) || (category.startsWith('{') && category.endsWith('}'))) {
      try {
        const categoryObj = JSON.parse(category);
        // 如果是数组，取第一个元素的name
        if (Array.isArray(categoryObj) && categoryObj.length > 0 && categoryObj[0].name) {
          return categoryObj[0].name;
        } 
        // 如果是对象，直接取name
        else if (typeof categoryObj === 'object' && categoryObj.name) {
          return categoryObj.name;
        }
      } catch (e) {
        // 解析失败，使用原始字符串
        console.warn('解析分类JSON失败:', e);
      }
    }
  }
  
  // 如果是对象，直接取name
  if (typeof category === 'object' && category !== null) {
    return category.name || JSON.stringify(category);
  }
  
  // 否则按原来的方式处理
  return texts[category] || category
}

// 获取标签文本
const getTagText = (tag) => {
  const tags = {
    'spicy': '辣',
    'sweet': '甜',
    'sour': '酸',
    'salty': '咸',
    'light': '清淡',
    'strong': '重口味',
    '麻辣': '麻辣',
    '香辣': '香辣',
    '酸甜': '酸甜'
  }
  return tags[tag] || tag
}

// 检查促销是否在有效期内
const isPromotionActive = (dish) => {
  if (!dish.isPromotion) return false

  // 检查促销状态（如果提供了状态字段）
  if (dish.promotionStatus && dish.promotionStatus !== 'active') return false

  // 如果没有设置时间范围，则认为促销有效
  if (!dish.promotionStart && !dish.promotionEnd) return true

  const now = new Date()
  const start = dish.promotionStart ? new Date(dish.promotionStart) : null
  const end = dish.promotionEnd ? new Date(dish.promotionEnd) : null

  if (start && now < start) return false
  if (end && now > end) return false

  return true
}

// 根据促销类型获取标签文字
const getPromotionLabel = (dish) => {
  const type = dish.promotionType
  switch (type) {
    case 'discount':
      return '折扣'
    case 'special':
      return '特价'
    case 'gift':
      return '买赠'
    case 'full_reduction':
      return '满减'
    case 'combo':
      return '套餐'
    case 'time_limit':
      return '限时'
    default:
      return '促销'
  }
}

const formatHealthRecs = (list) => {
  const raw = Array.isArray(list) ? list : []
  return raw.map((item) => {
    const price = Number(item?.price) || 0
    
    // 处理窗口名称
    let windowName = '未知窗口';
    if (item?.windowName) {
      windowName = item.windowName;
    } else if (item?.window && typeof item.window === 'object') {
      windowName = item.window.name || '未知窗口';
    }

    return {
      ...item, // 保留原始字段，确保详情页能获取到 description, canteenName 等
      id: item?.id,
      name: item?.name || '未命名菜品',
      price,
      image: item?.imageUrl || item?.image || getDefaultImageByCategory(item?.category || '主食'),
      available: item?.available !== undefined ? Boolean(item.available) : true,
      tags: Array.isArray(item?.healthTags) ? item.healthTags : [],
      nutritionScore: Number(item?.nutritionScore) || 0,
      fitPercent: Number(item?.fitPercent) || 0,
      calories: item?.calories,
      protein: item?.protein,
      fat: item?.fat,
      carbohydrate: item?.carbohydrate,
      canteenName: item?.canteenName || '未知食堂',
      windowName: windowName,
      description: item?.description || '',
      category: item?.category,
      dishCategory: item?.category // 确保dishCategory字段存在
    }
  }).filter(i => i && i.id)
}

const loadHealthGoalRecommendations = async (refreshToken) => {
  healthLoading.value = true
  try {
    const res = await recommendationApi.getHealthGoalRecommendations(4, refreshToken)
    const data = res?.data || {}
    healthGoals.value = Array.isArray(data.goals) ? data.goals : []
    healthRecs.value = formatHealthRecs(data.recommendations)
  } catch (e) {
    healthGoals.value = []
    healthRecs.value = []
  } finally {
    healthLoading.value = false
  }
}

const refreshHealthRecommendations = async () => {
  await loadHealthGoalRecommendations(String(Date.now()))
}

const scheduleHealthRefresh = () => {
  if (healthRefreshTimer) return
  healthRefreshTimer = setTimeout(async () => {
    healthRefreshTimer = null
    await loadHealthGoalRecommendations(String(Date.now()))
  }, 800)
}

const schedulePersonalizedRefresh = () => {
  if (personalizedRefreshTimer) return
  personalizedRefreshTimer = setTimeout(async () => {
    personalizedRefreshTimer = null
    clearPersonalizedCache()
    await Promise.allSettled([
      loadPersonalizedDishes(true),
      loadHotDishes()
    ])
  }, 800)
}

const subscribeOrderEvents = () => {
  if (orderEventSource) return

  const connect = () => {
    try {
      orderEventSource = new EventSource('/api/orders/events')

      orderEventSource.addEventListener('order-update', () => {
        scheduleHealthRefresh()
        schedulePersonalizedRefresh()
      })

      orderEventSource.onerror = () => {
        if (orderEventSource) {
          orderEventSource.close()
          orderEventSource = null
        }
        // 5秒后尝试重连
        setTimeout(() => {
          if (!orderEventSource) {
            connect()
          }
        }, 5000)
      }
    } catch (e) {
      console.warn('EventSource连接失败:', e)
      // 5秒后尝试重连
      setTimeout(() => {
        if (!orderEventSource) {
          connect()
        }
      }, 5000)
    }
  }

  connect()
}

const handlePreferencesUpdated = () => {
  schedulePersonalizedRefresh()
}

// 格式化菜品数据，确保与Dishes.vue页面一致
const formatDishData = (responseData) => {
  return responseData.map(dish => {
    // 处理状态字段的不同表示
    let isAvailable = true
    if (dish.status !== undefined) {
      isAvailable = dish.status === 'AVAILABLE' || dish.status === 'available' || dish.status === 'active' || dish.status === true
    } else if (dish.available !== undefined) {
      isAvailable = Boolean(dish.available)
    }
    
    // 处理价格字段
    const originalPrice = Number(dish.price) || 0
    
    // 检查是否有促销信息，直接从dish对象获取促销字段
    const isPromotion = Boolean(dish.isPromotion);
    const promotionPrice = isPromotion && dish.promotionPrice ? Number(dish.promotionPrice) : originalPrice;
    
    // 计算折扣（保留一位小数）
    const discount = isPromotion && promotionPrice < originalPrice ? ((promotionPrice / originalPrice) * 10).toFixed(1) : null;
    
    // 处理评分字段 - 确保评分在合理范围内
    let rating = Number(dish.rating) || Number(dish.averageRating) || 0;
    // 如果没有评分数据且有一定销量，可以设置一个默认评分
    if (rating === 0 && (Number(dish.sales) || Number(dish.salesCount) || 0) > 0) {
      rating = 4.0; // 设置一个默认好评分数
    }
    // 限制评分范围在0-5之间
    rating = Math.max(0, Math.min(5, rating));
    
    // 处理分类字段 - 优先使用 dishCategory，其次使用 category
    const categoryText = dish.dishCategory || dish.category || '未知分类';
    
    // 处理窗口名称 - 尝试从不同字段获取
    let windowName = '未知窗口';
    if (dish.windowName) {
      windowName = dish.windowName;
    } else if (dish.window && typeof dish.window === 'object') {
      windowName = dish.window.name || '未知窗口';
    }
    
    return {
      ...dish,
      id: dish.id || dish.dishId,
      name: dish.name || '未命名菜品',
      price: promotionPrice, // 显示促销价格
      originalPrice: originalPrice, // 显示原价
      promotionPrice: promotionPrice,
      discount: discount, // 添加折扣信息
      category: categoryText, // 使用 dishCategory 作为分类显示
      dishCategory: categoryText, // 确保dishCategory字段存在
      image: toImageUrl(
        dish.image || dish.imageUrl || getDefaultImageByCategory(categoryText),
      ),
      // 正确处理后端返回的tasteTags字段
      tags: Array.isArray(dish.tasteTags) ? dish.tasteTags.map(tag => getTagText(tag)) : [],
      salesCount: Number(dish.sales) || Number(dish.salesCount) || 0,
      rating: rating,
      available: isAvailable,
      isPromotion: isPromotion,
      canteenName: dish.canteenName || '未知食堂',
      windowName: windowName, // 使用从不同字段获取的窗口名称
      windowLocation: dish.windowLocation || '未知位置',
      description: dish.description || '',
      nutritionInfo: dish.nutrition || dish.nutritionInfo || '', // 兼容不同的营养信息字段名
      calories: dish.calories,
      protein: dish.protein,
      fat: dish.fat,
      carbohydrate: dish.carbohydrate,
      stock: Number(dish.stock) || 0,
      categoryId: dish.categoryId || dish.dishCategory || dish.category,
      // 保存原始分类和标签用于筛选
      originalCategory: dish.dishCategory || dish.category || '',
      originalTags: Array.isArray(dish.tasteTags) ? dish.tasteTags : (dish.tasteTags?.split(',') || [])
    }
  })
}

const CACHE_KEYS = {
  // v2：与后端删除菜品后缓存失效策略对齐，避免本地仍长期展示已删菜品
  todayNew: 'home_today_new_dishes_v2',
  youMayLike: 'home_you_may_like_dishes'
}

const getCurrentUserCacheSuffix = () => {
  const directUserId = localStorage.getItem('userId')
  if (directUserId) return String(directUserId)
  try {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (userInfo && userInfo.id != null) return String(userInfo.id)
  } catch (e) {}
  return 'guest'
}

const getScopedCacheKey = (baseKey) => `${baseKey}_${getCurrentUserCacheSuffix()}`

const clearPersonalizedCache = () => {
  try {
    localStorage.removeItem(getScopedCacheKey(CACHE_KEYS.youMayLike))
  } catch (e) {}
}

const saveCache = (key, data) => {
  try {
    const payload = {
      time: Date.now(),
      date: new Date().toDateString(),
      data
    }
    localStorage.setItem(key, JSON.stringify(payload))
  } catch (e) {}
}

const loadCache = (key, maxAgeMs, ignoreAge = false) => {
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return null
    const payload = JSON.parse(raw)
    if (!payload || !payload.time) return null
    const now = Date.now()
    if (!ignoreAge) {
      if (typeof maxAgeMs === 'number' && maxAgeMs > 0 && now - payload.time > maxAgeMs) return null
      if (payload.date && payload.date !== new Date().toDateString()) return null
    }
    return payload.data || null
  } catch (e) {
    return null
  }
}

// 处理API响应数据
const handleApiResponse = (response) => {
  let responseData = []
  
  console.log('原始响应数据:', response)
  
  // 1. 如果响应是数组，直接使用
  if (Array.isArray(response)) {
    responseData = response
    console.log('检测到直接返回数组格式')
  }
  // 2. 如果响应是对象，检查是否有data属性
  else if (typeof response === 'object' && response !== null) {
    // 2.1 检查是否有data属性
    if ('data' in response) {
      console.log('检测到data属性，值为:', response.data)
      // 2.1.1 data是数组
      if (Array.isArray(response.data)) {
        responseData = response.data
        console.log('检测到data属性为数组')
      }
      // 2.1.2 data是对象，可能有items或records属性
      else if (typeof response.data === 'object') {
        responseData = response.data.items || response.data.records || []
        console.log('检测到嵌套的data结构')
      } else {
        console.warn('响应data不是数组或对象:', response.data)
        responseData = []
      }
    } else {
      // 2.2 响应对象没有data属性
      console.warn('响应对象没有data属性')
      responseData = []
    }
  }
  
  console.log('处理后的响应数据:', responseData)
  return responseData
}

// 加载今日上线推荐
const loadNewDishes = async () => {
  try {
    console.log('调用API: 获取今日上线推荐')
    const cached = loadCache(CACHE_KEYS.todayNew, 5 * 60 * 1000)
    if (cached && Array.isArray(cached) && cached.length > 0) {
      newDishes.value = cached
      return
    }
    const response = await recommendationApi.getTodayNewDishes(4)
    const responseData = handleApiResponse(response)
    newDishes.value = formatDishData(responseData)
    saveCache(CACHE_KEYS.todayNew, newDishes.value)
  } catch (error) {
    console.error('加载今日上线推荐失败:', error)
    const fallback = loadCache(CACHE_KEYS.todayNew, 0, true)
    if (fallback && Array.isArray(fallback) && fallback.length > 0) {
      newDishes.value = fallback
    } else {
      newDishes.value = []
    }
  }
}

// 加载今日热门推荐
const loadHotDishes = async () => {
  try {
    console.log('调用API: 获取今日个性化热门推荐')
    const response = await recommendationApi.getTodayPersonalizedHotDishes(4)
    const responseData = handleApiResponse(response)
    let formattedData = formatDishData(responseData)
    
    // 如果返回的数据为空，或者与newDishes完全重复（例如未登录时），尝试前端筛选
    if (formattedData.length === 0) {
       // 降级：使用原有逻辑
       const allDishesResponse = await dishApi.getDishes()
       const allDishesData = handleApiResponse(allDishesResponse)
       formattedData = formatDishData(allDishesData)
         .sort((a, b) => b.salesCount - a.salesCount)
         .slice(0, 4)
    }

    // 筛选出与newDishes和discountDishes不同的菜品，避免重复显示
    const excludeDishIds = new Set([
      ...newDishes.value.map(dish => dish.id),
      ...discountDishes.value.map(dish => dish.id)
    ])
    
    // 如果排除后不够4个，则不排除（优先保证显示）
    const filteredDishes = formattedData.filter(dish => !excludeDishIds.has(dish.id))
    
    if (filteredDishes.length >= 4) {
      hotDishes.value = filteredDishes.slice(0, 4)
    } else {
      hotDishes.value = formattedData.slice(0, 4)
    }
  } catch (error) {
    console.error('加载热门菜品失败:', error)
    hotDishes.value = []
  }
}

// 加载折扣推荐
const loadDiscountDishes = async () => {
  try {
    console.log('调用API: 获取折扣推荐')
    let response = await dishApi.getActivePromotionDishes()
    let responseData = handleApiResponse(response)
    if (!Array.isArray(responseData) || responseData.length === 0) {
      response = await dishApi.getPromotionDishes()
      responseData = handleApiResponse(response)
    }
    
    const formattedData = Array.isArray(responseData) && responseData.length > 0
      ? formatDishData(responseData)
      : []
    
    discountDishes.value = formattedData
  } catch (error) {
    console.error('加载折扣推荐失败:', error)
    discountDishes.value = []
  }
}

const loadPromoCombos = async () => {
  try {
    const promosResp = await promotionsAPI.getActivePromotions()
    const promos = handleApiResponse(promosResp)
    const comboPromos = (promos || []).filter(p => String(p?.type || '').toLowerCase() === 'combo' && p?.id != null)
    if (comboPromos.length === 0) {
      promoCombos.value = []
      return
    }

    const all = []
    for (const p of comboPromos) {
      const combosResp = await combosAPI.getActiveCombosByPromotionId(p.id)
      const combos = handleApiResponse(combosResp)
      for (const c of combos || []) {
        all.push({
          ...c,
          promotionName: p.name || ''
        })
      }
    }

    const list = all
      .filter(c => c && c.id != null && c.name)
      .map(c => {
        const dishes = Array.isArray(c.dishes) ? c.dishes : []
        const dishNames = dishes.map(d => d?.name).filter(Boolean).slice(0, 3)
        const cover = dishes.find(d => d?.imageUrl)?.imageUrl || getDefaultImageByCategory('主食')
        return {
          ...c,
          dishNames,
          image: cover
        }
      })

    promoCombos.value = list
  } catch (e) {
    promoCombos.value = []
  }
}

// 加载个性化推荐
const loadPersonalizedDishes = async (forceRefresh = false) => {
  let usedCached = false
  try {
    console.log('调用API: 获取个性化推荐')
    const scopedKey = getScopedCacheKey(CACHE_KEYS.youMayLike)
    const cached = forceRefresh ? null : loadCache(scopedKey, 10 * 60 * 1000)
    if (!forceRefresh && cached && Array.isArray(cached) && cached.length > 0) {
      personalizedDishes.value = cached
      usedCached = true
    }
    const response = await recommendationApi.getPersonalizedRecommendationsWithReason(4)
    const responseData = handleApiResponse(response)
    const formatted = formatDishData(responseData)
    personalizedDishes.value = formatted.map((item, index) => ({
      ...item,
      recommendReason: responseData[index] && responseData[index].reason ? responseData[index].reason : '根据您的历史行为推荐'
    }))
    saveCache(scopedKey, personalizedDishes.value)
  } catch (error) {
    console.error('加载个性化推荐失败:', error)
    if (usedCached && personalizedDishes.value.length > 0) {
      return
    }
    const fallback = loadCache(getScopedCacheKey(CACHE_KEYS.youMayLike), 0, true)
    if (fallback && Array.isArray(fallback) && fallback.length > 0) {
      personalizedDishes.value = fallback
    } else {
      personalizedDishes.value = []
    }
  }
}

// 加载所有推荐数据
const loadAllRecommendations = async () => {
  console.log('===== 开始加载所有推荐数据 =====')
  loading.value = true
  try {
    // 先加载今日上新和折扣推荐，再加载热门推荐，确保热门推荐不与其他推荐重复
    await loadNewDishes()
    await loadDiscountDishes()
    await loadHotDishes()
  } catch (error) {
    console.error('加载推荐数据失败:', error)
    ElMessage.error('加载推荐数据失败，请稍后重试')
  } finally {
    loading.value = false
    console.log('===== 推荐数据加载结束 =====')
  }
}

// 显示菜品详情
const showDishDetail = (dish) => {
  currentDish.value = dish
  detailVisible.value = true
  loadDishReviews(dish.id)
}

// 添加到购物车
const addToCart = async (dish) => {
  if (!dish.available) {
    ElMessage.warning('该菜品已售罄')
    return
  }
  
  try {
    await orderApi.addToCart({ dishId: dish.id, quantity: 1 })

    const res = await orderApi.getCart()
    const serverCart = res?.data?.data ?? res?.data
    const localRaw = (() => {
      try {
        return JSON.parse(localStorage.getItem('cart') || '[]')
      } catch {
        return []
      }
    })()
    const comboItems = (Array.isArray(localRaw) ? localRaw : []).filter(i => i && i.type === 'COMBO')
    const merged = [...comboItems, ...(Array.isArray(serverCart) ? serverCart : [])]
    localStorage.setItem('cart', JSON.stringify(merged))
    window.dispatchEvent(new Event('storage'))
    ElMessage.success('已添加到购物车')
  } catch (error) {
    console.error('添加到购物车失败:', error)
    ElMessage.error('添加失败')
  }
}

const addComboToCart = (combo) => {
  try {
    const dishes = Array.isArray(combo?.dishes) ? combo.dishes : []
    if (dishes.length === 0) {
      ElMessage.warning('该套餐暂无菜品')
      return
    }

    const formatted = formatDishData(dishes)
    const unavailable = formatted.filter(d => !d.available)
    if (unavailable.length > 0) {
      ElMessage.warning('该套餐包含已售罄菜品，暂不可加入购物车')
      return
    }

    let cart = JSON.parse(localStorage.getItem('cart') || '[]')
    const existingIndex = cart.findIndex(i => i?.type === 'COMBO' && String(i?.combo?.id) === String(combo?.id))

    if (existingIndex >= 0) {
      cart[existingIndex].quantity = Number(cart[existingIndex].quantity || 1) + 1
      localStorage.setItem('cart', JSON.stringify(cart))
      ElMessage.success(`已将【${combo?.name || '套餐'}】加入购物车`)
      return
    }

    const comboItem = {
      id: Date.now() + Math.floor(Math.random() * 10000),
      type: 'COMBO',
      quantity: 1,
      combo: {
        id: combo?.id,
        name: combo?.name || '未命名套餐',
        description: combo?.description || '',
        price: Number(combo?.price) || 0,
        originalPrice: Number(combo?.originalPrice) || 0,
        image: combo?.image || getDefaultImageByCategory('主食'),
        promotionName: combo?.promotionName || ''
      },
      dishes: formatted
    }

    cart.push(comboItem)
    localStorage.setItem('cart', JSON.stringify(cart))
    ElMessage.success(`已将【${comboItem.combo.name}】加入购物车`)
  } catch (error) {
    console.error('加入套餐到购物车失败:', error)
    ElMessage.error('加入失败')
  }
}

const showComboDetail = (combo) => {
  currentCombo.value = combo
  comboDetailVisible.value = true
  const dishes = Array.isArray(combo?.dishes) ? combo.dishes : []
  comboDishes.value = formatDishData(dishes)
}

const scheduleMidnightRefresh = () => {
  if (midnightTimer) {
    clearTimeout(midnightTimer)
  }
  const now = new Date()
  const nextMidnight = new Date(now)
  nextMidnight.setHours(24, 0, 0, 0)
  const delay = nextMidnight.getTime() - now.getTime()
  midnightTimer = setTimeout(async () => {
    await loadNewDishes()
    scheduleMidnightRefresh()
  }, Math.max(1000, delay))
}

onMounted(async () => {
  window.addEventListener('preferences-updated', handlePreferencesUpdated)
  loading.value = true
  try {
    await Promise.allSettled([
      loadPersonalizedDishes(),
      loadNewDishes(),
      loadDiscountDishes(),
      loadPromoCombos(),
      loadHotDishes(),
      loadHealthGoalRecommendations()
    ])
    if (discountDishes.value.length === 0 && promoCombos.value.length > 0) {
      promotionTab.value = 'combo'
    } else if (promoCombos.value.length === 0 && discountDishes.value.length > 0) {
      promotionTab.value = 'dish'
    }
    scheduleMidnightRefresh()
    subscribeOrderEvents()
  } finally {
    loading.value = false
  }
})

onUnmounted(() => {
  if (midnightTimer) {
    clearTimeout(midnightTimer)
    midnightTimer = null
  }
  if (healthRefreshTimer) {
    clearTimeout(healthRefreshTimer)
    healthRefreshTimer = null
  }
  if (personalizedRefreshTimer) {
    clearTimeout(personalizedRefreshTimer)
    personalizedRefreshTimer = null
  }
  window.removeEventListener('preferences-updated', handlePreferencesUpdated)
  if (orderEventSource) {
    orderEventSource.close()
    orderEventSource = null
  }
})
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background-color: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.welcome-section {
  text-align: center;
  margin-bottom: 60px;
}

.welcome-title {
  font-size: 36px;
  color: #333;
  margin-bottom: 10px;
}

.welcome-subtitle {
  font-size: 18px;
  color: #666;
  margin-bottom: 40px;
}

.feature-cards {
  margin-bottom: 60px;
}

.feature-card {
  cursor: pointer;
  transition: transform 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
}

.card-content {
  text-align: center;
  padding: 30px 20px;
}

.card-content h3 {
  margin: 15px 0 10px;
  color: #333;
}

.card-content p {
  color: #666;
  font-size: 14px;
}

.section-title {
  font-size: 24px;
  color: #333;
  margin-bottom: 30px;
  text-align: center;
  padding: 20px 0;
  border-bottom: 2px solid #409EFF;
  width: fit-content;
  margin-left: auto;
  margin-right: auto;
}

.recommendation-section {
  margin-bottom: 60px;
}

.health-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.section-health-goals .section-title {
  border-bottom-color: #67c23a;
  margin-bottom: 0;
}

.health-panel {
  margin-top: 16px;
  border-radius: 12px;
}

.health-goals {
  margin-bottom: 16px;
}

.health-goals-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 10px;
}

.health-goals-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
}

.health-goals-desc {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: #666;
  font-size: 13px;
}

.health-goal-item {
  display: flex;
  gap: 10px;
}

.goal-name {
  color: #333;
  font-weight: 500;
  white-space: nowrap;
}

.health-recs {
  margin-top: 8px;
}

.health-badges {
  position: absolute;
  top: 10px;
  left: 10px;
  display: flex;
  gap: 8px;
  z-index: 1;
}

.health-badge {
  background: rgba(0, 0, 0, 0.65);
  color: #fff;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  line-height: 1;
}

.health-nutrition {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 6px 10px;
  font-size: 12px;
  color: #666;
  margin-top: 10px;
}

.dish-card {
  cursor: pointer;
  transition: transform 0.3s;
  position: relative;
  overflow: hidden;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.dish-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.dish-image {
  height: var(--dish-image-size);
  overflow: hidden;
  position: relative;
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

/* 新品标签样式 */
.new-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background-color: #67C23A;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  z-index: 1;
}

/* 折扣标签样式 */
.discount-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  background-color: #F56C6C;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
  z-index: 1;
}

.reason-badge {
  position: absolute;
  bottom: 10px;
  left: 10px;
  background-color: rgba(64, 158, 255, 0.9);
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  z-index: 1;
}

.section-today-new .section-title {
  border-bottom-color: #67C23A;
}
.section-you-may-like .section-title {
  border-bottom-color: #409EFF;
}
.section-header {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 12px;
  margin-bottom: 20px;
}
.section-subtitle {
  color: #666;
  font-size: 14px;
}

.youmaylike-scroll {
  overflow-x: auto;
  padding-bottom: 10px;
}

.youmaylike-inner {
  display: flex;
  gap: 20px;
}

.youmaylike-item {
  flex: 0 0 260px;
  height: 400px; /* 固定高度确保对齐 */
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
  overflow: hidden;
  text-overflow: ellipsis;
  /* 限制为最多2行 */
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  height: 44px; /* 固定高度 */
}

.dish-price {
  margin: 0 0 10px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.current-price {
  font-size: 18px;
  color: #f56c6c;
  font-weight: bold;
}

.original-price {
  font-size: 14px;
  color: #999;
  text-decoration: line-through;
}

.dish-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-bottom: 10px;
  height: 24px; /* 固定高度 */
  overflow: hidden;
}

.dish-actions {
  display: flex;
  gap: 10px;
  margin-top: auto; /* 将按钮推到底部 */
}

.detail-image {
  width: var(--dish-image-size);
  height: var(--dish-image-size);
  border-radius: 8px;
  flex-shrink: 0;
}

.combo-dish-image {
  width: var(--dish-image-size);
  height: var(--dish-image-size);
  border-radius: 6px;
  flex-shrink: 0;
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
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.nutrition-item .label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.nutrition-item .value {
  font-weight: bold;
  color: #409EFF;
}

.combo-dish-meta {
  font-size: 12px;
  color: #666;
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 10px;
}

.combo-dish-row {
  display: flex;
  gap: 8px;
}

.combo-dish-label {
  width: 36px;
  color: #999;
  flex: 0 0 auto;
}

.combo-dish-value {
  flex: 1 1 auto;
  color: #666;
}

.combo-dish-original {
  margin-left: 8px;
  color: #999;
  text-decoration: line-through;
}

.combo-dish-desc {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.combo-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

/* 评价列表样式 */
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

.reviews-container {
  min-height: 200px;
}

.no-reviews {
  text-align: center;
  color: #909399;
  padding: 40px 0;
}

.reviews-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.review-item {
  border-bottom: 1px solid #ebeef5;
  padding-bottom: 20px;
}

.review-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.username {
  font-size: 14px;
  color: #333;
}

.time {
  font-size: 12px;
  color: #909399;
}

.rating-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.tags-container {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.review-content {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
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

.merchant-reply {
  background-color: #f5f7fa;
  padding: 10px;
  border-radius: 4px;
  margin-top: 10px;
}

.reply-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
  font-size: 12px;
}

.reply-title {
  color: #e6a23c;
  font-weight: bold;
}

.reply-time {
  color: #909399;
}

.reply-content {
  font-size: 13px;
  color: #606266;
}
</style>
