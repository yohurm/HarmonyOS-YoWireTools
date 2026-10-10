---
id: ui.quality-gate
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/README.md
  - docs/goal/ui/PHASE-C-DISPOSITION.md
  - docs/goal/ui/app-shell/color-scheme.md
---

# 质量门禁

**结论：不可进入大规模页面实现。**

下面每一项都按仓库里的文件或本轮读过的文档填写。未通过的项不能靠「文档已经写了」勾掉。

## 自检

| 项 | 结果 | 证据 |
| --- | --- | --- |
| 1. 本轮只写界面文档，不改业务代码 | 通过 | 变更都在 `docs/goal/ui/`。未改 `features/`、`product/`、`common/` |
| 2. 顶层五项与 `main` 的路由常量一致 | 通过 | `product/phone/src/main/ets/navigation/AppRoutes.ets` 的五个常量和下标；`docs/goal/ui/app-shell/information-architecture.md` |
| 3. 导航不另起一套栈 | 通过 | `product/phone/src/main/ets/pages/Index.ets` 一个 `Navigation`、一个 `NavPathStack`、`NavigationMode.Stack`。`docs/goal/ui/app-shell/navigation.md` 沿用它，并废止 Wi-Fi Phase-C 的独立栈与 `Auto` |
| 4. 页面不直调 Kit，且没有新造 Repository 或查询函数 | 通过 | 分层引用 PR #6 `NL-001.md`、PR #7 `WN-001.md`、PR #8 `BT-001.md`。日志中心写明不新命名读接口：`docs/goal/ui/log/center.md` |
| 5. 组件树里的符号在文档仓或 `Index.ets` 中真实存在 | 通过 | 允许列表：`docs/goal/ui/app-shell/README.md`。`HdsListItem`、`YoListRow`、`YoTextField` 明确不用。`SegmentButton` 专页写明不支持通用属性 |
| 6. 每个屏幕都有布局、组件树、七态、编号追溯 | 通过 | 对 `docs/goal/ui/{bluetooth,nearlink,wifi-network,workbench,log,settings}` 下的屏幕文件检索 `## 布局`、`## ArkUI 组件树`、`## 状态矩阵` 以及默认、按下、禁用、空、错误、加载、无权限七行，缺失数为 0。索引和 `app-shell` 不是屏幕，不计入 |
| 7. Phase-C 每份旧 UI 稿都有处置，壳不再有三套断点 | 通过 | `docs/goal/ui/PHASE-C-DISPOSITION.md` 覆盖 PR #9 #10 #11 的全部 UI 文件。壳只认 `docs/goal/ui/app-shell/` |
| 8. Design Token 不新造资源名 | 通过 | `docs/goal/ui/app-shell/design-tokens.md` 只引用 `common/youi_kit/Index.ets` 已导出的 Token。`base/element/color.json` 与 `dark/element/color.json` 各 40 个同名 `youi_*` |
| 9. 浅色状态胶囊达到设计指南对辅助文本的优秀对比（大于 3:1） | 不通过 | `YoStatusPill.ets` 用语义色字打在约 10% 的同色容器上。浅色成功胶囊约 2.00:1，警告约 2.48:1，落在 `设计/设计指南/系统特性&能力/系统特性/深色模式.md` 的「一般」，不是「优秀」。计算写在 `docs/goal/ui/app-shell/color-scheme.md`。本设计不新造色，也不在特性里复制第二套胶囊 |
| 10. BT / NL / WN 编号能在默认分支上打开 | 不通过 | `git ls-tree origin/main docs` 为空。编号在 draft PR [#6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6)、[#7](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7)、[#8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8)。屏幕里的链接指向这些路径，但本分支基于 `main`，打不开文件 |
| 11. 工作台、命令面板、日志、设置有功能架构编号 | 不通过 | 已打开的 PR #2–#18 与兄弟功能 Goal 的记录里没有 `WB-`、`LOG-`、`SET-` 切片。本设计只用设计屏号，并写明它们不是接口。见 `docs/goal/ui/app-shell/information-architecture.md` |
| 12. 跨模块日志有一条已写明的读模型 | 不通过 | 蓝牙架构稿写 `YoLog`，星闪写 `DebugLogRecord`，Wi-Fi 写 `LogCaptureService` / `LogRepository`。三份都未入库。`docs/goal/ui/log/center.md` 拒绝把它们收成一个新函数 |
| 13. 官方样例引用到具体目录，而不是只贴首页 | 通过 | 见下方样例。华为工具库目录页在本环境抓取结果为空，因此没有把该首页当成案例证据 |

第 9、10、11、12 项未通过。所以文首结论是不可进入大规模页面实现。

真机朗读和目视对比没有做。这是设计稿阶段，没有新页面可装。不把「未实机」算成上表里的通过项，也不把它写成已经验收。

## 阻塞项

1. 浅色成功、警告胶囊对比度未达到辅助文本的优秀线，而每一屏都要用 `YoStatusPill`。
2. 架构文档不在 `main`，编号追溯不能在本分支独立打开。
3. 工作台、命令面板、日志中心、设置没有功能架构编号。
4. 跨模块日志没有单一读模型。在此之前日志中心不能指定查询函数，也不能开始按该屏铺数据。

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
- 胶囊对比度要改的是 `common/youi_kit` 的字色或容器色。那不是这份文档 PR 的范围。
