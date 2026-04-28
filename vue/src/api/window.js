import api from "./index";

// 窗口管理相关API
export const windowApi = {
  /**
   * 获取所有窗口
   */
  getAllWindows() {
    return api.get("/api/windows");
  },

  /**
   * 根据ID获取窗口
   */
  getWindowById(id) {
    return api.get(`/api/windows/${id}`);
  },

  /**
   * 创建窗口
   */
  createWindow(windowData) {
    return api.post("/api/windows", windowData);
  },

  /**
   * 更新窗口
   */
  updateWindow(id, windowData) {
    return api.put(`/api/windows/${id}`, windowData);
  },

  /**
   * 删除窗口
   */
  deleteWindow(id) {
    return api.delete(`/api/windows/${id}`);
  },

  /**
   * 根据食堂ID获取窗口
   */
  getWindowsByCanteenId(canteenId) {
    return api.get(`/api/windows/canteen/${canteenId}`);
  },

  /**
   * 根据状态获取窗口
   */
  getWindowsByStatus(status) {
    return api.get(`/api/windows/status/${status}`);
  },

  /**
   * 获取所有食堂
   */
  getCanteens() {
    return api.get("/api/windows/canteens");
  },

  /**
   * 从菜品数据同步窗口
   */
  syncWindowsFromDishes() {
    return api.post("/api/windows/sync");
  },
};
