<template>
  <el-header class="admin-header">
    <div class="header-content">
      <div class="logo-section">
        <el-icon size="32" color="#409EFF"><Food /></el-icon>
        <span class="admin-title">高校食堂菜品推荐系统 - 管理后台</span>
      </div>

      <div class="nav-section">
        <el-menu
          :default-active="activeMenu"
          mode="horizontal"
          class="admin-nav-menu"
          @select="handleMenuSelect"
        >
          <el-menu-item index="/admin/dashboard">
            <el-icon><DataAnalysis /></el-icon>
            <span>数据看板</span>
          </el-menu-item>

          <el-menu-item v-if="!isWindowManager" index="/admin/analysis">
            <el-icon><TrendCharts /></el-icon>
            <span>高级分析</span>
          </el-menu-item>

          <el-menu-item index="/admin/dishes">
            <el-icon><Food /></el-icon>
            <span>菜品管理</span>
          </el-menu-item>

          <el-menu-item index="/admin/orders">
            <el-icon><Document /></el-icon>
            <span>订单管理</span>
          </el-menu-item>
          <el-menu-item v-if="!isWindowManager" index="/admin/users">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/reviews">
            <el-icon><ChatDotRound /></el-icon>
            <span>评价管理</span>
          </el-menu-item>
          <el-menu-item v-if="!isWindowManager" index="/admin/announcements">
            <el-icon><Bell /></el-icon>
            <span>公告管理</span>
          </el-menu-item>

          <el-menu-item index="/admin/windows">
            <el-icon><Shop /></el-icon>
            <span>窗口管理</span>
          </el-menu-item>

          <el-menu-item v-if="!isWindowManager" index="/admin/canteens">
            <el-icon><OfficeBuilding /></el-icon>
            <span>食堂管理</span>
          </el-menu-item>

          <el-menu-item index="/admin/promotions">
            <el-icon><MilkTea /></el-icon>
            <span>促销管理</span>
          </el-menu-item>

          <el-menu-item v-if="!isWindowManager" index="/admin/vouchers">
            <el-icon><Tickets /></el-icon>
            <span>奖品管理</span>
          </el-menu-item>

          <el-menu-item
            v-if="!isWindowManager"
            index="/admin/voucher-exchanges"
          >
            <el-icon><List /></el-icon>
            <span>兑换订单</span>
          </el-menu-item>

          <el-menu-item index="/home">
            <el-icon><Setting /></el-icon>
            <span>系统设置</span>
          </el-menu-item>
        </el-menu>
      </div>

      <div class="user-section">
        <div class="notification-bell" @click="showNotifications">
          <el-badge :value="unreadCount" :hidden="unreadCount === 0" class="item">
            <el-icon size="20"><Bell /></el-icon>
          </el-badge>
        </div>
        <el-dropdown @command="handleUserCommand">
          <span class="user-info">
            <span class="avatar-wrapper">
              <el-avatar :size="32" :src="userAvatar" />
              <span v-if="hasUnread" class="unread-dot"></span>
            </span>
            <span class="user-name">{{ userName }}</span>
            <el-icon><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item divided command="logout">
                <el-icon><SwitchButton /></el-icon>
                退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
  </el-header>

  <el-drawer
    v-model="notificationDrawerVisible"
    title="消息通知"
    direction="rtl"
    size="350px"
  >
    <div v-loading="notificationLoading" class="notification-list">
      <div v-if="notifications.length === 0" class="empty-text">暂无通知</div>
      <div
        v-for="item in notifications"
        :key="item.id"
        class="notification-item"
        :class="{ unread: !item.isRead }"
        @click="handleNotificationClick(item)"
      >
        <div class="notification-title">{{ item.title }}</div>
        <div class="notification-content">{{ item.content }}</div>
        <div class="notification-time">{{ formatTime(item.createTime) }}</div>
      </div>
    </div>
    <div class="notification-footer">
      <el-button link type="primary" @click="markAllRead">全部已读</el-button>
    </div>
  </el-drawer>
</template>

<script setup>
import { ref, computed, onMounted, watch, onUnmounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { notificationApi } from "@/api/notification";
import { useUserStore } from "@/stores/user";
import { resolveStaticUrl } from "@/api";
import dayjs from "dayjs";
import {
  DataAnalysis,
  Food,
  Document,
  User,
  ChatDotRound,
  Bell,
  Shop,
  MilkTea,
  Setting,
  SwitchButton,
  ArrowDown,
  Tickets,
  List,
  TrendCharts,
  OfficeBuilding,
} from "@element-plus/icons-vue";

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();

// 响应式数据
const unreadCount = ref(0);
const hasUnread = computed(() => unreadCount.value > 0);
const notificationDrawerVisible = ref(false);
const notifications = ref([]);
const notificationLoading = ref(false);

const isWindowManager = computed(() => {
  return userStore.isManager;
});

const resolveAvatar = (avatar) => resolveStaticUrl(avatar, "/default-avatar.png");

const userAvatar = computed(() => resolveAvatar(userStore.userInfo?.avatar));
const userName = computed(() => {
  return (
    userStore.userInfo?.name ||
    userStore.userInfo?.username ||
    userStore.userInfo?.nickname ||
    "管理员"
  );
});

// 计算属性
const activeMenu = computed(() => {
  // 获取当前路径，确保正确匹配活动菜单
  const path = route.path;
  // 处理根路径情况
  if (path === "/admin") return "/admin/dashboard";
  return path;
});

// 监听路由变化
watch(
  () => route.path,
  () => {
    updateUserInfo();
    loadUnreadCount();
  },
);

const loadUnreadCount = async () => {
  try {
    const res = await notificationApi.admin.getWarningUnreadCount();
    const val = res?.data?.count;
    unreadCount.value =
      typeof val === "number" ? val : Number(val || 0);
  } catch (e) {
    unreadCount.value = unreadCount.value || 0;
  }
};

const showNotifications = () => {
  notificationDrawerVisible.value = true;
  loadNotifications();
};

const loadNotifications = async () => {
  notificationLoading.value = true;
  try {
    const res = await notificationApi.admin.getWarnings({
      page: 0,
      size: 20,
    });
    notifications.value = res?.data?.data || [];
  } catch (e) {
    console.error(e);
  } finally {
    notificationLoading.value = false;
  }
};

const formatTime = (time) => {
  if (!time) return "";
  return dayjs(time).format("MM-DD HH:mm");
};

const handleNotificationClick = async (item) => {
  if (!item.isRead) {
    try {
      await notificationApi.markAsRead(item.id);
      item.isRead = true;
      loadUnreadCount();
    } catch (e) {}
  }

  // Handle navigation based on notification type
  if (item.bizType === "REVIEW") {
    notificationDrawerVisible.value = false;
    router.push({
      path: "/admin/reviews",
      query: { status: "WARNING" }, // Automatically filter warnings if configured
    });
  }
};

const markAllRead = async () => {
  try {
    await notificationApi.admin.markAllWarningsAsRead();
    notifications.value.forEach((n) => (n.isRead = true));
    loadUnreadCount();
    ElMessage.success("全部标记已读");
  } catch (e) {}
};

// 更新用户信息
const updateUserInfo = () => {
  userStore.checkLoginStatus();
};

// 菜单选择处理
const handleMenuSelect = (index) => {
  if (route.path === index) return;
  router.push(index).catch((err) => {
    // 忽略重复导航错误
    if (
      err.name !== "NavigationDuplicated" &&
      !err.message.includes("Avoided redundant navigation")
    ) {
      console.error("Navigation failed:", err);
    }
  });
};

// 用户命令处理
const handleUserCommand = async (command) => {
  if (command === "logout") {
    await handleLogout();
  }
};

// 退出登录
const handleLogout = async () => {
  try {
    await ElMessageBox.confirm("确定要退出登录吗？", "提示", {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    });

    userStore.logout();

    // 跳转到登录页
    router.push("/login");

    ElMessage.success("退出登录成功");
  } catch (error) {
    // 用户取消操作
  }
};

let pollTimer = null;

// 初始化
onMounted(() => {
  updateUserInfo();
  loadUnreadCount();
  // 每30秒轮询一次未读数量
  pollTimer = setInterval(loadUnreadCount, 30000);
});

// 组件卸载时清除定时器
onUnmounted(() => {
  if (pollTimer) {
    clearInterval(pollTimer);
  }
});
</script>

<style scoped>
.admin-header {
  background: #fff;
  border-bottom: 1px solid #e6e6e6;
  padding: 0;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  z-index: 100;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 60px;
  padding: 0 32px 0 0;
  max-width: 100%;
  margin: 0;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.admin-title {
  font-size: 18px;
  font-weight: bold;
  color: #409eff;
  white-space: nowrap;
}

.nav-section {
  flex: 1;
  display: flex;
  justify-content: flex-start;
  margin-left: 24px;
}

.admin-nav-menu {
  border-bottom: none;
  height: 60px;
}

.admin-nav-menu .el-menu-item {
  height: 60px;
  line-height: 60px;
  border-bottom: 2px solid transparent;
  transition: all 0.3s;
  padding: 0 20px;
}

.admin-nav-menu .el-menu-item.is-active {
  border-bottom-color: #409eff;
  color: #409eff;
}

.user-section {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.user-info:hover {
  background-color: #f5f7fa;
}

.user-name {
  font-weight: 500;
  color: #333;
}

.avatar-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.unread-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #f56c6c;
  margin-top: 4px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .admin-nav-menu .el-menu-item {
    padding: 0 15px;
  }

  .admin-nav-menu .el-menu-item span {
    font-size: 14px;
  }
}

@media (max-width: 768px) {
  .header-content {
    padding: 0 10px;
  }

  .admin-title {
    font-size: 16px;
  }

  .nav-section {
    overflow-x: auto;
  }

  .admin-nav-menu {
    min-width: 700px;
  }

  .user-name {
    display: none;
  }
}
</style>
