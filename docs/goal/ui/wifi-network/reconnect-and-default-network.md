---
id: ui.wifi-network.reconnect
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 重连与默认网络

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
