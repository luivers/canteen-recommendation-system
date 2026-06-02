const memoryStorage = {};

const canUseWxStorage = () => {
  return typeof wx !== "undefined" && wx && typeof wx.getStorageSync === "function";
};

const get = (key, fallback = "") => {
  try {
    if (canUseWxStorage()) {
      const value = wx.getStorageSync(key);
      return value === undefined || value === null ? fallback : value;
    }
    return Object.prototype.hasOwnProperty.call(memoryStorage, key)
      ? memoryStorage[key]
      : fallback;
  } catch (error) {
    return fallback;
  }
};

const set = (key, value) => {
  if (canUseWxStorage()) {
    wx.setStorageSync(key, value);
    return;
  }
  memoryStorage[key] = value;
};

const remove = (key) => {
  if (canUseWxStorage()) {
    wx.removeStorageSync(key);
    return;
  }
  delete memoryStorage[key];
};

module.exports = {
  get,
  set,
  remove,
};
