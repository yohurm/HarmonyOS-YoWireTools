---
id: ui.wifi-network.link
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 已连接链路

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Column
            ├── Row
            │   ├── Text                    // 名称
            │   └── YoStatusPill
            ├── Text                        // 地址或 BSSID，MONO_S
            ├── List
            │   └── ListItem
            │       └── Row
            │           ├── Text
            │           └── Text
            └── Row
                └── YoActionButton
YoSplitScaffold                             // ≥600vp：左列表右本页
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
| 无权限 | 未授予对端 MAC 时显示「随机地址」（WN-008），不填真实 BSSID。这是受限内容，不是空链路。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/link` |
| 架构编号 | WN-043 至 WN-014（行为细则里逐条出现） |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 。文件不在 `main` |
| 工作台入口 | 工作台「网络」卡片，或底栏网络槽（下标 2） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


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
