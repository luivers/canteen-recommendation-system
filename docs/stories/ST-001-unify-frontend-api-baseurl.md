        # Story ST-001: 统一前端 API baseURL，接入 VITE_API_BASE

Status: Done

Epic: EPIC-001 前端工程质量治理  
Priority: Must  
Estimate: 2 points  
Planned Day: D1  
Primary Files: `vue/src/api/index.js`, `vue/.env.development`, `vue/.env.production`, `vue/.env.example`

## Story

作为前端开发者，我希望所有 Web 端 HTTP 请求都从同一个 Axios 实例读取 `VITE_API_BASE`，以便本地开发、演示部署和生产部署可以通过环境变量切换后端地址，而不需要修改源代码。

## Context

当前 `vue/src/api/index.js` 中 Axios `baseURL` 硬编码为 `http://localhost:8089`。PRD NFR-007 和架构文档均要求改为 `import.meta.env.VITE_API_BASE` 注入。现有 API 资源模块的请求路径已经包含 `/api` 前缀，例如 `/api/users/login`、`/api/dishes`、`/api/orders`，因此 `VITE_API_BASE` 应表示后端 origin，不应写成 `/api`。

本故事只处理 API baseURL 的配置治理，不重构 Pinia、路由鉴权、购物车或订单状态逻辑。

## Acceptance Criteria

1. `vue/src/api/index.js` 的 Axios 实例不再把 `http://localhost:8089` 写死在 `baseURL` 配置中。
2. Axios `baseURL` 从 `import.meta.env.VITE_API_BASE` 读取，并在使用前去除末尾 `/`，避免拼接出双斜杠。
3. 未配置 `VITE_API_BASE` 时，请求仍能走当前前端 origin 下的 `/api/**` 相对路径，便于通过 Vite proxy 或同源反向代理运行。
4. 新增 `vue/.env.development`，声明本地后端地址，例如 `VITE_API_BASE=http://localhost:8089`。
5. 新增 `vue/.env.production`，声明生产部署地址占位；如果生产使用同源反向代理，可以保留为空值并在文件注释中说明。
6. 新增 `vue/.env.example`，说明 `VITE_API_BASE` 应填写后端 origin，不包含 `/api` 后缀。
7. 全工程除文档和 env 示例外，不再出现 Axios baseURL 的后端地址硬编码。
8. 现有 `vue/src/api/*.js` 资源模块继续复用 `vue/src/api/index.js` 导出的 `api` 实例，不新增组件内 `axios.create`。
9. 使用 `api.defaults.baseURL` 拼接 `/uploads/**` 的页面在 `VITE_API_BASE` 为空或为 `http://localhost:8089` 时都能得到有效上传资源 URL。
10. `npm run build` 在 `vue/` 目录下通过。

## Dev Tasks

- [x] 在 `vue/src/api/index.js` 中增加 `resolveApiBaseURL` 或等价的小函数：
  - [x] 读取 `import.meta.env.VITE_API_BASE`。
  - [x] 对空值返回 `""`。
  - [x] 对非空值去除末尾 `/`。
- [x] 将 Axios `baseURL` 改为上述解析结果。
- [x] 保留现有 `timeout`、`withCredentials`、请求拦截器、响应拦截器和 FormData 处理逻辑。
- [x] 新增 `vue/.env.development`，本地默认指向 `http://localhost:8089`。
- [x] 新增 `vue/.env.production`，提供生产部署变量。
- [x] 新增 `vue/.env.example`，写明不要把变量配置成 `/api`。
- [x] 搜索确认组件内没有新增 `axios.create`。
- [x] 执行构建验证。

## Suggested Implementation

```js
const resolveApiBaseURL = () => {
  const rawBaseURL = import.meta.env.VITE_API_BASE || "";
  return rawBaseURL.replace(/\/$/, "");
};

const api = axios.create({
  baseURL: resolveApiBaseURL(),
  timeout: 15000,
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
});
```

`VITE_API_BASE` 示例：

```env
# Local backend origin. Do not include /api because API modules already use /api paths.
VITE_API_BASE=http://localhost:8089
```

## Verification

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n --glob '!vue/node_modules/**' --glob '!vue/dist/**' "axios\.create|http://localhost:8089|VITE_API_BASE" vue docs
```

Expected result:

- `axios.create` appears only in `vue/src/api/index.js`.
- `http://localhost:8089` appears only in env files or documentation, not as active source-code baseURL.
- `VITE_API_BASE` appears in env files, docs, and `vue/src/api/index.js`.

## Dependencies

- Existing backend local port remains `8089`.
- Existing API modules keep `/api/**` paths.
- Vite proxy for `/api` and `/uploads` remains available for same-origin or empty-baseURL local runs.

## Out of Scope

- Pinia user-state consolidation.
- Router role-guard cleanup.
- Payment, miniapp, order status, and recommendation UI changes.
- Rewriting API resource module endpoint paths.

## Dev Agent Record

Completed At: 2026-05-17

Files Changed:

- `vue/src/api/index.js`
- `vue/.env.development`
- `vue/.env.production`
- `vue/.env.example`
- `vue/vite.config.js`
- `docs/stories/ST-001-unify-frontend-api-baseurl.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`

Implementation Notes:

- `baseURL` now resolves from `import.meta.env.VITE_API_BASE`, trims whitespace, and removes trailing slashes.
- Empty production `VITE_API_BASE` supports same-origin reverse proxy deployments.
- `vite.config.js` `manualChunks` was changed from object form to function form because Vite 8/Rolldown rejects object `manualChunks`; this was required for `npm run build` to pass.

Validation:

- `npm run build` passed in `vue/`.
- `rg -n "axios\.create" vue\src` returns only `vue/src/api/index.js`.
- `rg -n "http://localhost:8089" vue\src vue\vite.config.js vue\.env.development vue\.env.production vue\.env.example` returns only env files.
