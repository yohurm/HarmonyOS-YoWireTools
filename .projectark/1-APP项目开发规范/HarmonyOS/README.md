# HarmonyOS APP 项目开发规范

## 目录说明

本目录统一 HarmonyOS APP 项目的开发基线，全部内容以**华为开发者联盟最新官方文档**为最高依据，在此之上补充团队工程化约定。

规范采用**单层顺序编号**（`1.1` ~ `1.8`），覆盖总则、架构、工程结构、分层、状态、路由、数据层与资源治理，不再维护独立的子目录副本。

---

## 阅读优先级

1. **华为开发者联盟最新官方文档与官方 API**
2. 本目录规范（`1.1` ~ `1.8`）
3. `.projectark/3-项目开发经验/HarmonyOS/` 实战经验
4. 项目内业务专项规范

如官方文档更新并与本目录冲突，**以官方最新文档为准**，并同步回收本目录内容。

---

## 文档清单

| 编号 | 文档 | 定位 |
|------|------|------|
| 1.1 | [项目开发总则](./1.1-项目开发总则.md) | 开发基线、官方主路径、默认原则 |
| 1.2 | [架构与 MVVM 规范](./1.2-架构与MVVM规范.md) | 官方三层架构 + MVVM 模式 |
| 1.3 | [工程目录与模块规范](./1.3-工程目录与模块规范.md) | common/features/products、HAP/HAR/HSP |
| 1.4 | [分层职责规范](./1.4-分层职责规范.md) | 各层职责、依赖方向、禁止事项 |
| 1.5 | [状态管理与数据流规范](./1.5-状态管理与数据流规范.md) | 状态管理 V2、ViewModel、单向数据流 |
| 1.6 | [页面装配与路由规范](./1.6-页面装配与路由规范.md) | UIAbility、Navigation、路由表 |
| 1.7 | [数据层设计规范](./1.7-数据层设计规范.md) | Repository、DataSource、官方存储与网络 |
| 1.8 | [资源管理规范](./1.8-资源管理规范.md) | resources、限定词、AppScope 公共资源 |

---

## 官方三层工程与目录映射

华为官方「三层架构工程」（Flexible Layout Ability 模板）与逻辑层的对应关系：

| 官方逻辑层 | 工程目录 | 默认包类型 | 职责 |
|-----------|---------|-----------|------|
| 产品定制层 | `products/` | Entry 类型 HAP | 应用入口、产品装配、根导航 |
| 基础特性层 | `features/` | HAR / Feature HAP / HSP | 业务特性模块 |
| 公共能力层 | `common/` | HAR | 公共 UI、网络、存储、工具 |

> 官方工程目录名为 **`common/`**（非 `commons`）。Feature 内 `ui / viewmodel / domain / data` 及 `usecase / repository / datasource` 为团队在中大型项目上的工程化扩展，官方 MVVM 入门示例结构较简（`model / view / viewmodel / pages`）。

---

## 新项目默认主路径

- Stage 模型 + UIAbility + WindowStage
- ArkTS 声明式开发范式 + ArkUI
- MVVM（Model 工程化细分为 Domain / Data）
- 状态管理 V2（`@ComponentV2`、`@ObservedV2` / `@Trace`、`@Local` / `@Param` / `@Event`）
- Navigation + NavPathStack + NavDestination + 系统路由表
- 官方 HTTP（`@kit.NetworkKit`）、Preferences、relationalStore（`RdbStore`）
- 资源统一进入 `resources`，公共资源下沉 AppScope
