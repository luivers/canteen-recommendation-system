# Sprint Plan — 校园食堂智能推荐系统

> 项目代号：canteen_recommendation 3.0  
> Sprint 周期：2026-05-17 ~ 2026-05-23  
> 项目级别：Level 3（复杂集成）  
> 输入文档：[PRD](prd-canteen-recommendation-2026-05-17.md)、[Architecture](architecture-canteen-recommendation-2026-05-17.md)  
> 输出类型：BMAD Phase 4 / Sprint Planning

---

## 1. Sprint 目标

本轮 Sprint 目标是在 2026-05-23 前交付一个可在 10 分钟内完整演示的作品集版本，覆盖 Web 点餐闭环、可解释推荐、后台数据看板、支付沙箱 / mock 兜底、微信小程序学生主流程和本地启动文档。

**Sprint 成功标准**

- Web 学生端可完成：浏览菜品 → 推荐 → 加购物车 → 下单 → 支付 mock/sandbox → 订单状态 → 评价 → 积分。
- 管理后台可完成：看板图表非空、高级分析可打开、核心管理表格无 console 错误。
- 推荐卡片展示中文推荐理由，理由短、可读、可解释。
- 支付模块具备 mock 兜底、回调验签、幂等处理和状态查询路径。
- 微信小程序学生端具备：首页、菜品列表、详情、购物车、订单、订单详情、评价、个人中心、积分商城。
- README / 启动文档支持 30 分钟内完成本地启动和 demo 路线复现。

---

## 2. 约束与决策

| 项目 | 决策 |
|---|---|
| 架构 | 继续使用 Spring Boot 模块化单体 + Vue Web SPA + 原生微信小程序 |
| 支付优先级 | 优先实现微信支付风格的 provider 与 mock 兜底；支付宝作为同一 facade 下的可选扩展 |
| 小程序技术 | 原生微信小程序，不引入 Taro / Uni-app |
| 实时状态 | Web 使用 SSE；小程序订单详情使用 5s 短轮询 |
| 演示保障 | 数据分析提供 demo/mock 开关，支付提供 mock 模式 |
| 文档交付 | README / 开发文档必须覆盖数据库、Redis、后端、Web、小程序启动 |

---

## 3. Sprint Backlog

| ID | Epic | Story | 优先级 | 估算 | 计划日 | 主要文件 / 模块 |
|---|---|---|---|---:|---|---|
| ST-001 | EPIC-001 | 统一前端 API baseURL，接入 `VITE_API_BASE` | Must | 2 | D1 | `vue/src/api/index.js`, `.env.*` |
| ST-002 | EPIC-001 | 收口 Pinia 用户状态与路由角色判断 | Must | 3 | D1 | `vue/src/stores/user.js`, `vue/src/router/index.js` |
| ST-003 | EPIC-001 | 拆分购物车 / 订单页关键职责，清理 localStorage 双写 | Must | 3 | D2 | `Cart.vue`, `Orders.vue`, `vue/src/api/order.js` |
| ST-004 | EPIC-001 | 图表与高级分析组件懒加载，降低首屏压力 | Must | 2 | D2 | `Dashboard.vue`, `AdvancedAnalysis.vue` |
| ST-005 | EPIC-002 | SmartRecommend 展示推荐理由 chip | Must | 2 | D2 | `SmartRecommend.vue`, `recommendation.js` |
| ST-006 | EPIC-002 | 增强健康目标推荐入口与策略切换体验 | Must | 2 | D2 | `Home.vue`, `SmartRecommend.vue` |
| ST-007 | EPIC-004 | 设计并实现支付 facade、provider 接口与 mock provider | Must | 5 | D3 | `PaymentController`, `payment` service |
| ST-008 | EPIC-004 | 支付创建接口返回二维码 / 跳转 / 小程序参数占位 | Must | 3 | D3 | `/api/payments/orders/{orderId}/create` |
| ST-009 | EPIC-004 | 支付回调验签、幂等处理、订单置为 `PAID` 并推送 SSE | Must | 5 | D3 | `OrderServiceImpl`, `OrderEventService` |
| ST-010 | EPIC-004 | 支付状态查询与前端支付结果页 / 弹窗 | Should | 3 | D4 | `PaymentController`, `Orders.vue` |
| ST-011 | EPIC-005 | 创建原生微信小程序工程骨架和 request 封装 | Must | 3 | D4 | `miniapp/`, request wrapper |
| ST-012 | EPIC-005 | 小程序 `wx.login` 静默登录与 JWT 存储 | Must | 3 | D4 | `miniapp` auth, backend miniapp login |
| ST-013 | EPIC-005 | 小程序首页、菜品列表、详情和推荐展示 | Must | 5 | D4 | `miniapp/pages/*`, dish/recommend APIs |
| ST-014 | EPIC-005 | 小程序购物车、下单、订单列表和订单详情轮询 | Must | 5 | D5 | cart/order pages, order polling |
| ST-015 | EPIC-005 | 小程序支付拉起、取消 / 失败提示和 mock 支付联调 | Must | 3 | D5 | `wx.requestPayment`, payment API |
| ST-016 | EPIC-005 | 小程序评价、个人中心和积分商城主流程 | Must | 5 | D5 | review/profile/rewards pages |
| ST-017 | EPIC-003 | 管理后台 demo/mock 数据开关 | Must | 3 | D5 | `statistics.js`, dashboard components |
| ST-018 | EPIC-003 | 空数据图表降级与图表非空验收 | Must | 2 | D5 | `components/admin/*` |
| ST-019 | EPIC-007 | Web 核心路径冒烟测试与 console 错误清零 | Must | 3 | D6 | Web student/admin pages |
| ST-020 | EPIC-007 | 后端核心路径冒烟测试：登录、下单、支付、评价、积分 | Must | 3 | D6 | API controllers/services |
| ST-021 | EPIC-006 | 本地启动文档与 10 分钟 demo 脚本 | Must | 3 | D6 | `README.md`, `docs/开发文档.md` |
| ST-022 | EPIC-006 | 数据库初始化与演示账号校验 | Must | 2 | D6 | `canteen_recommendation.sql` |
| ST-023 | EPIC-006 | 发布前打包检查与交付清单 | Must | 2 | D7 | `vue`, `java`, docs |
| ST-024 | EPIC-007 | 回归问题修复缓冲 | Should | 4 | D7 | 全项目 |

**总估算：78 story points**  
这是高强度 7 天冲刺，D7 必须用于修复和交付，不应继续扩大范围。

---

## 4. Day-by-Day Plan

| 日期 | Day | 重点 | 完成标准 |
|---|---|---|---|
| 2026-05-17 | D0 | Sprint planning、范围冻结 | Backlog、状态文件、验收标准完成 |
| 2026-05-18 | D1 | 前端 API / Pinia / 路由基础治理 | Web 登录、鉴权、API baseURL 稳定 |
| 2026-05-19 | D2 | 推荐 UX 与前端性能治理 | 推荐理由可见，图表/高级分析懒加载 |
| 2026-05-20 | D3 | 支付 facade、mock、回调主链路 | Web 订单可 mock 支付并变更为 `PAID` |
| 2026-05-21 | D4 | 小程序骨架、登录、浏览与下单基础 | 小程序可登录、浏览、加购、下单 |
| 2026-05-22 | D5 | 小程序支付 / 订单 / 评价 / 积分，后台 demo 数据 | 小程序主流程闭环，后台图表非空 |
| 2026-05-23 | D6/D7 | 冒烟测试、文档、打包和演示脚本 | 10 分钟 demo 路线可复现 |

---

## 5. Demo 路线

1. 学生 Web 端登录，查看首页推荐理由，按健康目标筛选推荐。
2. 浏览菜品，加入购物车，创建订单，使用 mock / sandbox 支付。
3. 订单状态从 `PENDING` 进入 `PAID`，Web 端收到状态更新。
4. 完成订单评价，查看积分变化和积分商城兑换。
5. 管理员登录后台，查看 Dashboard、高级分析和导出入口。
6. 小程序静默登录，完成浏览、加购、下单、支付、订单轮询和评价。
7. 展示 README 启动步骤、支付模式切换和 demo 数据开关。

---

## 6. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| 支付沙箱证书 / 商户号不可用 | 真实沙箱链路阻塞 | mock provider 必须先完成，sandbox 作为增强 |
| 小程序工作量过大 | D5 无法闭环 | 优先学生主流程，后台管理和复杂筛选不进小程序 |
| 现有 Web 状态散落 localStorage | 鉴权 bug 和路由误判 | D1 优先收口 Pinia 与路由守卫 |
| 数据分析真实数据不足 | demo 图表空白 | D5 前完成 demo/mock 开关 |
| 交付日继续开发新功能 | 稳定性下降 | D7 仅修复、文档、打包和演示验证 |

---

## 7. Definition of Done

每个 Story 完成时必须满足：

- 代码已落到对应模块，未引入无关重构。
- 关键路径有手动验证步骤或自动测试记录。
- 新增前端 API 走 `vue/src/api/`，不在组件内创建 Axios 实例。
- 新增后端写接口遵守 JWT / RBAC / 当前用户校验。
- 支付、订单、积分等重复调用场景具备幂等或防重复说明。
- 用户可见错误有明确提示，控制台无新增未处理异常。

---

## 8. 下一步

建议下一条 BMAD 命令进入 `/bmad:create-story`，从 `ST-001` 开始创建可执行开发故事。若要直接开发，应按 D1 → D2 → D3 的顺序推进，先稳定 Web 基础，再接支付和小程序。

