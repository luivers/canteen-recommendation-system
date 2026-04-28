import api from "./index";

export const userApi = {
  // 用户注册
  register: (userData) => {
    return api.post("/api/users/register", userData);
  },

  // 用户登录
  login: (credentials) => {
    return api.post("/api/users/login", credentials);
  },

  // 获取当前用户信息
  getCurrentUser: () => {
    return api.get("/api/users/me");
  },

  // 创建用户（管理员）
  createUser: (userData) => {
    return api.post("/api/users", userData);
  },

  // 更新用户信息
  updateUser: (userId, userData) => {
    return api.put(`/api/users/${userId}`, userData);
  },

  // 更新口味偏好
  updatePreferences: (userId, preferences) => {
    return api.put(`/api/users/${userId}/preferences`, preferences);
  },

  // 获取所有可用的饮食标签
  getDietaryTags: () => {
    return api.get("/api/users/dietary-tags");
  },

  // 获取用户列表（管理员）
  getUsers: (params) => {
    return api.get("/api/users", { params });
  },

  // 删除用户（管理员）
  deleteUser: (userId) => {
    return api.delete(`/api/users/${userId}`);
  },

  // 重置用户密码（管理员）
  resetPassword: (userId, newPassword) => {
    return api.put(`/api/users/${userId}/reset-password`, { newPassword });
  },

  // 修改当前用户密码
  changePassword: (userId, passwordData) => {
    return api.put(`/api/users/${userId}/change-password`, passwordData);
  },

  // 更新用户状态（管理员）
  updateUserStatus: (userId, status) => {
    return api.put(`/api/users/${userId}/status`, { status });
  },
};
