---
id: research.kai-morich-simple-bluetooth-le-terminal
type: project-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [java]
  frameworks: [android]
also_relevant: []
utilization: [adapt, anti-pattern]
source:
  platform: github
  repo: kai-morich/SimpleBluetoothLeTerminal
  url: https://github.com/kai-morich/SimpleBluetoothLeTerminal
  head: f322c06c84c60a1e647048094c0e58e683a2a1ea
  cloned_to: "/tmp/YoAgentResearch/kai-morich--SimpleBluetoothLeTerminal"
studied_at: 2026-10-09
related: [research.kai-morich-simple-bluetooth-terminal, research.synthesis.client-runtime]
---

# kai-morich/SimpleBluetoothLeTerminal

## 入选理由

与经典终端同一作者、同一终端壳（HEAD 同为 2026-04-12），但传输是 BLE GATT 串口，不是结构重复到可以丢弃的一份拷贝。它把多种厂商 UART 收成可切换的 `DeviceDelegate`，并处理 MTU、写队列、配对广播。通用 GATT 浏览器仍然不在这里。

## 项目是什么

Android BLE 串口终端。扫描周围 LE 设备后，按预设特征连接：CC254x（`ffe0`/`ffe1`）、Nordic UART（`6e400001-b5a3-f393-e0a9-e50e24dcca9e`）、Microchip、Telit TIO。终端菜单与经典版相同：清屏、换行、HEX、后台通知。

## 架构

- `DevicesFragment.startScan()`：位置权限与定位服务打开时走 `BluetoothLeScanner.startScan(leScanCallback)`，没有 `ScanFilter`。定位服务关闭或 scanner 为空时退回 `BluetoothAdapter.startDiscovery()`（经典+LE，注释写明结果更少或更慢）。扫描有 `LE_SCAN_PERIOD` 定时停止。
- `SerialSocket` 把 GATT 包成 connect / write / 回调。`DEFAULT_MTU = 23`，`payloadSize = MTU - 3`，`requestMtu(MAX_MTU)` 且 `MAX_MTU = 512`。写特征使用 `WRITE_TYPE_NO_RESPONSE`。`writePending` 与 `writeBuffer` 保证前一次写未完成不再叠写。
- 配对：注册 `ACTION_BOND_STATE_CHANGED` 与 `ACTION_PAIRING_REQUEST`。Telit 走独立 delegate（信用额特征）。
- 后台断开与经典版相同：Service 上下文、立即 disconnect、界面不在时排队。

## 利用价值

| 点 | 方式 | 说明 |
|----|------|------|
| 多 UART 预设表 | adapt | 预设是服务 UUID + 读/写/CCCD 特征的表，匹配失败应告诉用户「不是已知串口」，并留给通用 GATT。 |
| MTU 减 3 作为载荷 | adapt | 未协商默认 23，载荷 20。HarmonyOS 范围是 [23, 517]，协商成功以 `BLEMtuChange` 为准，不能把 `requestMtu` 的返回值当成已生效。 |
| 写队列防重入 | reuse-pattern | 官方错误码写明前序异步未完成会 2900099。一条写完再下一条。 |
| 无过滤全量扫描 | anti-pattern | 车库场景会扫到大量无关设备。HarmonyOS 应把 `ScanFilter` 白名单作为专家项，模糊名称放在回调里。 |
| 定位服务失败就退回经典发现 | anti-pattern | 那是 Android 6 的权限历史。HarmonyOS 经典发现与 BLE 扫描地址空间不同，不能互为回退。 |

## 架构设计经验

串口 profile 是 GATT 上的约定，不是第二种套接字。CCCD `00002902-0000-1000-8000-00805f9b34fb` 由启用通知时写入。无响应写适合吞吐，丢确认时调用方看不到对端是否收下。预设表要可扩展，但每种预设的读写特征方向必须写死在表里，不能运行时猜。

## 与当前工作

能直接用的：Nordic UART / CC254x / Microchip 的 UUID 作为预设数据；默认 MTU 23；无响应写；订阅通知前先等 MTU 与服务发现完成。

必须改写的：扫描过滤、虚拟 MAC、系统配对框。Android 的位置权限门禁不要搬到 HarmonyOS；鸿蒙 BLE 扫描权限是 `ACCESS_BLUETOOTH`。

明确不要用的：不要在 BLE 扫描失败时调用经典 `startBluetoothDiscovery` 凑设备列表。不要把 512 写成一定会协商成功。

## 阅读范围

读过：`SerialSocket.java` 的 UUID、MTU、连接/断开、配对接收器，以及 `WRITE_TYPE_NO_RESPONSE` 附近；`DevicesFragment.java` 的 `startScan`；`menu_terminal.xml` 与经典版同构（已读经典版菜单）。未读 Telit delegate 的信用额状态机全文，只确认它是独立 delegate。
