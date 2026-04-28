import api from "./index";

const canteenApi = {
  // 获取所有食堂
  getAll() {
    return api.get("/api/canteens");
  },

  // 获取单个食堂详情
  getById(id) {
    return api.get(`/api/canteens/${id}`);
  },

  // 创建食堂
  create(canteen) {
    return api.post("/api/canteens", canteen);
  },

  // 更新食堂
  update(id, canteen) {
    return api.put(`/api/canteens/${id}`, canteen);
  },

  // 删除食堂
  delete(id) {
    return api.delete(`/api/canteens/${id}`);
  },
};

export default canteenApi;
