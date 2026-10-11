# HTTP

从诊断或后续契约指定的入口 push。不占网络底栏。模式：上表单、下控制台。

## 布局

`Scroll` 只包表单，响应 `List` 单独滚动，各占一半高度（`layoutWeight` 1 和 1）。表单：`SegmentButton`「GET」「POST」；URL `TextInput`；POST 时 `TextArea` 正文，GET 时不渲染正文。主按钮「发送」在表单底部，全宽、高 40、圆角 20。

响应列表：状态行 48vp，左胶囊是状态码或「失败」，右 Body_S 耗时。其下正文行不限 48vp，Body_S 可多行，`tnum`。无响应时列表区 Body_M「尚未发送」。

宽屏 ≥600vp：`Row` 左表单 360vp，右响应。主按钮仍在表单底部。

## 组件树

```text
NavDestination 「HTTP」
  Row 或 Column
    Column layoutWeight 1 padding 16 gap 12
      SegmentButton 「GET」「POST」
      TextInput URL
      TextArea  仅 POST
      Button EMPHASIZED 「发送」
    List layoutWeight 1
      ListItem 状态行 胶囊 + 耗时
      ListItem Text Body_S 正文
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 有一次响应，胶囊为码，正文可见 |
| 按下 | 发送按下。方法切换按下 |
| 禁用 | URL 空：发送 enabled false |
| 空 | 「尚未发送」，无胶囊 |
| 错 | 胶囊「失败」error 色，正文区是消息，不是空 |
| 加载 | 发送变为「正在发送」+ LoadingProgress，响应区保留上一次，顶部 Body_S「当前请求未完成」 |
| 无权限 | 权限墙，表单不渲染 |

## 对照

采用控制台来放响应、场景 Tab 的两段方法切换（不是四格）、sheet 式的一颗主按钮但放在页内因为字段少且要对照响应。不采用扫描列表、WLAN 的 AP 分组、家居、FastBle、体温卡、密码可见性图标。
目标名 `/wifi/http-client`。来源：场景页里的表单，不是 E2 的 Toast；列表文档的单行状态 + 可多行正文。

`Column` 上下各 `layoutWeight` 1。上 `Scroll`：`SegmentButton`「GET」「POST」；URL `TextInput`；仅 POST 渲染 `TextArea`。主按钮「发送」全宽、最宽 448、高至少 40。下为响应 `List`：首行 48vp，左胶囊状态码或「失败」，右 12 耗时 `tnum`。正文行不限高，12 Regular，可选择。

无响应时下半区 14「尚未发送」，不画空胶囊。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 表单可编辑，有则显示响应 |
| 按下 | 「发送」按下 |
| 禁用 | URL 空时「发送」disabled |
| 空 | 「尚未发送」 |
| 错误 | 首行胶囊「失败」`warning`，正文为 ViewModel 的短句 |
| 加载 | 「发送」变为「正在发送」disabled，旧响应保留 |
| 无权限 | 表单换成权限墙 |
