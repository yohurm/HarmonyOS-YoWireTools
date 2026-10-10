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

工作台用 WB-001–WB-007，命令面板用 WB-008–WB-012。前缀跟 PR #19 已点名、当时尚未编号的 `WB-`。

屏名来自 PR #19：工作台 `screen.workbench.home`，命令面板 `screen.workbench.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，设置 `screen.settings.hub`。

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

### WB-003 工作台不显示蓝牙、WLAN、星闪状态胶囊

- **判定：** 缺口
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示
- **When** 查看状态条
- **Then** 没有三枚状态胶囊。页面内容是空的 `Column`。不得把空白说成「未读取」已按设计展示，也不得编造开关状态
- **证据：** `HomeFeaturePage.pageContent` 只有空 `Column`。该页不引用蓝牙、星闪或 Wi-Fi 的状态用例。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-004 工作台没有三张模块入口卡

- **判定：** 缺口
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示
- **When** 查找蓝牙、网络、星闪入口卡
- **Then** 页内没有这三张卡。切到蓝牙、网络、星闪只能用壳的底栏或侧栏。不得把底栏说成工作台卡片已经存在
- **证据：** `HomeFeaturePage` 无点击回调。`MainTabContainer.onTabChange` 只改槽位，不由工作台页发起。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-005 工作台不列出最近会话

- **判定：** 缺口
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 进程里可能已有 `SessionRuntimeStore` 摘要
- **When** 在工作台查找最近会话
- **Then** 没有列表，也没有「还没有会话」的空态。`LoadWorkbenchOverviewUseCase` 没有被任何页面调用。不得把用例存在写成列表已出现。用例本身也不把结果截成五行
- **证据：** `common/debug_core/src/main/ets/usecase/WorkbenchUseCases.ets` 的 `LoadWorkbenchOverviewUseCase.execute` 返回 `DebugSessionSummary[]`。全仓库页面没有引用它。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-006 工作台没有日志中心和命令面板入口

- **判定：** 缺口
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 工作台已显示
- **When** 查找日志中心与命令面板
- **Then** 没有这两张次入口。`AppRoutes` 没有日志中心或命令面板的路由名。`Index.ets` 的 `navDestination` 只注册蓝牙 SPP、终端和 BLE
- **证据：** `product/phone/src/main/ets/navigation/AppRoutes.ets`；`product/phone/src/main/ets/pages/Index.ets`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-007 工作台不弹出射频或网络授权

- **判定：** 支持
- **屏幕：** 工作台（`screen.workbench.home`）
- **Given** 未授予蓝牙、星闪或位置权限
- **When** 只进入工作台，不进入各模块
- **Then** 不出现 `requestPermissionsFromUser`。空页面没有授权调用
- **证据：** `HomeFeaturePage.ets` 不引用 `abilityAccessCtrl` 或权限编排。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

## 命令面板

### WB-008 命令面板没有页面，也没有路由

- **判定：** 缺口
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 应用已启动
- **When** 从工作台或路由表查找命令面板
- **Then** 找不到页面、找不到路由名、找不到 `navDestination` 分支。不得把 `CommandRepository` 或 `SendCommandUseCase` 的存在写成面板已打开
- **证据：** `AppRoutes.ets` 无命令面板常量。`Index.ets` 无对应分支。全仓库无命令面板页面。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-009 命令面板没有收藏列表和只读参数

- **判定：** 缺口
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** `command_template` 里可能已有行
- **When** 查看收藏与参数区
- **Then** 没有列表，没有选中行，没有只读参数。表上的 `tags` 没有被任何页面映射成收藏。不得把 tags 说成收藏已显示
- **证据：** `CommandRepository.listTemplates` 无调用方页面。`CommandTemplate` 无单独的收藏字段被 UI 读取。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-010 命令面板不能执行一次

- **判定：** 缺口
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 没有命令面板
- **When** 查找「执行一次」
- **Then** 没有这个按钮，也没有执行中的终态。`SendCommandUseCase` 要求调用方传入 `ITransportSession`，没有任何面板传入。不得把该类存在写成面板已能发送
- **证据：** `common/debug_core/src/main/ets/usecase/CommandUseCases.ets`。无页面构造 `SendCommandInput`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-011 命令面板不能周期发送

- **判定：** 缺口
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 没有命令面板，设置页也没有「允许周期」开关
- **When** 查找周期发送
- **Then** 没有次按钮，没有停止确认。`RepeatCommandCoordinator` 与 `PreferenceKeys.BACKGROUND_ALLOW_REPEAT_COMMAND` 没有被面板或设置页调用。默认值在 `PreferencesStore.ensureDefaults` 里是 false，但没有界面读它。不得显示周期已启动
- **证据：** `PreferencesStore.isBackgroundRepeatAllowed` 无页面调用方。`RepeatCommandCoordinator` 无命令面板引用。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### WB-012 没有「新建命令」成功态

- **判定：** 缺口
- **屏幕：** 命令面板（`screen.workbench.command`）
- **Given** 命令面板不存在
- **When** 查找新建命令
- **Then** 没有空态页，也没有「新建命令」成功。`saveTemplate` 没有面板调用方。不得出现保存成功
- **证据：** `CommandRepository.saveTemplate` 无 UI 调用。没有空态组件。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

## 覆盖统计

合计 **12** 条（WB-001–WB-012）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 3 | WB-001、WB-002、WB-007 |
| 缺口 | 9 | WB-003、WB-004、WB-005、WB-006、WB-008、WB-009、WB-010、WB-011、WB-012 |

命令面板没有页面。WB-008–WB-012 全部是缺口，不是假的通过。
