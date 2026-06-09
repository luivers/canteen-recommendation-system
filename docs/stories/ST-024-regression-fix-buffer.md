# Story ST-024: 回归问题修复缓冲

Status: Completed

Epic: EPIC-007 验收、回归与交付稳定性  
Priority: Should  
Estimate: 4 points  
Planned Day: D7  
Primary Files: `scripts/pre-release-check.ps1`, `scripts/web-smoke-cdp.mjs`, `java/src/test/java/com/school/canteen/smoke/BackendCoreSmokeTest.java`  
Likely Touch Points: `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为毕业设计交付验收者，我希望 D7 预留的回归修复缓冲可以被明确执行、记录和关闭，这样在发布前如果 Web、后端、小程序或交付包检查暴露阻断问题，可以优先修复；如果没有发现阻断回归，也能留下完整验证记录，证明本轮交付不是跳过了回归环节。

## Context

ST-019 已提供 Web 核心路由 smoke，ST-020 已提供后端登录、下单、支付、评价、积分主链路 smoke，ST-023 已提供发布前打包检查和可选 full smoke 串联能力。ST-024 不新增业务功能，专门用于承接发布前最后一轮回归验证和必要的小范围修复。本次执行中，`pre-release-check.ps1 -FullSmoke` 已覆盖 Web build、后端 package、小程序关键文件、Web smoke 和后端核心 smoke，未发现需要代码修复的阻断回归。

## Acceptance Criteria

1. 创建 ST-024 story 文档，明确回归缓冲的执行范围、验证命令和完成标准。
2. 从项目根目录执行发布前 full smoke，覆盖 Web 构建、后端打包、小程序关键入口、Web 路由 smoke 和后端核心业务 smoke。
3. 若 full smoke 暴露阻断回归，优先修复并补充验证记录；若未暴露阻断回归，明确记录“无需代码修复”。
4. 验证 Web smoke 仍覆盖 12 条核心路由且 `console errors: 0`。
5. 验证后端核心 smoke 仍覆盖学生/管理员登录、下单、mock 支付、订单流转、评价、积分余额和积分流水。
6. 更新 story 索引、Sprint 状态和 BMAD workflow 状态，将 ST-024 标记为 completed。
7. 保持 ST-024 不扩大业务范围，不引入新的功能开发或非必要重构。

## Dev Tasks

- [x] 创建 ST-024 story 文档。
- [x] 执行 `.\scripts\pre-release-check.ps1 -FullSmoke`。
- [x] 确认 Web build 和后端 package 通过。
- [x] 确认 Web smoke 12 条核心路由通过且无 console error。
- [x] 确认后端核心 smoke 通过。
- [x] 记录本次回归未发现需要代码修复的阻断项。
- [x] 更新 `docs/stories/README.md`、`docs/sprint-status.yaml` 和 `docs/bmm-workflow-status.yaml`。

## Verification

Run from repo root:

```powershell
.\scripts\pre-release-check.ps1 -FullSmoke
rg -n "ST-024|回归问题修复缓冲|pre-release-check.ps1 -FullSmoke|无需代码修复|Web smoke passed" docs scripts
```

Expected result:

- `.\scripts\pre-release-check.ps1 -FullSmoke` passes.
- Web build generates `vue/dist/index.html`.
- Backend package generates `java/target/canteen-recommendation-1.0.0.jar`.
- Web smoke reports `Web smoke passed: 12 routes, console errors: 0`.
- Backend core smoke passes through Maven with `BackendCoreSmokeTest`.

## Dependencies

- ST-019 已完成 Web 核心路径 smoke。
- ST-020 已完成后端核心业务链路 smoke。
- ST-023 已完成发布前打包检查脚本和 full smoke 串联。

## Out of Scope

- 新增业务功能、页面或接口。
- 修复未被本轮回归验证暴露、且不影响发布演示的低优先级体验问题。
- 替代 ST-021 本地启动文档或 ST-022 数据库初始化与演示账号校验。

## Dev Agent Record

Created At: 2026-06-08  
Completed At: 2026-06-08

Files Changed:

- `docs/stories/ST-024-regression-fix-buffer.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`

Implementation Notes:

- 本故事作为 D7 回归缓冲执行，实际验证结果未暴露阻断回归，因此无需业务代码修复。
- 复用 ST-023 的 full smoke 串联能力，将 ST-019 Web smoke 与 ST-020 后端核心 smoke 纳入同一条发布前检查路径。
- 本轮仅补充回归闭环文档和状态记录，避免在发布前扩大功能范围。

Validation:

- `.\scripts\pre-release-check.ps1 -FullSmoke` passed from repo root.
- Web smoke passed with 12 routes and `console errors: 0`.
- Backend core smoke passed through `BackendCoreSmokeTest`.
- No blocking regression was found; no code fix was required for ST-024.
