---
id: ui.app-shell
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/README.md
  - docs/goal/ui/QUALITY-GATE.md
  - docs/goal/ui/PHASE-C-DISPOSITION.md
  - product/phone/src/main/ets/pages/Index.ets
  - product/phone/src/main/ets/shell/MainTabContainer.ets
  - product/phone/src/main/ets/navigation/AppRoutes.ets
  - common/youi_kit/Index.ets
---

# 应用壳

本目录是整份 UI 设计里唯一的壳、Token、权限墙和深浅色规范。蓝牙、星闪、Wi-Fi 的 Phase-C 壳文档不再各写一套断点。

质量门禁未全部通过。结论写在 [QUALITY-GATE.md](../QUALITY-GATE.md)：**不可进入大规模页面实现**。

| 文件 | 内容 |
| --- | --- |
| [information-architecture.md](information-architecture.md) | 五项信息架构、与 PRD 的收口、UI 不直调 Kit |
| [navigation.md](navigation.md) | 一条根 Navigation、目的地层级、断点 |
| [design-tokens.md](design-tokens.md) | 只用现有 YoUI Token |
| [permission-gap-wall.md](permission-gap-wall.md) | 权限墙与缺口墙 |
| [color-scheme.md](color-scheme.md) | 深浅色、对比度、状态色用法 |

## 允许出现在组件树里的符号

页面只用下面两类。不恢复 `YouiKit-Component-Catalog.md` 里已删除的 P1 组件，包括 `YoListRow`、`YoTextField`、`YoLogRow`、`FilterSheetView`、`RiskConfirmDialog`、`DataTerminalView`。

Kit 公开符号以 `common/youi_kit/Index.ets` 为准：`YoAppShell`、`YoSideNavRail`、`YoSideNavItem`、`YoSplitScaffold`、`YoPageShell`、`YoNavDestinationKind`、`YoTitleBarActionRow`、`YoTitleBarMenuItem`、`YoSegmentButton`、`YoActionButton`、`YoModeEntryCard`、`YoStatusPill`、`YoContentState`、`YoEmpty`、`YoError`、`YoLoading`、`YoPermissionDenied`、`YoToast`、`YoImmersiveSurface`（只给概览状态卡的材质）、以及 Token 类。

ArkUI / UI Design Kit 只使用文档仓里有专页的组件。本设计用到的专页：

| 组件 | 文档仓路径 |
| --- | --- |
| `Column` / `Row` | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/构建布局/线性布局 (Row／Column).md` |
| `Flex` / `Stack` | 同目录 `弹性布局 (Flex).md`、`层叠布局 (Stack).md` |
| `GridRow` / `GridCol` | 同目录 `栅格布局 (GridRow／GridCol).md` |
| `List` / `ListItem` / `ListItemGroup` | `开发/API参考/应用框架/ArkUI（方舟UI框架）/ArkTS组件/滚动与滑动/` |
| `Scroll` | 同上 `Scroll.md` |
| `Text` / `TextInput` / `TextArea` / `Search` | `…/ArkTS组件/文本与输入/` |
| `Button` | `…/ArkTS组件/按钮与选择/Button.md` |
| `Toggle` | `…/ArkTS组件/按钮与选择/Toggle.md` |
| `SegmentButton` | `…/ArkTS组件/系统预置UI组件库/SegmentButton.md` |
| `LoadingProgress` | `…/ArkTS组件/信息展示/LoadingProgress.md` |
| `Divider` / `Blank` | `…/ArkTS组件/空白与分隔/` |
| `Navigation` / `NavDestination` / `Tabs` | `…/ArkTS组件/导航与切换/` |
| `AlertDialog` | `…/ArkTS组件/弹窗/警告弹窗 AlertDialog.md` |
| `bindSheet` | `开发/指南/…/使用弹窗/绑定模态页面/绑定半模态页面（bindSheet）.md` |
| `HdsNavigation` / `HdsTabs` | `开发/API参考/应用框架/UI Design Kit（UI设计套件）/ArkTS组件/HdsNavigation.md`、`HdsTabs.md` |

`HdsListItem` 有专页，但 `common/youi_kit` 未导出对应门面，目录把它放在 P2。屏幕列表行用 `ListItem` + `Text`，不用 `HdsListItem`。

`SegmentButton` 的专页写明不支持通用属性。宽度和边距写在外层 `Row` 或 `Scroll` 上，由已有的 `YoSegmentButton` 包一层。这是样例与专页共同的约束，不是新组件。
