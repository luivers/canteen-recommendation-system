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
        manualChunks: {
          vendor: ["vue", "element-plus"],
          utils: ["axios"],
        },
      },
    },
  },
  css: {
    devSourcemap: true,
  },
});
