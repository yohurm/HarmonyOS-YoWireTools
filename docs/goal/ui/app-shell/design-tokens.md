# 色彩与度量

来源：D2 色彩全量表；间隔参数；列表；底部页签；按钮；触摸热区；S1 三层 Token。ibest-ui-v2 与 CoolMallArkTS 只提供「浅色/深色成对资源、控件分层」的结构，它们的品牌十六进制不进入本表。

Token 三层：基础值（下面的 ARGB）→ 语义名（`brand`、`font_*`、`background_*`）→ 控件（`comp_*`、`interactive_*`）。界面只引用语义名和控件名。浅色与深色使用同一名字。

## 品牌与状态

| Token | 浅色 | 深色 | 用途 |
| --- | --- | --- | --- |
| brand | `#0A59F7` | `#317AF7` | 一颗主按钮、选中页签、高亮文字 `font_emphasize` |
| warning | `#E84026` | `#D94838` | 失败、危险按钮 `ButtonRole.ERROR` |
| alert | `#ED6F21` | `#DB6B42` | 警告，不是品牌蓝 |
| confirm | `#64BB5C` | `#5BA854` | 已连接、通过 |

禁止把 `brand` 涂成 `#1989fa`、`#465CFF`、`#2563EB` 或任何 Material 蓝阶。

## 文字、图标、背景

| Token | 浅色 | 深色 |
| --- | --- | --- |
| font_primary / icon_primary | `#E5000000` | `#E5FFFFFF` |
| font_secondary / icon_secondary | `#99000000` | `#99FFFFFF` |
| font_tertiary / icon_tertiary | `#66000000` | `#66FFFFFF` |
| font_fourth / icon_fourth | `#33000000` | `#33FFFFFF` |
| font_on_primary / icon_on_primary | `#FFFFFF` | `#FFFFFF` |
| background_primary | `#FFFFFF` | `#E5E5E5` |
| background_secondary | `#F1F3F5` | `#191A1C` |
| background_tertiary | `#E5E5EA` | `#202224` |
| background_fourth | `#D1D1D6` | `#2E3033` |
| comp_background_primary | `#FFFFFF` | `#202224` |
| comp_background_gray | `#F1F3F5` | `#E5E5EA` |
| comp_background_emphasize | `#0A59F7` | `#317AF7` |
| comp_emphasize_tertiary | `#190A59F7` | `#19317AF7` |
| comp_divider | `#33000000` | `#33FFFFFF` |
| interactive_pressed / interactive_click | `#19000000` | `#19FFFFFF` |
| interactive_hover | `#0C000000` | `#0CFFFFFF` |
| interactive_focus / interactive_active | `#0A59F7` | `#317AF7` |
| interactive_select | `#330A59F7` | `#33317AF7` |

雪域灰是浅色 `background_secondary` `#F1F3F5`，也是页面画布。卡片用 `comp_background_primary`。主按钮填充 `comp_background_emphasize`，字用 `font_on_primary`。选中行用 `interactive_select`，按下用 `interactive_pressed`。

`background_primary` 在深色表里是 `#E5E5E5`，不拿它当深色画布。深色页面画布用 `background_secondary`。

## 间隔

来源：间隔参数。基数 4vp / 8vp。

| 名字 | 值 | 场景 |
| --- | --- | --- |
| space.4 | 4vp | 图标与短标签 |
| space.8 | 8vp | 无边界控件、主次文字左右 |
| space.12 | 12vp | 卡片间距、列表右侧元素与正文、设置组间距 |
| space.16 | 16vp | 手机左右边距、有边界控件 |
| space.2 | 2vp | 主次文字上下 |

## 行高、热区、按钮

来源：列表、底部页签、按钮、触摸热区、BluetoothLowEnergy。

| 名字 | 值 | 场景 |
| --- | --- | --- |
| row.48 | 48vp | 单行日志 |
| row.56 | 56vp | 设置、入口 |
| row.64 | 64vp | 双行设备、会话 |
| row.76 | 76vp | 扫描结果卡（E3 实测高度，落在效率列表 72–96 档） |
| icon.24 | 24vp | 页签与列表主图标 |
| icon.16 | 16vp | 行尾箭头、系统小图标 |
| touch.40 | 40vp | 图标按钮热区，用 `responseRegion` 补足。系统默认最小高度是 32vp |
| bar.56 | 56vp | 悬浮底栏内容高，另避让系统导航条 |
| bar.48 | 48vp | 平铺底栏 |
| button.max | 448vp | 单按钮最宽 |
| sheet.max | 480vp | 半模态最宽，左右各留 16vp |

圆角不自造一套。设备卡沿 E3 用 16vp。主按钮沿 `ButtonStyleMode.EMPHASIZED` 的系统圆角，不另写 Material 胶囊色。半模态用 `bindSheet` 的系统圆角。

## 字体

HarmonyOS Sans。层级用 D2 的四级文字色，字号取已读样例，不另造展示字：

| 角色 | 字号 / 字重 | 颜色 | 出处 |
| --- | --- | --- | --- |
| 页标题 | 20 / Bold | font_primary | E3 `NavDestinationTitle` |
| 列表主行 | 16 / Medium | font_primary | E3 设备名 |
| 列表次行 | 14 / Regular | font_secondary | E3 设备标识 |
| 底栏标签 | 10 / Medium | 选中 brand，未选 font_secondary | E4 `tabBuilder` |
| 日志正文 | 12 / Regular，数字 `tnum` | font_primary | 效率列表的次级信息，避免再用更小一档做列表次行（列表文档） |

大字体时优先换行，不把主行缩到不可读。
