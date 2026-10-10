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
