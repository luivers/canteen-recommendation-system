import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { resolve } from "path";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "src"),
    },
  },
  server: {
    port: 3000,
    proxy: {
      "/api": {
        target: "http://127.0.0.1:8089",
        changeOrigin: true,
        secure: false,
        timeout: 60000, // 增加超时时间到60秒
        proxyTimeout: 60000,
        configure: (proxy) => {
          proxy.on('error', (err) => {
            console.log('代理错误:', err);
          });
        }
      },
      "/uploads": {
        target: "http://127.0.0.1:8089",
        changeOrigin: true,
        secure: false,
        timeout: 60000,
      },
    },
    open: true,
  },
  build: {
    outDir: "dist",
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes("node_modules/axios")) {
            return "utils";
          }
          if (
            id.includes("node_modules/echarts") ||
            id.includes("node_modules/zrender") ||
            id.includes("node_modules/echarts-wordcloud")
          ) {
            return "charts";
          }
          if (
            id.includes("node_modules/vue") ||
            id.includes("node_modules/element-plus")
          ) {
            return "vendor";
          }
        },
      },
    },
  },
  css: {
    devSourcemap: true,
  },
});
