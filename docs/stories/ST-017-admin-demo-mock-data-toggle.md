# Story ST-017: 管理后台 demo/mock 数据开关

Status: Completed

Epic: EPIC-003 管理后台数据看板  
Priority: Must  
Estimate: 3 points  
Planned Day: D5  
Primary Files: `vue/src/api/statistics.js`, `vue/src/api/statisticsDemoData.js`, `vue/src/views/admin/Dashboard.vue`  
Likely Touch Points: `vue/.env.*`, `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为管理员和演示讲解者，我希望管理后台数据看板和高级分析页面具备一个可控的 demo/mock 数据开关，这样在本地数据库统计数据不足、后端统计任务尚未产生结果或演示环境网络不稳定时，仍能展示完整的非空图表和分析结果。

## Context

当前管理后台 Dashboard、高级分析、排行、趋势、词云等页面都通过 `vue/src/api/statistics.js` 访问统计接口。若数据库样例数据不足或后端统计接口返回空数组，演示时会出现图表空白，影响 10 分钟 demo 路线。ST-017 聚焦前端 API 层可控演示兜底，不改变后端统计服务，也不替代 ST-018 的空数据图表降级验收。

## Acceptance Criteria

1. 新增环境变量 `VITE_ADMIN_DEMO_DATA`，默认关闭；设置为 `true` / `1` / `demo` / `mock` 等真值时启用管理后台统计 demo 数据。
2. demo 开关逻辑集中在统计 API 层或相邻模块，页面组件不需要硬编码后端 URL，也不需要关心当前是实数还是 demo 数据。
3. Dashboard 关键指标、仪表盘摘要、收入趋势、订单趋势、实时订单列表在 demo 模式下能显示非空数据。
4. 热门菜品排行、评分排行、趋势排行、分类排行、用户活跃时段、品类趋势、评价关键词和菜品特征词云在 demo 模式下能拿到与现有组件兼容的数据形状。
5. 高级分析中的关联规则、用户分群、分群用户列表、库存预警和对比分析在 demo 模式下能加载非空表格或卡片结果。
6. demo 模式不修改全局 Axios 拦截器，不影响登录、订单、菜品、支付等非统计 API 的真实调用。
7. `.env.example`、开发和生产环境变量文件标注该开关，生产默认仍为关闭。
8. 完成前端构建或等价语法检查，并搜索确认关键 demo 开关和统计 API 契约。

## Dev Tasks

- [x] 创建故事文档和状态更新。
- [x] 新增 `vue/src/api/statisticsDemoData.js`，提供管理后台统计演示数据。
- [x] 改造 `vue/src/api/statistics.js`，在 `VITE_ADMIN_DEMO_DATA` 启用时返回同形状本地响应。
- [x] 为 Dashboard 实时订单列表补充 demo 模式数据，避免该区域仍依赖订单 API。
- [x] 更新 `.env.example`、`.env.development` 和 `.env.production` 的开关说明。
- [x] 运行前端构建与关键契约搜索。

## Verification

Run from repo root:

```powershell
cd vue
npm run build
cd ..
rg -n "VITE_ADMIN_DEMO_DATA|isAdminStatisticsDemoEnabled|getStatisticsDemoResponse|statisticsRequest|demoRealTimeOrders" vue/src vue/.env.example vue/.env.development vue/.env.production
```

Expected result:

- `VITE_ADMIN_DEMO_DATA=false` 时统计 API 仍走真实后端。
- `VITE_ADMIN_DEMO_DATA=true` 时管理后台统计图表和高级分析使用前端本地 demo 数据。
- Dashboard、图表组件和高级分析组件不需要修改各自的接口调用参数。

## Dependencies

- ST-004 已完成后台图表与高级分析组件懒加载。
- 现有 `statisticsApi` 已作为后台图表统一统计 API 入口。

## Out of Scope

- 后端统计任务、统计 SQL 或真实样例数据生成。
- 空数据图表统一降级 UI 与视觉验收，这些属于 ST-018。
- Web 核心路径冒烟测试和 console 错误清零，这些属于 ST-019。

## Dev Agent Record

Created At: 2026-06-07  
Completed At: 2026-06-07

Files Changed:

- `docs/stories/ST-017-admin-demo-mock-data-toggle.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `vue/.env.example`
- `vue/.env.development`
- `vue/.env.production`
- `vue/src/api/statistics.js`
- `vue/src/api/statisticsDemoData.js`
- `vue/src/views/admin/Dashboard.vue`

Implementation Notes:

- Added a dedicated `statisticsDemoData` module so demo payloads stay out of the main API client.
- Added `statisticsApi.isDemoEnabled()` and a local `statisticsRequest()` helper to keep the real API path unchanged when the switch is off.
- Covered Dashboard, chart panels, word clouds and advanced analysis payloads with component-compatible response shapes.
- Kept the production default disabled; demo mode is opt-in through `VITE_ADMIN_DEMO_DATA`.

Validation:

- `npm run build` passed in `vue`; Vite reported only chunk-size warnings for existing large vendor/chart bundles.
- `rg -n "VITE_ADMIN_DEMO_DATA|isAdminStatisticsDemoEnabled|getStatisticsDemoResponse|statisticsRequest|demoRealTimeOrders" vue/src vue/.env.example vue/.env.development vue/.env.production docs/stories/ST-017-admin-demo-mock-data-toggle.md` passed.
