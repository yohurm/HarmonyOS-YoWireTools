# GATT 详情

目标名 `/bluetooth/gatt-detail`。来源：列表加详情；H8 最多三张度量卡（RSSI、MTU，第三张仅当 ViewModel 有吞吐）；E3 进入下一级页而不是在扫描行里展开树。

窄屏：`List`。先最多三张度量卡横滑 `Row`（不够三张就少画）。其下按服务分组，`ListItemGroup`，组头是服务 UUID 的短标签 14 `font_secondary`。属性行 56vp：主行 UUID 短标签 16，次行 14 写 ViewModel 给出的「可读 / 可写 / 可通知」。行点击在同一栈再推属性页。

属性页：标题为短 UUID。值区 `Text` 14 `tnum`，可系统选择复制。按钮一行：有读则「读取」，有写则「写入」打开 `bindSheet`（一个 `TextArea` +「写入」），有通知则 `Toggle`「通知」。没有的动作不渲染。

宽屏 ≥600：`Row` 左树 280vp，右属性页。未选时右侧 14「选择一项属性」。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 树与值可见 |
| 按下 | 属性行按下 |
| 禁用 | 断线：动作 enabled false，顶行胶囊「未连接」 |
| 空 | 无服务：14「没有服务」，不画假 UUID |
| 错误 | 值区 `warning` 一行，树保留 |
| 加载 | 「读取」文案变为「正在读取」且 disabled，值位置 16vp `LoadingProgress` |
| 无权限 | 权限墙替换整页 |
