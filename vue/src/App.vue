<template>
  <div id="app">
    <el-config-provider :locale="zhCn">
      <!-- 管理员布局 -->
      <div v-if="isAdminRoute" class="admin-layout">
        <!-- 管理员顶部导航栏 -->
        <AdminNavBar />
        <!-- 管理员主内容区域 -->
        <el-main class="admin-main">
          <router-view />
        </el-main>
      </div>
      <!-- 普通用户布局 -->
      <div v-else-if="isUserRoute" class="user-layout">
        <!-- 普通用户顶部导航栏 -->
        <UserNavBar />
        <!-- 普通用户主内容区域 -->
        <el-main class="user-main">
          <router-view />
        </el-main>
      </div>
      <!-- 登录注册页面直接使用router-view -->
      <template v-else>
        <router-view />
      </template>
    </el-config-provider>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { useRouter, useRoute } from "vue-router";
import {
  ElConfigProvider,
  ElMessage,
  ElMessageBox,
  ElMain,
} from "element-plus";
import zhCn from "element-plus/es/locale/lang/zh-cn";
import {
  HomeFilled,
  Dish,
  ShoppingCart,
  Document,
  User,
  Setting,
  SwitchButton,
  ArrowDown,
  Food,
  More,
} from "@element-plus/icons-vue";
import AdminNavBar from "./components/AdminNavBar.vue";
import UserNavBar from "./components/UserNavBar.vue";

const router = useRouter();
const route = useRoute();

// 响应式数据
const cartCount = ref(0);
const userAvatar = ref("");
const userName = ref("");

// 计算属性
const isLoggedIn = computed(() => {
  return !!localStorage.getItem("token");
});

const isAdminRoute = computed(() => {
  return route.path.startsWith("/admin");
});

const isUserRoute = computed(() => {
  const publicRoutes = ["/login", "/register"];
  return !isAdminRoute.value && !publicRoutes.includes(route.path);
});

const isAdmin = computed(() => {
  const userRole = localStorage.getItem("userRole");
  return userRole === "ADMIN" || userRole === "WINDOW_MANAGER";
});

const activeMenu = computed(() => {
  return route.path;
});

// 监听路由变化
watch(
  () => route.path,
  (newPath) => {
    // 更新用户信息
    updateUserInfo();
    // 更新购物车数量
    updateCartCount();
  },
);

// 更新用户信息
const updateUserInfo = () => {
  const userInfo = JSON.parse(localStorage.getItem("userInfo") || "{}");
  userAvatar.value = userInfo.avatar || "/default-avatar.png";
  userName.value = userInfo.name || "用户";
};

// 更新购物车数量
const updateCartCount = () => {
  // 模拟获取购物车数量
  const cart = JSON.parse(localStorage.getItem("cart") || "[]");
  cartCount.value = cart.length;
};

// 菜单选择处理
const handleMenuSelect = (index) => {
  router.push(index);
};

// 详情按钮命令处理
const handleMoreCommand = (command) => {
  if (command === "admin") {
    // 跳转到管理后台
    router.push("/admin");
  } else if (command.startsWith("/")) {
    // 跳转到指定路由
    router.push(command);
  }
};

// 用户命令处理
const handleUserCommand = async (command) => {
  switch (command) {
    case "profile":
      // 跳转到个人中心
      ElMessage.info("个人中心功能开发中");
      break;
    case "settings":
      // 跳转到设置页面
      ElMessage.info("设置功能开发中");
      break;
    case "logout":
      // 退出登录
      await handleLogout();
      break;
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

    // 清除本地存储
    localStorage.removeItem("token");
    localStorage.removeItem("userInfo");
    localStorage.removeItem("userRole");
    localStorage.removeItem("cart");
    localStorage.removeItem("userId");

    // 清理sessionStorage
    sessionStorage.clear();

    // 调用全局缓存清理（如果可用）
    if (window.clearAppCache) {
      window.clearAppCache();
    }

    // 跳转到登录页
    router.push("/login");

    ElMessage.success("退出登录成功");
  } catch (error) {
    // 用户取消操作
  }
};

// 初始化
onMounted(() => {
  updateUserInfo();
  updateCartCount();

  // 监听本地存储变化（用于购物车数量更新）
  window.addEventListener("storage", updateCartCount);
});
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

:root {
  --dish-image-size: 160px;
}

#app {
  font-family:
    "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB",
    "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100vh;
}

/* 管理员布局样式 */
.admin-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100%;
}

.admin-main {
  flex: 1;
  padding: 20px;
  margin: 0;
  background-color: #f5f7fa;
  overflow-y: auto;
  width: 100%;
}

/* 普通用户布局样式 */
.user-layout {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100%;
}

.user-main {
  flex: 1;
  margin: 0;
  padding: 0;
  overflow-y: auto;
  width: 100%;
}
</style>
