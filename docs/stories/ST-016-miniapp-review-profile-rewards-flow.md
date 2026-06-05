# Story ST-016: 小程序评价、个人中心和积分商城主流流程

Status: Completed

Epic: EPIC-005 微信小程序学生端  
Priority: Must  
Estimate: 5 points  
Planned Day: D5  
Primary Files: `miniapp/pages/profile/*`, `miniapp/pages/orders/*`, `miniapp/pages/order-detail/*`, `miniapp/api/user.js`, `miniapp/api/review.js`, `miniapp/api/rewards.js`, `miniapp/api/points.js`  
Likely Touch Points: `miniapp/app.json`, `miniapp/api/index.js`, `miniapp/utils/auth.js`, `miniapp/utils/order.js`, `miniapp/utils/request.js`, `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为微信小程序学生端用户，我希望在支付并完成取餐后可以评价订单，在“我的”页面查看个人信息、积分余额、积分流水、我的评价、优惠券和兑换记录，并能进入积分商城兑换可用奖励，这样小程序可以覆盖从点餐、支付、取餐到评价和积分激励的完整演示闭环。

## Context

ST-011 到 ST-015 已完成小程序工程骨架、静默登录、菜品浏览、购物车下单、订单轮询和 mock 支付联调。当前 `profile` 页面仍以登录状态展示为主，还没有承接评价、积分和兑换流程。

后端已有评价、积分和奖励相关接口：`GET /api/users/me`、`PUT /api/users/{userId}/preferences`、`POST /api/reviews`、`GET /api/reviews/order/{orderId}`、`GET /api/reviews/user/{userId}`、`GET /api/points/balance`、`GET /api/points/history/me`、`GET /api/rewards/page`、`GET /api/rewards/categories`、`POST /api/rewards/exchange/preview`、`POST /api/rewards/exchange`、`GET /api/rewards/exchanges/page`、`GET /api/rewards/vouchers/my`。本故事聚焦小程序端主流程串接和响应归一化，不改造后台管理能力。

## Acceptance Criteria

1. `miniapp/api/index.js` 导出评价、积分和积分商城 API 模块；页面不得硬编码后端 URL。
2. `miniapp/api/user.js` 保留 `loginByCode()`、`getCurrentUser()`，并新增或复用个人偏好更新能力，能调用 `PUT /api/users/{userId}/preferences`。
3. 新增 `miniapp/api/review.js`，至少封装创建评价、查询订单评价、查询我的评价；创建评价使用后端要求的 `multipart/form-data` 结构，包含 `review` JSON part 和可选图片。
4. 新增 `miniapp/api/points.js`，封装积分余额和我的积分流水查询，并兼容后端返回 `{ data: { points } }`、裸数组、分页字段混合等响应形状。
5. 新增 `miniapp/api/rewards.js`，封装奖励分页、分类、兑换预览、确认兑换、我的兑换记录和我的优惠券查询。
6. 订单详情页对已支付、已完成或已取餐订单展示评价入口；待支付、已取消等不可评价状态不展示提交入口。
7. 若订单已有评价，订单详情页展示评价摘要并阻止重复提交；可通过 `GET /api/reviews/order/{orderId}` 判断。
8. 评价提交支持总体评分、文字内容、菜品维度评分或标签等后端 DTO 可接收字段；必填项缺失时在小程序端给出明确提示。
9. 评价提交过程中按钮进入 loading/disabled 状态，重复点击不会创建并发评价请求。
10. 评价提交成功后刷新订单详情或评价状态，并展示积分奖励相关提示；如果后端没有返回奖励明细，也要给出评价成功的稳定反馈。
11. 评价提交失败时展示后端业务错误或网络错误，不清空用户已输入内容。
12. 个人中心页面不再只显示占位登录状态；登录后展示头像或占位头像、昵称/用户名、学号、角色、积分余额和常用入口。
13. 个人中心支持手动刷新用户信息与积分余额；未登录或 token 失效时能触发 ST-012 的静默登录重试或展示可重试提示。
14. 个人中心提供入口进入我的评价、积分流水、积分商城、我的兑换记录和我的优惠券；入口文案和空状态清晰可扫。
15. 积分流水页面支持分页加载、下拉刷新、空状态和积分增减方向展示。
16. 我的评价页面支持按当前用户加载评价列表，展示订单号、评分、内容摘要、创建时间和商家回复摘要；空状态不报错。
17. 积分商城页面支持加载奖励分类、分页奖励列表、关键词或分类筛选、只看可兑换奖励，并展示所需积分、库存、有效期、类型和兑换状态。
18. 兑换前调用 `POST /api/rewards/exchange/preview` 展示积分余额、兑换后余额、奖励信息和必要收货字段；积分不足、库存不足或奖励不可用时禁用确认。
19. 确认兑换调用 `POST /api/rewards/exchange`，提交 `rewardId`、幂等 `requestId` 和后端需要的收货信息；兑换中按钮 loading/disabled，失败后允许重试但不得复用已成功的请求。
20. 兑换成功后刷新积分余额，并能进入我的兑换记录或优惠券页面查看结果。
21. 我的兑换记录页面支持分页和状态展示；我的优惠券页面支持未使用/已使用筛选，并展示面额、门槛、有效期和使用状态。
22. 所有新增页面写入 `miniapp/app.json`，需要进入 tab 页时使用 `wx.switchTab`，非 tab 页使用 `wx.navigateTo`。
23. 新增响应归一化工具时放在 `miniapp/utils` 或 API 层，页面只消费稳定字段，避免散落解析 `{ data }`、`content`、`totalPages` 等结构。
24. 执行小程序 JS 语法检查和关键契约搜索；如微信开发者工具 CLI 不可用，记录原因。

## Dev Tasks

- [x] 创建故事文档和状态更新：
  - [x] 新增 ST-016 故事文档。
  - [x] 更新 `docs/stories/README.md`、`docs/sprint-status.yaml` 和 `docs/bmm-workflow-status.yaml`。
- [x] 完成小程序 API 层：
  - [x] 新增 `miniapp/api/review.js`。
  - [x] 新增 `miniapp/api/points.js`。
  - [x] 新增 `miniapp/api/rewards.js`。
  - [x] 扩展 `miniapp/api/user.js` 的个人信息/偏好能力。
  - [x] 在 `miniapp/api/index.js` 统一导出新增 API。
- [x] 完成评价流程：
  - [x] 在订单详情页展示评价入口和已有评价摘要。
  - [x] 新增评价提交页或弹层。
  - [x] 实现评分、内容、可选图片/标签和提交状态保护。
  - [x] 提交成功后刷新订单详情、评价状态和积分提示。
- [x] 完成个人中心：
  - [x] 展示当前用户、积分余额和登录重试状态。
  - [x] 提供我的评价、积分流水、积分商城、兑换记录、优惠券入口。
  - [x] 支持刷新用户信息和积分余额。
- [x] 完成积分与商城页面：
  - [x] 新增积分流水页面。
  - [x] 新增我的评价页面。
  - [x] 新增积分商城页面和兑换确认流程。
  - [x] 新增兑换记录页面。
  - [x] 新增我的优惠券页面。
- [x] 完成验证：
  - [x] 执行 miniapp JS 语法检查。
  - [x] 搜索确认新增路由、API、评价提交、积分查询和兑换契约。
  - [x] 如可用，执行微信开发者工具 CLI 预览或构建级检查；不可用则记录原因。

## Suggested Implementation Notes

评价创建建议由 API 层负责封装 multipart，页面只传业务对象：

```javascript
reviewApi.createReview({
  orderId,
  rating,
  content,
  dishRatings,
  tags,
  images,
});
```

兑换请求建议在确认弹层打开时生成一次 `requestId`，用户取消后丢弃；只有确认兑换成功后才标记完成，避免重试时误用成功请求。

积分、奖励、兑换记录和优惠券建议统一转成分页结构：

```javascript
{
  items: [],
  total: 0,
  totalPages: 0,
  page: 0,
  size: 20,
}
```

## Verification

Run from repo root:

```powershell
node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"
rg -n "reviewApi|pointsApi|rewardsApi|createReview|getPoint|exchangeReward|getMyVouchers|getMyExchanges|pages/.*/.*" miniapp --glob '!node_modules'
rg -n "reviews/order|points/balance|points/history/me|rewards/page|rewards/exchange|vouchers/my" miniapp java/src/main/java/com/school/canteen/controller
```

Expected result:

- 订单详情可以进入评价流程，已评价订单不会重复提交。
- 个人中心展示真实用户信息、积分余额和主流程入口。
- 积分流水、我的评价、积分商城、兑换记录和优惠券页面能加载、刷新、分页和展示空状态。
- 兑换成功后积分余额刷新，兑换记录或优惠券可看到结果。

## Dependencies

- ST-011 已完成小程序工程骨架、request 封装和基础页面。
- ST-012 已完成小程序 JWT 登录和 token 注入。
- ST-014 已完成订单列表、订单详情和取餐确认。
- ST-015 已完成支付拉起、mock 支付成功和订单状态刷新。
- 后端已有评价、积分、奖励兑换和优惠券相关 REST API。

## Out of Scope

- Web 端评价、积分商城和后台管理页面改造。
- 后台奖励规则、评价奖励规则和优惠券管理能力。
- 真实微信支付、真实优惠券核销和线下收货履约。
- 后端订单状态机、评价奖励规则和积分结算逻辑重构。

## Dev Agent Record

Created At: 2026-06-05  
Completed At: 2026-06-05

Files Changed:

- `docs/stories/ST-016-miniapp-review-profile-rewards-flow.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `miniapp/app.json`
- `miniapp/api/index.js`
- `miniapp/api/user.js`
- `miniapp/api/review.js`
- `miniapp/api/points.js`
- `miniapp/api/rewards.js`
- `miniapp/utils/engagement.js`
- `miniapp/pages/order-detail/order-detail.js`
- `miniapp/pages/order-detail/order-detail.wxml`
- `miniapp/pages/order-detail/order-detail.wxss`
- `miniapp/pages/profile/profile.js`
- `miniapp/pages/profile/profile.wxml`
- `miniapp/pages/profile/profile.wxss`
- `miniapp/pages/review-submit/*`
- `miniapp/pages/points-history/*`
- `miniapp/pages/my-reviews/*`
- `miniapp/pages/rewards/*`
- `miniapp/pages/exchanges/*`
- `miniapp/pages/vouchers/*`

Implementation Notes:

- Added review, points and rewards API modules plus shared normalization for reviews, point logs, rewards, exchanges and vouchers.
- Added order-detail review lookup, existing-review summary and a review entry for paid/ready/completed orders.
- Added a review submission page using backend-compatible multipart `review` JSON part with taste, portion, price, hygiene and dish-item ratings.
- Replaced the profile placeholder with user info, points balance, refresh/login retry and entries for reviews, points, rewards, exchanges and vouchers.
- Added points history, my reviews, rewards mall, exchange records and vouchers pages with loading, empty states, pagination where applicable and exchange confirmation.
- Kept image selection in the review UI as optional presentation state; submission uses the stable JSON review part path to match the current backend `@RequestPart("review")` contract.

Validation:

- `node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"` passed with 31 JS files.
- `node -e "const fs=require('fs'); for (const f of ['miniapp/app.json','miniapp/project.config.json']) JSON.parse(fs.readFileSync(f,'utf8')); console.log('miniapp json config ok')"` passed.
- `rg -n "\.slice\(|\.join\(|indexOf\(|form\[|\w+\(" miniapp/pages --glob "*.wxml"` returned no matches.
- `rg -n "reviewApi|pointsApi|rewardsApi|createReview|getBalance|getMyHistory|exchangeReward|getMyVouchersPage|getMyExchangesPage|reviews/order|points/balance|points/history/me|rewards/page|rewards/exchange|vouchers/my|multipart/form-data" miniapp java/src/main/java/com/school/canteen/controller` passed.
- WeChat DevTools CLI `help` passed. Full `preview` was not run because `miniapp/project.config.json` uses `touristappid`, which is known to fail preview/upload AppID validation.
