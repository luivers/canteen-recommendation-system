<template>
  <div class="notification-bar">
    <el-row :gutter="20">
      <!-- 系统公告 -->
      <el-col :span="8">
        <el-card shadow="hover" class="notify-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><Bell /></el-icon> 系统公告</span
              >
              <el-tag size="small" effect="plain">最新</el-tag>
            </div>
          </template>
          <div class="notify-list">
            <div v-if="announcements.length === 0" class="empty-text">
              暂无公告
            </div>
            <div
              v-for="item in announcements"
              :key="item.id"
              class="notify-item"
              @click="showAnnouncement(item)"
            >
              <span class="notify-title" :title="item.title">{{
                item.title
              }}</span>
              <span class="notify-time">{{ formatDate(item.createTime) }}</span>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 促销信息 -->
      <el-col :span="8">
        <el-card shadow="hover" class="notify-card promotion-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><Present /></el-icon> 优惠促销</span
              >
              <el-tag size="small" type="danger" effect="plain">HOT</el-tag>
            </div>
          </template>
          <div class="notify-list">
            <div v-if="promotions.length === 0" class="empty-text">
              暂无促销
            </div>
            <div
              v-for="item in promotions"
              :key="item.id"
              class="notify-item promotion-item"
              @click="showPromotion(item)"
            >
              <div class="promo-content">
                <span class="notify-title" :title="item.name">{{
                  item.name
                }}</span>
                <span v-if="item.description" class="promo-desc">{{
                  item.description
                }}</span>
              </div>
              <el-tag v-if="item.discountRate" size="small" type="danger"
                >{{ item.discountRate * 10 }}折</el-tag
              >
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 食堂信息 -->
      <el-col :span="8">
        <el-card shadow="hover" class="notify-card canteen-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><Shop /></el-icon> 食堂概况</span
              >
              <el-tag size="small" type="success" effect="plain">营业中</el-tag>
            </div>
          </template>
          <div class="notify-list">
            <div v-if="canteenGroups.length === 0" class="empty-text">
              暂无食堂信息
            </div>
            <div v-for="group in canteenGroups" :key="group.area">
              <div class="notify-item">
                <span class="notify-title"
                  >【{{ group.area || "未知区域" }}】（{{
                    group.items.length
                  }}个食堂）</span
                >
              </div>
              <div
                v-for="item in group.items"
                :key="item.id"
                class="notify-item"
              >
                <span class="notify-title">{{ item.name }}</span>
                <span v-if="item.description" class="notify-desc">{{
                  item.description
                }}</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 公告详情弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="selectedItem?.title || selectedItem?.name"
      width="30%"
    >
      <div class="dialog-content">
        <p v-if="selectedItem?.content" class="announcement-content">
          {{ selectedItem.content }}
        </p>
        <div v-if="selectedItem?.description" class="promotion-detail">
          <p>{{ selectedItem.description }}</p>
          <p v-if="selectedItem.startTime">
            开始时间: {{ formatDateFull(selectedItem.startTime) }}
          </p>
          <p v-if="selectedItem.endTime">
            结束时间: {{ formatDateFull(selectedItem.endTime) }}
          </p>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button type="primary" @click="dialogVisible = false"
            >关闭</el-button
          >
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { Bell, Present, Shop } from "@element-plus/icons-vue";
import { notificationApi } from "@/api/notification";
import { promotionsAPI } from "@/api/promotions";
import canteenApi from "@/api/canteen";

const announcements = ref([]);
const promotions = ref([]);
const canteens = ref([]);
const canteenGroups = ref([]);
const dialogVisible = ref(false);
const selectedItem = ref(null);

const formatDate = (dateStr) => {
  if (!dateStr) return "";
  const date = new Date(dateStr);
  return `${date.getMonth() + 1}-${date.getDate()}`;
};

const formatDateFull = (dateStr) => {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString();
};

const showAnnouncement = (item) => {
  selectedItem.value = item;
  dialogVisible.value = true;
};

const showPromotion = (item) => {
  selectedItem.value = item;
  dialogVisible.value = true;
};

const fetchData = async () => {
  try {
    // 获取公告
    try {
      const res1 = await notificationApi.getPublicAnnouncements();
      announcements.value = res1?.data?.data || [];
    } catch (e) {
      console.error("获取公告失败", e);
    }

    // 获取促销
    try {
      const res2 = await promotionsAPI.getActivePromotions();
      promotions.value = res2.data || [];
    } catch (e) {
      console.error("获取促销失败", e);
    }

    // 获取食堂（从canteens表）
    try {
      const res3 = await canteenApi.getAll();
      const list = Array.isArray(res3.data) ? res3.data : [];
      canteens.value = list;
      // 分组：按location作为区域
      const map = new Map();
      list.forEach((c) => {
        const area = c.location || "未知区域";
        if (!map.has(area)) map.set(area, []);
        map.get(area).push({
          id: c.id,
          name: c.name,
          description: c.description || "",
        });
      });
      canteenGroups.value = Array.from(map.entries()).map(([area, items]) => ({
        area,
        items,
      }));
    } catch (e) {
      console.error("获取食堂信息失败", e);
      canteens.value = [];
      canteenGroups.value = [];
    }
  } catch (e) {
    console.error("Failed to fetch notification bar data", e);
  }
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.notification-bar {
  margin-bottom: 24px;
}
.notify-card {
  height: 220px;
  display: flex;
  flex-direction: column;
}
.notify-card :deep(.el-card__header) {
  padding: 12px 20px;
  border-bottom: 1px solid #ebeef5;
  background-color: #fafafa;
}
.notify-card :deep(.el-card__body) {
  flex: 1;
  overflow: hidden;
  padding: 0;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
  font-size: 15px;
  color: #303133;
}
.card-header .el-icon {
  margin-right: 6px;
  vertical-align: middle;
}
.notify-list {
  height: 100%;
  overflow-y: auto;
  padding: 10px 0;
}
.notify-list::-webkit-scrollbar {
  width: 6px;
}
.notify-list::-webkit-scrollbar-thumb {
  background: #e4e7ed;
  border-radius: 3px;
}
.notify-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 20px;
  font-size: 14px;
  cursor: pointer;
  transition: background-color 0.2s;
  color: #606266;
}
.notify-item:hover {
  background-color: #f5f7fa;
  color: #409eff;
}
.notify-title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  margin-right: 10px;
}
.notify-time {
  color: #909399;
  font-size: 12px;
  flex-shrink: 0;
}
.empty-text {
  color: #909399;
  text-align: center;
  margin-top: 40px;
  font-size: 13px;
}
.promotion-item {
  align-items: flex-start;
}
.promo-content {
  display: flex;
  flex-direction: column;
  flex: 1;
  overflow: hidden;
}
.promo-desc {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.dialog-content {
  line-height: 1.6;
  color: #606266;
  font-size: 15px;
}
.announcement-content {
  white-space: pre-wrap;
}
</style>
