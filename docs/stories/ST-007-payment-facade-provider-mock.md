# Story ST-007: 设计并实现支付 facade、provider 接口与 mock provider

Status: Completed

Epic: EPIC-004 真实第三方支付集成  
Priority: Must  
Estimate: 5 points  
Planned Day: D3  
Primary Files: `java/src/main/java/com/school/canteen/controller/PaymentController.java`, `java/src/main/java/com/school/canteen/service/payment/*`, `java/src/main/resources/application.yml`  
Likely Touch Points: `java/src/main/java/com/school/canteen/config/SecurityConfig.java`, `java/src/main/java/com/school/canteen/service/OrderService.java`, `java/src/main/java/com/school/canteen/service/impl/OrderServiceImpl.java`, `vue/src/api/order.js`, `vue/src/views/Orders.vue`

## Story

作为后端开发者，我希望支付逻辑通过统一的 Payment facade 和 provider 接口封装，并先提供稳定的 mock provider，以便后续微信 / 支付宝沙箱、支付创建、回调验签、状态查询和小程序支付都复用同一套支付边界，而不是把支付分支散落在控制器里。

## Context

PRD FR-011 要求 Web 端调用 `POST /api/payments/orders/{orderId}/create` 返回支付参数，并在支付成功后通过 `POST /api/payments/callback` 将订单置为 `PAID`；FR-012 要求 `payment.mode=mock|sandbox` 作为演示兜底；FR-013 后续还会依赖支付状态查询。架构 3.7 明确支付模块需要 `PaymentController -> PaymentApplicationService -> PaymentProviderFactory -> Provider` 的组件边界，并支持 mock / sandbox provider 切换。

当前代码已有 `PaymentController`、`POST /api/payments/callback` 和 `POST /api/payments/orders/{orderId}/success`，但支付签名、订单访问校验、mock 成功和后续 provider 接入还混在控制器中，`application.yml` 也只有 `payment.callback-secret` 和 `payment.callback-timeout-seconds`。本故事先建立支付 facade / provider 的后端骨架和 mock provider，保留现有 `/success` 兼容路径，不要求一次完成二维码、真实沙箱、回调幂等和前端支付结果页。

## Acceptance Criteria

1. 新增支付应用层 facade，例如 `PaymentApplicationService`，控制器不再直接承载主要支付分支逻辑；支付创建、mock 成功、回调校验入口应通过该 facade 暴露清晰方法。
2. 新增 provider 抽象，例如 `PaymentProvider`，至少包含：
   - `createPayment(...)`
   - `verifyCallback(...)`
   - `parseCallback(...)`
   - `queryPayment(...)`
   - `getProviderType()` 或等价 provider 标识。
3. 新增 `PaymentProviderFactory` 或等价选择器，根据配置选择 `mock`、`wechat_sandbox`、`alipay_sandbox` 等 provider；当真实 provider 尚未完成时，未实现模式必须返回明确错误，不应静默退回到错误 provider。
4. `payment.mode`、`payment.mock.enabled`、`payment.callback-secret`、`payment.callback-timeout-seconds` 等配置应通过类型安全配置类或集中配置对象读取，避免在控制器里散落多个 `@Value`。
5. `MockPaymentProvider` 能生成稳定的 mock 支付结果对象，至少包含 `provider`、`orderId` / `orderNumber`、`amount`、`paymentMethod`、`transactionId`、`status`、`expiresAt` 和展示占位字段，例如 `qrCodeUrl`、`redirectUrl`、`miniProgramParams`。
6. mock provider 的交易流水号必须具备可追踪性和基本唯一性，建议包含订单号、provider 和时间 / UUID 片段；不能使用空字符串或固定常量作为成功交易号。
7. 现有 `POST /api/payments/orders/{orderId}/success` 仍可作为受控 mock / demo fallback 使用，并应通过 facade 进入订单置为 `PAID` 的路径，不绕过订单访问校验。
8. `POST /api/payments/callback` 保持公开传输入口，但签名校验和 payload 解析应迁移到 provider / facade 层；缺字段、签名失败、时间戳超时和 provider 不支持时返回清晰错误。
9. 用户只能为自己的订单创建或完成 mock 支付；`ADMIN` 和 `WINDOW_MANAGER` 可以访问管理场景中的订单支付状态，权限语义与当前 `PaymentController` 一致。
10. 支付 facade 返回的 DTO / Map 字段命名要为 ST-008 预留接口契约，前端不需要知道当前是 mock 还是 sandbox，但响应里可以包含 `mode` / `provider` 供演示和排障展示。
11. 不在本故事中引入真实微信 / 支付宝 SDK；沙箱 provider 可保留接口类或未实现占位，但不能伪装成真实支付已完成。
12. 新增或调整后端单元测试，覆盖 provider 选择、mock 创建结果、签名校验成功 / 失败、未实现 provider 的错误路径。
13. `mvn test` 或至少 `mvn -DskipTests compile` 在 `java/` 目录下通过；如本地 Maven 缓存 / 权限问题阻塞，记录具体错误并保留源码级验证结果。

## Dev Tasks

- [x] 建立支付领域 DTO / 枚举：
  - [x] 定义 `PaymentProviderType` / `PaymentMode` / `PaymentStatus` 等最小枚举。
  - [x] 定义 `PaymentCreateRequest`、`PaymentCreateResponse`、`PaymentCallbackPayload`、`PaymentQueryResponse` 或等价结构。
  - [x] 字段兼容 ST-008 需要的二维码、跳转链接和小程序参数占位。
- [x] 建立 provider 抽象：
  - [x] 新增 `PaymentProvider` 接口。
  - [x] 新增 `MockPaymentProvider`。
  - [x] 新增未实现沙箱 provider 的明确错误实现或占位选择逻辑。
  - [x] 新增 `PaymentProviderFactory`，按配置选择 provider。
- [x] 建立 facade：
  - [x] 新增 `PaymentApplicationService`。
  - [x] 将订单读取、用户访问校验、支付创建、mock 成功、回调入口编排放入 facade。
  - [x] 保持订单状态变更仍通过 `OrderService.markOrderPaid()` / `markOrderPaidByNumber()` 完成。
- [x] 整理配置：
  - [x] 在 `application.yml` 补充 `payment.mode`、`payment.mock.enabled`、mock 展示占位配置。
  - [x] 用配置类集中读取支付配置。
  - [x] 保留现有 `PAYMENT_CALLBACK_SECRET` 和 `PAYMENT_CALLBACK_TIMEOUT_SECONDS` 环境变量兼容。
- [x] 调整 `PaymentController`：
  - [x] 控制器只负责 HTTP 参数、当前用户获取、调用 facade 和响应映射。
  - [x] 保留 `/api/payments/callback` 和 `/api/payments/orders/{orderId}/success`。
  - [x] 为 ST-008 预留 `/api/payments/orders/{orderId}/create` 的 facade 调用能力；如果本故事实现 endpoint，也只返回 mock provider 结果，不做前端支付页改造。
- [x] 添加测试与搜索验证：
  - [x] 添加 mock provider / factory / facade 的单元测试。
  - [x] 搜索确认支付 HMAC / provider 选择逻辑不再散落在 `PaymentController`。
  - [x] 执行 Java 编译或测试。

## Suggested Implementation Notes

建议新增包结构：

```text
java/src/main/java/com/school/canteen/service/payment/
  PaymentApplicationService.java
  PaymentProvider.java
  PaymentProviderFactory.java
  config/PaymentProperties.java
  dto/PaymentCreateRequest.java
  dto/PaymentCreateResponse.java
  dto/PaymentCallbackPayload.java
  dto/PaymentQueryResponse.java
  provider/MockPaymentProvider.java
```

配置建议：

```yaml
payment:
  mode: ${PAYMENT_MODE:mock}
  callback-secret: ${PAYMENT_CALLBACK_SECRET:}
  callback-timeout-seconds: ${PAYMENT_CALLBACK_TIMEOUT_SECONDS:300}
  mock:
    enabled: ${PAYMENT_MOCK_ENABLED:true}
    qr-code-url: ${PAYMENT_MOCK_QR_CODE_URL:mock://canteen-payment}
    redirect-url: ${PAYMENT_MOCK_REDIRECT_URL:}
```

`PaymentController` 中现有的 `verifyCallbackSignature()`、`hmacSha256Hex()`、`normalizeValue()` 等逻辑可以迁到 mock provider 或共享签名 helper。注意 `callback` 是公开 endpoint，但公开只代表不走 JWT，仍必须由 provider 验签；`success` 是登录用户可用的受控 mock fallback。

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
rg -n "PaymentApplicationService|PaymentProvider|PaymentProviderFactory|MockPaymentProvider|payment.mode|PAYMENT_MODE" java/src/main/java java/src/main/resources/application.yml
rg -n "hmacSha256Hex|verifyCallbackSignature|@Value\\(\"\\$\\{payment" java/src/main/java/com/school/canteen/controller/PaymentController.java java/src/main/java/com/school/canteen/service/payment
```

Expected result:

- 支付 facade、provider 接口和 mock provider 均存在。
- `PaymentController` 不再持有主要 provider 选择和签名细节。
- mock 支付创建结果包含后续 ST-008 可直接返回给前端的二维码 / 跳转 / 小程序占位字段。
- 未完成的真实沙箱 provider 返回明确的未实现错误。
- Java 编译或测试通过；若环境阻塞，错误被记录。

## Dependencies

- ST-003 已完成，订单与购物车主路径稳定。
- `OrderService.markOrderPaid()`、`markOrderPaidByNumber()` 和订单状态机仍是订单状态变更的唯一入口。
- `SecurityConfig` 已允许 `/api/payments/callback` 公共访问，并要求 `/api/payments/**` 其他路径鉴权。
- ST-008、ST-009、ST-010 将基于本故事的 facade / provider 契约继续实现支付创建响应、回调幂等和状态查询。

## Out of Scope

- 真实微信支付 / 支付宝 SDK 接入、证书加载、真实沙箱联调。
- 完整 `POST /api/payments/orders/{orderId}/create` 前端联调和支付弹窗改造；这属于 ST-008 / ST-010。
- 回调幂等表、订单置为 `PAID` 后 SSE 推送增强；这属于 ST-009。
- 小程序 `wx.requestPayment` 调起；这属于 ST-015。
- 支付 README / demo 脚本；这属于 ST-021。

## Dev Agent Record

Completed At: 2026-05-20

Files Changed:

- `java/src/main/java/com/school/canteen/controller/PaymentController.java`
- `java/src/main/java/com/school/canteen/service/payment/PaymentApplicationService.java`
- `java/src/main/java/com/school/canteen/service/payment/PaymentProvider.java`
- `java/src/main/java/com/school/canteen/service/payment/PaymentProviderFactory.java`
- `java/src/main/java/com/school/canteen/service/payment/config/PaymentProperties.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCallbackPayload.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCompletionResponse.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCreateRequest.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentCreateResponse.java`
- `java/src/main/java/com/school/canteen/service/payment/dto/PaymentQueryResponse.java`
- `java/src/main/java/com/school/canteen/service/payment/enums/PaymentMode.java`
- `java/src/main/java/com/school/canteen/service/payment/enums/PaymentProviderType.java`
- `java/src/main/java/com/school/canteen/service/payment/enums/PaymentStatus.java`
- `java/src/main/java/com/school/canteen/service/payment/provider/MockPaymentProvider.java`
- `java/pom.xml`
- `java/src/main/resources/application.yml`
- `java/src/test/java/com/school/canteen/service/payment/PaymentApplicationServiceTest.java`
- `java/src/test/java/com/school/canteen/service/payment/PaymentProviderFactoryTest.java`
- `java/src/test/java/com/school/canteen/service/payment/provider/MockPaymentProviderTest.java`
- `docs/stories/ST-007-payment-facade-provider-mock.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`

Implementation Notes:

- Added a payment facade and provider abstraction so `PaymentController` delegates payment creation, callback handling, mock success and status query.
- Added a mock provider that generates traceable transaction ids and ST-008-ready placeholder fields: `qrCodeUrl`, `redirectUrl` and `miniProgramParams`.
- Added centralized `payment.*` configuration through `PaymentProperties`, including `PAYMENT_MODE`, `PAYMENT_MOCK_ENABLED`, `PAYMENT_CALLBACK_SECRET` and `PAYMENT_CALLBACK_TIMEOUT_SECONDS`.
- Kept `/api/payments/callback` public but provider-verified, and kept `/api/payments/orders/{orderId}/success` as authenticated mock/demo fallback.
- Sandbox mode now fails clearly with `PAYMENT_PROVIDER_NOT_IMPLEMENTED` until a real WeChat or Alipay provider is added.
- Payment tests use JUnit assertions directly, and `assertj-core` is excluded from `spring-boot-starter-test` because the project does not use AssertJ tests.

Validation:

- `mvn test` passed in `java/`: 7 tests, 0 failures, 0 errors.
- Search check confirmed `PaymentApplicationService`、`PaymentProviderFactory`、`MockPaymentProvider` and `payment.mode` are present.
- Search check confirmed `PaymentController` no longer contains `hmacSha256Hex`、`verifyCallbackSignature` or payment `@Value` fields.
