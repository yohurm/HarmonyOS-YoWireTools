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
