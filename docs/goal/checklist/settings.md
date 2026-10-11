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

设置用 SET-。前缀跟 PR #19 已点名、当时尚未编号的 `SET-`。屏幕名是设置，壳上的标题资源仍是「更多」。

屏名来自 PR #19：工作台 `screen.workbench.home`，命令面板 `screen.workbench.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，设置 `screen.settings.hub`。

导航见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md`：一个 Navigation 绑定一个 NavPathStack，显示模式含 Stack、Split、Auto。状态见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`。关系型库见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过关系型数据库实现数据持久化 (ArkTS).md`。用户首选项见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过用户首选项实现数据持久化 (ArkTS).md`。进程日志见 `开发/API参考/系统/调测调优/Performance Analysis Kit（性能分析服务）/ArkTS API/ohos.hilog HiLog日志打印.md`。hilog 不是会话读模型。

## 设置

### SET-001 设置八组没有出现，更多页是空壳

- **判定：** 缺口
- **屏幕：** 设置（`screen.settings.hub`）
- **Given** 槽位 `AppRoutes.TAB_INDEX_MORE` 为 4
- **When** 打开更多
- **Then** `MoreFeaturePage` 是空的 `YoPageShell`，标题资源 `more_hub_title` 为「更多」，底栏 `tab_more` 也是「更多」。看不到显示、日志、后台、命令、蓝牙、Wi-Fi、星闪、安全这八组。不得把空页说成设置已分组
- **证据：** `product/phone/src/main/ets/shell/MoreFeaturePage.ets`；电话包 `string.json`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### SET-002 设置页没有页面状态，启动读设置也不经过页面

- **判定：** 缺口
- **屏幕：** 设置（`screen.settings.hub`）
- **Given** `DebugCoreBootstrap.applyPersistedTheme` 会读主题
- **When** 进入设置页
- **Then** 页面没有状态层，不调用 `AppSettingRepository`，也不调用 `PreferencesStore` 的 `getAppMode` 等方法。看不到当前值。未知项没有显示成「未读取」，因为行本身不存在
- **证据：** `MoreFeaturePage.ets` 无仓库引用。`DebugCoreBootstrap.ets` 在启动时直接 `AppSettingRepository.get(PreferenceKeys.THEME_MODE)`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### SET-003 设置页不申请蓝牙、星闪或 WLAN 权限

- **判定：** 支持
- **屏幕：** 设置（`screen.settings.hub`）
- **Given** 未授予射频或位置权限
- **When** 只打开更多页
- **Then** 不出现授权弹窗。空页面没有权限调用
- **证据：** `MoreFeaturePage.ets` 不引用 `abilityAccessCtrl`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### SET-004 主题在关系库，其余设置键在用户首选项

- **判定：** 缺口
- **屏幕：** 设置（`screen.settings.hub`）
- **Given** 进程已完成 `StorageBootstrap`
- **When** 对照主题与专家/轻量、日志保留、周期允许这些键存在哪里
- **Then** `app.themeMode` 只被 `DebugCoreBootstrap` 从 `AppSettingRepository`（表 `app_setting`）读取。`app.mode`、`log.retentionDays`、`background.allowRepeatCommand` 等键的默认值和读取方法在 `PreferencesStore`（`@kit.ArkData` 的 preferences）。两边都没有设置页。这是两套设置库，判定缺口。不得把其中一边说成设置已保存成功
- **证据：** `DebugCoreBootstrap.ets`；`AppSettingRepository.ets`；`PreferencesStore.ensureDefaults` 与 `getAppMode`。`ensureDefaults` 不含 `THEME_MODE`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### SET-005 没有清除本地数据的确认

- **判定：** 缺口
- **屏幕：** 设置（`screen.settings.hub`）
- **Given** 设置页是空壳
- **When** 查找清除本地数据
- **Then** 没有这一行，也没有确认框。没有设置页调用删除。不得显示已清除
- **证据：** `MoreFeaturePage` 无删除调用。日志删除方法没有接到本页，见 LOG-007。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### SET-006 设置页不展示专家或轻量

- **判定：** 缺口
- **屏幕：** 设置（`screen.settings.hub`）
- **Given** `PreferenceKeys.APP_MODE` 为 `app.mode`，`AppMode` 有 `expert` 与 `light`
- **When** 在设置页查找模式开关
- **Then** 没有这一行。`PreferencesStore.getAppMode` 没有页面调用方。默认值在 `ensureDefaults` 写成 `expert`，但设置页不显示，工作台也不显示。不得把默认值说成用户已经选过
- **证据：** `PreferencesStore.getAppMode` 仅定义在该类内部路径上，无页面引用。`HomeFeaturePage` 不读 `app.mode`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

## 覆盖统计

合计 **6** 条（SET-001–SET-006）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 1 | SET-003 |
| 缺口 | 5 | SET-001、SET-002、SET-004、SET-005、SET-006 |
