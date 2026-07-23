# YoUI Kit — Migration Guide

## 包与路径

| 旧 | 新 |
|----|----|
| 路径 `common/ui` | `common/youi_kit` |
| 包名 `common_ui` | `youi_kit` |
| `import { X } from 'common_ui'` | `import { X } from 'youi_kit'` |
| 依赖路径（entry） | `file:../common/youi_kit` |
| 依赖路径（features） | `file:../../common/youi_kit` |

`build-profile.json5` 中 `srcPath` 为 `./common/youi_kit`。

## Token 对照

| 旧 | 新 |
|----|----|
| `UiRadius` / `UiSpace` / `UiSize` / `UiStroke` / `UiOpacity` / `UiMotion` | `YoRadius` / `YoSpace` / `YoSize` / `YoStroke` / `YoOpacity` / `YoMotion` |
| `UiColor` / `UiTypeStyle` / `UiResponsive` | `YoColor` / `YoTypeStyle` / `YoResponsive` |
| `UiSurface` | 删除（用 `YoResponsive` / `YoColor`） |
| `ButtonToken` / `CardToken` / `ChipToken` / … | `YoButtonToken` / `YoCardToken` / `YoChipToken` / … |
| `UiPageState` | `YoPageState` |
| `UiResourceUtil` | `YoResourceUtil` |

## 组件对照

| 旧 | 新 |
|----|----|
| `EmptyStateView` | `YoEmpty` |
| `ErrorStateView` | `YoError` |
| `LoadingStateView` | `YoLoading` |
| `PermissionDeniedView` | `YoPermissionDenied` |
| `ContentStateHost` | `YoContentState` |
| `StatusPillView` | `YoStatusPill` |
| `ModeEntryCard` | `YoModeEntryCard` |
| Feature `SppTabSegmentButton` | Kit `YoSegmentButton` |
| `YoAppShell` 写死 Tab 文案 | `items` + Builder 槽由 Entry 注入 |

## 资源对照

| 旧 | 新 |
|----|----|
| `app.color.ui_*` | `app.color.youi_*` |
| `app.string.ui_*` | `app.string.youi_*` |
| Kit 内 `tab_*` | 移至 Entry 资源 |

## 消费者改动清单

1. 全仓 `common_ui` → `youi_kit`（包名不变物理目录为 `common/youi_kit`）
2. Token / 组件按上表重命名
3. SPP：改用 `YoSegmentButton`
4. `MainTabContainer`：注入 `YoSideNavItem[]`
5. `ohpm install` + 编译验证
