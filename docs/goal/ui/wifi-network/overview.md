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
