# Story ST-005: SmartRecommend 展示推荐理由 chip

Status: Completed

Epic: EPIC-002 推荐体验与可解释性  
Priority: Must  
Estimate: 2 points  
Planned Day: D2  
Primary Files: `vue/src/components/SmartRecommend.vue`, `vue/src/api/recommendation.js`  
Likely Touch Points: `vue/src/views/Home.vue`, `java/src/main/java/com/school/canteen/service/impl/RecommendationServiceImpl.java`

## Story

作为学生用户，我希望首页 SmartRecommend 推荐卡片直接展示简短、可信的中文推荐理由，以便我知道系统为什么推荐这道菜，并能更快决定查看详情或加入购物车。

## Context

PRD FR-018 要求 `GET /api/recommendations/personalized/reasons` 返回每个菜品的推荐理由，并在前端 SmartRecommend 组件每张菜品卡片显示理由 chip。当前 `SmartRecommend.vue` 已在图片上展示 `recommend-reason-tag`，但推荐数据来自 `getRecommendationsByStrategy("context")`，理由主要由前端 `getRecommendReason(dish)` 根据时间、天气、季节和分类即时生成，尚未优先使用后端返回的 `reason` / `recommendSource` 等可解释字段。

本故事只治理 SmartRecommend 的推荐理由展示与数据归一化，不重写推荐算法，不改健康目标推荐入口，不调整首页其他推荐区块，也不改变加购 / 详情弹窗流程。

## Acceptance Criteria

1. `SmartRecommend.vue` 获取推荐时优先调用 `recommendationApi.getPersonalizedRecommendationsWithReason(4)` 或等价封装；若接口失败、返回空列表或用户未登录导致个性化结果不可用，应降级到现有 context / popular 推荐路径，并保持组件可用。
2. `vue/src/api/recommendation.js` 保留或补充清晰的带理由推荐方法，调用路径为 `/api/recommendations/personalized/reasons`，并支持 `limit` 参数。
3. SmartRecommend 对推荐响应做稳定归一化，至少兼容以下字段：
   - 菜品 ID：`id` / `dishId`
   - 图片：`image` / `imageUrl`
   - 推荐理由：`reason` / `recommendSource` / `recommendReason`
   - 分类、价格、热量、状态等现有显示字段
4. 每张推荐卡片必须展示一个理由 chip；后端有理由字段时优先使用后端理由，后端缺失时才使用前端兜底理由。
5. 理由 chip 文案必须为中文、简短、可读，展示长度控制在 20 个中文字符以内；过长理由应截断或压缩，不撑破卡片布局。
6. 理由 chip 不得遮挡菜品名称、价格、按钮或关键图片主体；在移动端单列和桌面端四列布局下都不应发生文本溢出或按钮挤压。
7. 推荐理由应避免空值、`undefined`、`null`、英文策略枚举值直接显示；无法识别时使用明确中文兜底文案，例如 `智能优选`。
8. SmartRecommend 刷新按钮继续可用；刷新时应重新拉取推荐和理由，加载中状态、空状态、错误提示保持用户可见。
9. 点击卡片查看详情和点击加入购物车的现有事件行为保持不变：`show-detail` 和 `add-to-cart` emit 参数仍是归一化后的菜品对象。
10. 不新增组件内 `axios.create`，不绕过 `vue/src/api/index.js` 的共享 Axios 实例。
11. `npm run build` 在 `vue/` 目录下通过。

## Dev Tasks

- [x] 调整推荐 API 使用：
  - [x] 确认 `recommendationApi.getPersonalizedRecommendationsWithReason(limit)` 存在并调用 `/api/recommendations/personalized/reasons`。
  - [x] 如需新增 helper，保持和现有 `recommendation.js` 风格一致，不创建新的 Axios 实例。
- [x] 重构 `SmartRecommend.vue` 数据加载：
  - [x] `fetchRecommendations()` 优先请求带理由的个性化推荐。
  - [x] 增加降级路径：带理由接口失败或返回空列表时，再使用现有 context / popular 推荐。
  - [x] 保留刷新按钮、加载态、空态和错误提示。
- [x] 完善推荐数据归一化：
  - [x] 在 `formatDishData()` 或邻近 helper 中统一 `id`、`image`、`available`、`price`、`calories` 等字段。
  - [x] 归一化 `recommendReason` 字段，优先读取 `reason`、`recommendSource`、`recommendReason`。
  - [x] 增加理由文案清洗函数，处理空值、英文枚举、超长文本和非字符串值。
- [x] 调整理由 chip 渲染：
  - [x] 模板中使用归一化后的理由字段展示 chip。
  - [x] 保留前端 `getRecommendReason(dish)` 作为兜底逻辑，而不是作为主数据来源。
  - [x] CSS 保证 chip 在桌面和移动端不溢出、不挤压卡片操作按钮。
- [x] 运行搜索与构建验证。

## Suggested Implementation Notes

理由选择可以收口成一个小 helper，避免模板里堆字段判断：

```js
const normalizeReasonText = (value) => {
  const text = String(value || "").trim();
  if (!text || text === "undefined" || text === "null") return "";
  return text.length > 20 ? `${text.slice(0, 20)}...` : text;
};

const resolveRecommendReason = (dish) => {
  return (
    normalizeReasonText(dish.reason) ||
    normalizeReasonText(dish.recommendSource) ||
    normalizeReasonText(dish.recommendReason) ||
    normalizeReasonText(getRecommendReason(dish)) ||
    "智能优选"
  );
};
```

`fetchRecommendations()` 可以保持简单的优先 / 降级结构：

```js
const fetchRecommendations = async () => {
  loading.value = true;
  try {
    const reasonRes = await recommendationApi.getPersonalizedRecommendationsWithReason(4);
    const reasonList = normalizeRecommendationList(reasonRes);
    if (reasonList.length > 0) {
      dishes.value = formatDishData(reasonList);
      return;
    }

    const fallbackRes = await recommendationApi.getRecommendationsByStrategy("context", 4);
    dishes.value = formatDishData(normalizeRecommendationList(fallbackRes));
  } catch (e) {
    ElMessage.error("智能推荐加载失败");
  } finally {
    loading.value = false;
  }
};
```

如果希望带理由接口失败时仍显示 fallback，注意不要在第一个请求的 `catch` 中直接结束整个流程；可以将 fallback 提取为独立函数。

## Verification

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "personalized/reasons|getPersonalizedRecommendationsWithReason|recommendReason|recommendSource|reason" vue/src/components/SmartRecommend.vue vue/src/api/recommendation.js
rg -n "axios\.create" vue/src/components/SmartRecommend.vue vue/src/api/recommendation.js
```

Expected result:

- First search shows SmartRecommend uses the reason-aware recommendation API or normalized reason fields.
- Second search returns no matches.
- Build passes.
- Manual smoke path passes: login as student, enter 首页, SmartRecommend cards show short Chinese reason chips; refresh keeps reasons visible; card detail and add-to-cart still work.

## Dependencies

- ST-001 completed, shared Axios client remains stable.
- Backend `GET /api/recommendations/personalized/reasons` returns a list of dish-like objects with `reason` and/or `recommendSource`.
- Existing `RecommendationServiceImpl.getPersonalizedRecommendationsWithReason()` continues to include dish display fields needed by the card.

## Out of Scope

- Recommendation ranking algorithm changes or strategy weight tuning.
- Health goal recommendation入口、目标筛选器和策略切换体验；这些属于 ST-006。
- 首页 “今日上新 / 你可能喜欢 / 优惠套餐” 等其他推荐区块的视觉重构。
- 后台推荐分析、缓存失效策略和 Redis 配置调整。

## Dev Agent Record

Completed At: 2026-05-18

Files Changed:

- `vue/src/components/SmartRecommend.vue`
- `docs/stories/ST-005-smartrecommend-reason-chip.md`
- `docs/sprint-status.yaml`

Implementation Notes:

- SmartRecommend now tries `getPersonalizedRecommendationsWithReason(4)` first and falls back to context, then popular, strategy recommendations.
- Recommendation responses are normalized for array, `recommendations`, `content`, `records`, and `rows` payload shapes.
- Card reason chips now render a normalized `recommendReason` that prefers backend `reason`, `recommendSource`, and `recommendReason`, maps common strategy tags to Chinese labels, filters invalid values, and caps text at 20 characters.
- Reason chip CSS now constrains width and ellipsis behavior so it stays inside the image area across card widths.

Validation:

- `npm run build` passed in `vue/`.
- `rg -n "personalized/reasons|getPersonalizedRecommendationsWithReason|recommendReason|recommendSource|reason|axios\.create" vue/src/components/SmartRecommend.vue vue/src/api/recommendation.js` shows the reason-aware API and normalized fields; no `axios.create` matches were present.
