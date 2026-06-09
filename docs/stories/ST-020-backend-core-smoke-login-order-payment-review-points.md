# Story ST-020: 后端核心路径冒烟测试：登录、下单、支付、评价、积分

Status: Completed

Epic: EPIC-007 验收、回归与交付稳定性  
Priority: Must  
Estimate: 3 points  
Planned Day: D6  
Primary Files: `java/src/test/java/com/school/canteen/smoke/BackendCoreSmokeTest.java`, `java/src/test/resources/application-smoke-test.yml`  
Likely Touch Points: `java/pom.xml`, `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为交付验收者和演示讲解者，我希望后端登录、下单、mock 支付、订单流转、评价和积分奖励主链路可以用一条 Maven 命令完成冒烟验证，这样在演示前可以快速确认真实 Spring MVC、安全过滤器、业务服务和数据库写入没有明显回归。

## Context

ST-019 已完成 Web 端核心路由的浏览器级冒烟测试，但它通过浏览器层 API mock 保证前端稳定，不覆盖真实后端业务链路。本故事补齐后端核心路径验证，使用 H2 内存数据库和 mock 支付配置，让测试不依赖本机 MySQL、Redis 或外部支付服务，同时尽量走真实控制器、JWT、服务和 JPA 写入。

## Acceptance Criteria

1. 新增后端核心链路 smoke 测试，覆盖学生登录、管理员登录和 JWT 受保护接口访问。
2. smoke 使用测试内存数据库和测试 profile，不能依赖本机 MySQL、Redis 或真实支付服务可用。
3. smoke 能通过真实 `/api/orders` 创建订单，并校验订单号、订单金额和下单成功响应。
4. smoke 能通过 mock 支付接口发起支付、完成支付并查询到 `PAID` 状态。
5. smoke 能通过管理员令牌推进订单制作和就绪，再通过学生令牌确认取餐。
6. smoke 能通过 multipart 评价接口提交订单评价，并触发评价奖励积分。
7. smoke 能查询积分余额和积分流水，确认评价奖励至少发放基础积分且流水来源为 `REVIEW_REWARD`。
8. 修复 smoke 暴露的评价奖励事务问题，保证评价后奖励记录、积分余额和积分流水在同一业务语义下可靠落库。
9. 完成 Maven smoke 验证，并记录验证命令和结果。

## Dev Tasks

- [x] 创建 ST-020 story 文档和状态更新。
- [x] 新增 H2 测试依赖和 `smoke-test` profile 配置。
- [x] 新增 `BackendCoreSmokeTest`，以 MockMvc 覆盖登录、下单、支付、订单流转、评价、积分链路。
- [x] 为 smoke 提供内存缓存替身，避免测试依赖 Redis cache manager。
- [x] 修复评价奖励发放事务边界，确保事务提交后奖励处理使用新事务。
- [x] 调整评价奖励积分更新路径，复用 `UserService.addPoints` 和积分日志服务逻辑。
- [x] 运行后端 smoke 测试并记录结果。

## Verification

Run from repo root:

```powershell
cd java
mvn -q -Dtest=BackendCoreSmokeTest test
cd ..
rg -n "BackendCoreSmokeTest|application-smoke-test|REQUIRES_NEW|UserService.addPoints|ST-020" java docs/stories docs/sprint-status.yaml docs/bmm-workflow-status.yaml
```

Expected result:

- `mvn -q -Dtest=BackendCoreSmokeTest test` passes.
- 测试日志中可看到订单创建、mock 支付完成、评价创建、`Awarded 10 points`、积分余额 `points=10` 和积分流水 `POINT_HISTORY_FETCHED`。
- 测试不需要本机 MySQL、Redis 或外部支付服务。

## Dependencies

- ST-007 至 ST-010 已完成支付 facade、mock provider、支付创建、支付完成和状态查询能力。
- ST-016 已完成评价、个人中心和积分商城主流程。
- ST-019 已完成 Web 前端路由 smoke，本故事补齐真实后端链路。

## Out of Scope

- 真实 MySQL 演示数据初始化与账号校验，这些属于 ST-022。
- 本地启动文档与 10 分钟 demo 脚本，这些属于 ST-021。
- sandbox/真实支付渠道联调，本故事仅验证 mock 支付链路。

## Dev Agent Record

Created At: 2026-06-08  
Completed At: 2026-06-08

Files Changed:

- `docs/stories/ST-020-backend-core-smoke-login-order-payment-review-points.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `java/pom.xml`
- `java/src/test/resources/application-smoke-test.yml`
- `java/src/test/java/com/school/canteen/smoke/BackendCoreSmokeTest.java`
- `java/src/main/java/com/school/canteen/repository/UserRepository.java`
- `java/src/main/java/com/school/canteen/service/impl/ReviewRewardServiceImpl.java`

Implementation Notes:

- Smoke 使用 `@SpringBootTest` + `MockMvc`，加载真实 Spring Boot 应用上下文、JWT 过滤器、控制器和 JPA repository。
- `smoke-test` profile 使用 H2 MySQL compatibility mode 和 mock 支付配置，避免依赖本机数据库和外部支付。
- 测试通过种子用户、窗口和菜品构造最小业务数据，再走真实接口推进全链路。
- 评价奖励处理改为 `REQUIRES_NEW`，匹配评价事务提交后的奖励发放语义，避免事务监听器中写入被回滚或不落库。
- 评价奖励积分更新复用 `UserService.addPoints`，同时保留积分日志写入，避免绕过服务层。

Validation:

- `mvn -q -Dtest=BackendCoreSmokeTest test` passed in `java`.
- Smoke 验证了学生/管理员登录、下单、mock 支付创建与完成、支付状态查询、订单制作/就绪/取餐、评价创建、积分余额和积分流水。
