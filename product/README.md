# YoWire 产品分层与分包架构

> 参考：官方《分层架构设计》+「一次开发，多端部署」；吸收 Notes1 的 product 入口思路，不照搬其取消 features / common→UI 反向依赖。

## 三层映射（官方折中）

| 官方分层 | YoWire 物理目录 | 包形态 | 职责 |
|----------|-----------------|--------|------|
| 产品定制层 | `product/phone`、`product/tablet`（预留） | Entry HAP | Ability、根导航、**Page 薄壳**、设备差异布局、产品资源与权限 |
| 基础特性层 | `features/*` | HAR | **ViewModel** + 业务 View/Component（蓝牙 / WiFi / 星闪 / 首页等） |
| 公共能力层 | `common/*` | HAR | `youi_kit`、core、platform、storage、`debug_core`、协议引擎（`yo_bluetooth` 等） |

依赖方向（硬约束）：

```
product/*  →  features/*  →  common/*
product/*  →  common/*
```

禁止：`common` / `features` 反向依赖 `product`；禁止 `common` 依赖 `features`。

## 页面归属

- **Page 壳** 放在 `product/*/src/main/ets/pages/`：创建 VM、转发生命周期、组合 Feature View、按断点切换布局。
- **ViewModel / 业务 View** 放在 `features/*`，供多个 product HAP 复用。
- **协议引擎**（UseCase / Repository / DataSource）放在 `common/yo_*`，不进 UI HAR。

## 一多适配

- phone / tablet / 2in1 布局相近：共用 `product/phone` + 断点 / 自适应 / 响应式。
- PC / TV / 穿戴 UX 大分叉：再拆独立 product HAP，复用同一套 features / common。
- 断点与窗口工具放 `common/platform` / `youi_kit`。

## 向 Notes1 学什么 / 不学什么

**学习：**

- 用 `product/{device}` 承载 Entry
- 业务引擎可下沉 `common`（类似 Notes1 datasource / grabthransfer）

**不照搬：**

- 不取消 `features/`
- 不建 Notes1 式 `components/` 混装包
- 不让 common 依赖带 UI 的业务 HAR

## 目录约定

```text
product/
├── README.md
├── phone/                    # Entry HAP（现网主产物）
│   └── src/main/ets/
│       ├── pages/            # Page 薄壳（含 bluetooth/ 等）
│       ├── shell/            # Tab / 导航装配
│       └── navigation/       # 路由常量
└── tablet/                   # 预留
    └── README.md
```

## 演进策略

1. **现在**：`product/phone` 唯一 Entry；`deviceTypes` 含 phone/tablet/2in1；蓝牙 Page 壳试点迁入 product。
2. **平板 UX 分叉时**：启用 `product/tablet` 独立 Entry。
3. **WiFi / NearLink**：按蓝牙同模式复制（引擎进 `common/yo_*`，Page 进 product）。
