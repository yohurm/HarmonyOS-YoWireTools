# YoUI Kit — Architecture Overview

## 定位

YoUI Kit（HAR 包名 `youi_kit`）是 YoWire 工程**公共能力层**的唯一 UI 出口，提供可复用的 Token、主题策略、通用壳与组件。

Android 工程中的 `youi_kit` 仅作产品定位参考（「需要有公共 UI 库」），**不对齐其目录、自定义 View 或 MVCS 实现**。本库按 HarmonyOS 原生规范设计。

## 官方依据

| 文档 | 对本库的约束 |
|------|----------------|
| 分层架构设计 | 公共 UI 组件落在公共能力层 HAR；上层可依赖，禁止反向 |
| HAR 包 | 仅 `Index.ets` 导出；无 AppScope；无循环依赖；无依赖传递；资源合并需前缀 |
| 组件封装 | AttributeModifier 样式复用；`@Component` 自定义组件；预置组件用 Options/Props 门面 |
| 设计指南 | 色彩 / 间隔 / 圆角 Token 化 |

## 工程分层

```
产品定制层   entry HAP
基础特性层   features/* HAR
公共能力层   common/youi_kit / common/core / common/platform
```

- Feature / Entry：`import { ... } from 'youi_kit'`
- Kit 可依赖 `common_platform`、`common_core`；不可被它们反向依赖
- 上层若需 platform API，须自行声明依赖（HAR 无依赖传递）

## 内部分层（自底向上）

1. `token/foundation` — 半径、间距、尺寸、描边、透明度、动效
2. `token/semantic` — 色、字型、响应式
3. `token/component` — 组件级 Token
4. `modifiers/` — AttributeModifier（基础系统组件样式）
5. `theme/` — 标题栏 / 材质策略
6. `components/` — Yo 组件（自研组合 + 系统门面）
7. `Index.ets` — 唯一公开 API

依赖方向：`components → token | theme | util | modifiers`。禁止 `token → components`。禁止业务文案与领域枚举进入 Kit。

## 组件双轨策略

| 类型 | 何时使用 | 示例 |
|------|----------|------|
| 系统门面 | 官方组件已覆盖交互/动效 | `YoSegmentButton` ← `SegmentButton` |
| 自研组合 | 需统一 Token / 布局语义 | `YoPageShell`、`YoActionButton`、空态族 |

预置组件（如 SegmentButton）**不支持通用属性链式**；尺寸与边距由外层布局承接。

## 模块契约

| 项 | 约定 |
|----|------|
| 类型 | HAR |
| 物理路径 | `common/youi_kit` |
| 包名 | `youi_kit` |
| 入口 | `Index.ets`（`oh-package.json5` → `main`） |
| 资源前缀 | `youi_*`（含 `base` / `dark`） |
| 命名 | 公开符号 `Yo*`；资源 `youi_*` |
