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
