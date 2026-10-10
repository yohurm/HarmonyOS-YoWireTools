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

工作台用 WB-001–WB-007，命令面板用 WB-008–WB-012。前缀是 `WB-`。视觉待新 UI 规范 PR。

视觉待新 UI 规范 PR。屏名仍沿用：工作台 `screen.workbench.home`，命令面板 `screen.workbench.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，设置 `screen.settings.hub`。

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
- **Then** 有三枚 `YoStatusPill`：蓝牙、WLAN、星闪。开关读到后显示「已开启」或「已关闭」。未授权显示「未授权」，星闪不支持显示「不支持」，失败或未返回显示「未读取」。入口卡不设 `statusLabel`。不调用 `requestPermissionsFromUser`
- **证据：** `HomeFeaturePage.ets`；`WorkbenchRadioState.ets`；`ReadBluetoothSwitchUseCase`；`ReadWifiSwitchUseCase`；`ReadNearLinkSwitchUseCase`。说明见 [WB-003](../architecture/workbench/WB-003.md)

### WB-004 工作台有三张模块入口卡

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示
- **When** 查找蓝牙、网络、星闪入口卡
- **Then** 页内有三张 `YoModeEntryCard`：蓝牙、网络、星闪。不设 `statusLabel`。点击只切换已有 Tab，不扫描，不申请权限
- **证据：** `HomeFeaturePage.ets`；`MainTabContainer.openModule`

### WB-005 工作台列出最近会话或空态

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 进程里可能已有 `SessionRuntimeStore` 摘要
- **When** 在工作台查找最近会话
- **Then** 有 `DebugSessionSummary` 就列出名称、模块和协议。没有就显示「还没有会话」。来源是 `LoadWorkbenchOverviewUseCase`，不是 `debug_log_index`
- **证据：** `WorkbenchViewModel.ets`；`HomeFeaturePage.ets`

### WB-006 工作台有日志中心和命令面板入口

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示
- **When** 查找日志中心与命令面板
- **Then** 另有日志中心和命令面板两张卡。路由名是 `log/center` 与 `command/panel`，push 到同一棵 `NavPathStack`
- **证据：** `AppRoutes.ets`；`Index.ets`

### WB-007 工作台不弹出射频或网络授权

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 未授予蓝牙、星闪或位置权限
- **When** 只进入工作台，不进入各模块
- **Then** 只进入工作台或点入口卡，不出现 `requestPermissionsFromUser`
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
| 支持 | 12 | WB-001、WB-002、WB-003、WB-004、WB-005、WB-006、WB-007、WB-008、WB-009、WB-010、WB-011、WB-012 |
| 缺口 | 0 | 无 |

命令面板已有页面。工作台状态胶囊已接通。射频仍是待真机。
