---
id: ui.wifi-network
type: ui-design
status: draft
when: phase-c
related: [checklist.wifi-network, research.wifi-network, architecture.wifi-network]
---

# Wi-Fi 与网络界面设计

本目录是 Phase C 的界面设计。它只规定 `features/wifi_network` 各屏幕的结构、文案结果和状态。本阶段不写 ArkUI 产品代码，不改 `common/youi_kit`，不新增第二套组件库或补丁层。

行为以 `docs/goal/checklist/wifi-network.md`、`docs/goal/research/wifi-network.md` 和 `docs/goal/architecture/wifi-network/` 为准。界面文案由 `features/wifi_network` 的页面状态生成。`common/youi_kit` 只提供壳、反馈和 Token，不解释 WLAN。
> 断点、Token、权限墙、深浅色以 [应用壳](../app-shell/README.md) 为准。质量门禁见 [QUALITY-GATE.md](../QUALITY-GATE.md)：**不可进入大规模页面实现**。目录不另建 `wifi_network` 文档树。


本目录是 Phase C 的界面设计。它只规定 `features/wifi_network` 各屏幕的结构、文案结果和状态。本阶段不写 ArkUI 产品代码，不改 `common/youi_kit`，不新增第二套组件库或补丁层。

行为以 `docs/goal/checklist/wifi-network.md`、`docs/goal/research/wifi-network.md` 和 `docs/goal/architecture/wifi-network/` 为准，编号是 WN-001–WN-132。下面的屏幕表是界面落点，不是第二份清单。对接的 PR 写在 [质量门禁](../QUALITY-GATE.md)。界面文案由 `features/wifi_network` 的页面状态生成。`common/youi_kit` 只提供壳、反馈和 Token，不解释 WLAN。

## 屏幕

| 文件 | 屏幕 | 清单 |
| --- | --- | --- |
| [shell-and-navigation.md](shell-and-navigation.md) | 壳与导航 | 全组入口；WN-131、WN-132 的导航约束 |
| [permissions-and-capability.md](permissions-and-capability.md) | 权限与能力 | WN-001 至 WN-010 |
| [wlan-state.md](wlan-state.md) | WLAN 状态 | WN-011 至 WN-018 |
| [scan-filter-channel.md](scan-filter-channel.md) | 扫描、过滤与信道 | WN-019 至 WN-039 |
| [link.md](link.md) | 已连接链路 | WN-040 至 WN-050 |
| [connect-and-auth.md](connect-and-auth.md) | 连接与认证 | WN-051 至 WN-064 |
| [reconnect-and-default-network.md](reconnect-and-default-network.md) | 重连与默认网络 | WN-065 至 WN-073 |
| [address-dns-route-ports.md](address-dns-route-ports.md) | 地址、DNS、路由与端口 | WN-074 至 WN-090 |
| [throughput.md](throughput.md) | 吞吐 | WN-091 至 WN-096 |
| [in-app-connection-inspect.md](in-app-connection-inspect.md) | 本应用连接检查 | WN-097 至 WN-111 |
| [lan-discovery.md](lan-discovery.md) | 局域网发现 | WN-112 至 WN-117 |
| [capture-boost-permission-walls.md](capture-boost-permission-walls.md) | 抓包、加速与权限墙 | WN-118 至 WN-127 |
| [session-log.md](session-log.md) | 会话日志 | WN-128 至 WN-132 |

## 组件

只用 `common/youi_kit/Index.ets` 已导出的符号，目录见 `common/youi_kit/doc/YouiKit-Component-Catalog.md`。

| 用途 | 组件 |
| --- | --- |
| 应用底栏 / 侧栏 | `YoAppShell`、`YoSideNavRail` |
| 页面壳、返回、标题菜单 | `YoPageShell`、`YoNavDestinationKind`、`YoTitleBarMenuItem` |
| 对话框标题操作 | `YoTitleBarActionRow` |
| 宽窗列表与详情 | `YoSplitScaffold` |
| 页内分段 | `YoSegmentButton` |
| 主次动作 | `YoActionButton` |
| 概览入口 | `YoModeEntryCard`、`YoStatusPill` |
| 内容 / 加载 / 空 / 错误 / 权限 | `YoContentState`、`YoPageState`、`YoLoading`、`YoEmpty`、`YoError`、`YoPermissionDenied` |
| 轻提示 | `YoToast` |
| 间距、字号、颜色、断点 | `YoSpace`、`YoSize`、`YoTypeStyle`、`YoColor`、`YoOpacity`、`YoResponsive`、`YoListToken`、`YoNavigationToken` |

页面内的列表、输入框、事实行用 ArkUI `List`、`TextInput`、`Row`、`Column`，间距和字号取上面的 Token。目录里标成 P1 的 `YoListRow`、`FilterSheet`、`YoTextField`、`YoLogRow`、`InspectorPanel` 不恢复，也不在特性里复制一份。

## 六态

每一屏都要能落到下表。页面只订阅页面状态。状态变量用状态管理 V2：页面 `@Local` / `@Param`，可观察数据用 `@ObservedV2` 与 `@Trace`。状态更新留在 UI 线程。

| 态 | `YoPageState` | 可见结果 |
| --- | --- | --- |
| 默认 | `CONTENT` | 当前事实。主行加 `YoStatusPill`，次行放单位和错误码 |
| 按下 | 仍是 `CONTENT` | `YoActionButton` 与可点行使用 `YoOpacity.PRESSED`（0.9）。松手恢复。禁用控件不进入按下 |
| 禁用 | 仍是 `CONTENT` 或保持原态 | `YoActionButton.isEnabled = false` 或 `YoModeEntryCard.disabled = true`，并显示 `disabledReason`。点击不提交 |
| 空 | `EMPTY` | 只用于合法的零结果，例如清空后的日志、成功扫描后的空缓存。`YoEmpty` 写明原因 |
| 错误 | `ERROR` | `YoError` 三层：用户一句、原因、下一步。`nativeCode` 可见。失败不进入空态 |
| 加载 | `LOADING` | `YoLoading` 带当前动作。终态到达后离开加载，包括 801 和扫描失败 |

缺口、受限、系统或企业、开发者选项的屏幕以拒绝说明或系统设置路径为默认内容。这些屏幕没有应用内成功态：不出现获权后才会有的数据，不出现「已完成」胶囊。

## 密度与断点

调试工具箱优先让错误码、单位和方法标签留在第一屏。

- 字号走 `fp`（`YoTypeStyle`）。布局走 `vp`。间距取 `YoSpace` 的 2 / 4 / 8vp 倍数。
- 手机左右边距 16vp，卡片间距 12vp，同级控件 8vp，分组 16vp，主次文字上下 2vp。这些数与 `YoSpace`、`YoResponsive` 一致。
- 窗口断点用 `common/platform` 的 `WindowWidthBreakpoint`：`<600vp` 单列，`600–839vp` 分栏，`≥840vp` 应用侧栏。内容最大宽度 2220vp，与 `YoResponsive.CONTENT_MAX_WIDTH` 相同。
- `<600vp`：单列，`Navigation` 单栏，整页替换。列表主行高 `YoSize.LIST_ROW_HEIGHT`（56vp），触控不小于 48vp。
- `≥600vp`：列表加详情用 `YoSplitScaffold`，默认 4:6，每栏最小 280vp。
- `≥840vp`：底栏变为 `YoSideNavRail`（宽 240vp）。网络仍是同一个 Tab，不增加导航项。
- 长列表设 `YoPageShell.contentEdgeToEdge = true`，行间距用 `YoListToken.ITEM_GAP`（0），分割线用 `YoListToken.DIVIDER_STROKE`。
- 主行一个名字加一个状态。次行最多四个短事实。响应体、信息元素、租约放进展开或详情。

## 导航约束

WLAN 与网络页面只挂在产品已有的网络 Tab（`AppRoutes.WIFI` = `/wifi/overview`，`MainTabContainer` 的第 3 个内容槽）。`features/bluetooth` 与 `features/nearlink` 不增加 WLAN 目的地，也不订阅这些页面的状态。

子页用 `Navigation` + `NavPathStack` 管理。路由容器由网络 Tab 持有。离开页面时订阅成对取消。

## 模拟器

WN-039 与 WN-124 在模拟器上的验收标记保持未通过。界面用 `warning` 色的 `YoStatusPill` 写「未通过」，说明未用真机或模拟器不支持该项。这个胶囊不改成 `success`。

## 依据

HarmonyOS 文档仓库路径：

- `设计/设计指南/通用设计基础/布局/布局基础.md`
- `设计/设计指南/通用设计基础/布局/响应式布局方法.md`
- `设计/设计指南/通用设计基础/布局/响应式应用架构.md`
- `设计/设计指南/通用设计基础/视觉风格/间隔参数.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/布局概述.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/构建布局/线性布局 (Row／Column).md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/构建布局/栅格布局 (GridRow／GridCol).md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航和页面路由概述.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation页面路由.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/状态管理概述.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`

扫描语义另见研究文档所引 API 参考：`开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.wifiManager WLAN.md`。
