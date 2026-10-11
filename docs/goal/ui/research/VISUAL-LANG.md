---
id: yowire.ui.research.visual
type: topic-study
status: active
when: research
---

# 视觉语言

色彩服务 [IA-NAV.md](IA-NAV.md) 的三类页面：看板要读数，调试页要看清当前对象，设置页要安静。不单独做一套品牌皮肤。

## 色彩

使用 HarmonyOS NEXT 语义 token，浅色与深色同一套名字、不同数值。出处：[色彩](https://developer.huawei.com/consumer/cn/doc/doccenter-ux-design/color-0000001776857164)。

| Token | 浅色 | 用在哪 |
| --- | --- | --- |
| `brand` / `comp_background_emphasize` | `#ff0a59f7` | 每屏唯一的主按钮、底栏或侧栏的选中项、焦点指标的强调 |
| `background_secondary` | `#fff1f3f5` | 页面底 |
| `comp_background_primary` | `#ffffffff` | 卡片与列表行 |
| `font_primary` → `font_fourth` | `#e5000000` 起逐级降低 | 数字、标题、单位、元数据 |
| `warning` | `#ffe84026` | 失败与关射频 |
| `alert` | `#ffed6f21` | 降级、节流、未采样以外的注意 |
| `confirm` | `#ff64bb5c` | 链路已连接、诊断步骤通过 |

深色 `brand` 为 `#ff317af7`，`background_secondary` 为 `#ff191a1c`。文档写明系统色最小对比度 3:1，反色 `font_on_*` 只放在强调底上。

宇宙蓝是强调，不是大面积底。interface-design 的比例是大约 60% 中性表面、30% 次级、10% 强调色（SKILL.md，Distribution and restraint）。ui-design-brain 要求中性色打底、一个强调瞬间，并禁止无意义的彩虹徽章（SKILL.md，Core Principles 与 Anti-Patterns）。状态色必须配文字或图标，ui-ux-pro-max 的 `color-not-only` 写的是同一条（`quick-reference.md`）。

不从组件库或商城模板另取一套主色，也不改用 Material 色板。ibest-ui-v2（HEAD `286a3e0`）只借鉴组件分工：`empty`、`skeleton`、`segmented`、`cellGroup`、`tree`、`swipeCell`、`noticeBar`。本次没有把它的色值表当作 token 来源，界面颜色仍映射到上表。

## 密度与层级

调试工具用紧密度：卡片内边距 12–16vp。interface-design 写明工具面板用这个区间，24px 会像宣传页。同一页里相关控件间距小，组与组之间间距大，避免每张卡片一样大（同文 Monotone layout）。

一页一个焦点。看板上是最高告警或活跃会话数。发现页上是扫描状态。终端上是最新一行。诊断运行页上是本次结果的大数字，结构参考测速结果（[evidence/net-speed-phone.png](evidence/net-speed-phone.png)），只用于 `NW-DIAG-RUN`。

数字使用等宽对齐。标签用 `font_secondary`，单位用 `font_tertiary`。正文不小于 14fp；ui-design-brain 写最小 14px、优先 16px。触控热区不小于 44vp × 44vp。

标题用系统字体的字重区分层级，不引入展示字体。四层文本 token 已经提供层级，不必再靠字号堆砌。

## 与页面种类的对应

| 种类 | 表面 | 强调色出现的位置 |
| --- | --- | --- |
| 看板 | 雪域灰底，白色指标块 | 焦点数字；选中的底栏项 |
| 发现 | 列表卡片 | 底部「开始/停止」；行内连接用次级胶囊，不用品牌色实心铺满 |
| 终端 | 记录区接近纯色，输入区固定在底部 | 发送按钮 |
| 树与键值 | 分组列表 | 当前选中节点的 `interactive_select`（浅色 `#330A59F7`） |
| 图表 | 折线用 `brand`，失败点用 `warning` | 不给每条序列一种装饰色。多序列用实线/虚线加直接标签（`charts.csv` 第 1 行） |
| 设置 | `ItemGroup` 分组，行高一致 | 开关的系统强调色。设置页没有第二颗品牌色大按钮 |
| 空态与阻断 | 内容区居中 | 一颗主按钮。宽屏不另做一套插画 |

加载骨架的色块用 `comp_background_tertiary`，形状与最终数字、行的位置一致。

## 图表

| 数据 | 图形 | 依据 |
| --- | --- | --- |
| RSSI、失败次数、通知值，时间轴且不少于 4 点 | 折线 | `charts.csv` 第 1 行；qCharts `LineChart`；BLE 示例用 `Canvas` 画心率折线 |
| 信道上的 AP 数量 | 柱 | `charts.csv` 第 2 行，类别不超过 15 |
| 一次诊断相对阈值 | 大数字 + 步骤清单 | 测速组件的结果结构。没有阈值时不画仪表 |
| 占比 | 默认不用 | `DataPanel` 与环图都是占比。射频读数不是占比 |

柱和折线的选中点能点到对应的 AP 或日志行，这是下钻，不是图例装饰。

## 动效

扫描中的状态写在发现页的状态条上，用进度或「正在发现」文案，不在模块板上放雷达动画。半模态用系统档位，关闭需能回到父页面。列表增删沿用系统过渡。不把工厂模板的深色仪表或健康模板的插画搬进来。

## 宽屏

侧栏 240vp，与 `multi-nav-bar` 的 `sideBarWidth(240)` 一致。这个宽度表示导航服务于内容（interface-design 用约 280px 表达同一关系；这里取官方示例的 240vp，避免侧栏和内容变成两个同等入口）。分割线用 `comp_divider`，不用粗描边。
