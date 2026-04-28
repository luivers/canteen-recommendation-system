import axios from "axios";
import { ElMessage } from "element-plus";

// 创建axios实例
const api = axios.create({
  baseURL: "http://localhost:8089", // 基础URL，指向8089端口（与后端配置匹配）
  timeout: 15000, // 增加超时时间到15秒
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
});

// 请求拦截器
api.interceptors.request.use(
  (config) => {
    console.log(`[API请求] ${config.method?.toUpperCase()} ${config.url}`, {
      params: config.params,
      data: config.data,
    });

    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    // 防止浏览器缓存GET请求
    if (config.method === "get") {
      config.params = {
        ...config.params,
        _t: Date.now(),
      };
    }
    if (config.data instanceof FormData) {
      if (config.headers) {
        delete config.headers["Content-Type"];
        delete config.headers["content-type"];
      }
    }
    return config;
  },
  (error) => {
    console.error("[API请求错误]", error);
    return Promise.reject(error);
  },
);

// 响应拦截器
api.interceptors.response.use(
  (response) => {
    console.log(`[API响应] ${response.config.url}`, {
      status: response.status,
      data: response.data,
    });

    // 直接返回响应对象，让调用者自行处理data
    return response;
  },
  (error) => {
    const status = error?.response?.status;
    const data = error?.response?.data;
    const cfg = error?.config || {};
    console.error("[API响应错误]", {
      url: cfg?.url,
      method: cfg?.method,
      baseURL: cfg?.baseURL,
      params: cfg?.params,
      data: cfg?.data,
      status,
      response: data,
      message: error?.message,
    });

    if (error.response) {
      const { status, data } = error.response;

      switch (status) {
        case 401:
          // 用户认证失败
          if (data && data.code) {
            switch (data.code) {
              case "USER_NOT_FOUND":
                ElMessage.error("用户不存在");
                break;
              case "INVALID_PASSWORD":
                ElMessage.error("密码错误");
                break;
              case "LOGIN_FAILED":
                ElMessage.error(data.message || "登录失败");
                break;
              default:
                ElMessage.error("登录失败，请检查学号和密码");
            }
          } else {
            ElMessage.error("登录失败，请检查学号和密码");
          }
          // 清除token
          localStorage.removeItem("token");
          // 只有不在登录页时才重定向到登录页
          // 如果当前已经在登录页，不要强制刷新，让用户可以重新输入
          if (!window.location.pathname.includes('/login')) {
            window.location.href = "/login";
          }
          break;
        case 403:
          // 权限不足
          if (data && data.code === "INSUFFICIENT_PERMISSIONS") {
            ElMessage.error("权限不足，无法访问该系统");
          } else {
            ElMessage.error("权限不足");
          }
          break;
        case 404:
          ElMessage.error("请求的资源不存在");
          break;
        case 500:
          ElMessage.error("服务器内部错误，请稍后重试");
          break;
        default:
          ElMessage.error(
            data?.message ||
              data?.error ||
              error.message ||
              `请求失败 (${status})`,
          );
      }
    } else if (error.request) {
      // 请求发送失败
      ElMessage.error("网络连接失败，请检查您的网络");
    } else {
      // 其他错误
      ElMessage.error(error.message || "请求失败");
    }
    return Promise.reject(error);
  },
);

export default api;
