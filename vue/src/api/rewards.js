import api from "./index";

export const rewardsApi = {
  getPointBalance: () => api.get("/api/points/balance"),
  getPointHistory: (params) => api.get("/api/points/history/me", { params }),

  getCategories: () => api.get("/api/rewards/categories"),
  getRewardsPage: (params) => api.get("/api/rewards/page", { params }),

  previewExchange: (rewardId) =>
    api.post("/api/rewards/exchange/preview", { rewardId }),
  exchange: (rewardId, requestId, extraData) =>
    api.post("/api/rewards/exchange", { rewardId, requestId, ...extraData }),

  getMyExchangesPage: (params) =>
    api.get("/api/rewards/exchanges/page", { params }),
  getMyVouchersPage: (params) =>
    api.get("/api/rewards/vouchers/my", { params }),
  getUsableVouchers: (amount) =>
    api.get("/api/rewards/vouchers/usable", { params: { amount } }),
  admin: {
    listCategories: () => api.get("/api/admin/vouchers/categories"),
    createCategory: (data) => api.post("/api/admin/vouchers/categories", data),
    updateCategory: (id, data) =>
      api.put(`/api/admin/vouchers/categories/${id}`, data),
    deleteCategory: (id) => api.delete(`/api/admin/vouchers/categories/${id}`),

    pageVouchers: (params) => api.get("/api/admin/vouchers/page", { params }),
    createVoucher: (data) => api.post("/api/admin/vouchers", data),
    updateVoucher: (id, data) => api.put(`/api/admin/vouchers/${id}`, data),
    deleteVoucher: (id) => api.delete(`/api/admin/vouchers/${id}`),

    pageExchanges: (params) =>
      api.get("/api/admin/voucher-exchanges/page", { params }),
    updateExchangeDelivery: (id, data) =>
      api.put(`/api/admin/voucher-exchanges/${id}/delivery`, data),
    updateExchangeStatus: (id, data) =>
      api.put(`/api/admin/voucher-exchanges/${id}/status`, data),
    getExchangeStats: (params) =>
      api.get("/api/admin/voucher-exchanges/stats", { params }),
  },
};
