# 日志中心

目标名 `/log/list`。从工作台「日志」进入，不是底栏第六项。来源：G12 `SystemLogsPage` 的级别 D/I/W/E/F、暂停/继续、清空、关键字、无设备空态；H6 的分类页签。

顶栏 `Tabs` Fixed：「全部」「蓝牙」「网络」「星闪」。每个页签过滤同一列表。行 48vp：4vp 圆点（E 用 `warning`，W 用 `alert`，其余 `font_tertiary`）、时间 12、摘要 12 省略。点行 `push` 详情。

关键字：`Search` layoutWeight 1，提示「关键字」。空关键字不显示清除；有字时尾部 40vp 热区清除。

级别：`Select`，选项为全部与 D/I/W/E/F，对应 hadice 的 Harmony 级别，不加入 Android 的 VERBOSE。暂停、继续、清空放标题栏菜单。无设备不是本页的条件；没有日志源时用空态，不搬 hadice 的 `NoDeviceState` 桌面插画。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 行按时间倒序，新行在上 |
| 按下 | 行按下 |
| 禁用 | 暂停时不再追加，已有行保留，菜单项变为「继续」 |
| 空 | 「没有日志」 |
| 错误 | 顶栏下 `warning`，筛选保留 |
| 加载 | 列表顶 16vp `LoadingProgress`，已有行保留 |
| 无权限 | 若读取被拒绝，内容换权限墙，页签保留 |
