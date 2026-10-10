# 界面规范质量门禁

**结论：不可进入大规模页面实现。**

外部阻塞还在。有本规范也不表示可以铺页面。不合并本 PR。

## 逐项

| # | 项 | 判定 | 依据 |
| --- | --- | --- | --- |
| 1 | 规范从 `main` 新写，不把 PR #19 / Phase-C 当底稿 | 通过 | 本分支只新增 `docs/goal/ui/` 与令牌检查脚本。旧稿作废声明在 [README.md](README.md) |
| 2 | 每屏有区域、滚动、分栏、ArkUI 组件树、七态的具体呈现 | 通过 | 各屏文件。树使用设计指南和 ArkUI 参考中的组件，不写只列名字的树 |
| 3 | 视觉对照 8 个市场参考，而不是少数商品标题 | 通过 | 八条都有商品页。连接 sheet、扫描列表、list+detail、场景 Tab、控制台、壳、数据卡、过滤后扫描分别落在 [layout-patterns.md](app-shell/layout-patterns.md)。FastBle 没有随包截图，文中不描述没看见的界面 |
| 4 | 组件不臆造 | 通过，附限制 | GitCode WAF 418，`guide-snippets` 与 `HarmonyOSComponentUXExamples` 的源码树未读，不引用它们的树。`Chip`、`Select`、`bindSheet`、`SubHeader`、`SegmentButton`、`Tabs`、`List` 以设计指南或 ArkUI 参考页为准 |
| 5 | UI 不直调 Kit | 通过 | 各屏写明动作进 ViewModel。Kit 只出现在对齐位的最后一跳 |
| 6 | 未改业务代码、未改 `youi_kit`、未铺页面、未画原型、未拷图 | 通过 | diff 只有文档和 `scripts/check-ui-tokens.ps1` |
| 7 | Token 写明层级、间距、热区、列表行、状态胶囊、宽窄屏、深浅色 | 通过 | [design-tokens.md](app-shell/design-tokens.md)、[density.md](app-shell/density.md)、[color-scheme.md](app-shell/color-scheme.md)。数值来自设计指南，不改 Kit 的 `color.json` |
| 8 | 功能编号已进 `main` 且可引用 | **阻塞** | `main` 没有 `docs/goal/`。索引只在 PR #20 `docs/goal/citation.md`。未合并前，屏上不把编号写成已经验收 |
| 9 | 整机架构与契约已进 `main` | **阻塞** | 文件在 PR #21：`docs/goal/checklist/app.md`、`docs/goal/architecture/app/APP-001.md`–`APP-006.md`。该 PR 正文里 APP-003、APP-004、APP-005 仍是缺口。壳的路由表和跨模块状态只留对齐位。禁止把蓝牙、星闪、Wi-Fi 三个模块拼成壳来勾掉本项 |
| 10 | 原型不以旧图降低规格 | 通过（不构成可铺页面） | PR #22 已关闭且未合并。不是底稿。新图以后交到 `docs/goal/ui/prototypes/`，agent `bc-b0fee2c5-cd47-50ca-8063-a2e2089334a1`。本门禁不因为没有新图而放行实现 |
| 11 | 可以开始大规模页面实现 | **否** | 第 8、9 项未解除。解除前本结论保持「不可进入大规模页面实现」 |

第 8、9 项未解除时，第 1–7、10 项通过也不等于全部门禁通过。
