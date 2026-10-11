---
id: ui.wifi-network.wlan-state
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# WLAN 状态

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Scroll
            └── Column
                ├── Row
                │   ├── Text
                │   └── YoStatusPill
                ├── TextInput
                ├── YoSegmentButton
                ├── List
                │   └── ListItem
                └── YoActionButton
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 见下方行为细则中的同名描述。 |
| 按下 | 见下方行为细则中的同名描述。 |
| 禁用 | 见下方行为细则中的同名描述。 |
| 空 | 见下方行为细则中的同名描述。 |
| 错误 | 见下方行为细则中的同名描述。 |
| 加载 | 见下方行为细则中的同名描述。 |
| 无权限 | 缺少 `GET_WIFI_INFO` 时不编造已激活或 SSID，进入权限/声明错误，而不是空态。普通应用没有 WLAN 开关（WN-010）。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/wlan-state` |
| 架构编号 | WN-011, WN-015, WN-016, WN-017, WN-018, WN-014, WN-012, WN-013, WN-010 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 。文件不在 `main` |
| 工作台入口 | 工作台「网络」卡片，或底栏网络槽（下标 2） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


本页只观察 STA 与热点是否激活，以及连接与否。打开或关闭系统 WLAN、打开热点，不在本页提供成功动作。

## 布局

`YoPageShell` 标题「WLAN 状态」，`MODULE`。

单列事实表，行高 56vp，分割线 `YoListToken.DIVIDER_STROKE`：

| 行 | 主文案 | 次行 |
| --- | --- | --- |
| 开关 | 已激活 / 未激活 | `wifiStateChange` 最后一次：DISABLED、ENABLING、ENABLED、DISABLING 中实际到达的值 |
| 关联 | 已连接 / 未连接 | 未连接时次行空。已连接只写「详见链路」，SSID 放在链路页 |
| 热点 | 是 / 否 | 来源 `isHotspotActive` |
| 系统开关 | 需在系统设置中操作 | 「需要系统应用或企业权限」 |
| 热点开关 | 没有打开热点的动作 | 「热点开关接口已废弃」 |

`≥600vp` 时左栏是这五类，右栏是会话日志里与开关相关的最近几行（时间、动作、终态）。日志详情仍以会话日志页为准。

页底不放「打开 WLAN」或「打开热点」。需要用户到系统设置时，用 `YoActionButton` `SECONDARY`，标签「打开系统设置」，`disabledReason` 留空。该按钮只离开应用去设置，返回后本页按新的回调刷新。按钮旁写明它不改变应用内的成功态。

## 状态

### 默认

WLAN 已打开：开关行胶囊「已激活」，色 `success`（WN-011）。已关联 AP：关联行「已连接」（WN-015）。已打开但未关联：关联行「未连接」，主行与次行都不保留上一次 SSID（WN-016）。系统热点开着：热点行「是」（WN-017）。

### 按下

「打开系统设置」按下时走 `YoActionButton` 的按下透明度。事实行按下只展开原始枚举名，例如 `ENABLED`。展开不发起 `enableWifi`。

### 禁用

系统 WLAN 开关行没有控件，不存在可按下的开关。热点动作位置用一段 `YoTypeStyle.BODY_S` 说明代替按钮。若剩余一个动作按钮，`isEnabled = false`，`disabledReason`「普通应用没有打开热点的动作」（WN-018）。

### 空

尚未收到任何 `wifiStateChange` 且读取也未返回时，开关块为 `EMPTY`，标题「尚未收到开关状态」。一旦收到回调或读到布尔值，离开空态。关联失败不用空态顶替错误码。

### 错误

WLAN 关闭后读取连接信息：关联行进入错误摘要，文案「STA 未打开」，`nativeCode`「2501001」（WN-014）。已连接详情区清空（WN-012）。2501001 与权限 201 分两行，不合并。

用户在系统设置关闭 WLAN、页面仍在前台：开关胶囊改为「未激活」，关联行清空。用户再打开：日志按实际回调顺序出现 ENABLING、ENABLED，最终胶囊回到「已激活」（WN-013）。未回调到的状态不补行。

### 加载

进入页面到第一次 `isWifiActive` / `isConnected` 返回前，内容为 `LOADING`，文案「正在读取 WLAN 状态」。返回后离开加载。查询热点失败时热点行是错误「未能读取」，不用「否」填充（WN-017）。

## 系统或企业

WN-010 与 WN-018 在本页的默认内容就是拒绝说明。点击系统设置路径之后，若系统 WLAN 状态没变，胶囊保持原值，并有 `YoToast`「开关状态未变」。没有「已打开 WLAN」或「已打开热点」的成功胶囊。

## 依据

- `docs/goal/architecture/wifi-network/WN-011.md` 至 `WN-018.md`
- `docs/goal/research/wifi-network.md` 连接状态一节
- `设计/设计指南/通用设计基础/视觉风格/间隔参数.md`
- `common/youi_kit/src/main/ets/components/controls/YoActionButton.ets`
