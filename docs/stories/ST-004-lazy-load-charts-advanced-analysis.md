# Story ST-004: 图表与高级分析组件懒加载，降低首屏压力

Status: Completed

Epic: EPIC-001 前端工程质量治理  
Priority: Must  
Estimate: 2 points  
Planned Day: D2  
Primary Files: `vue/src/views/admin/Dashboard.vue`, `vue/src/views/admin/AdvancedAnalysis.vue`, `vue/vite.config.js`  
Likely Touch Points: `vue/src/components/admin/*.vue`, `vue/src/components/admin/analysis/*.vue`

## Story

作为前端开发者，我希望管理后台 Dashboard 的图表组件和高级分析页的重型分析面板按需加载，以便管理员进入后台时优先看到关键指标和页面骨架，避免 ECharts、词云、关联规则、用户分群等大模块在首屏一次性下载和初始化。

## Context

PRD NFR-002 要求登录后首页 LCP < 2.5s，架构文档也明确要求 ECharts 和高级分析面板懒加载。当前 `Dashboard.vue` 静态导入 `echarts` 以及多个图表组件，并且图表组件使用 `v-show` 挂载，导致非当前图表也可能进入当前页面 chunk 或初始化路径。`AdvancedAnalysis.vue` 虽然通过 `v-if` 控制 tab 内容显示，但四个分析组件仍为静态 import，会被打进高级分析页面首个 chunk。

本故事只处理管理后台图表 / 分析组件的加载时机和构建拆包，不改统计接口语义、不改图表视觉设计，也不引入新的图表库。

## Acceptance Criteria

1. `AdvancedAnalysis.vue` 使用 `defineAsyncComponent` 或等价动态 import 加载四个 tab 组件：关联规则、用户分群、异常检测、对比分析；未激活的 tab 不应在页面初次进入时下载和挂载。
2. `AdvancedAnalysis.vue` 的 tab 切换保持现有功能：首次进入默认展示关联规则；切换到其他 tab 时出现合理加载态，组件加载成功后渲染原有内容。
3. `Dashboard.vue` 中非默认图表面板改为按需渲染：订单趋势、热门菜品排行、用户活跃时段、品类销售趋势、评论关键词、菜品特征词云只在用户选择对应图表时加载。
4. `Dashboard.vue` 不再在模块顶层静态 `import * as echarts from "echarts"`；收入趋势图所需 ECharts 通过动态 import 或独立异步组件加载，避免阻塞关键指标区域渲染。
5. Dashboard 进入页面时先渲染欢迎区、关键指标和系统状态；收入趋势图可以延后到 `nextTick` / idle callback / 动态 import 完成后初始化，并在加载中显示稳定高度的占位。
6. 图表切换后仍能正确接收 `startDate`、`endDate`、`height`、`active`、`showLabels` 和 `refreshKey` 等现有参数；刷新按钮仍能刷新当前已加载图表。
7. 图表导出功能保持可用：当前可见图表如果已加载且暴露 `getDataURL`，仍可导出 PNG / PDF；图表尚未加载完成时给出用户可见提示，不抛未处理异常。
8. 懒加载后的图表 resize 行为保持稳定：窗口变化时当前可见图表能 resize；未加载图表不触发空引用错误。
9. 构建产物应能看到图表 / 高级分析相关异步 chunk；`Dashboard` 和 `AdvancedAnalysis` 初始 chunk 不应静态包含所有分析子组件。
10. 不新增组件内 `axios.create`，不改变 `vue/src/api/statistics.js`、`vue/src/api/order.js` 的公开调用契约。
11. `npm run build` 在 `vue/` 目录下通过。

## Dev Tasks

- [x] 重构 `AdvancedAnalysis.vue`：
  - [x] 引入 `defineAsyncComponent`。
  - [x] 将 `AssociationRules`、`UserSegmentation`、`AnomalyDetection`、`ComparisonAnalysis` 改为动态 import。
  - [x] 为异步 tab 内容提供 `loadingComponent` 或 Element Plus 加载态 / 骨架屏。
  - [x] 保留现有 tab name 和默认 `activeTab = "association"`。
- [x] 重构 `Dashboard.vue` 的图表加载：
  - [x] 将非默认图表组件改为 `defineAsyncComponent` 动态 import。
  - [x] 用 `v-if` 或动态 `<component>` 替换会立即挂载所有图表的 `v-show` 路径。
  - [x] 当前图表切换时，确保仅当前图表组件加载和挂载。
  - [x] 为图表区域保留固定高度占位，避免异步加载时页面跳动。
- [x] 延后收入趋势 ECharts 初始化：
  - [x] 移除 `Dashboard.vue` 顶层 `import * as echarts from "echarts"`。
  - [x] 新增 `loadEcharts()` helper，缓存动态 import 结果。
  - [x] `initRevenueTrendChart()` 等待 ECharts 加载完成后再 `init`。
  - [x] 处理组件卸载时动态 import 仍在进行的情况，避免卸载后继续初始化图表。
- [x] 整理导出和 resize：
  - [x] 导出前判断当前图表是否已加载且可读取 data URL。
  - [x] 未加载完成时使用 `ElMessage.warning` 提示。
  - [x] `handleResize()` 只 resize 当前已存在的图表实例或当前组件 ref。
- [x] 调整构建拆包（如有必要）：
  - [x] 保持 `vue/vite.config.js` 现有 `manualChunks` 与 Vite/Rolldown 兼容。
  - [x] 如 ECharts 仍被打入过大的同步 chunk，可增加函数式 `manualChunks` 分支，将 `echarts` / `zrender` / `echarts-wordcloud` 拆到独立 chunk。
- [x] 运行搜索与构建验证。

## Suggested Implementation Notes

`AdvancedAnalysis.vue` 的基本形态可以是：

```js
import { defineAsyncComponent, ref } from "vue";

const AssociationRules = defineAsyncComponent(() =>
  import("@/components/admin/analysis/AssociationRules.vue"),
);
```

`Dashboard.vue` 中 ECharts 可用缓存式动态加载：

```js
let echartsModule = null;
let isUnmounted = false;

const loadEcharts = async () => {
  if (!echartsModule) {
    echartsModule = await import("echarts");
  }
  return echartsModule;
};

const initRevenueTrendChart = async () => {
  await nextTick();
  if (isUnmounted || !revenueTrendChartRef.value) return;
  const echarts = await loadEcharts();
  if (isUnmounted || !revenueTrendChartRef.value) return;
  revenueTrendChart = echarts.init(revenueTrendChartRef.value);
  revenueTrendChart.setOption(getRevenueTrendBaseOption());
};
```

非默认图表组件如果继续使用当前多个 ref，也可以先保持显式模板结构，只把静态 import 改为 async component，并把 `v-show` 改为 `v-if`：

```vue
<OrdersTrendChart
  v-if="isOrdersTrend"
  ref="ordersTrendChartComponentRef"
  :start-date="chartStartDate"
  :end-date="chartEndDate"
  :height="chartHeight"
  :active="isOrdersTrend"
  :refresh-key="ordersTrendRefreshKey"
/>
```

## Verification

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "import \* as echarts|from ['\"]echarts['\"]" vue/src/views/admin/Dashboard.vue vue/src/views/admin/AdvancedAnalysis.vue
rg -n "defineAsyncComponent|import\\(" vue/src/views/admin/Dashboard.vue vue/src/views/admin/AdvancedAnalysis.vue
rg -n "axios\.create" vue/src/views/admin vue/src/components/admin
```

Expected result:

- First search returns no static ECharts import from the two admin view files.
- Second search shows dynamic imports for Dashboard chart panels and AdvancedAnalysis tab panels.
- Third search returns no component-level Axios instance creation.
- Build passes and build output includes separate async chunks for at least some chart / analysis panels.

Manual smoke path:

1. Login as `ADMIN` or `WINDOW_MANAGER` and enter `/admin/dashboard`.
2. Confirm welcome metrics render before chart interaction and no console error appears.
3. Switch chart type from revenue trend to orders trend, hot dish ranking, review keywords, and word cloud.
4. Use refresh and export on the active chart.
5. Enter `/admin/advanced-analysis`, switch all tabs once, and confirm each panel loads without blank screen or route error.

## Dependencies

- ST-001 completed, shared Axios client and Vite build remain stable.
- ST-002 should be completed or admin route access should remain available for manual smoke testing.
- Existing statistics APIs and `vue/src/api/statistics.js` method names remain unchanged.
- Existing chart components continue to expose `getDataURL` where export depends on it.

## Out of Scope

- 数据看板 mock 数据开关和空数据兜底；这属于 ST-017 / ST-018。
- 图表视觉重设计、指标口径调整或统计接口重写。
- 推荐组件、学生端首页和小程序性能治理。
- 引入新的图表库、虚拟滚动库或全局性能监控平台。

## Dev Agent Record

Completed At: 2026-05-18

Files Changed:

- `vue/src/views/admin/Dashboard.vue`
- `vue/src/views/admin/AdvancedAnalysis.vue`
- `vue/src/components/admin/HotDishRanking.vue`
- `vue/vite.config.js`
- `docs/stories/ST-004-lazy-load-charts-advanced-analysis.md`
- `docs/sprint-status.yaml`

Implementation Notes:

- `AdvancedAnalysis.vue` now lazy-loads each analysis tab with `defineAsyncComponent` and an Element Plus skeleton loading state.
- `Dashboard.vue` now lazy-loads non-default chart panels and uses `v-if` so inactive panels are not mounted.
- Revenue trend ECharts initialization now uses cached dynamic `import("echarts")` and guards against initialization after component unmount.
- `HotDishRanking.vue` now exposes `getDataURL` and `resize` so Dashboard export and resize flows can treat it like the other chart panels.
- `vite.config.js` now emits `echarts`, `zrender`, and `echarts-wordcloud` into a `charts` chunk while preserving the function-style `manualChunks` required by the current Vite/Rolldown build.

Validation:

- `npm run build` passed in `vue/`.
- Static ECharts import search in `Dashboard.vue` and `AdvancedAnalysis.vue` returned no matches.
- `rg -n 'defineAsyncComponent|import\(' vue/src/views/admin/Dashboard.vue vue/src/views/admin/AdvancedAnalysis.vue` shows dynamic imports for Dashboard chart panels, AdvancedAnalysis panels, and revenue ECharts.
- `rg -n 'axios\.create' vue/src/views/admin vue/src/components/admin` returned no matches.
- Build output includes separate async chunks such as `Dashboard-*.js`, `OrdersTrendChart-*.js`, `HotDishRanking-*.js`, `AssociationRules-*.js`, `UserSegmentation-*.js`, and `charts-*.js`.
