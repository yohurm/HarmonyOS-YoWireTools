# 网络概览

现路由 `/wifi/overview`，槽位「网络」。`main` 上是空 `Column`。模式：一张当前链路摘要 + 入口列表。摘要的字段对齐 WLAN 信息查询右机：名称、IP。没有读到的值写「未读取」，不画灰条冒充。

## 布局

标题「网络」。

摘要卡 radius.16，padding 12：第一行名称 Body_L，第二行 IP Body_S `tnum`，右侧胶囊「已连接」或「未连接」。卡可点，push 链路详情。

`SubHeader`「入口」。四行 56vp：扫描、诊断、局域网、Socket。HTTP 与 WebSocket 从诊断的场景里进入，不堆在概览。行尾箭头。

无权限时整页权限墙「需要网络权限」，不显示假的 SSID。

## 组件树

```text
NavDestination 「网络」
  Column padding 16 gap 12
    Row 表面卡 height 72 padding 12
      Column
        Text Body_L SSID 或「未连接」
        Text Body_S IP 或「未读取」
      胶囊
    SubHeader 「入口」
    List
      ListItem 56 「扫描」
      ListItem 56 「诊断」
      ListItem 56 「局域网」
      ListItem 56 「Socket」
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 卡上有名称和 IP，胶囊「已连接」。四行可点 |
| 按下 | 卡与行按压色 |
| 禁用 | WLAN 关闭：胶囊「未开启」，卡次行「未开启」，点击卡不 push。入口里扫描行禁用，诊断、局域网、Socket 仍可点（它们不都依赖 WLAN 已连接，是否禁用由 ViewModel 的布尔值决定，规范不猜测） |
| 空 | 从未读取：卡主行「未读取」，无胶囊颜色，用中性「未读取」 |
| 错 | 卡下方 Body_M status.error 消息。入口仍在 |
| 加载 | 卡内 LoadingProgress，文字「正在读取」 |
| 无权限 | 权限墙 |

## 对照

采用 WLAN 的名称+地址层次和家居壳之外的列表入口。不在概览放 wifi 选择的密码框、扫描雷达、四格诊断（诊断页自己用）、控制台、体温卡、FastBle。
# 网络总览

路由 `/wifi/overview` 已在 `main`。来源：E2 的四个场景收成诊断入口，而不是四颗底按钮；E6 的入口行。

状态行「WLAN」+ 胶囊（已连接 SSID 或「未连接」）。其下 `List` 四行 56vp：扫描、诊断、局域网、Socket。HTTP 与 WebSocket 从诊断的场景页进入，不堆在总览。行尾箭头。点击 `push` 对应目标名；目标名未注册则次行「不能打开」且不跳。

已连接胶囊点击 `push` 链路详情。未连接时胶囊不可点。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 胶囊为当前 SSID，四行可点 |
| 按下 | 行按下 |
| 禁用 | WLAN 关闭：扫描与诊断行仍可点进各自的关闭空态，胶囊「未开启」 |
| 空 | 无 SSID：胶囊「未连接」 |
| 错误 | 状态行下 `warning` 一行 |
| 加载 | 胶囊位置为进度 +「正在读取」 |
| 无权限 | 权限墙替换总览 |
