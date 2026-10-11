---
id: ui.nearlink.shell
type: ui-design
status: draft
when: phase-c
related:
  - docs/goal/ui/nearlink/README.md
  - docs/goal/checklist/nearlink.md
  - common/youi_kit/Index.ets
  - product/phone/src/main/ets/shell/MainTabContainer.ets
  - product/phone/src/main/ets/navigation/AppRoutes.ets
---

# 壳与导航

星闪是应用壳里的一个一级 Tab，不是另一套应用。`product/phone` 只挂载星闪页。页内跳转留在特性自己的导航栈里。

## 依据

鸿蒙文档仓 `yohurm/HarmonyOS-Developer-docs`：

| 主题 | 仓内路径 |
| --- | --- |
| vp、fp、8vp 网格、断点、栅格、安全区 | `设计/设计指南/通用设计基础/布局/布局基础.md` |
| 拉伸、延伸、隐藏、折行、分栏 | `设计/设计指南/通用设计基础/布局/响应式布局方法.md` |
| 响应式架构：窄屏底部页签、宽屏侧栏 | `设计/设计指南/通用设计基础/布局/响应式应用架构.md` |
| 边距与间距 | `设计/设计指南/通用设计基础/视觉风格/间隔参数.md` |
| 布局容器怎么选 | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/布局概述.md` |
| 用 Navigation，不用 Router 做页内跳转 | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航和页面路由概述.md` |
| 宽屏分栏、窄屏堆栈 | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation分栏开发.md` |
| 导航容器、标题栏、内容区、工具栏 | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md` |
| 界面由状态驱动；新界面用状态管理 V2 | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/状态管理概述.md` |

工程落点：

- 壳：`common/youi_kit/src/main/ets/components/shell/YoAppShell.ets`、`YoSideNavRail.ets`、`YoPageShell.ets`、`YoSplitScaffold.ets`
- 断点：`common/platform/src/main/ets/window/WindowWidthBreakpoint.ets`
- 间距与最大宽度：`common/youi_kit/src/main/ets/token/foundation/YoSpace.ets`、`common/youi_kit/src/main/ets/token/semantic/YoResponsive.ets`
- 公开面：`common/youi_kit/Index.ets`、`common/youi_kit/doc/YouiKit-Component-Catalog.md`
- 星闪 Tab：`product/phone/src/main/ets/shell/MainTabContainer.ets` 的第 4 个页签（下标 3），路由 `AppRoutes.NEARLINK` 为 `/nearlink/overview`

架构约束见 `docs/goal/architecture/nearlink/NL-001.md`：页面只读页面状态；用户可见句子由页面状态按领域类别生成；`common/youi_kit` 不收业务文案，也不引用 `@kit.NearLinkKit`。

## 信息架构

```text
YoAppShell
└── 星闪 Tab（ROOT_TAB，YoPageShell）
    ├── 支持与开关条（始终在根页顶部）
    ├── 模式入口（扫描、广播、SSAP 客户端、SSAP 服务端、端口、配对、日志）
    ├── 扫描 MODULE
    │   └── 广播详情 OBJECT（宽屏时与列表分栏）
    ├── 广播 MODULE
    ├── SSAP 客户端 OBJECT（从扫描行或会话进入）
    ├── SSAP 服务端 MODULE
    │   └── 服务与请求 OBJECT
    ├── 端口 MODULE
    │   └── 终端 TERMINAL（宽屏时与端口列表分栏）
    ├── 配对与加密 MODULE（加密胶囊也出现在端口终端顶栏）
    ├── 会话日志 MODULE
    │   └── 单条详情 OBJECT
    └── 合作设备集 MODULE（缺口页，从支持条进入）
```

一级页是星闪 Tab。其余都是二级或对象页，标题栏有返回。半模态只用于过滤表单、切片确认、销毁端口确认，不承载一条完整调试流程。

`YoNavDestinationKind`（`common/youi_kit/src/main/ets/components/shell/YoNavDestinationKind.ets`）：

| 种类 | 星闪用法 | 底栏 |
| --- | --- | --- |
| `ROOT_TAB` | 星闪根页 | 窄屏显示应用底栏 |
| `MODULE` | 扫描、广播、服务端、端口列表、配对、日志、合作设备集 | 隐藏，显示返回 |
| `OBJECT` | 广播详情、SSAP 会话、服务端请求、日志详情 | 隐藏，显示返回 |
| `TERMINAL` | 端口终端 | 隐藏，会话区贴底 |
| `MODAL` | 过滤、确认 | 无应用壳装饰 |

页内跳转用 Navigation / NavDestination。`组件导航和页面路由概述.md` 写明 Router 不适合多端单双栏。星闪不使用 `@ohos.router` 做这些目的地。

## 断点与密度

窗口宽度断点与 `WindowWidthBreakpoint` 一致，并对应 `布局基础.md` 的栅格：

| 窗口宽度 | 断点 | 栅格 | 页边距 | 壳 |
| --- | --- | --- | --- | --- |
| 小于 600vp | COMPACT | 4 列 | 16vp | 底部 `HdsTabs` |
| 600–839vp | MEDIUM | 8 列 | 24vp | 底部页签；内容可分栏 |
| 840–1439vp | EXPANDED | 12 列 | 32vp | 同一组 Tab 移到 `YoSideNavRail`，宽 240vp |
| 大于等于 1440vp | XL | 12 列 | 32vp | 侧栏；内容最大宽 2220vp，两侧留白 |

页边距来自 `YoResponsive.pageHorizontal`，与 `布局基础.md` 的 16 / 24 / 32vp margin 相同。最大宽度 2220vp 与该文「栅格最大使用宽度」相同，Token 是 `YoResponsive.CONTENT_MAX_WIDTH`。

间距走 8vp 网格：`YoSpace` 的 4、8、12、16、24、32vp。字号用 `fp`，走 `YoTypeStyle`，随系统字体缩放。布局尺寸用 `vp`，不用 px。热区不小于 `YoSize.TOUCH_TARGET_MIN`（48vp）。列表行不低于 `YoSize.LIST_ROW_HEIGHT`（56vp），带两行摘要的行用 `YoSize.LIST_CARD_HEIGHT`（72vp）。

安全区由 `YoPageShell` 的 `HdsNavigation` 处理：顶部状态栏沉浸，滚动条贴内容视口（`contentEdgeToEdge` 的列表页）。窄屏底栏浮动边距是 `YoNavigationToken.FLOATING_TAB_MARGIN`（28vp），内容底部预留 `FLOATING_TAB_BOTTOM_PADDING`（88vp），用来避开导航条。标题栏场景用 `HdsTitleBarScene.LIST_CONTENT`，不用沉浸大图的白字样式。深色走 `YoColor` 的 `base` / `dark` 同名资源。

折叠与分屏：主操作不压在折痕上。分栏每侧最小 280vp（`YoSplitScaffold.minPaneWidthVp`）。窗口窄于分栏条件时回到单列，输入中的过滤字段和终端草稿留在页面状态里，不因旋转或分屏被清掉。`布局概述.md` 的动态布局要求切换布局时保持输入和滚动位置；星闪用同一原则，不另做一套布局容器。

`响应式应用架构.md` 的断点与现有壳一致：窗口宽度达到 840vp 时，底部 Tab 挪到左侧；达到 600vp 时，父子页面可以分栏，默认 4:6，也可以是 6:4。星闪不增加导航层级，所以侧栏里的项与底栏相同，由 `YoAppShell` 在 `isSideNavCapable` 时切换，不另做侧边 Tab 组件。

宽屏分栏用已有 `YoSplitScaffold`，默认列表:详情为 4:6（`YoNavigationToken.SPLIT_LIST_WEIGHT` / `SPLIT_DETAIL_WEIGHT`）。这是 `Navigation分栏开发.md` 里「宽屏保持列表、窄屏进栈」的工程落点。终端页改用 6:4，让收发记录占更多宽度。不新增第二种分栏组件。

## 调试工具箱的信息密度

屏上只留判断下一步所需的事实。原始字节、展开 UUID、`reasonMsg`、完整设置说明放进详情或半模态。

| 留在屏上 | 放进详情 |
| --- | --- |
| 一个状态胶囊：支持、开关、扫描、连接、加密、缺口 | 错误码的接口名、时间、方向，进会话日志 |
| 一个主操作 | HEX、TLV、两套名称、厂商数据分列 |
| 列表两行：名称或 UUID，以及地址 / RSSI / 时间 | `reasonMsg` 只在日志详情，不参与界面分支 |
| 失败时的错误码和一句原因，留在失败的那一块 | 版本说明的长文、两条设置路径的全文 |
| 应用层收发计数（端口终端） | 空口、PHY、连接间隔：这些是缺口，不显示测量值 |

同一事实只占一个位置。扫描 RSSI 只在扫描行。连接后的对端 RSSI 不是另一列，见会话日志里的 NL-103。

列表用 ArkUI `List`。Kit 目录已删除 `YoListRow`，不恢复。行内状态用 `YoStatusPill`。文本输入用 ArkUI `TextInput`，边距、字色、字号取 `YoSpace`、`YoColor`、`YoTypeStyle`。`Index.ets` 没有文本框导出，不把输入框再包一层。

二次确认用系统对话框。文案由页面状态提供。目录已删除 `RiskConfirmDialog`，不恢复，也不新增确认组件。轻量反馈用 `YoToast`，单次短提示，不承载错误码。错误码留在 `YoError` 或列表行。

## 状态词

每个可点控件都覆盖六态。页面区域另用 `YoPageState`（`common/youi_kit/src/main/ets/model/YoPageState.ets`）在内容、加载、空、错误、权限之间切换，宿主是 `YoContentState`。

| 态 | 落点 |
| --- | --- |
| 默认 | 可点、未按下。主按钮 `YoActionButtonKind.PRIMARY`，次按钮 `SECONDARY`，危险 `DANGER`，文字 `TEXT` |
| 按下 | `YoActionButton` 已有按下、悬浮、获焦。`YoOpacity.PRESSED` 只在组件内部使用。入口卡 `YoModeEntryCard` 没有单独按下层，按下沿用系统点击反馈，不在 Kit 外再铺蒙层 |
| 禁用 | `YoActionButton.isEnabled = false`，并带 `disabledReason`。入口卡用 `disabled` 与 `disabledReason`。标题栏图标用 `YoTitleBarMenuItem.enabled`，禁用透明度由 `YoTitleBarActionRow` 处理 |
| 空 | `YoPageState.EMPTY` + `YoEmpty`。空是「没有数据」，不是失败，也不是缺口 |
| 错误 | `YoPageState.ERROR` + `YoError`：`userMessage`、`causeHint`、`nextStep`、`nativeCode`。可重试才显示重试 |
| 加载 | 首屏查询用 `YoPageState.LOADING` + `YoLoading`。进行中的扫描、连接、写入用按钮的 `loading`，列表留在屏上 |

权限用 `YoPageState.PERMISSION` + `YoPermissionDenied`。只在用户已经点击扫描或连接、并且被拒绝之后占用内容区。进入模块不弹授权，见支持页 NL-013。

缺口不是错误态，也不是成功态。缺口页用中性或警告胶囊，文案写明 Kit 未提供。不出现「已完成」「已测量」「已解除」「已抓包」「已按系统过滤」这一类成功胶囊。`YoStatusPill` 的 `success` 色只用于 Kit 确实返回了成功结果的条目。

状态数据放在特性的页面状态里，用状态管理 V2 观察。`状态管理概述.md` 建议新界面使用 V2；`YoPageShell`、`YoContentState`、`YoActionButton` 已是 `@ComponentV2`。扫描行的 RSSI 和发现次数要能更新同一行，不能只在整表替换时才刷新。Kit 传输对象不进入界面状态。

## 根页在窄屏与宽屏

窄屏根页是一条纵列：支持条，然后入口卡。入口卡使用 `YoModeEntryCard`，一屏两列时折行，仍保持 48vp 热区。宽屏根页把支持条固定在顶部，入口卡按 8 列或 12 列延伸，不把卡片放大成插画。

离开星闪 Tab：取消 `stateChange` 订阅（NL-009，表现在支持页）。若扫描仍在进行，先停止扫描并取消 `deviceFound`（NL-027、NL-110，表现在扫描页）。返回根页不重新弹出已经结束的授权框。

## 组件边界

只用 `common/youi_kit/Index.ets` 已导出的符号。不新增 Kit，不在特性里复制一套按钮、空态或分栏。

已删除、本设计不恢复的组件（`YouiKit-Component-Catalog.md` 的 P1）：`FilterSheetView`、`DataTerminalView`、`YoListRow`、`YoLogRow`、`YoTextField`、`InspectorPanel`、`PayloadViewerView`、`RiskConfirmDialog`、`CapabilityBannerView`。过滤、终端、日志行、HEX 详情都用本目录里写的 List、Text、半模态和 `YoError` 组合表达。
