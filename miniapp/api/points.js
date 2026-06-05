const { get } = require("../utils/request");
const { normalizePage, normalizePointBalance, normalizePointLog } = require("../utils/engagement");

const getBalance = () => get("/api/points/balance").then(normalizePointBalance);

const getMyHistory = (params = {}) => {
  const page = params.page || 0;
  const size = params.size || 20;
  return get("/api/points/history/me", { page, size }).then((response) => (
    normalizePage(response, normalizePointLog, page, size)
  ));
};

module.exports = {
  getBalance,
  getMyHistory,
};
