const { get, post } = require("../utils/request");
const {
  normalizeExchange,
  normalizeExchangePreview,
  normalizePage,
  normalizeReward,
  normalizeRewardCategory,
  toArray,
  unwrapData,
} = require("../utils/engagement");

const getCategories = () => get("/api/rewards/categories").then((response) => (
  toArray(unwrapData(response)).map(normalizeRewardCategory)
));

const getRewardsPage = (params = {}, currentPoints = 0) => {
  const page = params.page || 0;
  const size = params.size || 20;
  return get("/api/rewards/page", { page, size, ...params }).then((response) => (
    normalizePage(response, (item) => normalizeReward(item, currentPoints), page, size)
  ));
};

const previewExchange = (rewardId) => post("/api/rewards/exchange/preview", { rewardId }).then(normalizeExchangePreview);

const exchangeReward = (payload = {}) => post("/api/rewards/exchange", payload).then((response) => (
  normalizeExchange(unwrapData(response))
));

const getMyExchangesPage = (params = {}) => {
  const page = params.page || 0;
  const size = params.size || 20;
  return get("/api/rewards/exchanges/page", { page, size, ...params }).then((response) => (
    normalizePage(response, normalizeExchange, page, size)
  ));
};

const getMyVouchersPage = (params = {}) => {
  const page = params.page || 0;
  const size = params.size || 20;
  return get("/api/rewards/vouchers/my", { page, size, ...params }).then((response) => (
    normalizePage(response, normalizeExchange, page, size)
  ));
};

module.exports = {
  exchangeReward,
  getCategories,
  getMyExchangesPage,
  getMyVouchersPage,
  getRewardsPage,
  previewExchange,
};
