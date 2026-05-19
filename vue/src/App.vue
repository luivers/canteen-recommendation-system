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
import { computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import { ElConfigProvider, ElMain } from "element-plus";
import zhCn from "element-plus/es/locale/lang/zh-cn";
import AdminNavBar from "./components/AdminNavBar.vue";
import UserNavBar from "./components/UserNavBar.vue";
import { useUserStore } from "@/stores/user";

const route = useRoute();
const userStore = useUserStore();

const isAdminRoute = computed(() => {
  return route.path.startsWith("/admin");
});

const isUserRoute = computed(() => {
  const publicRoutes = ["/login", "/register"];
  return !isAdminRoute.value && !publicRoutes.includes(route.path);
});

// 初始化
onMounted(() => {
  userStore.checkLoginStatus();
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
