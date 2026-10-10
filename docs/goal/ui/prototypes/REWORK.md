# YoWire 原型返工（高保真暂停）

定稿级高保真先停。用户要求对照更多官方样例和高星开源之后再画，禁止靠少数几个市场组件铺完整原型。本目录现在只有信息架构草图。颜色、行高、圆角、标题栏形态、列表还是宫格，都还没有选定。

和已作废的 PR #19、PR #22 的差别：那两套稿不再作为设计依据；这里也不把蓝牙、星闪、Wi-Fi 做成三套导航再拼起来。

## 先等的调研

下面三块到齐之前，不出高保真。

1. 华为开发者工具库截图（https://developer.huawei.com/consumer/cn/market/prod-list?fromNav=toolLibrary）。用户稍后转发。到达前不写「已看过哪些工具 App、密度如何」这类结论。
2. 扩大后的官方样例包。除组件库以外，还要有更多 ArkUI 页面样例（LayoutSample、BindSheet 示例工程、导航与列表的完整页面，而不是单个控件）。
3. 高星开源工具类界面。用来对照扫描列表、终端、命令面板、日志和设置的信息架构，而不是只看鸿蒙组件橱窗。

## 已经读过、但不够定稿的材料

这些只证明「官方组件长什么样」，不能单独支撑整 App 视觉。

- https://github.com/carmahhawwari/ui-design-brain  
  通读 `SKILL.md`，以及 `components.md` 的 Alert、Badge、Button、Drawer、Empty state、Header、List、Modal、Navigation、Search、Segmented control、Skeleton、Tabs、Text input、Toast、Toggle。四步流程（点名组件、最佳实践、选定方向、再产出）留到高保真阶段执行。本轮只借用其中和结构有关的约束：主导航条目要少、空态和错误态要有位置、半模态不套半模态。
- https://github.com/JimLiu/baoyu-design  
  通读 `skills/baoyu-design/SKILL.md`、`system-prompt.md` 的流程与内容规范、`references/cursor.md`、`project-types.json`、`built-in-skills/hi-fi-design.md`、`mobile-prototype.md`、`interactive-prototype.md`、`wireframe.md`。高保真和可点击原型按新要求推迟。本轮按 `wireframe.md`：先画结构，低保真，关键岔路并列，不假装已经选定。
- https://gitcode.com/HarmonyOS_Samples/HarmonyOSComponentUXExamples  
  提交 `257ef5976ca1f979bb4d30977c8d168cd0d960f9`。读过手机 `Index.ets`（一个 `HdsNavigation`，宽屏 `navBarWidth` 40%）、`BreakpointModel.shouldHideBackButton`、列表 / 标题栏 / `bindSheet` / `NoNetworkView`、设计 token，以及仓库自带的 `screenshots/phone.png`（副本在 `references/harmonyos-component-ux-phone.png`）。这是组件橱窗，不是工具类 App。
- 打开过、未整库克隆：LayoutSample 目录页、bindSheet 接口说明、ArkUI `examples/BindSheet` 目录页。页面结构还没逐文件对照，所以不能当视觉依据。

## 信息架构（任务已限定，草图按此画）

一个 App，一个根 `Navigation`，一个 `NavPathStack`。窄屏用栈，宽屏用同一套目的地分栏。返回逐级弹出。没有底部三栏，也没有每个无线模块各自的导航栈。

```text
工作台（导航栏内容）
├── 蓝牙
│   ├── 经典蓝牙 → 配对半模态 → 连接半模态 → SPP 终端
│   └── BLE → GATT → BLE 串口
├── Wi-Fi
│   ├── 环境（AP、信道）
│   ├── 诊断
│   ├── 协议
│   └── 局域网发现
├── 星闪
│   ├── 扫描
│   ├── SSAP
│   └── dataTransfer
├── 命令面板
├── 日志 → 会话详情
└── 设置
```

产品任务（工作台、命令、日志、设置，以及三条无线链路的关键页）决定「有哪些页」。页面内部用列表、宫格还是半模态，草图里标成未选定。

## 草图里故意不选定的岔路

- 工作台模块入口：分组列表，或宫格。见 `ia/workbench.svg`。
- 命令面板：整页目的地，或半模态。见 `ia/command.svg`。
- 宽屏导航栏宽度：组件示例是 40%，工程常量还有 240vp 和 4:6。草图只标明「同一侧栏」，不标具体宽度。见 `ia/wide.svg`。

空、错、无权限不各画一套高保真。`ia/list.svg` 标明这三态出现在列表内容区，标题栏保持不动。

## 图的规格

草图画布是结构图，不是手机效果图。灰盒、实线分区、中文标签。角上写「信息架构草图 · 非高保真」。PNG 由 SVG 导出，方便在 PR 里直接看。路径对照见 `README.md`。
