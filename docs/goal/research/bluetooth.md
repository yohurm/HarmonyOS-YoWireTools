---
id: research.bluetooth
type: topic-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [ArkTS, Kotlin, Java, C#]
  frameworks: [HarmonyOS Connectivity Kit, Android BLE, UWP Bluetooth LE]
also_relevant: []
utilization: [adapt, lesson-only, anti-pattern]
source:
  platform: github
  url: https://github.com/yohurm/HarmonyOS-Developer-docs
  repos:
    - NordicSemiconductor/Android-nRF-Toolbox
    - kai-morich/SimpleBluetoothTerminal
    - kai-morich/SimpleBluetoothLeTerminal
    - microsoft/BluetoothLEExplorer
  cloned_to:
    - /tmp/YoAgentResearch/yohurm--HarmonyOS-Developer-docs
    - /tmp/YoAgentResearch/NordicSemiconductor--Android-nRF-Toolbox
    - /tmp/YoAgentResearch/kai-morich--SimpleBluetoothTerminal
    - /tmp/YoAgentResearch/kai-morich--SimpleBluetoothLeTerminal
    - /tmp/YoAgentResearch/microsoft--BluetoothLEExplorer
studied_at: 2026-10-09
related: [docs/goal/checklist/bluetooth.md]
---

# 蓝牙专业调试能力

## 背景

主题是手机工具箱里可以诚实提供的蓝牙调试与测试：扫描过滤、配对、GATT / SPP、中心与外围、吞吐、报文检查、回连、日志、权限和诊断。

官方规范先于开源实现。HarmonyOS 文档镜像是 `yohurm/HarmonyOS-Developer-docs` 的 `1d85fab9f9750a9e79a8ccd10509e41753e1ef45`（2026-10-09）。下文未写仓库名的路径都相对该镜像根。开源实现按联网深研手册浅克隆到 `/tmp/YoAgentResearch/<owner>--<repo>`。手册要求 GitHub 默认 SSH；本环境没有可用 SSH，改用 HTTPS `--depth 1`。源码留在临时目录，不进入本仓库。

本文件是模块笔记，把官方能力边界和四份调试应用的可抄、须改、不要抄放在一起。细项验收在 `docs/goal/checklist/bluetooth.md`。YoAgentDocs 知识库的归档位置是 `research/by-stack/client-runtime/`；产品仓库只放这一篇，不把知识库目录树复制进来。

判定只用三档：**支持**（镜像写了可调用的 API 与约束）、**缺口**（文档写明没有，或只在系统应用、开发者模式、外部工具）、**待证**（API 在，但是否在当前设备、API 等级或 ACL 上可用要真机看）。概述写明蓝牙模块暂不支持模拟器。

## 关键结论

专业调试台把发现和连接拆开，把串口预设和通用 GATT 拆开。一次传输回调是一段字节，不是一条业务消息。写操作必须串行。吞吐测量和逐包日志不能同时开。配对框属于系统。错误要能对上未认证、禁止写、MTU、报文超长，而不是一律「操作失败」。

### 能力对照

| 能力 | 行业里专业工具怎么做 | HarmonyOS | 判定 |
|------|----------------------|-----------|------|
| 权限 | Android 12+ 的 BLUETOOTH_SCAN/CONNECT；旧版还绑定位 | API 10+ 用 `ohos.permission.ACCESS_BLUETOOTH`。`USE_BLUETOOTH` 只服务已废弃的 API 7/8/9。开关订阅从 API 18 起不再校验该权限 | 支持 |
| 开关 | 应用内开关，系统仍可能弹窗 | `access.enableBluetooth` / `disableBluetooth` 弹系统框，用户拒绝则保持原状态。状态机含 `STATE_OFF`、`TURNING_ON`、`ON`、`BLE_ON` 等。只有 `STATE_ON` 后才能用其他蓝牙能力 | 支持 |
| 经典发现过滤 | 按名称、RSSI、COD 过滤 | `startBluetoothDiscovery()` 无过滤参数，约 12s，扫描中不可再调，停后才能再开。FAQ 写明经典扫描无法配置过滤参数。名称/RSSI/类型只能在应用层滤 `discoveryResult`（API 18+：地址、RSSI、名称、`deviceClass`）。API 17 及以前 `bluetoothDeviceFind` 只有地址 | 支持发现；平台过滤是缺口 |
| 经典结果里混有 BLE | 列表按传输类型分开 | 该接口同时发现传统与 BLE。应用必须再分流。`getRemoteDeviceTransport` 从 API 20 起 | 支持，分流在应用层 |
| BLE 扫描过滤 | BLE Explorer：名称、UUID、厂商数据、RSSI、原始 AD | `ScanFilter` 是白名单。字段含 deviceId/name/serviceUuid(+mask)/serviceSolicitationUuid(+mask)/serviceData(+mask)/manufactureId+data+mask。`rssiThreshold` 与带类型的 `address` 从 API 23。`null` 过滤器表示取消过滤。模糊名称要在回调里做，不能当成 `name` 的精确字段 | 支持 |
| 扫描模式 | 低功耗 / 低延迟 | `ScanDuty`：`LOW_POWER`、`BALANCED`、`LOW_LATENCY`。`phyType` 默认 1M，或 `PHY_LE_ALL_SUPPORTED`。`interval` 只在批量上报时生效。API 15+ `BleScanner` 多路；API 14 及以前全局单路 | 支持 |
| 广播原始字节 | Explorer 展示 AD 段 | `ScanResult.data` 是未解析广播。API 22+ 另给 flags、厂商表、服务表、UUID、发射功率 | 支持 |
| 本机可被发现 | 调试器可让手机可被扫到 | `setBluetoothScanMode` API 在，但指南写「非系统应用一般不用关注」，系统设置决定模式 | 待证 |
| 配对 | 系统对话框；应用看 bond 状态 | `pairDevice`（API 21 起可带 `BluetoothAddress` 类型）。结果看 `bondStateChange`，不是 Promise。`setDevicePairingConfirmation` 还要 `MANAGE_BLUETOOTH`，仅系统应用。`setDevicePinCode` 只要 `ACCESS_BLUETOOTH`。取消配对无 API，只能引导系统设置 | 支持发起与观察；取消配对是缺口；应用自绘确认框是缺口 |
| 虚拟 MAC | 专业工具仍显示稳定 ID | 扫描与 `getDeviceId` 默认虚拟地址。未配对时重启蓝牙会变。配对后固化。API 16 `addPersistentDeviceId` 另需 `PERSISTENT_BLUETOOTH_PEERS_MAC`（ACL）。卸载重装失效；对端真实地址变了也失效。FAQ 建议一般走配对，而不是申请该受限权限 | 支持虚拟地址；免配对固化是待证（ACL） |
| 双模 | 同一物理设备两条链路 | FAQ：用已连接 BLE 的虚拟地址 `pairDevice`，配对列表会同时出现经典记录。BLE 扫描地址不能直接 `sppConnect`。先经典再 BLE 的桥接，FAQ 写明目前不支持 | 支持 BLE→经典配对；反向桥接是缺口 |
| SPP 客户端 | SimpleBluetoothTerminal：标准 UUID、原始字节 | `socket.sppConnect`，UUID 必须与对端一致。标准 Serial Port UUID 可用，也可用自定义 UUID。未配对 2900016。FAQ：单次 `sppWrite` 最好 ≤600 字节，不建议超过 1024 | 支持 |
| SPP 服务端 | 工装常要手机当从 | `sppListen` + `sppAccept` + `sppCloseServerSocket` | 支持 |
| L2CAP | 较少出现在通用终端 | API 20+ `SPP_L2CAP` 与 `SPP_L2CAP_BLE`，PSM 用 `getL2capPsm`。写入不得超过 `getMaxTransmitDataSize`（API 22） | 支持 API；产品是否做留到设计 |
| GATT 客户端 | Explorer：发现服务、读、写、通知、描述符 | `createGattClientDevice`、`connect`、`getServices`、读/写特征与描述符、`setCharacteristicChangeNotification` / `Indication`、`on('BLECharacteristicChange')`。`getServices` 必须在连接成功之后、其他特征操作之前。通知订阅要排在 MTU 与服务发现成功之后，否则 2900007/2900099 | 支持 |
| 写类型 | 有响应 / 无响应 | `GattWriteType.WRITE`（对端确认）与 `WRITE_NO_RESPONSE` | 支持 |
| GATT 服务端 | Explorer 发布本地服务 | `createGattServer`、`addService`、读写请求回调里 `sendResponse`、`notifyCharacteristicChanged`。不应答会导致对端订阅一直阻塞 | 支持 |
| 广播 | 外围角色 | `startAdvertising`。传统报文最长 31 字节，超出 2902054。不能直接写任意 AD Type：`serviceUuids`、`serviceData`（0x16）、`manufactureData`（0xFF）、`includeDeviceName`（0x09）各有固定 Type。扩展广播 `isExtended` 自 26.0.0，且与可连接、扫描响应的组合有互斥。`duration` 单位 10ms，0 表示一直广播 | 支持；任意 AD Type 是缺口 |
| MTU | BLE 终端请求 512，载荷按 MTU-3 | `setBLEMtuSize` 范围 [23, 517]，未协商默认 23。必须已连接。结果看 `BLEMtuChange`，不要把调用返回当成协商完成。FAQ 建议在 `getServices` 之前调用 | 支持 |
| PHY | 1M / 2M / Coded | 客户端与服务端均有 `readPhy` / `setPhy` / PHY 更新回调，API 23。`BlePhy`：1M、2M、CODED（S2 500 kbit/s，S8 125 kbit/s） | 支持 API；芯片是否具备待证（错误码 801） |
| 连接间隔 | 桌面调试器可填 interval/latency/timeout 数字 | 没有这些数字。API 22 `updateConnectionParam` 只有 `LOW_POWER` / `BALANCED` / `HIGH`。大量传输用 `HIGH`，传完回到 `BALANCED` | 数字间隔是缺口；三档枚举支持 |
| 吞吐 | nRF Toolbox：无响应写 + 分片 + 计时 + 可选对端计数；计时期间停日志 | 应用层可做。平台不提供「吞吐测试」API。分片上限来自协商 MTU。SPP 大包另有 FAQ 的 600/1024 建议，且大数据不要堵主线程 | 支持（应用层测量） |
| 空口抓包 | Wireshark / Ellisys 打开 HCI | 应用内没有 HCI 套接字。开发者模式一键采集从 API 26.0.0 起，Phone/Tablet，约 30 秒，文件在本地。Release 去掉 payload 只留 Header。分析工具在 PC | 应用内抓包是缺口；开发者采集支持，payload 在 Release 上是缺口 |
| 回连 | 保存地址再连 | 配对可固化虚拟地址，之后 `getPairedDevices` 直连。免配对固化要 ACL 权限。GATT 重连必须丢掉旧 `GattClientDevice` 再创建，否则 2900099 子原因写明对象未销毁。扫描进行中不允许连接 | 支持；免配对持久化待证 |
| 后台 | Android 前台服务 + 通知 | FAQ：进程会被杀掉。长时任务类型 `BLUETOOTH_INTERACTION`，权限 `KEEP_BACKGROUND_RUNNING`，并在 `module.json5` 声明 `backgroundModes`。车钥匙子类型另有限制，不属于通用调试 | 支持长时任务；不声明则会断 |
| 已连接设备枚举 | 系统设置里的已连接 | `ble.getConnectedBLEDevices`；API 26.0.0 起 `connection.onAclStateChange`（可再要 `GET_BLUETOOTH_PEERS_MAC`）。`connectAllowedProfiles` 不管 SPP | ACL 监听支持（版本新）；SPP 是否出现在系统「已连接」待证 |
| Profile 电量 | 耳机电量 | `getRemoteDeviceBatteryInfo` API 12，仅对应 profile，不是 GATT Battery Service 的替代 | 支持该 API；与 GATT 0x180F 不是同一条 |

错误码主表在 `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/错误码/蓝牙服务子系统错误码.md`。调试台至少要单独呈现：2900001 服务停止、2900003 开关关闭、2900007 超时、2900009 硬件资源不足、2900010 资源上限、2900011 操作频繁、2900016 未配对、2900099 操作失败（含参数、前序未完成、扫描中禁止连接、GATT 未连接、重连未销毁客户端）、2901000–2901007 GATT 权限/加密、2902050 扫描失败、2902054 广播超长。

C API `oh_bluetooth.h` 从 API 13 起只有开关状态查询，不能当调试面。已停止维护的 `ohos.bluetooth` / `ohos.bluetoothManager` 不作为新能力依据。

API 文件：

- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.bluetooth.access 蓝牙access模块.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.bluetooth.connection 蓝牙connection模块.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.bluetooth.ble 蓝牙ble模块.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.bluetooth.socket 蓝牙socket模块.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.bluetooth.common 蓝牙common模块.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/C API/头文件/oh_bluetooth.h.md`

## 分歧与取舍

| 分歧 | 取舍 |
|------|------|
| 经典终端不扫描，只列已配对 | 调试台仍要发现，但发现结果不能直接当 SPP 已就绪。未配对先走系统配对。 |
| BLE 终端无 `ScanFilter`，定位服务关闭就退回经典发现 | 不学。HarmonyOS 经典扫描不能当 BLE 扫描的替身，两边地址也不能混用。 |
| nRF 吞吐绑定自家特征 UUID | 通用调试台的吞吐是：对用户选定的可写特征做无响应写，并显示字节/秒。不要内置 `00001524-0000-1000-8000-00805F9B34FB` 才算吞吐。对端统计读数是加分项，不是唯一算法。 |
| BLE Explorer 能按任意 AD 段过滤，也能发布 HID | 过滤可学。任意 AD Type 写入不要学。HID 注入不在本次通用调试范围。 |
| 桌面 nRF Connect 口碑高 | 其开源仓库 `pc-nrfconnect-ble` 只剩启动器，GATT 引擎是下载的二进制。不用用户文档代替源码下实现结论。 |

## 开源实现

四份都读了源码。HEAD 记在各节。利用方式只用 adapt、reuse-pattern、lesson-only、anti-pattern。

### NordicSemiconductor/Android-nRF-Toolbox

- 仓库：https://github.com/NordicSemiconductor/Android-nRF-Toolbox
- HEAD：`c7f8e443ab706fe5a2c03368a05488880c8299ed`（提交说明为 2026-08-26 的依赖升级）
- 克隆：`/tmp/YoAgentResearch/NordicSemiconductor--Android-nRF-Toolbox`
- 入选：仍在维护的 BLE 工具箱。README 把 UART 与 Throughput 列为正式 profile。通用 GATT 浏览器不在这个仓库里。

它是容器应用：心率、血压、CSC/RSC、血糖、UART、吞吐、Blinky、Channel Sounding。连接依赖 Kotlin BLE Library。DFU 已从本应用移走，README 指向 Android-DFU-Library 与 nRF Connect Device Manager。

`app/` 的 `ScannerDestination.kt`、`HomeView.kt` 按 `Profile.UART` 分流。`ProfileService` 一个前台服务管全部连接，Activity 解绑后连接仍在，断连原因向外发布。`ThroughputManager` 绑定特征 `00001524-0000-1000-8000-00805F9B34FB`，用 `WriteType.WITHOUT_RESPONSE` 按 `maxWriteValueLength` 分片，`measureTime` 计时，再 `read()` 取对端统计；计时期间把 `peripheral.logger` 置空。`UARTManager.sendText` 按 `maxWriteLength` 分片。宏和换行在 `UARTMacro`、`MacroEol`、`UARTConfiguration`。日志走 nRF Logger API，按设备一份，不是 logcat。

| 点 | 方式 | 说明 |
|----|------|------|
| 吞吐与日志互斥 | adapt | 压测时关闭逐包日志。HarmonyOS 侧把「记录原始字节」和「测速率」分成两种会话模式。 |
| 按 ATT 载荷分片 | adapt | 分片长度来自当前可写长度，不写死 20。对应协商后的 MTU 减 ATT 开销。 |
| UART 预设与通用 GATT 分开 | reuse-pattern | Nordic UART 是快捷路径。任意服务仍走 GATT 浏览器。 |
| 前台服务保住连接 | lesson-only | 不能抄成 Android Service。后台走长时任务 `BLUETOOTH_INTERACTION`。 |
| 把 DFU 塞进通用调试台 | anti-pattern | README 已把 DFU 迁出。固件升级不属于通用收发。 |

Profile 是插件：发现服务后按 UUID 挂 `ServiceManager`，缺服务要通知观察者。吞吐特征不可写就失败，不静默改用别的特征。不要把 `CentralManager` / `WriteType` 搬进 ArkTS。本仓库没有 SPP，没有空口抓包，没有通用 GATT 树。目录里残留的 DFU 视图以 README「已移出」为准。

读过：`README.md`；`profile_manager/.../ThroughputManager.kt`；`UARTManager.kt` 的 `sendText`；`HomeView.kt` 的 UART 分流；`view/throughput` 与 `view/uart` 目录。未读医疗 profile 解析器与 Channel Sounding。

### kai-morich/SimpleBluetoothTerminal

- 仓库：https://github.com/kai-morich/SimpleBluetoothTerminal
- HEAD：`688a628e04cea5c1e7ce253229a5feb90d104ea9`（2026-04-12）
- 克隆：`/tmp/YoAgentResearch/kai-morich--SimpleBluetoothTerminal`
- 入选：仍在维护的经典 SPP 终端。它故意不做 Inquiry，正好把「SPP」和「经典发现」拆开。

`DevicesFragment.refresh()` 只遍历 `BluetoothAdapter.getBondedDevices()`。全仓库 Java/XML 没有 `startDiscovery`。`SerialSocket` 固定 `00001101-0000-1000-8000-00805F9B34FB`，`createRfcommSocketToServiceRecord` 后在工作线程连接。读循环用 1024 字节缓冲，一次 `read` 原样交给监听者。构造函数拒绝 Activity 作 Context。后台断开立刻 `disconnect()`，不把错误排队到界面回来。`SerialService` 在界面不在前台时把连接、读、错误放进双队列。未连接的 `write` 抛 `not connected`。菜单是清屏、换行（默认 CRLF）、HEX、后台通知。

| 点 | 方式 | 说明 |
|----|------|------|
| 一次 read 即一段字节 | reuse-pattern | 不做业务分包。日志保存这次回调的原始长度。 |
| 已配对才进 SPP | adapt | 发现与配对是另一条链路，连上之前必须先停发现。 |
| 固定标准 UUID | lesson-only | 调试台要有标准 UUID 默认值，同时允许自定义 UUID。`sppConnect` 的 UUID 必须与对端注册值一致。 |
| 后台双队列 | adapt | 离开页面时字节不能丢，也不能在界面线程上读。用会话队列加长时任务，不抄 Android Service。 |
| 把发现和 SPP 写在同一个按钮里 | anti-pattern | 若产品要发现，必须单独停止扫描后再连接。 |

能用的：标准 SPP UUID 默认值、原始字节日志、未连接不可写、清屏只清显示。必须改写的：自定义 UUID、服务端、发现、虚拟 MAC、系统配对框。不要用 Android 通道号去猜 HarmonyOS SDP。不要假设系统已配对就跳过配对引导。

读过：`SerialSocket.java`；`DevicesFragment.java` 的 `getBondedDevices`；`SerialService.java` 的队列与 `startForeground`；`menu_terminal.xml`；`TextUtil.java` 的换行常量与 `HexWatcher`。未读布局 XML。

### kai-morich/SimpleBluetoothLeTerminal

- 仓库：https://github.com/kai-morich/SimpleBluetoothLeTerminal
- HEAD：`f322c06c84c60a1e647048094c0e58e683a2a1ea`（2026-04-12）
- 克隆：`/tmp/YoAgentResearch/kai-morich--SimpleBluetoothLeTerminal`
- 入选：与经典终端同一壳，传输是 BLE GATT 串口。它不是可以丢掉的重复实现。

预设：CC254x（`ffe0`/`ffe1`）、Nordic UART（`6e400001-b5a3-f393-e0a9-e50e24dcca9e`）、Microchip、Telit TIO。`DevicesFragment.startScan()` 在定位服务打开时 `BluetoothLeScanner.startScan`，没有 `ScanFilter`；定位服务关闭或 scanner 为空时退回 `startDiscovery()`。扫描有 `LE_SCAN_PERIOD`。`SerialSocket` 把 GATT 包成 connect / write。`DEFAULT_MTU = 23`，`payloadSize = MTU - 3`，`requestMtu(512)`。写特征使用 `WRITE_TYPE_NO_RESPONSE`。`writePending` 保证前一次写未完成不再叠写。配对注册 `ACTION_BOND_STATE_CHANGED` 与 `ACTION_PAIRING_REQUEST`。CCCD 为 `00002902-0000-1000-8000-00805f9b34fb`。

| 点 | 方式 | 说明 |
|----|------|------|
| 多 UART 预设表 | adapt | 预设是服务 UUID 加读/写/CCCD。匹配失败应告诉用户不是已知串口，并留给通用 GATT。 |
| MTU 减 3 作为载荷 | adapt | 未协商默认 23。HarmonyOS 范围是 [23, 517]，成功以 `BLEMtuChange` 为准。 |
| 写队列防重入 | reuse-pattern | 前序异步未完成会 2900099。一条写完再下一条。 |
| 无过滤全量扫描 | anti-pattern | 车库场景会扫到大量无关设备。`ScanFilter` 做白名单，模糊名称放在回调里。 |
| 定位服务失败就退回经典发现 | anti-pattern | 那是 Android 6 的权限历史。鸿蒙 BLE 扫描权限是 `ACCESS_BLUETOOTH`。经典发现与 BLE 扫描不能互为回退。 |

不要在 BLE 扫描失败时调用 `startBluetoothDiscovery` 凑设备列表。不要把 512 写成一定会协商成功。未读 Telit 信用额状态机全文，只确认它是独立 delegate。

### microsoft/BluetoothLEExplorer

- 仓库：https://github.com/microsoft/BluetoothLEExplorer
- HEAD：`494ccc99d7e615498af71ecb71ba8945083adb35`（2022-09-08）
- 克隆：`/tmp/YoAgentResearch/microsoft--BluetoothLEExplorer`
- 入选：维护停在 2022，但是公开源码里结构完整的 GATT 浏览器。前三份都没有任意服务树。活跃度不足，所以只借用交互结构，不借用 Windows 行为当鸿蒙限制。

`GattSampleContext` 持有 `BluetoothLEAdvertisementWatcher`，启停成对。`ObservableBluetoothLEAdvertisementFilter` 按 `SectionType`、`SectionOffset`、`SectionDataString` 过滤，格式为 Hex 或 String，再变成 `BluetoothLEAdvertisementBytePattern`。`CharacteristicPage` 在 Hex 模式下逐字校验，非法字符不送进写调用。`GattProtocolErrorParser` 把 `ReadNotPermitted`、`WriteNotPermitted`、`InsufficientAuthentication`、`InsufficientAuthorization`、`InsufficientEncryption`、`InvalidAttributeValueLength`、`PrepareQueueFull` 译成可读原因。`VirtualKeyboard` 用 `GattServiceProvider.CreateAsync` 发布 HID，并监听广播状态。

| 点 | 方式 | 说明 |
|----|------|------|
| GATT 树与串口预设分开 | reuse-pattern | 浏览器是 BLE 主路径。预设只是匹配成功后的快捷终端。 |
| 广播段过滤器 | adapt | 对应 `ScanFilter` 的 serviceData / manufactureData 及 mask，回调里保留原始 `data`。不要发明任意 AD Type 写入。 |
| ATT 错误人话 | adapt | 对照 2901000–2901007 显示原因。 |
| Hex 写前校验 | reuse-pattern | 非法 HEX 停在输入框，不发空写或半字节。 |
| 整份 UWP API | lesson-only | `GattServiceProvider` 不是 ArkTS API。本机外设用 `ble.createGattServer` 与 `startAdvertising`。 |

不要因为本仓库能做虚拟键盘，就在调试台里做 HID 注入。HID 属于 `ohos.bluetooth.hid`，错误码 2903050 要求 HID 在前台，超出本次范围。未读心率、血压等测量解析。

## 落选

- `NordicSemiconductor/pc-nrfconnect-ble`（HEAD `d7714424cd10d3312af8ddbc593346ee1fe81411`，2026-08-13）：已克隆。`src/` 只有下载安装与拉起，`package.json` 描述为 BLE 开发测试工具，`doc/docs/` 有服务发现、连接参数、广播、DFU 的用户文档。GATT 实现不在 git 里。
- `adafruit/Bluefruit_LE_Connect_Android`：2022-04 后无提交，UART/绘图与已入选终端、Toolbox 重叠。未克隆。
- `NordicSemiconductor/Android-nRF-Connect-Device-Manager`：DFU、日志、统计库，不是通用扫描/GATT/SPP 调试应用。未克隆。
- 闭源的 nRF Connect 手机版与 LightBlue：没有可克隆源码，不写成实现结论。
- YoAgentDocs 已有的 Android-BLE-Library、blessed-android、kable：库而不是调试应用。本轮不重复克隆。

## 现有代码上下文

只说明读到了什么。这不是架构，也不沿用 `.projectark` 里的旧设计。

- `common/yobluetooth` 已导出经典发现、配对、SPP 连接与发送、BLE 扫描、GATT 连接/发现/读/写/通知/MTU、UART 预设连接、重连协调。
- `features/bluetooth` 有经典扫描过滤界面、SPP 终端、配对引导。`product/phone/src/main/ets/pages/bluetooth/BleMainPage.ets` 仍是空壳。
- `.projectark/5-架构设计/无线调试工具/bluetooth/` 里「当前 SDK 无 ACL API」与镜像里 API 26.0.0 的 `onAclStateChange` 不一致，以镜像为准，真机是否具备标待证。
- 手机模块 `module.json5` 已声明 `ACCESS_BLUETOOTH` 与 `PERSISTENT_BLUETOOTH_PEERS_MAC`。声明不等于 ACL 已批准。

## 阅读范围（官方文档）

指南：`开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/` 下概述、蓝牙设置、传统蓝牙三篇、低功耗蓝牙两篇、2900099。HCI：`开发/指南/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/蓝牙常见问题/如何抓取蓝牙HCI日志/如何抓取蓝牙HCI日志.md`。最佳实践：`开发/最佳实践/功能开发/网络/低功耗蓝牙基础使用.md`。

FAQ 读过正文：`USE_BLUETOOTH 和 ACCESS_BLUETOOTH的区别是什么.md`、快速回连、31 字节、大量设备扫描、MTU 失败、BLE 虚拟地址建经典连接、长时任务、扫描阶段定位、通知 2900007/2900099、自定义 AD Type，以及 HCI、重连、订阅、大数据相关篇的问题与结论段。未把星闪 API 当作蓝牙能力。
