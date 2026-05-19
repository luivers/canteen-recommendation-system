# Story ST-009: 支付回调验签、幂等处理、订单置为 PAID 并推送 SSE

Status: Completed

Epic: EPIC-004 真实第三方支付集成  
Priority: Must  
Estimate: 5 points  
Planned Day: D3  
Primary Files: `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`, `java/src/main/java/com/school/canteen/service/impl/OrderServiceImpl.java`, `java/src/main/java/com/school/canteen/service/OrderEventService.java`  
Likely Touch Points: `java/src/main/java/com/school/canteen/controller/PaymentController.java`, `java/src/main/java/com/school/canteen/service/payment/provider/MockPaymentProvider.java`, `java/src/main/java/com/school/canteen/entity/*`, `java/src/main/java/com/school/canteen/repository/*`, `java/src/test/java/com/school/canteen/service/payment/*`

## Story

作为学生用户，我希望第三方支付或 mock 支付完成后，后端能安全接收支付回调，校验签名并幂等地把订单置为 `PAID`，同时向 Web 订单页推送 SSE 状态更新，以便支付成功状态可以从后端可信链路同步，而不是依赖前端直接标记成功。

## Context

PRD FR-011 要求支付成功后通过 `POST /api/payments/callback` 将订单变为 `PAID` 并推送 SSE；NFR-004 要求支付回调必须验签，篡改 body 验签失败，重复回调 10 次仅生效一次。架构 3.7 和 4.2 将支付回调、订单状态机与 `OrderEventService` 明确为支付主链路的一部分，订单合法状态为 `PENDING -> PAID -> PREPARING -> READY -> COMPLETED`。

ST-007 已建立 `PaymentApplicationService`、`PaymentProvider`、`PaymentProviderFactory` 和 `MockPaymentProvider`，并将 `/api/payments/callback` 的签名校验入口收口到 facade / provider。ST-008 已让前端先调用 `POST /api/payments/orders/{orderId}/create` 获取后端交易号，再用 mock fallback 完成演示支付。当前 `PaymentApplicationService#handleCallback` 已能验签后调用 `OrderService.markOrderPaidByNumber()`；`OrderServiceImpl#markOrderPaidInternal()` 对已支付或后续状态有基础幂等返回，并在首次置为 `PAID` 时调用 `OrderEventService.publishOrderUpdate(saved)`。但代码还缺少可追踪的支付通知幂等记录，无法证明重复回调只处理一次，也没有明确处理同一订单不同交易号的冲突场景。

本故事聚焦后端回调主链路：验签失败不落库、不改订单；验签成功后以持久化幂等键防重；首次成功回调把订单置为 `PAID` 并推送 SSE；重复成功回调返回稳定结果但不重复写状态历史、通知或事件。不实现真实微信 / 支付宝 SDK，也不做 ST-010 的支付结果页和主动状态查询 UI。

## Acceptance Criteria

1. `POST /api/payments/callback` 保持公开入口，不要求 JWT，但必须完成 provider 级签名校验；缺失签名、时间戳超时、必填字段缺失或签名不匹配时返回清晰 4xx 错误，且不修改订单。
2. 回调 payload 至少校验并解析 `orderNumber`、`paymentMethod`、`transactionId`、支付成功状态或等价成功信号；非成功支付通知不得将订单置为 `PAID`。
3. 新增持久化幂等机制，例如 `PaymentCallbackRecord` / `PaymentNotification`，以 `provider + orderNumber + transactionId` 或 provider 返回的通知 ID 作为唯一幂等键；重复通知能命中同一记录。
4. 同一幂等键重复回调 10 次时，仅第一次允许触发订单状态变更、`OrderStatusHistory` 写入、用户通知和 SSE 推送；后续重复回调返回已处理结果，不抛出误导性失败。
5. 已经支付的订单收到相同交易号回调时应幂等返回；收到不同交易号或不同 provider 的成功回调时，不得覆盖原支付信息，应返回明确冲突错误或记录为冲突状态。
6. 订单状态变更仍必须通过 `OrderService.markOrderPaidByNumber()` / `markOrderPaid()` 这样的订单服务入口完成，不在 payment facade 中直接修改 `Order` 或 `OrderItem`。
7. 首次成功回调后，订单状态为 `PAID`，所有订单项的 `paymentMethod`、`paymentTransactionId`、`paymentTime` 与回调解析结果一致。
8. 首次成功回调后，`OrderEventService` 向 SSE 客户端发送 `order-update` 事件，payload 包含 `status: "PAID"`、`paymentMethod`、`transactionId` 和 `paymentTime`，兼容 `vue/src/views/Orders.vue` 当前监听逻辑。
9. 回调日志应能定位 provider、订单号、交易号和幂等处理结果，但不得输出完整密钥、签名 secret 或敏感证书内容。
10. mock provider 的签名算法继续可用于本地测试；如果未来 sandbox provider 未实现，`payment.mode=sandbox` 下仍应保持明确的 provider-not-implemented 错误，不静默降级为 mock。
11. 后端测试覆盖：签名成功首次回调、签名失败不改订单、重复回调只处理一次、已支付相同交易号幂等、已支付不同交易号冲突、SSE 发布只在首次状态变更发生。
12. `mvn test` 或至少 `mvn -DskipTests compile` 在 `java/` 目录下通过；如本地 Maven 缓存 / 权限问题阻塞，记录具体错误并保留源码级验证结果。

## Dev Tasks

- [x] 建立回调幂等记录：
  - [x] 新增 `PaymentCallbackRecord` / `PaymentNotification` 实体或等价持久化结构。
  - [x] 保存 provider、orderNumber、paymentMethod、transactionId、idempotencyKey、processStatus、receivedAt、processedAt、attemptCount 和错误摘要。
  - [x] 为幂等键添加唯一约束，避免并发重复回调双写。
- [x] 收口回调处理流程：
  - [x] 在 `PaymentApplicationService#handleCallback` 中先完成 payload 基础校验和 provider 选择。
  - [x] 签名失败、字段缺失、时间戳异常时直接返回业务错误，不创建成功幂等记录，不调用订单服务。
  - [x] 签名成功后通过幂等服务 / repository 判断首次、重复或冲突。
- [x] 强化订单置为 `PAID` 的幂等语义：
  - [x] 保持订单状态变更通过 `OrderService` 完成。
  - [x] 确认 `OrderServiceImpl#markOrderPaidInternal` 对同交易号重复调用不重复写历史、通知、SSE。
  - [x] 为不同交易号重复支付补充冲突判断，避免覆盖 `OrderItem` 中已有支付信息。
- [x] 验证 SSE 契约：
  - [x] 确认 `OrderEventService.OrderUpdatePayload` 包含 Web 端需要的支付字段。
  - [x] 添加或调整测试，证明首次支付成功会发布一次 `order-update`，重复回调不重复发布。
- [x] 补齐测试：
  - [x] 添加 `PaymentApplicationService` 回调幂等单元测试。
  - [x] 添加 `MockPaymentProvider` 回调失败 / 成功解析测试。
  - [x] 添加 `OrderServiceImpl` 支付幂等 / 冲突测试，必要时 mock `OrderEventService`。
  - [x] 搜索确认回调签名和幂等处理没有散落到 `PaymentController`。
- [x] 验证：
  - [x] 执行 Java 测试或编译。
  - [x] 记录命令和结果到本故事的 Dev Agent Record。

## Suggested Implementation Notes

幂等键建议优先使用 provider 明确通知 ID；mock provider 暂无通知 ID 时可使用：

```text
MOCK:{orderNumber}:{transactionId}
```

可选实体结构：

```text
PaymentCallbackRecord
  id
  provider
  orderNumber
  paymentMethod
  transactionId
  idempotencyKey
  processStatus   // PROCESSING, PROCESSED, DUPLICATE, CONFLICT, FAILED
  rawPayloadHash
  attemptCount
  firstReceivedAt
  lastReceivedAt
  processedAt
  errorMessage
```

`OrderServiceImpl#markOrderPaidInternal()` 当前已经在订单为 `PAID`、`PREPARING`、`READY`、`COMPLETED` 时直接返回，适合作为重复回调的基础。但本故事需要补齐“相同交易号重复”和“不同交易号冲突”的可测试语义，避免第二个交易号悄悄被忽略或覆盖。

如果实现持久化幂等记录时担心并发，可让 repository 的唯一约束承担最终防线：重复插入捕获唯一键异常后重新读取记录并返回稳定结果。不要用 JVM 内存 `Set` 作为唯一幂等方案，因为支付回调需要跨重启可追踪。

## Verification

Run from `java/`:

```powershell
mvn test
```

If test execution is blocked by local dependency cache or environment permissions, run:

```powershell
mvn -DskipTests compile
```

Search checks from repo root:

```powershell
rg -n "PaymentCallbackRecord|PaymentNotification|idempotencyKey|handleCallback|markOrderPaidByNumber" java/src/main/java java/src/test
rg -n "verifyCallback|X-Payment-Signature|X-Payment-Timestamp|hmacSha256Hex" java/src/main/java/com/school/canteen/controller java/src/main/java/com/school/canteen/service/payment java/src/test
```

Expected result:

- `/api/payments/callback` 仍是公开 endpoint，但所有成功处理都经过 provider 验签。
- 重复成功回调只产生一次订单状态变更、历史、通知和 SSE。
- 相同交易号重复回调幂等返回，不同交易号冲突不覆盖原支付信息。
- Web 订单页能通过现有 SSE `order-update` 收到 `PAID` 状态和支付字段。
- Java 编译或测试通过；若环境阻塞，错误被记录。

## Dependencies

- ST-007 已完成支付 facade、provider 接口、mock provider 和配置集中化。
- ST-008 已完成支付创建接口与 Web 订单页最小串接，前端可使用后端生成的 `transactionId`。
- `OrderServiceImpl.markOrderPaidByNumber()` 是公开回调进入订单状态机的可信入口。
- `OrderEventService.publishOrderUpdate()` 已被 Web `Orders.vue` / `Home.vue` 通过 `/api/orders/events` 消费。

## Out of Scope

- 真实微信支付 / 支付宝 SDK、平台证书、APIv3 验签或沙箱网络联调。
- 支付状态查询、支付结果页、二维码弹窗、主动轮询和倒计时 UI；这些属于 ST-010。
- 小程序 `wx.requestPayment` 拉起和订单详情轮询；这些属于 ST-015。
- 支付 README、环境变量说明和 10 分钟 demo 脚本；这些属于 ST-021。

## Dev Agent Record

Created At: 2026-05-20

Files Changed:

- `docs/stories/ST-009-payment-callback-idempotent-paid-sse.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `java/src/main/java/com/school/canteen/entity/PaymentCallbackRecord.java`
- `java/src/main/java/com/school/canteen/repository/PaymentCallbackRecordRepository.java`
- `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCallbackPayload.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCompletionResponse.java`
- `java/src/main/java/com/school/canteen/service/payment/provider/MockPaymentProvider.java`
- `java/src/main/java/com/school/canteen/service/impl/OrderServiceImpl.java`
- `java/src/test/java/com/school/canteen/service/payment/PaymentApplicationServiceTest.java`
- `java/src/test/java/com/school/canteen/service/payment/provider/MockPaymentProviderTest.java`
- `java/src/test/java/com/school/canteen/service/impl/OrderServiceImplPaymentTest.java`

Implementation Notes:

- Added persistent `PaymentCallbackRecord` idempotency tracking with a unique `idempotencyKey`, attempt count, payload hash, processing status, timestamps and error summary.
- `PaymentApplicationService#handleCallback` now validates required callback fields, delegates signature verification to the selected provider, rejects non-`PAID` callbacks, records first/duplicate/conflict processing, and keeps order mutation behind `OrderService.markOrderPaidByNumber()`.
- `OrderServiceImpl#markOrderPaidInternal()` now treats already-paid same-transaction callbacks as idempotent and rejects different payment method / transaction callbacks with `PAYMENT_CONFLICT` without rewriting order items, history, notification or SSE.
- `MockPaymentProvider#parseCallback()` now parses an explicit success signal from `status`, `paymentStatus`, `tradeStatus` or `success`.

Validation:

- `rg -n "PaymentCallbackRecord|PaymentNotification|idempotencyKey|handleCallback|markOrderPaidByNumber" java/src/main/java java/src/test` passed.
- `rg -n "verifyCallback|X-Payment-Signature|X-Payment-Timestamp|hmacSha256Hex" java/src/main/java/com/school/canteen/controller java/src/main/java/com/school/canteen/service/payment java/src/test` passed; callback signature verification remains in provider/facade path.
- `git diff --check` passed with only existing CRLF conversion warnings.
- `mvn -U test` passed from `java/` after removing project Maven offline mode and switching the project-local Maven mirror to Huawei Cloud.
