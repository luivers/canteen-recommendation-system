import { createApp } from "vue";
import { createPinia } from "pinia";
import ElementPlus from "element-plus";
import "element-plus/dist/index.css";
import zhCn from "element-plus/es/locale/lang/zh-cn";
import * as ElementPlusIconsVue from "@element-plus/icons-vue";
import App from "./App.vue";
import router from "./router";
import { useUserStore } from "./stores/user";

const app = createApp(App);

// 注册Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component);
}

app.use(createPinia());
app.use(router);
app.use(ElementPlus, { locale: zhCn });

// 挂载应用前检查登录状态
app.mount("#app");

// 使用setTimeout确保Pinia已完全初始化
setTimeout(() => {
  const userStore = useUserStore();
  userStore.checkLoginStatus();
}, 0);

// 全局缓存清理函数
window.clearAppCache = function() {
  try {
    // 清理localStorage中非必要数据（保留登录信息）
    const essentialKeys = ['token', 'userInfo', 'userRole', 'userId'];
    const keysToRemove = [];

    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && !essentialKeys.includes(key)) {
        keysToRemove.push(key);
      }
    }

    keysToRemove.forEach(key => localStorage.removeItem(key));

    // 清理sessionStorage
    sessionStorage.clear();

    // 强制垃圾回收提示（开发者工具）
    if (window.gc) {
      window.gc();
    }

    console.log('缓存已清理，移除了', keysToRemove.length, '个非必要数据项');
    return true;
  } catch (e) {
    console.error('清理缓存失败:', e);
    return false;
  }
};

// 内存监控 - 当内存使用过高时警告
if (window.performance && window.performance.memory) {
  setInterval(() => {
    const memory = window.performance.memory;
    const usedMB = Math.round(memory.usedJSHeapSize / 1048576);
    const limitMB = Math.round(memory.jsHeapSizeLimit / 1048576);
    const usagePercent = Math.round((usedMB / limitMB) * 100);

    // 如果内存使用超过80%，警告并建议刷新
    if (usagePercent > 80) {
      console.warn(`内存使用过高: ${usedMB}MB / ${limitMB}MB (${usagePercent}%)，建议刷新页面`);
    }
  }, 60000); // 每分钟检查一次
}
