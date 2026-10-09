---
id: checklist.goal.bluetooth
type: checklist
status: active
when: research
when_to_use: 蓝牙专业调试能力逐条做架构设计之前
related: [research.synthesis.client-runtime]
---

# 蓝牙专业调试特性清单

每条只钉一个可观察结果。平台判定来自 HarmonyOS 镜像 `1d85fab9`，不是实现方案。

- **支持**：文档给出 API 与约束，后续设计可以按条做。
- **缺口**：文档写明没有，或只属于系统应用、开发者模式、PC 侧工具。设计时不得做成「应用里点一下就有」。
- **待证**：API 在文档里，但是否在目标设备、API 等级或 ACL 上可用，必须真机单独判。文档阶段不能标通过。

证据路径相对 `yohurm/HarmonyOS-Developer-docs`。行业行为见 `docs/goal/research/by-stack/client-runtime/_synthesis.md`。

## 1. 权限与适配器

### BT-001 未授予权限时不开始经典发现

- **判定：** 支持
- **Given** 未授予 `ohos.permission.ACCESS_BLUETOOTH`
- **When** 用户请求开始经典发现
- **Then** 不出现「发现中」；不新增设备；可见拒绝，并可再次申请
- **证据：** `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/传统蓝牙/查找设备.md`

### BT-002 未授予权限时不开始 BLE 扫描

- **判定：** 支持
- **Given** 同上
- **When** 用户请求 BLE 扫描
- **Then** 不调用成功的扫描；列表不增加；拒绝原因可见
- **证据：** `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/低功耗蓝牙/查找设备.md`

### BT-003 用户拒绝打开蓝牙后保持关闭

- **判定：** 支持
- **Given** 状态为 `STATE_OFF`
- **When** 应用调用 `enableBluetooth` 且用户在系统框拒绝
- **Then** 状态回到 `STATE_OFF`；扫描与连接入口保持不可用
- **证据：** `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/蓝牙设置.md`

### BT-004 用户拒绝关闭蓝牙后保持开启

- **判定：** 支持
- **Given** 状态为 `STATE_ON`
- **When** 应用调用 `disableBluetooth` 且用户拒绝
- **Then** 状态保持 `STATE_ON`
- **证据：** 同上

### BT-005 开关切换过程中不可用

- **判定：** 支持
- **Given** 状态为 `STATE_TURNING_ON`、`STATE_TURNING_OFF`、`STATE_BLE_TURNING_ON` 或 `STATE_BLE_ON` 之一
- **When** 用户请求发现或 GATT 连接
- **Then** 请求不发出；界面标明尚未 `STATE_ON`
- **证据：** `ohos.bluetooth.access` 的 `BluetoothState`；蓝牙设置指南只把 `STATE_ON` 定为可使用其他功能

### BT-006 蓝牙关闭时的错误不是空列表

- **判定：** 支持
- **Given** 蓝牙关闭
- **When** 扫描接口返回
- **Then** 可见错误码 2900003，而不是「附近没有设备」
- **证据：** `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/错误码/蓝牙服务子系统错误码.md`

### BT-007 不使用已废弃的 USE_BLUETOOTH 作为 API 10+ 权限

- **判定：** 支持
- **Given** 应用目标为 API 10 及以上
- **When** 检查声明的蓝牙权限
- **Then** 接入能力对应 `ACCESS_BLUETOOTH`；`USE_BLUETOOTH` 不作为扫描/配对/连接的权限
- **证据：** `开发/FAQ/系统开发/网络/短距通信（Connectivity）/USE_BLUETOOTH 和 ACCESS_BLUETOOTH的区别是什么.md`

### BT-008 模拟器上蓝牙标为不可用

- **判定：** 缺口（模拟器）
- **Given** 运行在模拟器
- **When** 打开蓝牙调试入口
- **Then** 明确显示蓝牙不可用；不展示会成功的扫描按钮结果
- **证据：** `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/蓝牙服务开发概述.md`「蓝牙模块暂不支持模拟器」

## 2. 经典发现

### BT-009 API 18+ 发现结果含信号与类型

- **判定：** 支持
- **Given** API 18+ 且已开始发现
- **When** 收到 `discoveryResult`
- **Then** 每条可见虚拟地址、RSSI（dBm）、名称、设备类型
- **证据：** `ohos.bluetooth.connection` 的 `DiscoveryResult18+`；传统蓝牙查找设备指南

### BT-010 API 17 及以前只有地址

- **判定：** 支持
- **Given** API 17 及以前
- **When** 收到 `bluetoothDeviceFind`
- **Then** 列表只保证地址；不显示编造的 RSSI 或名称
- **证据：** 传统蓝牙查找设备指南

### BT-011 一次发现约 12 秒后结束

- **判定：** 支持
- **Given** 发现已开始且用户未手动停止
- **When** 经过该次发现
- **Then** 发现状态结束；可再次开始。文档写明过程大约持续 12s
- **证据：** `connection.startBluetoothDiscovery` 说明

### BT-012 发现进行中不能再开始一次

- **判定：** 支持
- **Given** `isBluetoothDiscovering()` 为真
- **When** 用户再次点开始
- **Then** 不叠加第二次发现；按钮保持停止
- **证据：** 同上，「请勿重复调用」

### BT-013 未停止不能开始下一次

- **判定：** 支持
- **Given** 上一次发现尚未停止
- **When** 立即再次开始
- **Then** 第二次不生效，直到停止完成
- **证据：** 同上

### BT-014 连接前停止发现

- **判定：** 支持
- **Given** 经典发现进行中
- **When** 用户对某设备发起配对或 SPP 连接
- **Then** 先停止发现，再发起后续操作
- **证据：** 传统蓝牙查找设备指南；错误码子原因「业务扫描期间不允许发起连接」

### BT-015 经典发现没有平台过滤参数

- **判定：** 缺口（平台过滤）
- **Given** 用户设置名称或 RSSI 条件
- **When** 开始经典发现
- **Then** 条件只作用于已上报结果；调用本身没有过滤参数
- **证据：** FAQ「如何通过已连接的 BLE 蓝牙设备的虚拟 MAC 地址建立经典蓝牙连接」：经典扫描无法配置过滤参数

### BT-016 经典发现结果按传输类型分流

- **判定：** 支持
- **Given** 同一次发现里既有经典设备也有 BLE 设备
- **When** 查看 SPP 候选列表
- **Then** 仅经典/双模进入 SPP 候选；纯 LE 不出现在该列表
- **证据：** `startBluetoothDiscovery` 说明可发现传统与 BLE 设备

### BT-017 已配对设备可在发现前列出

- **判定：** 支持
- **Given** 系统里已有配对设备
- **When** 打开经典设备页且尚未发现
- **Then** `getPairedDevices` 的结果可见，并带 `getPairState`
- **证据：** 传统蓝牙查找设备指南

### BT-018 硬件资源不足时结束发现

- **判定：** 支持
- **Given** 扫描因硬件资源失败
- **When** 接口返回 2900009 或扫描失败 2902050
- **Then** 发现状态结束并显示该错误，不保持「发现中」
- **证据：** 蓝牙服务子系统错误码

## 3. 配对

### BT-019 配对完成以配对状态事件为准

- **判定：** 支持
- **Given** 对未配对设备调用 `pairDevice`
- **When** Promise 成功返回，但尚未收到 `BOND_STATE_BONDED`
- **Then** 界面仍为配对进行中，不显示已配对
- **证据：** `connection.pairDevice`；`bondStateChange`；`BondState`

### BT-020 配对使用系统对话框

- **判定：** 支持
- **Given** 发起配对
- **When** 系统需要用户确认密钥或 PIN
- **Then** 出现系统配对框；应用内没有自绘的 PIN 输入被当作系统结果
- **证据：** 传统蓝牙「配对与连接设备」指南

### BT-021 用户取消配对可见

- **判定：** 支持
- **Given** 系统配对框已出现
- **When** 用户取消
- **Then** 设备不是已配对；失败可见。取消 PIN 的回调可能延迟，界面在事件到达前保持进行中
- **证据：** FAQ「蓝牙 on('bondStateChange') 监听取消输入 PIN 码回调有延迟」

### BT-022 未配对不能当成 SPP 超时

- **判定：** 支持
- **Given** 设备未配对
- **When** SPP 连接返回 2900016
- **Then** 文案为未配对，并提供发起配对，而不是「连接超时」
- **证据：** 错误码 2900016

### BT-023 应用不能取消配对

- **判定：** 缺口
- **Given** 设备已配对
- **When** 用户在应用内要求取消配对
- **Then** 不存在成功的取消配对调用；提供打开系统蓝牙设置
- **证据：** 最佳实践「如何通过代码调用取消配对」；FAQ 同结论

### BT-024 普通应用不调用系统级配对确认

- **判定：** 缺口（普通应用）
- **Given** 应用不是系统应用
- **When** 收到需要确认的配对
- **Then** 不调用 `setDevicePairingConfirmation`（该接口还要 `MANAGE_BLUETOOTH`）
- **证据：** `ohos.bluetooth.connection` 中该接口的权限说明

### BT-025 配置文件连接不等于 SPP 已连接

- **判定：** 支持
- **Given** `connectAllowedProfiles` 已成功
- **When** 查看 A2DP/HFP/HID/PAN 与 SPP
- **Then** 配置文件状态单独显示；SPP 仍须 `socket.sppConnect` 成功才算连接
- **证据：** 配对与连接设备指南

### BT-026 远端 UUID 查询失败不阻止手工 SPP UUID

- **判定：** 支持
- **Given** `getRemoteProfileUuids` 失败
- **When** 用户仍选择标准或自定义 UUID 发起 SPP
- **Then** 失败提示可见，SPP UUID 输入仍可用
- **证据：** 同上，UUID 查询是连接配置文件前的建议步骤；SPP 另见套接字指南

## 4. 地址

### BT-027 扫描地址标注为虚拟地址

- **判定：** 支持
- **Given** 扫描时过滤条件没有填写真实 MAC
- **When** 展示 `deviceId`
- **Then** 地址以虚拟 MAC 呈现，不标成物理 MAC
- **证据：** 蓝牙服务开发概述；`ScanResult.deviceId`；`DiscoveryResult.deviceId`

### BT-028 未配对设备重启蓝牙后旧地址失效

- **判定：** 支持
- **Given** 未配对且未持久化，已保存扫描地址
- **When** 对端或本机重启蓝牙后再用旧地址连接
- **Then** 连接失败原因可见，并提示需要重新发现
- **证据：** FAQ「如何实现 BLE 蓝牙快速回连」

### BT-029 配对后虚拟地址保持可用

- **判定：** 支持
- **Given** 配对已完成
- **When** 重启蓝牙后不扫描，用配对地址连接
- **Then** 地址仍被接受为同一设备（连接是否成功还取决于对端可连接）
- **证据：** 同上，方案一

### BT-030 无 ACL 权限时不做免配对固化

- **判定：** 待证（权限往往拿不到）
- **Given** 未授予 `PERSISTENT_BLUETOOTH_PEERS_MAC` 或 ACL 未过
- **When** 用户收藏一台未配对设备
- **Then** 不把 `addPersistentDeviceId` 的失败显示成已固化；回连路径改为重新发现或配对
- **证据：** `access.addPersistentDeviceId` 权限；FAQ 注明该权限受限，一般建议配对

### BT-031 对端真实地址变化后丢弃固化项

- **判定：** 支持
- **Given** 虚拟地址已固化，对端真实地址已变
- **When** 用固化地址连接失败
- **Then** 该项标失效，不再自动重试同一地址
- **证据：** `addPersistentDeviceId` 说明

### BT-032 卸载重装后固化地址不可用

- **判定：** 支持
- **Given** 应用曾固化地址后被卸载重装
- **When** 读取持久化列表
- **Then** 旧地址不作为可用回连目标
- **证据：** 同上，「卸载重装持久化失效」

### BT-033 未知地址类型时用不带类型的配对

- **判定：** 支持
- **Given** 只有虚拟地址字符串，不知道 `BluetoothAddressType`
- **When** 发起配对
- **Then** 使用不带地址类型的 `pairDevice(deviceId)`
- **证据：** 配对与连接设备指南

### BT-034 BLE 扫描地址不能直接用于 SPP

- **判定：** 缺口（混用地址）
- **Given** 只有 BLE 扫描得到的地址
- **When** 用户要求立刻 SPP
- **Then** 不把该地址传给 `sppConnect`；说明需要经典地址或先按 FAQ 做 BLE 地址配对
- **证据：** FAQ「ble.startBLEScan 扫描出来的地址可以放到 socket.sppConnect 吗」答案为不可以

### BT-035 不提供「先经典再 BLE」的自动桥

- **判定：** 缺口
- **Given** 仅有经典连接
- **When** 用户要求自动转成 GATT
- **Then** 不出现成功的自动桥接；若要 GATT，走 BLE 扫描或已有 BLE 地址
- **证据：** 同一 FAQ：目前不支持先经典再 BLE

### BT-036 已连接 BLE 地址可以发起配对以得到经典记录

- **判定：** 支持
- **Given** BLE 已连接且已知其虚拟地址，对端为双模
- **When** 用该地址 `pairDevice`
- **Then** 配对成功后，已配对列表能用于后续经典连接
- **证据：** FAQ「如何通过已连接的 BLE 蓝牙设备的虚拟 MAC 地址建立经典蓝牙连接」

## 5. SPP

### BT-037 标准串口 UUID 可连接

- **判定：** 支持
- **Given** 对端注册 `00001101-0000-1000-8000-00805F9B34FB`，且已配对、发现已停
- **When** 客户端 `sppConnect` 使用该 UUID
- **Then** 进入已连接，可读写
- **证据：** `ohos.bluetooth.socket` 的 `SppOptions.uuid`；传统蓝牙连接和传输数据指南

### BT-038 UUID 不一致时连接失败可见

- **判定：** 支持
- **Given** 客户端 UUID 与服务端注册值不同
- **When** `sppConnect`
- **Then** 连接失败，原因可见，不进入已连接
- **证据：** 传统蓝牙连接和传输数据指南

### BT-039 自定义 UUID 可连接

- **判定：** 支持
- **Given** 两端使用同一个自定义 UUID
- **When** 客户端连接
- **Then** 连接成功
- **证据：** 套接字文档允许自定义 UUID

### BT-040 一次读取是一段字节

- **判定：** 支持
- **Given** SPP 已连接，对端连续发送多于一次回调的数据
- **When** 收到 `sppRead` 或 `sppReadAsync` 数据
- **Then** 日志保留该次字节及长度；不把一次回调显示成一条完整业务消息
- **证据：** 行业侧 SimpleBluetoothTerminal 的 read 拷贝；HarmonyOS 套接字为字节流。FAQ「socket.sppReadAsync 循环读取异常」要求按流读取

### BT-041 单次写入超过建议上限时失败可见

- **判定：** 支持
- **Given** SPP RFCOMM 已连接
- **When** 一次写入超过 1024 字节
- **Then** 不把整段标成已发送；可见失败或要求分段。建议上限 600 作为默认分段长度
- **证据：** FAQ 双模篇：「最好控制在 600 字节以下，不建议超过 1024 字节」

### BT-042 大数据写出不冻结界面

- **判定：** 支持
- **Given** 需要发送大于一次建议长度的缓冲
- **When** 用户发送
- **Then** 界面仍可停止发送；写入不在主线程上堵死
- **证据：** FAQ「蓝牙发送大数据导致主线程卡死」

### BT-043 未连接时发送失败

- **判定：** 支持
- **Given** SPP 未连接或 `isConnected`（API 22+）为假
- **When** 用户发送
- **Then** 不写入；提示未连接
- **证据：** 错误码 2900005；`socket.isConnected` API 22

### BT-044 服务端可接受客户端

- **判定：** 支持
- **Given** 本机 `sppListen` 已注册 UUID
- **When** 对端用同一 UUID 连接且 `sppAccept` 返回
- **Then** 本机出现已接入的客户端套接字，可读写
- **证据：** `socket.sppListen`、`socket.sppAccept`

### BT-045 服务端关闭后对端看到断开

- **判定：** 支持
- **Given** SPP 会话已建立
- **When** 本机 `sppCloseClientSocket` 或关闭服务端套接字
- **Then** 对端读写失败或断开，本机会话不再是已连接
- **证据：** 传统蓝牙连接和传输数据指南的断开步骤

### BT-046 HEX 非法输入不发送

- **判定：** 支持（应用层）
- **Given** 输入模式为 HEX，文本含非十六进制字符或奇数个半字节
- **When** 用户发送
- **Then** 不调用 `sppWrite`；输入标为无效
- **证据：** 行业侧 Bluetooth LE Explorer 与 SimpleBluetoothTerminal 的 HEX 校验。平台只接收 `ArrayBuffer`

## 6. L2CAP

### BT-047 L2CAP 的 PSM 必须与对端一致

- **判定：** 支持
- **Given** 类型为 `SPP_L2CAP` 或 `SPP_L2CAP_BLE`
- **When** 客户端 PSM 与服务端 `getL2capPsm` 不一致
- **Then** 连接失败可见
- **证据：** `SppOptions.psm`、`SppType`

### BT-048 L2CAP 写入不超过链路最大发送长度

- **判定：** 支持
- **Given** L2CAP 已连接
- **When** 写入长度大于 `getMaxTransmitDataSize`
- **Then** 拒绝该次写入并显示上限
- **证据：** `socket.sppWrite` 参数说明；`getMaxTransmitDataSize` API 22

### BT-049 RFCOMM 不填写 PSM

- **判定：** 支持
- **Given** 类型为 `SPP_RFCOMM`
- **When** 发起连接
- **Then** 不把 PSM 当作必填
- **证据：** `SppOptions.psm` 说明

## 7. BLE 扫描

### BT-050 过滤条件是白名单

- **判定：** 支持
- **Given** `ScanFilter` 指定了服务 UUID
- **When** 周围还有不含该 UUID 的广播
- **Then** 回调里只有符合条件的报文
- **证据：** FAQ「ScanFilter 是过滤出（仅包含）」；`ScanFilter` 说明

### BT-051 空过滤表示不过滤

- **判定：** 支持
- **Given** 用户清空过滤
- **When** 开始扫描
- **Then** 以 `null` 过滤启动，回调不再按上一轮条件丢弃
- **证据：** 同一 FAQ

### BT-052 精确名称、UUID、厂商数据与掩码可下发

- **判定：** 支持
- **Given** 用户填写 name、serviceUuid、serviceUuidMask、manufactureId、manufactureData、manufactureDataMask 中的若干项
- **When** 开始扫描
- **Then** 这些字段进入 `ScanFilter`，而不是只在界面上隐藏行
- **证据：** `ohos.bluetooth.ble` 的 `ScanFilter`

### BT-053 模糊名称在回调中匹配

- **判定：** 支持
- **Given** 用户要的是名称子串，且另有 UUID 或厂商 ID
- **When** 扫描
- **Then** 平台过滤用 UUID 或厂商条件；子串在回调中判断；命中后停止扫描
- **证据：** FAQ「存在较大量的蓝牙设备时低功耗蓝牙连接效率低」

### BT-054 RSSI 门限使用 API 23 字段

- **判定：** 支持（API 23+）；更低版本为缺口
- **Given** API 23+，门限设在建议区间 [-90, 127] dBm
- **When** 扫描
- **Then** 低于门限的报文不上报。超出协议范围 [-128, 127] 的输入被拒绝
- **证据：** `ScanFilter.rssiThreshold23+`

### BT-055 可切换三种扫描占空

- **判定：** 支持
- **Given** 用户选择低功耗、均衡或低延迟
- **When** 开始扫描
- **Then** `dutyMode` 分别为 `SCAN_MODE_LOW_POWER`、`BALANCED`、`LOW_LATENCY`
- **证据：** `ScanDuty`；拥挤场景 FAQ 建议低延迟

### BT-056 API 14 及以前不能并行两路扫描

- **判定：** 支持
- **Given** API ≤14，已有扫描
- **When** 再开一路
- **Then** 必须先 `stopBLEScan`，否则第二路不启动
- **证据：** 低功耗蓝牙查找设备指南

### BT-057 API 15+ 可以同时保留多路扫描

- **判定：** 支持
- **Given** API ≥15
- **When** 两个 `BleScanner` 使用不同过滤各扫一路
- **Then** 两路都有独立停止；停一路不影响另一路
- **证据：** `ble.createBleScanner`、`BleScanner.startScan` / `stopScan`

### BT-058 连上目标后停止扫描

- **判定：** 支持
- **Given** 扫描进行中且 GATT 已连接目标
- **When** 连接状态变为已连接
- **Then** 该路扫描停止
- **证据：** 最佳实践「低功耗蓝牙基础使用」；错误码禁止扫描期间连接

### BT-059 离开扫描页停止扫描

- **判定：** 支持
- **Given** 扫描进行中
- **When** 用户离开该页
- **Then** 扫描停止，不再耗电
- **证据：** 同上

### BT-060 保留原始广播并展示已解析字段

- **判定：** 支持
- **Given** API 22+ 的一条 `ScanResult`
- **When** 展示设备
- **Then** 可见原始 `data`，以及存在时的 flags、厂商数据、服务数据、UUID、发射功率；缺字段显示为空而不是 0
- **证据：** `ScanResult` 字段说明

### BT-061 不可连接广播不能发起 GATT

- **判定：** 支持
- **Given** `connectable` 为 false
- **When** 用户点连接
- **Then** 不调用 `gatt.connect`；说明该广播不可连接
- **证据：** `ScanResult.connectable`

## 8. 广播与 GATT 服务端

### BT-062 传统广播超过 31 字节失败

- **判定：** 支持
- **Given** 未开启扩展广播
- **When** 设备名与服务 UUID 等合计超过 31 字节并 `startAdvertising`
- **Then** 失败可见（2902054）；不显示「正在广播」
- **证据：** FAQ「广播报文长度超出 31 字节」；错误码 2902054

### BT-063 不能任意填写 AD Type

- **判定：** 缺口
- **Given** 用户想发送 Type 0x01 或其他未列出的 Type
- **When** 编辑广播
- **Then** 没有「自定义 Type」成功路径。可用字段只对应固定 Type：服务 UUID、serviceData 0x16、厂商数据 0xFF、设备名 0x09
- **证据：** FAQ「蓝牙 BLE 广播是否支持自定义广播 Type 数据」

### BT-064 扩展广播遵守可连接与扫描响应互斥

- **判定：** 支持（API 26.0.0 字段）
- **Given** `isExtended` 为 true
- **When** 同时要求可连接和非空扫描响应
- **Then** 启动前拒绝该组合
- **证据：** `AdvertisingParams` 对 `isExtended`、`connectable`、`advertisingResponse` 的说明

### BT-065 持续广播在离开场景时停止

- **判定：** 支持
- **Given** `duration` 未设或为 0（持续广播）
- **When** 用户停止或离开
- **Then** `stopAdvertising` 之后不再处于广播中
- **证据：** `AdvertisingParams.duration`；查找设备指南要求主动停止

### BT-066 服务端必须应答读写请求

- **判定：** 支持
- **Given** 本机 GATT Server 已添加服务，对端读或写特征
- **When** 收到 `characteristicRead` / `characteristicWrite`
- **Then** 调用 `sendResponse`；否则对端订阅通知会停在 2900099
- **证据：** `GattServer.sendResponse`；指南「蓝牙接口调用报错 2900099」

### BT-067 服务端可以发送通知

- **判定：** 支持
- **Given** 对端已订阅
- **When** 本机 `notifyCharacteristicChanged`
- **Then** 对端 `BLECharacteristicChange` 收到该值
- **证据：** `GattServer.notifyCharacteristicChanged`；低功耗蓝牙连接和传输数据指南

### BT-068 服务端关闭后不再接受请求

- **判定：** 支持
- **Given** Server 已 `close`
- **When** 对端再写
- **Then** 本机不再进入读写回调
- **证据：** `GattServer.close`

## 9. GATT 客户端

### BT-069 未连接不能发现服务

- **判定：** 支持
- **Given** GATT 未连接
- **When** 调用 `getServices`
- **Then** 失败（2901003 或等价）；不显示空服务树冒充成功
- **证据：** 错误码 2901003；最佳实践「连接后 getServices 获取不到」要求先连上

### BT-070 服务发现完成前不能读写

- **判定：** 支持
- **Given** 已连接但 `getServices` 未完成
- **When** 读或写特征
- **Then** 操作不发出
- **证据：** 最佳实践「蓝牙数据传输报错失败」；2900099 指南中的调用顺序

### BT-071 特征必须属于已发现服务

- **判定：** 支持
- **Given** 服务列表已返回
- **When** 读写一个不在列表中的 UUID
- **Then** 失败可见（2901008 服务不存在一类）
- **证据：** 低功耗蓝牙连接和传输数据指南；错误码 2901008

### BT-072 读与两种写分开

- **判定：** 支持
- **Given** 特征同时允许读、写、无响应写中的若干种
- **When** 用户选择其中一种
- **Then** 读走 `readCharacteristicValue`；写走 `GattWriteType.WRITE`；无响应写走 `WRITE_NO_RESPONSE`。不允许的属性对应 2901000 或 2901001
- **证据：** `GattWriteType`；错误码 2901000、2901001

### BT-073 描述符可单独读写

- **判定：** 支持
- **Given** 特征下有描述符
- **When** 用户读或写该描述符
- **Then** 使用描述符接口，结果与特征读写分开记录
- **证据：** `readDescriptorValue`、`writeDescriptorValue`

### BT-074 通知与指示分开订阅

- **判定：** 支持
- **Given** 特征支持 notify 或 indicate
- **When** 用户开启其中一种
- **Then** 分别调用 `setCharacteristicChangeNotification` 或 `setCharacteristicChangeIndication`；随后 `BLECharacteristicChange` 带原始值
- **证据：** GATT 客户端对应方法；FAQ 2900099 的顺序：先 MTU，再 `getServices`，再订阅

### BT-075 前一次 GATT 操作未完成时拒绝下一次

- **判定：** 支持
- **Given** 读、写或订阅尚未回调
- **When** 用户立即再发一次
- **Then** 第二次不并发发出；若平台返回 2900099「前序未完成」，文案使用该原因
- **证据：** 错误码 2900099 子原因；2900007 超时

### BT-076 订阅失败区分服务端未应答

- **判定：** 支持
- **Given** 对端 GATT Server 不 `sendResponse`
- **When** 订阅通知
- **Then** 失败为 2900007 或 2900099，并说明等待对端应答，而不是「权限不足」
- **证据：** FAQ「setCharacteristicChangeNotification 报错 2900007 或 2900099」

### BT-077 加密不足时显示 GATT 安全错误

- **判定：** 支持
- **Given** 特征需要加密或认证
- **When** 读写返回 2901005、2901006 或 2901007
- **Then** 文案分别为未加密、未认证、未授权，并提供配对入口
- **证据：** 错误码 2901005–2901007

### BT-078 断开后服务树清空

- **判定：** 支持
- **Given** 已有服务树
- **When** `BLEConnectionStateChange` 变为断开
- **Then** 树不再可读写；断开原因字符串（若有，如 `0X16_LOCAL_HOST`）可见
- **证据：** `BLEConnectionChangeState.reasonMessage`（26.0.0）

### BT-079 连接后可读 RSSI

- **判定：** 支持
- **Given** GATT 已连接
- **When** 用户读取 RSSI
- **Then** `getRssiValue` 的结果以 dBm 显示；失败可见
- **证据：** `GattClientDevice.getRssiValue`

## 10. MTU、PHY、连接参数

### BT-080 未协商 MTU 按 23 字节

- **判定：** 支持
- **Given** 已连接且未调用 `setBLEMtuSize`
- **When** 查看 MTU
- **Then** 显示 23
- **证据：** `setBLEMtuSize` 说明

### BT-081 MTU 超出范围被拒绝

- **判定：** 支持
- **Given** 已连接
- **When** 请求小于 23 或大于 517
- **Then** 不发起协商；提示范围
- **证据：** 参数说明；FAQ「协商 MTU 参数失败」

### BT-082 协商结果以 MTU 事件为准

- **判定：** 支持
- **Given** 请求 185
- **When** `setBLEMtuSize` 已返回但 `BLEMtuChange` 尚未到
- **Then** 界面仍为协商中；事件到达后显示事件里的值，可能小于请求值
- **证据：** `on('BLEMtuChange')`；FAQ 要求连接成功之后再协商

### BT-083 无响应写按当前 MTU 分片

- **判定：** 支持（应用层）
- **Given** 已协商 MTU，用户发送长于单包载荷的数据
- **When** 选择无响应写
- **Then** 按载荷上限分段顺序发送，段间不并发；日志能看到段数
- **证据：** 行业 `ThroughputManager` / `UARTManager` 的 `chunked`；平台单次 ATT 受 MTU 约束

### BT-084 连接参数只有三档

- **判定：** 缺口（数字间隔）；三档为支持（API 22+）
- **Given** API 22+ 且已连接
- **When** 用户选择低功耗、均衡或高速率
- **Then** 调用 `updateConnectionParam` 的对应枚举。没有连接间隔、从机延迟、监督超时的数字输入
- **证据：** `ConnectionParam22+` 只有 `LOW_POWER`、`BALANCED`、`HIGH`

### BT-085 PHY 读写失败时显示能力不支持

- **判定：** 待证
- **Given** API 23+ 且已连接
- **When** `readPhy` 或 `setPhy` 返回 801
- **Then** 显示当前设备不支持，不把 PHY 显示成已切换
- **证据：** `readPhy23+` / `setPhy23+` 错误码 801；`BlePhy23+`

## 11. 吞吐、报文、日志

### BT-086 吞吐会话暂停逐包日志

- **判定：** 支持（应用层）
- **Given** 用户对选定可写特征开始吞吐
- **When** 测试进行
- **Then** 界面显示已发送字节与用时；逐包十六进制不写入该次记录。结束后恢复普通日志
- **证据：** nRF Toolbox `ThroughputManager` 在计时期间清空 logger。平台无单独吞吐 API

### BT-087 吞吐可被用户停止

- **判定：** 支持（应用层）
- **Given** 吞吐进行中
- **When** 用户停止
- **Then** 不再继续写；已发送字节保留

### BT-088 应用内不能抓空口 HCI

- **判定：** 缺口
- **Given** 普通应用会话
- **When** 用户要求抓空口包
- **Then** 不出现应用内 HCI 文件；说明需开发者模式采集，再用 PC 工具打开
- **证据：** `开发/指南/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/蓝牙常见问题/如何抓取蓝牙HCI日志/如何抓取蓝牙HCI日志.md`

### BT-089 Release 的 HCI 日志没有载荷

- **判定：** 缺口（Release payload）
- **Given** Release 版本上的开发者 HCI 采集
- **When** 用 Wireshark 或 Ellisys 打开
- **Then** 预期只有 Header；界面若引导抓包，写明载荷被去掉
- **证据：** 同上

### BT-090 会话日志可按条导出且含原始值

- **判定：** 支持（应用层）
- **Given** 一次 SPP 或 GATT 会话中有收发
- **When** 用户导出
- **Then** 导出含时间、方向、原始字节；导出失败可见。清屏只影响显示，不删已导出文件

## 12. 回连、后台、诊断

### BT-091 重连前销毁旧的 GATT 客户端

- **判定：** 支持
- **Given** 同一设备的 `GattClientDevice` 曾经连接后断开
- **When** 再次连接
- **Then** 使用新的客户端实例；若仍用旧对象导致 2900099，提示为客户端未销毁
- **证据：** 错误码 2900099 子原因「GATT 设备重连后接口调用失败-gattClient 对象未及时销毁」

### BT-092 回连失败次数可见且能停止

- **判定：** 支持（应用层）
- **Given** 用户打开自动回连，对端不可达
- **When** 连续失败
- **Then** 每次失败有次数与原因；用户可关闭自动回连，之后不再发起

### BT-093 扫描未停时不回连

- **判定：** 支持
- **Given** BLE 或经典扫描仍在进行
- **When** 自动回连触发
- **Then** 先停扫描再连接；若返回「扫描期间不允许连接」，显示该原因
- **证据：** 错误码 2900099 子原因

### BT-094 未申请长时任务时，退后台可能断开

- **判定：** 支持（现象）；要保活则必须走长时任务
- **Given** 未申请 `BLUETOOTH_INTERACTION` 长时任务
- **When** 应用退到后台并被挂起
- **Then** 会话可变为断开，且原因不是「对端主动断开」的误导文案
- **证据：** FAQ「应用长期在后台会不会被杀掉」；`开发/FAQ/系统开发/网络/短距通信（Connectivity）/蓝牙相关业务开发中长时任务的使用流程以及注意事项.md`

### BT-095 长时任务声明蓝牙交互类型

- **判定：** 支持
- **Given** 用户打开后台保持，且授予 `KEEP_BACKGROUND_RUNNING`
- **When** GATT 或 SPP 已连接并退到后台
- **Then** `backgroundModes` 含蓝牙交互类型后任务处于运行；用户停止或断开后任务取消
- **证据：** 同上。未在真机执行，故实现阶段仍要真机复验

### BT-096 重复订阅同一事件不会多播

- **判定：** 支持
- **Given** 已经 `on` 某个蓝牙事件
- **When** 页面再次出现
- **Then** 同一次状态变化只更新一次界面。重复 `on` 导致的多次回调被取消订阅去掉
- **证据：** FAQ「蓝牙监听接口重复触发」；「如何解决蓝牙订阅事件异常问题」

### BT-097 操作频繁时可见 2900011

- **判定：** 支持
- **Given** 短时间反复扫描或连接
- **When** 返回 2900011
- **Then** 显示操作频繁，并暂时禁用该按钮
- **证据：** 错误码 2900011

### BT-098 服务停止时全部会话结束

- **判定：** 支持
- **Given** 存在扫描或连接
- **When** 返回 2900001
- **Then** 扫描与连接都结束，提示蓝牙服务已停止
- **证据：** 错误码 2900001

## 覆盖统计

合计 **98** 条（BT-001–BT-098）。按每条开头的判定计数，三者相加为 98。

| 判定开头 | 条数 | 编号 |
|----------|------|------|
| 支持 | 86 | 其余全部。其中应用层即可测量、平台无单独 API 的有 BT-046、BT-083、BT-086、BT-087、BT-090、BT-092。BT-054 仅 API 23+ 有 RSSI 门限，更低版本是缺口。BT-064 的扩展广播互斥字段从 API 26.0.0 起。BT-094 写的是未申请长时任务时会被挂起 |
| 缺口 | 10 | BT-008 模拟器、BT-015 经典扫描无平台过滤、BT-023 不能取消配对、BT-024 普通应用不能做系统配对确认、BT-034 BLE 地址不能直接 SPP、BT-035 不能先经典再 BLE、BT-063 不能任意 AD Type、BT-084 没有数字连接间隔（三档枚举仍支持）、BT-088 应用内无 HCI、BT-089 Release HCI 无载荷 |
| 待证 | 2 | BT-030 免配对地址固化（ACL）、BT-085 PHY 是否返回 801 |

本清单不包含星闪、A2DP 听歌、HID 注入、DFU。那些不是本次蓝牙通用调试范围。
