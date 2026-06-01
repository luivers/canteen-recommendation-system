# Story ST-010: 支付状态查询与前端支付结果页 / 弹窗

Status: Completed

Epic: EPIC-004 真实第三方支付集成  
Priority: Should  
Estimate: 3 points  
Planned Day: D4  
Primary Files: `java/src/main/java/com/school/canteen/controller/PaymentController.java`, `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`, `java/src/main/java/com/school/canteen/service/payment/dto/PaymentQueryResponse.java`, `vue/src/views/Orders.vue`, `vue/src/api/order.js`  
Likely Touch Points: `java/src/main/java/com/school/canteen/service/payment/provider/MockPaymentProvider.java`, `java/src/test/java/com/school/canteen/service/payment/*`, `vue/src/router/index.js`, `vue/src/views/PaymentResult.vue`

## Story

作为学生用户，我希望在发起支付后能看到明确的支付结果弹窗或结果页，并且页面能通过后端支付状态查询接口确认订单是否已经支付成功，这样即使 SSE 延迟、浏览器刷新或 mock 支付流程中断，我也能知道当前订单支付状态，而不是只能依赖一次性的前端成功提示。

## Context

ST-008 已完成支付创建接口和前端 `orderApi.createPayment()` 串接，Web 订单页可以拿到后端生成的 `transactionId`。ST-009 已完成支付回调验签、幂等记录、订单置为 `PAID` 与 SSE `order-update` 推送。当前 `PaymentController` 已暴露 `GET /api/payments/orders/{orderId}/status`，`PaymentApplicationService#queryPaymentStatus()` 会返回 provider 状态、本地订单状态、支付方式、交易号和支付时间等字段。

本故事聚焦支付体验收口：补齐前端 API 封装和订单页支付结果 UI，在支付创建后展示二维码 / 跳转 / mock 状态信息，并通过状态查询轮询或手动刷新确认 `PENDING -> PAID`。它不实现真实微信 / 支付宝 SDK 联调，也不替代 ST-009 的回调幂等主链路。

## Acceptance Criteria

1. `GET /api/payments/orders/{orderId}/status` 只能由订单本人或具备管理权限的用户访问；未登录返回 401，越权返回 403。
2. 状态查询响应至少包含 `mode`、`provider`、`orderId`、`orderNumber`、`paymentMethod`、`transactionId`、`localStatus`、`providerStatus`、`paymentTime`、`queryTime` 或等价字段。
3. `providerStatus` 与 `localStatus` 语义清晰区分：provider 表示支付渠道查询结果，本地状态表示系统订单状态；前端不得只凭 provider 状态直接改写订单。
4. mock provider 查询能根据本地订单状态返回稳定结果：订单已支付时可展示成功，待支付时可展示待支付或未知，不抛出未处理异常。
5. sandbox / 未实现 provider 查询时返回可展示的业务错误，不静默降级为 mock 成功。
6. `vue/src/api/order.js` 新增 `queryPaymentStatus(orderId)` 或等价封装，订单页不得硬编码支付状态查询 URL。
7. `Orders.vue` 支付创建成功后展示支付结果弹窗或结果区域，至少包含订单号、应付金额、支付方式、交易号、二维码 / 跳转占位信息和当前状态。
8. 支付结果弹窗支持“刷新状态”操作；刷新时调用后端状态查询接口，成功后同步订单列表中的支付字段和订单状态。
9. 支付创建后可启动有限次数轮询，例如每 2-5 秒查询一次、最多 3-5 次；轮询命中 `PAID` 后停止并展示成功，不得无限轮询。
10. SSE `order-update` 仍作为首选实时同步路径；状态查询作为主动确认和兜底路径，两者更新同一个订单状态模型，避免重复弹出多个成功提示。
11. 失败、超时、取消或 provider 未实现时，前端展示清晰提示，并保留“手动刷新状态 / 返回订单列表 / 联系客服”路径。
12. 支付结果 UI 不能破坏当前订单列表、订单详情、取消订单、确认取餐和评价流程；弹窗关闭后订单列表仍可正常刷新和操作。
13. 后端测试覆盖状态查询成功、未登录 / 越权、待支付订单、已支付订单、未实现 provider 查询错误路径。
14. 前端修改后执行 `npm run build`；后端修改后执行 `mvn test` 或至少 `mvn -DskipTests compile`，若环境阻塞需记录具体错误。

## Dev Tasks

- [x] 稳定后端支付状态查询契约：
  - [x] 复核 `PaymentController#queryPaymentStatus` 鉴权与异常返回。
  - [x] 复核 `PaymentApplicationService#queryPaymentStatus` 字段填充，确保本地订单状态和 provider 状态同时返回。
  - [x] 为 mock provider 查询补齐待支付、已支付和未知状态语义。
  - [x] 为 sandbox / 未实现 provider 查询保留明确错误 code / message。
- [x] 补齐后端测试：
  - [x] 添加或扩展 `PaymentApplicationService` 状态查询测试。
  - [x] 覆盖订单本人、管理员 / 窗口管理员、越权用户和未登录场景。
  - [x] 覆盖 `PENDING` 与 `PAID` 本地状态，以及 provider 查询不可用路径。
- [x] 增加前端 API 封装：
  - [x] 在 `vue/src/api/order.js` 增加 `queryPaymentStatus(orderId)`。
  - [x] 搜索确认前端支付状态查询只通过 API 模块调用。
- [x] 实现支付结果弹窗 / 结果区域：
  - [x] 在 `Orders.vue` 支付创建后保存支付创建响应和查询状态。
  - [x] 展示订单号、金额、支付方式、交易号、二维码 / 跳转 / mock 信息。
  - [x] 增加“刷新状态”“关闭”“返回订单列表”操作。
  - [x] 成功查询到 `PAID` 后更新当前订单项并展示成功提示。
- [x] 串接轮询与 SSE 兜底：
  - [x] 支付创建后启动有限次数状态查询轮询。
  - [x] SSE 收到 `PAID` 后停止支付状态轮询。
  - [x] 弹窗关闭或组件卸载时清理轮询定时器。
- [x] 验证：
  - [x] 执行 Java 测试或编译。
  - [x] 执行前端 build。
  - [x] 记录命令和结果到本故事的 Dev Agent Record。

## Suggested Implementation Notes

前端 API 建议：

```javascript
queryPaymentStatus: (orderId) => {
  return api.get(`/api/payments/orders/${orderId}/status`);
},
```

支付结果状态建议按本地订单状态优先展示：

```text
localStatus = PAID      -> 支付成功
providerStatus = PAID   -> 渠道已支付，等待本地订单同步
localStatus = PENDING   -> 待支付 / 等待回调
providerStatus = FAILED -> 支付失败或已取消
```

轮询应是兜底，不要替代 SSE。建议在支付弹窗打开期间执行 3-5 次短轮询，命中成功或用户关闭弹窗时立即停止。

## Verification

Run from `java/`:

```powershell
mvn test
```

If test execution is blocked by local dependency cache or environment permissions, run:

```powershell
mvn -DskipTests compile
```

Run from `vue/`:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "queryPaymentStatus|/api/payments/orders/.*/status|orders/\\$\\{orderId\\}/status" vue/src java/src/main/java java/src/test
rg -n "setInterval|setTimeout|clearInterval|clearTimeout|order-update" vue/src/views/Orders.vue
```

Expected result:

- 支付状态查询接口经过鉴权，并返回本地订单状态与 provider 查询状态。
- `Orders.vue` 支付创建后能展示结果弹窗 / 区域，并可主动刷新状态。
- SSE 与轮询不会重复更新或重复弹成功提示。
- 支付成功、待支付、失败、超时和 provider 未实现都有清晰用户提示。

## Dependencies

- ST-008 已完成支付创建接口和 Web 最小串接。
- ST-009 已完成支付回调验签、幂等处理、订单置为 `PAID` 和 SSE 推送。
- `PaymentController#queryPaymentStatus` 与 `PaymentApplicationService#queryPaymentStatus` 已有基础实现。
- `OrderEventService.publishOrderUpdate()` 已可向 Web 端推送订单支付字段。

## Out of Scope

- 真实微信支付 / 支付宝 SDK、证书、沙箱网络联调。
- 小程序 `wx.requestPayment` 拉起和订单详情轮询，这些属于 ST-015。
- 支付 README、环境变量说明和 demo 脚本，这些属于 ST-021。
- 订单支付成功后的评价、积分发放和优惠券核销流程改造。

## Dev Agent Record

Created At: 2026-06-01  
Completed At: 2026-06-01

Files Changed:

- `docs/stories/ST-010-payment-status-result-dialog.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentQueryResponse.java`
- `java/src/test/java/com/school/canteen/service/payment/PaymentApplicationServiceTest.java`
- `vue/src/api/order.js`
- `vue/src/views/Orders.vue`

Implementation Notes:

- Added `queryTime` to the payment status response and made mock-mode provider status derive from the local order state: `PENDING` stays pending, paid / preparing / ready / completed read as paid, and cancelled reads as cancelled.
- Added `PaymentApplicationService` tests for pending and paid status query responses, unauthenticated / unauthorized access, admin access, and sandbox provider-not-implemented behavior.
- Added `orderApi.queryPaymentStatus(orderId)`.
- Upgraded `Orders.vue` payment flow so payment creation opens a result view with order number, amount, payment method, transaction ID, QR / redirect / miniapp placeholders, local/provider statuses, manual refresh, and bounded status polling.
- SSE `order-update`, manual status refresh, dialog close and component unmount now update or clean up the same payment status state and timer.

Validation:

- `rg -n "queryPaymentStatus|/api/payments/orders/.*/status|orders/\\$\\{orderId\\}/status" vue/src java/src/main/java java/src/test/java` passed.
- `rg -n "paymentStatusTimer|PAYMENT_STATUS_MAX_ATTEMPTS|refreshPaymentStatus|order-update|stopPaymentStatusPolling" vue/src/views/Orders.vue` passed.
- `mvn test` passed in `java/`: 23 tests, 0 failures, 0 errors.
- `npm run build` passed in `vue/`; Vite reported the existing large chunk warning.
- Local dev server started at `http://127.0.0.1:5173`; `Invoke-WebRequest http://127.0.0.1:5173/orders` returned `200`.
- In-app Browser verification was attempted, but no `iab` browser session was available in this environment.
