const profiles = {
  local: {
    apiBaseUrl: "http://localhost:8089",
  },
  dev: {
    apiBaseUrl: "http://localhost:8089",
  },
  prod: {
    apiBaseUrl: "",
  },
};

const activeProfile = "local";
const activeConfig = profiles[activeProfile];

module.exports = {
  activeProfile,
  profiles,
  apiBaseUrl: activeConfig.apiBaseUrl,
};
