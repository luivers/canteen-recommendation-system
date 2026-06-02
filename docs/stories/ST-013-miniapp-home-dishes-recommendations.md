# Story ST-013: 小程序首页、菜品列表、详情和推荐展示

Status: Completed

Epic: EPIC-005 微信小程序学生端  
Priority: Must  
Estimate: 5 points  
Planned Day: D4  
Primary Files: `miniapp/pages/index/*`, `miniapp/pages/dishes/*`, `miniapp/pages/dish-detail/*`, `miniapp/api/dish.js`, `miniapp/api/recommendation.js`  
Likely Touch Points: `miniapp/app.json`, `miniapp/app.wxss`, `miniapp/utils/*`, `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为微信小程序学生用户，我希望在首页看到热门菜品、推荐菜品和健康推荐入口，并能进入菜品列表按分类、关键词筛选，再打开菜品详情查看价格、窗口、库存、评分、口味标签和营养信息，这样我可以在下单前快速判断今天吃什么。

## Context

ST-011 已创建原生微信小程序骨架和统一 request 封装；ST-012 已完成 `wx.login` 静默登录与 JWT 存储。后端已有 `/api/dishes`、`/api/dishes/{dishId}`、`/api/dishes/categories`、`/api/dishes/hot`、`/api/dishes/search` 以及 `/api/recommendations/*` 接口，且 `/api/dishes/**` 与 `/api/recommendations/**` 允许未登录访问并可在有 token 时提供个性化能力。

本故事聚焦浏览与推荐展示，不实现购物车加购、下单、支付和评价提交流程；这些属于 ST-014 到 ST-016。

## Acceptance Criteria

1. 小程序 `app.json` 新增可打开的菜品列表页和菜品详情页路径。
2. 首页不再是占位内容，启动后并行加载热门菜品、个性化推荐、健康目标推荐或等价推荐数据。
3. 首页展示推荐分区，包含菜品名称、价格、窗口/食堂、评分或销量、推荐理由/健康标签等可扫描信息。
4. 首页提供进入菜品列表和进入菜品详情的交互；空数据和请求失败时显示清晰降级状态，不阻塞页面渲染。
5. 新增菜品列表页，支持分页加载 `/api/dishes`，并展示列表总数、加载状态和“没有更多”状态。
6. 菜品列表页支持分类筛选，分类来源于 `/api/dishes/categories`；支持全部分类回退。
7. 菜品列表页支持关键词搜索，关键词不为空时调用 `/api/dishes/search`，清空后回到普通列表。
8. 菜品列表项展示图片或稳定占位、价格、分类、窗口/食堂、评分、销量、库存/售罄状态和口味标签。
9. 新增菜品详情页，通过路由参数 `id` 调用 `/api/dishes/{dishId}`；缺少 id 或接口失败时展示明确错误。
10. 菜品详情页展示主信息、促销价、窗口位置、状态、评分、销量、口味标签和营养信息。
11. 小程序端新增数据归一化工具，兼容后端返回数组、`{ data: { content } }`、`{ data: dish }` 和健康推荐 DTO 中的 `recommendations`。
12. 新增或更新 API 模块，暴露 ST-013 需要的推荐接口，不改变现有 ST-011/ST-012 登录和 request 行为。
13. 执行小程序 JS 语法检查与关键契约搜索；如微信开发者工具 CLI 不可用，记录原因。

## Dev Tasks

- [x] 创建故事文档和状态更新：
  - [x] 新增 ST-013 故事文档。
  - [x] 更新 `docs/stories/README.md`、`docs/sprint-status.yaml` 和 `docs/bmm-workflow-status.yaml`。
- [x] 完成小程序数据层：
  - [x] 扩展 `miniapp/api/recommendation.js`。
  - [x] 新增菜品/推荐响应归一化工具。
- [x] 完成首页真实数据展示：
  - [x] 加载热门、个性化和健康目标推荐。
  - [x] 提供列表和详情跳转。
  - [x] 增加空状态和错误降级。
- [x] 完成菜品列表页：
  - [x] 新增 `miniapp/pages/dishes/*`。
  - [x] 支持分页、搜索、分类筛选和触底加载。
- [x] 完成菜品详情页：
  - [x] 新增 `miniapp/pages/dish-detail/*`。
  - [x] 展示菜品详情、营养和状态信息。
- [x] 添加验证：
  - [x] 执行 miniapp JS 语法检查。
  - [x] 搜索确认关键路由/API/组件契约。
  - [x] 记录验证结果到 Dev Agent Record。

## Suggested Implementation Notes

后端菜品列表可能返回两种结构：

```json
[
  { "id": 1, "name": "红烧肉", "price": 12 }
]
```

或分页结构：

```json
{
  "data": {
    "content": [
      { "id": 1, "name": "红烧肉", "price": 12 }
    ],
    "totalElements": 42,
    "totalPages": 4,
    "number": 0,
    "size": 12
  }
}
```

小程序端需要统一转成 `{ items, totalElements, totalPages, page, size }`，避免页面直接耦合后端响应形状。

## Verification

Run from repo root:

```powershell
node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"
rg -n "pages/dishes/dishes|pages/dish-detail/dish-detail|getHotDishes|getPersonalizedRecommendations|getRecentHealthGoalRecommendations|normalizeDish|normalizeDishPage|wx.navigateTo" miniapp
```

Expected result:

- 首页、菜品列表页和详情页均有真实数据加载逻辑。
- 菜品列表支持分页、搜索和分类筛选。
- 菜品详情页通过 `id` 参数请求后端详情。
- 推荐接口和健康目标 DTO 归一化后能稳定展示。

## Dependencies

- ST-011 已完成小程序工程骨架、request 封装和基础页面。
- ST-012 已完成小程序 JWT 登录和 token 注入。
- 后端已有菜品与推荐 REST API。

## Out of Scope

- 加入购物车、下单、订单列表和订单详情轮询；这些属于 ST-014。
- `wx.requestPayment` 拉起和支付失败 / 取消提示；这些属于 ST-015。
- 评价、个人中心和积分商城完整流程；这些属于 ST-016。

## Dev Agent Record

Created At: 2026-06-02  
Completed At: 2026-06-02

Files Changed:

- `docs/stories/ST-013-miniapp-home-dishes-recommendations.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `miniapp/app.json`
- `miniapp/api/recommendation.js`
- `miniapp/utils/dish.js`
- `miniapp/pages/index/index.js`
- `miniapp/pages/index/index.wxml`
- `miniapp/pages/index/index.wxss`
- `miniapp/pages/dishes/dishes.js`
- `miniapp/pages/dishes/dishes.wxml`
- `miniapp/pages/dishes/dishes.wxss`
- `miniapp/pages/dishes/dishes.json`
- `miniapp/pages/dish-detail/dish-detail.js`
- `miniapp/pages/dish-detail/dish-detail.wxml`
- `miniapp/pages/dish-detail/dish-detail.wxss`
- `miniapp/pages/dish-detail/dish-detail.json`

Implementation Notes:

- Added dish response normalization for list, paged list, detail, reason recommendations and health-goal recommendations.
- Added category label-to-enum mapping so the Chinese `/api/dishes/categories` response can still drive backend enum filtering.
- Replaced the miniapp home placeholder with hot dishes, personalized recommendations and health recommendations.
- Added a native miniapp dish list page with category filter, search, pagination, pull-down refresh and reach-bottom loading.
- Added a native miniapp dish detail page with dish status, promotion price, window details, rating/sales and nutrition fields.
- Extended miniapp recommendation API with reason, discovery, today-new and today-personalized-hot helpers.

Validation:

- `node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"` passed with 19 JS files.
- `rg -n "pages/dishes/dishes|pages/dish-detail/dish-detail|getHotDishes|getPersonalizedRecommendations|getRecentHealthGoalRecommendations|normalizeDish|normalizeDishPage|wx.navigateTo" miniapp` passed.
- WeChat DevTools CLI path is configured at `C:\Program Files (x86)\Tencent\微信web开发者工具\cli.bat`; CLI `help` runs successfully. `islogin` still requires 微信开发者工具的 Settings > Security > Service Port to be enabled, otherwise it times out by design.
