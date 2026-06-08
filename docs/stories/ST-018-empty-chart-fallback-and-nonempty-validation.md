# Story ST-018: 空数据图表降级与图表非空验收

Status: Completed

Epic: EPIC-003 管理后台数据看板  
Priority: Must  
Estimate: 2 points  
Planned Day: D5  
Primary Files: `vue/src/components/admin/*`, `vue/src/components/admin/analysis/*`  
Likely Touch Points: `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为管理员和演示讲解者，我希望管理后台图表和高级分析模块在真实统计数据为空、接口返回字段不完整或 demo 数据关闭时仍能显示稳定的空态、表格提示或加载失败提示，而不是出现空白画布、控制台异常或数字格式化崩溃，这样 10 分钟演示路线可以稳定覆盖数据看板与高级分析。

## Context

ST-017 已提供 `VITE_ADMIN_DEMO_DATA` 开关，在 demo 模式下可返回非空统计数据。本故事补足真实数据为空时的降级体验和验收保护，重点覆盖 `HotDishRanking`、评价关键词词云、菜品特征词云、关联规则、用户分群、库存预警和对比分析等后台图表/分析组件，不改变后端统计 API 和 demo/mock 开关语义。

## Acceptance Criteria

1. 热门菜品排行的销量排行、评分排行、趋势排行和分类排行在接口返回空数组、缺失 `top` 或数值字段为空时显示明确空态，不保留空白 ECharts 画布。
2. 热门菜品排行对 `name`、`dishName`、`category` 以及 `qty`、`value`、`sales`、`growthRate` 等常见字段做局部归一化，避免后端字段轻微变化导致图表不可渲染。
3. 评价关键词词云在 `keywords` 为空、字段为 `word` / `keyword` / `count` / `frequency` 或加载失败时显示稳定空态。
4. 菜品特征词云在 `keywords` 为空、字段为 `word` / `keyword` / `weight` / `count` / `frequency` 时可以归一化渲染或降级为空态。
5. 高级分析的关联规则、用户分群、库存预警和对比分析表格都设置业务语义明确的空数据文案。
6. 高级分析组件对 `toFixed()`、百分比进度、summary、breakdowns 和列表字段进行防御式归一化，避免空响应触发控制台异常。
7. 本故事不修改全局 Axios 拦截器，不改变统计 API 路径，不影响 ST-017 的 demo/mock 数据开关。
8. 完成前端构建或等价语法检查，并搜索确认新增空态、归一化 helper 和关键组件契约。

## Dev Tasks

- [x] 创建故事文档和状态更新。
- [x] 为 `HotDishRanking.vue` 增加排行数据归一化和四个 tab 的 ECharts 空态。
- [x] 为 `ReviewKeywordsPanel.vue` 增加关键词归一化、空态和失败态。
- [x] 为 `DishFeaturesWordCloud.vue` 增加关键词归一化和抽屉列表安全赋值。
- [x] 为高级分析表格补充 `empty-text` 和空响应归一化。
- [x] 为用户分群和对比分析补充数字字段安全格式化。
- [x] 运行前端构建和关键契约搜索。

## Verification

Run from repo root:

```powershell
cd vue
npm run build
cd ..
rg -n "showChartEmpty|normalizeRankingRows|normalizeKeywords|empty-text=\"暂无|normalizeComparisonResult|暂无评价关键词|暂无对比分析数据" vue/src/components/admin vue/src/components/admin/analysis docs/stories/ST-018-empty-chart-fallback-and-nonempty-validation.md
```

Expected result:

- 管理后台图表接口返回空数组时显示中文空态，不出现空白画布。
- 高级分析表格在空响应下展示对应业务空文案。
- demo 数据开关关闭时，真实空数据路径也不会触发 `undefined.toFixed` 等运行时错误。

## Dependencies

- ST-004 已完成后台图表和高级分析组件懒加载。
- ST-017 已完成管理后台统计 demo/mock 数据开关。

## Out of Scope

- 后端统计 SQL、真实样本数据生成和统计任务调度。
- Playwright 全路径冒烟测试与 console 错误清零，这些属于 ST-019。
- 本地启动文档、demo 脚本和发布清单，这些属于 ST-021 / ST-023。

## Dev Agent Record

Created At: 2026-06-07  
Completed At: 2026-06-07

Files Changed:

- `docs/stories/ST-018-empty-chart-fallback-and-nonempty-validation.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `vue/src/components/admin/HotDishRanking.vue`
- `vue/src/components/admin/ReviewKeywordsPanel.vue`
- `vue/src/components/admin/DishFeaturesWordCloud.vue`
- `vue/src/components/admin/analysis/AssociationRules.vue`
- `vue/src/components/admin/analysis/UserSegmentation.vue`
- `vue/src/components/admin/analysis/AnomalyDetection.vue`
- `vue/src/components/admin/analysis/ComparisonAnalysis.vue`

Implementation Notes:

- Added local normalization helpers instead of changing the API layer so ST-017 demo data behavior remains untouched.
- Used ECharts `graphic` empty text for chart and word-cloud components.
- Used Element Plus table `empty-text` for advanced analysis tables.
- Normalized comparison metrics, breakdown rows, user segmentation summary and inventory warning rows before rendering.

Validation:

- `npm run build` passed in `vue`; Vite reported only existing chunk-size warnings.
- `rg -n "showChartEmpty|normalizeRankingRows|normalizeKeywords|empty-text=\"暂无|normalizeComparisonResult|暂无评价关键词|暂无对比分析数据" vue/src/components/admin vue/src/components/admin/analysis docs/stories/ST-018-empty-chart-fallback-and-nonempty-validation.md` passed.
