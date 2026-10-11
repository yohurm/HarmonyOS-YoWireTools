---
id: ui.bluetooth.pairing
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-019, BT-020, BT-021, BT-022, BT-023, BT-024, BT-025, BT-026]
verdict_notes: BT-023 与 BT-024 是缺口，没有取消配对或应用内确认的成功态
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-019.md
  - docs/goal/architecture/bluetooth/BT-023.md
  - docs/goal/architecture/bluetooth/BT-024.md
  - features/bluetooth/src/main/ets/ui/dialog/PairingGuideDialog.ets
---

# 配对

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
bindSheet
└── Column
    ├── YoTitleBarActionRow
    ├── Text
    ├── YoStatusPill
    ├── YoError                     // 取消或失败
    └── YoActionButton              // 发起配对。没有 PIN 输入
AlertDialog                         // 只用于破坏性确认，不用于系统配对
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 未配对。胶囊 `neutral`「未配对」。主按钮「发起配对」。没有 PIN 输入框 |
| 按下 | 「发起配对」按下松手后才调用。关闭图标按下只关半模态，不改变配对状态 |
| 禁用 | 配对中主按钮禁用，原因「等待系统配对」。已配对时「发起配对」不出现。应用内「取消配对」不作为可成功的按钮（见缺口） |
| 空 | 没有选中设备就打开时，半模态用 `YoEmpty`，标题「未选择设备」，主操作「返回列表」。不显示已配对 |
| 错误 | 用户取消系统框后，胶囊回到未配对，`YoError` 说明已取消。取消 PIN 的事件可能晚到，晚到前保持配对中（BT-021）。UUID 查询失败是说明行，不是整页错误 |
| 加载 | `pairDevice` 已返回但尚未收到 `BOND_STATE_BONDED` 时，胶囊「配对中」，语气 `warning`，按钮 `loading`。这时不显示「已配对」（BT-019） |
| 无权限 | 未授权不调用配对。半模态说明需要蓝牙权限，主操作「授权」。没有 PIN 框。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/pairing` |
| 架构编号 | BT-019, BT-020, BT-021, BT-022, BT-023, BT-024, BT-025, BT-026 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


配对不是独立 Tab。它是经典发现或地址页上的半模态，加上系统配对框。应用半模态只解释将要发生什么。密钥和 PIN 的确认留在系统界面。

状态在 `SppPairingGuideController` 与 `SppMainViewModel`。`pairDevice` 只经 `common/yobluetooth`。未知地址类型时调用不带类型的 `pairDevice(deviceId)`（BT-033，入口在地址页，结果仍回到这里的配对胶囊）。

## 结构

`YoNavDestinationKind.MODAL`。`<600vp` 时从底部升起，`≥600vp` 时居中，宽度受 `YoDialogToken` 约束。标题行用 `YoTitleBarActionRow` 放关闭。正文是线性 `Column`：

1. 设备名与虚拟地址，地址等宽。
2. 胶囊：未配对、配对中、已配对、失败。
3. 两句说明：系统将显示配对框；应用不输入 PIN。
4. 主按钮「发起配对」。已配对时主按钮改为「连接」，`SECONDARY` 是「在系统设置中管理」。
5. 配置文件一行：A2DP、HFP、HID、PAN 各自一枚 `YoStatusPill`。SPP 单独一枚，文案在未 `sppConnect` 前是「SPP 未连接」（BT-025）。

远端 UUID 查询失败时，说明行可见，其下仍保留标准 UUID 与自定义 UUID 的 `TextInput`（BT-026）。UUID 等宽。

## 信息密度

半模态同时只服务一台设备。不列附近其他设备。配置文件状态用胶囊，不用段落。失败原因一行，平台码放在 `YoError` 的原因层，例如未配对是 2900016，用户句是「尚未配对」，下一步是「发起配对」，不用「连接超时」（BT-022）。

## 控件

| 区域 | 符号 |
| --- | --- |
| 半模态标题操作 | `YoTitleBarActionRow` |
| 配对 / 连接 / 打开设置 | `YoActionButton` |
| 相位 | `YoStatusPill` |
| 失败 | `YoError` 嵌在半模态内，不替换整个发现页 |
| 说明已读完仍要等系统框 | 按钮 `loading` |

`PairingGuideDialog` 继续作为特性对话框。它内部只组装上述 Kit 符号。

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 未配对。胶囊 `neutral`「未配对」。主按钮「发起配对」。没有 PIN 输入框 |
| 按下 | 「发起配对」按下松手后才调用。关闭图标按下只关半模态，不改变配对状态 |
| 禁用 | 配对中主按钮禁用，原因「等待系统配对」。已配对时「发起配对」不出现。应用内「取消配对」不作为可成功的按钮（见缺口） |
| 空 | 没有选中设备就打开时，半模态用 `YoEmpty`，标题「未选择设备」，主操作「返回列表」。不显示已配对 |
| 错误 | 用户取消系统框后，胶囊回到未配对，`YoError` 说明已取消。取消 PIN 的事件可能晚到，晚到前保持配对中（BT-021）。UUID 查询失败是说明行，不是整页错误 |
| 加载 | `pairDevice` 已返回但尚未收到 `BOND_STATE_BONDED` 时，胶囊「配对中」，语气 `warning`，按钮 `loading`。这时不显示「已配对」（BT-019） |

系统框出现时，应用半模态留在后面，不自绘第二套 PIN（BT-020）。`BOND_STATE_BONDED` 到达后胶囊改为 `success`「已配对」，主按钮变为「连接」。

## 缺口

BT-023：已配对设备上没有「取消配对」成功按钮。次按钮文案是「打开系统蓝牙设置」。设置打不开时 `YoError` 说明，设备仍显示已配对。

BT-024：普通应用不出现「确认配对」「拒绝配对」或 PIN 键盘。没有「已确认」胶囊。`setDevicePairingConfirmation` 不在界面上有入口。

## 导航

关闭半模态回到发现列表，列表上的配对胶囊与半模态一致。配对完成后用户点「连接」，先停止发现（BT-014），再进入 SPP 连接。SPP 未配对失败时，终端或连接对话框提供回到本半模态的「发起配对」，不把用户送去 Wi‑Fi 或星闪。

## 非目标

- 不把配置文件已连接画成 SPP 已连接。
- 不在应用内收集 PIN 并当作系统结果。
