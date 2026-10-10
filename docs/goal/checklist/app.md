---
id: checklist.goal.app
type: checklist
status: active
when: design
when_to_use: 查整机一个 HAP、依赖方向、跨模块契约和唯一数据路径时。判定以本文件为准
related:
  - docs/goal/checklist/master.md
  - docs/goal/citation.md
  - docs/goal/checklist/workbench.md
  - docs/goal/checklist/log.md
  - docs/goal/checklist/settings.md
---

# 整机架构

每条只钉一个可观察结果。判定只有「支持」和「缺口」。

- **支持**：当前工作区代码里，这个结果已经能被模块配置、依赖声明或调用链证实。
- **缺口**：契约、导出面或数据链路还没有这个结果。不得把已有类写成已经接通。

这些编号是整机层，不计入三模块 350，也不改写壳清单 WB / LOG / SET。壳的屏幕行为仍以 [139ddc61d1f82e3d8f5c92980d420f19230bffec](https://github.com/yohurm/HarmonyOS-YoWireTools/commit/139ddc61d1f82e3d8f5c92980d420f19230bffec)（PR #20）为准。缺的屏幕保持缺口。

视觉不在本 PR。五个主路由：`/home/dashboard`、`/bluetooth/overview`、`/nearlink/overview`、`/wifi/overview`、`/settings/app`。没有第六个主页面。

分层见 `开发/最佳实践/架构设计/应用架构/分层架构设计.md`：产品定制层、基础特性层、公共能力层。安装包见 `开发/指南/入门/开发基础知识/应用程序包基础知识/应用程序包开发与使用/HAP.md` 与 `开发/指南/入门/开发基础知识/应用程序包基础知识/应用程序包开发与使用/HAR.md`。HAR 不能单独安装。单 UIAbility 场景官方优先一个 entry HAP。

导航、状态、关系库、用户首选项、hilog 的章节与壳清单相同。hilog 不是会话读模型。页面状态沿用本仓库 `viewmodel`，对应《MVVM模式（V2）》的 ViewModel，也是鸿蒙类型包里的页面状态层。

射频行为只作证据，不把这三棵树 checkout 进本分支：

- Wi-Fi `7295d1771288a0fb957021bd0e948073f435d96c`
- 蓝牙 `fba7e5d6dc3dd725f1baf3af4dea322943baf506`
- 星闪 `d58de1c9b6e7681bada1e642c1955c1a02079570`

## 整机

### APP-001 只有一个可安装 HAP

- **判定：** 支持
- **屏幕：** 无单独屏幕。产物是 `product/phone`
- **Given** 仓库里的 `module.json5`
- **When** 查找 `type` 为 `entry` 的模块，以及按射频拆开的 product
- **Then** `AppScope/app.json5` 的 `bundleName` 是 `com.yohurm.yowiretools`。唯一 entry 是 `product/phone`，`module.name` 为 `phone`。`features/home`、`features/bluetooth`、`features/nearlink`、`features/wifi_network` 和 `common/*` 的 `type` 都是 `har`。没有 `product/bluetooth`、`product/nearlink`、`product/wifi`。`product/tablet` 只有说明，没有 `module.json5`，不是第二个 HAP
- **证据：** `AppScope/app.json5`；`product/phone/src/main/module.json5`；四个 feature 与 `common/debug_core` 的 `module.json5`；`product/tablet/README.md`。本清单不改 ets

### APP-002 壳依赖 feature，feature 只依赖 common

- **判定：** 支持
- **屏幕：** 无单独屏幕。依赖在各模块 `oh-package.json5`
- **Given** `product/phone` 已经依赖四个 feature
- **When** 查 feature 的 `dependencies`，以及 ets 里对另一个 feature 包名的 import
- **Then** `product/phone` 依赖 `feature_home`、`feature_bluetooth`、`feature_nearlink`、`feature_wifi_network`，并直接依赖它自己 import 的 common 包。`features/home` 依赖 `debug_core` 与 `youi_kit`，不依赖三个射频包。三个射频 feature 只依赖 common，没有互相依赖，也没有依赖 `feature_home`。ets 里没有 `from 'feature_` 出现在 feature 或 common 源码中。壳对射频页面的 import 只在 `product/phone`
- **证据：** 五个 `oh-package.json5`。全仓库 `from 'feature_` 只出现在 `product/phone`。HAR 不支持依赖传递，所以 phone 直接声明 common，这不是第二条依赖方向。本清单不改 ets

### APP-003 feature 包入口只导出稳定接口

- **判定：** 支持
- **屏幕：** 无单独屏幕。入口是各 feature 的 `Index.ets`
- **Given** 壳只构造页面和蓝牙页已经用到的视图模型
- **When** 看四个 feature 的包入口
- **Then** `feature_nearlink` 导出 `NearLinkFeaturePage`、`NearLinkSettingsPage` 与 `ReadNearLinkSwitchUseCase`。`feature_wifi_network` 导出 `WifiFeaturePage`、`WifiSettingsPage` 与 `ReadWifiSwitchUseCase`。`feature_home` 导出 `HomeFeaturePage`、`LogCenterPage`、`LogDetailPage`、`CommandPanelTemplate`、`BluetoothCommandPage`、`NearLinkCommandPage`、`WifiCommandPage`、`SettingsHubPage`、`LogDetailNavParams`。`feature_bluetooth` 导出 `product/phone` 已 import 的页面与视图模型，另加 `BluetoothSettingsPage`。蓝牙开关用例是 `yobluetooth` 的 `ReadBluetoothSwitchUseCase`。仓库、传输、探测类不在 feature 入口
- **证据：** 四个 `Index.ets`。契约在 `common/debug_core`，名单见 [APP-003](../architecture/app/APP-003.md)

### APP-004 一条数据路径

- **判定：** 支持
- **屏幕：** 无单独屏幕。链路是 UI → ViewModel/State → UseCase → RepositoryContract → DataSource/KitBridge → Kit
- **Given** 射频 Kit 已经出现在各模块 `data/datasource` 与 `data/kit`
- **When** 查 `domain/usecase` 与 `domain/service` 的 import
- **Then** 这些目录不再 import `data/datasource`、`data/transport` 或射频 `@kit.*`。`WifiNetworkRepositoryContract` 引用领域模型 `NetworkStateSnapshot`。`LoadSessionLogPreviewUseCase` 只调用 `SessionLogRepositoryContract`。页面不调用 DataSource 或 Kit
- **证据：** `WifiSessionGateway.ets`；`data/registry/DeviceRegistry.ets`；`SsapPlatformMapper.buildTree`；`BluetoothRepository.connectGattTransport`。说明见 [APP-004](../architecture/app/APP-004.md)

### APP-005 壳接到唯一读模型

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** 写入侧已经进入表 `debug_log_index`（LOG-004，支持）
- **When** 追踪壳上的一次会话行读取
- **Then** 日志中心经 `LogCenterViewModel` → `LoadSessionLogPreviewUseCase` → `SessionLogRepositoryContract` → `LogIndexDataSource` → 表 `debug_log_index`。工作台不读这张表，也不把 `LoadWorkbenchOverviewUseCase` 的摘要列成最近会话。日志中心不读 `YoLog` 或 hilog（LOG-008，支持）
- **证据：** `LogCenterPage.ets`；`HomeFeaturePage.ets`；`LogIndexDataSource.ets`。说明见 [APP-005](../architecture/app/APP-005.md)

### APP-006 没有按射频拆开的产品模块

- **判定：** 支持
- **屏幕：** 无单独屏幕
- **Given** 三个射频能力都在 feature HAR 里
- **When** 查找第二个 entry，或把上述三个 phase-d 提交里的 `features/*` 目录 checkout 进当前树
- **Then** 不存在这种 product，当前分支也不是这三棵树拼起来的目录。本条只确认工程形态。它不证明射频页面已在真机通过，射频仍是待真机
- **证据：** `product/` 下只有 `phone` 有 `module.json5`。三个提交只在清单和架构里当行为证据引用。本清单不改 ets

### APP-007 只有五个主页面

- **判定：** 支持
- **屏幕：** 无单独屏幕。底栏五个槽位
- **Given** `MainTabContainer` 的 `tabContent0` 到 `tabContent4`
- **When** 数主页面和主路由
- **Then** 槽位 0 首页看板 `/home/dashboard`，1 蓝牙 `/bluetooth/overview`，2 星闪 `/nearlink/overview`，3 WiFi `/wifi/overview`，4 设置 `/settings/app`。没有第六个主页面，也没有「更多」槽位。日志中心、日志详情、三个模块设置、三个命令页都是同一棵 `NavPathStack` 上的压栈页
- **证据：** `AppRoutes.ets`；`MainTabContainer.ets`；`Index.ets`。说明见 [APP-007](../architecture/app/APP-007.md)

## 覆盖统计

合计 **7** 条（APP-001–APP-007）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 7 | APP-001、APP-002、APP-003、APP-004、APP-005、APP-006、APP-007 |
| 缺口 | 0 | 无 |

首页看板缺口是 WB-004、WB-006。射频仍是待真机。
