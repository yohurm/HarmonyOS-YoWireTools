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
