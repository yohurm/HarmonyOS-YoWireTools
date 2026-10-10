---
id: checklist.goal.workbench
type: checklist
status: active
when: design
when_to_use: UI Goal 引用壳与跨模块编号时。判定以本文件为准
related:
  - docs/goal/citation.md
---

# 工作台与命令面板

每条只钉一个可观察结果。判定只有「支持」和「缺口」。

- **支持**：在 Wi-Fi 分支上述提交的现有代码里，这个结果已经能被代码路径或界面证实。
- **缺口**：界面或读链路没有这个结果。不得把已有类、表或用例写成已经成功。

工作台用 WB-001–WB-007，命令面板用 WB-008–WB-012。前缀是 `WB-`。视觉不在本 PR。

屏名仍沿用：工作台 `screen.workbench.home`，命令面板 `screen.workbench.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，设置 `screen.settings.hub`。

导航见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md`：一个 Navigation 绑定一个 NavPathStack，显示模式含 Stack、Split、Auto。状态见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`。关系型库见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过关系型数据库实现数据持久化 (ArkTS).md`。用户首选项见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过用户首选项实现数据持久化 (ArkTS).md`。进程日志见 `开发/API参考/系统/调测调优/Performance Analysis Kit（性能分析服务）/ArkTS API/ohos.hilog HiLog日志打印.md`。hilog 不是会话读模型。

## 工作台

### WB-001 工作台是根 Tab，标题为「工作台」

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 应用冷启动，槽位为 `AppRoutes.TAB_INDEX_WORKBENCH`（0）
- **When** 显示工作台
- **Then** `HomeFeaturePage` 用 `YoPageShell`，`destinationKind` 为 `ROOT_TAB`，标题资源 `home_title` 为「工作台」。底栏标签 `tab_workbench` 也是「工作台」
- **证据：** `features/home/src/main/ets/ui/page/HomeFeaturePage.ets`；`features/home/src/main/resources/base/element/string.json`；`product/phone/src/main/ets/shell/MainTabContainer.ets`；`product/phone/src/main/resources/base/element/string.json`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

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

### WB-008 命令面板有页面和路由

- **判定：** 支持
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 应用已启动
- **When** 从工作台或路由表查找命令面板
- **Then** `CommandPanelPage` 存在，路由 `command/panel` 在 `navDestination` 中
- **证据：** `CommandPanelPage.ets`；`AppRoutes.ets`；`Index.ets`

### WB-009 命令面板有收藏列表和只读参数

- **判定：** 支持
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** `command_template` 里可能已有行
- **When** 查看收藏与参数区
- **Then** 收藏列表读 `CommandTemplate.favorite`。选中行的 payload 只读。页面不读 `tags`
- **证据：** `CommandPanelViewModel.ets`；`CommandTemplateRepository.ets`

### WB-010 命令面板可以执行一次

- **判定：** 支持
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 没有命令面板
- **When** 查找「执行一次」
- **Then** 「执行一次」调用 `ExecuteSavedCommandUseCase`。没有传输会话时显示「没有进行中的会话」，不显示假成功
- **证据：** `CommandPanelPage.ets`；`CommandPanelUseCases.ets`

### WB-011 命令面板可以周期发送或说明原因

- **判定：** 支持
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 没有命令面板，设置页也没有「允许周期」开关
- **When** 查找周期发送
- **Then** 设置不允许时「周期发送」不可用，并显示「设置里未允许周期发送」。停止前要确认
- **证据：** `CommandPanelPage.ets`；`RepeatSavedCommandUseCase`

### WB-012 新建命令有成功态

- **判定：** 支持
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 命令面板不存在
- **When** 查找新建命令
- **Then** 空列表有「新建命令」。保存成功显示「已保存」
- **证据：** `CommandPanelPage.ets`；`SaveCommandTemplateUseCase`

## 覆盖统计

合计 **12** 条（WB-001–WB-012）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 10 | WB-001、WB-002、WB-003、WB-005、WB-007、WB-008、WB-009、WB-010、WB-011、WB-012 |
| 缺口 | 2 | WB-004、WB-006 |

命令面板已有页面，但不从工作台首页启动。WB-004 下钻和 WB-006 模块概览计数仍是缺口。射频仍是待真机。
