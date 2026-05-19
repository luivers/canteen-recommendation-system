import { defineStore } from "pinia";
import { computed, ref } from "vue";

const ADMIN_ROLES = ["ADMIN", "WINDOW_MANAGER"];

const normalizeLoginData = (loginData = {}) => {
  const rawToken = loginData.token || "";
  const rawUser = loginData.user || loginData;
  const { token: _token, user: _user, ...user } = rawUser || {};
  return {
    token: rawToken || rawUser?.token || "",
    user,
  };
};

export const useUserStore = defineStore("user", () => {
  const userInfo = ref(null);
  const token = ref("");
  const role = ref("");
  const isLoggedIn = ref(false);

  const currentRole = computed(() => role.value || userInfo.value?.role || "");
  const isAuthenticated = computed(() => Boolean(token.value && userInfo.value));
  const isAdmin = computed(() => currentRole.value === "ADMIN");
  const isManager = computed(() => currentRole.value === "WINDOW_MANAGER");
  const canAccessAdmin = computed(() => ADMIN_ROLES.includes(currentRole.value));
  const hasAnyRole = (roles = []) => {
    return Array.isArray(roles) && roles.includes(currentRole.value);
  };

  const persistUserState = () => {
    localStorage.setItem("token", token.value);
    localStorage.setItem("userInfo", JSON.stringify(userInfo.value));
    localStorage.setItem("userRole", currentRole.value);
    if (userInfo.value?.id !== undefined && userInfo.value?.id !== null) {
      localStorage.setItem("userId", userInfo.value.id);
    }
  };

  // 登录
  const login = (loginData) => {
    const normalized = normalizeLoginData(loginData);
    if (!normalized.token) {
      throw new Error("登录响应缺少 token");
    }

    userInfo.value = normalized.user;
    token.value = normalized.token;
    role.value = normalized.user?.role || "";
    isLoggedIn.value = true;
    persistUserState();
  };

  // 登出
  const logout = () => {
    userInfo.value = null;
    token.value = "";
    role.value = "";
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
    const storedRole = localStorage.getItem("userRole") || "";

    if (!storedToken || !storedUserInfo) {
      token.value = "";
      userInfo.value = null;
      role.value = "";
      isLoggedIn.value = false;
      if (storedToken || storedUserInfo || storedRole) {
        logout();
      }
      return false;
    }

    try {
      const parsedUserInfo = JSON.parse(storedUserInfo);
      token.value = storedToken;
      userInfo.value = parsedUserInfo;
      role.value = parsedUserInfo?.role || storedRole;
      isLoggedIn.value = true;
      return true;
    } catch (error) {
      console.error("恢复登录状态失败:", error);
      logout();
      return false;
    }
  };

  // 更新用户信息
  const updateUserInfo = (newInfo) => {
    userInfo.value = { ...userInfo.value, ...newInfo };
    role.value = userInfo.value?.role || role.value;
    localStorage.setItem("userInfo", JSON.stringify(userInfo.value));
    if (currentRole.value) {
      localStorage.setItem("userRole", currentRole.value);
    }
  };

  // 获取用户角色
  const getUserRole = () => {
    return currentRole.value;
  };

  return {
    userInfo,
    token,
    role,
    isLoggedIn,
    isAuthenticated,
    currentRole,
    isAdmin,
    isManager,
    canAccessAdmin,
    hasAnyRole,
    login,
    logout,
    checkLoginStatus,
    updateUserInfo,
    getUserRole,
  };
});
