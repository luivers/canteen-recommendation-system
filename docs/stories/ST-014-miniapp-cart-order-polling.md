# Story ST-014: 小程序购物车、下单、订单列表和订单详情轮询

Status: Completed

Epic: EPIC-005 微信小程序学生端  
Priority: Must  
Estimate: 5 points  
Planned Day: D5  
Primary Files: `miniapp/pages/cart/*`, `miniapp/pages/orders/*`, `miniapp/pages/order-detail/*`, `miniapp/api/order.js`, `miniapp/utils/order.js`  
Likely Touch Points: `miniapp/app.json`, `miniapp/pages/dishes/*`, `miniapp/pages/dish-detail/*`, `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为微信小程序学生用户，我希望能从菜品列表或详情加入购物车，在购物车调整数量并提交订单，然后在订单列表查看自己的订单，并打开订单详情通过 5 秒短轮询看到订单状态变化，这样小程序可以覆盖浏览到下单再到取餐状态跟踪的主流程。

## Context

ST-011 已完成原生微信小程序骨架和统一 request 封装，ST-012 已完成 `wx.login` 静默登录与 JWT 存储，ST-013 已完成首页、菜品列表、详情和推荐展示。后端已有 `/api/orders/cart/**`、`/api/orders`、`/api/orders/{orderId}`、取消订单和确认取餐接口。架构要求 Web 使用 SSE，小程序订单详情使用 5 秒短轮询。

本故事聚焦购物车、下单、订单列表和订单详情轮询；不实现 `wx.requestPayment` 拉起、支付取消/失败提示和 mock 支付联调，这些属于 ST-015。

## Acceptance Criteria

1. 小程序 `app.json` 新增可打开的订单详情页路径。
2. `miniapp/api/order.js` 暴露购物车获取、添加、更新、删除、清空以及订单创建、列表、详情、取消、确认取餐接口。
3. 菜品列表页可对可售菜品执行“加购”，且不打断原有打开详情交互。
4. 菜品详情页展示加入购物车入口；不可售菜品禁用加购。
5. 购物车页不再是占位内容，启动时加载 `/api/orders/cart` 并展示商品、价格、数量、小计、窗口/食堂信息和空状态。
6. 购物车页支持数量加减、删除单项、清空购物车，并对请求失败给出用户可见提示。
7. 购物车页支持选择立即取餐或预约取餐、填写备注，并按后端 `POST /api/orders` 所需 `items` 结构提交订单。
8. 下单成功后清空购物车，并跳转订单详情；若响应中没有订单 ID，则退回订单列表。
9. 订单列表页支持状态筛选、分页加载、下拉刷新和触底加载更多。
10. 订单列表项展示订单号、状态、下单时间、商品摘要、窗口/食堂、取餐方式和应付金额。
11. 订单详情页通过路由参数 `id` 调用 `/api/orders/{orderId}`；缺少 id 或请求失败时展示明确错误。
12. 订单详情页展示订单状态、金额、轮询时间、商品明细、取餐与支付信息，并在页面显示期间每 5 秒短轮询刷新一次。
13. 订单详情页支持取消待支付/已支付订单、确认 `READY` 订单取餐；支付按钮只给出 ST-015 占位提示。
14. 新增订单/购物车归一化工具，兼容后端裸数组、分页结构、详情对象和不同金额字段。
15. 执行小程序 JS 语法检查和关键契约搜索；如微信开发者工具 CLI 不可用，记录原因。

## Dev Tasks

- [x] 创建故事文档和状态更新：
  - [x] 新增 ST-014 故事文档。
  - [x] 更新 `docs/stories/README.md`、`docs/sprint-status.yaml` 和 `docs/bmm-workflow-status.yaml`。
- [x] 完成小程序购物车数据层：
  - [x] 扩展 `miniapp/api/order.js` 的购物车 API。
  - [x] 新增 `miniapp/utils/order.js`，归一化购物车、订单列表和订单详情响应。
- [x] 完成加购入口：
  - [x] 菜品列表加购。
  - [x] 菜品详情加购和购物车入口。
- [x] 完成购物车页：
  - [x] 加载、空状态、数量修改、删除、清空。
  - [x] 立即/预约取餐、备注和提交订单。
- [x] 完成订单列表页：
  - [x] 状态筛选、分页、下拉刷新和触底加载。
  - [x] 订单摘要展示和详情跳转。
- [x] 完成订单详情页：
  - [x] 新增 `miniapp/pages/order-detail/*`。
  - [x] 详情展示、取消订单、确认取餐和 5 秒短轮询。
- [x] 添加验证：
  - [x] 执行 miniapp JS 语法检查。
  - [x] 搜索确认关键路由/API/轮询契约。
  - [x] 记录验证结果到 Dev Agent Record。

## Verification

Run from repo root:

```powershell
node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"
rg -n "order-detail|addToCart|getCart|updateCartItem|normalizeOrder|setInterval|POLLING_INTERVAL|createOrder\(" miniapp --glob '!node_modules'
```

Expected result:

- 菜品列表和详情可以加入购物车。
- 购物车可加载、改数量、删除、清空和提交订单。
- 订单列表可分页筛选并进入详情。
- 订单详情会每 5 秒轮询，页面隐藏/卸载时停止轮询。

## Dependencies

- ST-011 已完成小程序工程骨架、request 封装和基础页面。
- ST-012 已完成小程序 JWT 登录和 token 注入。
- ST-013 已完成菜品浏览与详情。
- 后端已有 `/api/orders/cart/**` 和 `/api/orders/**`。

## Out of Scope

- `wx.requestPayment` 支付拉起、支付失败/取消提示和 mock 支付联调；这些属于 ST-015。
- 评价、个人中心和积分商城完整流程；这些属于 ST-016。
- 后端订单状态机和支付回调逻辑改造；现有能力由 ST-007 至 ST-010 提供。

## Dev Agent Record

Created At: 2026-06-02  
Completed At: 2026-06-02

Files Changed:

- `docs/stories/ST-014-miniapp-cart-order-polling.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `miniapp/app.json`
- `miniapp/api/order.js`
- `miniapp/utils/order.js`
- `miniapp/pages/dishes/dishes.js`
- `miniapp/pages/dishes/dishes.wxml`
- `miniapp/pages/dishes/dishes.wxss`
- `miniapp/pages/dish-detail/dish-detail.js`
- `miniapp/pages/dish-detail/dish-detail.wxml`
- `miniapp/pages/dish-detail/dish-detail.wxss`
- `miniapp/pages/cart/cart.js`
- `miniapp/pages/cart/cart.wxml`
- `miniapp/pages/cart/cart.wxss`
- `miniapp/pages/cart/cart.json`
- `miniapp/pages/orders/orders.js`
- `miniapp/pages/orders/orders.wxml`
- `miniapp/pages/orders/orders.wxss`
- `miniapp/pages/orders/orders.json`
- `miniapp/pages/order-detail/order-detail.js`
- `miniapp/pages/order-detail/order-detail.wxml`
- `miniapp/pages/order-detail/order-detail.wxss`
- `miniapp/pages/order-detail/order-detail.json`

Implementation Notes:

- Added a shared order normalization utility for cart items, order pages and order details.
- Cart order creation submits only dish or combo IDs present on each item, matching the backend `items` contract.
- Reservation time is normalized to `yyyy-MM-dd HH:mm` for the existing backend parser.
- Order detail polling is scoped to page visibility and stops for completed/cancelled orders.
- The payment action remains a visible ST-015 placeholder so this story does not overreach into payment launch.

Validation:

- `node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"` passed with 21 JS files.
- `rg -n "order-detail|addToCart|getCart|updateCartItem|normalizeOrder|setInterval|POLLING_INTERVAL|createOrder\(" miniapp --glob '!node_modules'` passed.
- WeChat DevTools CLI was not re-run in this story; source-level miniapp validation was completed.
