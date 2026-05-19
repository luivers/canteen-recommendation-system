# Story ST-003: 拆分购物车 / 订单页关键职责，清理 localStorage 双写

Status: Completed

Epic: EPIC-001 前端工程质量治理  
Priority: Must  
Estimate: 3 points  
Planned Day: D2  
Primary Files: `vue/src/views/Cart.vue`, `vue/src/views/Orders.vue`, `vue/src/api/order.js`  
Likely Touch Points: `vue/src/views/Home.vue`, `vue/src/views/Dishes.vue`

## Story

作为前端开发者，我希望购物车和订单页的数据来源、页面职责和接口封装更加清晰，以便学生端从加购、确认购物车、下单到查看订单状态时使用同一套后端订单数据，避免 `localStorage.cart` 与 `/api/orders/cart` 双写导致金额、套餐、数量或下单结果不一致。

## Context

当前 `Cart.vue` 会先请求 `orderApi.getCart()`，再读取 `localStorage.getItem("cart")` 中的套餐项并与后端购物车合并，最后又把合并后的完整购物车写回 `localStorage.cart`。`Home.vue` 和 `Dishes.vue` 的加购流程也会在调用后端购物车接口后写入本地 `cart`，这会造成后端持久化购物车与前端缓存互相覆盖。由于后端 `CartController` / `CartService` 已支持 `dishId` 和 `comboId` 两种加购方式，Web 端不再需要把套餐购物车长期保存在 `localStorage`。

`Orders.vue` 同时承载订单列表、筛选分页、订单详情、评价、支付 mock、SSE 订阅和轮询降级，职责较重。ST-003 只做必要的职责整理和数据流稳定，不重写支付 provider，也不扩大到小程序或后台订单管理。

## Acceptance Criteria

1. Web 学生端购物车以 `/api/orders/cart` 为唯一真实来源；`Cart.vue` 不再读取、写入或删除 `localStorage.cart`。
2. 套餐加购走 `orderApi.addToCart({ comboId, quantity })`，普通菜品加购走 `orderApi.addToCart({ dishId, quantity })`；不再为了套餐单独维护本地购物车缓存。
3. `Home.vue` 和 `Dishes.vue` 中与 `localStorage.cart` 相关的加购同步逻辑被移除或改为调用统一购物车 API；加购成功后如需提示数量，应来自接口响应或重新拉取购物车。
4. `Cart.vue` 中购物车加载、数量更新、删除、清空、下单 payload 组装拆成清晰的小函数或局部 helper，避免在同一个流程中混合 API 调用、缓存合并、金额计算和错误提示。
5. 购物车项标准化后必须同时兼容后端返回的菜品项和套餐项：
   - 菜品项以 `item.dish.id` 或等价字段生成 `dishId`。
   - 套餐项以 `item.combo.id` 或等价字段生成 `comboId`。
   - `quantity` 始终转为正整数。
   - `isGift` 仅对菜品赠品保留，套餐项不应错误携带赠品标记。
6. 下单 payload 中每个 item 只携带有效的 `dishId` 或 `comboId` 之一，不提交两者都为空的项；无有效项时给出用户可见提示并阻止请求。
7. 下单成功后只执行一次明确的购物车清理流程：调用 `orderApi.clearCart()` 并清空页面状态；失败时保留页面购物车并提示用户刷新或重试。
8. 代金券列表仍按当前购物车总金额加载；购物车为空或总金额为 0 时不请求可用券，并清空已选券。
9. `orderApi` 提供更明确的购物车和订单方法命名或参数校验，例如 `addDishToCart`、`addComboToCart`、`normalizeOrderListResponse` 或等价实现；组件内不直接拼接新增订单 / 购物车 endpoint。
10. `Orders.vue` 的订单列表加载逻辑收口为单一入口，分页响应和数组响应都被稳定归一化；加载失败时 `orders` 和 `total` 有确定兜底值。
11. `Orders.vue` 去除面向调试的 `console.log`；保留必要 `console.error`，且用户可见错误通过 Element Plus 消息或页面 banner 呈现。
12. 订单 SSE 订阅和 5s 轮询降级行为保持可用；组件卸载时必须关闭 `EventSource` 并清理轮询定时器。
13. 订单操作按钮仍按状态显示：`PENDING` 可支付 / 取消，`READY` 可确认取餐，`COMPLETED` 可评价；取消和确认取餐成功后刷新当前列表。
14. 支付 mock 弹窗的现有行为可以保留，但不得在本故事中改造真实支付 facade；支付 provider、二维码 / 跳转和支付状态查询留给 ST-007 到 ST-010。
15. `npm run build` 在 `vue/` 目录下通过。

## Dev Tasks

- [ ] 收口购物车 API：
  - [ ] 在 `vue/src/api/order.js` 中补充 `addDishToCart(dishId, quantity)` 和 `addComboToCart(comboId, quantity)` 或等价封装。
  - [ ] 对缺失 ID / 非法数量做前端参数校验，避免组件发出明显无效请求。
  - [ ] 保留现有 `addToCart` 兼容层，或一次性替换所有调用点。
- [ ] 清理加购入口的本地购物车双写：
  - [ ] `Home.vue` 普通菜品加购只调用后端购物车接口。
  - [ ] `Home.vue` 套餐加购改为调用后端 `comboId` 加购接口。
  - [ ] `Dishes.vue` 普通菜品加购只调用后端购物车接口。
  - [ ] 删除上述页面中 `localStorage.cart` 的读取、合并和写入逻辑。
- [ ] 重构 `Cart.vue`：
  - [ ] `loadCart()` 只从 `orderApi.getCart()` 获取数据，不读写 `localStorage.cart`。
  - [ ] 增加购物车项标准化 helper，统一菜品项 / 套餐项显示字段和下单字段。
  - [ ] 更新数量、删除、清空均以接口结果为准，成功后更新页面状态或重新拉取购物车。
  - [ ] 下单前通过 helper 生成 `items`，过滤无效项并合并重复项。
  - [ ] 下单成功后统一清理购物车状态和已选代金券。
  - [ ] 总金额为 0 或购物车为空时跳过可用代金券请求。
- [ ] 整理 `Orders.vue`：
  - [ ] 提取订单查询参数构造逻辑。
  - [ ] 提取订单列表响应归一化逻辑。
  - [ ] 删除调试 `console.log`。
  - [ ] 确认 SSE 错误时只启动一条轮询链路，卸载时清理干净。
  - [ ] 保持评价、取消、确认取餐和支付 mock 的现有可用行为。
- [ ] 运行搜索验证，确认 Web 学生端不再使用 `localStorage.cart`。
- [ ] 执行构建验证。

## Suggested Implementation Notes

Cart item normalization can stay local to `Cart.vue` if no other page needs it yet:

```js
const toPositiveQuantity = (value) => Math.max(1, Number(value) || 1);

const toOrderPayloadItem = (item) => {
  const quantity = toPositiveQuantity(item?.quantity);
  const comboId = Number(item?.combo?.id || item?.comboId || 0);
  if (comboId) return { comboId, quantity };

  const dishId = Number(item?.dish?.id || item?.dishId || 0);
  if (dishId) {
    return { dishId, quantity, isGift: Boolean(item?.isGift) };
  }

  return null;
};
```

`orderApi` wrapper shape:

```js
addDishToCart: (dishId, quantity = 1) =>
  api.post("/api/orders/cart", { dishId: Number(dishId), quantity }),

addComboToCart: (comboId, quantity = 1) =>
  api.post("/api/orders/cart", { comboId: Number(comboId), quantity }),
```

For `Orders.vue`, prefer pure helpers for date range and response normalization so the page flow reads as:

```js
const params = buildOrderQueryParams();
const response = await orderApi.getOrders(params);
const { rows, totalElements } = normalizeOrderListResponse(response);
orders.value = rows;
total.value = totalElements;
```

## Verification

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "localStorage\.(getItem|setItem|removeItem)\(['\"]cart" vue/src/views/Cart.vue vue/src/views/Home.vue vue/src/views/Dishes.vue
rg -n "console\.log\(" vue/src/views/Cart.vue vue/src/views/Orders.vue
rg -n "addComboToCart|comboId|addDishToCart|addToCart" vue/src/api/order.js vue/src/views/Home.vue vue/src/views/Dishes.vue vue/src/views/Cart.vue
```

Expected result:

- First search returns no matches.
- Second search returns no matches for `Cart.vue` / `Orders.vue`.
- Third search shows combo add-to-cart now reaches `orderApi` instead of `localStorage.cart`.
- Manual smoke path passes: login as student, add one dish and one combo, open cart, update quantity, apply / clear voucher if available, create order, verify cart empties and `/orders` shows the new `PENDING` order.

## Dependencies

- ST-001 completed, shared Axios client remains stable.
- ST-002 should be completed or its auth store contract should remain stable before full manual smoke testing.
- Backend `/api/orders/cart` supports both `dishId` and `comboId` payloads.
- Backend `/api/orders` accepts order items with exactly one of `dishId` or `comboId`.

## Out of Scope

- Real payment provider, payment facade, QR code / redirect payment flow, and payment status query.
- Backend order status machine changes.
- Review form UX redesign.
- Mini program cart / order flow.
- Admin order management pages.
