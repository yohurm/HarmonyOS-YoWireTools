---
id: ui.app-shell.ia
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/navigation.md
  - docs/goal/ui/app-shell/permission-gap-wall.md
  - product/phone/src/main/ets/navigation/AppRoutes.ets
  - .projectark/2-需求文档/无线调试工具/PRD/01-产品信息架构与模式PRD.md
---

# 信息架构

## 顶层

`product/phone` 的 `MainTabContainer` 已经固定五个槽，顺序与 `AppRoutes` 常量一致。本设计不增加第六个底栏项，也不把蓝牙、网络、星闪互相注册成子入口。

| 槽 | `AppRoutes` | 下标 | 根路由 | 设计屏 |
| --- | --- | --- | --- | --- |
| 工作台 | `WORKBENCH` | `TAB_INDEX_WORKBENCH` = 0 | `/home/workbench` | [工作台](../workbench/home.md) |
| 蓝牙 | `BLUETOOTH` | 1 | `/bluetooth/overview` | [适配器与权限](../bluetooth/adapter-permissions.md) |
| 网络 | `WIFI` | 2 | `/wifi/overview` | [壳内概览](../wifi-network/shell-and-navigation.md) |
| 星闪 | `NEARLINK` | 3 | `/nearlink/overview` | [支持与开关](../nearlink/support-radio.md) |
| 更多 | `MORE_HUB` | 4 | `/more/hub` | [设置](../settings/hub.md) |

`main` 上工作台和更多目前是空的 `YoPageShell`。本设计补的是这两处的目标结构，不改代码。

PRD《01-产品信息架构与模式PRD》把日志中心、命令面板、设置画在首页分支上。落到现有五槽时：

| PRD 里的全局能力 | 落点 | 不这样做的原因 |
| --- | --- | --- |
| 模块入口 | 工作台卡片，并保留三个模块 Tab | 用户已经可以从底栏直接进入模块 |
| 最近会话 | 工作台列表区 | 不另开底栏 |
| 命令面板 | 工作台进入的二级页 | 见 [command-panel.md](../workbench/command-panel.md) |
| 日志中心 | 工作台入口，也可从各模块标题菜单进入本模块会话日志 | 跨模块列表见 [日志中心](../log/center.md) |
| 设置 | 「更多」 | 当前路由就是 `/more/hub` |

工作台、命令面板、日志、设置的编号在未合并的 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20)：`docs/goal/checklist/workbench.md`、`docs/goal/checklist/log.md`、`docs/goal/checklist/settings.md`，以及同号的 `docs/goal/architecture/workbench/`、`log/`、`settings/`。索引入口是 `docs/goal/citation.md`。这些文件不在 `main` 上。设计屏号 `screen.workbench.home`、`screen.workbench.command`、`screen.log.center`、`screen.log.detail`、`screen.settings.hub` 仍只是屏名，不代替那些编号。

目录名继续用 Phase-C 的 `docs/goal/ui/wifi-network/`。特性包目录是 `features/wifi_network`。不另建 `docs/goal/ui/wifi_network/`，避免两套路径。

## UI 边界

页面不调用 Kit。这条边界来自未合并的架构稿，不来自本目录新发明的分层。

| 模块 | 调用方向 | 出处（均未进入 `main`） |
| --- | --- | --- |
| 蓝牙 | `product/phone` 薄壳转发点击 → `features/bluetooth` 页面状态 → 用例 → `common/yobluetooth` 数据源 → `ohos.bluetooth.*`。`common/youi_kit` 不解释蓝牙，不调用 `ohos.bluetooth.*` | [PR #8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8) `docs/goal/architecture/bluetooth/BT-001.md`，提交 `acdc64fbebe693e4b3fc020c0dc98d6d8202cee5` |
| 星闪 | 页面只读页面状态；页面状态调用领域用例；`@kit.NearLinkKit` 只在 `features/nearlink` 数据源的调用点 | [PR #6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6) `docs/goal/architecture/nearlink/NL-001.md`，提交 `45188bf6745101d4fd56940f5f4da1e8a9fbd138` |
| Wi-Fi / 网络 | `product/phone` → `features/wifi_network` 页面 → 页面状态 → `domain` → `data` → Kit。页面只订阅页面状态 | [PR #7](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7) `docs/goal/architecture/wifi-network/WN-001.md`，提交 `a5d202385cd37108da16f86b94c86cf4b73aee79` |

`main` 的 `git ls-tree origin/main docs` 为空。BT / NL / WN 的清单、架构和总表路径写在 [质量门禁](../QUALITY-GATE.md) 的对接点，不在这里再抄一份编号表。在那些文档进入 `main` 之前，这仍是阻塞项，不是授权本设计另写一套 Repository。

跨模块会话日志的读路径写在 PR #20 的 `docs/goal/architecture/log/LOG-003.md`：页面只读页面状态，终点是 `LogRepository` 的 `debug_log_index`。`LOG-008.md` 写明会话列表不读 `YoLog` 或 hilog。该 PR 未进 `main`。日志中心不新命名查询函数。见 [日志中心](../log/center.md)。

## 模块内屏幕

模块屏幕表仍在各自索引：

- [蓝牙](../bluetooth/index.md)
- [星闪](../nearlink/README.md)
- [Wi-Fi 与网络](../wifi-network/README.md)

每条清单只在一个屏幕里写验收表现。壳不重复占一套 BT / NL / WN 编号。
