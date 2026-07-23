# 蓝牙模块详细设计索引

本目录细化蓝牙模块设计。依据 PRD、功能总清单 `00`、竞品对照，以及 HarmonyOS Connectivity Kit（access / connection / ble / socket）与短距 FAQ。

## 阅读顺序

| 顺序 | 文档 | 说明 |
| --- | --- | --- |
| 1 | **`00-传输类型与双地址身份模型设计.md`** | 底座必读：transport、双地址、SPP 白名单、桥接 |
| 2 | `01-经典蓝牙发现配对与设备身份设计.md` | Inquiry、已配对非 LE、配对 |
| 3 | `02-SPP终端连接收发与日志设计.md` | 单活跃写、TX 队列、终端、日志 |
| 4 | `03-BLE扫描GATT与串口预设设计.md` | 扫描、GATT 多会话、OpQueue |
| 5 | **`04-BLE-UART与Profile匹配设计.md`** | 独立 UART 路径、Matcher、失败→GATT |
| 6 | **`05-会话队列与统一后端集成设计.md`** | SessionKind、队列、debug_core |
| 7 | **`06-模块目录与MVVM装配规范.md`** | 目录树、禁令、VM 装配 |
| — | [`../02-蓝牙模块架构设计.md`](../02-蓝牙模块架构设计.md) | 总册概览 |

功能清单总册：`.projectark/7-UIUX设计/.../02-蓝牙模块/00-蓝牙功能总清单与优先级矩阵.md`

## 蓝牙模块总原则

1. 页面不直接持有平台连接真相；经 Repository/DataSource → `SessionRuntimeStore`。
2. 经典发现、SPP、BLE 扫描、GATT/UART 连接是**独立会话**，状态不混用。
3. 传输类型以 `getRemoteDeviceTransport` 为准；CoD 只作展示。
4. 双地址分字段：SPP 只用 `classicDeviceId`；GATT/UART 只用 `bleDeviceId`。
5. SPP 列表只含 `BR_EDR | DUAL`；过滤在 Data/Domain。
6. SPP/UART 为 byte stream；日志保留原始 chunk。
7. GATT 必须先服务发现再读写/订阅；操作串行；应用层最多 4 会话。
8. 连接前必须 stop Inquiry / BLE scan。
9. 所有 `on` 必须有 `off`；closed Transport 不可复用。
10. `connectAllowedProfiles` 永不承担 SPP。
11. 严格 MVVM：见 `06` 禁令。

## 实现状态表（2026-07-23 · 功能层优先）

| 项 | 架构要求 | 代码现状 |
| --- | --- | --- |
| transport + 双地址 | 必有 | **已落地** |
| loadPairedClassicCandidates | 滤 LE | **已落地** |
| Spp / Gatt TransportSession | 独立 | **已落地** |
| DeviceRegistry | 收藏/最近/双模 | **已落地** `service/registry` |
| CommandWriteQueue + 背压 | SPP/UART TX | **已落地** `service/queue` |
| SppActiveWritePolicy | 单活跃写端 | **已落地** `service/spp` |
| 连接前 stop 扫描 | UseCase 强制 | **已落地** ConnectSpp / ConnectGatt / ConnectUart |
| GATT 会话上限 4 | tryReserveBleConnection | **已落地** Repository |
| SerialProfileMatcher | Nordic/TI | **已落地** `service/uart` |
| ConnectUartUseCase | 阶段 + 无 Profile 错误码 | **已落地** |
| Repository 分面接口 | 06 | **已落地** Facets（实现仍聚合） |
| SppTerminal / Uart / Settings UI | P0/P1 | **暂缓 UI**（先功能层） |
| Gatt 多会话浏览器 UI | P1 | **暂缓 UI** |
| 实验室 | P3 缝 | 不实现 |

---

## 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-23 | 接入 04/05/06；删除过时审查快照；改为实现状态表 |
