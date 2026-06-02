const { dishApi, orderApi } = require("../../api/index");
const {
  normalizeCategories,
  normalizeDishPage,
} = require("../../utils/dish");

Page({
  data: {
    keyword: "",
    activeCategory: "",
    activeCategoryLabel: "",
    categories: [{ value: "", label: "全部" }],
    dishes: [],
    page: 0,
    size: 10,
    totalElements: 0,
    totalPages: 0,
    hasMore: false,
    loading: false,
    loadingMore: false,
    errorMessage: "",
  },

  onLoad(options = {}) {
    const keyword = options.keyword || "";
    this.setData({ keyword });
    this.loadCategories();
    this.loadDishes(true);
  },

  onPullDownRefresh() {
    this.loadCategories();
    this.loadDishes(true).finally(() => {
      wx.stopPullDownRefresh();
    });
  },

  onReachBottom() {
    if (!this.data.hasMore || this.data.loading || this.data.loadingMore) return;
    this.loadDishes(false);
  },

  loadCategories() {
    dishApi
      .getCategories()
      .then((response) => {
        const categories = normalizeCategories(response);
        this.setData({
          categories: [{ value: "", label: "全部" }].concat(categories),
        });
      })
      .catch(() => {
        this.setData({
          categories: [{ value: "", label: "全部" }],
        });
      });
  },

  loadDishes(reset) {
    const page = reset ? 0 : this.data.page + 1;
    const params = {
      page,
      size: this.data.size,
    };
    const keyword = this.data.keyword.trim();

    if (this.data.activeCategory) {
      params.category = this.data.activeCategory;
    }

    this.setData({
      loading: reset,
      loadingMore: !reset,
      errorMessage: "",
    });

    const request = keyword
      ? dishApi.searchDishes(keyword, params)
      : dishApi.getDishes(params);

    return request
      .then((response) => {
        const pageData = normalizeDishPage(response, page, this.data.size);
        this.setData({
          dishes: reset ? pageData.items : this.data.dishes.concat(pageData.items),
          page: pageData.page,
          totalElements: pageData.totalElements,
          totalPages: pageData.totalPages,
          hasMore: pageData.hasMore,
          errorMessage: pageData.items.length || !reset ? "" : "没有找到符合条件的菜品",
        });
      })
      .catch((error) => {
        this.setData({
          errorMessage: error.message || "菜品加载失败",
          hasMore: false,
        });
      })
      .finally(() => {
        this.setData({
          loading: false,
          loadingMore: false,
        });
      });
  },

  onKeywordInput(event) {
    this.setData({ keyword: event.detail.value });
  },

  submitSearch() {
    this.loadDishes(true);
  },

  clearSearch() {
    this.setData({ keyword: "" });
    this.loadDishes(true);
  },

  selectCategory(event) {
    const value = event.currentTarget.dataset.value || "";
    const label = event.currentTarget.dataset.label || "";
    if (value === this.data.activeCategory) return;
    this.setData({
      activeCategory: value,
      activeCategoryLabel: label,
    });
    this.loadDishes(true);
  },

  openDish(event) {
    const id = event.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/dish-detail/dish-detail?id=${id}` });
  },

  addToCart(event) {
    const id = event.currentTarget.dataset.id;
    if (!id) return;

    orderApi
      .addToCart({ dishId: id, quantity: 1 })
      .then(() => {
        wx.showToast({
          title: "已加入购物车",
          icon: "success",
        });
      })
      .catch((error) => {
        wx.showToast({
          title: error.message || "加购失败",
          icon: "none",
        });
      });
  },
});
