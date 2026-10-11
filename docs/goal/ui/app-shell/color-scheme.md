---
id: ui.app-shell.color
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/design-tokens.md
  - common/youi_kit/src/main/resources/base/element/color.json
  - common/youi_kit/src/main/resources/dark/element/color.json
  - common/youi_kit/src/main/ets/components/containers/YoStatusPill.ets
---

# 深浅色

深色与浅色使用同一套资源名。`common/youi_kit/src/main/resources/base/element/color.json` 与 `dark/element/color.json` 各 40 个 `youi_*` 颜色，名称集合相同。页面写 `YoColor.*`，不写十六进制，不在特性模块再放一份色表。

依据：`设计/设计指南/系统特性&能力/系统特性/深色模式.md`（来源 <https://developer.huawei.com/consumer/cn/doc/design-guides/dark-mode-0000001823255497>）。原则是易读、暗环境不过亮、浅色和深色的层级与语义一致。色彩总述见 `设计/设计指南/通用设计基础/视觉风格/色彩.md`。

## 语义

| 语气 | Token | 只用在 |
| --- | --- | --- |
| 成功 | `SUCCESS` / `SUCCESS_CONTAINER` | Kit 确实返回成功。模拟器未测、缺口、待证不用 |
| 警告 | `WARNING` / `WARNING_CONTAINER` | 缺口、未通过、配对进行中、网络阻塞 |
| 错误 | `ERROR` / `ERROR_CONTAINER` | 拒绝、超时、服务停止、平台错误码 |
| 信息 | `INFO` / `INFO_CONTAINER` | 进行中：发现中、扫描中、回连中 |
| 中性 | `TEXT_SECONDARY` 字，`BACKGROUND_SECONDARY` 底 | 空闲、未读取、未配对 |
| 按下 | `INTERACTIVE_PRESSED` | 行按下。松手恢复。禁用行不进入按下 |
| 选中 | `SURFACE_SELECTED` | 侧栏选中、当前列表行 |
| 页底 / 卡片 / 输入 | `BACKGROUND_PRIMARY` / `SURFACE_CARD` / `SURFACE_INPUT` | 页面、卡片、`TextInput` |

深色下语义色相保持，明度用 dark 资源里的同名色。不在深色页保留大面积白底。

## 对比度（本轮计算，未上真机）

计算方式：8 位色先按 alpha 合成到页面底，再算对比度。浅色页底 `#FFF1F3F5`，深色页底 `#FF191A1C`。

| 组合 | 对比度 | 对照辅助文本「优秀大于 3:1」 |
| --- | --- | --- |
| 浅色正文 `youi_text_primary` 对页底 | 15.81 | 正文优秀（大于 4.5:1） |
| 深色正文 `youi_text_primary` 对页底 | 14.21 | 深色舒适区间内（低于 15.7:1 的高对比上限） |
| 浅色次文 `youi_text_secondary` 对页底 | 5.58 | 优秀 |
| 浅色成功胶囊：当前 Kit `#64BB5C` 字对 10% 成功容器 | 2.00 | 待替换。落在「一般」（1.9–3） |
| 浅色警告胶囊：当前 Kit | 2.48 | 待替换。一般 |
| 浅色成功目标 `#44923D` 对合成底 `#E0E9E3` | 3.12 | 辅助文本大于 3:1 |
| 浅色警告目标 `#D45C11` 对合成底 `#EEE4DF` | 3.15 | 辅助文本大于 3:1 |
| 深色成功：当前 Kit `#5BA854`，核过，保持 | 5.18 | 大于 3:1，且低于 15.7:1 |
| 深色警告：当前 Kit `#DB6B42`，核过，保持 | 4.57 | 大于 3:1，且低于 15.7:1 |
| 浅色错误胶囊 | 3.19 | 辅助文本达到优秀 |
| 深色错误胶囊 | 3.73 | 辅助文本达到优秀 |

`YoStatusPill` 把字色设成 `SUCCESS` / `WARNING` / `ERROR`，背景设成对应 10% 容器（`YoStatusPill.ets`）。浅色成功、警告的当前资源是待替换值。目标色、前景、合成背景和算式写在 [design-tokens.md](design-tokens.md)。不新造资源名，不在特性页复制第二套胶囊。页面继续只用 `YoStatusPill`。替换 `color.json` 留给实现阶段，不在本设计 PR。

禁用色 `youi_text_disabled` 按深色模式文档不必满足正文对比。

## 无障碍

屏幕朗读依据：`开发/指南/…/无障碍与适老化/无障碍开发指导.md`。

`YoStatusPill` 设置了 `accessibilityLevel('no')`，胶囊自己不会被朗读。列表行和入口卡必须在行上 `accessibilityGroup(true)`，`accessibilityText` 拼上名称、关键事实和胶囊文案。`YoModeEntryCard`、`YoActionButton`、`ClassicDeviceCard` 已经这样写。新行照此办理，不依赖胶囊自身发声。

触控不小于 48vp。焦点顺序与视觉顺序一致：状态、主操作、列表。图标按钮带文字或朗读标签。

本阶段没有页面实现，没有真机朗读记录。
# 深浅色

跟随系统。不在更多里做「强制浅色」开关，除非设置契约以后单列该项。设置页可以有主题行，但存储键未进 `main` 前，行的值显示「未读取」，见设置屏。

## 浅色

页面 canvas 是灰，卡片和输入是 surface 白。这是 wifi 选择组件和 WLAN 列表的关系：字段浮在灰底上，而不是整页纯白再加阴影。卡片只用圆角和表面色区分，不加阴影（ui-design-brain：阴影和描边二选一；此处用表面色差，不加描边）。

主按钮填充 brand，字 on.brand。文字按钮只有 brand 字色，没有灰底。

## 深色

`设计/设计指南/系统特性&能力/系统特性/深色模式.md`：

- 背景改深色，前景改浅色。不保留大块白色卡片。
- 非大字号正文与背景，深色模式优秀线大于 5:1。列表次行、Caption、功能图标优秀线大于 3:1。
- 可点控件的填充与页面背景不低于 2.2:1。主按钮因此不能用和 canvas 太接近的蓝。
- 正文对比度不要超过 17.6:1，避免暗环境刺眼。
- 成功、警告、错误、信息保持色相，只调明度。深浅色的「已连接」必须仍是成功色，不能一边绿一边蓝。
- 不出现浅色页和深色页夹杂。sheet 与背后页面同一套深色表面，sheet 比页面亮一档以表达层级。

资源放在深色限定词目录，与浅色同名。本 PR 不提交色值文件。

## 状态在两种模式下都要看得见

胶囊的字与胶囊底之间同样满足辅助文本大于 3:1。禁用文本可以低于该线（设计指南允许 disable 例外），但禁用按钮的形状还在，不只靠颜色。
# 浅色与深色

来源：D2「同名 Token，浅色与深色数值可以不同」；ibest-ui-v2 用 `resources/dark/element/color.json` 覆盖同名颜色，不在组件里写死 `#fff` / `#000`。BluetoothLowEnergy 把卡片写成 `Color.White`、把页面写成 `#F1F3F5`，本文只保留 `#F1F3F5` 作为浅色 `background_secondary`，卡片改 `comp_background_primary`。

跟随系统 `ColorMode`。设置里可以选浅色、深色、跟随系统，三个选项都只切换资源限定符，不复制一套组件。

深色画布是 `background_secondary` `#191A1C`。主按钮仍是 `brand`，深色为 `#317AF7`，字保持 `font_on_primary`。`warning` / `alert` / `confirm` 换深色表中的对应值，色相不变。

按下叠 `interactive_pressed`。禁用把文字降到 `font_fourth`，主按钮改为 `comp_emphasize_tertiary`，不另画灰色 Material 按钮。

分割线只用 `comp_divider`。不在深色里把分割线改成纯白实线。
