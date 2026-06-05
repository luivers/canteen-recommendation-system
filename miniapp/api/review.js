const { get, buildUrl } = require("../utils/request");
const { getAuthHeader } = require("../utils/auth");
const { normalizePage, normalizeReview, toArray, unwrapData } = require("../utils/engagement");

const boundary = "----canteen-miniapp-review-boundary";

const buildMultipartBody = (review) => {
  const json = JSON.stringify(review || {});
  return [
    `--${boundary}`,
    'Content-Disposition: form-data; name="review"',
    "Content-Type: application/json; charset=UTF-8",
    "",
    json,
    `--${boundary}--`,
    "",
  ].join("\r\n");
};

const requestMultipartReview = (review) => {
  return new Promise((resolve, reject) => {
    wx.request({
      url: buildUrl("/api/reviews"),
      method: "POST",
      data: buildMultipartBody(review),
      header: {
        ...getAuthHeader(),
        "Content-Type": `multipart/form-data; boundary=${boundary}`,
      },
      timeout: 15000,
      success: (response) => {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          resolve(response.data);
          return;
        }
        reject({
          statusCode: response.statusCode,
          data: response.data,
          message: response.data && (response.data.message || response.data.error || response.data.code) || "评价提交失败",
        });
      },
      fail: (error) => {
        reject({
          statusCode: 0,
          original: error,
          message: error && error.errMsg ? error.errMsg : "网络连接失败",
        });
      },
    });
  });
};

const createReview = (payload = {}) => {
  const review = {
    orderId: payload.orderId,
    tasteRating: payload.tasteRating || payload.rating || 5,
    portionRating: payload.portionRating || payload.rating || 5,
    priceRating: payload.priceRating || payload.rating || 5,
    hygieneRating: payload.hygieneRating || payload.rating || 5,
    comment: payload.comment || payload.content || "",
    quickTags: toArray(payload.quickTags || payload.tags),
    items: toArray(payload.items),
  };

  return requestMultipartReview(review);
};

const getOrderReview = (orderId) => get(`/api/reviews/order/${orderId}`).then((response) => {
  const data = unwrapData(response);
  return data ? normalizeReview(data) : null;
});

const getUserReviews = (userId) => get(`/api/reviews/user/${userId}`).then((response) => (
  toArray(unwrapData(response)).map(normalizeReview)
));

const getReviews = (params = {}) => {
  const page = params.page || 0;
  const size = params.size || 20;
  return get("/api/reviews", { page, size, ...params }).then((response) => (
    normalizePage(response, normalizeReview, page, size)
  ));
};

module.exports = {
  createReview,
  getOrderReview,
  getReviews,
  getUserReviews,
};
