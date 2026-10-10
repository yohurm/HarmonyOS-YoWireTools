---
id: checklist.goal.workbench
type: checklist
status: active
when: design
when_to_use: UI Goal 引用壳与跨模块编号时。判定以本文件为准
related:
  - docs/goal/citation.md
---

# 首页看板与命令模板

每条只钉一个可观察结果。判定只有「支持」和「缺口」。

- **支持**：在 Wi-Fi 分支上述提交的现有代码里，这个结果已经能被代码路径或界面证实。
- **缺口**：界面或读链路没有这个结果。不得把已有类、表或用例写成已经成功。

首页看板用 WB-001–WB-007，命令模板用 WB-008–WB-012。前缀是 `WB-`。视觉不在本 PR。

主页面只有五个：首页看板、蓝牙、星闪、WiFi、设置。命令不是主页面。屏名：首页看板 `screen.home.dashboard`，蓝牙命令 `screen.bluetooth.command`，星闪命令 `screen.nearlink.command`，WiFi 命令 `screen.wifi.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，应用设置 `screen.settings.app`。

导航见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md`：一个 Navigation 绑定一个 NavPathStack，显示模式含 Stack、Split、Auto。状态见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`。关系型库见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过关系型数据库实现数据持久化 (ArkTS).md`。用户首选项见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过用户首选项实现数据持久化 (ArkTS).md`。进程日志见 `开发/API参考/系统/调测调优/Performance Analysis Kit（性能分析服务）/ArkTS API/ohos.hilog HiLog日志打印.md`。hilog 不是会话读模型。

## 工作台

### WB-001 首页看板是根 Tab，标题为「首页看板」

- **判定：** 支持
- **屏幕：** 首页看板（`screen.home.dashboard`）
- **Given** 应用冷启动，槽位为 `AppRoutes.TAB_INDEX_HOME`（0）
- **When** 显示首页看板
- **Then** `HomeFeaturePage` 用 `YoPageShell`，`destinationKind` 为 `ROOT_TAB`，标题资源 `home_title` 为「首页看板」。底栏标签 `tab_workbench` 也是「首页看板」
- **证据：** `HomeFeaturePage.ets`；`features/home` 的 `string.json`；`MainTabContainer.ets`；`product/phone` 的 `string.json`

### WB-002 一条 Navigation、一个 NavPathStack、Stack 模式

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** `Index.ets` 已创建唯一的 `rootNavStack`
- **When** 在工作台与其他根 Tab 之间切换，或从蓝牙概览 push SPP / BLE
- **Then** 仍然是同一棵 `Navigation`、同一个 `NavPathStack`、`NavigationMode.Stack`。工作台切换只改 `activeTabIndex`，不新开栈
- **证据：** `product/phone/src/main/ets/pages/Index.ets`。官方导航架构写明 Navigation 绑定一个 NavPathStack；本工程选用 Stack，不用 Auto。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-003 工作台显示蓝牙、WLAN、星闪状态胶囊

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示
- **When** 查看状态条
- **Then** 有三枚 `YoStatusPill`：蓝牙、WLAN、星闪。开关读到后显示「已开启」或「已关闭」。未授权显示「未授权」，星闪不支持显示「不支持」，失败或未返回显示「未读取」。不调用 `requestPermissionsFromUser`
- **证据：** `WorkbenchViewModel.figures` 含这三枚读数。蓝牙：`ReadBluetoothSwitchUseCase` → `BluetoothRepositoryContract.getAdapterState`。WLAN：`ReadWifiSwitchUseCase` → `WifiNetworkRepositoryContract.getWifiState`。星闪：`ReadNearLinkSwitchUseCase` → `NearLinkRepositoryContract.loadAdapterState`。读取在 `WorkbenchRadioState`，经 `bindCapability` 写入页面状态。说明见 [WB-003](../architecture/workbench/WB-003.md)

### WB-004 工作台下钻只进入已有功能栈

- **判定：** 缺口
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示某一能力读数
- **When** 从该读数进入对应模块的深度调试
- **Then** 只打开已有 feature 栈。看板契约没有下钻字段。页内没有模块入口卡，也没有日志或命令快捷入口
- **证据：** `WorkbenchViewModel.figures` 没有下钻目标。`HomeFeaturePage` 不再放置 `YoModeEntryCard`

### WB-005 工作台汇总会话摘要统计

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 进程里可能已有会话摘要，表 `debug_log_index` 里可能已有行
- **When** 在工作台查找活动会话数、会话内日志条数合计、以及日志索引行数
- **Then** `WorkbenchViewModel` 只保存这三个数字。活动会话数和会话内日志条数合计来自 `LoadWorkbenchOverviewUseCase` 对 `SessionRuntimeStore.listActiveSummaries` 的计数，不保留会话列表。日志索引行数来自 `CountSessionLogRowsUseCase` → `SessionLogRepositoryContract.list` 的 `total`。页面不列出会话供用户启动
- **证据：** `WorkbenchViewModel.activeSessionCount`、`sessionLogCount`、`logIndexCount`。未在真机执行，射频仍是待真机

### WB-006 工作台聚合模块概览计数

- **判定：** 缺口
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 各模块仓库快照里已有配对设备数、扫描 AP 数或星闪设备数
- **When** 在工作台查找这些计数
- **Then** 工作台不显示。`LoadBluetoothOverviewSnapshotUseCase` → `BluetoothRepositoryContract.loadOverview`、`WifiNetworkRepositoryContract.loadOverview`、`LoadNearLinkOverviewUseCase` → `NearLinkRepositoryContract.loadOverview` 都不由工作台调用。噪声、SNR、MCS、重传、PHY、空口 HCI、原始套接字没有 Kit 接口，工作台不补调用
- **证据：** `WorkbenchViewModel.figures` 没有这些计数

### WB-007 工作台不弹出射频或网络授权

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 未授予蓝牙、星闪或位置权限
- **When** 只进入工作台，不进入各模块
- **Then** 只进入工作台，不出现 `requestPermissionsFromUser`
- **证据：** `HomeFeaturePage.ets` 不引用权限编排。胶囊读取走 `checkGranted`，不调用 `requestPermissionsFromUser`

## 命令面板

### WB-008 命令模板由三个射频各自扩展

- **判定：** 支持
- **屏幕：** 蓝牙命令（`screen.bluetooth.command`）、星闪命令（`screen.nearlink.command`）、WiFi 命令（`screen.wifi.command`）
- **Given** 应用已启动
- **When** 从路由表查找命令
- **Then** 壳是 `CommandPanelTemplate`，契约是 `CommandRepositoryContract.listTemplates(module, offset, limit)`。`BluetoothCommandPage`、`NearLinkCommandPage`、`WifiCommandPage` 各自持有自己的视图模型，并分别调用 `ExecuteBluetoothCommandUseCase`、`ExecuteNearLinkCommandUseCase`、`ExecuteWifiCommandUseCase`。路由是 `/bluetooth/command`、`/nearlink/command`、`/wifi/command`。没有一条把三个射频写在同一个实现里的 `command/panel`。首页看板不打开命令
- **证据：** `CommandPanelTemplate.ets`；`BluetoothCommandPage.ets`；`NearLinkCommandPage.ets`；`WifiCommandPage.ets`；`BluetoothCommandUseCases.ets`；`NearLinkCommandUseCases.ets`；`WifiCommandUseCases.ets`；`AppRoutes.ets`；`Index.ets`

### WB-009 命令模板有收藏列表和只读参数

- **判定：** 支持
- **屏幕：** 蓝牙命令（`screen.bluetooth.command`）
- **Given** `command_template` 里可能已有该模块的行
- **When** 查看收藏与参数区
- **Then** 收藏列表读 `CommandTemplate.favorite`，且列表按该页的 `ModuleType` 过滤。选中行的 payload 只读。页面不读 `tags`
- **证据：** `CommandPanelViewModel.ets`；`CommandTemplateRepository.ets`

### WB-010 命令模板可以执行一次

- **判定：** 支持
- **屏幕：** 蓝牙命令（`screen.bluetooth.command`）
- **Given** 当前射频命令页已打开
- **When** 查找「执行一次」
- **Then** 「执行一次」调用该射频自己的执行用例。没有传输会话时显示「没有进行中的会话」，不显示假成功。模板的 `module` 与用例模块不一致时不发送
- **证据：** `CommandPanelTemplate.ets`；`ExecuteModuleCommandUseCase`

### WB-011 命令模板可以周期发送或说明原因

- **判定：** 支持
- **屏幕：** 蓝牙命令（`screen.bluetooth.command`）
- **Given** 周期开关不在应用设置页
- **When** 查找周期发送
- **Then** 命令页用 `ReadCommandRepeatPolicyUseCase` 与 `SaveCommandRepeatPolicyUseCase`，不调用 `LoadSettingsUseCase`。未允许时「周期发送」不可用，并显示「未允许周期发送」。停止前要确认
- **证据：** `CommandPanelTemplate.ets`；`RepeatModuleCommandUseCase`；`ReadCommandRepeatPolicyUseCase`

### WB-012 新建命令有成功态

- **判定：** 支持
- **屏幕：** 蓝牙命令（`screen.bluetooth.command`）
- **Given** 当前射频命令页已打开
- **When** 查找新建命令
- **Then** 空列表有「新建命令」。保存成功显示「已保存」。保存写入该射频的 `ModuleType`，换行写在模板上，不写进应用设置页
- **证据：** `CommandPanelTemplate.ets`；`SaveModuleCommandTemplateUseCase`

## 覆盖统计

合计 **12** 条（WB-001–WB-012）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 10 | WB-001、WB-002、WB-003、WB-005、WB-007、WB-008、WB-009、WB-010、WB-011、WB-012 |
| 缺口 | 2 | WB-004、WB-006 |

命令模板已按蓝牙、星闪、WiFi 分开，不从首页看板启动。WB-004 下钻和 WB-006 模块概览计数仍是缺口。射频仍是待真机。
