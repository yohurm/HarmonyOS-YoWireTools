# 06-模块目录与 MVVM 装配规范

> **状态：修订 · 2026-07-23（官方折中）**  
> **依据**：项目 `1.2-架构与MVVM规范` · ArkTS MVVM V2 · 本目录 `00`～`05`  
> **实现根**：
> - 引擎：`common/yo_bluetooth/src/main/ets/`
> - UI：`features/bluetooth/src/main/ets/`（ViewModel + View）
> - Page 壳：`product/phone/src/main/ets/pages/bluetooth/`

---

## 1. 目标目录树

```text
common/yo_bluetooth/src/main/ets/
├── constants/
├── domain/
│   ├── model/
│   ├── repository/
│   ├── service/
│   └── usecase/
└── data/
    ├── datasource/platform/
    ├── mapper/ · transport/ · repository/ · kit/ · verification/

features/bluetooth/src/main/ets/
├── viewmodel/
└── ui/
    ├── view/ · component/ · menu/ · util/

product/phone/src/main/ets/pages/bluetooth/
├── BluetoothOverviewPage.ets
├── SppMainPage.ets
└── BleMainPage.ets
```

---

## 2. 分层职责

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| product `pages/` | 装配壳：创建 VM、绑生命周期、组合 Feature View、断点布局 | Kit、DataSource、UseCase 编排 |
| feature `ui/view` / `component` | 纯展示 + `@Param`/`@Event` | UseCase、Repository |
| feature `viewmodel` | `@ObservedV2` + `@Trace`；唯一 UI 状态出口 | 持有 socket / GattClientDevice |
| `yo_bluetooth` domain/usecase | 用例编排 | ArkUI |
| `yo_bluetooth` data/* | Kit 适配、Transport、Mapper | 反向依赖 viewmodel/ui |

---

## 3. MVVM 禁令（Code Review 必查）

1. product Page 不得 `import` `@kit.ConnectivityKit` 蓝牙子模块或 `*DataSource`。
2. `viewmodel` 不得保存 `clientSocket:number` / `GattClientDevice`。
3. `yo_bluetooth` domain 不得依赖 `@kit.ArkUI` / 页面组件。
4. 跨路径状态只经 Session 摘要 + `debug_core`。
5. SPP 连接参数只含 `classicDeviceId`；GATT/UART 只含 `bleDeviceId`。

---

## 4. ViewModel 装配表

| VM（feature） | Page 壳（product） | 主 UseCase（yo_bluetooth） |
| --- | --- | --- |
| `BtOverviewViewModel` | BluetoothOverviewPage | LoadOverview |
| `SppMainViewModel` | SppMainPage | Classic scan / paired / active list |
| `BleMainViewModel` | BleMainPage | BLE scan entry |

---

## 5. Index 导出策略

- `yo_bluetooth`：导出 Repository、UseCases、models、error codes；**不导出** DataSource / Kit bridge。
- `feature_bluetooth`：导出 ViewModel、View、业务组件。
- product：不对外导出 barrel。
