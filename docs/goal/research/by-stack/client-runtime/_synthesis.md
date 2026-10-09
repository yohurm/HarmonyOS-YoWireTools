---
id: research.synthesis.client-runtime
type: synthesis
status: active
when: research
stack:
  capability: client-runtime
---

# client-runtime 横向总结（蓝牙专业调试）

本篇只总结 **蓝牙调试/测试应用** 这一批。它不是 YoAgentDocs 里整个 client-runtime 层的总汇。HarmonyOS 对照以镜像仓库 `yohurm/HarmonyOS-Developer-docs` 的 `1d85fab9f9750a9e79a8ccd10509e41753e1ef45`（2026-10-09）为准。下文路径都相对该仓库根。

克隆用 HTTPS 浅克隆到 `/tmp/YoAgentResearch/`。手册写 GitHub 默认 SSH；本环境没有可用的 GitHub SSH，故改用 HTTPS。源码未复制进本仓库。

## 本层已研项目

| 仓库 | 一句话 | 利用方式 |
|------|--------|----------|
| NordicSemiconductor/Android-nRF-Toolbox | 多 profile 工具箱：UART 分片、吞吐计时、前台连接宿主、按设备日志 | adapt |
| kai-morich/SimpleBluetoothTerminal | 已配对设备上的 SPP 终端：原始 read、HEX、换行、后台队列 | adapt |
| kai-morich/SimpleBluetoothLeTerminal | BLE 串口预设、MTU-3、无响应写、无过滤扫描（反例） | adapt / anti-pattern |
| microsoft/BluetoothLEExplorer | 通用 GATT 树、AD 段过滤、ATT 错误翻译、本机服务发布 | adapt |

## 共同架构经验

专业调试台把下面几件事拆开，而不是做成一个「连接」按钮：

1. **发现** 与 **连接** 分开。连接前停止扫描。nRF Toolbox 与 BLE Explorer 都有明确的停止；HarmonyOS 传统蓝牙指南写明扫描消耗硬件，连接前必须 `stopBluetoothDiscovery`。
2. **预设串口** 与 **通用 GATT** 分开。UART 是一张 UUID 表。浏览器才是任意服务的入口。
3. **一次传输回调是一段字节**，不是一条业务消息。SPP `read` 与 BLE Notify 都这样。
4. **写操作串行**。前一次未完成就再写，会在 Android 写队列和 HarmonyOS 2900099 上同时失败。
5. **吞吐测量关闭逐包日志**。nRF `ThroughputManager` 在计时期间摘掉 logger。
6. **配对 UI 属于系统**。应用只发起配对并订阅结果。
7. **错误要能对上协议原因**（未认证、禁止写、MTU、报文超长），而不是一律「操作失败」。

## 分歧与取舍

| 分歧 | 取舍 |
|------|------|
| 经典终端不扫描，只列已配对 | 调试台仍要发现，但发现结果不能直接当 SPP 已就绪。未配对先走系统配对。 |
| BLE 终端无 `ScanFilter`，定位服务关闭就退回经典发现 | 不学。HarmonyOS 经典扫描不能当 BLE 扫描的替身，两边地址也不能混用。 |
| nRF 吞吐绑定自家特征 UUID | 通用调试台的「吞吐」应是：对用户选定的可写特征做无响应写，并显示字节/秒。不要内置 0x1524 才算吞吐。对端统计读数是加分项，不是唯一算法。 |
| BLE Explorer 能按任意 AD 段过滤，也能发布 HID | 过滤可学。任意 AD Type 写入不要学：鸿蒙 FAQ 写明不能直接设置任意 Type。HID 注入不在本次通用调试范围。 |
| 桌面 nRF Connect 口碑最高 | 其开源仓库 `pc-nrfconnect-ble` 只剩启动器，GATT 引擎是下载的二进制。不用文档代替源码下实现结论。 |

## 与 HarmonyOS 能力对照

判定只用三档：**支持**（镜像写了可调用的 API 与约束）、**缺口**（文档写明没有，或只在系统应用/开发者模式/外部工具）、**待证**（API 在，但是否在当前设备/ACL/版本上可用要真机看）。模拟器：概述写明蓝牙模块暂不支持模拟器。

| 能力 | 行业里专业工具怎么做 | HarmonyOS | 判定 |
|------|----------------------|-----------|------|
| 权限 | Android 12+ 的 BLUETOOTH_SCAN/CONNECT；旧版还绑定位 | API 10+ 用 `ohos.permission.ACCESS_BLUETOOTH`。`USE_BLUETOOTH` 只服务已废弃的 API 7/8/9。开关订阅从 API 18 起不再校验该权限 | 支持 |
| 开关 | 应用内开关，系统仍可能弹窗 | `access.enableBluetooth` / `disableBluetooth` 弹系统框，用户拒绝则保持原状态。状态机含 `STATE_OFF`、`TURNING_ON`、`ON`、`BLE_ON` 等。只有 `STATE_ON` 后才能用其他蓝牙能力 | 支持 |
| 经典发现过滤 | 按名称、RSSI、COD 过滤 | `startBluetoothDiscovery()` 无过滤参数，约 12s，扫描中不可再调，停后才能再开。FAQ 写明经典扫描无法配置过滤参数。名称/RSSI/类型只能在应用层滤 `discoveryResult`（API 18+：地址、RSSI、名称、`deviceClass`）。API 17 及以前 `bluetoothDeviceFind` 只有地址 | 支持发现；平台过滤是缺口 |
| 经典结果里混有 BLE | 列表按传输类型分开 | 该接口同时发现传统与 BLE。应用必须再分流。`getRemoteDeviceTransport` 从 API 20 起 | 支持，分流在应用层 |
| BLE 扫描过滤 | nRF Connect / BLE Explorer：名称、UUID、厂商数据、RSSI、原始 AD | `ScanFilter` 是白名单。字段含 deviceId/name/serviceUuid(+mask)/serviceSolicitationUuid(+mask)/serviceData(+mask)/manufactureId+data+mask。`rssiThreshold` 与带类型的 `address` 从 API 23。`null` 过滤器表示取消过滤。模糊名称要在回调里做，不能当成 `name` 的精确字段 | 支持 |
| 扫描模式 | 低功耗 / 低延迟 | `ScanDuty`：`LOW_POWER`、`BALANCED`、`LOW_LATENCY`。`phyType` 默认 1M，或 `PHY_LE_ALL_SUPPORTED`。`interval` 只在批量上报时生效。API 15+ `BleScanner` 多路；API 14 及以前全局单路 | 支持 |
| 广播原始字节 | Explorer 展示 AD；nRF Connect 解类型 | `ScanResult.data` 是未解析广播。API 22+ 另给 flags、厂商表、服务表、UUID、发射功率 | 支持 |
| 本机可被发现 | 调试器可让手机可被扫到 | `setBluetoothScanMode` API 在，但指南写「非系统应用一般不用关注」，系统设置决定模式 | 待证 |
| 配对 | 系统对话框；应用看 bond 状态 | `pairDevice`（API 21 起可带 `BluetoothAddress` 类型）。结果看 `bondStateChange`，不是 Promise。`setDevicePairingConfirmation` 还要 `MANAGE_BLUETOOTH`，仅系统应用。`setDevicePinCode` 只要 `ACCESS_BLUETOOTH`。取消配对无 API，只能引导系统设置 | 支持发起与观察；取消配对是缺口；应用自绘确认框是缺口 |
| 虚拟 MAC | 专业工具仍显示「稳定 ID」 | 扫描与 `getDeviceId` 默认虚拟地址。未配对时重启蓝牙会变。配对后固化。API 16 `addPersistentDeviceId` 另需 `PERSISTENT_BLUETOOTH_PEERS_MAC`（ACL）。卸载重装失效；对端真实地址变了也失效。FAQ 建议一般走配对，而不是申请该受限权限 | 支持虚拟地址；免配对固化是待证（ACL） |
| 双模 | 同一物理设备两条链路 | FAQ：用已连接 BLE 的虚拟地址 `pairDevice`，配对列表会同时出现经典记录。BLE 扫描地址不能直接 `sppConnect`。先经典再 BLE 的桥接，FAQ 写明目前不支持 | 支持 BLE→经典配对；反向桥接是缺口 |
| SPP 客户端 | SimpleBluetoothTerminal：标准 UUID、原始字节 | `socket.sppConnect`，UUID 必须与对端一致。标准 Serial Port UUID 可用，也可用自定义 UUID。未配对 2900016。FAQ：单次 `sppWrite` 最好 ≤600 字节，不建议超过 1024 | 支持 |
| SPP 服务端 | 工装常要手机当从 | `sppListen` + `sppAccept` + `sppCloseServerSocket` | 支持 |
| L2CAP | 较少出现在通用终端 | API 20+ `SPP_L2CAP` 与 `SPP_L2CAP_BLE`，PSM 用 `getL2capPsm`。写入不得超过 `getMaxTransmitDataSize`（API 22） | 支持 API；产品是否做留到设计，本篇只标能力在 |
| GATT 客户端 | Explorer：发现服务、读、写、通知、描述符 | `createGattClientDevice`、`connect`、`getServices`、读/写特征与描述符、`setCharacteristicChangeNotification` / `Indication`、`on('BLECharacteristicChange')`。`getServices` 必须在连接成功之后、其他特征操作之前。通知订阅要排在 MTU 与服务发现成功之后，否则 2900007/2900099 | 支持 |
| 写类型 | 有响应 / 无响应 | `GattWriteType.WRITE`（对端确认）与 `WRITE_NO_RESPONSE` | 支持 |
| GATT 服务端 | Explorer 发布本地服务 | `createGattServer`、`addService`、读写请求回调里 `sendResponse`、`notifyCharacteristicChanged`。不应答会导致对端订阅一直阻塞 | 支持 |
| 广播 | 外围角色 | `startAdvertising`。传统报文最长 31 字节，超出 2902054。不能直接写任意 AD Type：`serviceUuids`、`serviceData`（0x16）、`manufactureData`（0xFF）、`includeDeviceName`（0x09）各有固定 Type。扩展广播 `isExtended` 自 26.0.0，且与可连接、扫描响应的组合有互斥。`duration` 单位 10ms，0 表示一直广播 | 支持；任意 AD Type 是缺口 |
| MTU | BLE 终端请求 512，载荷按 MTU-3 | `setBLEMtuSize` 范围 [23, 517]，未协商默认 23。必须已连接。结果看 `BLEMtuChange`，不要把调用返回当成协商完成。FAQ 建议在 `getServices` 之前调用 | 支持 |
| PHY | 1M / 2M / Coded | 客户端与服务端均有 `readPhy` / `setPhy` / PHY 更新回调，API 23。`BlePhy`：1M、2M、CODED（S2 500 kbit/s，S8 125 kbit/s） | 支持 API；芯片是否具备待证（错误码 801） |
| 连接间隔 | nRF Connect 可填 interval/latency/timeout 数字 | 没有这些数字。API 22 `updateConnectionParam` 只有 `LOW_POWER` / `BALANCED` / `HIGH`。大量传输用 `HIGH`，传完回到 `BALANCED` | 数字间隔是缺口；三档枚举支持 |
| 吞吐 | nRF：无响应写 + 分片 + 计时 + 可选对端计数；计时期间停日志 | 应用层可做。平台不提供「吞吐测试」API。分片上限来自协商 MTU。SPP 大包另有 FAQ 的 600/1024 建议，且大数据不要堵主线程 | 支持（应用层测量） |
| 空口抓包 | nRF Sniffer + Wireshark / Ellisys | 应用内没有 HCI 套接字。开发者模式一键采集从 API 26.0.0 起，Phone/Tablet，约 30 秒，文件在本地。Release 去掉 payload 只留 Header。分析工具在 PC。hdc 抓不到时另有稳定性 FAQ | 应用内抓包是缺口；开发者采集支持，payload 在 Release 上是缺口 |
| 回连 | 保存地址再连 | 配对可固化虚拟地址，之后 `getPairedDevices` 直连。免配对固化要 ACL 权限。GATT 重连必须丢掉旧 `GattClientDevice` 再创建，否则 2900099 子原因写明对象未销毁。扫描进行中不允许连接（错误码子原因：业务扫描期间不允许发起连接） | 支持；免配对持久化待证 |
| 后台 | Android 前台服务 + 通知 | FAQ：进程会被杀掉。长时任务类型 `BLUETOOTH_INTERACTION`，权限 `KEEP_BACKGROUND_RUNNING`，并在 `module.json5` 声明 `backgroundModes`。车钥匙子类型另有限制，不属于通用调试 | 支持长时任务；不声明则会断，这是缺口用法而不是平台没有 API |
| 已连接设备枚举 | 系统设置里的已连接 | `ble.getConnectedBLEDevices`；API 26.0.0 起 `connection.onAclStateChange`（可再要 `GET_BLUETOOTH_PEERS_MAC`）。`connectAllowedProfiles` 不管 SPP | ACL 监听支持（版本新）；SPP 是否出现在系统「已连接」待证 |
| Profile 电量 | 耳机电量 | `getRemoteDeviceBatteryInfo` API 12，仅对应 profile，不是 GATT Battery Service 的替代 | 支持该 API；与 GATT 0x180F 不是同一条 |

错误码主表在 `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/错误码/蓝牙服务子系统错误码.md`。调试台至少要单独呈现：2900001 服务停止、2900003 开关关闭、2900007 超时、2900009 硬件资源不足、2900010 资源上限、2900011 操作频繁、2900016 未配对、2900099 操作失败（含参数、前序未完成、扫描中禁止连接、GATT 未连接、重连未销毁客户端）、2901000–2901007 GATT 权限/加密、2902050 扫描失败、2902054 广播超长。

C API `oh_bluetooth.h` 从 API 13 起只有开关状态查询，不能当调试面。已停止维护的 `ohos.bluetooth` / `ohos.bluetoothManager` 不作为新能力依据。

## 对本知识库规则的候选修订

只记录，不改 YoAgentDocs。

- 蓝牙调试类深研继续放 `client-runtime`，不要新建 `bluetooth` 能力层，除非同类文章超过三篇且用户同意升格。
- 若以后把「官方能力对照」收成规则，应引用 HarmonyOS 镜像路径与 git 修订，而不是只引用 developer.huawei.com 网页。

## 入选与落选备忘

入选四份的理由见各篇。Top N 取 4：三份仍在 2026 年更新，一份用完整 GATT 源码补上前三份没有的浏览器。

落选：

- `NordicSemiconductor/pc-nrfconnect-ble`（HEAD `d7714424`，2026-08-13）：仓库是 nRF Connect for Desktop 的启动器。`src/` 只有下载安装与拉起，`package.json` 描述为 BLE 开发测试工具，`doc/docs/` 有服务发现、连接参数、广播、DFU 的用户文档。GATT 实现不在 git 里，不符合源码级深研，故不写单篇。
- `adafruit/Bluefruit_LE_Connect_Android`：2022-04 后无提交，UART/绘图与已入选终端、Toolbox 重叠。
- `NordicSemiconductor/Android-nRF-Connect-Device-Manager`：DFU、日志、统计库，不是通用扫描/GATT/SPP 调试应用。
- 闭源的 nRF Connect 手机版与 LightBlue：行业参照，没有可克隆源码，不写成深研篇。
- YoAgentDocs 已有的 Android-BLE-Library、blessed-android、kable：库而不是调试应用。本轮不重复克隆。

## 现有代码上下文（不是设计）

只说明读到了什么，避免下一阶段把现状当成架构。

- `common/yobluetooth` 已导出经典发现、配对、SPP 连接与发送、BLE 扫描、GATT 连接/发现/读/写/通知/MTU、UART 预设连接、重连协调。
- `features/bluetooth` 有经典扫描过滤界面、SPP 终端、配对引导。`BleMainPage.ets` 仍是空壳。
- `.projectark/5-架构设计/无线调试工具/bluetooth/` 是既有设计笔记。本阶段不沿用、不增补。其中「当前 SDK 无 ACL API」与镜像里 API 26.0.0 的 `onAclStateChange` 不一致，以镜像为准，真机是否具备标待证。
- 手机模块 `module.json5` 已声明 `ACCESS_BLUETOOTH` 与 `PERSISTENT_BLUETOOTH_PEERS_MAC`。本轮没有把这当成 ACL 已批准。

## 阅读范围（官方文档）

指南：`开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/` 下概述、蓝牙设置、传统蓝牙三篇、低功耗蓝牙两篇、2900099。HCI：`开发/指南/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/蓝牙常见问题/如何抓取蓝牙HCI日志/如何抓取蓝牙HCI日志.md`。最佳实践：`开发/最佳实践/功能开发/网络/低功耗蓝牙基础使用.md`。

API：`ohos.bluetooth.access`、`connection`、`ble`（扫描过滤、MTU、PHY、连接参数、广播、GATT 客户端/服务端）、`socket`、`constant`、`common`、`baseProfile` 的标题与权限；错误码全文标题；`oh_bluetooth.h` 仅确认能力范围。

FAQ（正文，不只标题）：USE/ACCESS 区别、虚拟 MAC 回连、31 字节、大量设备扫描、MTU 失败、BLE 虚拟地址建经典连接、长时任务、扫描阶段定位、通知 2900007/2900099、自定义 AD Type、以及 HCI/重连/订阅/大数据相关篇的问题与结论段。未把星闪 API 当作蓝牙能力。
