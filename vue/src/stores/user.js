import { defineStore } from "pinia";
import { ref } from "vue";

export const useUserStore = defineStore("user", () => {
  const userInfo = ref(null);
  const token = ref("");
  const isLoggedIn = ref(false);

  // 登录
  const login = (userData) => {
    userInfo.value = userData;
    token.value = userData.token;
    isLoggedIn.value = true;

    // 存储到localStorage
    localStorage.setItem("token", userData.token);
    localStorage.setItem("userInfo", JSON.stringify(userData));
    localStorage.setItem("userRole", userData.role);
    localStorage.setItem("userId", userData.id); // 单独存储userId，方便其他组件使用
  };

  // 登出
  const logout = () => {
    userInfo.value = null;
    token.value = "";
    isLoggedIn.value = false;

    // 清除localStorage中的用户相关数据
    localStorage.removeItem("token");
    localStorage.removeItem("userInfo");
    localStorage.removeItem("userRole");
    localStorage.removeItem("userId");
    localStorage.removeItem("cart");

    // 清理sessionStorage
    sessionStorage.clear();
  };

  // 检查登录状态
  const checkLoginStatus = () => {
    const storedToken = localStorage.getItem("token");
    const storedUserInfo = localStorage.getItem("userInfo");

    if (storedToken && storedUserInfo) {
      token.value = storedToken;
      userInfo.value = JSON.parse(storedUserInfo);
      isLoggedIn.value = true;
    }
  };

  // 更新用户信息
  const updateUserInfo = (newInfo) => {
    userInfo.value = { ...userInfo.value, ...newInfo };
    localStorage.setItem("userInfo", JSON.stringify(userInfo.value));
  };

  // 获取用户角色
  const getUserRole = () => {
    return userInfo.value?.role || localStorage.getItem("userRole");
  };

  // 检查是否是管理员
  const isAdmin = () => {
    const role = getUserRole();
    return role === "ADMIN";
  };

  return {
    userInfo,
    token,
    isLoggedIn,
    login,
    logout,
    checkLoginStatus,
    updateUserInfo,
    getUserRole,
    isAdmin,
  };
});
