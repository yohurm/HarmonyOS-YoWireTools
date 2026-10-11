# 网络诊断

目标路由 `/wifi/diagnostics`。模式：场景 Tab，四个页签与 NetworkQuery 的信息结构对应，但文案用本应用能做的事，不照抄示例工程的演示步骤。

页签固定四项：「连接」「状态」「定位」「故障」。页签文本过长时省略，不改成可横滑的第五项。

## 各页签里有什么

连接：一张说明 Body_M「从扫描页选择网络」，文字按钮「去扫描」push 扫描。不在这里再做一套密码框。

状态：链路详情的只读字段，嵌入本页签的 `Scroll`，没有自己的标题栏。

定位：若 ViewModel 没有定位结果，本页签 Body_M「未读取」+ 文字按钮「刷新」。不画地图。有结果则标签/值：经纬度或 ViewModel 给出的字段名。没有字段就不画。

故障：`List` 48vp，每行一条检测项的名称和胶囊（通过、失败、未测）。点行展开无动画的第二行 Body_S 消息（用 `ListItem` 高度变到内容高，或项下再嵌 `Text`）。没有「下载测速 URL」这类示例专用句子。

## 组件树

```text
NavDestination 「诊断」
  Tabs barPosition Start  barMode Fixed
    TabContent 「连接」
      Column padding 16
        Text Body_M
        Button TEXTUAL 「去扫描」
    TabContent 「状态」
      Scroll  链路字段
    TabContent 「定位」
      Column Text 「未读取」 / 字段
        Button TEXTUAL 「刷新」
    TabContent 「故障」
      List
        ListItem
          Text Body_L 项名
          胶囊
          Text Body_S 消息  仅展开
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 停在「状态」。故障项有胶囊 |
| 按下 | 页签按下态（字色 brand）。列表行按压 |
| 禁用 | 某一项 ViewModel 标成不可用：胶囊「不可用」，行 text.disabled，不展开 |
| 空 | 故障页没有任何项：Body_M「没有检测项」，不是零条假数据 |
| 错 | 当前页签顶部插入 Body_M status.error，页签不跳走 |
| 加载 | 当前页签标题行 LoadingProgress「正在检测」。其他页签可切换，切换不取消进行中的检测（取消与否由 ViewModel，界面只反映布尔值） |
| 无权限 | 四个页签都换成同一权限墙，页签仍可切换但内容相同，避免看起来像有一个页签能绕过权限 |

## 对照

采用 NetworkQuery 的等宽文字页签。状态页采用 WLAN 标签/值。不把连接页做成 wifi 密码 sheet。不采用扫描雷达、控制台、家居底栏、FastBle、体温卡。
目标名 `/wifi/diagnostics`。来源：E2 四个视图 `WifiConnector`、`NetworkMonitor`、`WlanLocation`、`NetworkDiagnostics`；H4 等宽页签。E2 把四颗按钮放在栈底，本页改顶栏 `Tabs`。

页签：「连接」「状态」「定位」「故障」。`BarMode.Fixed`。

- 连接：只读当前 SSID、是否验证通过、是否需要门户。这些句子来自 ViewModel，不写死 E2 的 `MyWifi`。需要口令时按钮「连接」打开扫描页那张半模态。
- 状态：标签/值列表，沿链路详情的卡片，字段由 ViewModel 给。
- 定位：AP 列表行 56，主行 BSSID，次行 RSSI。没有地图。
- 故障：行 48，名称 + 胶囊「通过 / 失败 / 未测」。点行在项下展开 14 的说明。若 ViewModel 给出一个速率，在列表上方放一个大数字和三列说明（时延、下载、上传），来源是 M4 测网速。数字用 `font_primary`，弧线刻度和全黑背景不采用。没有速率时不留空仪表。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 当前页签有内容 |
| 按下 | 页签字色 `brand`；行按下 |
| 禁用 | 无 WLAN 时四个页签仍可切换，内容为「WLAN 已关闭」 |
| 空 | 定位无 AP：「没有接入点」 |
| 错误 | 该页签顶部 `warning`，其他页签保持上次内容 |
| 加载 | 当前页签中部 `LoadingProgress` +「正在读取」 |
| 无权限 | 权限墙盖住页签内容，页签条保留 |
