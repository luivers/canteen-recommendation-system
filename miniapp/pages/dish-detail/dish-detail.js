const { dishApi } = require("../../api/index");
const { normalizeDish } = require("../../utils/dish");

Page({
  data: {
    id: "",
    dish: null,
    loading: false,
    errorMessage: "",
  },

  onLoad(options = {}) {
    if (!options.id) {
      this.setData({ errorMessage: "缺少菜品 ID" });
      return;
    }

    this.setData({ id: options.id });
    this.loadDish(options.id);
  },

  loadDish(id) {
    this.setData({ loading: true, errorMessage: "" });
    dishApi
      .getDish(id)
      .then((response) => {
        this.setData({ dish: normalizeDish(response) });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "菜品详情加载失败",
        });
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  reload() {
    if (!this.data.id) return;
    this.loadDish(this.data.id);
  },
});
