---
id: ui.wifi-network.reconnect
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 重连与默认网络

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Column
            ├── Scroll
            │   └── YoSegmentButton         // 文本 / HEX / 混合
            ├── List
            │   └── ListItemGroup
            │       └── ListItem
            │           └── Column
            │               ├── Text        // 时间、方向、错误码
            │               └── Text        // MONO_S
            └── Row
                ├── YoActionButton          // 导出
                └── YoActionButton          // 清空，先 AlertDialog
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
| 无权限 | 缺少 `GET_NETWORK_INFO` 时不编造网关或默认网络（WN-005）。注册失败是错误，不是空时间线。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/reconnect-and-default-network` |
| 架构编号 | WN-070, WN-071, WN-072, WN-073, WN-065, WN-066, WN-067, WN-068, WN-069 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 。文件不在 `main` |
| 工作台入口 | 工作台「网络」卡片，或底栏网络槽（下标 2） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


本页把 WLAN 连接变化和默认网络回调按时间排开。新的一次连接写新行，不改上一行的终态。上网结论按能力位原文显示，不把「提供者标记可上网」写成已经验证。

## 布局

`YoPageShell` 标题「默认网络」，`MODULE`，`contentEdgeToEdge = true`。

顶区三枚 `YoStatusPill`：

- 关联：`CONNECTED` / `DISCONNECTED` / `UNKNOWN` 等 `ConnState`。
- 默认网络：`netId`，为 0 时胶囊「无默认网络」。
- 上网：检测中、需要门户认证、未验证、已验证、网络阻塞，五者取当前位能确定的那一句。

其下是时间线列表。每行：时间、来源（`wifiConnectionChange` 或 `NetConnection` 事件名）、终态。行高 56vp，项间距 0。

再连接用底栏 `YoActionButton`「再次连接选中的候选网络」。候选选择用列表单选，不用新的选择器组件。

`≥600vp` 左时间线、右能力位明细。明细逐位列出：`NET_CAPABILITY_INTERNET`、`VALIDATED`、`CHECKING_CONNECTIVITY`、`PORTAL`，值是有或无。

## 文案

| 事实 | 上网胶囊 | 依据 |
| --- | --- | --- |
| 含 `CHECKING_CONNECTIVITY` | 检测中 | WN-070。此时不把 `VALIDATED` 写成最终结论 |
| 含 `PORTAL` | 需要门户认证 | WN-071 |
| 只有 `NET_CAPABILITY_INTERNET` | 网络提供者标记可上网，连通性未验证 | WN-072 |
| `VALIDATED` 且不在检测中 | 已验证 | 能力位原文 |
| `netBlockStatusChange` 的 blocked 为 true | 网络阻塞 | WN-073 |

时间线顺序：

- 系统设置断开 WLAN 后，新行是 `DISCONNECTED` 或 `UNKNOWN`，时间晚于断开动作（WN-065）。
- 再次连接：新行用新时间开始。上一行的 `CONNECTED` 或失败终态保持原文字（WN-066）。
- 从无网到有网：先 `netAvailable`，随后能力或属性变化，`netId` 不为 0（WN-067）。
- 从未连上：只有 `netUnavailable`，它前面没有 `netAvailable`（WN-068）。
- Wi-Fi 落到蜂窝：先 Wi-Fi 的 `netLost`，再蜂窝的 `netAvailable`（WN-069）。

## 状态

### 默认

已注册回调，顶区和时间线与最近一次事件一致。再次连接按钮在存在候选网络且 WLAN 已打开时可点。

### 按下

时间线行按下展开该次的 `netId` 与能力位，透明度 `YoOpacity.PRESSED`。再次连接按下后按钮进入处理中。

### 禁用

没有候选网络、WLAN 未激活、或上一次连接尚未终态时，再次连接禁用。`disabledReason` 分别是「没有候选网络」「STA 未打开」「上一次尚未结束」。

### 空

已注册且尚未发生任何事件：时间线 `YoEmpty`「还没有网络事件」，顶区胶囊保持「无默认网络」。注册失败不用这个空态。

### 错误

注册回调失败：整页 `ERROR`，带系统码。`netId` 为 0 时不把空事件列表标成已联网。阻塞为真时胶囊是「网络阻塞」，色 `warning`，不用错误页盖住时间线。

### 加载

注册完成前 `LOADING`「正在注册默认网络」。第一次 `netAvailable` 或 `netUnavailable` 到达后离开加载。检测中的胶囊可以保持，那是内容态，不是整页加载。

## 依据

- `docs/goal/architecture/wifi-network/WN-065.md` 至 `WN-073.md`
- `docs/goal/research/wifi-network.md` 网络连接事件
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/状态管理概述.md`
- `common/youi_kit/src/main/ets/components/containers/YoStatusPill.ets`
