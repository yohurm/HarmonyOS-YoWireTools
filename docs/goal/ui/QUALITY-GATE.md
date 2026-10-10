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
| 10. BT / NL / WN 编号只对接功能文档，不在本规范另编 | 阻塞 | `git ls-tree origin/main docs` 仍为空。路径与 PR 见下方，[PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) 的 `docs/goal/citation.md` 索引的是同一套编号。文件未进 `main`，不因 PR 存在而改成通过 |
| 11. 工作台、命令面板、日志、设置的 WB- / LOG- / SET- 编号 | 阻塞 | 范围没变。索引用 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) head `139ddc61` 的 `docs/goal/citation.md`。清单与架构路径见下方，该 head 上仍在。未进 `main` |
| 12. 跨模块日志有一条已写明的读模型 | 阻塞 | 唯一允许路径写在 PR #20 `docs/goal/architecture/log/LOG-003.md`：UI → ViewModel/State → UseCase → RepositoryContract → DataSource → 表 `debug_log_index`。该条判定仍是「缺口」：`LoadSessionLogPreviewUseCase` 直连 `LogRepository`，页面侧还没接上，不是读模型已经接通。`LOG-008.md` 禁止第二日志库，会话列表不读 `YoLog` 或 hilog。未进 `main` |
| 13. 官方样例引用到具体目录，而不是只贴首页 | 通过 | 见下方样例。华为工具库目录页在本环境抓取结果为空，因此没有把该首页当成案例证据 |

第 9 项按设计目标通过。第 10、11、12 项的对接文件已经在未合并的 PR 上，但都还没进入 `main`，所以保持阻塞。文首结论仍是不可进入大规模页面实现。

真机朗读和目视对比没有做。这是设计稿阶段，没有新页面可装。不把「未实机」算成上表里的通过项，也不把它写成已经验收。

## 阻塞项与对接点

合入前，UI 规范只留下面的路径和 PR，不发明编号，也不把功能清单复述成第二份。

| 项 | 阻塞原因 | 对接 | 合入前 UI 怎么引用 |
| --- | --- | --- | --- |
| 10. 蓝牙 BT-001–BT-098 | `main` 没有 `docs/goal/` | 编号范围没变。清单 `docs/goal/checklist/bluetooth.md`（[PR #3](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/3)）。架构 `docs/goal/architecture/bluetooth/`（[PR #8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8)）。[PR #13](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/13) head `fba7e5d6` 上也有这两处。索引改为 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) head `139ddc61` 的 `docs/goal/citation.md` | 屏幕表只标已有编号区间。不另列一份 BT 清单 |
| 10. 星闪 NL-001–NL-120 | 同上 | 编号范围没变。清单 `docs/goal/checklist/nearlink.md`（[PR #2](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/2)）。架构 `docs/goal/architecture/nearlink/`（[PR #6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6)）。[PR #14](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/14) head `d58de1c9` 上也有这两处；`citation.md` 写明 #20 从这棵星闪树复制。索引同上 | 屏幕表只标已有编号区间。不另列一份 NL 清单 |
| 10. Wi-Fi / 网络 WN-001–WN-132 | 同上 | 编号范围没变。清单 `docs/goal/checklist/wifi-network.md`（[PR #4](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/4)）。架构 `docs/goal/architecture/wifi-network/`（[PR #7](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7)）。[PR #12](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/12) head `7295d177` 上也有这两处。索引同上 | 屏幕表只标已有编号区间。不另列一份 WN 清单 |
| 10. 总表 | 同上 | `docs/goal/checklist/master.md`（[PR #5](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/5)）。#20 的 `docs/goal/citation.md` 指向同一文件 | 不把总表抄进 UI 目录 |
| 11. WB- / LOG- / SET- | 文件在 PR #20，未进 `main` | 范围没变，索引是 #20 head `139ddc61` 的 `docs/goal/citation.md`。该 head 上仍有：`docs/goal/checklist/workbench.md`（WB-001–WB-012；工作台 WB-001–WB-007，命令面板 WB-008–WB-012）与 `docs/goal/architecture/workbench/WB-001.md` 至 `WB-012.md`；`docs/goal/checklist/log.md`（LOG-001–LOG-008）与 `docs/goal/architecture/log/LOG-001.md` 至 `LOG-008.md`；`docs/goal/checklist/settings.md`（SET-001–SET-006）与 `docs/goal/architecture/settings/SET-001.md` 至 `SET-006.md` | 屏幕继续用设计屏号，并指向这些路径。不在 UI 目录再编一套编号 |
| 12. 跨模块日志读模型 | 允许路径已写明，页面未接通，且未进 `main` | 唯一允许路径，见 #20 `docs/goal/architecture/log/LOG-003.md` 与 `docs/goal/citation.md`：UI → ViewModel/State → UseCase → RepositoryContract → DataSource → 表 `debug_log_index`。LOG-003 判定仍是「缺口」：现有 `LoadSessionLogPreviewUseCase` 直连 `LogRepository.getInstance().list`，中间没有页面、页面状态、RepositoryContract、DataSource。不要写成读模型已经接通。`docs/goal/architecture/log/LOG-008.md` 禁止第二日志库，会话列表不读 `YoLog` 或 hilog | 日志中心只渲染页面状态给出的行，不新命名查询函数，也不把直连用例当成已接通 |

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
- WB- / LOG- / SET- 与跨模块日志读路径在 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) head `139ddc61`，索引 `docs/goal/citation.md`。LOG-003 仍是缺口，尚未进入 `main`。在此之前不开始按这些屏铺数据。
