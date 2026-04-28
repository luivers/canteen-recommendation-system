<template>
  <div class="data-dashboard-container">
    <el-row :gutter="20">
      <!-- 口味偏好分析 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="12" class="dashboard-col">
        <el-card class="dashboard-card" shadow="hover" v-loading="loading">
          <template #header>
            <div class="card-header">
              <div class="header-left">
                <el-icon class="header-icon"><ForkSpoon /></el-icon>
                <span class="header-title">口味偏好分析</span>
              </div>
            </div>
          </template>
          <div class="preference-content">
            <div v-if="isEmpty(preferences)" class="empty-state">
              <el-empty description="暂无口味数据" :image-size="80" />
            </div>
            <div v-else>
              <div class="preference-item">
                <span class="label">最喜爱的品类</span>
                <span class="value highlight">{{ preferences.favoriteCategory || '暂无' }}</span>
              </div>
              
              <div class="preference-item">
                <span class="label">辣度偏好</span>
                <div class="progress-wrapper">
                  <el-rate
                    v-model="preferences.spicinessLevel"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template="{value}级"
                    :max="5"
                  />
                </div>
              </div>

              <div class="preference-item">
                <span class="label">甜度偏好</span>
                <div class="progress-wrapper">
                  <el-rate
                    v-model="preferences.sweetnessLevel"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template="{value}级"
                    :max="5"
                    :colors="['#99A9BF', '#F7BA2A', '#FF9900']" 
                  />
                </div>
              </div>

              <div class="preference-item" v-if="preferences.dietaryRestrictions">
                <span class="label">忌口偏好</span>
                <div class="tags-wrapper">
                  <el-tag type="danger" size="small" effect="light">
                    {{ preferences.dietaryRestrictions }}
                  </el-tag>
                </div>
              </div>

               <div class="preference-item" v-if="preferences.dietaryTags && preferences.dietaryTags.length">
                <span class="label">饮食标签</span>
                <div class="tags-wrapper">
                  <el-tag 
                    v-for="tag in preferences.dietaryTags" 
                    :key="tag" 
                    type="success" 
                    size="small" 
                    class="dietary-tag"
                  >
                    {{ tag }}
                  </el-tag>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 健康饮食建议 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="12" class="dashboard-col">
        <el-card class="dashboard-card" shadow="hover" v-loading="loading">
          <template #header>
            <div class="card-header">
              <div class="header-left">
                <el-icon class="header-icon"><Apple /></el-icon>
                <span class="header-title">健康饮食建议</span>
              </div>
            </div>
          </template>
          <div class="health-content">
            <div v-if="!healthRecommendations || healthRecommendations.length === 0" class="empty-state">
              <el-empty description="暂无健康建议" :image-size="80" />
            </div>
            <div v-else class="recommendation-list">
              <div 
                v-for="(item, index) in healthRecommendations" 
                :key="index" 
                class="recommendation-item"
              >
                <div class="item-icon">
                  <el-icon color="#67C23A"><CircleCheckFilled /></el-icon>
                </div>
                <div class="item-text">
                  <div class="item-title">{{ item.title || item.name || '健康贴士' }}</div>
                  <div class="item-desc">{{ item.content || item.description || '保持均衡饮食，多吃蔬菜水果。' }}</div>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ForkSpoon, Apple, CircleCheckFilled } from '@element-plus/icons-vue';
import { statisticsApi } from '@/api/statistics';
import { ElMessage } from 'element-plus';

const loading = ref(false);
const preferences = ref({
  spicinessLevel: 0,
  sweetnessLevel: 0,
  favoriteCategory: '',
  dietaryRestrictions: '',
  dietaryTags: []
});
const healthRecommendations = ref([]);

const isEmpty = (obj) => {
  return !obj || (
    !obj.favoriteCategory && 
    !obj.spicinessLevel && 
    !obj.sweetnessLevel && 
    !obj.dietaryRestrictions && 
    (!obj.dietaryTags || obj.dietaryTags.length === 0)
  );
};

const fetchData = async () => {
  const token = localStorage.getItem("token");
  if (!token) {
    preferences.value = {
      spicinessLevel: 0,
      sweetnessLevel: 0,
      favoriteCategory: "",
      dietaryRestrictions: "",
      dietaryTags: [],
    };
    healthRecommendations.value = [];
    return;
  }
  loading.value = true;
  try {
    const [prefRes, healthRes] = await Promise.all([
      statisticsApi.getMyUserPreferences(),
      statisticsApi.getMyHealthRecommendations()
    ]);
    
    if (prefRes.data) {
      preferences.value = {
        ...preferences.value,
        ...prefRes.data
      };
      // Ensure levels are numbers for el-rate
      if (typeof preferences.value.spicinessLevel !== 'number') {
          preferences.value.spicinessLevel = Number(preferences.value.spicinessLevel) || 0;
      }
      if (typeof preferences.value.sweetnessLevel !== 'number') {
          preferences.value.sweetnessLevel = Number(preferences.value.sweetnessLevel) || 0;
      }
    }
    
    if (healthRes.data) {
      healthRecommendations.value = healthRes.data;
    }
  } catch (error) {
    console.error('Failed to fetch dashboard data:', error);
    ElMessage.warning('部分数据加载失败');
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.data-dashboard-container {
  margin-bottom: 20px;
}

.dashboard-col {
  margin-bottom: 20px;
}

/* Adjust for larger screens to remove bottom margin if needed, 
   but generally margin-bottom on col is safe for wrapping */
@media (min-width: 992px) {
  .dashboard-col {
    margin-bottom: 0;
  }
}

.dashboard-card {
  height: 100%;
  display: flex;
  flex-direction: column;
}

/* Ensure card body takes remaining height if we want equal height cards */
:deep(.el-card__body) {
  flex: 1;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.header-icon {
  font-size: 18px;
  color: #409EFF;
}

.header-title {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
}

.preference-content, .health-content {
  min-height: 150px;
}

.preference-item {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.preference-item:last-child {
  margin-bottom: 0;
}

.preference-item .label {
  width: 100px;
  color: #606266;
  font-size: 14px;
}

.preference-item .value {
  color: #303133;
  font-weight: 500;
}

.preference-item .highlight {
  color: #409EFF;
  font-weight: bold;
}

.progress-wrapper {
  flex: 1;
}

.tags-wrapper {
  flex: 1;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.dietary-tag {
  margin-right: 0;
}

.recommendation-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.recommendation-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 8px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.item-icon {
  margin-top: 2px;
}

.item-text {
  flex: 1;
}

.item-title {
  font-weight: bold;
  color: #303133;
  margin-bottom: 4px;
  font-size: 14px;
}

.item-desc {
  color: #606266;
  font-size: 13px;
  line-height: 1.4;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  min-height: 150px;
}
</style>
