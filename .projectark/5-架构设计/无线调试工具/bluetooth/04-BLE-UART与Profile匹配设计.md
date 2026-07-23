# 04-BLE-UART 与 Profile 匹配设计

> **状态：定稿 · 2026-07-23**  
> **依据**：功能清单 `03-BLE-UART` · SimpleBluetoothLeTerminal · Connectivity Kit `ble` · 总册 `00`  
> **前置**：`00` 双地址 · `03` GATT 浏览器 · `05` 会话队列

---

## 1. 路径定位

| 项 | 约定 |
| --- | --- |
| 用户目标 | 快速串口 Profile 终端（对标 SimpleBT LE） |
| UI | **独立 L1**；连接后终端布局与 SPP **同构** |
| 传输 | 复用 `GattTransportSession` + `bleDeviceId`；禁止走 SPP |
| 发送 | 复用 `CommandWriteQueue`；按 `mtu-3` 切块经 `GattWriteChunker` |
| 失败 | **不得**在 UART 页复刻 GATT 树；跳转 GATT 浏览器 |

---

## 2. Profile 匹配

### 2.1 服务 `SerialProfileMatcher`

```text
input:  discovered GattServiceTree
output: ProfileMatchResult { profileId, serviceUuid, txChar, rxChar, cccdUuid }
```

| Profile | 优先级 | Service UUID（摘要） |
| --- | --- | --- |
| Nordic UART (NUS) | **P0** | `6e400001-b5a3-f393-e0a9-e50e24dcca9e` |
| TI CC254x | P1 | `0000ffe0-…` |
| Microchip RN487x | P1 | `49535343-FE7D-…` |
| Telit Bluemod | P1 | `0000FEFB-…` |
| 自定义 | P2 | 用户映射存 ⚙ |

匹配顺序：设备级保存映射 → 全局默认 → 自动遍历树 → 失败。

CCCD：`00002902-0000-1000-8000-00805f9b34fb`。

### 2.2 阶段条（必须显式）

| 步 | 阶段 | 失败动作 |
| --- | ---: | --- |
| 1 | GATT 连接中 | 错误卡 + 重试 |
| 2 | 服务发现 | 同左 |
| 3 | Profile 匹配 | **改用 GATT** CTA |
| 4 | MTU + CCCD Notify | 展示 MTU / payloadSize |
| 5 | 就绪 | 进入终端 |

---

## 3. 与 GATT / SPP 边界

| 能力 | UART | GATT | SPP |
| --- | --- | --- | --- |
| 地址 | bleDeviceId | bleDeviceId | classicDeviceId |
| 连接前 stop 扫描 | 是 | 是 | Inquiry stop |
| 操作队列 | WriteQueue + OpQueue | OpQueue | WriteQueue |
| 业务帧切分 | 否（字节流） | 否 | 否 |

---

## 4. 目录与类型

```text
domain/model/uart/          # UartConnectPhase, ProfileMatchResult, BleSerialPreset
domain/service/uart/        # SerialProfileMatcher
domain/usecase/uart/        # ConnectUart, DisconnectUart, SendUartPayload
viewmodel/uart/             # UartMainViewModel
ui/page/UartMainPage.ets
```

既有 `BleSerialEndpoints` / `BleSerialPlatformMapper` 迁入或委托给 Matcher，避免 UI 直调 Mapper。

---

## 5. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-23 | 初稿定稿：独立路径、Matcher、阶段条、失败跳转 |
