---
id: checklist.goal.log
type: checklist
status: active
when: design
when_to_use: UI Goal 引用壳与跨模块编号时。判定以本文件为准
related:
  - docs/goal/citation.md
---

# 跨模块日志

每条只钉一个可观察结果。判定只有「支持」和「缺口」。

- **支持**：在 Wi-Fi 分支上述提交的现有代码里，这个结果已经能被代码路径或界面证实。
- **缺口**：界面或读链路没有这个结果。不得把已有类、表或用例写成已经成功。

日志中心与日志详情共用 LOG-。前缀是 `LOG-`。视觉待新 UI 规范 PR。

视觉待新 UI 规范 PR。屏名仍沿用：工作台 `screen.workbench.home`，命令面板 `screen.workbench.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，设置 `screen.settings.hub`。

导航见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/设置组件导航和页面路由/组件导航(Navigation) (推荐)/Navigation基础架构介绍.md`：一个 Navigation 绑定一个 NavPathStack，显示模式含 Stack、Split、Auto。状态见 `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`。关系型库见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过关系型数据库实现数据持久化 (ArkTS).md`。用户首选项见 `开发/指南/开发/应用框架/ArkData（方舟数据管理）/应用数据持久化/通过用户首选项实现数据持久化 (ArkTS).md`。进程日志见 `开发/API参考/系统/调测调优/Performance Analysis Kit（性能分析服务）/ArkTS API/ohos.hilog HiLog日志打印.md`。hilog 不是会话读模型。

## 统一日志

### LOG-001 日志中心有页面

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** 工作台或各模块已能写入会话行
- **When** 查找日志中心
- **Then** `LogCenterPage` 路由 `log/center`。有模块分段、关键字，列表显示模块和协议
- **证据：** `LogCenterPage.ets`；`AppRoutes.ets`

### LOG-002 日志详情有页面

- **判定：** 支持
- **屏幕：** 日志详情（`screen.log.detail`）
- **Given** 没有日志中心，因此也没有选中行
- **When** 查找日志详情
- **Then** 点一行打开 `LogDetailPage`。HEX 显示「未记录」
- **证据：** `LogDetailPage.ets`；`LogDetailNavParams`

### LOG-003 跨模块读路径接到日志中心

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** 只存在 `LoadSessionLogPreviewUseCase`
- **When** 追踪一次会话日志读取
- **Then** 页面状态只调用 `LoadSessionLogPreviewUseCase`。用例只调用 `SessionLogRepositoryContract`。终点是 `LogIndexDataSource` 查询表 `debug_log_index`
- **证据：** `LogCenterViewModel.ets`；`SessionLogRepository.ets`；`LogIndexDataSource.ets`

### LOG-004 三模块会话行写入同一张 debug_log_index

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** 蓝牙、星闪或 Wi-Fi 的已有 logger 捕获一条事件或一段字节
- **When** `LogCaptureService.captureEvent` 或 `captureBytes` 返回
- **Then** 行进入 `LogRepository.append`，表是 `debug_log_index`。模块字段来自 `ModuleType`：`bluetooth`、`wifi`、`nearlink`。这是写入侧已经成立的事实，不是日志中心页面已经能看
- **证据：** `BluetoothScanLogger`、`SppReconnectEventLogger`、`NearLinkEventLogger`、`WifiScanLogger`、`WifiMessageLogger`、`HttpNetworkLogger`、`TransportLogBinder`、`SessionManager`、`SendCommandUseCase`、`AppendLogUseCase` 都调用 `LogCaptureService.captureEvent` 或 `captureBytes`，再由 `LogRepository.append` 写入 `debug_log_index`。 `LogCaptureService.captureRecord` 调用 `logRepository.append`。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

### LOG-005 查询带模块和关键字

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** 日志中心需要「全部 / 蓝牙 / 网络 / 星闪」和关键字
- **When** 查看 `LogQuery`
- **Then** `SessionLogQuery` 与 `LogQuery` 带 module 和 keyword。谓词在 `LogIndexDataSource`
- **证据：** `LogQuery.ets`；`SessionLogQuery.ets`；`LogIndexDataSource.ets`

### LOG-006 预览行带模块和协议

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** `LogIndexRecord` 含 `module` 与 `protocol`
- **When** `LoadSessionLogPreviewUseCase` 映射成 `WorkbenchLogLine`
- **Then** `WorkbenchLogLine` 带 module、protocol、sessionId。列表主行显示模块和协议
- **证据：** `WorkbenchLogLine.ets`；`LogCenterPage.ets`

### LOG-007 日志中心可以导出和清空

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** `LogExportService.exportLogs`、`LogRepository.deleteBySession` 和 `cleanup` 已存在
- **When** 在日志中心查找导出和清空
- **Then** 导出和清空都在日志中心。清空先确认。两者走会话日志契约
- **证据：** `LogCenterViewModel.ets`；`ExportSessionLogUseCase`；`ClearSessionLogUseCase`

### LOG-008 没有任何界面把 YoLog 或 hilog 当成会话列表

- **判定：** 支持
- **屏幕：** 日志中心（`screen.log.center`）
- **Given** 会话写入走 `LogCaptureService`，进程日志走 `YoLog`
- **When** 查找读取 `FileAppender`、`MemoryRingAppender` 或 hilog 来画出会话行的页面或用例
- **Then** 没有这种读取点。`LoadSessionLogPreviewUseCase` 只调 `LogRepository.list`。这不等于日志中心已显示，只说明第二读点现在还不存在
- **证据：** `FileAppender`、`MemoryRingAppender`、`HiLogAppender` 只被 `common/yolog` 自己引用。页面目录不引用它们。行为对照 Wi-Fi 分支 `cursor/wifi-network-phase-d-4072` 的 `7295d1771288a0fb957021bd0e948073f435d96c`。本清单不改 ets。

## 覆盖统计

合计 **8** 条（LOG-001–LOG-008）。编号连续。支持与缺口相加等于合计。

| 判定 | 条数 | 编号 |
| --- | --- | --- |
| 支持 | 8 | LOG-001、LOG-002、LOG-003、LOG-004、LOG-005、LOG-006、LOG-007、LOG-008 |
| 缺口 | 0 | 无 |
