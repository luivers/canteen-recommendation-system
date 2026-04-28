<template>
  <el-header class="header">
    <div class="header-content">
      <div class="logo">
        <h2>高校食堂菜品推荐系统</h2>
      </div>
      <div class="nav-menu">
        <el-menu
          :default-active="activeMenu"
          mode="horizontal"
          class="menu"
          @select="handleMenuSelect"
        >
          <el-menu-item index="/home">首页</el-menu-item>
          <el-menu-item index="/dishes">菜品浏览</el-menu-item>
          <el-menu-item index="/orders">我的订单</el-menu-item>
          <el-menu-item index="/cart">购物车</el-menu-item>

          <!-- 更多菜单，仅管理员显示 -->
          <el-sub-menu v-if="isAdmin" index="more">
            <template #title>
              <span>
                <el-icon><More /></el-icon>
              </span>
            </template>
            <el-menu-item index="/admin">管理后台</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </div>
      <div class="user-info">
        <el-dropdown>
          <span class="user-name">
            <span class="avatar-wrapper">
              <el-avatar :size="32" :src="userAvatar" />
              <span v-if="hasUnread" class="unread-dot"></span>
            </span>
            {{ userName }}
            <el-icon><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="handleProfile"
                >个人中心</el-dropdown-item
              >
              <el-dropdown-item @click="handleLogout"
                >退出登录</el-dropdown-item
              >
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
  </el-header>
</template>

<script setup>
import { ref, onMounted, computed, watch, onUnmounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import { ElMessage } from "element-plus";
import { ArrowDown, More } from "@element-plus/icons-vue";
import { notificationApi } from "@/api/notification";
import { userApi } from "@/api/user";

const router = useRouter();
const route = useRoute();

// 计算属性
const activeMenu = computed(() => route.path);

const isLoggedIn = computed(() => {
  return !!localStorage.getItem("token");
});

const isAdmin = computed(() => {
  const userRole = localStorage.getItem("userRole");
  return userRole === "ADMIN" || userRole === "WINDOW_MANAGER";
});

const userAvatar = ref("/default-avatar.png");
const userName = ref("用户");

const updateUserInfo = async () => {
  // 首先尝试从本地存储获取
  let userInfo = JSON.parse(localStorage.getItem("userInfo") || "{}");
  
  // 如果已登录，尝试从后端获取最新信息
  if (isLoggedIn.value) {
    try {
      const res = await userApi.getCurrentUser();
      if (res && res.data) {
        userInfo = res.data;
        // 更新本地存储
        localStorage.setItem("userInfo", JSON.stringify(userInfo));
      }
    } catch (error) {
      console.error("获取最新用户信息失败", error);
    }
  }

  const avatar = userInfo.avatar;
  if (!avatar) {
    userAvatar.value = "/default-avatar.png";
  } else if (avatar.startsWith("http") || avatar.startsWith("/uploads/") || avatar.startsWith("data:image")) {
    userAvatar.value = avatar;
  } else {
    userAvatar.value = `/uploads/${avatar}`;
  }
  userName.value = userInfo.name || userInfo.username || "用户";
};

const unreadCount = ref(0);
const hasUnread = computed(() => unreadCount.value > 0);

// 处理个人中心
const handleProfile = () => {
  router.push("/profile");
};

// 处理菜单选择
const handleMenuSelect = (index) => {
  // 手动处理路由跳转，确保导航正常工作
  router.push(index);
};

// 处理退出登录
const handleLogout = () => {
  // 清除本地存储
  localStorage.removeItem("token");
  localStorage.removeItem("userInfo");
  localStorage.removeItem("userRole");
  localStorage.removeItem("cart");

  ElMessage.success("已退出登录");
  router.push("/login");
};

const loadUnreadCount = async () => {
  if (!isLoggedIn.value) {
    unreadCount.value = 0;
    return;
  }
  try {
    const res = await notificationApi.getUnreadCount();
    const val = res?.data?.count;
    unreadCount.value =
      typeof val === "number" ? val : Number(val || 0);
  } catch (e) {
    unreadCount.value = unreadCount.value || 0;
  }
};

watch(
  () => route.path,
  () => {
    loadUnreadCount();
  },
);

// 监听 storage 事件
window.addEventListener("storage", updateUserInfo);

onMounted(() => {
  loadUnreadCount();
  updateUserInfo();
});

onUnmounted(() => {
  window.removeEventListener("storage", updateUserInfo);
});
</script>

<style scoped>
.header {
  background: white;
  border-bottom: 1px solid #e6e6e6;
  padding: 0;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.logo h2 {
  color: #409eff;
  margin: 0;
}

.nav-menu {
  flex: 1;
  display: flex;
  justify-content: center;
}

.menu {
  border-bottom: none;
  width: 100%;
  justify-content: center;
}

.user-info {
  display: flex;
  align-items: center;
}

.user-name {
  cursor: pointer;
  color: #666;
  display: flex;
  align-items: center;
  gap: 8px;
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
</style>
