---
id: ui.bluetooth.ble-scan
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-050, BT-051, BT-052, BT-053, BT-054, BT-055, BT-056, BT-057, BT-058, BT-059, BT-060, BT-061]
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-050.md
  - product/phone/src/main/ets/pages/bluetooth/BleMainPage.ets
---

# BLE 扫描

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
| 默认 | 未扫描。占空停留在用户上次选择，默认均衡。过滤为空时摘要「不过滤」。列表保留上一次结果直到用户清空 |
| 按下 | 「开始扫描」松手后才提交当前过滤。行按下选中并在窄屏推入详情、宽屏更新右栏 |
| 禁用 | 非 `STATE_ON` 时开始禁用。API ≤14 且已有一路扫描时，第二路不出现可点的开始（BT-056）。`connectable` 为假时「连接」禁用，原因「该广播不可连接」（BT-061）。操作频繁 2900011 时开始按钮暂时禁用 |
| 空 | 扫描正常结束且回调为零：`YoEmpty`「没有符合过滤的广播」，主操作「停止条件并再扫」。过滤为空仍为零时，标题「附近没有低功耗广播」 |
| 错误 | 未授权：不增加行，`YoPermissionDenied`（BT-002）。蓝牙关闭：2900003，不是空列表（BT-006）。门限超出 [-128, 127]：输入下错误文案，不发扫描 |
| 加载 | 扫描中胶囊「扫描中」，主按钮为「停止」。命中名称子串后停止扫描并保持该行（BT-053）。连上目标后该路扫描停止（BT-058） |
| 无权限 | 未授权不增加扫描行，用 `YoPermissionDenied`（BT-002）。蓝牙关闭的 2900003 仍是错误，不是无权限。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/ble-scan` |
| 架构编号 | BT-050, BT-051, BT-052, BT-053, BT-054, BT-055, BT-056, BT-057, BT-058, BT-059, BT-060, BT-061 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


路由 `/bluetooth/ble`。薄壳 `BleMainPage`，扫描状态在 `BleMainViewModel`。开始扫描只进 `common/yobluetooth` 的 BLE 扫描用例。未授权不调用扫描（BT-002）。

## 结构

`YoPageShell`，`MODULE`，标题「低功耗扫描」，返回概览。`scrollable` 为假，列表贴边。

顶区：

- 主按钮「开始扫描 / 停止」。
- `YoSegmentButton` 占空：低功耗、均衡、低延迟，对应 `SCAN_MODE_LOW_POWER`、`BALANCED`、`LOW_LATENCY`（BT-055）。外层决定宽度。
- 过滤摘要一行，点开为面板。

过滤面板字段：name、serviceUuid、serviceUuidMask、manufactureId、manufactureData、manufactureDataMask。另有「名称包含」子串，标成应用层匹配，不放进精确 name（BT-053）。API 23+ 增加 RSSI 门限。空过滤的摘要写「不过滤」（BT-051）。

列表一行一台设备。点行展开本机已解析字段，不跳到 Wi‑Fi。

`≥600vp`：左过滤与列表，右选中设备的原始广播与连接按钮。

API 15+ 可以有第二路扫描：顶区用两枚胶囊「扫描 1 / 扫描 2」，各自停止（BT-057）。API ≤14 不提供第二路开关（BT-056）。

## 信息密度

一行：名称（可空）、虚拟地址、RSSI dBm、可连接胶囊。第二行只在展开时出现：flags、厂商数据、服务数据、UUID、发射功率、原始 `data`。缺的字段写「空」，不写 0（BT-060）。原始字节等宽，默认两行省略。

过滤是白名单。摘要用「仅包含」而不是「排除」（BT-050）。有 UUID 或厂商条件且用户要名称子串时，摘要写「平台过滤 UUID 或厂商，名称在结果里匹配」（BT-053）。

RSSI 门限输入限制在协议范围 [-128, 127]。建议区间 [-90, 127] 写在输入说明里。超出协议范围时不开始扫描。API 23 以下没有门限输入，说明「当前系统没有 RSSI 门限」（BT-054）。

## 控件

| 区域 | 符号 |
| --- | --- |
| 开始 / 停止 / 连接 | `YoActionButton` |
| 占空 | `YoSegmentButton` |
| 扫描相位、可连接 | `YoStatusPill` |
| 过滤 | 特性面板 + `TextInput` |
| 无结果 / 失败 / 权限 | `YoContentState`、`YoEmpty`、`YoError`、`YoPermissionDenied` |

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 未扫描。占空停留在用户上次选择，默认均衡。过滤为空时摘要「不过滤」。列表保留上一次结果直到用户清空 |
| 按下 | 「开始扫描」松手后才提交当前过滤。行按下选中并在窄屏推入详情、宽屏更新右栏 |
| 禁用 | 非 `STATE_ON` 时开始禁用。API ≤14 且已有一路扫描时，第二路不出现可点的开始（BT-056）。`connectable` 为假时「连接」禁用，原因「该广播不可连接」（BT-061）。操作频繁 2900011 时开始按钮暂时禁用 |
| 空 | 扫描正常结束且回调为零：`YoEmpty`「没有符合过滤的广播」，主操作「停止条件并再扫」。过滤为空仍为零时，标题「附近没有低功耗广播」 |
| 错误 | 未授权：不增加行，`YoPermissionDenied`（BT-002）。蓝牙关闭：2900003，不是空列表（BT-006）。门限超出 [-128, 127]：输入下错误文案，不发扫描 |
| 加载 | 扫描中胶囊「扫描中」，主按钮为「停止」。命中名称子串后停止扫描并保持该行（BT-053）。连上目标后该路扫描停止（BT-058） |

离开本页时扫描停止，回来不是仍在「扫描中」（BT-059）。页面隐藏与返回都走同一停止。

## 导航

「连接」只对可连接广播 push `/bluetooth/ble/client`。连接前停止该路扫描。地址行进 `/bluetooth/device`。标题菜单进 `/bluetooth/ble/peripheral` 与 `/bluetooth/diagnostics`。不进星闪。

## 非目标

- 不把经典发现当作本页扫描失败后的替身。
- 不把空过滤显示成仍在使用上一轮条件。
# BLE 扫描

现路由 `/bluetooth/ble`。模式：过滤后扫描（FastBle 的顺序）+ 扫描列表。过滤表单在 sheet，不嵌在每一行。

## 布局

标题栏「低功耗」，右侧文字按钮「过滤」。

头与经典扫描相同：标题、辅文、开始或重新搜索。有行后 `List` 64vp：名称、地址 Body_S、次行 RSSI 与是否可连接。不可连接的行仍显示，右侧按钮文案「不可连接」且 enabled false，行点击不 push。可连接行右侧「连接」，点击 push GATT 详情并带上地址参数；连接过程中的进度在详情页，不在扫描页打开第二张 sheet。

过滤 sheet：`Select` 或 `TextInput` 四项里只放 ViewModel 已有的条件（名称、服务 UUID、RSSI）。没有的字段不画。主按钮「用此过滤重新扫描」，关闭 sheet 并开始扫描。点遮罩关闭且不扫描。

空过滤：若 ViewModel 允许，主按钮可点，sheet 内 Body_S「未填写条件将看到更多设备」。若不允许，主按钮 enabled false，这句改为「至少填一项」。

宽屏：列表最大宽 600vp。sheet 居中。不在扫描页右侧展开 GATT。

## 组件树

```text
NavDestination 「低功耗」
  标题栏 Button TEXTUAL 「过滤」
  Column
    结果头 同经典扫描
    List
      ListItem 64
        Column
          Text Body_L 名称或「未命名」
          Text Body_S 地址
          Text Body_S  「RSSI -60」 「可连接」|「不可连接」
        Button TEXTUAL 「连接」|「不可连接」
bindSheet 「过滤」
  Column gap 16 padding 16
    TextInput 提示「名称」
    TextInput 提示「服务 UUID」
    TextInput 提示「最低 RSSI」 type Number
    Text Body_S 空过滤说明
    Button EMPHASIZED 「用此过滤重新扫描」
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 标题「搜索成功」，列表有行，可连接行的「连接」可点 |
| 按下 | 行与按钮按下态。过滤字段获焦时边框用 brand，这是 TextInput 的焦点，不是按下 |
| 禁用 | 蓝牙未开：与经典扫描相同的缺口短结构。「不可连接」按钮始终禁用 |
| 空 | 「尚未搜索」+ 图示 +「开始搜索」。无「已搜索到设备」 |
| 错 | 「搜索失败」+ 消息。过滤 sheet 若开着，错误写在 sheet 结果行，不关 sheet |
| 加载 | 「正在搜索」+ LoadingProgress。新行插入列表。按钮变为「停止」 |
| 无权限 | 权限墙。过滤按钮不渲染 |

## 对照

| 参考 | 取舍 |
| --- | --- |
| wifi 选择 | 过滤 sheet 用输入而不是 Wi-Fi 下拉；仍是一颗主按钮 |
| 蓝牙扫描 | 结果头与列表 |
| WLAN 信息 | 行是双行文本，没有「加密」锁图标，除非 ViewModel 提供安全字段 |
| NetworkQuery | 不用场景 Tab |
| 智慧家居 | 不用设备海报 |
| 控制台 | 广播原文不在本列表展开，进详情再看 |
| FastBle | 采用「先过滤再扫」。没有它的截图，不模仿未见过的控件皮肤 |
| BLE 通信 | RSSI 留在次行，不做成全宽数据卡 |
# BLE 扫描

路由 `/bluetooth/ble` 已在 `main` 作为目的地。来源：E3 `BluetoothClientView` 与 `BluetoothDeviceItem`；H2 的重新搜索；H7 只说明扫描前可以有过滤，本页不画 FastBle 的库表单，除非 ViewModel 已给出过滤词。

与经典扫描同一张卡片。次行是地址和 RSSI。不可连接的行仍显示，右侧按钮文案「不可连接」且 `enabled` false，行点击不 push。可连接行按钮「连接」，点击 `push` GATT 详情目标名并带上 ViewModel 的地址参数。连接进度在详情页，扫描页不弹第二张 sheet。

E3 在行内就地连接并在连接中显示 `LoadingProgress`，点已连接行才进入心率页。本应用把「进入详情」放在可连接行的点击上，避免一行里既跳转又发起连接。行内按钮只负责连接请求，结果反映到按钮文案「连接中」。

空态沿 E3：不渲染空 `List`，中部说明「没有设备」，底部一颗主按钮「搜索设备」，最宽 448vp。

过滤：仅当 ViewModel 提供名称关键字时，在标题下放一个 `Search`，高度 40，提示「名称」。没有关键字状态时不渲染 `Search`。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 有卡，按钮「连接」或「不可连接」 |
| 按下 | 卡片 `interactive_pressed` |
| 禁用 | 扫描中「搜索设备」改为「停止」且可点；适配器关则按钮 disabled |
| 空 | 无卡，说明 +「搜索设备」 |
| 错误 | 标题下 `warning` 一行，列表保留上次结果 |
| 加载 | 按钮「停止」，已有卡保留，新卡追加 |
| 无权限 | 权限墙。E3 在 `aboutToAppear` 里查权限，本页改由 ViewModel 状态驱动墙，界面不查 |
