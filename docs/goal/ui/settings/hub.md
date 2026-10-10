# 设置

从「更多」`/more/hub` 进入。更多页本身是三行 56vp：设置、关于。关于可与设置里的关于重复，更多页的关于行直接滚到设置的关于组（同一 `NavDestination`，不建第二页）。

目标名 `/settings/index`。来源：E6 `SettingList` 的组间距 12 与组内分割线；G8 行内「标题 + 右值 + 箭头」；G6 的分组节奏。E6 的搜索框、WLAN 开关、生物识别等系统设置项不搬进工具。S2 要求工具设置保持可扫读，三组不够搜索。

三组，组间 12vp，组内 `Divider` 用 `comp_divider`，左右 padding 12，页面底 `background_secondary`，组卡片 `comp_background_primary` 圆角 16：

1. 显示：一行「主题」，右值「跟随系统 / 浅色 / 深色」。点击 `bindSheet`，三行单选，选中行 `interactive_select`。
2. 记录：一行「日志级别」，右值当前级别。sheet 与日志中心同一组 D/I/W/E/F 加上「全部」。
3. 关于：一行「版本」，右值为版本号，无箭头，不可点。

不绘制未合并契约里的八组设置，不画专家/轻量开关。

## 更多枢纽树

```
Column background background_secondary padding 16
  List
    ListItem 56  「设置」  箭头
    ListItem 56  「关于」  箭头
```

## 设置状态

| 态 | 表现 |
| --- | --- |
| 默认 | 三组可见，右值已填 |
| 按下 | 行按下；sheet 选项按下 |
| 禁用 | 版本行无按下 |
| 空 | 版本未知时右值「未读取」，组仍在 |
| 错误 | 主题行下不放错误；保存失败时 sheet 内 `warning` |
| 加载 | 右值「正在读取」 |
| 无权限 | 设置不换权限墙 |
