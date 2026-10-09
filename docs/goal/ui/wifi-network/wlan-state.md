---
id: ui.wifi-network.wlan-state
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# WLAN 状态

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
