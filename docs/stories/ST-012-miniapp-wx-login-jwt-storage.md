# Story ST-012: 小程序 wx.login 静默登录与 JWT 存储

Status: Completed

Epic: EPIC-005 微信小程序学生端  
Priority: Must  
Estimate: 3 points  
Planned Day: D4  
Primary Files: `miniapp/utils/login.js`, `miniapp/utils/auth.js`, `miniapp/api/user.js`, `java/src/main/java/com/school/canteen/controller/MiniAppAuthController.java`, `java/src/main/java/com/school/canteen/service/miniapp/*`  
Likely Touch Points: `java/src/main/java/com/school/canteen/entity/User.java`, `java/src/main/java/com/school/canteen/repository/UserRepository.java`, `java/src/main/java/com/school/canteen/config/SecurityConfig.java`, `java/src/main/resources/application.yml`, `miniapp/app.js`, `miniapp/pages/profile/*`

## Story

作为微信小程序学生用户，我希望打开小程序后通过 `wx.login` 自动完成静默登录，并把后端颁发的 JWT 存入小程序本地 storage，这样后续浏览、加购、下单、支付和评价请求都能统一携带 `Authorization: Bearer <token>`，而不需要手动输入 Web 端学号密码。

## Context

ST-011 已创建原生微信小程序工程骨架、`miniapp/utils/request.js`、`miniapp/utils/auth.js` 和 `miniapp/api/user.js`，并预留了 `/api/miniapp/login` 调用。PRD FR-026 要求小程序使用 `wx.login` 获取 `code`，后端通过 `code2session` 换取 `openid`，首次自动注册学生账号并颁发 JWT。架构 3.3 / 3.4 明确 Web 与小程序共用 REST API、JWT Header 和独立 token 存储。

本故事聚焦登录和登录态，不实现菜品/推荐真实页面、不实现购物车下单、不实现 `wx.requestPayment`。真实微信 `code2session` 需要 AppID/AppSecret；本地演示默认使用 mock 模式，sandbox/production 可通过配置切换到真实微信接口。

## Acceptance Criteria

1. 后端新增公开接口 `POST /api/miniapp/login`，请求体至少包含 `code`；空 code 返回 400 和清晰错误码。
2. 后端新增小程序登录服务边界，支持 `miniapp.mode=mock|wechat` 或等价配置；默认 mock 模式可本地演示。
3. mock 模式下后端根据 code 生成稳定 mock openid，用于本地调试和自动注册，不依赖真实微信网络。
4. wechat 模式下后端通过微信 `jscode2session` 接口换取 openid；未配置 `app-id` / `app-secret` 时返回明确错误，不静默降级为 mock。
5. 首次登录时后端自动创建 `STUDENT` 用户，并保存小程序 openid 绑定；再次使用同一 openid 登录复用同一用户。
6. 已绑定用户若状态为 `inactive`，小程序登录返回 403 或等价业务错误，不颁发 JWT。
7. 登录成功响应包含 `token`、`user`、`isNewUser` 等字段；JWT 使用现有 `JwtUtils` 生成，角色为 `STUDENT`。
8. `SecurityConfig` 允许 `/api/miniapp/login` 未登录访问，但其他 `/api/miniapp/**` 或业务 API 仍需按现有规则鉴权。
9. 小程序 `app.js` 启动时读取本地 token；没有 token 时调用 `wx.login` 并请求 `/api/miniapp/login`。
10. 小程序成功登录后调用 `setToken` / `setCurrentUser` 或等价工具保存 JWT 和用户信息，后续 `request.js` 自动注入 `Authorization: Bearer <token>`。
11. 小程序登录失败时保留清晰错误消息，不阻塞基础页面渲染；个人中心能展示当前登录状态并提供手动重试。
12. 新增或更新测试覆盖后端 mock code 交换、首次创建用户、复用已有用户、空 code、未配置真实微信模式错误和禁用用户。
13. 执行 `mvn test` 或至少相关 Java 测试；小程序新增 JS 做语法检查；如微信开发者工具 CLI 不可用，记录原因。

## Dev Tasks

- [x] 创建故事文档和后端登录边界：
  - [x] 新增 `MiniAppAuthController`。
  - [x] 新增小程序配置、code session 服务和登录应用服务。
  - [x] 在 `SecurityConfig` 放行 `/api/miniapp/login`。
- [x] 支持 openid 绑定与自动注册：
  - [x] 在 `User` 增加 `miniappOpenid`。
  - [x] 在 `UserRepository` 增加 `findByMiniappOpenid` / `existsByMiniappOpenid`。
  - [x] 首次登录创建学生用户，再次登录复用已有用户。
- [x] 完成小程序端静默登录：
  - [x] 新增 `miniapp/utils/login.js`。
  - [x] `app.js` 启动时读取 token，无 token 时调用静默登录。
  - [x] `auth.js` 增加统一保存登录态工具。
  - [x] 个人中心展示登录状态并提供重试。
- [x] 添加验证：
  - [x] 添加小程序登录服务单元测试。
  - [x] 执行 Java 测试。
  - [x] 执行 miniapp JS 语法检查。
  - [x] 记录验证结果到 Dev Agent Record。

## Suggested Implementation Notes

本地演示配置建议：

```yaml
miniapp:
  mode: ${MINIAPP_MODE:mock}
  app-id: ${WECHAT_MINIAPP_APP_ID:}
  app-secret: ${WECHAT_MINIAPP_APP_SECRET:}
  mock:
    openid-prefix: ${MINIAPP_MOCK_OPENID_PREFIX:mock-openid-}
```

小程序登录响应可按以下结构归一：

```json
{
  "data": {
    "token": "...",
    "user": {
      "id": 1,
      "studentId": "WX_xxx",
      "username": "微信用户xxx",
      "role": "STUDENT"
    },
    "isNewUser": true
  }
}
```

小程序端拿到响应后应兼容 `response.data` 与扁平响应，便于和 Web 端登录响应共存。

## Verification

Run from `java/`:

```powershell
mvn test
```

Run from repo root:

```powershell
node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"
rg -n "wx.login|silentLogin|/api/miniapp/login|miniappOpenid|MINIAPP_MODE|Authorization" miniapp java/src/main/java java/src/test/java
```

Expected result:

- `/api/miniapp/login` 可公开访问并返回 JWT。
- mock 模式可在本地无微信 AppSecret 时演示静默登录。
- 小程序 token 存储在独立 storage key 中，request 后续自动携带 Bearer token。
- 微信 DevTools CLI 若未配置，则只记录未运行，不阻塞源码级验证。

## Dependencies

- ST-011 已完成小程序工程骨架、request 封装和独立 token storage。
- 现有 Web 登录和 `JwtUtils` 可复用 JWT 生成逻辑。

## Out of Scope

- 首页、菜品列表、详情和推荐展示；这些属于 ST-013。
- 购物车、下单、订单列表和订单详情轮询；这些属于 ST-014。
- `wx.requestPayment` 拉起和支付失败 / 取消提示；这些属于 ST-015。
- 评价、个人中心和积分商城完整流程；这些属于 ST-016。

## Dev Agent Record

Created At: 2026-06-02  
Completed At: 2026-06-02

Files Changed:

- `docs/stories/ST-012-miniapp-wx-login-jwt-storage.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `java/src/main/java/com/school/canteen/config/SecurityConfig.java`
- `java/src/main/java/com/school/canteen/controller/MiniAppAuthController.java`
- `java/src/main/java/com/school/canteen/entity/User.java`
- `java/src/main/java/com/school/canteen/repository/UserRepository.java`
- `java/src/main/java/com/school/canteen/service/miniapp/MiniAppAuthService.java`
- `java/src/main/java/com/school/canteen/service/miniapp/MiniAppCodeSessionService.java`
- `java/src/main/java/com/school/canteen/service/miniapp/config/MiniAppProperties.java`
- `java/src/main/java/com/school/canteen/service/miniapp/dto/MiniAppLoginRequest.java`
- `java/src/main/java/com/school/canteen/service/miniapp/dto/MiniAppLoginResponse.java`
- `java/src/main/java/com/school/canteen/service/miniapp/dto/MiniAppSession.java`
- `java/src/main/resources/application.yml`
- `java/src/test/java/com/school/canteen/service/miniapp/MiniAppAuthServiceTest.java`
- `java/src/test/java/com/school/canteen/service/miniapp/MiniAppCodeSessionServiceTest.java`
- `miniapp/app.js`
- `miniapp/api/user.js`
- `miniapp/utils/auth.js`
- `miniapp/utils/login.js`
- `miniapp/pages/profile/profile.js`
- `miniapp/pages/profile/profile.wxml`
- `miniapp/pages/profile/profile.wxss`

Implementation Notes:

- Added `/api/miniapp/login` as a public endpoint that returns the same JWT style used by Web login.
- Added `miniapp.mode` configuration. Mock mode is the local default; wechat mode requires `WECHAT_MINIAPP_APP_ID` and `WECHAT_MINIAPP_APP_SECRET`.
- Added `miniappOpenid` to `User` and repository lookup helpers so WeChat identity binding does not overload Web student ID login.
- First miniapp login creates a `STUDENT` user with generated `WX_` student id and username; repeated login for the same openid reuses that user.
- Miniapp launch now attempts silent login only when no token exists, stores token/user through `auth.js`, and leaves pages usable if login fails.
- Profile page now shows miniapp login status and supports manual retry.

Validation:

- `mvn test` passed in `java/`: 29 tests, 0 failures, 0 errors.
- `node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"` passed with 16 JS files.
- `rg -n "wx.login|silentLogin|/api/miniapp/login|miniappOpenid|MINIAPP_MODE|Authorization" miniapp java/src/main/java java/src/main/resources java/src/test/java` passed.
- WeChat DevTools CLI path is configured at `C:\Program Files (x86)\Tencent\微信web开发者工具\cli.bat`; CLI `help` runs successfully. `islogin` still requires 微信开发者工具的 Settings > Security > Service Port to be enabled, otherwise it times out by design.
