# Story ST-002: 收口 Pinia 用户状态与路由角色判断

Status: Ready for Dev

Epic: EPIC-001 前端工程质量治理  
Priority: Must  
Estimate: 3 points  
Planned Day: D1  
Primary Files: `vue/src/stores/user.js`, `vue/src/router/index.js`, `vue/src/App.vue`, `vue/src/components/UserNavBar.vue`, `vue/src/components/AdminNavBar.vue`, `vue/src/views/Login.vue`

## Story

作为前端开发者，我希望登录态、当前用户和角色判断统一由 Pinia user store 提供，以便路由守卫、导航栏和登录跳转使用同一套规则，避免 `localStorage` 分散读取导致管理员权限、窗口管理员权限和登录状态判断不一致。

## Context

当前 `vue/src/stores/user.js` 已经保存 `userInfo`、`token` 和 `isLoggedIn`，但路由守卫仍直接读取 `localStorage.getItem("token")` 和 `localStorage.getItem("userRole")`。同时 `userStore.isAdmin()` 只认 `ADMIN`，而 `vue/src/router/index.js` 的管理后台允许 `ADMIN` 和 `WINDOW_MANAGER`，登录后跳转与路由授权存在历史不一致。

本故事只治理鉴权 / 当前用户 / 角色状态。购物车 `cart` 的 localStorage 缓存、推荐缓存和页面级业务缓存不在本故事内，留给 ST-003 或对应页面故事处理。

## Acceptance Criteria

1. `vue/src/stores/user.js` 明确涵盖 `token`、`userInfo`、`role` 三项状态，并提供稳定 getter / 方法：
   - `isAuthenticated`
   - `currentRole`
   - `isAdmin`
   - `isManager`
   - `canAccessAdmin`
   - `hasAnyRole(roles)`
2. `userStore.login()` 能兼容后端返回 `{ token, user }` 或扁平用户对象两种结构，最终 store 内的 `userInfo` 不应把 token 混入业务用户对象。
3. `userStore.checkLoginStatus()` 从持久化状态恢复时必须安全处理损坏 JSON；解析失败时调用 `logout()` 清理鉴权状态，不让半登录态继续存在。
4. `vue/src/router/index.js` 的 `beforeEach` 使用 Pinia store 判断登录态和角色，不再直接读取 `localStorage`。
5. 路由授权按 `meta.allowedRoles` 作为唯一细粒度规则；若路由只设置 `requiresAdmin: true` 但未设置 `allowedRoles`，默认允许 `ADMIN` 和 `WINDOW_MANAGER`。
6. `userStore.isAdmin` 只表示系统管理员 `ADMIN`；新增 `canAccessAdmin` 表示可进入后台的 `ADMIN` 或 `WINDOW_MANAGER`，并用于登录后的后台跳转判断。
7. `Login.vue` 登录成功后基于 `userStore.canAccessAdmin` 跳转：后台角色进入 `/admin`，学生进入 `/home` 或 `/`。
8. `App.vue`、`UserNavBar.vue`、`AdminNavBar.vue` 的登录态、当前角色、当前用户名 / 头像和退出登录逻辑改为使用 Pinia store，不再直接维护 token / userRole / userInfo 的 localStorage 读写。
9. `vue/src/api/index.js` 的请求拦截器可以继续从持久化 token 读取，或改为从 store 读取；若继续读 localStorage，必须仅作为请求头注入的兼容层存在。
10. 搜索检查中，`localStorage.getItem("token")`、`localStorage.getItem("userRole")`、`localStorage.getItem("userInfo")` 不应再出现在 router、App、导航栏组件和登录页中。
11. `npm run build` 在 `vue/` 目录下通过。

## Dev Tasks

- [ ] 重构 `vue/src/stores/user.js`：
  - [ ] 增加 `role` 状态和 `currentRole` getter。
  - [ ] 增加 `isAuthenticated`、`isAdmin`、`isManager`、`canAccessAdmin`、`hasAnyRole`。
  - [ ] 让 `login()` 兼容 `{ token, user }` 与扁平登录返回。
  - [ ] 让 `checkLoginStatus()` 具备 JSON 解析失败兜底。
  - [ ] 统一 `logout()` 清理 token / userInfo / userRole / userId，并保留必要的业务缓存清理行为。
- [ ] 重构 `vue/src/router/index.js`：
  - [ ] 在守卫内获取 `useUserStore()`。
  - [ ] 进入需要鉴权的路由前先恢复登录态。
  - [ ] 用 `userStore.isAuthenticated` 替代 token 直读。
  - [ ] 用 `userStore.hasAnyRole()` 和 `allowedRoles` 校验角色。
- [ ] 重构登录跳转：
  - [ ] `Login.vue` 使用 `userStore.canAccessAdmin` 决定跳转后台还是学生首页。
- [ ] 重构应用壳和导航栏：
  - [ ] `App.vue` 使用 Pinia 的登录态、角色、用户信息和 `logout()`。
  - [ ] `UserNavBar.vue` 使用 Pinia 的登录态、角色、用户信息和 `logout()`。
  - [ ] `AdminNavBar.vue` 使用 Pinia 的角色、用户信息和 `logout()`。
- [ ] 运行搜索验证，确认 router/App/nav/login 不再直接读取 token / userRole / userInfo localStorage。
- [ ] 执行构建验证。

## Suggested Implementation Notes

Role semantics:

```js
const ADMIN_ROLES = ["ADMIN", "WINDOW_MANAGER"];

const currentRole = computed(() => role.value || userInfo.value?.role || "");
const isAdmin = computed(() => currentRole.value === "ADMIN");
const isManager = computed(() => currentRole.value === "WINDOW_MANAGER");
const canAccessAdmin = computed(() => ADMIN_ROLES.includes(currentRole.value));
const hasAnyRole = (roles = []) => roles.includes(currentRole.value);
```

Router fallback rule:

```js
const allowedRoles = matchWithAllowed?.meta.allowedRoles
  || (to.meta.requiresAdmin ? ["ADMIN", "WINDOW_MANAGER"] : []);
```

Login response normalization should not assume one backend shape:

```js
const token = loginData.token;
const user = loginData.user || loginData;
```

If `user` still contains `token`, remove it before storing in `userInfo`.

## Verification

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "localStorage\.getItem\(\"token\"\)|localStorage\.getItem\(\"userRole\"\)|localStorage\.getItem\(\"userInfo\"\)" vue/src/router vue/src/App.vue vue/src/components/UserNavBar.vue vue/src/components/AdminNavBar.vue vue/src/views/Login.vue
rg -n "isAdmin\(|canAccessAdmin|hasAnyRole|currentRole" vue/src/stores/user.js vue/src/router/index.js vue/src/views/Login.vue
```

Expected result:

- First search returns no matches.
- Role helpers are defined in `vue/src/stores/user.js` and consumed by router/login/nav code.
- `npm run build` passes.

## Dependencies

- ST-001 completed, shared Axios client remains stable.
- Existing backend role enum remains `STUDENT`, `WINDOW_MANAGER`, `ADMIN`.
- Existing route meta fields `requiresAuth`, `requiresAdmin`, `allowedRoles` remain the public contract.

## Out of Scope

- Cart localStorage cache cleanup and order-page storage cleanup; this belongs to ST-003.
- Recommendation and home-page business caches.
- Backend JWT / RBAC implementation.
- Payment, miniapp, and analytics changes.

