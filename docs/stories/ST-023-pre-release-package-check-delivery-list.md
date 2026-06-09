# Story ST-023: 发布前打包检查与交付清单

Status: Completed

Epic: EPIC-006 本地启动、演示与交付文档  
Priority: Must  
Estimate: 2 points  
Planned Day: D7  
Primary Files: `scripts/pre-release-check.ps1`, `docs/发布前交付清单.md`  
Likely Touch Points: `docs/stories/README.md`, `docs/sprint-status.yaml`, `docs/bmm-workflow-status.yaml`

## Story

作为毕业设计交付者和演示准备者，我希望发布前可以用一条脚本检查 Web、后端、小程序、数据库脚本和文档交付物是否齐备，并在清单中明确交付路径、检查命令和补救方式，这样演示前可以快速确认打包产物与文档资料没有遗漏。

## Context

ST-019 已完成 Web 核心路径 smoke，ST-020 已完成后端核心业务 smoke。ST-023 不继续扩大功能范围，而是将发布前打包检查和交付清单固化为可重复执行的交付流程，确保 D7 聚焦稳定性、文档和演示验收。

## Acceptance Criteria

1. 新增发布前检查脚本，能够从项目根目录执行，并检查 Web、后端、小程序、数据库脚本和交付文档关键路径。
2. 脚本能够执行 `npm run build` 并确认 `vue/dist/index.html` 生成。
3. 脚本能够执行后端 Maven 打包并确认 `java/target` 下存在可交付 Jar。
4. 脚本检查小程序工程入口和主流程页面文件存在，避免交付包缺少微信开发者工具导入所需文件。
5. 脚本提供可选 full smoke 模式，能够串联 Web smoke 与后端核心 smoke。
6. 新增发布前交付清单，明确 Web、后端、小程序、数据库、文档、smoke 和检查脚本的交付路径。
7. 交付清单记录发布前检查命令、手动核对项、当前验证记录和失败补救方式。
8. 更新 story 索引、sprint 状态和 BMAD workflow 状态，标记 ST-023 已完成。

## Dev Tasks

- [x] 创建 ST-023 story 文档。
- [x] 新增 `scripts/pre-release-check.ps1` 发布前检查脚本。
- [x] 新增 `docs/发布前交付清单.md` 交付清单。
- [x] 脚本检查 Web 构建产物、后端 Jar、小程序关键文件、数据库脚本和交付文档。
- [x] 脚本增加 `-FullSmoke` 开关，用于执行 `npm run smoke:web` 和 `BackendCoreSmokeTest`。
- [x] 更新 `docs/stories/README.md`、`docs/sprint-status.yaml` 和 `docs/bmm-workflow-status.yaml`。
- [x] 运行发布前检查并记录结果。

## Verification

Run from repo root:

```powershell
.\scripts\pre-release-check.ps1
rg -n "ST-023|pre-release-check|发布前交付清单|FullSmoke|Pre-release check passed" docs scripts
```

Optional full smoke:

```powershell
.\scripts\pre-release-check.ps1 -FullSmoke
```

Expected result:

- `.\scripts\pre-release-check.ps1` passes.
- `vue/dist/index.html` exists after Web build.
- `java/target/canteen-recommendation-1.0.0.jar` or another non-original Jar exists after Maven package.
- `docs/发布前交付清单.md` records the delivery package, manual checklist and fallback handling.

## Dependencies

- ST-019 已提供 Web smoke 命令。
- ST-020 已提供后端核心业务 smoke。
- ST-021 / ST-022 的最终文档和演示账号校验可继续补强清单内容，但不阻塞本故事的发布前检查框架。

## Out of Scope

- 新增业务功能或修复非打包检查暴露的问题。
- 微信开发者工具自动上传或 CI/CD 发布流水线。
- 真实生产环境部署脚本。

## Dev Agent Record

Created At: 2026-06-08  
Completed At: 2026-06-08

Files Changed:

- `docs/stories/ST-023-pre-release-package-check-delivery-list.md`
- `docs/stories/README.md`
- `docs/sprint-status.yaml`
- `docs/bmm-workflow-status.yaml`
- `docs/发布前交付清单.md`
- `scripts/pre-release-check.ps1`

Implementation Notes:

- 发布前检查脚本默认执行 Web build、后端 package、关键小程序文件检查和交付文档检查，避免默认验证时间过长。
- `-FullSmoke` 模式复用 ST-019 与 ST-020 的 smoke 能力，将打包检查扩展到 Web 路由和后端业务链路。
- 交付清单使用中文命名，便于毕业设计材料归档和演示前人工核对。

Validation:

- `.\scripts\pre-release-check.ps1` passed from repo root.
- Contract search for `ST-023`, `pre-release-check`, `发布前交付清单`, `FullSmoke` and `Pre-release check passed` passed.
