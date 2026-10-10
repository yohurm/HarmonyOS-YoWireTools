# HTTP

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
