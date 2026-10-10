# 日志中心

目标名 `/log/list`。从工作台「日志」进入，不是底栏第六项，也不是 M6 那种可拖动的圆形「log」按钮。

来源：G12 hadice 的 D/I/W/E/F、暂停、清空、关键字；H6 的分类页签；M6 应用内可视化日志的搜索框、一排级别芯片、清空、以及「开启滑动到底部」。

顶栏 `Tabs` Fixed：「全部」「蓝牙」「网络」「星闪」。其下 `Search`，提示「关键字」，空关键字不显示清除，有字时尾部 40vp 热区清除。再下一行五个芯片：Debug、Info、Warn、Error、Fatal。选中底 `comp_background_neutral`、字 `font_on_primary`；未选中字 `font_secondary`、无底。可多选；一个都不选等于全部。不用 Android 的 VERBOSE。

`List` 行 48vp：4vp 圆点，时间 12，摘要 12 省略。圆点颜色：Error/Fatal `warning`，Warn `alert`，Info `brand`，Debug `font_tertiary`。不画 M6 的彩色描边卡片，背景保持 `comp_background_primary`。点行 `push` 详情。

标题栏菜单：「暂停 / 继续」「清空」「滑动到底部」。清空前 `AlertDialog`，确认按钮 `ButtonRole.ERROR`。滑动到底部默认开：新行在底部时跟着滚；用户上滑后关掉跟随，直到再次打开菜单项。不提供半模态里的背景色板，也不提供「半模态 / 全模态」切换；本页始终是栈上的整页。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 行按时间正序，新行在下，贴底时跟随 |
| 按下 | 行按下；芯片按下 |
| 禁用 | 暂停时不再追加，菜单变为「继续」，芯片仍可筛已有行 |
| 空 | 中部「没有日志」，搜索和芯片留着，没有圆形入口 |
| 错误 | 顶栏下 `warning`，筛选保留 |
| 加载 | 列表顶 16vp `LoadingProgress`，已有行保留 |
| 无权限 | 内容换权限墙，页签、搜索、芯片保留 |
