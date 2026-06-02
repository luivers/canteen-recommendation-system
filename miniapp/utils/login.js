const { loginByCode } = require("../api/user");
const { saveAuthState } = require("./auth");

const normalizeLoginPayload = (response) => {
  const payload = response && response.data ? response.data : response;
  if (!payload || !payload.token) {
    throw new Error("小程序登录响应缺少 token");
  }
  return {
    token: payload.token,
    user: payload.user || null,
    isNewUser: !!payload.isNewUser,
  };
};

const callWxLogin = () => {
  return new Promise((resolve, reject) => {
    wx.login({
      success: (result) => {
        if (result && result.code) {
          resolve(result.code);
          return;
        }
        reject(new Error("wx.login 未返回 code"));
      },
      fail: (error) => {
        reject(new Error(error && error.errMsg ? error.errMsg : "wx.login 调用失败"));
      },
    });
  });
};

const silentLogin = () => {
  return callWxLogin()
    .then((code) => loginByCode(code))
    .then((response) => {
      const authState = normalizeLoginPayload(response);
      saveAuthState(authState.token, authState.user);
      return authState;
    });
};

module.exports = {
  silentLogin,
  normalizeLoginPayload,
};
