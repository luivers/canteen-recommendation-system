const { apiBaseUrl } = require("../config/env");
const { clearToken, getAuthHeader } = require("./auth");

const normalizePath = (url) => {
  if (!url) return "/";
  if (url.startsWith("http://") || url.startsWith("https://")) return url;
  return url.startsWith("/") ? url : `/${url}`;
};

const buildUrl = (url) => {
  const normalizedUrl = normalizePath(url);
  if (normalizedUrl.startsWith("http://") || normalizedUrl.startsWith("https://")) {
    return normalizedUrl;
  }
  return `${apiBaseUrl.replace(/\/+$/, "")}${normalizedUrl}`;
};

const resolveErrorMessage = (data, fallback) => {
  if (!data) return fallback;
  if (typeof data === "string") return data;
  return data.message || data.error || data.code || fallback;
};

const request = (options = {}) => {
  return new Promise((resolve, reject) => {
    if (!options.url) {
      reject({
        statusCode: 0,
        message: "request url is required",
      });
      return;
    }

    const method = (options.method || "GET").toUpperCase();
    const header = Object.assign(
      {
        "Content-Type": "application/json",
      },
      getAuthHeader(),
      options.header || {},
    );

    wx.request({
      url: buildUrl(options.url),
      method,
      data: options.data || {},
      header,
      timeout: options.timeout || 15000,
      success: (response) => {
        const statusCode = response.statusCode;
        const data = response.data;

        if (statusCode >= 200 && statusCode < 300) {
          resolve(data);
          return;
        }

        if (statusCode === 401) {
          clearToken();
        }

        reject({
          statusCode,
          data,
          message: resolveErrorMessage(data, `请求失败 (${statusCode})`),
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

const get = (url, data = {}, options = {}) => request({ ...options, url, data, method: "GET" });
const post = (url, data = {}, options = {}) => request({ ...options, url, data, method: "POST" });
const put = (url, data = {}, options = {}) => request({ ...options, url, data, method: "PUT" });
const del = (url, data = {}, options = {}) => request({ ...options, url, data, method: "DELETE" });

module.exports = {
  request,
  get,
  post,
  put,
  delete: del,
  buildUrl,
};
