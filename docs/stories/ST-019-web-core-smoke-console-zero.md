# Story ST-019: Web 核心路径冒烟测试与 console 错误清零

Status: Completed

Epic: EPIC-007 验收、回归与交付稳定性  
Priority: Must  
Estimate: 3 points  
Planned Day: D6  
Primary Files: `scripts/web-smoke-cdp.mjs`, `vue/package.json`, Web student/admin pages  
Likely Touch Points: `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为交付验收者和演示讲解者，我希望 Web 学生端与管理后台的核心路径可以用一条命令完成浏览器级冒烟检查，并在检查中捕获 `console.error`、未处理运行时异常和空白页面，这样在演示前可以快速确认 Web 路由、懒加载组件和关键页面首轮渲染没有明显故障。

## Context

ST-017 已完成管理后台 demo/mock 统计数据开关，ST-018 已补充空数据图表降级。本故事聚焦 Web 前端自身的验收工具和 smoke 暴露的问题修复。真实后端业务链路的登录、下单、支付、评价、积分接口验证属于 ST-020；本故事通过浏览器层 API mock 保证前端路由与页面初始化可以稳定、可重复验收。

## Acceptance Criteria

1. 新增可执行 Web smoke 命令，能自动启动 Vite dev server 和本机 Chrome/Edge headless。
2. smoke 覆盖登录页、学生首页、菜品页、购物车、我的订单、个人中心、积分兑换，以及后台看板、高级分析、订单管理、评价管理、奖品管理等核心路由。
3. smoke 在浏览器层捕获 `console.error`、runtime exception、CDP log error 和页面空白结果，出现问题时以非 0 退出。
4. smoke 不依赖真实后端 8089 可用性；测试运行时强制同源 API，并对 `/api/*` 返回稳定 mock 响应。
5. smoke 对 SSE 连接使用无副作用 stub，避免前端 smoke 被后端长连接状态误判。
6. 学生端与后台路由按角色注入登录态，仍走真实 Vue Router 守卫和懒加载页面。
7. 修复 smoke 暴露的 Web runtime 问题：订单页订单项字段缺失不再触发 `dish.name` / `dish.price` 异常。
8. 修复 smoke 暴露的 Web runtime 问题：个人中心饮食标签接口返回对象、分页或空数据时不再触发 `new Set(object)` 异常。
9. 完成前端构建、Web smoke 和关键契约搜索，并记录验证结果。

## Dev Tasks

- [x] 创建 ST-019 story 文档和状态更新。
- [x] 新增 `scripts/web-smoke-cdp.mjs`，使用 Chrome DevTools Protocol 执行 Web 路由冒烟。
- [x] 在 `vue/package.json` 增加 `npm run smoke:web` 命令。
- [x] 为 smoke 增加 API mock、登录态 preload、SSE stub 和 console/runtime 捕获。
- [x] 修复 `vue/src/views/Orders.vue` 的订单项字段兼容。
- [x] 修复 `vue/src/views/Profile.vue` 的饮食标签响应归一化。
- [x] 运行构建、smoke 和契约搜索。

## Verification

Run from repo root:

```powershell
cd vue
npm run build
npm run smoke:web
cd ..
rg -n "smoke:web|web-smoke-cdp|buildPreloadScript|getOrderItemName|normalizeTagList|Web smoke passed" scripts vue/package.json vue/src/views/Orders.vue vue/src/views/Profile.vue docs/stories/ST-019-web-core-smoke-console-zero.md
```

Expected result:

- `npm run build` passes.
- `npm run smoke:web` passes 12 Web routes with `console errors: 0`.
- Smoke failures include enough route/source detail to locate console/runtime issues when regressions appear.

## Dependencies

- ST-017 已完成管理后台统计 demo/mock 数据开关。
- ST-018 已完成图表空数据降级和高级分析空态保护。
- 本机需要安装 Chrome 或 Edge；如路径不在默认位置，可通过 `CHROME_PATH` 指定。

## Out of Scope

- 真实后端 API 冒烟、登录/下单/支付/评价/积分业务链路，这些属于 ST-020。
- Playwright/Cypress 等第三方 E2E 框架引入。
- 发布前打包检查与交付清单，这些属于 ST-023。

## Dev Agent Record

Created At: 2026-06-07  
Completed At: 2026-06-07

Files Changed:

- `docs/stories/ST-019-web-core-smoke-console-zero.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `scripts/web-smoke-cdp.mjs`
- `vue/package.json`
- `vue/src/views/Orders.vue`
- `vue/src/views/Profile.vue`

Implementation Notes:

- The smoke runner starts Vite on a free local port, opens Chrome/Edge headless, creates one browser target per route, and intercepts same-origin `/api/*` requests with deterministic JSON.
- Login state is injected before page scripts run so Vue Router guards and page loading still execute normally.
- EventSource is stubbed only in the smoke browser context to keep frontend smoke independent from backend SSE availability.
- The runner intentionally avoids adding Playwright/Cypress dependencies and uses Node's built-in WebSocket plus Chrome DevTools Protocol.

Validation:

- `npm run smoke:web` passed with 12 routes and `console errors: 0`.
- `npm run build` passed in `vue`; Vite reported only existing chunk-size warnings.
- Contract search for `smoke:web`, `web-smoke-cdp`, `buildPreloadScript`, `getOrderItemName` and `normalizeTagList` passed.
