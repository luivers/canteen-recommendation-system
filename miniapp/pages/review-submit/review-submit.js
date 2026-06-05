const { orderApi, reviewApi } = require("../../api/index");
const { normalizeOrder } = require("../../utils/order");

const RATING_OPTIONS = [1, 2, 3, 4, 5];
const QUICK_TAGS = ["味道不错", "分量足", "价格合适", "干净卫生", "出餐快", "包装完整"];

const buildRatingGroups = (form) => ([
  { field: "tasteRating", label: "口味", value: form.tasteRating },
  { field: "portionRating", label: "分量", value: form.portionRating },
  { field: "priceRating", label: "价格", value: form.priceRating },
  { field: "hygieneRating", label: "卫生", value: form.hygieneRating },
]);

const buildTagOptions = (selectedTags) => QUICK_TAGS.map((label) => ({
  label,
  selected: selectedTags.includes(label),
}));

Page({
  data: {
    id: "",
    order: null,
    existingReview: null,
    loading: false,
    submitting: false,
    errorMessage: "",
    ratingOptions: RATING_OPTIONS,
    tagOptions: buildTagOptions([]),
    ratingGroups: buildRatingGroups({
      tasteRating: 5,
      portionRating: 5,
      priceRating: 5,
      hygieneRating: 5,
    }),
    selectedTags: [],
    images: [],
    form: {
      rating: 5,
      tasteRating: 5,
      portionRating: 5,
      priceRating: 5,
      hygieneRating: 5,
      comment: "",
    },
  },

  onLoad(options = {}) {
    if (!options.id) {
      this.setData({ errorMessage: "缺少订单 ID" });
      return;
    }
    this.setData({ id: options.id });
    this.loadData();
  },

  onPullDownRefresh() {
    this.loadData().finally(() => wx.stopPullDownRefresh());
  },

  loadData() {
    this.setData({ loading: true, errorMessage: "" });
    return Promise.all([
      orderApi.getOrder(this.data.id).then(normalizeOrder),
      reviewApi.getOrderReview(this.data.id).catch(() => null),
    ])
      .then(([order, existingReview]) => {
        this.setData({ order, existingReview: existingReview && existingReview.id ? existingReview : null });
      })
      .catch((error) => {
        this.setData({ errorMessage: error.message || "评价信息加载失败" });
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  setRating(event) {
    const field = event.currentTarget.dataset.field;
    const value = Number(event.currentTarget.dataset.value);
    if (!field || !value) return;

    const nextForm = { ...this.data.form, [field]: value };
    if (field === "rating") {
      nextForm.tasteRating = value;
      nextForm.portionRating = value;
      nextForm.priceRating = value;
      nextForm.hygieneRating = value;
    }
    this.setData({
      form: nextForm,
      ratingGroups: buildRatingGroups(nextForm),
    });
  },

  onCommentInput(event) {
    this.setData({
      form: {
        ...this.data.form,
        comment: event.detail.value || "",
      },
    });
  },

  toggleTag(event) {
    const tag = event.currentTarget.dataset.tag;
    if (!tag) return;
    const selected = this.data.selectedTags.includes(tag)
      ? this.data.selectedTags.filter((item) => item !== tag)
      : this.data.selectedTags.concat(tag);
    this.setData({
      selectedTags: selected,
      tagOptions: buildTagOptions(selected),
    });
  },

  chooseImages() {
    const remain = 3 - this.data.images.length;
    if (remain <= 0) return;

    const applyFiles = (files = []) => {
      const paths = files.map((file) => file.tempFilePath || file.path).filter(Boolean);
      this.setData({ images: this.data.images.concat(paths).slice(0, 3) });
    };

    if (wx.chooseMedia) {
      wx.chooseMedia({
        count: remain,
        mediaType: ["image"],
        sourceType: ["album", "camera"],
        success: (result) => applyFiles(result.tempFiles || []),
      });
      return;
    }

    wx.chooseImage({
      count: remain,
      sourceType: ["album", "camera"],
      success: (result) => applyFiles(result.tempFilePaths || []),
    });
  },

  removeImage(event) {
    const index = Number(event.currentTarget.dataset.index);
    this.setData({
      images: this.data.images.filter((_, itemIndex) => itemIndex !== index),
    });
  },

  submitReview() {
    if (this.data.submitting || this.data.existingReview) return;
    const order = this.data.order;
    if (!order || !order.id) return;
    const items = (order.items || [])
      .filter((item) => item.dishId)
      .map((item) => ({ dishId: item.dishId, rating: this.data.form.rating }));

    if (!items.length) {
      wx.showToast({ title: "缺少可评价菜品", icon: "none" });
      return;
    }

    this.setData({ submitting: true });
    reviewApi
      .createReview({
        orderId: order.id,
        ...this.data.form,
        quickTags: this.data.selectedTags,
        items,
        images: this.data.images,
      })
      .then(() => {
        wx.showToast({ title: "评价成功", icon: "success" });
        return this.loadData();
      })
      .catch((error) => {
        wx.showToast({
          title: error.message || "评价提交失败",
          icon: "none",
        });
      })
      .finally(() => {
        this.setData({ submitting: false });
      });
  },
});
