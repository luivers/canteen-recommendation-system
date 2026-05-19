# Story ST-008: 支付创建接口返回二维码 / 跳转 / 小程序参数占位

Status: Completed

Epic: EPIC-004 真实第三方支付集成  
Priority: Must  
Estimate: 3 points  
Planned Day: D3  
Primary Files: `java/src/main/java/com/school/canteen/controller/PaymentController.java`, `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`, `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCreateResponse.java`, `vue/src/api/order.js`  
Likely Touch Points: `java/src/main/java/com/school/canteen/service/payment/provider/MockPaymentProvider.java`, `java/src/main/java/com/school/canteen/service/payment/config/PaymentProperties.java`, `java/src/test/java/com/school/canteen/service/payment/*`, `vue/src/views/Orders.vue`

## Story

作为学生用户，我希望点击待支付订单后，前端先调用统一的支付创建接口，并拿到二维码、跳转链接或小程序支付参数占位，以便 Web、mock 演示和后续小程序支付都走同一个支付创建契约，而不是继续由前端直接伪造交易号并调用 mock 成功接口。

## Context

PRD FR-011 要求 Web 端调用 `POST /api/payments/orders/{orderId}/create` 返回支付参数（二维码 / 跳转链接），FR-012 要求 `payment.mode=mock|sandbox` 作为演示兜底，FR-028 后续会依赖小程序原生支付参数。架构 3.7 将支付创建列为 `payment` 模块目标接口，并要求 Web / 小程序共用后端 API。

ST-007 已建立 `PaymentApplicationService`、`PaymentProvider`、`PaymentProviderFactory`、`MockPaymentProvider` 和 `PaymentCreateResponse`，当前 `PaymentController` 已有 `POST /api/payments/orders/{orderId}/create`，mock provider 也能生成 `qrCodeUrl`、`redirectUrl` 和 `miniProgramParams`。但前端 `vue/src/api/order.js` 仍只暴露 `markPaid()`，`Orders.vue` 的确认支付仍直接构造 `transactionId` 并调用 `/success`。本故事聚焦支付创建响应契约与前端 API 落点，不实现回调幂等、真实沙箱 SDK 或完整支付结果页。

## Acceptance Criteria

1. `POST /api/payments/orders/{orderId}/create` 可由已登录学生为自己的 `PENDING` / 可支付订单调用；`ADMIN` 和 `WINDOW_MANAGER` 的管理访问语义保持与 ST-007 facade 一致。
2. 请求体支持 `paymentMethod`，至少兼容 `WECHAT`、`ALIPAY` 和 `CARD` 等当前前端已有选项；缺省时按后端现有默认值处理。
3. 响应结构稳定返回支付创建所需字段：`mode`、`provider`、`orderId`、`orderNumber`、`amount`、`paymentMethod`、`transactionId`、`status`、`qrCodeUrl`、`redirectUrl`、`miniProgramParams`、`createdAt`、`expiresAt`。
4. mock 模式下 `qrCodeUrl` 必须可演示、可追踪到订单号；`redirectUrl` 可以为空字符串或配置值；`miniProgramParams` 至少包含 provider / mock 标识、订单号和交易号。
5. sandbox / 未实现 provider 模式不得静默返回 mock 成功；应保留 ST-007 的明确错误语义，前端能拿到可展示的错误消息。
6. `create` 接口不得直接把订单置为 `PAID`；支付成功仍由后续 `/callback`、受控 `/success` 或 ST-009/ST-010 的流程完成。
7. `create` 接口对已取消、已完成或不可支付订单返回清晰业务错误，不生成新的支付参数。
8. `vue/src/api/order.js` 新增 `createPayment(orderId, payload)` 或等价封装，所有前端调用支付创建时必须通过 API 模块，不在视图里硬编码 URL。
9. `Orders.vue` 的确认支付流程先调用 `orderApi.createPayment()` 获取后端交易号和占位支付参数；mock/demo fallback 可以继续调用 `markPaid()`，但不得再由前端自行生成 `"TX" + Date.now()` 作为主交易号。
10. 前端在 mock 模式下能保留当前一键演示支付能力，并在失败时沿用现有错误提示 / 支持提示，不引入未处理 Promise 错误。
11. 后端测试覆盖 `createPayment` 成功响应字段、不可支付订单、越权订单、未实现 provider 错误路径；如现有测试已覆盖部分场景，应补齐 ST-008 字段契约断言。
12. 前端至少通过搜索验证确认支付创建 URL 只在 `vue/src/api/order.js` 中封装；如调整 `Orders.vue`，需执行 `npm run build`。
13. Java 侧执行 `mvn test` 或至少 `mvn -DskipTests compile`；若本地 Maven 缓存 / 权限问题阻塞，记录具体错误并保留源码级验证结果。

## Dev Tasks

- [x] 稳定后端支付创建契约：
  - [x] 复核 `PaymentController#createPayment` 请求体解析，确保空 body、缺省 `paymentMethod` 和非法 provider 错误都可预测。
  - [x] 复核 `PaymentApplicationService#createPayment` 不修改订单状态，只返回 provider 创建结果。
  - [x] 补齐 `PaymentCreateResponse` / mock provider 字段断言，锁定二维码、跳转、小程序参数占位。
- [x] 补齐错误路径：
  - [x] 覆盖越权访问、不可支付订单、未实现 provider / sandbox 模式错误。
  - [x] 确认错误 code / message 能被现有 Axios 拦截器或调用方展示。
- [x] 增加前端 API 封装：
  - [x] 在 `vue/src/api/order.js` 增加 `createPayment(orderId, payload)`。
  - [x] 保留 `markPaid()` 作为 mock/demo 完成支付 fallback，不把它作为支付创建入口。
- [x] 串接 Web 订单页的最小创建流程：
  - [x] `Orders.vue` 确认支付时先调用 `createPayment()`。
  - [x] 使用后端返回的 `transactionId`、`paymentMethod` 和占位字段作为后续 mock 完成支付的输入。
  - [x] 保持现有支付成功 banner、订单刷新、SSE / 轮询同步兜底不回退。
- [x] 验证：
  - [x] Java 测试或编译通过。
  - [x] 前端 build 通过，或说明未改前端视图时的搜索验证结果。
  - [x] 搜索确认支付创建 endpoint 没有散落硬编码。

## Suggested Implementation Notes

后端响应建议继续沿用 ST-007 的 DTO：

```json
{
  "mode": "mock",
  "provider": "MOCK",
  "orderId": 20,
  "orderNumber": "ORD2001",
  "amount": 25.00,
  "paymentMethod": "WECHAT",
  "transactionId": "MOCK-ORD2001-...",
  "status": "CREATED",
  "qrCodeUrl": "mock://canteen-payment/ORD2001",
  "redirectUrl": "",
  "miniProgramParams": {
    "provider": "MOCK",
    "mock": true,
    "orderNumber": "ORD2001",
    "transactionId": "MOCK-ORD2001-..."
  },
  "createdAt": "2026-05-20T10:00:00",
  "expiresAt": "2026-05-20T10:15:00"
}
```

前端 API 建议：

```javascript
createPayment: (orderId, payload) => {
  return api.post(`/api/payments/orders/${orderId}/create`, payload);
},
```

`Orders.vue` 可以先做最小串接：选择支付方式 -> `createPayment()` -> mock 模式继续调用 `markPaid()` 完成演示。二维码展示、跳转页、主动查询和支付结果弹窗属于 ST-010；本故事只需让创建接口成为前端支付链路的第一步，并保留当前 demo 可用性。

## Verification

Run from `java/`:

```powershell
mvn test
```

If test execution is blocked by local dependency cache or environment permissions, run:

```powershell
mvn -DskipTests compile
```

Run from `vue/` if `Orders.vue` or API modules change:

```powershell
npm run build
```

Search checks from repo root:

```powershell
rg -n "createPayment|/api/payments/orders/.*/create|orders/\\$\\{orderId\\}/create" vue/src java/src/main/java java/src/test
rg -n "\"TX\" \\+ Date.now|transactionId: \"TX\"" vue/src/views/Orders.vue
```

Expected result:

- 后端 `create` 接口返回 ST-008 所需二维码 / 跳转 / 小程序参数占位字段。
- 前端支付创建 URL 通过 `vue/src/api/order.js` 封装。
- `Orders.vue` 不再把前端自造交易号作为主支付创建结果。
- mock 模式仍可完成演示支付；真实回调幂等和结果页仍留给后续故事。

## Dependencies

- ST-007 已完成支付 facade、provider 接口、mock provider 和基础支付配置。
- ST-003 已完成订单 / 购物车主路径，订单状态和金额字段可用于支付创建。
- `SecurityConfig` 应保持 `/api/payments/**` 除 `/callback` 外需要鉴权。
- ST-009 将继续处理回调验签、幂等、订单置为 `PAID` 并推送 SSE。
- ST-010 将继续处理支付状态查询与前端支付结果页 / 弹窗。
- ST-015 将基于 `miniProgramParams` 接入小程序支付拉起。

## Out of Scope

- 真实微信 / 支付宝 SDK、证书、沙箱商户参数和外部网络联调。
- 支付回调幂等表、重复通知防重和订单置为 `PAID` 后的 SSE 强化。
- 完整二维码弹窗、支付倒计时、主动查询轮询和支付结果页。
- 小程序工程内 `wx.requestPayment` 调起。
- 支付 README / demo 脚本。

## Dev Agent Record

Completed At: 2026-05-20

Files Changed:

- `java/src/main/java/com/school/canteen/controller/PaymentController.java`
- `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`
- `java/src/test/java/com/school/canteen/service/payment/PaymentApplicationServiceTest.java`
- `vue/src/api/order.js`
- `vue/src/views/Orders.vue`
- `docs/stories/ST-008-payment-create-qr-redirect-miniapp-params.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`

Implementation Notes:

- `PaymentController#createPayment` now normalizes missing, blank or `"null"` payment method values to `WECHAT` before calling the facade.
- `PaymentApplicationService#createPayment` now only accepts `PENDING` orders as payable and does not mark orders paid during payment creation.
- Added ST-008-focused unit coverage for the mock payment creation response contract, already-paid order rejection and sandbox provider-not-implemented errors.
- Added `orderApi.createPayment(orderId, payload)` and changed `Orders.vue` to call it before mock completion.
- `Orders.vue` now uses the backend-created `transactionId` for `/success` instead of generating `"TX" + Date.now()` in the browser.

Validation:

- `mvn test` passed in `java/`: 10 tests, 0 failures, 0 errors.
- `npm run build` passed in `vue/`; Vite reported only the existing large chunk warning.
- `rg -n "createPayment|/api/payments/orders/.*/create|orders/\\$\\{orderId\\}/create" vue/src java/src/main/java java/src/test` confirmed the create endpoint is exposed through backend controller/service/tests and `vue/src/api/order.js`, with `Orders.vue` calling `orderApi.createPayment()`.
- `rg -n "TX" vue/src/views/Orders.vue` returned no matches.
