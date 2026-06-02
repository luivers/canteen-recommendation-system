const { get } = require("../utils/request");

const getDishes = (params = {}) => get("/api/dishes", params);
const getDish = (dishId) => get(`/api/dishes/${dishId}`);
const getCategories = () => get("/api/dishes/categories");
const getHotDishes = (limit = 10) => get("/api/dishes/hot", { limit });
const searchDishes = (keyword, params = {}) => get("/api/dishes/search", { keyword, ...params });

module.exports = {
  getDishes,
  getDish,
  getCategories,
  getHotDishes,
  searchDishes,
};
