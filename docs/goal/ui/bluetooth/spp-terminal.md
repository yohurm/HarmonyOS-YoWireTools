---
id: ui.bluetooth.spp-terminal
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-037, BT-038, BT-039, BT-040, BT-041, BT-042, BT-043, BT-044, BT-045, BT-046]
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/ui/bluetooth/l2cap.md
  - docs/goal/architecture/bluetooth/BT-037.md
  - features/bluetooth/src/main/ets/ui/page/SppTerminalPage.ets
---

# SPP 终端

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
| 默认 | 已连接。胶囊 `success`「已连接」。输入为空。List 有历史则显示历史。标准或两端一致的自定义 UUID 都可以是这个默认 |
| 按下 | 「发送」按下松手后提交。「停止发送」按下松手后停止后续分段。行按下展开 HEX |
| 禁用 | 未连接或 API 22+ `isConnected` 为假时发送禁用，原因「未连接」（BT-043）。HEX 非法时发送禁用，原因「HEX 无效」（BT-046）。写操作进行中「发送」改为「停止发送」，避免再入队 |
| 空 | 已连接但还没有字节：List 区 `YoEmpty`，标题「还没有数据」，没有主操作。未连接不是空，是禁用加说明 |
| 错误 | UUID 不一致：不进入已连接，顶栏 `YoError` 说明原因（BT-038）。未配对：文案「尚未配对」，下一步「发起配对」，码 2900016（BT-022）。单次写入超过建议上限：该段不标已发送；默认分段长度 600 字节，超过 1024 字节失败可见（BT-041）。服务端关闭后本机胶囊变为未连接，对端方向不再追加成功行（BT-045） |
| 加载 | 连接或 `sppAccept` 未返回时胶囊「连接中」，发送禁用。大缓冲写出时界面保持可点「停止发送」，不用整页 `YoLoading` 盖住终端（BT-042） |
| 无权限 | 未授权不进入「已连接」。终端区改为权限墙，发送不可用（与 BT-043 的未连接区分：未连接是禁用，未授权是权限墙）。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `bluetooth/spp-terminal` |
| 架构编号 | BT-037, BT-038, BT-039, BT-040, BT-041, BT-042, BT-043, BT-044, BT-045, BT-046 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8 。文件不在 `main` |
| 工作台入口 | 工作台「蓝牙」卡片，或底栏蓝牙槽（`TAB_INDEX_BLUETOOTH` = 1） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


路由 `/bluetooth/spp/terminal`，参数是会话 id。页面 `SppTerminalPage`，状态 `SppTerminalViewModel`。读写只经 `common/yobluetooth` 的 SPP 用例。L2CAP 与本页共用终端壳，类型分段见 [L2CAP](l2cap.md)。本页默认类型是 `SPP_RFCOMM`。

## 结构

`YoPageShell`，`TERMINAL`，显示返回，`scrollable` 为假，`contentEdgeToEdge` 为真。标题是设备名，副标题是 UUID 的短标签。

纵向三区，中间区吃掉剩余高度（`layoutWeight`）：

1. 顶栏：连接胶囊、角色胶囊（客户端 / 服务端）、`YoSegmentButton` 三项「RFCOMM / L2CAP / L2CAP BLE」。分段按钮的宽度由外层 `Column` 给，不链式写在分段组件上。
2. 报文 `List`：每行时间、方向、长度、一段 HEX。一次回调一行（BT-040）。字号 `YoTypeStyle.MONO_S`。
3. 底栏：`TextInput`、HEX / 文本分段、`YoActionButton`「发送」。大数据发送时同一位置变成「停止发送」。

服务端模式在顶栏下多一行：监听胶囊和「等待接入 / 已接入」。`sppListen` 与 `sppAccept` 的结果分开显示（BT-044）。

`≥600vp` 时左栏是会话与 UUID，右栏是报文加发送。发送栏贴在右栏底部。

## 信息密度

默认 UUID 显示标准串口 `00001101-0000-1000-8000-00805F9B34FB`，允许改成自定义 UUID（BT-037、BT-039）。UUID 用等宽，完整值在一行内可横向滚动，不折成多行解释。

报文行不把一次读取合并成「一条业务消息」。长度用十进制字节数。超过两行 HEX 在行内省略，点行才展开全文。展开仍在本页，不新开路由。

未连接时底栏留着，发送按钮禁用，避免用户找不到入口（BT-043）。

## 控件

| 区域 | 符号 |
| --- | --- |
| 类型 | `YoSegmentButton` |
| 连接 / 监听 | `YoStatusPill` |
| 发送、停止、断开、开始监听 | `YoActionButton` |
| 非法 HEX | 输入框下 `YoColor.ERROR` 的 `BODY_S` 说明 |
| 无报文 | `YoEmpty` 放在 List 区域 |
| 连接失败 | `YoError` 放在顶栏下，List 仍保留已有行 |
| 复制短反馈 | `YoToast` |

标题栏更多菜单沿用特性里的 `SppTerminalMoreMenu`，项用 `YoTitleBarMenuItem`，由 `YoPageShell` 呈现。

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 已连接。胶囊 `success`「已连接」。输入为空。List 有历史则显示历史。标准或两端一致的自定义 UUID 都可以是这个默认 |
| 按下 | 「发送」按下松手后提交。「停止发送」按下松手后停止后续分段。行按下展开 HEX |
| 禁用 | 未连接或 API 22+ `isConnected` 为假时发送禁用，原因「未连接」（BT-043）。HEX 非法时发送禁用，原因「HEX 无效」（BT-046）。写操作进行中「发送」改为「停止发送」，避免再入队 |
| 空 | 已连接但还没有字节：List 区 `YoEmpty`，标题「还没有数据」，没有主操作。未连接不是空，是禁用加说明 |
| 错误 | UUID 不一致：不进入已连接，顶栏 `YoError` 说明原因（BT-038）。未配对：文案「尚未配对」，下一步「发起配对」，码 2900016（BT-022）。单次写入超过建议上限：该段不标已发送；默认分段长度 600 字节，超过 1024 字节失败可见（BT-041）。服务端关闭后本机胶囊变为未连接，对端方向不再追加成功行（BT-045） |
| 加载 | 连接或 `sppAccept` 未返回时胶囊「连接中」，发送禁用。大缓冲写出时界面保持可点「停止发送」，不用整页 `YoLoading` 盖住终端（BT-042） |

## 导航

返回发现页，会话按 ViewModel 决定保持或关闭；关闭动作在菜单里显式叫「断开」，不靠返回键偷偷断开。未配对错误打开配对半模态。本终端不从星闪或 Wi‑Fi 进入。

## 非目标

- 不把 A2DP / HFP 已连接画进这页的「已连接」。
- 不在 Kit 里新增终端、日志行或 HEX 输入组件。
# SPP 终端

现路由 `/bluetooth/spp/terminal`。模式：控制台日志 + 底栏发送。不是扫描列表。

多路会话用标题下的 `SegmentButton` 切换焦点，切换不断开其他路。发送只作用于焦点。断开在标题栏 `bindMenu`，先 `AlertDialog`「断开这路连接？」确认与取消。

## 布局

标题栏：返回、标题为设备名、菜单。

固定区：一行胶囊（已连接 / 重连中 / 已断开）+ Body_S 地址。其下 `SegmentButton`，一项一路，文案是 UUID 的短标签。只有一路时不渲染 SegmentButton。

中部 `List` `layoutWeight` 1，贴底，新行出现时滚到底（用户上滑离开底部后不抢滚动）。行 48vp：色点（收为 info，发为 brand）、时间 Caption_L、摘要 Body_S 单行省略。点行 push 日志详情，若日志详情路由未对齐则先在本页 `bindSheet` 展示全文，不新造第二套详情视觉。

底栏固定，不随列表滚走：`Row` 高 56，左 `SegmentButton` 小尺寸「文本」「HEX」（若 SegmentButton 的小尺寸 API 不可用，则用两枚 TEXTUAL 按钮，选中的那枚品牌色），中 `TextInput` layoutWeight 1，右主按钮「发送」宽 72、高 40。

左右边距 16。底栏上沿 1vp divider。

宽屏 ≥600vp：`Row`。左列表 280vp 为会话行（每路一行，64vp，显示名称和胶囊），右为上面的日志+发送。窄屏的 SegmentButton 在宽屏隐藏，由左列选中态代替。

## 组件树

```text
NavDestination 设备名
  bindMenu 「断开」
  Column
    Row height 40 padding 水平 16
      胶囊 「已连接」|「重连中」|「已断开」
      Text Body_S 地址
    SegmentButton  仅窄屏且多路
    List layoutWeight 1
      ListItem 48
        Row gap 8
          Circle 或 4vp 色块 radius 4
          Text Caption_L 时间
          Text Body_S 摘要  maxLines 1  textOverflow Ellipsis
    Row height 56 padding 16
      SegmentButton 「文本」「HEX」
      TextInput
      Button EMPHASIZED 「发送」
AlertDialog 「断开这路连接？」 确认 / 取消
```

`Circle` 若未在目标 API 作为组件使用，色点改为 8×8 的 `Row` 背景，不用自造控件名。

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 胶囊「已连接」成功色。列表有收发行。发送可点。输入空时发送 enabled false |
| 按下 | 日志行按压色。发送按钮按下态。菜单项按下态 |
| 禁用 | 胶囊「已断开」中性。输入和发送 enabled false，文字 text.disabled。SegmentButton 仍可切换以查看各路日志 |
| 空 | 列表区居中 Body_M「还没有数据」，无色点行。发送栏仍在 |
| 错 | 发送失败不改标题。列表末尾追加一行，摘要为 ViewModel 消息，色点 error。输入内容保留 |
| 加载 | 胶囊「重连中」警告色，左侧 16vp LoadingProgress。发送 enabled false。已有日志保留 |
| 无权限 | 若进入时权限已丢失：列表区换成权限墙，发送栏不渲染。不在终端里重新扫描 |

## 对照

| 参考 | 取舍 |
| --- | --- |
| wifi 选择 | 发送栏不是密码 sheet。HEX/文本用 SegmentButton，不用下拉 |
| 蓝牙扫描 | 不显示雷达 |
| WLAN 信息 | 宽屏左会话、右日志，相当于 list+detail |
| NetworkQuery | 会话切换用 SegmentButton，不用四个场景名 |
| 智慧家居 | 不使用其底栏；本页底栏是发送 |
| 控制台 | 行是单行日志流，顶上状态而不是 IKConsole 的网络/cookie 页签 |
| FastBle | 不在终端里过滤扫描 |
| BLE 通信 | 不把吞吐做成大号数据卡；计数字在胶囊旁的 Body_S「收 n / 发 n」 |
