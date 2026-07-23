# YoUI Kit — API Design

## 导出规则

1. 所有对外符号仅通过根目录 `Index.ets` 导出。
2. 未完成、实验、仅内部使用的实现放在源码目录内，**不**写入 Index。
3. Feature / Entry 禁止 deep-import `youi_kit/src/...`。

## 命名

| 类别 | 规则 | 示例 |
|------|------|------|
| 组件 | `Yo` + 语义名 | `YoSegmentButton`、`YoPageShell` |
| Token 类 | `Yo` + 域 | `YoColor`、`YoSpace`、`YoCardToken` |
| 模型 / 枚举 | `Yo` 或语义名 | `YoPageState`、`YoActionButtonKind` |
| 资源 | `youi_` 前缀 | `youi_color_brand`、`youi_string_loading` |

废弃：`*View` / `*Host` 作为公开名（迁移期可短暂保留别名，最终收敛为 `Yo*`）。

## Component V1 / V2 选用

| 场景 | 选用 | 原因 |
|------|------|------|
| 绑定系统预置组件需 `$` / `@Link`（如 SegmentButton `selectedIndexes`） | `@Component` | 与系统 V1 绑定形态一致；当前结构下 V2 易丢滑动动画 |
| 纯自研组合、无系统 `$` 绑定 | 优先 `@ComponentV2` | 与工程壳层（`YoPageShell`、`YoAppShell`）一致 |

## 系统门面约定

对外暴露简化 Props / 回调，例如：

- `labels: ResourceStr[]`
- `selectedIndex: number`
- `onSelectedIndexChange: (index: number) => void`

对内组装 `SegmentButtonOptions` 等官方 Options，并固化 Kit 级默认（如深色可读的选中字色）。

**禁止**在预置组件实例上链式 `width` / `margin` 等通用属性。

## AttributeModifier

- 用于 Button / Text / Image 等支持通用属性的基础组件样式复用。
- Modifier 类可导出供业务微调；默认样式由 Kit Token 驱动。
- AttributeModifier 主要作用于系统基础组件；挂自定义组件能力需核对 API 基线（工程目标 API 23）。

## 壳层注入

`YoAppShell` 不内置产品 Tab 文案：

- `@Param items: YoSideNavItem[]` — 标签与符号由 Entry 注入
- `@BuilderParam` 内容槽由 Entry 提供
- Kit 内不引用 `tab_workbench` 等产品字符串
