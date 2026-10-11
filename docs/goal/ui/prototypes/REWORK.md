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
# YoWire 高保真原型

这一版按华为工具库调研重画，从 `main` 新开。不沿用 PR #19 的文案规范，也不沿用 PR #22 或信息架构草图的视觉。旧稿把三种无线做成多套导航；这里只有一个手机外壳、一条页面栈。

## 调研里实际看过的界面

材料是 2026-10-10 的工具库目录和随附截图。视觉只取布局，不抄产品名和品牌插画。

| 参考 | 截图里看到的 | 落到原型 |
| --- | --- | --- |
| wifi 扫描选择组件 | 浅灰圆角输入、眼睛图标、居中蓝色胶囊「下一步」 | `phone/wifi-connect.svg` |
| 蓝牙扫描组件 | 大标题「搜索成功」、副标题、雷达、蓝色文字「重新搜索」、下面才是设备列表 | `phone/bt-scan-*.svg`、`phone/nl-scan-*.svg` |
| WLAN 信息查询 | 左列表（已连接 / 可用）右详情（标签左、值右）；行尾是信息图标，不是彩色徽章 | `phone/wifi-list-*.svg`、`phone/wifi-detail.svg`、`wide/wifi-split.svg` |
| NetworkQuery | 连接、状态、定位、故障是同一网络工具里的场景 | 诊断页只保留当前网络和检测结果 |
| 智慧家居模板 | 浅灰底、白卡片、底部四栏、设置是分组列表加开关 | 首页 / 调试 / 控制台 / 我的 |
| 终端控制台 IKConsoleKit | 日志、网络、存储分成控制台里的页签 | 控制台页签：日志 / 网络 / 命令 |
| BluetoothLowEnergy | 样例把心率做成大数字卡片 | 不照搬心率。BLE / SSAP 用同一套列表行展示服务 |

FastBle 那一页是库说明，没有可对照的界面，所以没有拿来画。

## 设计技能怎么用

- https://github.com/carmahhawwari/ui-design-brain  
  先点组件再画：底栏是 Navigation，扫描和 WLAN 是 List，连接是带一个主按钮的表单，失败和无权限是页内说明加一个动词按钮，控制台页签是 Tabs，空列表留在原位。方向用工具密度，不是宽松营销页。避开彩虹徽章、套两层弹窗、没有解释的灰按钮、整页转圈、宽屏汉堡、只有占位符的输入框、两个同样重的按钮。
- https://github.com/JimLiu/baoyu-design  
  高保真以这次调研为设计上下文，不从空白风格起稿。交付按任务指定为静态 SVG/PNG，所以没有做可点击 HTML。中文用文泉驿微米黑。正文字号不小于 14，UUID 用 12。

## 导航

底栏四项是外壳，不是三套无线导航：首页、调试、控制台、我的。蓝牙、Wi-Fi、星闪是调试页里的三行，点进去都压在同一条栈上，带返回。宽屏只补了 Wi-Fi 的列表加详情，对应官方并排预览，没有另做侧栏导航。

## 怎么看

同名 PNG 可在 PR 里直接打开。路径对照见 `README.md`。
