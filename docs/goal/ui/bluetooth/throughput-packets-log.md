---
id: ui.bluetooth.throughput-packets-log
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-086, BT-087, BT-088, BT-089, BT-090]
verdict_notes: BT-088 与 BT-089 是缺口，没有应用内 HCI 成功态，也没有 Release 载荷被补回的成功态
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-086.md
  - docs/goal/architecture/bluetooth/BT-088.md
  - docs/goal/architecture/bluetooth/BT-089.md
---

# 吞吐、报文与会话日志

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
| 默认 | 报文段。已有收发则按时间列出。吞吐未开始，数字为 0 字节、用时 0。0 在这里是计数初值，与「字段缺失留空」不同，标签写「已发送」 |
| 按下 | 「开始」松手后进入计数。「停止」松手后不再写。「导出」松手后写文件。行按下展开 HEX |
| 禁用 | 未连接时吞吐开始禁用，原因「未连接」。选定特征不允许写时禁用，原因「特征不可写」。报文段在吞吐计数期间不追加 HEX，List 禁用滚动写入，已有行仍可看。没有「生成 HCI」按钮 |
| 空 | 会话已建立但还没有收发：`YoEmpty`「这次会话还没有字节」。未连接不用空态冒充 |
| 错误 | 导出失败：`YoError` 说明原因，已有行保留（BT-090）。吞吐写入失败：停止计数，已发送字节保留，结果区给出 GATT 或 SPP 的原错误 |
| 加载 | 吞吐进行中胶囊「计数中」，主按钮是「停止」，数字持续更新。导出写文件时按钮 `loading`，List 仍可滚动 |
| 无权限 | 未授权不开始吞吐计数，也不把 0 字节画成一次成功测量。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/throughput-packets-log` |
| 架构编号 | BT-086, BT-087, BT-088, BT-089, BT-090 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


路由 `/bluetooth/session-log`。从 SPP 终端菜单或 GATT 客户端的日志卡片进入，参数带会话种类（SPP 或 GATT）和会话 id。状态在对应 ViewModel。记录和导出走 `common/yobluetooth` 与 `common/storage`。没有单独的平台吞吐 API，速率是应用层计数。

## 结构

`YoPageShell`，`TERMINAL`，`scrollable` 为假，列表贴边。标题「会话」。

顶区 `YoSegmentButton`：「报文」「吞吐」。外层定宽。

报文段：

- `List` 行：时间、方向、长度、原始 HEX。SPP 一次回调一行。GATT 一次读、写、通知或指示一行，对象列写特征或描述符 UUID。
- 底栏：「清屏」`TEXT`，「导出」`SECONDARY`。

吞吐段（仅 GATT，且用户已选定可写特征）：

- 三格数字：已发送字节、用时、字节每秒。用 `TITLE_S`。
- 主按钮「开始 / 停止」。
- 一句说明：计时期间不写逐包 HEX。
- 特征 UUID 一行等宽。没有内置 Nordic 吞吐 UUID 才算开始的限制；任意用户选定的可写特征都可以。

缺口说明固定在页底，不随分段消失：

- 「应用内不能生成空口 HCI。开发者模式采集后用电脑上的工具打开。」
- 「Release 上的这类采集只有 Header，没有载荷。」

`≥600vp`：左栏是模式和缺口说明，右栏是报文或三个数字。

## 信息密度

报文默认两行 HEX，点行展开。时间用 `BODY_S`，HEX 用 `MONO_S`。导出文件包含时间、方向、原始字节；界面清屏不影响已导出文件，清屏按钮的 `disabledReason` 在仅清显示时不出现，旁边 `BODY_S` 写「只清屏幕」（BT-090）。

吞吐进行时右栏不渲染逐包 List，避免调试台在压测时被 HEX 撑满（BT-086）。三个数字始终保留。

HCI 说明是两行 `warning` 胶囊加两句 `BODY_S`，不做成进度或文件名。

## 控件

| 区域 | 符号 |
| --- | --- |
| 报文 / 吞吐 | `YoSegmentButton` |
| 开始、停止、导出 | `YoActionButton` |
| 清屏 | `YoActionButton` `TEXT` |
| 吞吐中 | `YoStatusPill` `info`「计数中」 |
| HCI 限制 | `YoStatusPill` `warning` |
| 没有收发 | `YoEmpty` |
| 导出失败 | `YoError` |
| 导出完成的短反馈 | `YoToast` |

日志行是 `List` 与 `Text`。不恢复已删除的 `YoLogRow` 或 `DataTerminalView`。

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 报文段。已有收发则按时间列出。吞吐未开始，数字为 0 字节、用时 0。0 在这里是计数初值，与「字段缺失留空」不同，标签写「已发送」 |
| 按下 | 「开始」松手后进入计数。「停止」松手后不再写。「导出」松手后写文件。行按下展开 HEX |
| 禁用 | 未连接时吞吐开始禁用，原因「未连接」。选定特征不允许写时禁用，原因「特征不可写」。报文段在吞吐计数期间不追加 HEX，List 禁用滚动写入，已有行仍可看。没有「生成 HCI」按钮 |
| 空 | 会话已建立但还没有收发：`YoEmpty`「这次会话还没有字节」。未连接不用空态冒充 |
| 错误 | 导出失败：`YoError` 说明原因，已有行保留（BT-090）。吞吐写入失败：停止计数，已发送字节保留，结果区给出 GATT 或 SPP 的原错误 |
| 加载 | 吞吐进行中胶囊「计数中」，主按钮是「停止」，数字持续更新。导出写文件时按钮 `loading`，List 仍可滚动 |

停止后不再继续写，已发送字节保留在三格里（BT-087）。结束后分段回到报文，之后的新收发恢复逐行 HEX（BT-086）。

## 缺口

BT-088：没有应用内 HCI 文件，没有「正在抓空口」的加载，没有成功文件名。说明指向开发者模式采集和 PC 工具。`common/storage` 不出现 HCI 导出项。

BT-089：同一说明的第二句写明 Release 只有 Header、载荷被去掉。页面不提供「补回载荷」或「在 Wireshark 中已看到载荷」的成功态。应用不解析 HCI。

## 导航

返回发起它的终端或客户端。SPP 与 GATT 共用这一路由，用参数区分，不复制到星闪或 Wi‑Fi。清屏和导出都不离开本页。

## 非目标

- 不把吞吐绑死在某个特征 UUID 上才显示开始。
- 不在计数期间把逐包 HEX 写进这次记录。
