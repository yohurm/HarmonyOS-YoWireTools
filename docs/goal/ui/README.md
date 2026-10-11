---
id: ui.index
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/QUALITY-GATE.md
  - docs/goal/ui/PHASE-C-DISPOSITION.md
  - docs/goal/ui/app-shell/README.md
---

# YoWireTools 界面设计

**不可进入大规模页面实现。** 依据是 [QUALITY-GATE.md](QUALITY-GATE.md)。文档写完不等于门禁通过。第 10、11、12、14 项仍阻塞。第一批原型在 [PR #22](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/22)，有图也不构成可以铺页面。

本目录是整 App 的 UI 设计。页面不调用 Kit。壳、Token、权限墙和深浅色只在 [app-shell](app-shell/README.md)。模块屏幕沿用 Phase-C 的行为，并补上布局、ArkUI 组件树、七态和编号追溯。旧文件怎么处置见 [PHASE-C-DISPOSITION.md](PHASE-C-DISPOSITION.md)。

特性包目录是 `features/wifi_network`。界面文档目录沿用 Phase-C 的 `wifi-network`，不另建 `docs/goal/ui/wifi_network/`。

## 可视化原型

第一批静态图在 [PR #22](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/22)（head `da7dcde`）的 `docs/goal/ui/prototypes/`，不在本 PR，这里不拷图。交付方是 UI 原型图 Goal，agent `bc-b0fee2c5-cd47-50ca-8063-a2e2089334a1`。

原型依据本目录的文字规范：各屏的布局、ArkUI 组件树、状态矩阵，以及 [app-shell](app-shell/README.md) 的 Design Token 和壳层。原型不另起一套布局或组件。门禁只核对两者一致。核对通过也不取消第 10、11、12、14 项。结论仍以 [QUALITY-GATE.md](QUALITY-GATE.md) 为准。
静态原型在 [prototypes/README.md](prototypes/README.md)。图按本目录的布局、文案和单根导航绘制，不是组件实现，也不另起一套壳。对上原型也不取消第 10–12、14 项。结论仍以 [QUALITY-GATE.md](QUALITY-GATE.md) 为准。

## 阅读顺序

| 顺序 | 路径 | 内容 |
| --- | --- | --- |
| 1 | [QUALITY-GATE.md](QUALITY-GATE.md) | 自检结论 |
| 2 | [PHASE-C-DISPOSITION.md](PHASE-C-DISPOSITION.md) | 旧 UI 规范保留、重做或合并 |
| 3 | [app-shell](app-shell/README.md) | 信息架构、导航、Token、权限墙、深浅色 |
| 4 | [workbench/home.md](workbench/home.md) | 工作台 |
| 5 | [workbench/command-panel.md](workbench/command-panel.md) | 命令面板 |
| 6 | [log/center.md](log/center.md)、[log/detail.md](log/detail.md) | 日志中心与详情 |
| 7 | [settings/hub.md](settings/hub.md) | 设置（更多） |
| 8 | [bluetooth/index.md](bluetooth/index.md) | 蓝牙各屏 |
| 9 | [nearlink/README.md](nearlink/README.md) | 星闪各屏 |
| 10 | [wifi-network/README.md](wifi-network/README.md) | Wi-Fi 与网络各屏 |

## 分层

UI 边界写在 [信息架构](app-shell/information-architecture.md)。方向来自未合并的架构 PR #6、#7、#8，不是本目录新做的一层。`main` 上还没有这些架构文件。
# YoWire 整 App 界面规范

本目录是从 `main` 起写的界面规范。不沿用 PR #19（`cursor/app-ui-design-2dc3`）的正文，也不沿用已关闭且未合并的 PR #22 里的图。Phase-C（PR #9、#10、#11）同样作废，不是合并底稿。

本规范只定界面。页面不调用 Kit。读数和动作都停在 ViewModel。路径对齐位是：UI → ViewModel/State → UseCase → RepositoryContract → DataSource/KitBridge → Kit。整机契约还没进 `main`，导航和状态模型只留对齐位，见 [QUALITY-GATE.md](QUALITY-GATE.md)。

没有原型图。第一批原型 PR #22 已关闭且未合并，不是本规范的底稿。可视化原型以后由 UI 原型图 Goal（`bc-b0fee2c5-cd47-50ca-8063-a2e2089334a1`）另交到 `docs/goal/ui/prototypes/`。不按旧 PNG 改规格，本 PR 不拷图。

**现在不可进入大规模页面实现。**

## 视觉语言从哪来

公开组件市场的 8 个参考（2026-10-10 浏览，不登录）。GitCode / AtomGit 返回 WAF 418，官方案例源码树没有读到，组件名只采用华为设计指南和 ArkUI 参考里能核到的。

| # | 参考 | 地址 | 本规范拿走的布局 |
| --- | --- | --- | --- |
| 1 | wifi 扫描选择组件 | https://developer.huawei.com/consumer/cn/market/prod-detail/b7e8c084fc214b80820ae31ba5ae9358/2adce9bbd4cb42d58a87e6add45594b3 | 连接 sheet：选择、密码、一颗「下一步」 |
| 2 | 蓝牙扫描组件 | https://developer.huawei.com/consumer/cn/market/prod-detail/f6bf602fb1224791ae5874a45e292728/2adce9bbd4cb42d58a87e6add45594b3 | 扫描列表：结果标题、图示、文字按钮「重新搜索」、设备列表 |
| 3 | WLAN 信息查询 | https://developer.huawei.com/consumer/cn/market/prod-detail/f722288166ec49cab512d9fef9efafe6/PLATFORM | list + detail：分组列表，详情是标签/值 |
| 4 | NetworkQuery | https://developer.huawei.com/consumer/cn/market/prod-detail/15e711a071a9441b9a9b52b185792124/PLATFORM | 场景 Tab：等宽文字页签切换内容 |
| 5 | 智慧家居应用模板 | https://developer.huawei.com/consumer/cn/market/prod-detail/0d7dd2239ce14a8e9fe8cfcde426d5ff/2adce9bbd4cb42d58a87e6add45594b3 | App shell：底栏图标+文字。不抄家居卡片和品牌 |
| 6 | 终端控制台 IKConsoleKit | https://developer.huawei.com/consumer/cn/market/prod-detail/11090518ae8147e9b12f9ab8fb5cf815/c5ef800e4cc6476ab179493aa30dff52 | 控制台日志：顶栏页签分日志/网络等 |
| 7 | FastBle | https://developer.huawei.com/consumer/cn/market/prod-detail/dca785c6dc1d458c8fd12568ecd78f05/PLATFORM | 过滤后再扫描、再连接。交付截图里没有 `fastble.png`，不把它的界面当成看见过 |
| 8 | BluetoothLowEnergy 通信 | https://developer.huawei.com/consumer/cn/market/prod-detail/c0b2e7a68718427eb7fa8ba0fd8afd00/PLATFORM | 设备数据竖卡：色点、数值、说明 |

市场站点本身是 SPA。类目接口 `product/productCategoryQuery` 与列表接口 `product/list` 能拉到目录；「组件 / 工具」一类有数百条。上表 8 条是对照过界面的，其余商品名不参与视觉。

Design Skill（交互规则，不替代 ArkUI 组件名）：

- [ui-design-brain](https://github.com/carmahhawwari/ui-design-brain)（核到约 893 star）：一个区域一颗主按钮，动词文案；空态带下一步；页签不宜多；状态标签词短、颜色少。Web 组件名（Modal、Drawer）映射到 `CustomDialog` / `bindSheet`，不直接写进组件树。
- [baoyu-design](https://github.com/JimLiu/baoyu-design)（核到约 4276 star）：层级、间距节奏、一个焦点操作。该 Skill 的产物是 HTML 原型。本规范不产出 HTML，也不画原型图。

官方度量见 `yohurm/HarmonyOS-Developer-docs`：`设计/设计指南/通用设计基础/视觉风格/间隔参数.md`、`圆角参数.md`、`文本排版.md`，`系统特性/深色模式.md`，`控件/容器类/列表.md`、`半模态面板.md`，`控件/导航类/底部页签.md`，`控件/操作类/按钮.md`，`布局/布局基础.md`，以及 ArkUI `触摸热区设置.md`、`Navigation基础架构介绍.md`。来源规则见 `yohurm/YoAgentDocs` 的 `instructions/rules/common/design-sources.md`：规范管状态和尺寸，仓库管实现。

## 目录

壳层：[app-shell/](app-shell/README.md)

| 模块 | 屏 |
| --- | --- |
| [workbench](workbench/home.md) | 工作台、命令面板 |
| [bluetooth](bluetooth/overview.md) | 概览、经典扫描、SPP 终端、BLE 扫描、GATT 详情 |
| [nearlink](nearlink/overview.md) | 概览、扫描、SSAP 客户端、端口数传 |
| [wifi-network](wifi-network/overview.md) | 概览、扫描、链路详情、诊断、Socket、HTTP、WebSocket、局域网发现 |
| [log](log/center.md) | 日志中心、日志详情 |
| [settings](settings/hub.md) | 更多（设置） |

屏名单对齐 `main` 上已有路由（`AppRoutes.ets`）和 `.projectark/5-架构设计/无线调试工具/00-总体架构与工程模块化设计.md` 第 7.2 节。第 7.2 节有、代码还没有的路由，在各屏文首标成目标路由。布局、Token、组件树、状态呈现是新写的。

## 编号

不新编 BT / NL / WN / WB / LOG / SET。要追溯时只指向未进 `main` 的 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) `docs/goal/citation.md`。整机契约只指向未进 `main` 的 [PR #21](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/21) `docs/goal/checklist/app.md` 与 `docs/goal/architecture/app/APP-001.md`–`APP-006.md`。
# YoWireTools 手机 UI 规范

本目录是整 App 的界面规范，从默认分支空白重写，并按工具库第二轮画面定稿。PR #19 已关闭未合并，旧稿作废，不是底稿。PR #22 同样已关闭未合并，不是底稿。门禁未过，不铺页面。

产品是一个手机 HAP（`product/phone`，包名 `com.yohurm.yowiretools`）。Wi‑Fi、蓝牙、星闪、日志、设置都在这一个壳里，不另起蓝牙或网络产品。界面不调用 Kit。数据只沿这条对齐槽往下走：UI → ViewModel/State → UseCase → RepositoryContract → DataSource/KitBridge → Kit。

## 不是底稿的东西

- [PR #19](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/19) 已关闭且未合并。旧 UI 稿作废，本目录不延续那条分支，也不粘贴旧组件树。
- 原型 PR #22 已关闭且未合并，不是本文的底稿。以后的图由界面原型目标交给 `docs/goal/ui/prototypes/`，作者目标 `bc-b0fee2c5-cd47-50ca-8063-a2e2089334a1`。本文不因旧图降低密度或改树。
- 更早的页面实现稿与薄市场稿同样作废。视觉以 [色彩 Token](app-shell/design-tokens.md) 为准。

## 先读

1. [QUALITY-GATE.md](QUALITY-GATE.md) — 结论仍是「不可进入大规模页面实现」。
2. [SOURCES.md](SOURCES.md) — 每个关键模式对应的仓库或官方文档。
3. [app-shell/](app-shell/README.md) — 壳、导航、色彩、密度、权限墙。
4. 各模块页：蓝牙、星闪、Wi‑Fi、工作台、日志、设置。

## 屏幕从哪来

已在 `main` 注册的路由（`product/phone` 的 `AppRoutes.ets`）可以当导航对齐槽：`/home/workbench`、`/bluetooth/overview`、`/bluetooth/spp`、`/bluetooth/spp/terminal`、`/bluetooth/ble`、`/wifi/overview`、`/nearlink/overview`、`/more/hub`。

`.projectark/5-架构设计/无线调试工具/00-总体架构与工程模块化设计.md` §7.2 另有扫描、详情、诊断、日志、设置等目标路由。那些名字可以当屏幕清单，不是已合并的整 App 契约。功能编号只追溯未合并的 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) `docs/goal/citation.md`。整 App 契约只追溯未合并的 [PR #21](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/21)。两者都不在 `main`，所以门禁保持拦住。本文不新造 BT/NL/WN/WB/LOG/SET 编号，不猜测契约文件名，不起草功能架构。

## 本规范不改什么

不改业务实现，不改 `youi_kit`，不实现页面，不画原型，不复制图片。壳的导航与状态模型只是对齐槽。
