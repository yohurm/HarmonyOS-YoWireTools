# 06-模块目录与 MVVM 装配规范

> **状态：定稿 · 2026-07-23**  
> **依据**：项目 `1.2-架构与MVVM规范` · ArkTS MVVM V2 · 本目录 `00`～`05`  
> **实现根**：`features/bluetooth/src/main/ets/`

---

## 1. 目标目录树

```text
features/bluetooth/src/main/ets/
├── constants/
├── domain/
│   ├── model/
│   │   ├── identity/     # DeviceIdentity, BluetoothTransportType
│   │   ├── device/       # BluetoothDevice, Favorite, Recent
│   │   ├── scan/         # BleScanFilter, Advertising, ScanPhase*
│   │   ├── spp/          # SppConnectParams, SppRuntimeState, UuidPreset
│   │   ├── gatt/         # GattConnectParams, ServiceTree, CharacteristicRef
│   │   ├── uart/         # BleSerialPreset, UartConnectPhase, ProfileMatchResult
│   │   └── session/      # BluetoothSessionKind, SessionLifecycle, SessionSummary
│   ├── repository/       # Contract + 分面接口
│   ├── service/
│   │   ├── registry/     # DeviceRegistry
│   │   ├── queue/        # CommandWriteQueue
│   │   ├── scan/         # Merger, MaskMatcher, AdParser, Timers
│   │   ├── spp/          # Reconnect, FailureHints
│   │   ├── gatt/         # OpQueue, WriteChunker, NotifyDispatcher, TreeBuilder
│   │   └── uart/         # SerialProfileMatcher
│   └── usecase/
│       ├── overview/ · classic/ · spp/ · ble/ · gatt/ · uart/
│       ├── device/ · command/ · shared/
├── data/
│   ├── datasource/platform/
│   ├── mapper/ · transport/ · repository/ · kit/ · verification/
├── viewmodel/
│   ├── overview/ · spp/ · ble/ · gatt/ · uart/ · settings/
└── ui/
    ├── page/ · view/ · component/ · menu/
    └── lab/              # P3 空壳预留，v1 无实现
```

迁移策略：**先新增目标路径文件并改 import，再删除旧路径**；单次 PR 保持可编译。

---

## 2. 分层职责

| 层 | 职责 | 禁止 |
| --- | --- | --- |
| `ui/page` | 装配 YoPageShell、绑 VM 生命周期、转发 `@Event` | Kit、DataSource、业务编排 |
| `ui/view` / `component` | 纯展示 + `@Param`/`@Event` | UseCase、Repository |
| `viewmodel` | `@ObservedV2` + `@Trace`；唯一 UI 状态出口 | 持有 socket / GattClientDevice |
| `domain/usecase` | 用例编排；stop-before-connect | ArkUI、资源文案堆砌 |
| `domain/service` | 无状态/会话策略、队列、匹配 | UI |
| `data/*` | Kit 适配、Transport、Mapper | 反向依赖 viewmodel/ui |

---

## 3. MVVM 禁令（Code Review 必查）

1. `ui/page` 不得 `import` `@kit.ConnectivityKit` 的 bluetooth 子模块或 `*DataSource`。
2. `viewmodel` 不得保存 `clientSocket:number` / `GattClientDevice`。
3. `domain` 不得依赖 `@kit.ArkUI` / 页面组件。
4. 跨路径状态只经 Session 摘要 + `feature_debug_core`；禁止 SPP VM 直接操作 GATT OpQueue。
5. 新功能优先 UseCase + 队列策略；禁止在 Page `@LocalBuilder` 堆业务。
6. SPP 连接参数只含 `classicDeviceId`；GATT/UART 只含 `bleDeviceId`。

---

## 4. ViewModel 装配表

| VM | 页面 | 主 UseCase |
| --- | --- | --- |
| `BtOverviewViewModel` | BluetoothFeaturePage | LoadOverview |
| `SppMainViewModel` | SppMainPage | Classic scan / paired / active list |
| `SppTerminalViewModel` | SppTerminalPage | Connect/Disconnect/Send/Observe |
| `BleScanViewModel` | BleScanPage / BleMain 扫描区 | Start/StopBleScan + Filter |
| `GattBrowserViewModel` | GattBrowserPage | 多会话 GATT ops |
| `UartMainViewModel` | UartMainPage | ConnectUart + Send |
| `BluetoothSettingsViewModel` | BluetoothSettingsPage | 设定读写（P1） |

---

## 5. Repository 分面

接口可拆、实现可暂聚合于 `BluetoothRepository`：

| 分面 | 代表方法 |
| --- | --- |
| Classic | loadPairedClassicCandidates, start/stopClassicScan, pair |
| Spp | createSppTransport, resolveClassicIdForSpp |
| BleScan | start/stopBleScan, filters |
| Gatt | createGattClient, ops by sessionId, maxSessions=4 |
| Identity | linkDualMode, favorites, recent |

---

## 6. Index 导出策略

- 对外导出：Page、主要 VM、领域模型、错误码、关键 UseCase。
- **不导出**：DataSource、Kit bridge、实验室未实现符号。

---

## 7. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-23 | 初稿定稿：目录树、禁令、VM 表、分面、导出策略 |
