# Story ST-015: 小程序支付拉起、取消 / 失败提示和 mock 支付联调

Status: Completed

Epic: EPIC-005 微信小程序学生端  
Priority: Must  
Estimate: 3 points  
Planned Day: D5  
Primary Files: `miniapp/pages/order-detail/*`, `miniapp/api/payment.js`, `miniapp/api/index.js`  
Likely Touch Points: `miniapp/utils/order.js`, `miniapp/utils/request.js`, `java/src/main/java/com/school/canteen/controller/PaymentController.java`, `java/src/main/java/com/school/canteen/service/payment/*`, `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为微信小程序学生用户，我希望在待支付订单详情页点击“去支付”后，小程序能调用统一支付创建接口并拉起 `wx.requestPayment` 或 mock 支付流程，同时在用户取消、支付失败、后端不可用时给出明确提示，这样我可以在小程序里完成从下单到支付结果确认的主流程闭环。

## Context

ST-011 已完成原生微信小程序工程骨架和 request 封装，ST-012 已完成 `wx.login` 静默登录与 JWT 注入，ST-014 已完成购物车、下单、订单列表、订单详情和 5 秒短轮询。订单详情页当前 `goPay()` 仍是 ST-015 占位提示。

后端支付主链路已由 ST-007 至 ST-010 提供：`POST /api/payments/orders/{orderId}/create` 创建支付参数，`GET /api/payments/orders/{orderId}/status` 查询支付状态，mock 模式可通过受控成功或回调路径将订单置为 `PAID`。小程序侧已经有 `miniapp/api/payment.js` 暴露 `createPayment()` 和 `queryPaymentStatus()`，本故事聚焦小程序支付入口、支付结果处理、mock 联调和订单详情刷新，不引入真实微信商户证书或生产支付 SDK 配置。

## Acceptance Criteria

1. 订单详情页 `goPay()` 不再显示占位提示；仅当订单为待支付且未处于操作中时允许发起支付。
2. 小程序支付入口调用 `paymentApi.createPayment(orderId, { paymentMethod: "WECHAT" })` 或等价 payload，不在页面里硬编码后端 URL。
3. 支付创建期间按钮进入 loading/disabled 状态，重复点击不会创建多个并发支付请求。
4. 支付创建失败时展示后端返回的业务错误或网络错误提示，并保持订单详情页可继续重试。
5. 能从支付创建响应中兼容读取 `miniProgramParams`、`timeStamp`、`nonceStr`、`package`、`signType`、`paySign`、`transactionId`、`provider`、`mode` 等字段；响应字段缺失时走明确降级提示。
6. 当响应包含完整微信支付参数时调用 `wx.requestPayment`，并按 `success`、`fail`、`complete` 分支处理支付结果。
7. 用户主动取消支付时显示“已取消支付”或等价温和提示，不把订单标记为已支付，不吞掉后续刷新。
8. 非取消类支付失败时显示失败原因，并允许用户再次点击支付。
9. mock 模式下，如果后端只返回 mock / 占位参数而无法真实拉起微信支付，小程序提供可演示的 mock 完成路径，并通过现有后端受控成功、回调模拟或项目已有等价接口完成订单状态流转。
10. 支付成功或 mock 完成后立即刷新订单详情，并保留 ST-014 的 5 秒短轮询作为状态同步兜底。
11. 支付完成后可调用 `paymentApi.queryPaymentStatus(orderId)` 或等价状态查询，展示本地订单状态与 provider 状态的清晰结果，不仅依赖一次性 toast。
12. 订单详情页展示支付方式、交易号或支付状态摘要；无交易号时不显示空占位。
13. 支付过程中页面隐藏或卸载时不遗留额外定时器；不得破坏 ST-014 已有订单详情轮询启停逻辑。
14. `miniapp/api/payment.js` 保持统一 API 封装，并被 `miniapp/api/index.js` 导出使用；如新增 `mockSuccess` / `completeMockPayment` helper，也应放在 API 层。
15. 若后端当前缺少小程序 mock 完成所需接口，应优先复用既有 `/api/payments/orders/{orderId}/success` 或回调模拟能力；确需后端补充时必须沿用 payment facade，不把支付分支写回 controller。
16. 执行小程序 JS 语法检查和关键契约搜索；如微信开发者工具 CLI 不可用，记录原因。

## Dev Tasks

- [x] 串接小程序支付 API：
  - [x] 在订单详情页引入 `paymentApi`。
  - [x] 调用 `createPayment()` 创建支付，payload 默认使用 `WECHAT`。
  - [x] 统一解析支付创建响应和错误消息。
- [x] 实现支付拉起与结果处理：
  - [x] 完整支付参数存在时调用 `wx.requestPayment`。
  - [x] 区分成功、用户取消和失败提示。
  - [x] 支付结束后刷新订单详情并保留短轮询兜底。
- [x] 实现 mock 支付联调：
  - [x] 识别 mock / 占位响应并进入 demo 完成路径。
  - [x] 通过既有后端受控成功或回调模拟接口推动订单变为 `PAID`。
  - [x] 将交易号、provider、支付状态摘要展示到订单详情页。
- [x] 保护交互状态：
  - [x] 支付创建和支付中禁用重复点击。
  - [x] 页面隐藏 / 卸载时不新增泄漏定时器。
  - [x] 网络错误、后端业务错误和缺字段错误均有用户可见提示。
- [x] 验证：
  - [x] 执行 miniapp JS 语法检查。
  - [x] 搜索确认支付 API、`wx.requestPayment`、mock 完成路径和轮询契约。
  - [x] 如微信开发者工具 CLI 可用，执行小程序构建/预览级检查；不可用则记录原因。

## Suggested Implementation Notes

支付参数归一化建议集中在订单详情页局部 helper 或 `miniapp/utils/payment.js` 中，避免把响应兼容逻辑散在多个分支里。优先兼容以下两种形状：

```javascript
{
  miniProgramParams: {
    timeStamp: "1710000000",
    nonceStr: "...",
    package: "prepay_id=...",
    signType: "RSA",
    paySign: "..."
  },
  transactionId: "MOCK-ORD-...",
  mode: "mock",
  provider: "MOCK"
}
```

或后端直接平铺微信支付字段：

```javascript
{
  timeStamp: "1710000000",
  nonceStr: "...",
  package: "prepay_id=...",
  signType: "RSA",
  paySign: "..."
}
```

mock 模式可先用 `wx.showModal` 明确提示“当前为演示支付”，用户确认后调用后端受控成功接口；用户取消 modal 时按取消支付处理。

## Verification

Run from repo root:

```powershell
node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"
rg -n "paymentApi|createPayment|queryPaymentStatus|requestPayment|mock.*pay|success" miniapp --glob '!node_modules'
rg -n "setInterval|POLLING_INTERVAL|stopPolling|startPolling" miniapp/pages/order-detail miniapp/utils
```

Expected result:

- 待支付订单可从订单详情页发起支付创建。
- 微信支付参数完整时能调用 `wx.requestPayment`。
- mock 模式可完成演示支付并刷新为已支付状态。
- 取消、失败、网络错误和缺字段场景均有明确提示。

## Dependencies

- ST-011 已完成小程序工程骨架、request 封装和基础页面。
- ST-012 已完成小程序 JWT 登录和 token 注入。
- ST-014 已完成订单详情页、支付占位按钮和 5 秒轮询。
- ST-007 至 ST-010 已提供后端支付 facade、创建、回调、状态查询和 mock 能力。

## Out of Scope

- 真实微信支付商户号、证书、签名密钥和生产环境支付联调。
- Web 支付结果页、二维码展示和 SSE 行为改造，这些已由 ST-008 至 ST-010 覆盖。
- 评价、个人中心和积分商城完整流程，这些属于 ST-016。
- 支付 README、环境变量说明和 10 分钟 demo 脚本，这些属于 ST-021。

## Dev Agent Record

Created At: 2026-06-02  
Completed At: 2026-06-02

Files Changed:

- `docs/stories/ST-015-miniapp-payment-request-mock-integration.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `miniapp/api/payment.js`
- `miniapp/pages/order-detail/order-detail.js`
- `miniapp/pages/order-detail/order-detail.wxml`
- `miniapp/pages/order-detail/order-detail.wxss`

Implementation Notes:

- Added `paymentApi.completeMockPayment()` for the existing backend `/api/payments/orders/{orderId}/success` mock completion endpoint.
- Replaced the order-detail payment placeholder with payment creation, WeChat payment parameter parsing, `wx.requestPayment` handling and mock payment confirmation.
- Payment cancellation, failed payment, backend errors and missing parameter fallbacks now show user-visible prompts without marking the order paid.
- Payment success and mock completion both query payment status and refresh order detail, while preserving the existing 5-second polling lifecycle.
- Order detail now displays payment method, payment status, provider/channel status and transaction id when available.

Validation:

- `node -e "const fs=require('fs'); const path=require('path'); const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>{const p=path.join(d,e.name); return e.isDirectory()?walk(p):[p];}); const files=walk('miniapp').filter(f=>f.endsWith('.js')); files.forEach(f=>new Function(fs.readFileSync(f,'utf8'))); console.log('miniapp all js syntax ok:', files.length)"` passed with 21 JS files.
- `rg -n "paymentApi|createPayment|queryPaymentStatus|completeMockPayment|requestPayment|mock.*支付|/success" miniapp --glob '!node_modules'` passed.
- `rg -n "setInterval|POLLING_INTERVAL|stopPolling|startPolling" miniapp/pages/order-detail miniapp/utils` passed.
- WeChat DevTools CLI `help` passed.
- WeChat DevTools CLI `preview` reached IDE/upload but failed because the project uses `touristappid`; DevTools returned `AppID 不合法, invalid appid`.
