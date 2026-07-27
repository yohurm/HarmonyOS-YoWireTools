# 蓝牙模块详细设计索引

本目录细化蓝牙模块设计。依据 PRD、功能总清单 `00`、竞品对照，以及 HarmonyOS Connectivity Kit（access / connection / ble / socket）与短距 FAQ。

## 阅读顺序

| 顺序 | 文档 | 说明 |
| --- | --- | --- |
| 1 | **`00-传输类型与双地址身份模型设计.md`** | 底座必读：transport、双地址、SPP 白名单、桥接 |
| 2 | `01-经典蓝牙发现配对与设备身份设计.md` | Inquiry、已配对非 LE、配对 |
| 3 | `02-SPP终端连接收发与日志设计.md` | **v1.3** 多路 RFCOMM、Ledger、Connect Dialog、终端 |
| 4 | `03-BLE扫描GATT与串口预设设计.md` | 扫描、GATT 多会话、OpQueue |
| 5 | **`04-BLE-UART与Profile匹配设计.md`** | 独立 UART 路径、Matcher、失败→GATT |
| 6 | **`05-会话队列与统一后端集成设计.md`** | SessionKind、队列、SPP/GATT 多会话对称 |
| 7 | **`06-模块目录与MVVM装配规范.md`** | 目录树、Dialog controller、VM 装配、Index 导出 |
| — | [`../02-蓝牙模块架构设计.md`](../02-蓝牙模块架构设计.md) | 总册概览 |

## 蓝牙模块总原则

1. 页面不直接持有平台连接真相；经 Repository/DataSource → `SessionRuntimeStore`。
2. 经典发现、SPP、BLE 扫描、GATT/UART 连接是**独立会话**，状态不混用。
3. 传输类型以 `getRemoteDeviceTransport` 为准；CoD 只作展示。
4. 双地址分字段：SPP 只用 `classicDeviceId`；GATT/UART 只用 `bleDeviceId`。
5. SPP 列表只含 `BR_EDR | DUAL`；过滤在 Data/Domain。
6. SPP/UART 为 byte stream；日志保留原始 chunk。
7. GATT / SPP 应用层最多 4 会话；SPP 按 `(classicDeviceId, serviceUuid)` 去重（`SppSessionLedger`）。
8. 连接前必须 stop Inquiry / BLE scan。
9. 所有 `on` 必须有 `off`；closed Transport 不可复用。
10. `connectAllowedProfiles` 永不承担 SPP。
11. 严格 MVVM：见 `06` 禁令（含 Dialog→controller→UseCase）。

## 实现状态表（2026-07-27 · 多会话重构）

| 项 | 架构要求 | 代码现状 |
| --- | --- | --- |
| transport + 双地址 | 必有 | **已落地** |
| loadPairedClassicCandidates | 滤 LE | **已落地** |
| SppTransportSession + Gateway/Rfcomm | L1–L3 分层；barrel 不导出具体类 | **已落地** `data/platform/spp` + `data/transport`（Index 仅导出 Domain/UC） |
| GattTransportSession | 独立会话 | **已有**（未与 SPP 同轮重构） |
| SppSessionLedger | 槽位唯一真相 | **已落地** |
| CommandWriteQueue + 背压 | SPP/UART TX | **已落地** |
| ~~SppActiveWritePolicy~~ | 已删除 | **禁止复活** |
| ~~SppSocketDataSource 单例读~~ | 已删除 | **禁止复活** |
| 连接前 stop 扫描 | UseCase 强制 | **已落地** |
| GATT 会话上限 4 | tryReserveBleConnection | **已落地** |
| SPP 会话上限 4 | Ledger.tryReserve | **已落地** |
| SerialProfileMatcher | Nordic/TI | **已落地** |
| SppMain + ConnectDialog + Terminal | P0；无独立连接页 | **已落地** Dialog + `SppTerminalPage`/`SppTerminalViewModel` |
| PairingGuideDialog | 系统配对与应用 Dialog 分离 | **已落地** |
| FAILED teardown | `SppSessionTeardown.failCleanup` | **已落地** |
| 单一重连所有者 | 仅 `SppReconnectCoordinator`（Connect bind；Transport `requestReconnect`） | **已落地** |
| Dialog→Controller→UseCase | 06 MVVM；配对真相 = bond PAIRED | **已落地** |
| Observe ∩ Ledger | Catalog 无 Ledger key 不展示 | **已落地** |
| Repository 分面接口 | 06 | **已落地** Facets |
| Index 导出卫生 | 不导出 L1–L3 具体类 | **已落地** |

---

## 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-23 | 接入 04/05/06；实现状态表 |
| 2026-07-27 | SPP v1.3：Connect Dialog 替代连接页；系统/应用弹窗分层；状态机三层分离 |
| 2026-07-27 | Ledger / Gateway 标为已落地；SessionKey 规范化与 FAILED release 闭环 |
| 2026-07-27 | 收口：FAILED teardown / Coordinator 单一重连 / Facet / Dialog Controller / Observe∩Ledger |
