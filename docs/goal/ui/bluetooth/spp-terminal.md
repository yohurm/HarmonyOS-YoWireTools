# SPP 终端

`/bluetooth/spp` 与 `/bluetooth/spp/terminal` 已在 `main` 注册。来源：日志控制台模式；G12 的暂停与清空收进行菜单；连接半模态不用于串口（没有口令字段时不画空输入）。

未连接：内容区不是空日志。`Column` 居中，最大宽 448。标题 20「未连接」，辅文 14「选择设备后连接」，主按钮「连接」。点「连接」若扫描页可打开则 `push` 经典扫描，否则按钮 disabled 且辅文「不能打开」。

已连接：顶行胶囊「已连接」confirm。中部 `List` `layoutWeight` 1，行 48vp：4vp 圆点（收到用 `brand`，发出用 `font_secondary`）、时间 12、摘要 12 单行省略。新行到达时若用户贴着底部则滚到底；用户上滑后不抢滚动。底栏 `Row`：`TextInput` layoutWeight 1，主按钮「发送」宽不超过 448 的剩余。标题栏菜单「断开」「清空」「暂停」。断开先 `AlertDialog`，主按钮「断开」`ButtonRole.ERROR`，次按钮「取消」。

点一行：若 `/log/detail` 未注册，用 `bindSheet` 展示该行全文，不新做第二种详情皮肤。

宽屏 ≥600：`Row`。左 280vp 会话列表，行 64，右为日志加发送栏。窄屏的设备切换若有多个会话，用 `SegmentButton`，宽屏改由左列选中（`interactive_select`）代替。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 已连接布局，发送可点 |
| 按下 | 日志行按下；发送按钮按下 |
| 禁用 | 暂停时发送 enabled false，胶囊改为「已暂停」 |
| 空 | 已连接但无字节：列表区 14「还没有数据」，底栏仍在 |
| 错误 | 顶行 `warning` 短句，日志保留 |
| 加载 | 胶囊「正在连接」加 16vp `LoadingProgress`，发送 disabled，已有日志保留 |
| 无权限 | 未连接区换成权限墙 |
