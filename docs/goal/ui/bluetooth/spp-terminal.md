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
