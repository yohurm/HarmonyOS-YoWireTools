# 06-模块目录与 MVVM 装配规范

> **状态：修订 · 2026-07-27**  
> **依据**：项目 `1.2-架构与MVVM规范` · ArkTS MVVM V2 · 本目录 `00`～`05`  
> **实现根**：
> - 引擎：`common/yobluetooth/src/main/ets/`
> - UI：`features/bluetooth/src/main/ets/`（ViewModel + View + Dialog + Feature Page）
> - Page 壳：`product/phone/src/main/ets/pages/bluetooth/`（装配 + 路由入口；SPP Terminal 页在 Feature）

---

## 1. 目标目录树

```text
common/yobluetooth/src/main/ets/
├── constants/
├── domain/
│   ├── model/          # 含 spp/ · session/ · …
│   ├── repository/     # Facets + Contract
│   ├── service/        # Ledger · Catalog · Admission · Reconnect · …
│   └── usecase/
└── data/
    ├── datasource/platform/   # Classic / BLE / GATT（非 SPP）
    ├── platform/spp/          # SppPlatformGateway · SppRfcommClient（模块内）
    ├── mapper/ · transport/ · repository/ · kit/ · verification/

features/bluetooth/src/main/ets/
├── navigation/         # SppNavParams 等
├── viewmodel/
│   ├── BtOverviewViewModel.ets
│   ├── SppMainViewModel.ets
│   ├── SppTerminalViewModel.ets
│   ├── SppConnectDialogController.ets   # Dialog 生命周期 UseCase 出口
│   ├── SppPairingGuideController.ets
│   └── BleMainViewModel.ets
└── ui/
    ├── page/           # SppTerminalPage（focusSessionId）
    ├── dialog/         # PairingGuideDialog · SppConnectDialog（Content + open/close 壳）
    ├── view/ · component/ · menu/ · util/

product/phone/src/main/ets/pages/bluetooth/
├── BluetoothOverviewPage.ets
├── SppMainPage.ets      # 装配 SppMainVM；连接入口走 Dialog，无独立连接页
└── BleMainPage.ets
```

---

## 2. 分层职责

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| product `pages/` | 装配壳：创建 VM、绑生命周期、组合 Feature View、断点布局；打开 Dialog | Kit、DataSource、UseCase 编排（连接编排交给 Dialog Controller） |
| feature `ui/view` / `component` | 纯展示 + `@Param`/`@Event` | UseCase、Repository |
| feature `ui/dialog` | `openCustomDialog` + 自绘 AdvancedDialog 结构（标题居中 / ULTRA_THICK 模糊 / 底栏文字按钮）；回调 Controller | 直接 `new XxxUseCase()`；持有 socket；伪造系统配对/开蓝牙 UI；在 ComponentContent 内嵌套 `CustomContentDialogV2`（边距/宽度错乱） |
| feature `ui/page` | Feature 内页面（如 Terminal）：创建 Terminal VM、绑焦点会话 | 直接 `socket.*` |
| feature `viewmodel` | `@ObservedV2` / Dialog Controller；唯一 UI→UseCase 出口 | 持有 socket / GattClientDevice |
| `yobluetooth` domain/usecase | 用例编排 | ArkUI |
| `yobluetooth` data/* | Kit 适配、Transport、Mapper | 反向依赖 viewmodel/ui |

### 2.1 Dialog → Controller → UseCase

SPP 连接/配对**不经**独立连接页或 `SppMainViewModel.connect`：

```text
SppMainPage / Index
  → PairingGuideDialog.open
       → SppPairingGuideController.pairFromGuide
            → PairBluetoothDeviceUseCase + ObservePairingEventsUseCase
            → 仅 PairingState.PAIRED（bond）后 onPaired
  → SppConnectDialog.open
       → SppConnectDialogController.connectFromDialog
            → QuerySppConnectEligibilityUseCase → ConnectSppUseCase
  → 成功回调 sessionId → push SppTerminalPage
```

- Dialog **Content** 只改表单态并调用 hooks；UseCase 编排在 `viewmodel/*Controller`。
- 最终准入权威仍是 `ConnectSppUseCase`（预检可失败，UC 再校验）。
- 系统配对/开蓝牙弹窗与应用 RFCOMM Dialog **严格分离**（见 `01` / `02`）。
- `pairDevice` Promise 成功 ≠ 已配对；配对真相为 `bondStateChange` → `PAIRED`（平台 BONDED）。

---

## 3. MVVM 禁令（Code Review 必查）

1. product Page 不得 `import` `@kit.ConnectivityKit` 蓝牙子模块或 `*DataSource` / L1–L3 SPP 具体类。
2. `viewmodel` 不得保存 `clientSocket:number` / `GattClientDevice`。
3. `yobluetooth` domain 不得依赖 `@kit.ArkUI` / 页面组件。
4. 跨路径状态只经 Session 摘要 + `debug_core`。
5. SPP 连接参数只含 `classicDeviceId`；GATT/UART 只含 `bleDeviceId`。
6. Feature/product **不得** import `SppPlatformGateway` / `SppRfcommClient` / `SppTransportSession`（barrel 不导出）。

---

## 4. ViewModel / Dialog 装配表

| 表面（feature） | Page 壳 / 宿主 | 主 UseCase（yobluetooth） |
| --- | --- | --- |
| `BtOverviewViewModel` | BluetoothOverviewPage | LoadOverview |
| `SppMainViewModel` | SppMainPage | Classic scan / paired / active list |
| `SppPairingGuideController` | `PairingGuideDialog`（Dialog 生命周期） | Pair + ObservePairing（bond 真相） |
| `SppConnectDialogController` | `SppConnectDialog`（Dialog 生命周期） | QueryEligibility + ConnectSpp |
| `SppTerminalViewModel` | `ui/page/SppTerminalPage` | Send / Observe / Disconnect（焦点会话） |
| `BleMainViewModel` | BleMainPage | BLE scan entry |

**已移除**：`SppConnectPage` / `SppConnectViewModel` / 路由 `/bluetooth/spp/connect`。

---

## 5. Index 导出策略

- `yobluetooth`：导出 Repository、UseCases、models、error codes、PairingState、Ledger/Catalog/Admission 等 Domain 面；**不导出** L1–L3 具体实现（`SppPlatformGateway` / `SppRfcommClient` / `SppTransportSession`）及一般 DataSource / Kit bridge。
- `feature_bluetooth`：导出 ViewModel、Dialog Controller、View、`ui/page`、`ui/dialog` 业务表面。
- product：不对外导出 barrel。
