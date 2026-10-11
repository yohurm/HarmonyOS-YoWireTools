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

页面不调用 Kit。整 App 的分层与 API 还没有文档，等待功能 Goal 的整 App 架构与统一工程。下面三行是各模块自己的架构稿，用来防止页面直调 Kit。把它们接在一起并不是应用契约，也不代替那份还没到的文档。

| 模块 | 该模块稿里的调用方向 | 出处（均未进入 `main`，且不是整 App 契约） |
| --- | --- | --- |
| 蓝牙 | `product/phone` 薄壳转发点击 → `features/bluetooth` 页面状态 → 用例 → `common/yobluetooth` 数据源 → `ohos.bluetooth.*`。`common/youi_kit` 不解释蓝牙，不调用 `ohos.bluetooth.*` | [PR #8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8) `docs/goal/architecture/bluetooth/BT-001.md`，提交 `acdc64fbebe693e4b3fc020c0dc98d6d8202cee5` |
| 星闪 | 页面只读页面状态；页面状态调用领域用例；`@kit.NearLinkKit` 只在 `features/nearlink` 数据源的调用点 | [PR #6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6) `docs/goal/architecture/nearlink/NL-001.md`，提交 `45188bf6745101d4fd56940f5f4da1e8a9fbd138` |
| Wi-Fi / 网络 | `product/phone` → `features/wifi_network` 页面 → 页面状态 → `domain` → `data` → Kit。页面只订阅页面状态 | [PR #7](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7) `docs/goal/architecture/wifi-network/WN-001.md`，提交 `a5d202385cd37108da16f86b94c86cf4b73aee79` |

## 待对齐的页面状态

壳上的七态写在 [navigation.md](navigation.md)，那是呈现，不是领域状态 API。页面只读页面状态、页面状态再往下调用，方向与上表一致。状态对象的类型、谁创建、三个模块的结果怎样进入同一个壳，等功能侧整 App 架构文档里的分层与 API。

还没到的位置：

| 位置 | 现在能说的 | 还不写 |
| --- | --- | --- |
| 页面持有什么 | 新界面用状态管理 V2，`@Local` 持有页面状态 | 新的状态类型名或字段表 |
| 点击交给谁 | 交给页面状态，页面不调用 Kit | 跨模块的用例或仓库签名 |
| 会话日志怎么读 | 只允许 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) `LOG-003` 那一条，而且判定仍是缺口 | 把这条缺口说成整 App 状态模型已经接通 |

不在本目录起草这套契约。

`main` 的 `git ls-tree origin/main docs` 为空。BT / NL / WN 的清单、架构和总表路径写在 [质量门禁](../QUALITY-GATE.md) 的对接点，不在这里再抄一份编号表。在那些文档进入 `main` 之前，这仍是阻塞项，不是授权本设计另写一套 Repository。

跨模块会话日志只允许一条读路径，写在 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) head `139ddc61` 的 `docs/goal/architecture/log/LOG-003.md`：UI → ViewModel/State → UseCase → RepositoryContract → DataSource → 表 `debug_log_index`。该条判定仍是「缺口」：`LoadSessionLogPreviewUseCase` 直连 `LogRepository`，页面侧还没接上。`LOG-008.md` 禁止第二日志库，会话列表不读 `YoLog` 或 hilog。该 PR 未进 `main`。见 [日志中心](../log/center.md)。

## 模块内屏幕

模块屏幕表仍在各自索引：

- [蓝牙](../bluetooth/index.md)
- [星闪](../nearlink/README.md)
- [Wi-Fi 与网络](../wifi-network/README.md)

每条清单只在一个屏幕里写验收表现。壳不重复占一套 BT / NL / WN 编号。
# 信息架构

一个应用，五个一级目的地。射频能力是目的地里面的屏，不是另一个 HAP。

```text
工作台
  最近会话列表
  命令面板（push）
蓝牙
  概览
  经典扫描（含连接 sheet）
  SPP 终端
  BLE 扫描（含过滤 sheet）
  GATT 详情
网络
  概览
  扫描
  链路详情
  诊断（场景 Tab）
  Socket 终端
  HTTP
  WebSocket
  局域网发现
星闪
  概览
  扫描
  SSAP 客户端
  端口数传
更多
  设置分组列表
日志中心（从工作台进入，不是第六个底栏项）
  日志详情
```

日志中心挂在工作台的入口上，宽屏侧栏也不增加第六项。当前项在进入日志中心时仍高亮工作台。这是壳的结构；入口是否已经接到读模型，见门禁第 9 项，现在没有。

命令面板同样从工作台 push，不占底栏。

蓝牙概览只放适配器状态和两个入口（经典、BLE）。扫描结果不堆在概览上。网络概览只放当前链路摘要和四个入口（扫描、诊断、局域网、Socket）。星闪概览只放支持/开关和两个入口（扫描、数传）。SSID 列表、设备列表都在下一级，避免概览变成第二首页。

配对的系统对话框不属于本应用的屏。应用只在连接 sheet 里说明「接下来是系统配对」，不自绘 PIN。
# 信息架构

来源：E4 一级页签；E6 设置分组；E2 四个网络场景；H6 控制台分类；现有 `AppRoutes` 与架构 §7.2 的屏幕名。§7.2 未合并进运行时代码的路由，下面标成「目标名」。

```
工作台
  最近会话
  日志中心          目标名 /log/list
    日志详情        目标名 /log/detail
  命令面板          目标名 /command/list
蓝牙
  总览              /bluetooth/overview
  经典扫描          目标名 /bluetooth/classic-scan
  SPP               /bluetooth/spp
    SPP 终端        /bluetooth/spp/terminal
  BLE 扫描          /bluetooth/ble
    GATT 详情       目标名 /bluetooth/gatt-detail
网络
  总览              /wifi/overview
  扫描              目标名，对齐 E1 列表
  链路详情          目标名，对齐 E1 详情
  诊断              目标名 /wifi/diagnostics（连接 / 状态 / 定位 / 故障）
  Socket 终端       目标名 /wifi/socket-terminal
  HTTP              目标名 /wifi/http-client
  WebSocket         目标名 /wifi/websocket
  局域网发现        目标名 /wifi/lan-discovery
星闪
  总览              /nearlink/overview
  扫描              目标名 /nearlink/scan
  SSAP              目标名 /nearlink/ssap-client
  数据传输          目标名 /nearlink/data-transfer
更多
  枢纽              /more/hub
  设置              目标名 /settings/index
```

模块页由各自 HAR 提供内容构建器，壳只负责栈和页签。HAR 之间不互相引用界面（E5 navigation-router 的方向；该仓库本次未克隆，不把它的 API 写进树）。跨模块只通过壳上的路由名。

工作台不放三张「蓝牙 / 网络 / 星闪」大卡去重复底栏。底栏已经是这三项目的地。
