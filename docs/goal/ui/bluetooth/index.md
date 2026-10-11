---
id: ui.bluetooth.index
type: ui-design
status: draft
when: design
phase: C
related:
  - docs/goal/checklist/bluetooth.md
  - docs/goal/research/bluetooth.md
  - docs/goal/architecture/bluetooth/BT-001.md
  - common/youi_kit/doc/YouiKit-Component-Catalog.md
  - common/youi_kit/Index.ets
---

# 蓝牙调试台界面

本目录是 Phase C 的屏幕设计。它规定蓝牙调试台的导航、信息密度和每种状态看见什么。本阶段不写 ArkUI 产品代码，不开始特性实现。

行为以已接受的清单和架构为准。界面只呈现 `common/yobluetooth` 给出的领域结果。控件只使用 `common/youi_kit` 已从 `Index.ets` 导出的符号。不新增第二套 UI Kit，不增加补丁层，不把已删除的 P1 组件加回来。

蓝牙屏幕只出现在蓝牙 Tab 和蓝牙 `Navigation` 栈。不放进星闪（`AppRoutes.NEARLINK`、`feature_nearlink`）或 Wi‑Fi（`AppRoutes.WIFI`、`feature_wifi_network`）。

## 屏幕

| 文档 | 设计路由 | 壳层级 | 清单 |
| --- | --- | --- | --- |
| [壳与导航](shell-navigation.md) | 应用壳 | `YoAppShell` | 全部屏幕的进出 |
| [适配器与权限](adapter-permissions.md) | 蓝牙 Tab 根 | `ROOT_TAB` | BT-001–BT-008 |
| [经典发现](classic-discovery.md) | `/bluetooth/spp` | `MODULE` | BT-009–BT-018 |
| [配对](pairing.md) | 发现页上的半模态 | `MODAL` | BT-019–BT-026 |
| [地址与身份](address-identity.md) | `/bluetooth/device` | `OBJECT` | BT-027–BT-036 |
| [SPP 终端](spp-terminal.md) | `/bluetooth/spp/terminal` | `TERMINAL` | BT-037–BT-046 |
| [L2CAP](l2cap.md) | 同一终端的类型分段 | `TERMINAL` | BT-047–BT-049 |
| [BLE 扫描](ble-scan.md) | `/bluetooth/ble` | `MODULE` | BT-050–BT-061 |
| [广播与 GATT 服务端](advertising-gatt-server.md) | `/bluetooth/ble/peripheral` | `MODULE` | BT-062–BT-068 |
| [GATT 客户端](gatt-client.md) | `/bluetooth/ble/client` | `OBJECT` | BT-069–BT-079 |
| [MTU、PHY 与连接参数](mtu-phy-connection.md) | 客户端页的参数区 | `OBJECT` | BT-080–BT-085 |
| [吞吐、报文与会话日志](throughput-packets-log.md) | `/bluetooth/session-log` | `TERMINAL` | BT-086–BT-090 |
| [回连、后台与诊断](reconnect-background-diagnostics.md) | `/bluetooth/diagnostics` | `MODULE` | BT-091–BT-098 |

路由名是设计名。现有代码里已经有 `/bluetooth/overview`、`/bluetooth/spp`、`/bluetooth/spp/terminal`、`/bluetooth/ble`。其余子路由留到实现阶段，仍由 `product/phone` 的根 `Navigation` 承载，ViewModel 留在 `features/bluetooth`。

## 布局、状态、导航、密度

证据来自镜像 `yohurm/HarmonyOS-Developer-docs` 的 `1d85fab9`。路径相对该仓库根。

| 主题 | 本设计采用的结论 | 路径 |
| --- | --- | --- |
| 布局结构 | 先定页面结构，再用容器管位置。调试页优先线性 `Column` / `Row`。设备列表用 `List`。超过一层嵌套时才考虑相对布局。绝对定位不用于适配宽度 | `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/布局概述.md`；`…/组件布局/构建布局/线性布局 (Row／Column).md` |
| 断点 | 容器断点按容器尺寸响应。本工程已经用窗口宽度断点：`<600vp` 单列，`≥600vp` 分栏，`≥840vp` 侧栏，`≥1440vp` 内容最大宽度。本阶段不引入 `ContainerReader` | `…/组件布局/构建布局/容器断点 (ContainerReader).md`；`common/platform` 的 `WindowWidthBreakpoint` |
| 状态 | 界面是状态的结果。新组件用 V2：页面 `@Local` 持有 ViewModel，子组件用 `@Param` 接输入，用 `@Event` 交出点击。`@Param` 不在子组件里改蓝牙事实。状态装饰器只在 UI 主线程使用，扫描回调先写入 ViewModel | `…/学习UI范式状态管理/状态管理概述.md`；`…/状态管理（V2）/管理组件拥有的状态/@Param：组件外部输入.md` |
| 导航 | 应用内跳转用 `Navigation` + `NavDestination`，不用 `@ohos.router` 做蓝牙内页面。标题栏、内容区、返回由导航容器承担。宽屏分栏是平台能力；蓝牙列表与详情用已有 `YoSplitScaffold`，不另做一套 `NavigationMode` | `…/设置组件导航和页面路由/组件导航和页面路由概述.md`；`…/组件导航(Navigation) (推荐)/Navigation分栏开发.md`；`…/组件导航(Navigation) (推荐)/Navigation页面路由.md` |
| 密度 | 布局数字默认 vp，未写单位即 vp。字号走 fp，随系统字体变化。不用 px 写间距、行高或触控区。地址和报文用等宽字，仍是 fp 语义 | `开发/API参考/应用框架/ArkUI（方舟UI框架）/ArkTS组件/公共定义/像素单位.md` |

间距取 `YoSpace`（2vp 网格）。页面水平边距取 `YoResponsive.pageHorizontal`。分区间距 `YoResponsive.SECTION_GAP`（16vp）。触控不小于 `YoSize.TOUCH_TARGET_MIN`（48vp）。正文字号 `YoTypeStyle.BODY_M` / `BODY_S`，地址、UUID、HEX、错误码用 `YoTypeStyle.MONO_S`。

## 调试台密度

一行必须能读完：名称（可空）、虚拟地址、一枚状态胶囊、一个主操作。次要事实放第二行或分栏详情，默认最多两行，超出省略。缺字段留空，不写成 0。平台错误码放在 `YoError` 的原因层，不单独占一屏。

手机单列时主按钮 `fullWidth`。`≥600vp` 时列表与详情分栏，权重用 `YoNavigationToken` 的 4:6，列宽不小于 280vp。`≥840vp` 时应用壳改为侧栏，底栏隐藏。`≥1440vp` 时内容限制在 `YoResponsive.CONTENT_MAX_WIDTH`。

`YoSegmentButton` 是系统门面，尺寸和边距放在外层，不在分段按钮上链式写宽度。

## 六种状态

每个屏幕都覆盖下面六态。按下只改变控件外观，不改变领域状态。

| 状态 | 看见什么 | 用什么 |
| --- | --- | --- |
| 默认 | 可操作的内容 | `YoPageState.CONTENT`，主操作 `YoActionButton` `PRIMARY` |
| 按下 | 按钮或行的按下色，松手恢复 | `YoActionButton` 已有按下；行用 `YoColor.INTERACTIVE_PRESSED`，写在特性视图里 |
| 禁用 | 控件不可点，原因可见 | `isEnabled` 为假，并带 `disabledReason`；入口卡用 `YoModeEntryCard.disabled` |
| 空 | 操作已经正常结束，确实没有行 | `YoContentState` + `YoEmpty` |
| 错误 | 拒绝、关闭、超时、服务停止、平台码 | `YoError` 三层文案；权限拒绝用 `YoPageState.PERMISSION` 与 `YoPermissionDenied` |
| 加载 | 请求已发出，结果未到 | `YoLoading`，或按钮 `loading`。加载中不显示成功胶囊 |

关蓝牙、未授权、服务停止不是空列表。`YoToast` 只用于不打断当前列表的短反馈。

## 缺口与待证

缺口的完成态是看见限制。这些条目没有成功胶囊，没有「已完成」主按钮。

| 条目 | 屏幕 | 限制上写什么 |
| --- | --- | --- |
| BT-008 | 适配器 | 模拟器上蓝牙不可用 |
| BT-015 | 经典发现 | 名称和 RSSI 只过滤已上报结果 |
| BT-023 | 配对 | 应用内不能取消配对，只能打开系统蓝牙设置 |
| BT-024 | 配对 | 普通应用不做系统配对确认 |
| BT-034 | 地址 | BLE 扫描地址不能直接 SPP |
| BT-035 | 地址 | 没有先经典再 BLE 的自动桥 |
| BT-063 | 广播 | 不能任意填写 AD Type |
| BT-084 | 连接参数 | 没有连接间隔的数字输入 |
| BT-088 | 日志 | 应用内不能抓空口 HCI |
| BT-089 | 日志 | Release 的 HCI 只有 Header |

待证保持未证实，不画成功：

| 条目 | 屏幕 | 界面保持 |
| --- | --- | --- |
| BT-030 | 地址 | 收藏是本地书签。不出现地址已固化 |
| BT-085 | PHY | 不出现 PHY 已切换。801 只作为将来的不支持说明，本阶段不发起切换 |

## 允许的 Kit 符号

壳：`YoAppShell`、`YoSideNavRail`、`YoSplitScaffold`、`YoPageShell`、`YoTitleBarActionRow`、`YoNavDestinationKind`。

操作与分段：`YoActionButton`、`YoSegmentButton`、`YoModeEntryCard`、`YoStatusPill`。

反馈：`YoContentState`、`YoEmpty`、`YoError`、`YoLoading`、`YoPermissionDenied`、`YoToast`。

表面：`YoImmersiveSurface` 只给概览状态卡的材质，不拿它当终端或日志列表。

Token：`YoSpace`、`YoSize`、`YoColor`、`YoTypeStyle`、`YoResponsive`、`YoNavigationToken`，以及按钮、列表、分段、对话框、Toast 的组件 Token。

文本输入用系统 `TextInput`，颜色 `YoColor.SURFACE_INPUT`，字号 `YoTypeStyle`，修饰用已导出的 `YoTextModifier`。不新增 `YoTextField`。报文列表是特性页里的 `List` 加 `Text`，不新增终端组件。

`common/youi_kit` 不解释蓝牙状态，不调用 `ohos.bluetooth.*`。
