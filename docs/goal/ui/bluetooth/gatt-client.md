---
id: ui.bluetooth.gatt-client
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-069, BT-070, BT-071, BT-072, BT-073, BT-074, BT-075, BT-076, BT-077, BT-078, BT-079]
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/ui/bluetooth/mtu-phy-connection.md
  - docs/goal/architecture/bluetooth/BT-069.md
---

# GATT 客户端

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
| 默认 | 已连接且服务发现完成。树可见。选中一个允许读的特征时「读」可点。MTU 区显示当前值，未协商时是 23，细节在参数文档 |
| 按下 | 每个操作按钮松手后入队一次。树节点按下只选中 |
| 禁用 | 未连接时发现、读、写、订阅全部禁用。已连接但 `getServices` 未完成时读写禁用，原因「先完成服务发现」（BT-070）。前一次读、写或订阅尚未回调时，其余操作禁用，原因「等待上一次完成」（BT-075）。不可连接广播不会进入本页的可点连接（扫描页已挡住，BT-061） |
| 空 | 发现成功且服务列表长度为 0：`YoEmpty`「没有服务」，主操作「重新发现」。未连接时不用这个空态 |
| 错误 | 未连接就发现：2901003 或等价码，`YoError`「尚未连接」，不显示空服务树冒充成功（BT-069）。UUID 不在已发现服务里：2901008「服务不存在」（BT-071）。不允许的属性：2901000 或 2901001。订阅时对端不应答：2900007 或 2900099，用户句「等待对端应答」，不写「权限不足」（BT-076）。加密不足：2901005 未加密、2901006 未认证、2901007 未授权，并给出「配对」（BT-077）。断开后树不可读写；若有 `reasonMessage`（如 `0X16_LOCAL_HOST`）显示该字符串（BT-078） |
| 加载 | 连接中、发现中、单次读写中：对应按钮 `loading`，胶囊「连接中」或「发现服务」。发现完成前树区是 `YoLoading`「正在发现服务」，不是空列表 |
| 无权限 | 未授权不发现服务、不读写。权限墙与「尚未连接」（BT-069）分开：前者没有连接动作，后者是已进入客户端但未连上。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/gatt-client` |
| 架构编号 | BT-069, BT-070, BT-071, BT-072, BT-073, BT-074, BT-075, BT-076, BT-077, BT-078, BT-079 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


路由 `/bluetooth/ble/client`，参数是虚拟地址。状态在 `BleMainViewModel` 的连接与浏览器部分。`createGattClientDevice`、连接、发现服务和读写只进 `common/yobluetooth`。

MTU、PHY 和连接参数是本页连上之后的一块区域，细节见 [MTU、PHY 与连接参数](mtu-phy-connection.md)。

## 结构

`YoPageShell`，`OBJECT`，标题为设备名或地址。`scrollable` 为假。

窄屏纵向：

1. 连接条：胶囊、主按钮「连接 / 断开」、次按钮「读取 RSSI」。
2. 服务树 `List`。服务可展开到特征和描述符。
3. 选中项操作条：读、写、无响应写、通知、指示、读描述符、写描述符。只显示属性允许的按钮。
4. 结果区：最近一次值，等宽，以及操作队列「进行中 / 完成」。

`≥600vp`：`YoSplitScaffold` 左树右操作。右栏顶部链到参数区和会话日志，用两张 `YoModeEntryCard`，各一行描述。

## 信息密度

树节点一行一个 UUID，属性用短胶囊：读、写、无响应、通知、指示。不在节点上展开长说明。

操作条一次只高亮用户选中的那一种。读、`WRITE`、`WRITE_NO_RESPONSE` 是三个按钮，不合成一个「写入」后再猜类型（BT-072）。通知和指示也是两个按钮（BT-074）。

描述符操作与特征操作分开记在结果区的「对象」列（BT-073）。

失败码保留在结果区第二行：2901000、2901001、2901003、2901005、2901006、2901007、2901008、2900007、2900099。用户句按码区分，不统一写成「操作失败」。

## 控件

| 区域 | 符号 |
| --- | --- |
| 连接、读、写、订阅 | `YoActionButton`，不允许的属性不渲染该按钮 |
| 连接与订阅相位 | `YoStatusPill` |
| 参数、日志入口 | `YoModeEntryCard` |
| 未连接却去发现 | `YoError` |
| 树还没有服务 | `YoEmpty` 只在发现成功且服务数为 0 时使用 |
| RSSI | `Text` + `MONO_S`，单位 dBm |

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 已连接且服务发现完成。树可见。选中一个允许读的特征时「读」可点。MTU 区显示当前值，未协商时是 23，细节在参数文档 |
| 按下 | 每个操作按钮松手后入队一次。树节点按下只选中 |
| 禁用 | 未连接时发现、读、写、订阅全部禁用。已连接但 `getServices` 未完成时读写禁用，原因「先完成服务发现」（BT-070）。前一次读、写或订阅尚未回调时，其余操作禁用，原因「等待上一次完成」（BT-075）。不可连接广播不会进入本页的可点连接（扫描页已挡住，BT-061） |
| 空 | 发现成功且服务列表长度为 0：`YoEmpty`「没有服务」，主操作「重新发现」。未连接时不用这个空态 |
| 错误 | 未连接就发现：2901003 或等价码，`YoError`「尚未连接」，不显示空服务树冒充成功（BT-069）。UUID 不在已发现服务里：2901008「服务不存在」（BT-071）。不允许的属性：2901000 或 2901001。订阅时对端不应答：2900007 或 2900099，用户句「等待对端应答」，不写「权限不足」（BT-076）。加密不足：2901005 未加密、2901006 未认证、2901007 未授权，并给出「配对」（BT-077）。断开后树不可读写；若有 `reasonMessage`（如 `0X16_LOCAL_HOST`）显示该字符串（BT-078） |
| 加载 | 连接中、发现中、单次读写中：对应按钮 `loading`，胶囊「连接中」或「发现服务」。发现完成前树区是 `YoLoading`「正在发现服务」，不是空列表 |

RSSI：已连接时「读取 RSSI」成功后在连接条显示 dBm；失败走结果区错误，不把失败显示成 0 dBm（BT-079）。

前序未完成若平台返回 2900099，文案使用「前序未完成」，按钮保持禁用直到回调或失败（BT-075）。

## 导航

「配对」打开蓝牙配对半模态，不打开星闪。参数卡片滚到本页参数区或在窄屏 push 同一路由的参数锚点。日志卡片进 `/bluetooth/session-log`。断开后留在本页，树清空为不可操作，方便看断开原因。

重连必须换新的客户端实例；若 2900099 的子原因是客户端未销毁，文案用该原因，入口在 [诊断](reconnect-background-diagnostics.md)。

## 非目标

- 不在发现完成前发出读写。
- 不把通知和指示画成同一个开关。
