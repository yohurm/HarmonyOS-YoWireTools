---
id: checklist.goal.settings
type: checklist
status: active
when: design
when_to_use: UI Goal 引用壳与跨模块编号时。判定以本文件为准
related:
  - docs/goal/citation.md
---

# 设置

每条只钉一个可观察结果。判定只有「支持」和「缺口」。

- **支持**：在 Wi-Fi 分支上述提交的现有代码里，这个结果已经能被代码路径或界面证实。
- **缺口**：界面或读链路没有这个结果。不得把已有类、表或用例写成已经成功。

设置用 SET-。前缀是 `SET-`。视觉不在本 PR。应用设置是底栏第五页。蓝牙设置、星闪设置、WiFi 设置留在各自功能栈，不是应用设置页。命令不在设置页上。

屏名：应用设置 `screen.settings.app`，蓝牙设置 `screen.bluetooth.settings`，星闪设置 `screen.nearlink.settings`，WiFi 设置 `screen.wifi.settings`。

导航见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md`：一个 Navigation 绑定一个 NavPathStack，显示模式含 Stack、Split、Auto。状态见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`。关系型库见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过关系型数据库实现数据持久化 (ArkTS).md`。用户首选项见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过用户首选项实现数据持久化 (ArkTS).md`。进程日志见 `开发/API参考/系统/调测调优/Performance Analysis Kit（性能分析服务）/ArkTS API/ohos.hilog HiLog日志打印.md`。hilog 不是会话读模型。

## 设置

### SET-001 应用设置与三个模块设置分开

- **判定：** 支持
- **屏幕：** 应用设置（`screen.settings.app`）
- **Given** 槽位 `AppRoutes.TAB_INDEX_SETTINGS` 为 4，路由 `/settings/app`
- **When** 打开底栏「设置」，或在首页看板点「设置」
- **Then** 两者都是 `AppSettingsPage` 里的同一个 `SettingsHubPage`。页上只有显示、日志、后台连接、安全。没有命令、蓝牙、星闪、WiFi 组。首页只切槽位，不 push 第二页。`BluetoothSettingsPage` 路由 `/bluetooth/settings`，视图模型是 `BluetoothSettingsViewModel`，用例是 `LoadBluetoothModuleSettingsUseCase` 与 `SaveBluetoothAutoStopUseCase`。`NearLinkSettingsPage` 路由 `/nearlink/settings`，用例是 `LoadNearLinkModuleSettingsUseCase` 与 `SaveNearLinkRequireFilterUseCase`。`WifiSettingsPage` 路由 `/wifi/settings`，用例是 `LoadWifiModuleSettingsUseCase` 与 `SaveWifiScanCooldownUseCase`。这三页不用 `SettingsViewModel`，也不调用 `LoadSettingsUseCase`
- **证据：** `AppSettingsPage.ets`；`SettingsHubPage.ets`；`HomeFeaturePage.ets`；`BluetoothSettingsPage.ets`；`NearLinkSettingsPage.ets`；`WifiSettingsPage.ets`；`AppRoutes.ets`

### SET-002 设置页和启动主题走同一用例

- **判定：** 支持
- **屏幕：** 应用设置（`screen.settings.app`）
- **Given** `DebugCoreBootstrap.applyPersistedTheme` 会读主题
- **When** 进入设置页
- **Then** `SettingsViewModel` 与启动主题都调用 `LoadSettingsUseCase`。失败显示「未读取」
- **证据：** `SettingsViewModel.ets`；`DebugCoreBootstrap.ets`

### SET-003 设置页不申请蓝牙、星闪或 WLAN 权限

- **判定：** 支持
- **屏幕：** 应用设置（`screen.settings.app`）
- **Given** 未授予射频或位置权限
- **When** 只打开应用设置
- **Then** 不出现授权弹窗。应用设置页没有权限调用
- **证据：** `AppSettingsPage.ets` 与 `SettingsHubPage.ets` 不引用 `abilityAccessCtrl`

### SET-004 主题走 app_setting，其余走 preferences

- **判定：** 支持
- **屏幕：** 应用设置（`screen.settings.app`）
- **Given** 进程已完成 `StorageBootstrap`
- **When** 对照主题与专家/轻量、日志保留、周期允许这些键存在哪里
- **Then** 设置页经用例读取：主题来自 `app_setting`，其余键来自 preferences
- **证据：** `SettingsRepository.ets`

### SET-005 清除本地数据有确认

- **判定：** 支持
- **屏幕：** 应用设置（`screen.settings.app`）
- **Given** 设置页是空壳
- **When** 查找清除本地数据
- **Then** 「清除本地数据」先确认，再由 `ClearLocalDataUseCase` 清理会话日志
- **证据：** `SettingsHubPage.ets`；`ClearLocalDataUseCase`

### SET-006 设置页展示专家或轻量

- **判定：** 支持
- **屏幕：** 应用设置（`screen.settings.app`）
- **Given** `PreferenceKeys.APP_MODE` 为 `app.mode`，`AppMode` 有 `expert` 与 `light`
- **When** 在设置页查找模式开关
- **Then** 显示组有模式行，在专家和轻量之间切换
- **证据：** `SettingsHubPage.ets`；`UpdateSettingUseCase.saveAppMode`

## 覆盖统计

合计 **6** 条（SET-001–SET-006）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 6 | SET-001、SET-002、SET-003、SET-004、SET-005、SET-006 |
| 缺口 | 0 | 无 |
