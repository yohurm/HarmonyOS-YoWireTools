---
id: ui.bluetooth.address-identity
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-027, BT-028, BT-029, BT-030, BT-031, BT-032, BT-033, BT-034, BT-035, BT-036]
verdict_notes: BT-034 与 BT-035 是缺口。BT-030 待证，不画已固化
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-027.md
  - docs/goal/architecture/bluetooth/BT-030.md
  - docs/goal/architecture/bluetooth/BT-034.md
  - docs/goal/architecture/bluetooth/BT-035.md
---

# 地址与身份

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
| 默认 | 展示虚拟地址和来源。已配对且地址仍被接受时，胶囊「配对后保持」（BT-029）。主按钮按上表 |
| 按下 | 收藏、配对、连接按下后松手才提交。按下不把稳定性改成已固化 |
| 禁用 | 只有 BLE 扫描地址时，「SPP」禁用，原因「需要经典地址，或先配对」（BT-034）。只有经典连接时，「GATT」禁用，原因「需要 BLE 扫描或已有 BLE 地址」（BT-035）。地址已标失效时，连接禁用，原因「请重新发现」 |
| 空 | 没有 `deviceId`：`YoEmpty`，标题「没有地址」，主操作「去发现」或「去扫描」，由进入来源决定 |
| 错误 | 未配对地址在蓝牙重启后连接失败：原因可见，下一步「重新发现」（BT-028）。固化项因对端真实地址变化而失败：该项标失效，不再对同一地址自动重试（BT-031）。卸载重装后的旧地址不作为回连目标，打开时直接是失效说明（BT-032） |
| 加载 | 查询传输类型或配对状态时，胶囊位置用 `YoLoading` 的短文案「正在核对地址」。核对完成前不显示「可以 SPP」 |
| 无权限 | 未授权时不把地址画成可连接。连接与配对按钮进入权限墙，而不是空地址。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/address-identity` |
| 架构编号 | BT-027, BT-028, BT-029, BT-030, BT-031, BT-032, BT-033, BT-034, BT-035, BT-036 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


路由 `/bluetooth/device`。从经典行、BLE 行或回连入口进入。`destinationKind` 为 `OBJECT`。状态在 `features/bluetooth` 的设备页。身份字段来自 `common/yobluetooth` 的 `DeviceIdentity`。本地书签写入 `common/storage` 的 `DeviceFavoriteRecord`。

这页回答「这个地址是什么、能不能拿去连接」。它不扫描，也不发起 GATT 读写。

## 结构

`YoPageShell` 标题用设备名，没有名称时标题是「设备」。副标题固定写「虚拟地址」，下面一行等宽地址（BT-027）。

内容 `Column`，四段：

1. 身份：地址、地址稳定性胶囊、传输胶囊（经典 / LE / 双模 / 未知）。
2. 可用动作：按地址来源只放做得到的按钮。
3. 书签：`YoActionButton` `SECONDARY`「收藏」。
4. 失效说明：旧地址、卸载重装、对端地址变化时用 `YoError` 嵌在段内。

`≥600vp` 时左栏仍是来源列表，本页占右栏。手机上本页独占。

## 信息密度

地址永远带「虚拟地址」四字，不标成物理 MAC。稳定性只用三枚胶囊之一：临时、配对后保持、本地书签。不出现第四枚「已固化」。

动作区最多三个按钮，纵向排列，间距 `YoSpace.M`：

| 地址来源 | 主按钮 | 不出现的按钮 |
| --- | --- | --- |
| 经典或双模，已配对 | 连接 SPP | — |
| 经典或双模，未配对 | 配对 | 把未配对直接写成已连接 |
| 只有 BLE 扫描地址 | 用此地址配对 | 「立即 SPP」 |
| 仅有经典连接 | 说明需要 BLE 地址 | 「自动转为 GATT」 |
| BLE 已连接的双模地址 | 配对以得到经典记录 | 把尚未配对写成经典已连接 |

未知类型时，「配对」仍可用，调用不带 `BluetoothAddressType`（BT-033）。类型未知写在胶囊「类型未知」，不猜一个类型。

## 控件

| 区域 | 符号 |
| --- | --- |
| 地址 | `Text` + `YoTypeStyle.MONO_S` |
| 稳定性 / 传输 | `YoStatusPill` |
| 动作 | `YoActionButton` |
| 不能做的路径 | 胶囊 `warning` 加禁用按钮的 `disabledReason` |
| 失效 | `YoError` |
| 无地址 | `YoEmpty` |

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 展示虚拟地址和来源。已配对且地址仍被接受时，胶囊「配对后保持」（BT-029）。主按钮按上表 |
| 按下 | 收藏、配对、连接按下后松手才提交。按下不把稳定性改成已固化 |
| 禁用 | 只有 BLE 扫描地址时，「SPP」禁用，原因「需要经典地址，或先配对」（BT-034）。只有经典连接时，「GATT」禁用，原因「需要 BLE 扫描或已有 BLE 地址」（BT-035）。地址已标失效时，连接禁用，原因「请重新发现」 |
| 空 | 没有 `deviceId`：`YoEmpty`，标题「没有地址」，主操作「去发现」或「去扫描」，由进入来源决定 |
| 错误 | 未配对地址在蓝牙重启后连接失败：原因可见，下一步「重新发现」（BT-028）。固化项因对端真实地址变化而失败：该项标失效，不再对同一地址自动重试（BT-031）。卸载重装后的旧地址不作为回连目标，打开时直接是失效说明（BT-032） |
| 加载 | 查询传输类型或配对状态时，胶囊位置用 `YoLoading` 的短文案「正在核对地址」。核对完成前不显示「可以 SPP」 |

## 缺口

BT-034：从 BLE 扫描进入时，没有成功的 SPP 按钮。说明行写需要经典地址，或先对已连接 BLE 地址配对。不把该地址传给 `sppConnect`。

BT-035：没有「桥接到 GATT」的成功结果。主路径是去 BLE 扫描，或使用已有 BLE 地址。

BT-036 是支持项：BLE 已连接且为双模时，「配对」成功后，文案说明已配对列表可用于后续经典连接。成功胶囊只写「已配对」，不写「SPP 已连接」。

## 待证

BT-030：未证实 `PERSISTENT_BLUETOOTH_PEERS_MAC` 或 ACL 时，收藏成功只表示本地书签。胶囊是 `warning`「未固化 · 待证」。回连动作是「重新发现」或「配对」。不出现「已固化」「免配对回连已就绪」。调用失败同样不显示已固化。

## 导航

「去发现」pop 或 push `/bluetooth/spp`。「去扫描」到 `/bluetooth/ble`。「配对」打开配对半模态。「连接 SPP」在已配对且地址可用时进入终端。本页不注册到星闪或 Wi‑Fi。

## 非目标

- 不设计 `addPersistentDeviceId` 的成功画面。
- 不提供真实 MAC 的输入框。
