# Story ST-011: 创建原生微信小程序工程骨架和 request 封装

Status: Completed

Epic: EPIC-005 微信小程序学生端  
Priority: Must  
Estimate: 3 points  
Planned Day: D4  
Primary Files: `miniapp/`, `miniapp/utils/request.js`, `miniapp/config/env.js`  
Likely Touch Points: `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为开发者，我希望先创建一个原生微信小程序工程骨架，并提供统一的 `wx.request` 封装、独立 token 存储和基础页面入口，以便后续 ST-012 到 ST-016 可以在稳定的小程序目录结构上继续实现静默登录、浏览、购物车、订单、支付、评价和积分商城，而不是每个故事重复搭建工程基础。

## Context

PRD FR-026 到 FR-028 要求本轮新增微信小程序学生端，架构 3.3 明确小程序使用原生微信小程序框架，不引入 Taro / Uni-app，并通过 `wx.request` 复用后端 REST API、通过 `Authorization: Bearer <token>` 携带 JWT。ST-007 到 ST-010 已完成支付 facade、支付创建、回调幂等和 Web 支付状态查询，小程序后续将复用这些后端契约。

本故事只建立小程序基础工程和网络层边界，不实现 `wx.login` 静默登录、不新增后端小程序登录接口、不实现完整业务页面和 `wx.requestPayment` 拉起。

## Acceptance Criteria

1. 仓库根目录新增 `miniapp/`，使用原生微信小程序工程文件结构，至少包含 `project.config.json`、`app.js`、`app.json`、`app.wxss`、`sitemap.json`。
2. `miniapp/app.json` 配置可打开的基础页面，至少包含首页、购物车、订单和个人中心占位页，为 ST-013 到 ST-016 预留路径。
3. 小程序工程不引入 Taro、Uni-app、npm 构建或 Web SPA 依赖；所有新增运行时代码使用微信小程序原生语法。
4. 新增 `miniapp/config/env.js` 或等价配置文件，集中维护本地后端 `apiBaseUrl`，默认指向 `http://localhost:8089`，后续可替换为合法域名。
5. 新增 `miniapp/utils/request.js`，统一封装 `wx.request`，支持 `get/post/put/delete` 或等价快捷方法。
6. request 封装自动从小程序本地存储读取 token，并在存在 token 时写入 `Authorization: Bearer <token>`。
7. 新增独立的 token 存储工具，例如 `miniapp/utils/auth.js`，不得复用 Web 端 `localStorage` 或 Pinia 状态。
8. request 封装统一处理 2xx 成功、非 2xx 错误、网络失败和 401 清理 token；错误对象需要包含可展示的 `message`。
9. 新增基础 API 模块或出口文件，为后续登录、菜品、推荐、订单和支付调用预留统一导入入口。
10. 基础页面可以在微信开发者工具中作为占位页打开，页面文案清楚说明当前模块将在后续故事补齐，但不写入真实业务流程。
11. 新增文档或故事记录说明小程序启动方式、默认 baseURL 和后续故事边界。
12. 验证至少覆盖：新增小程序 JS 文件语法检查、关键文件存在检查、request / auth / env 搜索检查；若无法使用微信开发者工具命令行验证，需要记录原因。

## Dev Tasks

- [x] 创建小程序工程骨架：
  - [x] 新增 `miniapp/project.config.json`、`miniapp/app.js`、`miniapp/app.json`、`miniapp/app.wxss`、`miniapp/sitemap.json`。
  - [x] 新增首页、购物车、订单和个人中心占位页面。
  - [x] 保持原生微信小程序结构，不引入跨端框架。
- [x] 创建配置与存储工具：
  - [x] 新增 `miniapp/config/env.js`，集中定义默认后端地址。
  - [x] 新增 `miniapp/utils/storage.js`，封装同步存储并支持非微信环境语法检查。
  - [x] 新增 `miniapp/utils/auth.js`，提供 token / user 读写和清理。
- [x] 创建 request 封装：
  - [x] 新增 `miniapp/utils/request.js`，封装 `wx.request`。
  - [x] 支持鉴权 header、错误消息归一、401 清理 token。
  - [x] 暴露 `get/post/put/delete` 快捷方法。
- [x] 创建基础 API 出口：
  - [x] 新增 `miniapp/api/index.js`。
  - [x] 新增用户、菜品、推荐、订单、支付 API 占位模块。
  - [x] API 模块只绑定已存在或后续明确规划的 REST 路径，不在本故事实现业务 UI。
- [x] 更新 BMAD 状态：
  - [x] 更新 `docs/stories/README.md`，加入 ST-011 并指向 ST-012。
  - [x] 更新 `docs/sprint-status.yaml` 中 ST-011 状态、统计和下一故事。
  - [x] 更新 `docs/bmm-workflow-status.yaml` 中 story 汇总。
- [x] 验证：
  - [x] 检查 `miniapp/` 关键文件存在。
  - [x] 用 Node 对新增 JS 文件做语法加载检查。
  - [x] 搜索确认 request / auth / env 关键契约存在。

## Suggested Implementation Notes

小程序本地开发默认后端地址：

```javascript
const profiles = {
  local: {
    apiBaseUrl: "http://localhost:8089",
  },
};
```

request 封装建议保持和 Web Axios client 同样的鉴权语义：

```javascript
Authorization: Bearer <token>
```

由于微信小程序没有浏览器 `localStorage` 和 Web SSE，后续故事需要继续保持小程序 token 独立存储，并在订单详情页使用短轮询。

## Verification

Run from repo root:

```powershell
Get-ChildItem miniapp -Recurse -File
node -e "['./miniapp/config/env.js','./miniapp/utils/storage.js','./miniapp/utils/auth.js','./miniapp/utils/request.js','./miniapp/api/index.js'].forEach(require); console.log('miniapp js ok')"
rg -n "apiBaseUrl|Authorization|Bearer|wx.request|TOKEN_KEY|getToken|clearToken" miniapp
```

Expected result:

- `miniapp/` 原生小程序工程文件存在。
- `request.js` 通过 `wx.request` 统一发起请求，并注入 token。
- token 存储在小程序 storage 工具中，与 Web 端状态隔离。
- 后续 ST-012 到 ST-016 可以直接复用 `miniapp/api` 与 `miniapp/utils/request.js`。

## Dependencies

- ST-001 已完成前端 API baseURL 治理，Web 与小程序都遵循“统一后端 REST API”的方向。
- ST-007 到 ST-010 已完成支付 facade、支付创建、回调幂等和 Web 状态查询，为后续小程序支付与订单轮询预留契约。
- 后端当前仍需 ST-012 增加 `/api/miniapp/login` 或等价登录入口。

## Out of Scope

- `wx.login` 静默登录、`code2session`、小程序 JWT 颁发；这些属于 ST-012。
- 首页、菜品列表、详情和推荐真实数据展示；这些属于 ST-013。
- 购物车、下单、订单列表和订单详情轮询；这些属于 ST-014。
- `wx.requestPayment` 拉起和支付失败 / 取消提示；这些属于 ST-015。
- 评价、个人中心和积分商城完整流程；这些属于 ST-016。

## Dev Agent Record

Created At: 2026-06-01  
Completed At: 2026-06-01

Files Changed:

- `docs/stories/ST-011-miniapp-native-skeleton-request-wrapper.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `miniapp/project.config.json`
- `miniapp/app.js`
- `miniapp/app.json`
- `miniapp/app.wxss`
- `miniapp/sitemap.json`
- `miniapp/config/env.js`
- `miniapp/utils/storage.js`
- `miniapp/utils/auth.js`
- `miniapp/utils/request.js`
- `miniapp/api/index.js`
- `miniapp/api/user.js`
- `miniapp/api/dish.js`
- `miniapp/api/recommendation.js`
- `miniapp/api/order.js`
- `miniapp/api/payment.js`
- `miniapp/pages/index/index.*`
- `miniapp/pages/cart/cart.*`
- `miniapp/pages/orders/orders.*`
- `miniapp/pages/profile/profile.*`

Implementation Notes:

- Added a native WeChat mini program scaffold under `miniapp/` without Taro / Uni-app / npm dependencies.
- Added environment configuration with local backend default `http://localhost:8089`.
- Added storage and auth utilities so miniapp token state is isolated from Web localStorage / Pinia.
- Added a `wx.request` wrapper with token header injection, 2xx success handling, normalized error messages and 401 token cleanup.
- Added API modules for user, dish, recommendation, order and payment paths so later miniapp stories have stable import boundaries.
- Added placeholder native pages for home, cart, orders and profile.

Validation:

- `Test-Path` checks for `miniapp/project.config.json`, `miniapp/app.json`, `miniapp/utils/request.js`, `miniapp/utils/auth.js`, `miniapp/config/env.js` passed.
- `node -e "['./miniapp/config/env.js','./miniapp/utils/storage.js','./miniapp/utils/auth.js','./miniapp/utils/request.js','./miniapp/api/index.js'].forEach(require); console.log('miniapp js ok')"` passed.
- `node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"` passed with 15 JS files.
- `rg -n "apiBaseUrl|Authorization|Bearer|wx.request|TOKEN_KEY|getToken|clearToken" miniapp` passed.
- WeChat DevTools CLI path is configured at `C:\Program Files (x86)\Tencent\微信web开发者工具\cli.bat`; CLI `help` runs successfully. `islogin` still requires 微信开发者工具的 Settings > Security > Service Port to be enabled, otherwise it times out by design.
