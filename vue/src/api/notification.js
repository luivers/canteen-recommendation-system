import api from "./index";

// 通知相关API
export const notificationApi = {
  /**
   * 获取当前用户的通知列表
   */
  getUserNotifications(params) {
    return api.get("/api/notifications", { params });
  },

  /**
   * 获取未读通知数量
   */
  getUnreadCount() {
    return api.get("/api/notifications/unread-count");
  },

  /**
   * 标记通知为已读
   */
  markAsRead(id) {
    return api.put(`/api/notifications/${id}/read`);
  },

  /**
   * 标记所有通知为已读
   */
  markAllAsRead() {
    return api.put("/api/notifications/read-all");
  },

  /**
   * 删除已读通知
   */
  deleteReadNotifications() {
    return api.delete("/api/notifications/read");
  },

  /**
   * 发布系统公告（管理员）
   */
  createAnnouncement(data) {
    return api.post("/api/admin/announcements", data);
  },

  /**
   * 获取公开系统公告（用于首页通知栏）
   */
  getPublicAnnouncements() {
    return api.get("/api/announcements");
  },
  admin: {
    listAnnouncements(params) {
      return api.get("/api/admin/announcements", { params });
    },
    updateAnnouncement(id, data) {
      return api.put(`/api/admin/announcements/${id}`, data);
    },
    deleteAnnouncement(id) {
      return api.delete(`/api/admin/announcements/${id}`);
    },
    getWarnings(params) {
      return api.get("/api/notifications/admin/warnings", { params });
    },
    getWarningUnreadCount() {
      return api.get("/api/notifications/admin/warnings/unread-count");
    },
    markAllWarningsAsRead() {
      return api.put("/api/notifications/admin/warnings/read-all");
    },
  },
};
