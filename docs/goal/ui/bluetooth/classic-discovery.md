---
id: ui.bluetooth.classic-discovery
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-009, BT-010, BT-011, BT-012, BT-013, BT-014, BT-015, BT-016, BT-017, BT-018]
verdict_notes: BT-015 是缺口，过滤没有平台成功态
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-009.md
  - docs/goal/architecture/bluetooth/BT-015.md
  - features/bluetooth/src/main/ets/ui/view/ClassicScanPanelView.ets
---

# 经典发现

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Column
            ├── Row                         // 状态条，高 56vp
            │   ├── Text
            │   └── YoStatusPill
            ├── Scroll                      // 只包分段，宽度不写在 SegmentButton 上
            │   └── YoSegmentButton         // SegmentButton，@kit.ArkUI
            ├── TextInput                   // 过滤字段，YoTextModifier
            ├── List
            │   └── ListItem
            │       └── Column
            │           ├── Row
            │           │   ├── Text        // 主行，accessibilityGroup
            │           │   └── YoStatusPill
            │           └── Text            // 次行，最多四个短事实
            └── Row
                ├── YoActionButton          // Button，PRIMARY
                └── YoActionButton          // SECONDARY
    bindSheet                               // 过滤或确认，不承载整条调试流程
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 未发现。已配对设备已列出。主按钮「开始发现」。过滤摘要可见 |
| 按下 | 「开始发现」按下后松手才请求。发现中主按钮文案是「停止」，按下松手才请求停止。行按下只表示选中，不立刻连接 |
| 禁用 | 发现进行中不能再开始，按钮保持「停止」（BT-012）。上一次尚未停止完成时，「开始发现」禁用，原因「请先停止」（BT-013）。非 `STATE_ON` 时按钮禁用，原因来自适配器页的同一快照。选中纯 LE 行时「连接」禁用，原因「不是经典或双模」 |
| 空 | 已配对为空且本次发现已结束、上报为零：`YoEmpty`，标题「附近没有经典设备」，主操作「再次发现」。发现尚未开始且已配对也为空时，标题「尚未发现」，主操作「开始发现」 |
| 错误 | 未授权不进入发现中，列表不新增，用 `YoPermissionDenied`，可再次申请（BT-001）。蓝牙关闭显示 2900003，不用空态（BT-006）。硬件资源 2900009 或扫描失败 2902050 结束发现并显示该码（BT-018）。操作频繁 2900011 时按钮暂时禁用 |
| 加载 | 发现中胶囊「发现中」，约 12 秒后回到空闲，按钮回到「开始发现」（BT-011）。已配对列表首次读取用列表区 `YoLoading`，不挡住停止按钮 |
| 无权限 | 未授权不进入「发现中」，列表不新增，内容区为 `YoPermissionDenied`，可再次申请（BT-001）。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/classic-discovery` |
| 架构编号 | BT-009, BT-010, BT-011, BT-012, BT-013, BT-014, BT-015, BT-016, BT-017, BT-018 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


路由 `/bluetooth/spp`。薄壳是 `SppMainPage`，状态在 `SppMainViewModel`。发现调用只进 `common/yobluetooth` 的 `StartClassicScanUseCase`。

## 结构

`YoPageShell`，`MODULE`，显示返回，标题「经典」。`scrollable` 为假，`contentEdgeToEdge` 为真，列表滚动条贴齐视口。

`<600vp` 时自上而下三块，间距 16vp：

1. `ClassicScanPanelView`：主按钮「开始发现」或「停止」，旁边 `YoStatusPill`。
2. `ClassicScanFilterPanelView`：名称、RSSI 下限。默认收起为一行摘要，点开后用系统 `TextInput`。
3. `SppDeviceListView`：`List`。已配对段在上（BT-017），本次发现段在下。

`≥600vp` 时 `YoSplitScaffold`：左栏是过滤加列表，右栏是选中设备的地址摘要和「配对 / 连接」；未选中时右栏是 `YoEmpty`，标题「未选择设备」。

行组件沿用特性里的 `ClassicDeviceCard`，内部只用 `Text`、`YoStatusPill`、`YoTypeStyle`。不新增 Kit 行。

## 信息密度

API 18+ 的一行四项：名称、虚拟地址、RSSI（dBm）、设备类型（BT-009）。名称或 RSSI 缺失时该格留空。API 17 及以前只保证地址，不补名称和 RSSI（BT-010）。

传输类型用胶囊：经典、双模进入本列表；纯 LE 不进入 SPP 候选（BT-016）。配对状态另一枚胶囊，与传输类型并列，不写成一长句。

过滤摘要始终带一句：「只过滤已经上报的结果」。这句在过滤面板展开时仍可见（BT-015）。

## 控件

| 区域 | 符号 |
| --- | --- |
| 开始 / 停止 | `YoActionButton` `PRIMARY` |
| 发现相位 | `YoStatusPill`：空闲 `neutral`，发现中 `info`，结束 `neutral`，失败 `error` |
| 过滤展开 | 特性面板 + `TextInput` + `YoTextModifier` |
| 列表空、错、加载 | `YoContentState` |
| 行内主操作 | `YoActionButton` `compact`、`fullWidth` 为假 |

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 未发现。已配对设备已列出。主按钮「开始发现」。过滤摘要可见 |
| 按下 | 「开始发现」按下后松手才请求。发现中主按钮文案是「停止」，按下松手才请求停止。行按下只表示选中，不立刻连接 |
| 禁用 | 发现进行中不能再开始，按钮保持「停止」（BT-012）。上一次尚未停止完成时，「开始发现」禁用，原因「请先停止」（BT-013）。非 `STATE_ON` 时按钮禁用，原因来自适配器页的同一快照。选中纯 LE 行时「连接」禁用，原因「不是经典或双模」 |
| 空 | 已配对为空且本次发现已结束、上报为零：`YoEmpty`，标题「附近没有经典设备」，主操作「再次发现」。发现尚未开始且已配对也为空时，标题「尚未发现」，主操作「开始发现」 |
| 错误 | 未授权不进入发现中，列表不新增，用 `YoPermissionDenied`，可再次申请（BT-001）。蓝牙关闭显示 2900003，不用空态（BT-006）。硬件资源 2900009 或扫描失败 2902050 结束发现并显示该码（BT-018）。操作频繁 2900011 时按钮暂时禁用 |
| 加载 | 发现中胶囊「发现中」，约 12 秒后回到空闲，按钮回到「开始发现」（BT-011）。已配对列表首次读取用列表区 `YoLoading`，不挡住停止按钮 |

点配对或 SPP 时，界面先结束「发现中」，再打开配对或连接（BT-014）。发现中的行仍可点，点下后按钮变为停止中的加载，直到停止完成才进入下一步。

## 缺口

BT-015：过滤条件写在面板里，开始调用不带平台过滤参数。没有「平台已按名称扫描」的成功胶囊。未命中的行不出现，是应用层丢掉已上报结果，摘要句保持可见。

## 导航

返回概览。点未配对设备打开配对半模态。点已配对设备打开连接半模态，成功后 push `/bluetooth/spp/terminal`。点地址行 push `/bluetooth/device`。离开本页时若仍在发现，ViewModel 先停止发现。

## 非目标

- 不用 BLE `ScanFilter` 过滤这次发现。
- 不把发现结果画成已经连上 SPP。
