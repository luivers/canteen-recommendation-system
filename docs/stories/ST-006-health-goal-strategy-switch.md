# Story ST-006: 增强健康目标推荐入口与策略切换体验

Status: Completed

Epic: EPIC-002 推荐体验与可解释性  
Priority: Must  
Estimate: 2 points  
Planned Day: D2  
Primary Files: `vue/src/views/Home.vue`, `vue/src/components/SmartRecommend.vue`, `vue/src/api/recommendation.js`  
Likely Touch Points: `java/src/main/java/com/school/canteen/controller/RecommendationController.java`, `java/src/main/java/com/school/canteen/dto/HealthGoalRecommendationResponse.java`, `java/src/main/java/com/school/canteen/service/HealthGoalRecommendationService.java`

## Story

作为学生用户，我希望在首页可以清楚地切换推荐策略，并能一眼理解健康目标推荐为什么适合我，以便我根据当前诉求选择“个性化、相似同学、口味匹配、情景、热门”或健康目标推荐，而不是只能被动接收默认推荐列表。

## Context

PRD FR-017 要求多策略推荐可单独调用，FR-019 要求健康目标推荐覆盖 `HIGH_PROTEIN / LOW_FAT / CONTROL_CARBS / CONTROL_CALORIES`，推荐旅程也明确包含“选择策略或健康目标 → 查看推荐结果 + 推荐理由 → 加购或查看详情”。ST-005 已完成 SmartRecommend 推荐理由 chip，但它明确把“健康目标推荐入口、目标筛选器和策略切换体验”留给 ST-006。

当前 `SmartRecommend.vue` 主要自动拉取带理由的个性化推荐，并在失败后降级到 `context / popular`；用户无法主动切换策略。`Home.vue` 已有“智能健康目标推荐”区块，调用 `recommendationApi.getHealthGoalRecommendations(4, refreshToken)` 展示后端推断出的目标和推荐菜品，但入口说明、目标状态、刷新反馈和异常兜底还不够明确。

本故事只增强 Web 首页的推荐入口与交互体验，不重写推荐算法，不调整健康目标评分模型，不改支付 / 订单 / 小程序流程，也不重构首页其他推荐区块。

## Acceptance Criteria

1. `SmartRecommend.vue` 增加策略切换控件，至少包含：
   - 综合推荐：优先使用 `getPersonalizedRecommendationsWithReason(4)`，保留 ST-005 的理由 chip。
   - 相似同学：调用 `getRecommendationsByStrategy("collaborative", 4)`。
   - 口味匹配：调用 `getRecommendationsByStrategy("content", 4)`。
   - 情景推荐：调用 `getRecommendationsByStrategy("context", 4)`。
   - 热门推荐：调用 `getRecommendationsByStrategy("popular", 4)`。
2. 策略切换控件必须用中文标签展示，并在当前策略上有清晰选中态；切换时只刷新 SmartRecommend 当前卡片列表，不触发首页其他推荐区块重载。
3. 策略请求失败、返回空列表或用户未登录导致个性化推荐不可用时，组件必须保留现有降级路径，最终至少尝试 `popular` 兜底，并给出用户可见的空态或错误提示。
4. SmartRecommend 的卡片归一化逻辑继续兼容 ST-005 的字段约定：`id / dishId`、`image / imageUrl`、`reason / recommendSource / recommendReason`、价格、分类、热量、可售状态。
5. 切换到非“综合推荐”策略后，卡片仍必须显示中文理由 chip；若后端未返回理由，应根据策略类型映射为简短中文理由，例如“相似同学常点”“匹配你的口味”“符合当前情景”“近期人气很高”。
6. `vue/src/api/recommendation.js` 保持清晰的推荐 API 封装，不新增组件内 `axios.create`；如需补充 helper，应继续复用 `vue/src/api/index.js` 的共享 Axios 实例。
7. `Home.vue` 的“智能健康目标推荐”入口应更像可操作的推荐模块：展示后端返回的健康目标、目标说明、推荐菜品和刷新按钮，并区分加载态、空态、错误态。
8. 健康目标推荐区必须稳定展示 7 日营养画像或目标依据中的关键字段；如果 `profile7d` 缺失，也要用明确中文兜底文案，不显示 `undefined` / `null`。
9. 健康目标标签必须可读且不撑破布局；桌面端四列推荐卡片和移动端单列布局下，目标标签、营养信息、按钮不发生重叠或文本溢出。
10. 健康目标刷新按钮应调用 `getHealthGoalRecommendations(limit, refreshToken)` 或等价封装；刷新过程中按钮 loading 可见，刷新失败时保留旧数据或显示明确空态，不能直接清空导致页面跳动。
11. 健康目标推荐菜品继续支持查看详情和加入购物车；事件行为与首页其他菜品卡片一致，不绕过现有 `showDishDetail` / `addToCart` 流程。
12. 不在本故事中引入新的推荐策略枚举到后端，除非前端发现现有接口无法满足“策略切换”最小验收；若必须改后端，只做兼容性映射，不改变算法权重。
13. `npm run build` 在 `vue/` 目录下通过。

## Dev Tasks

- [x] 增强 SmartRecommend 策略切换：
  - [x] 定义策略配置表，包含中文标签、接口 strategy type、默认理由文案和是否使用带理由个性化接口。
  - [x] 增加策略切换 UI，并绑定当前策略状态。
  - [x] 调整 `fetchRecommendations()`，根据当前策略调用个性化带理由接口或 `getRecommendationsByStrategy()`。
  - [x] 保留刷新按钮，刷新当前策略而不是重置到默认策略。
- [x] 完善 SmartRecommend 数据与理由兜底：
  - [x] 继续复用或整理 `normalizeRecommendationList()`、`formatDishData()`、`resolveRecommendReason()`。
  - [x] 为 `collaborative/content/context/popular` 映射中文理由。
  - [x] 保证策略切换后的卡片详情与加购 emit 参数稳定。
- [x] 增强 Home 健康目标推荐区：
  - [x] 展示 `profile7d` 的关键营养画像或清晰兜底说明。
  - [x] 优化 `healthGoals` 的标签、说明和当前推荐关系展示。
  - [x] 调整刷新失败行为，尽量保留旧 `healthGoals` / `healthRecs`，并展示用户可见提示。
  - [x] 检查 `formatHealthRecs()` 对图片、窗口、食堂、营养字段、健康标签的归一化。
- [x] 校验 API 封装：
  - [x] 确认 `getRecommendationsByStrategy(strategyType, limit)` 使用的策略值与后端一致：`collaborative`、`content`、`context`、`popular`。
  - [x] 确认 `getHealthGoalRecommendations(limit, refreshToken)` 调用 `/api/recommendations/health-goals`。
  - [x] 不新增组件内 Axios 实例。
- [x] 运行搜索与构建验证。

## Suggested Implementation Notes

策略配置可以放在 `SmartRecommend.vue` 的脚本区，避免模板里散落分支：

```js
const recommendationModes = [
  { key: "personalized", label: "综合推荐", reason: "为你个性推荐", withReason: true },
  { key: "collaborative", label: "相似同学", reason: "相似同学常点" },
  { key: "content", label: "口味匹配", reason: "匹配你的口味" },
  { key: "context", label: "情景推荐", reason: "符合当前情景" },
  { key: "popular", label: "热门推荐", reason: "近期人气很高" },
];
```

`fetchRecommendations()` 可以按当前模式选择接口；非综合策略返回的菜品如果没有后端理由，把当前模式的 `reason` 注入归一化流程即可。注意后端协同过滤策略名是 `collaborative`，不是推荐理由里常见的 `cf`。

健康目标区不必强行新增后端筛选参数。当前 `/api/recommendations/health-goals` 已返回 `profile7d`、`goals` 和 `recommendations`，本故事优先把这些信息展示清楚；只有在接口契约确实缺字段时，再做小范围兼容补充。

## Verification

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "collaborative|content|context|popular|getRecommendationsByStrategy|getHealthGoalRecommendations|health-goals|profile7d" vue/src/components/SmartRecommend.vue vue/src/views/Home.vue vue/src/api/recommendation.js
rg -n "axios\.create" vue/src/components/SmartRecommend.vue vue/src/views/Home.vue vue/src/api/recommendation.js
```

Expected result:

- First search shows SmartRecommend can switch between supported strategies and Home still uses health-goal recommendations.
- Second search returns no component-level Axios instance creation.
- Build passes.
- Manual smoke path passes: login as student, enter 首页, switch each SmartRecommend strategy, refresh current strategy, verify reason chips remain Chinese; health goal section shows goals/profile context, refreshes with loading state, and card detail/add-to-cart still work.

## Dependencies

- ST-001 completed, shared Axios client remains stable.
- ST-005 completed, SmartRecommend reason chip and recommendation normalization are available.
- Backend `/api/recommendations/strategy/{type}` supports `collaborative`、`content`、`context`、`popular` strategy types.
- Backend `/api/recommendations/health-goals` returns `profile7d`、`goals`、`recommendations` and accepts `limit` / `refreshToken`.

## Out of Scope

- Recommendation ranking algorithm changes, fusion weight tuning, or new strategy implementation.
- Redesign of 首页 “今日上新 / 你可能喜欢 / 今日个性化热门 / 促销栏” sections.
- Backend health scoring model changes beyond minimal response compatibility.
- Payment, order status, SSE, miniapp, admin analytics, and Redis cache policy changes.

## Dev Agent Record

Completed At: 2026-05-18

Files Changed:

- `vue/src/components/SmartRecommend.vue`
- `vue/src/views/Home.vue`
- `docs/stories/ST-006-health-goal-strategy-switch.md`
- `docs/sprint-status.yaml`

Implementation Notes:

- SmartRecommend now exposes a segmented strategy selector for 综合推荐、相似同学、口味匹配、情景推荐 and 热门推荐.
- The selected mode controls the recommendation API call, while the refresh button reloads the current mode instead of resetting to the default.
- Non-reason strategy responses now receive short Chinese reason-chip fallbacks based on the selected strategy.
- The health-goal section now shows profile-derived nutrition metrics, goal descriptions, explicit empty/error states, and preserves previous recommendations when refresh fails.
- Health recommendation cards now use responsive Element Plus column breakpoints for desktop and mobile layouts.

Validation:

- `npm run build` passed in `vue/`.
- `rg -n "collaborative|content|context|popular|getRecommendationsByStrategy|getHealthGoalRecommendations|health-goals|profile7d" vue/src/components/SmartRecommend.vue vue/src/views/Home.vue vue/src/api/recommendation.js` shows strategy switching and health-goal wiring.
- `rg -n "axios\.create" vue/src/components/SmartRecommend.vue vue/src/views/Home.vue vue/src/api/recommendation.js` returned no matches.
