# 经典扫描

现页面 `SppMainPage`，现路由 `/bluetooth/spp`。目标名可对齐架构第 7.2 节 `/bluetooth/classic-scan`，路由字符串等 PR #21 进 `main` 再改。模式：扫描列表 + 连接 sheet。

活动连接不和扫描行混在一组。上面一组「活动连接」，下面一组才是发现结果。行点击进终端；「连接」才打开 sheet。未配对时 sheet 先说明系统配对，主按钮「去配对」。系统 PIN 对话框不是本页的组件。配对成功后同一 sheet 换成 UUID 与「连接」。

## 布局

标题栏「经典」，返回 pop。内容：

- 固定头：结果标题 + 辅文 + 文字按钮「重新搜索」（还没扫过时是「开始搜索」）。
- 无行且未在扫描：160vp 图示区，然后按钮。不显示「已搜索到设备」。
- 有行：`List` 滚动，头不滚动。`ListItemGroup`「活动连接」可以没有 header 当组为空则整组不渲染。`ListItemGroup`「已搜索到设备」。
- 行 64vp：名称 Body_L，次行地址 Body_S。活动行次行再加短 UUID。右侧「连接」或，活动行右侧不放「断开」（断开在终端或行的 `bindMenu`）。

连接 sheet（`bindSheet`，模态）：

- 标题「连接」。
- 设备名 Body_L，地址 Body_S。
- 未配对：Body_M「接下来由系统弹出配对，本页不输入 PIN。」主按钮「去配对」。
- 已配对：`SegmentButton` 两项「标准串口」「自定义」。自定义时 `TextInput` 放 UUID。主按钮「连接」。
- 结果行：成功前隐藏；失败时 Body_S status.error，显示 ViewModel 消息。

宽屏：列表与图示规则不变。sheet 按宽度变为居中面板。不在右侧开详情，经典扫描的详情就是终端。

## 组件树

```text
NavDestination 「经典」
  Column
    Column padding 16 gap 2
      Text Title_M  「尚未搜索」|「正在搜索」|「搜索成功」|「搜索失败」
      Text Body_M text.secondary  对应辅文
      Button TEXTUAL 「开始搜索」|「重新搜索」
    图示区 height 160  仅无行时
      Stack
        SymbolGlyph 48
    List layoutWeight 1
      ListItemGroup
        SubHeader 「活动连接」
        ListItem 64  点击 push 终端
          Text 名称 / Text 地址+UUID
          bindMenu：断开
      ListItemGroup
        SubHeader 「已搜索到设备」
        ListItem 64
          Text 名称 / Text 地址
          Button TEXTUAL 「连接」  onClick 打开 sheet，不触发行点击
bindSheet
  Column padding 16 gap 16
    Text Body_L 设备名
    Text Body_S 地址
    未配对：Text Body_M 系统配对说明
    已配对：SegmentButton 「标准串口」「自定义」
            TextInput  仅自定义
    Button EMPHASIZED 「去配对」|「连接」
    Text Body_S  仅失败
# 经典蓝牙扫描

目标名 `/bluetooth/classic-scan`。`main` 未注册，入口按缺口墙处理。来源：H2 状态标题 +「重新搜索」+ 列表；E3 卡片尺寸与连接中进度；E1 的「已连接」分组。

## 布局

上：标题 20「尚未搜索 / 正在搜索 / 搜索成功 / 搜索失败」。辅文 14。文字按钮在标题行右侧。无结果且未搜索时，中部 48vp Symbol（SDK 核对后）和一句「附近的设备会出现在这里」。有结果后图示收起。

`List` 两组：`ListItemGroup`「已连接」，`ListItemGroup`「可用」。行 76vp，圆角 16，左右 16，间距 12。主行名称 16，次行地址 14 `tnum`。右侧文字按钮「连接」，与正文间隔 12。连接中该按钮内放 20vp `LoadingProgress`，色 `brand`（E3 用了 `#FF0A59F7`，本文改 Token）。

已连接行不放「断开」。断开在终端页菜单，或本行 `bindMenu` 一项「断开」。长按不出删除，经典配对记录的删除不在本页发明。

## 树

```
Column
  Row
    Column
      Text 20
      Text 14
    Button TEXTUAL  「开始搜索」|「停止」|「重新搜索」
  List layoutWeight 1  或空态 Column
    ListItemGroup header 已连接
    ListItemGroup header 可用
      ListItem
        Row
          Column 名称 / 地址
          Button TEXTUAL 连接
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 标题「搜索成功」。辅文「已搜索到周边设备」。列表有行。按钮「重新搜索」可点。sheet 关闭 |
| 按下 | 行按压色。「连接」和「重新搜索」走文字按钮按下。sheet 主按钮走 EMPHASIZED 按下 |
| 禁用 | 适配器未开：按钮 enabled false，标题「蓝牙未打开」，无列表，无图示雷达成功态，改为缺口墙的短结构（见权限与缺口）。已在连接中的那一行「连接」变为「连接中」且 enabled false |
| 空 | 标题「尚未搜索」，辅文「开始后大约十余秒结束」，图示区在，无 SubHeader，无 ListItem |
| 错 | 标题「搜索失败」，辅文为 ViewModel 消息（不新编错误码）。上次的活动连接组若 ViewModel 仍给出则保留，发现组清空 |
| 加载 | 标题「正在搜索」，标题行尾 16vp LoadingProgress。已发现的行留在列表里逐条变高。按钮文案「停止」，可点 |
| 无权限 | 权限墙「需要蓝牙权限」。不渲染列表和 sheet |

## 对照

| 参考 | 取舍 |
| --- | --- |
| wifi 选择 | sheet 的字段节奏：选择或输入、一颗主按钮、结果行。经典这里是 UUID 而不是 Wi-Fi 下拉 |
| 蓝牙扫描 | 标题、辅文、重新搜索、分组列表。有行时不留雷达 |
| WLAN 信息 | 活动连接与发现分两组，同 SubHeader 做法 |
| NetworkQuery | 不用场景 Tab |
| 智慧家居 | 不放底栏里的家居卡 |
| 控制台 | 终端才用日志流 |
| FastBle | 过滤 sheet 不用于经典发现；经典没有平台过滤字段可填 |
| BLE 通信 | 不在扫描行上放大号 RSSI 数字卡 |
| 态 | 表现 |
| --- | --- |
| 默认 | 标题「搜索成功」，按钮「重新搜索」，列表可见 |
| 按下 | 行 `interactive_pressed`；按钮按系统按下 |
| 禁用 | 适配器关：按钮 enabled false，标题「蓝牙已关闭」 |
| 空 | 搜索结束 0 台：标题「搜索成功」，辅文「没有设备」，无 List |
| 错误 | 标题「搜索失败」，辅文为 ViewModel 短句，按钮「重新搜索」 |
| 加载 | 标题「正在搜索」，标题旁 16vp `LoadingProgress`，已出现的行保留，按钮「停止」 |
| 无权限 | 权限墙替换整页 |
