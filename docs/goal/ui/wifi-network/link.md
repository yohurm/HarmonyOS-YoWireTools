---
id: ui.wifi-network.link
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 已连接链路

本页显示当前 STA 关联的事实。未连接时不保留上一份 SSID。噪声底和 SNR 固定为「未提供」。

## 布局

`YoPageShell` 标题「链路」，`MODULE`。事实用单列，`≥840vp` 时两列栅格：左列标识与信号，右列速率与 IP。栅格列数跟随窗口：`<600vp` 4 列里事实占满，`600–839vp` 8 列，`≥840vp` 12 列。间距用 `YoSpace`，不用绝对定位。

块顺序：

1. 标识。SSID、隐藏（是/否）、BSSID 与「随机地址」、`ConnState`。
2. 信号。RSSI dBm 与档位 0–4 分两格，两格同时在（WN-043）。`wifiRssiChange` 到达后 dBm 与档位一起更新（WN-042）。
3. 射频。频率、信道带宽、Wi-Fi 标准。信道仍标「由频率换算」。
4. 速率。第一行瞬时 `linkSpeed`。第二行最大协商上行、下行。两行标题分别是「瞬时」和「协商」（WN-041）。
5. 链路类型。API 18 及以上显示默认、Wi-Fi 7 单链路、MLSR、EMLSR、STR 之一。低于 18 时该行写「当前系统无此字段」（WN-046）。
6. 限制。`isRestricted` 为真时胶囊「数据量受限」（WN-045）。
7. IPv4。点分十进制的地址、网关、掩码、主 DNS、备 DNS、DHCP 服务器、租约秒数。数值 0 的格子写「未获得」（WN-047）。
8. IPv6。链路地址、全局地址、网关、DNS。随机全局地址一格写「未提供」（WN-048）。
9. 缺口。噪声底、SNR 写「未提供」（WN-049）。
10. 距离。默认折叠。用户打开后显示米，前缀「按自由空间路径损耗估算」，同一块保留 RSSI 与频率（WN-050）。

已连接且 `ConnState` 为 `CONNECTED` 时，首块还要能看到上行 Mbps、下行 Mbps（WN-040）。

## 状态

### 默认

已连接：上述各块有值或有明确的「未获得」「未提供」「当前系统无此字段」。隐藏网络的隐藏行是「是」（WN-044）。BSSID 行带「随机地址」（WN-008）。

### 按下

距离开关用 `YoActionButton` `SECONDARY`，标签「显示估算距离」或「收起估算」。按下走按钮按下态。事实行按下无导航，避免把链路页变成第二份扫描列表。进入连接页用标题菜单「去连接」，那是另一次导航。

### 禁用

`ConnState` 不是 `CONNECTED` 时，「显示估算距离」禁用，`disabledReason`「未连接」。字段行不可编辑。

### 空

WLAN 打开但未关联：整页 `EMPTY`，标题「未连接」，说明「没有当前 SSID」。不显示上一次的 SSID、RSSI 或 IP（WN-016）。

### 错误

WLAN 关闭：`ERROR`，「STA 未打开」，`nativeCode`「2501001」（WN-014）。低版本不把链路类型填成某一个枚举再标成功。IPv4 的 0 不显示成 `0.0.0.0`。

### 加载

订阅建立前 `LOADING`「正在读取链路」。`wifiRssiChange` 的后续更新不整页加载，只改 dBm 两格，避免闪烁。读取失败或 801 后结束加载。

## 依据

- `docs/goal/architecture/wifi-network/WN-040.md` 至 `WN-050.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/布局概述.md`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/构建布局/栅格布局 (GridRow／GridCol).md`
- `设计/设计指南/通用设计基础/布局/布局基础.md`
