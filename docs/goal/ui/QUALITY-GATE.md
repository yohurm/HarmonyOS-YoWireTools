---
id: ui.quality-gate
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/README.md
  - docs/goal/ui/PHASE-C-DISPOSITION.md
  - docs/goal/ui/app-shell/color-scheme.md
  - docs/goal/ui/app-shell/design-tokens.md
---

# 质量门禁

**结论：不可进入大规模页面实现。**

整 App 架构与契约尚未就绪。在功能侧补上整 App 架构文档和统一工程（分层与 API）之前，本门禁不得全部通过。这不是把蓝牙、星闪、Wi-Fi 三套模块界面拼在一起就能勾掉的项。

下面每一项都按仓库里的文件或本轮读过的文档填写。未通过的项不能靠「文档已经写了」勾掉。

## 自检

| 项 | 结果 | 证据 |
| --- | --- | --- |
| 1. 本轮不改业务代码，不铺页面 | 通过 | 界面规范只在 `docs/goal/ui/`。另补仓库里缺失、而 `.github/workflows/ui-tokens.yml` 已经调用的 `scripts/check-ui-tokens.ps1`。未改 `features/`、`product/`、`common/`（含 `youi_kit`） |
| 2. 顶层五项与 `main` 的路由常量一致 | 通过 | `product/phone/src/main/ets/navigation/AppRoutes.ets` 的五个常量和下标；`docs/goal/ui/app-shell/information-architecture.md` |
| 3. 导航不另起一套栈 | 通过 | `product/phone/src/main/ets/pages/Index.ets` 一个 `Navigation`、一个 `NavPathStack`、`NavigationMode.Stack`。`docs/goal/ui/app-shell/navigation.md` 沿用它，并废止 Wi-Fi Phase-C 的独立栈与 `Auto` |
| 4. 页面不直调 Kit，且没有新造 Repository 或查询函数 | 通过 | 分层引用 PR #6 `NL-001.md`、PR #7 `WN-001.md`、PR #8 `BT-001.md`。日志中心写明不新命名读接口：`docs/goal/ui/log/center.md` |
| 5. 组件树里的符号在文档仓或 `Index.ets` 中真实存在 | 通过 | 允许列表：`docs/goal/ui/app-shell/README.md`。`HdsListItem`、`YoListRow`、`YoTextField` 明确不用。`SegmentButton` 专页写明不支持通用属性 |
| 6. 每个屏幕都有布局、组件树、七态、编号追溯 | 通过 | 对 `docs/goal/ui/{bluetooth,nearlink,wifi-network,workbench,log,settings}` 下的屏幕文件检索 `## 布局`、`## ArkUI 组件树`、`## 状态矩阵` 以及默认、按下、禁用、空、错误、加载、无权限七行，缺失数为 0。索引和 `app-shell` 不是屏幕，不计入 |
| 7. Phase-C 每份旧 UI 稿都有处置，壳不再有三套断点 | 通过 | `docs/goal/ui/PHASE-C-DISPOSITION.md` 覆盖 PR #9 #10 #11 的全部 UI 文件。壳只认 `docs/goal/ui/app-shell/` |
| 8. Design Token 不新造资源名 | 通过 | `docs/goal/ui/app-shell/design-tokens.md` 只引用 `common/youi_kit/Index.ets` 已导出的 Token。`base/element/color.json` 与 `dark/element/color.json` 各 40 个同名 `youi_*` |
| 9. 浅色成功/警告胶囊的设计目标达到辅助文本大于 3:1，深色同样核过 | 通过 | 目标色与算式在 `docs/goal/ui/app-shell/design-tokens.md`。浅色成功目标 3.12，警告目标 3.15。深色沿用当前 Kit，成功 5.18，警告 4.57，且低于 15.7:1。当前浅色 Kit 约 2.00 与 2.48 标为待替换。屏幕仍只用 `YoStatusPill`。替换 `color.json` 不在本 PR。依据 `设计/设计指南/系统特性&能力/系统特性/深色模式.md` |
| 10. BT / NL / WN 编号只对接功能文档，不在本规范另编 | 阻塞 | `git ls-tree origin/main docs` 仍为空。编号范围没变。索引是 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) head `139ddc61`（仍为草案）的 `docs/goal/citation.md`。星闪树是 `d58de1c9`，蓝牙树是 `fba7e5d6`，Wi-Fi 树是 `7295d177`。未进 `main` |
| 11. 工作台、命令面板、日志、设置的 WB- / LOG- / SET- 编号 | 阻塞 | 范围仍是 WB-001–WB-012、LOG-001–LOG-008、SET-001–SET-006。功能侧清单在同一 head：与 Wi-Fi 树代码对齐、判定「支持」的 6 条是 WB-001、WB-002、WB-007、LOG-004、LOG-008、SET-003。其余 20 条判定「缺口」，含命令面板 WB-008–WB-012。这是清单判定，不是本 UI 规范自编的未做页面。文件未进 `main` |
| 12. 跨模块日志有一条已写明的读模型 | 阻塞 | 终点是表 `debug_log_index`。唯一允许路径：UI → ViewModel/State → UseCase → RepositoryContract → DataSource → 表 `debug_log_index`（`docs/goal/architecture/log/LOG-003.md`）。LOG-003 判定仍是「缺口」：`LoadSessionLogPreviewUseCase` 直连 `LogRepository`，页面侧未接通，不是已经接通。`LOG-008` 禁止第二日志库，不读 `YoLog` 或 hilog。未进 `main` |
| 13. 官方样例引用到具体目录，而不是只贴首页 | 通过 | 见下方样例。华为工具库目录页在本环境抓取结果为空，因此没有把该首页当成案例证据 |
| 14. 整 App 架构与契约先于大规模页面 | 阻塞 | 依赖功能侧即将补的整 App 架构文档与统一工程（分层与 API）。不是把三模块 UI 拼成一个壳。`origin/main` 没有 `docs/`。已打开的 PR #1–#20 里没有这份文档。PR #20 的 `docs/goal/citation.md` 只索引编号，不是该契约。等待功能 Goal。不猜文件名，不在本目录起草功能架构 |

第 9 项按设计目标通过，对比度目标色不改。第 10、11、12、14 项继续阻塞，所以文首结论仍是不可进入大规模页面实现。第一批原型已经在 [PR #22](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/22)，图的存在不改成可以铺页面。

## 可视化原型

第一批静态图在 [PR #22](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/22)（`cursor/ui-prototypes-55cb`，head `da7dcde`），目录 `docs/goal/ui/prototypes/`。该 head 上有 `README.md`，以及同名成对的 PNG 与 SVG。交付方是 UI 原型图 Goal，agent `bc-b0fee2c5-cd47-50ca-8063-a2e2089334a1`。本 PR 不拷这些图。

原型的依据是本 PR 的文字规范：各屏布局、ArkUI 组件树、状态矩阵，以及 `app-shell` 里的 Design Token 和壳层。原型不另起一套布局或组件。

门禁对原型只核对与这些文字规范一致。对不齐就改原型或先改文字规范，不在原型里新开控件。核对一致也不取消第 10、11、12、14 项。那些项仍阻塞时，结论保持不可进入大规模页面实现。

真机朗读和目视对比没有做。这是设计稿阶段，没有新页面可装。不把「未实机」算成上表里的通过项，也不把它写成已经验收。

## 阻塞项与对接点

合入前，UI 规范只留下面的路径和 PR，不发明编号，也不把功能清单复述成第二份。

| 项 | 阻塞原因 | 对接 | 合入前 UI 怎么引用 |
| --- | --- | --- | --- |
| 10. 蓝牙 BT-001–BT-098 | `main` 没有 `docs/goal/`。#20 仍是草案 | 编号范围没变。`citation.md` 写明从蓝牙树 `fba7e5d6dc3dd725f1baf3af4dea322943baf506` 复制，同一清单在 [PR #13](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/13)。清单原文还在 [PR #3](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/3)，架构原文还在 [PR #8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8) `docs/goal/architecture/bluetooth/`。索引是 #20 head `139ddc61` 的 `docs/goal/citation.md` | 屏幕表只标已有编号区间。不另列一份 BT 清单 |
| 10. 星闪 NL-001–NL-120 | 同上 | 编号范围没变。`citation.md` 写明星闪树是 `d58de1c9b6e7681bada1e642c1955c1a02079570`，同一清单在 [PR #14](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/14)。清单原文还在 [PR #2](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/2)，架构原文还在 [PR #6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6) `docs/goal/architecture/nearlink/` | 屏幕表只标已有编号区间。不另列一份 NL 清单 |
| 10. Wi-Fi / 网络 WN-001–WN-132 | 同上 | 编号范围没变。`citation.md` 写明从 `7295d1771288a0fb957021bd0e948073f435d96c` 复制，同一文件在 [PR #12](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/12)。清单原文还在 [PR #4](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/4)，架构原文还在 [PR #7](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7) `docs/goal/architecture/wifi-network/` | 屏幕表只标已有编号区间。不另列一份 WN 清单 |
| 10. 总表 | 同上 | `docs/goal/checklist/master.md`。`citation.md` 写明复制自 [PR #5](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/5) 的 `95c4f93d1b316f76f098a15da20d5b1fecbd9b7d`。WB / LOG / SET 不计入该文件的 350 条 | 不把总表抄进 UI 目录 |
| 11. WB- / LOG- / SET- | 文件在 PR #20 草案，未进 `main` | 索引 `docs/goal/citation.md`。清单：`docs/goal/checklist/workbench.md`、`log.md`、`settings.md`。架构：`docs/goal/architecture/workbench/`（WB-001–WB-012）、`log/`（LOG-001–LOG-008）、`settings/`（SET-001–SET-006）。与 Wi-Fi 树代码对齐、判定「支持」：WB-001、WB-002、WB-007、LOG-004、LOG-008、SET-003。判定「缺口」的 20 条：WB-003–WB-006、WB-008–WB-012（命令面板全部）、LOG-001–LOG-003、LOG-005–LOG-007、SET-001、SET-002、SET-004–SET-006。缺口来自这些清单，不是本 UI 规范另写的未做页面 | 屏幕指向这些编号。不把「支持」写成页面已按本设计铺完，也不把「缺口」改写成另一套编号 |
| 12. 跨模块日志读模型 | 允许路径已写明，LOG-003 仍是缺口，且未进 `main` | 终点是表 `debug_log_index`。唯一允许路径见 `docs/goal/architecture/log/LOG-003.md` 与 `docs/goal/citation.md`：UI → ViewModel/State → UseCase → RepositoryContract → DataSource → 表 `debug_log_index`。LOG-003 判定「缺口」：`LoadSessionLogPreviewUseCase` 直连 `LogRepository.getInstance().list`，中间没有页面、页面状态、RepositoryContract、DataSource。不是已经接通。`LOG-008` 判定「支持」：禁止第二日志库，会话列表不读 `YoLog` 或 hilog | 日志中心只渲染页面状态给出的行，不新命名查询函数，也不把直连用例当成已接通 |
| 14. 整 App 架构与契约 | 功能侧文档还没有 | 等待功能 Goal 的整 App 架构文档与统一工程（分层与 API）。已查 `main` 与已打开 PR，没有可引用的路径。PR #20 的编号索引和三份模块架构（PR #6、#7、#8）都不是这份契约 | 壳层导航和页面状态只标待对齐位置，见 `docs/goal/ui/app-shell/navigation.md` 与 `information-architecture.md`。不发明路由类型、页面状态类型或跨模块跳转函数 |

## 样例

从这些目录学到的用法已经写进壳和屏幕，不是附在文末的空链接。

| 样例 | 用在哪里 |
| --- | --- |
| [HarmonyOSComponentUXExamples](https://gitcode.com/HarmonyOS_Samples/HarmonyOSComponentUXExamples) `products/phone/.../navigation/bottomtabbar/`、`titlebar/`、`container/list`、`container/bindsheet`、`container/dialog`、`select/toggle`、`input` | 底栏用 `HdsTabs`、标题用 `HdsNavigation`、列表用 `List`/`ListItem`、半模态用 `bindSheet`、确认用 `AlertDialog`、设置用 `Toggle`、日志搜索用 `Search` |
| [LayoutSample](https://gitcode.com/HarmonyOS_Samples/guide-snippets/tree/master/ArkUISample/LayoutSample) | 调试页优先 `Column`/`Row`，安全区不靠绝对定位 |
| [ArktsMvvmSample](https://gitcode.com/HarmonyOS_Samples/guide-snippets/tree/master/ArkUISample/ArktsMvvmSample) | 只采用 Model / View / 页面状态分开。样例 README 是 V1，本工程新界面用状态管理 V2，不抄 `@State` 页 |
| [BindSheet](https://gitcode.com/HarmonyOS_Samples/guide-snippets/tree/master/ArkUISample/BindSheet) | 过滤与说明用半模态，不承载整条调试流程 |
| [NativeDialogSample](https://gitcode.com/HarmonyOS_Samples/guide-snippets/tree/master/ArkUISample/NativeDialogSample) | 这是 NDK 弹窗。本设计不采用。确认框走 ArkTS `AlertDialog` |

`SegmentButton` 的约束来自文档仓 `开发/API参考/应用框架/ArkUI（方舟UI框架）/ArkTS组件/系统预置UI组件库/SegmentButton.md`：不支持通用属性。宽度写在外层。

## 开放缺口

- 功能侧文档门禁（PR #15–#18）在兄弟 Goal 里未通过。本 UI 设计不重裁那些架构冲突。
- PR #1 的工作台实现未合并。本设计不引用它的用例签名。
- `main` 上工作台与更多仍是空的 `YoPageShell`。
- 浅色成功、警告的目标色已写在 `design-tokens.md`。替换 `common/youi_kit` 的 `color.json` 留给实现阶段，不在本 PR。
- [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) head `139ddc61` 仍是草案。壳层 26 条里，功能清单判定「支持」的是 WB-001、WB-002、WB-007、LOG-004、LOG-008、SET-003；其余 20 条是「缺口」。LOG-003 的读路径终点是表 `debug_log_index`，页面侧未接通。这些文件尚未进入 `main`。
- 整 App 架构文档与统一工程（分层与 API）仍等待功能 Goal。没有可引用的路径。在它到达并进入可引用位置之前，门禁不得全部通过。
- 第一批原型在 [PR #22](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/22) 的 `docs/goal/ui/prototypes/`，不在本 PR。只核对与文字规范一致。有图也不取消第 10、11、12、14 项。
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
# UI 规范门禁

对照本目录，不对照已作废的旧稿。

| 项 | 结果 | 说明 |
| --- | --- | --- |
| 1. 从零新写，不延续旧 UI | 通过 | PR #19 已关闭未合并，旧稿作废，不是底稿。PR #22 已关闭未合并，不是原型底稿 |
| 2. 每个模块页有布局、ArkUI 树、七态 | 通过 | 见蓝牙、星闪、Wi‑Fi、工作台、日志、设置 |
| 3. 关键模式标注来源 | 通过 | [SOURCES.md](SOURCES.md)。Top 12 开源样例，加上第二轮看过的工具壳、日志、空态、蓝牙列表、测速、半模态 |
| 4. 色彩用宇宙蓝与雪域灰语义 Token | 通过 | `brand` 浅色 `#0A59F7`。不用 ibest `#1989fa`、CoolMall `#465CFF`、Material `#2563EB` |
| 5. 一 App、单 phone HAP | 通过 | 不新开产品模块 |
| 6. 只改文档 | 通过 | 无业务、无 `youi_kit`、无页面、无原型图 |
| 7. 界面不调用 Kit | 通过 | 数据路径只写对齐槽 |
| 8. 功能编号已在 main | **拦住** | 编号只在未合并的 PR #20，不在 `main`。本文不新造编号 |
| 9. 整 App 契约已在 main | **拦住** | APP-001–006 只在未合并的 PR #21。不把三个无线模块缝进壳来放行 |
| 10. 原型不拉低文字规范 | 通过 | 旧图不在本文；以后的图放到 `docs/goal/ui/prototypes/` |
| 11. 可以开始大规模铺页面 | **否** | 第 8、9 项仍拦住 |

结论：不可进入大规模页面实现。
