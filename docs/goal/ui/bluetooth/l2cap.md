---
id: ui.bluetooth.l2cap
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-047, BT-048, BT-049]
related:
  - docs/goal/ui/bluetooth/spp-terminal.md
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-047.md
---

# L2CAP

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell                         // TERMINAL
        └── Column
            ├── Row
            │   ├── Text
            │   └── YoStatusPill
            ├── List                        // 收发记录，边到边
            │   └── ListItem
            │       └── Text                // MONO_S，文本或 HEX
            └── Row
                ├── TextInput               // 或 TextArea
                └── YoActionButton          // 发送 / 停止
YoSplitScaffold                             // ≥600vp 用 6:4
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 已选择 L2CAP，PSM 已填写且与对端一致，已连接。只读长度可见。发送可用 |
| 按下 | 「连接」和「发送」的按下与终端相同。按下不改写 PSM |
| 禁用 | PSM 为空时「连接」禁用，原因「需要与对端一致的 PSM」。写入长度大于最大发送长度时「发送」禁用，原因写出该上限（BT-048）。RFCOMM 分段不要求 PSM，连接按钮不因 PSM 为空而禁用（BT-049） |
| 空 | 已连接但无字节：与终端相同的 `YoEmpty`「还没有数据」。未填写 PSM 不是空列表 |
| 错误 | PSM 不一致：连接失败可见，不进入已连接（BT-047）。超限写入被拒绝，该次不标已发送，段内显示上限 |
| 加载 | 连接中胶囊「连接中」，PSM 输入禁用，避免连接过程中改 PSM。读取最大长度前，长度位置是「—」，不用 0 |
| 无权限 | 与 SPP 终端同一权限墙。未授权不发起 L2CAP 连接。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/l2cap` |
| 架构编号 | BT-047, BT-048, BT-049 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


L2CAP 使用 [SPP 终端](spp-terminal.md) 的同一页和同一 `SppTerminalViewModel`。用户用顶栏 `YoSegmentButton` 选择 `SPP_L2CAP` 或 `SPP_L2CAP_BLE`。不另做模块，不放进星闪。

套接字调用仍只进 `common/yobluetooth`。

## 结构

在终端顶栏和报文之间插入一条参数行，线性 `Row`，窄宽时改为 `Column`：

- PSM：`TextInput`，等宽，只在 L2CAP 两种类型下必填。
- 最大发送长度：只读数字，来自已连接后的 `getMaxTransmitDataSize`（API 22）。未拿到前置「—」。
- 服务端时增加只读「本机 PSM」，来自 `getL2capPsm`。

RFCOMM 分段不显示 PSM 必填，输入行收起（BT-049）。切换分段不清除已经连接的会话；若类型与当前会话不一致，参数行用 `warning` 胶囊「与当前会话类型不同」，主按钮是「断开后按此类型连接」，而不是在已连接会话上改类型。

报文列表和发送栏与 SPP 终端相同。一次读取仍是一行字节。

## 信息密度

PSM 用十进制。最大长度用十进制字节，紧挨发送按钮，使用户在超限前看见上限。不展示 L2CAP 信道内部字段。

`≥600vp` 时参数行留在左栏，报文留在右栏。

## 控件

| 区域 | 符号 |
| --- | --- |
| 类型 | 终端已有 `YoSegmentButton` |
| PSM | 系统 `TextInput` + `YoTextModifier` |
| 上限、本机 PSM | `Text` + `YoTypeStyle.MONO_S` |
| 连接 | `YoActionButton` |
| 类型不符或超限 | `YoStatusPill` `warning` 或段内 `YoError` |

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 已选择 L2CAP，PSM 已填写且与对端一致，已连接。只读长度可见。发送可用 |
| 按下 | 「连接」和「发送」的按下与终端相同。按下不改写 PSM |
| 禁用 | PSM 为空时「连接」禁用，原因「需要与对端一致的 PSM」。写入长度大于最大发送长度时「发送」禁用，原因写出该上限（BT-048）。RFCOMM 分段不要求 PSM，连接按钮不因 PSM 为空而禁用（BT-049） |
| 空 | 已连接但无字节：与终端相同的 `YoEmpty`「还没有数据」。未填写 PSM 不是空列表 |
| 错误 | PSM 不一致：连接失败可见，不进入已连接（BT-047）。超限写入被拒绝，该次不标已发送，段内显示上限 |
| 加载 | 连接中胶囊「连接中」，PSM 输入禁用，避免连接过程中改 PSM。读取最大长度前，长度位置是「—」，不用 0 |

## 导航

类型分段留在本终端内。返回行为与 SPP 终端相同。不从 BLE 扫描地址直接进入 L2CAP；地址页若只有 BLE 扫描地址，L2CAP 连接与 SPP 一样不可用（BT-034）。

## 非目标

- 不把 PSM 填进 RFCOMM 请求里当成必填。
- 不为 L2CAP 新做一套日志组件。
