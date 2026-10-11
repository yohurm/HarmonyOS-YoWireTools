---
id: ui.app-shell.tokens
type: ui-design
status: draft
when: design
related:
  - common/youi_kit/doc/YouiKit-Token-Design.md
  - common/youi_kit/src/main/ets/token/foundation/YoSpace.ets
  - common/youi_kit/src/main/ets/token/semantic/YoColor.ets
  - common/youi_kit/src/main/ets/token/semantic/YoResponsive.ets
  - common/youi_kit/src/main/ets/components/containers/YoStatusPill.ets
  - docs/goal/ui/app-shell/color-scheme.md
---

# Design Token

屏幕只引用 `common/youi_kit/Index.ets` 已导出的 Token。不新增 `youi_*` 资源名，不恢复已删除的 `YoSurface`、`YoInputToken`、`YoTerminalToken`。

## 三层

Foundation → Semantic → Component。业务页读 Semantic 和 Component。壳和 Kit 内部才直接读 Foundation。这与 `common/youi_kit/doc/YouiKit-Token-Design.md` 一致。

| 层 | 类 | 本设计用到的值 |
| --- | --- | --- |
| Foundation | `YoSpace` | 2 / 4 / 6 / 8 / 12 / 16 / 24 / 32 / 40 / 48 / 64 vp。页面间距取 8vp 网格上的这些档 |
| Foundation | `YoSize` | 触控不小于 `TOUCH_TARGET_MIN`（48vp）。列表行 `LIST_ROW_HEIGHT`（56vp）。两行摘要 `LIST_CARD_HEIGHT`（72vp） |
| Foundation | `YoRadius` | 卡片 16vp，即 `MEDIUM`。不另写 16 |
| Foundation | `YoOpacity` | 按下 `PRESSED`（0.9）。禁用内容 `DISABLED_CONTENT`（0.38） |
| Foundation | `YoStroke` / `YoMotion` | 分割线与时长走已有常量，页面不写毫秒魔法数 |
| Semantic | `YoColor` | 见 [color-scheme.md](color-scheme.md) |
| Semantic | `YoTypeStyle` | 正文 `BODY_M` / `BODY_S`。标题用 `TITLE_S` 或页壳标题。地址、UUID、HEX、错误码用 `MONO_S` |
| Semantic | `YoResponsive` | `pageHorizontal(breakpoint)`、`SECTION_GAP`（16vp）、`CARD_GAP`（12vp）、`CONTROL_GAP`（8vp）、`CONTENT_MAX_WIDTH`（2220） |
| Component | `YoNavigationToken` | 侧栏 240vp，悬浮底栏边距 28vp，底留白 88vp，分栏 4:6 或终端 6:4，栏宽至少 280vp |
| Component | `YoListToken` | 长列表行间距与分割线 |
| Component | `YoButtonToken` / `YoSegmentToken` / `YoDialogToken` / `YoToastToken` / `YoChipToken` / `YoCardToken` | 只在对应组件内部使用 |

布局数字默认 vp。字号走 fp，随系统字体缩放。不用 px 写间距、行高或触控区。依据：`开发/API参考/应用框架/ArkUI（方舟UI框架）/ArkTS组件/公共定义/像素单位.md`，以及 `设计/设计指南/通用设计基础/视觉风格/间隔参数.md`。

## 密度

调试页一行要能判断下一步。主行一个名字加一枚状态胶囊。次行最多四个短事实。原始字节、完整 UUID、`reasonMsg` 进详情或半模态。缺字段留空，不写成 0。计数初值是例外，标签必须写「已发送」这类计数名，避免和缺字段混淆。

手机上主按钮 `fullWidth`。`YoSegmentButton` 不链式写宽度。

## 样例里的 Token 用法

[HarmonyOSComponentUXExamples](https://gitcode.com/HarmonyOS_Samples/HarmonyOSComponentUXExamples) 把间距和圆角放在 `commons/componentuxexamplesbase/src/main/ets/designtoken/`（`SpaceToken`、`PaddingToken`、`CornerRadiusToken`、`ColorToken`）。本工程对应物已经是 `YoSpace`、`YoResponsive`、`YoRadius`、`YoColor`。不把样例的 Token 类再引入一份。

## 状态胶囊目标色

屏幕只使用 `YoStatusPill`。不另做一套胶囊，不新增 `youi_*` 资源名。`YoStatusPill` 的成功字色是 `YoColor.SUCCESS`（`youi_success`），背景是 `YoColor.SUCCESS_CONTAINER`（`youi_success_container`）。警告同样走 `youi_warning` 与 `youi_warning_container`。容器资源是前景色的约 10% 透明（alpha `0x19`，即 25/255），铺在页面底 `youi_background` 上。

对比度按 `设计/设计指南/系统特性&能力/系统特性/深色模式.md`（来源 <https://developer.huawei.com/consumer/cn/doc/design-guides/dark-mode-0000001823255497>）。该文把辅助文本的优秀线定为大于 3:1，并写明分级来自 WCAG。计算用 WCAG 相对亮度：通道先线性化（`c/12.92`，或 `((c+0.055)/1.055)^2.4`），`L = 0.2126R + 0.7152G + 0.0722B`，对比度 `(L亮+0.05)/(L暗+0.05)`。8 位色先按 alpha 合成到页底，再算对比度。浅色页底 `#F1F3F5`，深色页底 `#191A1C`。深色还要避开该文的高对比不适区：文字对比度低于 15.7:1。

色相沿用当前资源，只改明度。落地时替换同名资源的色值，不改 `YoStatusPill.ets` 的取色分支。`youi_on_success_container`、`youi_on_warning_container` 今天与字色相同，替换时一起换成下表的目标字色。Kit 资源文件不在本 PR 修改。

### 待替换（当前 Kit，浅色）

| 语气 | 当前字色 | 当前容器 | 合成背景 | 对比度 |
| --- | --- | --- | --- | --- |
| 成功 | `#64BB5C` | `#1964BB5C` | `#E3EEE6` | 2.00 |
| 警告 | `#ED6F21` | `#19ED6F21` | `#F1E6E0` | 2.48 |

成功：字色亮度 0.390227，合成底亮度 0.831931，`(0.831931+0.05)/(0.390227+0.05) = 2.0034`。警告：字色亮度 0.294832，合成底亮度 0.806762，`(0.806762+0.05)/(0.294832+0.05) = 2.4846`。两条都落在该文「一般」（1.9:1–3:1），不是优秀。这是待替换值。

### 目标（浅色，大于 3:1）

| 资源 | 目标值 | 合成背景 | 对比度 |
| --- | --- | --- | --- |
| `youi_success` / `youi_on_success_container` | `#44923D` | `#E0E9E3` | 3.12 |
| `youi_success_container` | `#1944923D` | 同上 | 同上 |
| `youi_warning` / `youi_on_warning_container` | `#D45C11` | `#EEE4DF` | 3.15 |
| `youi_warning_container` | `#19D45C11` | 同上 | 同上 |

成功：字色 `#44923D` 亮度 0.221236，合成底 `#E0E9E3` 亮度 0.796712，`(0.796712+0.05)/(0.221236+0.05) = 3.1217`。警告：字色 `#D45C11` 亮度 0.216918，合成底 `#EEE4DF` 亮度 0.789917，`(0.789917+0.05)/(0.216918+0.05) = 3.1467`。都大于 3:1。

### 深色核过（沿用当前 Kit，不替换）

| 语气 | 字色 | 容器 | 合成背景 | 对比度 |
| --- | --- | --- | --- | --- |
| 成功 | `#5BA854` | `#195BA854` | `#1F2821` | 5.18 |
| 警告 | `#DB6B42` | `#19DB6B42` | `#2C2220` | 4.57 |

成功：字色亮度 0.308695，合成底亮度 0.019187，`(0.308695+0.05)/(0.019187+0.05) = 5.1844`。警告：字色亮度 0.259688，合成底亮度 0.017838，`(0.259688+0.05)/(0.017838+0.05) = 4.5651`。都大于 3:1，且低于 15.7:1。深色资源保持现状，作为目标值。
# Design Token

手机档。实现时映射到资源，本 PR 不改 `youi_kit`，不改 `color.json`。名字是规范名，不是 Kit 类名。

度量来自 `yohurm/HarmonyOS-Developer-docs`：

- 间隔：`设计/设计指南/通用设计基础/视觉风格/间隔参数.md`（4vp/8vp 网格；手机左右 16vp；卡片 12vp；有边界控件 16vp；无边界 8vp；主次文本上下 2vp、左右 8vp）
- 圆角：`圆角参数.md`（4 / 8 / 16 / 20 / 32vp）
- 字号：`文本排版.md` 手机列。工具界面最小用到 Caption_L 12vp，不用 Caption_M 10vp 做列表次行
- 列表行：`控件/容器类/列表.md` 效率型 48、56、64vp
- 底栏：`底部页签.md` 悬浮式 56vp，图标 24vp
- 热区：`触摸热区设置.md` 写明 API 26 起 Button、Toggle 的 Button 模式、Select、Chip 默认最小命中高度为 32vp。本应用主操作和列表行按设计指南做到更高，并用 `responseRegion` 保证图标按钮命中不小于 40×40vp

## 间距

| Token | vp | 用在 |
| --- | --- | --- |
| space.2 | 2 | 主行与次行 |
| space.4 | 4 | 色点与文字、胶囊内边 |
| space.8 | 8 | 无边界控件、图标与文字 |
| space.12 | 12 | 卡片之间、列表右侧元素与正文 |
| space.16 | 16 | 屏幕左右边距、有边界控件、sheet 内边距 |
| space.24 | 24 | 结果标题区与列表之间 |
| space.32 | 32 | 空态图示与按钮 |

## 圆角

| Token | vp | 用在 |
| --- | --- | --- |
| radius.4 | 4 | 状态胶囊、色点 |
| radius.8 | 8 | 列表内小图标底 |
| radius.16 | 16 | 内容卡、数据卡 |
| radius.20 | 20 | 按钮、Select、TextInput。高度 40vp 时呈胶囊，与 wifi 选择字段一致 |
| radius.32 | 32 | bindSheet、AlertDialog、CustomDialog |

同一层级只用一档。不把卡片做成 20、按钮做成 16。

## 字号（手机）

| Token | 对应 | 字重 | vp |
| --- | --- | --- | --- |
| type.title.m | Title_M | Bold | 24 |
| type.title.s | Title_S | Bold | 20 |
| type.subtitle.m | Subtitle_M | Medium | 16 |
| type.subtitle.s | Subtitle_S | Medium | 14 |
| type.body.l | Body_L | Medium | 16 |
| type.body.m | Body_M | Regular | 14 |
| type.body.s | Body_S | Regular | 12 |
| type.caption.l | Caption_L | Medium | 12 |

扫描结果标题用 type.title.m。页标题走系统标题栏，不在内容区再放一个 Title_L。数据卡上的数字用 type.title.s。日志行用 type.body.s。

字体是 HarmonyOS Sans。十六进制和计数值加 `fontFeature` `tnum`。

## 尺寸

| Token | vp | 用在 |
| --- | --- | --- |
| touch.40 | 40 | 文字按钮、图标按钮、Select、页签的最小高度。图标视觉可以是 24，命中用 responseRegion 扩到 40 |
| row.48 | 48 | 单行设置、侧栏项、日志行 |
| row.56 | 56 | 带一行辅文的设置 |
| row.64 | 64 | 扫描结果、WLAN 列表（主行 +「加密」或地址） |
| icon.24 | 24 | 列表主图标、底栏图标 |
| icon.16 | 16 | 行内锁、信息 |
| bar.56 | 56 | 窄屏悬浮底栏 |
| sheet.pad | 16 | sheet 内容边距 |
| detail.label | 8 | 详情里空值灰条的高度 |

## 颜色角色

不写死十六进制。浅色资源与深色资源成对，规则见 [color-scheme.md](color-scheme.md)。

| 角色 | 界面 |
| --- | --- |
| canvas | 页面底。截图里是灰底，卡片是白的。对应二级背景，不是卡片色 |
| surface | 列表组、输入框、数据卡 |
| text.primary | 主行、结果标题 |
| text.secondary | 辅文、详情标签、未选中页签 |
| text.disabled | 禁用行 |
| brand | 一颗主按钮的填充、文字按钮、选中页签、当前底栏项 |
| on.brand | 主按钮上的字 |
| status.success / warning / error / info | 胶囊字色。胶囊底用对应的浅容器色，圆角 radius.4 |
| scrim | 半模态遮罩 |
| divider | 组与组之间。行与行能靠 8vp 间距分开时不加线 |

状态胶囊只有这四色加中性（中性用 text.secondary，底用 canvas）。不为每种协议加一种颜色。

## 按下、禁用

主按钮用系统 `Button` 的 EMPHASIZED，按下和禁用走控件自带状态，不另画一层。列表行按下时表面叠一层按压色（仍是 surface 的按下资源），松手恢复。禁用行：文字 text.disabled，尾部按钮 `enabled` false，不响应按下。
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
