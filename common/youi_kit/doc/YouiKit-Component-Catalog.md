# YoUI Kit — Component Catalog

## P0（公开 API，有消费者或壳必需）

| 组件 | 类型 | 说明 |
|------|------|------|
| `YoAppShell` | 自研壳 | 注入式 Tabs / 侧栏；无产品文案 |
| `YoSideNavRail` | 自研 | 侧栏；`YoSideNavItem` |
| `YoSplitScaffold` | 自研 | 分栏布局 |
| `YoPageShell` | 自研 | 页面标题栏 / 安全区壳 |
| `YoNavDestinationKind` | 枚举 | 与 Navigation 配套 |
| `YoSegmentButton` | 系统门面 | 包装 `SegmentButton` + Options |
| `YoActionButton` | 自研 | 主/次操作按钮 |
| `YoImmersiveSurface` | 自研 | 沉浸表面 |
| `YoEmpty` / `EmptyStateView` | 自研反馈 | 空态（迁移期保留旧名导出至收敛） |
| `ErrorStateView` / `LoadingStateView` / `PermissionDeniedView` | 自研反馈 | 状态视图 |
| `ContentStateHost` | 自研 | 页面状态宿主 |
| `ModeEntryCard` | 自研容器 | 模式入口卡 |
| `StatusPillView` | 自研 | 状态胶囊 |
| Theme / Token / Util | — | 见 Token / API 文档 |

## P1（删除或隔离，不进入 Index）

以下原 `common_ui` 导出无外部引用，重构中删除源码或移出公开面：

- CommandDockView、DataTerminalView、DeviceCardView
- FilterSheetView / FilterSheetHost
- InspectorPanel、PayloadViewerView
- SessionCardView、SessionChipView、SegmentChipView
- CapabilityBannerView、InfoBannerView、ModuleCapabilityCard
- YoListRow、YoLogRow、YoTextField、YoSwitchRow、YoSelectRow
- SectionTitleView、ThemeModeSelect
- RiskConfirmDialog / RiskConfirmOverlay
- YoContextStrip

## P2（按产品路线再补）

- 系统 Chip / HdsListItem 门面
- 表单行、终端、去业务硬编码的过滤器

## 包装类型图例

- **系统门面**：薄封装官方预置 / 高级组件，统一默认 Token
- **自研**：基础 ArkUI + Token（+ 可选 AttributeModifier）组合
