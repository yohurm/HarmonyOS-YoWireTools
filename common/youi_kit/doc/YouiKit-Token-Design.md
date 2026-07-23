# YoUI Kit — Token Design

## 三层模型

```
Foundation  →  Semantic  →  Component
(YoRadius…)    (YoColor…)   (YoCardToken…)
```

组件禁止魔法数字；跨层读取应经 Semantic / Component，避免在业务里直读 Foundation（壳与组件内部除外）。

## Foundation

| 类 | 职责 |
|----|------|
| `YoRadius` | 4 / 8 / 16 / 20 / 32 / FULL |
| `YoSpace` | 8vp 网格间距 |
| `YoSize` | 触控目标、图标、行高 |
| `YoStroke` | 描边宽度 |
| `YoOpacity` | 启用 / 禁用 / 遮罩透明度 |
| `YoMotion` | 动效时长 |

## Semantic

| 类 | 职责 |
|----|------|
| `YoColor` | 映射 `youi_color_*` 资源；`base` 与 `dark` 名称对称 |
| `YoTypeStyle` | 字号 / 字重，映射 `youi_float_*` |
| `YoResponsive` | 内容最大宽、分区间距、断点相关布局常量 |

优先使用系统语义色（`$r('sys.color.*')`）的场景，在 Token 注释中标明；品牌与表面色走 `youi_*` 资源以保证 HAR 自洽。

## Component

| 类 | 职责 |
|----|------|
| `YoButtonToken` | 按钮高度 / 圆角 |
| `YoCardToken` | 卡片圆角（设备卡 16vp = `YoRadius.MEDIUM`） |
| `YoChipToken` | Chip / StatusPill |
| `YoListToken` | 列表间距 / 滚动条 |
| `YoMenuToken` | 菜单宽 |
| `YoDialogToken` | 对话框圆角 |
| `YoNavigationToken` | 侧栏宽、悬浮 Tab 边距、分栏权重 |
| `YoSegmentToken` | Segment 选中字色等门面默认 |

已裁剪（无消费者或不进公开 API）：`YoSurface`、`YoPageLayoutToken`、`YoCommandDockToken`、`YoTerminalToken`、`YoInputToken`（随死组件删除）。

## 资源前缀

- 颜色 / 字符串 / 浮点：统一 `youi_` 前缀，降低多 HAR 合并冲突。
- 深色：仅在 `dark/element/color.json` 提供同名覆盖。
- Kit 不引用 AppScope 资源。
