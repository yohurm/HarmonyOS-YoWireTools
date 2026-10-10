---
id: research.yowire-ui-studies
type: project-study
status: active
when: research
studied_at: 2026-10-10
---

# 单项目阅读记录

每节对应一个已克隆仓库。克隆路径均在 `/tmp/YoAgentResearch/`。未读的文件不写入结论。

## harmonyos_samples/network-query

- 地址：<https://gitee.com/harmonyos_samples/network-query>，HEAD `42c7516`
- 入选：网络调试的目的地拆分。
- 读过：`entry/src/main/ets/pages/Index.ets` 全文；`NetworkDiagnostics.ets` 的结构检索（重新查询按钮在约第 307 行）。
- 架构：一个 `Navigation` + `NavPathStack`。首页四颗按钮推入 `WifiConnector`、`NetworkMonitor`、`WlanLocation`、`NetworkDiagnostics`。背景用 `sys.color.background_secondary`。
- 利用：四个目的地类型分别对应连接、感知、定位、排障。YoWire 将排障收成 `NW-DIAG-RUN` 的步骤，不保留四颗按钮。
- 不要用：首页按钮列表。

## harmonyos_samples/wlan-info-query

- 地址：<https://gitee.com/harmonyos_samples/wlan-info-query>，HEAD `a114aba`
- 读过：`pages/Index.ets` 的列表与 `getScanInfoList` 路径；`DetailInfoView.ets` 确认为独立详情结构。
- 架构：`Navigation` 内 `List` 展示扫描结果，按 SSID 去重，失败写日志错误码。详情是另一视图。
- 利用：AP 列表进详情，详情是键值。对应 `NW-SPECTRUM` 与 `NW-AP-DETAIL`。
- 不要用：把扫描列表当作网络模块的根页。

## harmonyos_samples/BluetoothLowEnergy

- 地址：<https://gitee.com/harmonyos_samples/BluetoothLowEnergy>，HEAD `0f169cc`
- 读过：`pages/Index.ets`（`Navigation` + `NavigationMode.Stack`）；`BluetoothClientView.ets` 的列表、搜索按钮、胶囊连接；`HeartRateGraph.ets` 使用 `CanvasRenderingContext2D`。
- 架构：客户端与服务端分视图。设备行推进心率页，心率用 Canvas 折线，不画在列表头上。
- 利用：发现页 C3 与曲线页分离。对应 `BT-BLE-SCAN` 与 `BT-NOTIFY-CURVE`。
- 不要用：把「列表 + 底部搜索」同时用作蓝牙首页。

## harmonyos_samples/multi-nav-bar

- 地址：<https://gitee.com/harmonyos_samples/multi-nav-bar>，HEAD `a9a49a9`
- 读过：`BreakpointType.ets` 全文结构；`Home.ets` 中 `xl` 分支与 `Tabs` 分支；`SideBarView.ets` 的组件名。
- 架构：`xl` 使用 `SideBarContainer` 嵌入，`sideBarWidth` 240，`autoHide(false)`。其他断点用 `Tabs`，`lg` 时 `BarPosition.Start`，否则 `End`。
- 利用：`WD-SHELL` 的断点与宽度。
- 不要用：示例里的视频分类内容，以及在底栏之内再套一层目的地 Tabs。

## harmonyos_samples/NavigationSettings

- 地址：<https://gitee.com/harmonyos_samples/NavigationSettings>，HEAD `4349e44`
- 读过：`products/default/.../Index.ets`；`SettingList.ets` 的 `SearchBox` 与多个 `ItemGroup`。
- 架构：`NavigationMode` 在非 `sm` 时为 `Split`，否则 `Stack`。设置项按组，组内有开关、箭头、WLAN 子页。
- 利用：`SET-ROOT` 与 C11。
- 不要用：把系统设置里的 WLAN 入口理解成 YoWire 的网络调试首页。

## harmonyos_samples/navigation-router

- 地址：<https://gitee.com/harmonyos_samples/navigation-router>，HEAD `6f81cde`
- 读过：`RouterModule.ets`。`registerBuilder`、`createRouter`、`push` 把 `builderName` 推入对应 `NavPathStack`。HAR A/B/C 各有自己的页面文件。
- 利用：蓝牙、网络、星闪 HAR 只登记路由，不互相引用界面。
- 不要用：为每个 HAR 再做一套底栏。

## harmonyos_samples/nearlink-kit_-sample-code

- 地址：<https://gitee.com/harmonyos_samples/nearlink-kit_-sample-code>，HEAD `d211493`
- GitCode 对照：<https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code>，`ls-remote` 的 `master` 为 `f70be9b`。页面阅读以 Gitee 克隆为准。
- 读过：`MainPage.ets` 的按钮与列表结构。页面文件还有 `ScanConfigPage.ets`、`SsapPage.ets`、`SsapClientPage.ets`、`SsapServerPage.ets`。
- 架构：`MainPage` 同时放广播开关、开始扫描（推入扫描配置）、停止扫描、SSAP 按钮和扫描结果 `ListItemGroup`。SSAP 在独立页。
- 利用：扫描配置、客户端、服务端必须分页。
- 不要用：`MainPage` 这种按钮加列表的演示首页。Codelab 仓库同结构，已落选。

## harmonyos_samples/list-exchange

- 地址：<https://gitee.com/harmonyos_samples/list-exchange>，HEAD `bad3f1e`
- 读过：`Index.ets` 中 `swipeAction` 与 `onMove`。
- 利用：知道系统列表能侧滑和拖拽。
- 不要用：日志流的主操作做成删除。

## harmonyos_samples/PureTabs

- 地址：<https://gitee.com/harmonyos_samples/PureTabs>，HEAD `49e12dd`
- 读过：文件清单 `OutTabsComponent.ets`、`InTabsComponent.ets`、`SelectTabsComponent.ets`。未逐行阅读每个 view 的视觉参数。
- 利用：页签适合内容分类，可以嵌套，但嵌套之后仍是同一任务的视图。
- 不要用：底栏再套一层 `Tabs` 当第二导航。

## harmonyos_samples/custom-dialog-selection-and-development

- 地址：<https://gitee.com/harmonyos_samples/custom-dialog-selection-and-development>，HEAD `d448e79`
- 读过：页面文件划分 `PrivacyDialog.ets`、`CommentList.ets`、`AgreementPage.ets`、`NavigationDialog.ets`；`Index.ets` 使用 `promptAction`。
- 利用：确认、列表、协议分页，Toast 与对话框分开。对应 C13 里「对话框 / 半模态 / Toast」的分工。
- 不要用：一个弹层里做完连接、过滤和导出。

## HuolalaTech/hadice

- 地址：<https://github.com/HuolalaTech/hadice>，HEAD `ff3b9a9`
- 读过：`frontend/src/pages` 的文件名；`DeviceOverviewPage.tsx` 的指标栅格与 `Card`；`PerformanceMonitorPage.tsx` 的图表导入（CPU、内存、网络、FPS、电池等独立图表组件）。
- 架构：总览、性能、网络抓包、HDC Shell、文件传输是不同页面。总览展示内存、UDID 和进度，不提供「进入某工具」的宫格。
- 利用：看板上的读数块；曲线与终端分离。
- 不要用：桌面端多列卡片的具体业务（安装应用、抓包）和它的深色控制台皮肤。

## ibestservices/ibest-ui-v2

- 地址：<https://github.com/ibestservices/ibest-ui-v2>，HEAD `286a3e0`
- 读过：`library/src/main/ets/components` 目录名。未逐页阅读 82 个 demo。
- 架构：空态、骨架、分段、单元格组、树、侧滑、通知条、标签页各自目录。
- 利用：这些职责应对到 C3、C7、C9、C11、C12，而不是合成一个 List 壳。
- 不要用：该库的品牌色。

## qingkouwei/qcharts

- 地址：<https://github.com/qingkouwei/qcharts>，HEAD `27c3278`
- 读过：`README.md` 的图表种类与交互（缩放、点击提示、折线、柱、饼、仪表）。
- 利用：RSSI 与失败趋势用折线并支持点选；信道用柱。仪表组件存在，但只在「单指标对目标」时考虑，工作台不使用。
- 不要用：3D 柱、玫瑰图、漏斗。Star 很低，只借鉴图表类型选择，不把它当视觉规范。

## carmahhawwari/ui-design-brain

- 地址：<https://github.com/carmahhawwari/ui-design-brain>，HEAD `38f04c5`
- 读过：`SKILL.md` 的原则、状态和 Anti-Patterns。
- 利用：一个强调色；空态要有标题和主按钮；可预期布局用骨架且晚于 300ms；禁止彩虹徽章、模态套模态、等重按钮。
- 不要用：它默认的 SaaS 营销气质和「展示字体 + 正文」配对。YoWire 用系统字体和语义 token。

## DammyJay93/interface-design

- 地址：<https://github.com/DammyJay93/interface-design>，HEAD `2f9be32`
- 读过：`.claude/skills/interface-design/SKILL.md` 的层级、密度、避免清单。
- 利用：一页一个焦点；指标用小标签加大数字；工具密度 12–16px；60/30/10；侧栏宽度表达「导航服务于内容」；禁止每张卡片一样大。
- 不要用：为调试工具另起一套「温暖」或「交易终端」皮肤。密度取紧，色彩取系统 token。

## nextlevelbuilder/ui-ux-pro-max-skill

- 地址：<https://github.com/nextlevelbuilder/ui-ux-pro-max-skill>，HEAD `50d8a7d`
- 读过：`src/ui-ux-pro-max/data/charts.csv` 第 1–8 行；`templates/base/quick-reference.md` 中 `color-not-only`。未运行它的检索脚本，也未通读全部 CSV。
- 利用：时间用折线（少于 4 点用数字）；类别用柱；占比才用环图且不超过 5 类；仪表仅用于单 KPI 对目标；颜色不能是唯一编码。
- 不要用：CSV 里推荐的 Web 图表库（Chart.js 等）。HarmonyOS 侧用 ArkUI Canvas 或 qCharts 一类原生实现，那是实现 Goal 的选择，本总纲不指定依赖。

## JimLiu/baoyu-design

- 地址：<https://github.com/JimLiu/baoyu-design>，HEAD `6530033`
- 读过：`skills/baoyu-design/built-in-skills/wireframe.md` 开头。该技能要求先出多种低保真结构再承诺方向。
- 利用：本总纲只定一种信息架构，因为用户已经否决入口首页和换皮。多样探索留在各模块 Goal 的页面内部，不回到「宫格还是列表」的工作台选择。
- 不要用：把线框技能理解成可以再交一版入口首页。

## pbakaus/impeccable

- 地址：<https://github.com/pbakaus/impeccable>，HEAD `d631a88`
- 读过：`skill/reference/critique.md` 中要求指出具体失败元素；`doctor.md` 的步骤标题。未把 24 条命令逐条映射到鸿蒙控件。
- 利用：审查时点名哪一页又变成了入口或列表壳。
- 不要用：把它的 Web 视觉处方当成 HarmonyOS token 的替代。

## 工具库

目录：<https://developer.huawei.com/consumer/cn/market/prod-list?fromNav=toolLibrary>

截图与商品链接见 [EVIDENCE.md](EVIDENCE.md)。市场包多数不能 git clone，只读了画面。IKConsoleKit、FastBle、Wi-Fi 扫描组件的源码不在本次克隆里，不把它们写成已读实现。
