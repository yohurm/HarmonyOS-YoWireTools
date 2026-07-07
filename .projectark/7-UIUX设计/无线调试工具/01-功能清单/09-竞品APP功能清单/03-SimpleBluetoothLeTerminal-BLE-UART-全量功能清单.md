# 03-SimpleBluetoothLeTerminal — BLE UART 全量功能清单

> **状态**：深研草稿，未定稿  
> **竞品**：kai-morich / [SimpleBluetoothLeTerminal](https://github.com/kai-morich/SimpleBluetoothLeTerminal)（开源简化版）  
> **Play 完整版**：`de.kai_morich.serial_bluetooth_terminal`（与经典 SPP 同包；Play 描述含 Nordic/CC254x/Microchip/Telit 等 BLE UART Profile）  
> **YoWire 映射目标**：`01-功能清单/02-蓝牙模块/03-BLE-UART功能清单.md`  
> **证据链**：`.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §2 · `07-联网调研证据/01-竞品版本基线与公开证据索引.md` E-SBLE-* / E-SBT-005  
> **核验日期**：2026-07-03（GitHub `master` SerialSocket.java 648 行 + DevicesFragment 源码）

---

## 1. 应用元数据（SBLE-META-*）

| ID | 属性 | 值 | 证据 |
| --- | --- | --- | --- |
| **SBLE-META-01** | 应用名（开源） | Simple Bluetooth LE Terminal | E-SBLE-001 · https://github.com/kai-morich/SimpleBluetoothLeTerminal |
| **SBLE-META-02** | 包名（开源） | `de.kai_morich.simple_bluetooth_le_terminal` | GitHub 仓库 |
| **SBLE-META-03** | 与 Play 关系 | Play **Serial Bluetooth Terminal** 合并 Classic + LE；开源拆两仓库 | E-SBT-005 |
| **SBLE-META-04** | 许可 | MIT | E-SBLE-001 |
| **SBLE-META-05** | 目标设备（Play） | nRF51822/micro:bit、HM-10/CC41-A、RN4870/71、Telit Bluemod 等 | E-SBT-005 商店描述 |
| **SBLE-META-06** | 自定义 Profile（Play） | CC2640 serial（除 config 特征）、BLE113、uConnect 等 **Play 完整版** | E-SBT-005 · 开源仅 4 预设 |
| **SBLE-META-07** | 架构注释 | 「wrap BLE communication into socket like class」 | SerialSocket.java 文件头 |
| **SBLE-META-08** | 与 SPP 开源同构 | `TerminalFragment` / `SerialService` **共用设计**；仅 `SerialSocket` 构造不同 | `19` §2.4 · E-SBLE-005 |

**YoWire 差分（Meta）**：YoWire 将 BLE UART 提升为蓝牙首页 **独立 L1「BLE 串口预设」**；竞品仅为单 App 内 LE 扫描页（SBLE-IA-02）。

---

## 2. 信息架构（SBLE-IA-*）— 两屏模型

| ID | 层级 | 屏幕 | Fragment | 与 SPP 差异 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBLE-IA-01** | L0 | 单 Activity | `MainActivity` → 默认 `DevicesFragment` | 同 SPP | E-SBLE-001 |
| **SBLE-IA-02** | L1 | **LE 扫描设备列表** | `DevicesFragment`（SCAN/STOP 菜单） | **非**已配对列表 | UART-01~08 |
| **SBLE-IA-03** | L2 | **终端** | `TerminalFragment` + `fragment_terminal.xml` | 布局 **同 SPP** | UART-18 |
| **SBLE-IA-04** | — | 无 Profile 选手动 UI | 连接后 **自动**匹配 4 Profile | YoWire Connect Sheet 可选 Profile | UART-12 |
| **SBLE-IA-05** | 返回栈 | Back 离开终端 | `onPause` → **stopScan**（若在扫描页则停） | 连接保持 + detach 通知 | DevicesFragment.onPause |
| **SBLE-IA-06** | 参数 | `Bundle "device"` | MAC address | 同 SPP | UART-20 |
| **SBLE-IA-07** | 列表项 | `<unnamed>` | 名为空时占位 | 同左 | UART-04 |
| **SBLE-IA-08** | 无 GATT 树 | 失败仅 status 行 | YoWire **改用 GATT 调试** 跳转 | UART-13 · B-UART-C-05 |

**YoWire 差分（IA）**

| 竞品 SBLE | YoWire | 映射 |
| --- | --- | --- |
| 2 屏 LE 扫描 → 终端 | 三路径 IA + 显式阶段条 + MTU 顶栏 | B-UART-S-10, C-01~09, T-04 |
| 无 Filter | Filter Sheet → ⚙·BLE 扫描 | B-UART-S-09 |
| 无 MTU UI | 顶栏 `NUS · MTU 247 · payload 244` | B-UART-M-02, T-04 |

---

## 3. 权限与扫描分支（SBLE-PERM-*）

| ID | API 级别 | 条件 | 权限 / 降级 | UI | 证据 URL |
| --- | --- | --- | --- | --- | --- |
| **SBLE-PERM-01** | 31+ (S) | 扫描前 | `BLUETOOTH_SCAN` + `BLUETOOTH_CONNECT`（`RequestMultiplePermissions`） | 拒绝则无法 Scan | https://github.com/kai-morich/SimpleBluetoothLeTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_le_terminal/DevicesFragment.java |
| **SBLE-PERM-02** | 23~30 (M) | 扫描前 | `ACCESS_FINE_LOCATION` | AlertDialog 解释 → 申请 | UART-07 |
| **SBLE-PERM-03** | 23~30 | 定位服务关闭 | **fallback** `startDiscovery()` 经典发现（兼 LE） | 注释说明 LESCAN 需 location services | UART-08 |
| **SBLE-PERM-04** | 任意 | `BluetoothLeScanner==null` | fallback DISCOVERY | — | DevicesFragment.startScan |
| **SBLE-PERM-05** | 33+ | 后台通知 | `POST_NOTIFICATIONS` | 同 SPP TerminalFragment | UART-19 |
| **SBLE-PERM-06** | — | 配对广播 | `ACTION_PAIRING_REQUEST` / `ACTION_BOND_STATE_CHANGED` | status：`pairing request` | UART-10 · E-SBLE-004 |

**YoWire 差分**：HarmonyOS 蓝牙+定位合一权限说明 → `05-全局与权限`；配对 Sheet ≥600vp → B-UART-C-02。

---

## 4. 设备列表页 — DevicesFragment（SBLE-DEV-*）

### 4.1 ScanState 状态机

| ID | 状态 enum | 含义 | 进入 | 退出 |
| --- | --- | --- | --- | --- |
| **SBLE-DEV-S-01** | `NONE` | 未扫描 | 初始 / stopScan 完成 | startScan |
| **SBLE-DEV-S-02** | `LE_SCAN` | BLE LE 扫描中 | `scanner.startScan` | 10s 超时 / Stop / 点击设备 |
| **SBLE-DEV-S-03** | `DISCOVERY` | 经典 discovery fallback | 定位关或 scanner null | `ACTION_DISCOVERY_FINISHED` / stop |
| **SBLE-DEV-S-04** | `DISCOVERY_FINISHED` | discovery 结束中间态 | 广播 FINISHED | stopScan |

### 4.2 生命周期钩子

| ID | 钩子 | 行为 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- |
| **SBLE-DEV-LC-01** | `onCreate` | 注册 LE callback、discovery receiver、权限 Launchers | — | DevicesFragment 构造 |
| **SBLE-DEV-LC-02** | `onActivityCreated` | header + `initializing...` | + Banner | UART-01 |
| **SBLE-DEV-LC-03** | `onCreateOptionsMenu` | inflate `menu_devices.xml`；BT 关则 disable scan | B SCAN/STOP toggle | menu_devices.xml |
| **SBLE-DEV-LC-04** | `onResume` | 注册 discovery receiver；空态 `use LE scan` / disabled | 同左 | UART-01 |
| **SBLE-DEV-LC-05** | `onPause` | **stopScan**；unregister receiver | 同 left | DevicesFragment |
| **SBLE-DEV-LC-06** | `onDestroyView` | `menu=null` | — | DevicesFragment |
| **SBLE-DEV-LC-07** | `onListItemClick` | **第一行 `stopScan()`** 再 push 终端 | **P0 对齐** BT-GATT-03 | UART-06 · **E-SBLE-001** |

### 4.3 菜单项（menu_devices.xml）

| ID | `@id` | 行为 | 扫描中可见性 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBLE-DEV-M-01** | `ble_scan` | `startScan()` | 扫描时 **隐藏** | B 栏 SCAN 按钮 | UART-02 · https://github.com/kai-morich/SimpleBluetoothLeTerminal/blob/master/app/src/main/res/menu/menu_devices.xml |
| **SBLE-DEV-M-02** | `ble_scan_stop` | `stopScan()` | 扫描时 **显示** | 同 SCAN toggle | UART-05 |
| **SBLE-DEV-M-03** | `bt_settings` | `ACTION_BLUETOOTH_SETTINGS` | adapter null 时 disabled | 配对引导 | 同 SPP SBT-DEV-M-02 |

**竞品无**：RSSI Filter、服务 UUID Filter、⚙ 设置 — B-UART-S-09。

### 4.4 startScan() 逐步逻辑

| ID | 步骤 | 逻辑 | 常量/参数 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBLE-DEV-SC-01** | 防重入 | `scanState != NONE` 则 return | — | — | startScan |
| **SBLE-DEV-SC-02** | 决定 LE vs DISCOVERY | 权限 + 定位服务 + scanner | — | 平台降级文案 | UART-07~08 |
| **SBLE-DEV-SC-03** | 清空列表 | `listItems.clear()` | — | — | UART-03 |
| **SBLE-DEV-SC-04** | 空态 | `setEmptyText("<scanning...>")` | — | 倒计时 Chip | UART-02 |
| **SBLE-DEV-SC-05** | 菜单切换 | Scan 隐藏 / Stop 显示 | — | — | UART-02 |
| **SBLE-DEV-SC-06** | LE 扫描 | 新线程 `scanner.startScan(leScanCallback)` | — | 主线程 API 封装 | UART-03 |
| **SBLE-DEV-SC-07** | **10s 自动 stop** | `postDelayed(leScanStopCallback, LE_SCAN_PERIOD)` | **`LE_SCAN_PERIOD = 10000` ms** | ⚙ 可配置 duty | UART-03 · E-SBLE-001 |
| **SBLE-DEV-SC-08** | Discovery | `bluetoothAdapter.startDiscovery()` | — | — | UART-08 |

### 4.5 updateScan() 列表插入

| ID | 规则 | 实现 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- |
| **SBLE-DEV-U-01** | 去重 | `Collections.binarySearch` + 插入 | — | UART-04 |
| **SBLE-DEV-U-02** | 名称 | 空 → `"<unnamed>"` | Filter 名匹配 | UART-04 |
| **SBLE-DEV-U-03** | 副标题 | MAC address | + RSSI / 发现次数 P1 | device_list_item |
| **SBLE-DEV-U-04** | 过滤 classic | discovery 路径：`type != DEVICE_TYPE_CLASSIC` | — | discoveryBroadcastReceiver |

---

## 5. Profile 预设与 UUID 全表（SBLE-PROF-*）

> 源码：`SerialSocket.java` 常量 + 四个 `DeviceDelegate` 内部类  
> 证据：https://github.com/kai-morich/SimpleBluetoothLeTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_le_terminal/SerialSocket.java

### 5.1 通用 GATT

| ID | 名称 | UUID | 用途 | 证据 |
| --- | --- | --- | --- | --- |
| **SBLE-PROF-00** | CCCD | `00002902-0000-1000-8000-00805f9b34fb` | Notify/Indicate 使能 | UART-16 |

### 5.2 Nordic UART Service（NUS）

| ID | 角色 | UUID | 属性 | Delegate |
| --- | --- | --- | --- | --- |
| **SBLE-PROF-N-01** | Service | `6e400001-b5a3-f393-e0a9-e50e24dcca9e` | — | `NrfDelegate` |
| **SBLE-PROF-N-02** | Char RW2 | `6e400002-b5a3-f393-e0a9-e50e24dcca9e` | micro:bit read / adafruit write | 自动判 write |
| **SBLE-PROF-N-03** | Char RW3 | `6e400003-b5a3-f393-e0a9-e50e24dcca9e` | 与 RW2 互补 TX/RX | 双 write 报错 |

**NrfDelegate 逻辑（SBLE-PROF-N-04）**：若 RW2/RW3 均可写 → `multiple write characteristics` 错误；否则 write 特征 → read/notify 特征。

### 5.3 TI CC254x（HM-10 等）

| ID | 角色 | UUID | 说明 |
| --- | --- | --- | --- |
| **SBLE-PROF-C-01** | Service | `0000ffe0-0000-1000-8000-00805f9b34fb` | `Cc245XDelegate` |
| **SBLE-PROF-C-02** | Char RW | `0000ffe1-0000-1000-8000-00805f9b34fb` | **同一特征**读写 |

### 5.4 Microchip RN4870/71

| ID | 角色 | UUID | 说明 |
| --- | --- | --- | --- |
| **SBLE-PROF-M-01** | Service | `49535343-FE7D-4AE5-8FA9-9FAFD205E455` | `MicrochipDelegate` |
| **SBLE-PROF-M-02** | Char RW | `49535343-1E4D-4BD9-BA61-23C647249616` | 读/Notify |
| **SBLE-PROF-M-03** | Char W | `49535343-8841-43F4-A8D4-ECBE34729BB3` | 写（优先）；无则 fallback RW |

### 5.5 Telit Bluemod TIO 2.0（Credits 流控）

| ID | 角色 | UUID | 属性 | 说明 |
| --- | --- | --- | --- | --- |
| **SBLE-PROF-T-01** | Service | `0000FEFB-0000-1000-8000-00805F9B34FB` | — | TelitDelegate |
| **SBLE-PROF-T-02** | TX | `00000001-0000-1000-8000-008025000000` | WNR | write |
| **SBLE-PROF-T-03** | RX | `00000002-0000-1000-8000-008025000000` | N | notify read |
| **SBLE-PROF-T-04** | TX Credits | `00000003-0000-1000-8000-008025000000` | W | 流控 |
| **SBLE-PROF-T-05** | RX Credits | `00000004-0000-1000-8000-008025000000` | I | indicate |

**Telit 连接链（SBLE-PROF-T-06）**：先写 RX Credits CCCD → `connectCharacteristics2`（MTU）→ 再写 RX CCCD → `grantReadCredits()` 异步 credits。

参考：SerialSocket 注释 → https://www.telit.com/wp-content/uploads/2017/09/TIO_Implementation_Guide_r6.pdf

### 5.6 Profile 匹配顺序（connectCharacteristics1）

| 遍历顺序 | 命中 Service UUID | Delegate | sync 连接下一步 |
| --- | --- | --- | --- |
| 1 | 任意 services 循环 | 最后匹配的 CC254x / Microchip / Nrf / Telit | 第一个 hit **break** |
| 失败 | 无 delegate 或 RW 特征 null | 日志 dump 全部 service/char | `no serial profile found` **E-SBLE-003** |

**YoWire 差分**：首期仅 NUS P0；手动 Profile 选择 → B-UART-P-06；自定义 UUID 对 → B-UART-P-05。

---

## 6. 连接阶段链 — SerialSocket GATT（SBLE-CONN-*）

| ID | 阶段 | Log / status | 方法 | YoWire 阶段条 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBLE-CONN-01** | connectGatt | `connectGatt,LE`（API23+ `TRANSPORT_LE`） | `connect()` | 1/4 连接中 | UART-09 |
| **SBLE-CONN-02** | 配对请求 | `pairing request`（string 资源） | `onPairingBroadcastReceive` | 配对 Sheet | UART-10 · **E-SBLE-004** |
| **SBLE-CONN-03** | 已连接 | `discoverServices` | `onConnectionStateChange(CONNECTED)` | 2/4 发现服务 | UART-11 |
| **SBLE-CONN-04** | 服务发现完成 | `servicesDiscovered` | `onServicesDiscovered` → `connectCharacteristics1` | — | SerialSocket |
| **SBLE-CONN-05** | Profile 匹配 | service xxx uart | `connectCharacteristics1` | 3/4 Profile 名 | UART-12 |
| **SBLE-CONN-06** | **无 Profile** | `connection failed: no serial profile found` | 失败 dump UUID | Error + **改用 GATT** | UART-13 · **E-SBLE-003** |
| **SBLE-CONN-07** | MTU 请求 | `request max MTU` | `connectCharacteristics2` → `requestMtu(512)` | 4/4 子步 | UART-14 |
| **SBLE-CONN-08** | MTU 结果 | `payload size = mtu-3` | `onMtuChanged` | **顶栏 MTU**（YoWire） | UART-15 |
| **SBLE-CONN-09** | Notify/Indicate | `enable read notification/indication` | `connectCharacteristics3` | — | UART-16 |
| **SBLE-CONN-10** | CCCD 写完成 | `connected` | `onDescriptorWrite` 成功 → `onSerialConnect()` | 阶段条完成 | UART-17 |
| **SBLE-CONN-11** | 断开 / GATT error | `gatt status <code>` | CONNECTED 前 ConnectError；后 IoError | 错误卡 | SerialSocket |
| **SBLE-CONN-12** | 写特征不可写 | `write characteristic not writable` | properties 检查 | — | connectCharacteristics3 |
| **SBLE-CONN-13** | 无 CCCD | `no CCCD descriptor` | — | — | connectCharacteristics3 |

**MTU 常量（SBLE-CONN-MTU）**

| 常量 | 值 | 说明 |
| --- | --- | --- |
| `MAX_MTU` | 512 | `gatt.requestMtu` 请求上限 |
| `DEFAULT_MTU` | 23 | 初始 payloadSize = 20 |
| `payloadSize` | `mtu - 3` | ATT 开销 |

**YoWire 差分（MTU UI）**：竞品 **无** UI 展示 MTU/payload；YoWire 终端顶栏 + SessionLog 事件 → B-UART-M-02, T-04。

---

## 7. 终端页 — TerminalFragment（SBLE-TERM-*）

> 与 SimpleBluetoothTerminal **同文件结构**；`connect()` 使用 `new SerialSocket(context, device)` 而非 RFCOMM。

| ID | 能力 | SBLE 行为 | 与 SPP 关系 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBLE-TERM-01** | 布局 | receive + send + button | **同构** SPP | C 70/30 | UART-18 |
| **SBLE-TERM-02** | auto-connect | onResume → `SerialSocket` → `service.connect` | 同 SPP-13 | ⚙ 可关 | UART-20 |
| **SBLE-TERM-03** | 菜单 Clear | 清 receiveText | = SBT-TERM-M-01 | 不清 SessionLog | UART-19 |
| **SBLE-TERM-04** | 菜单 Newline | CR+LF / LF / none | = SPP-22 | 同左 | UART-19 |
| **SBLE-TERM-05** | 菜单 HEX | toggle HexWatcher | = SPP-23 | 同左 | UART-19 |
| **SBLE-TERM-06** | 菜单 Background notification | detach 前台通知 | = SPP-24 | 模块后台 | UART-19 |
| **SBLE-TERM-07** | status 混排 | connecting / connected / failed | **无**独立阶段条 | **显式阶段条 P1** | B-UART-C-10 |
| **SBLE-TERM-08** | MTU 显示 | **无** | — | 顶栏 MTU · payload | UART-22 · B-UART-T-04 |
| **SBLE-TERM-09** | 周期发送 | **无** | Play Macros | ⚙·命令 | B-UART-T-05 |
| **SBLE-TERM-10** | SessionLog | **无** | — | SL-TYPE BLE UART | B-UART-T-07 |

### 7.1 发送分包（writeBuffer 队列）

| ID | 规则 | 实现 | 证据 |
| --- | --- | --- | --- |
| **SBLE-TERM-TX-01** | 按 payload 切分 | `data.length > payloadSize` → 多段入队 | UART-21 |
| **SBLE-TERM-TX-02** | writePending | 单 inflight GATT write | SerialSocket.write |
| **SBLE-TERM-TX-03** | Telit credits | `delegate.canWrite()` false 则排队 | TelitDelegate |
| **SBLE-TERM-TX-04** | 完成回调 | `onCharacteristicWrite` → `writeNext()` | SerialSocket |
| **SBLE-TERM-TX-05** | 未连接 | IOException `not connected` | SerialSocket.write |

### 7.2 接收

| ID | 路径 | 行为 | 证据 |
| --- | --- | --- | --- |
| **SBLE-TERM-RX-01** | Notify/Indicate | `onCharacteristicChanged` → `onSerialRead` | SerialSocket |
| **SBLE-TERM-RX-02** | UI 节流 | `SerialService.onSerialRead` 合并 chunk | **E-SBLE-005** · 同 SPP-29 |
| **SBLE-TERM-RX-03** | CRLF / HEX | TerminalFragment.receive 同 SPP | TerminalFragment |

---

## 8. SerialService — 与 SPP 同构（SBLE-SVC-*）

| ID | 能力 | SBLE | 证据 |
| --- | --- | --- | --- |
| **SBLE-SVC-01** | 双队列 attach/detach | **与 SBT-SVC 相同代码结构** | E-SBLE-005 · E-SBT-003 |
| **SBLE-SVC-02** | Read 合并节流 | lastRead + mainLooper.post | SPP-29 |
| **SBLE-SVC-03** | 前台通知 Disconnect | INTENT → SerialSocket.disconnect | E-SBT-003 |
| **SBLE-SVC-04** | GATT 后台断开 | `background disconnect` IOException | SerialSocket receiver |

**YoWire 差分（SessionLog / 命令面板）**：竞品无；YoWire 统一后端 SL-* + ⚙·会话与日志 / 命令与面板。

---

## 9. 逐步流程 UART-01～UART-22 全表

| UART-ID | SBLE 别名 | 用户/系统 | UI / 日志 | 源码 | YoWire 映射 | Evidence URL |
| --- | --- | --- | --- | --- | --- | --- |
| UART-01 | SBLE-DEV-LC-04 | 进入扫描页 | 空态 use LE scan / disabled | onResume | B-UART-S-01 | E-SBLE-001 |
| UART-02 | SBLE-DEV-M-01 | ⋮ Scan | `<scanning...>`；Stop 显示 | startScan | B-UART-S-02 | DevicesFragment |
| UART-03 | SBLE-DEV-SC-06~07 | — | 10s 自动 stop | LE_SCAN_PERIOD | B-UART-S-03 | 同上 |
| UART-04 | SBLE-DEV-U-01~02 | 发现设备 | 名/MAC 列表 | updateScan | B-UART-S-04 | 同上 |
| UART-05 | SBLE-DEV-M-02 | ⋮ Stop | Scan 恢复 | stopScan | B-UART-S-05 | 同上 |
| UART-06 | SBLE-DEV-LC-07 | 点击设备 | **stopScan 首行** | onListItemClick | B-UART-S-06 | **E-SBLE-001** |
| UART-07 | SBLE-PERM-02 | 缺定位权限 | AlertDialog | startScan M | B-UART-S-07 | DevicesFragment |
| UART-08 | SBLE-PERM-03 | 定位关 | fallback Discovery | nextScanState | B-UART-S-08 | 同上 |
| UART-09 | SBLE-CONN-01 | GATT 连接 | connectGatt LE | connect() | B-UART-C-01 | SerialSocket.java |
| UART-10 | SBLE-CONN-02 | 配对 | pairing request | pairing receiver | B-UART-C-02 | **E-SBLE-004** |
| UART-11 | SBLE-CONN-03 | 服务发现 | discoverServices | onConnectionStateChange | B-UART-C-03 | SerialSocket |
| UART-12 | SBLE-CONN-05 | Profile | delegate 命中 | connectCharacteristics1 | B-UART-C-04, P-* | 同上 |
| UART-13 | SBLE-CONN-06 | 无 Profile | no serial profile found | 失败分支 | B-UART-C-05 | **E-SBLE-003** |
| UART-14 | SBLE-CONN-07 | MTU | request max MTU | connectCharacteristics2 | B-UART-C-06 | 同上 |
| UART-15 | SBLE-CONN-08 | MTU 结果 | payload size | onMtuChanged | B-UART-C-07, M-02 | 同上 |
| UART-16 | SBLE-CONN-09 | CCCD | write descriptor | connectCharacteristics3 | B-UART-C-08 | 同上 |
| UART-17 | SBLE-CONN-10 | 就绪 | connected | onDescriptorWrite | B-UART-C-09 | 同上 |
| UART-18 | SBLE-TERM-01 | 终端布局 | receive+send | fragment_terminal | B-UART-T-01 | 同 SPP 仓库 |
| UART-19 | SBLE-TERM-03~06 | 终端菜单 | 四件套 | menu_terminal | B-UART-T-02 | menu_terminal.xml |
| UART-20 | SBLE-TERM-02 | auto-connect | onResume connect | TerminalFragment | B-UART-T-03 | Le Terminal 仓库 |
| UART-21 | SBLE-TERM-TX-01 | 长发送 | writeBuffer 队列 | SerialSocket.write | B-UART-M-03 | SerialSocket.java |
| UART-22 | SBLE-TERM-08 | MTU UI | **无** | — | B-UART-T-04 | YoWire PRD §8.4 |

---

## 10. YoWire 核心差分列

| 维度 | SimpleBLE（本清单） | YoWire | YoWire ID | 证据 |
| --- | --- | --- | --- | --- |
| **Inquiry** | N/A（LE 扫描，非经典 Inquiry） | SPP 路径有 Inquiry；UART 为 LE Scan | B-SPP-09 vs B-UART-S-02 | `19` §2.5 |
| **Filter** | ✗ 无扫描 Filter | 名/RSSI/收藏 Filter Sheet | B-UART-S-09 | `19` §2.5 |
| **MTU UI** | ✗ 仅 Logcat `payload size` | 顶栏 MTU + payload + SessionLog | B-UART-M-02, T-04 | UART-22 |
| **阶段条** | ✗ status 混排 | 1/4~4/4 显式阶段 | B-UART-C-10 | PRD · `17` §3.3 |
| **SessionLog** | ✗ | 模块 ⚙·会话与日志 | B-UART-T-07 | E-SBLE-005 Gap |
| **命令面板** | ✗ 开源；Play Macros | ⚙·命令与面板 | B-UART-T-05~06 | E-SBT-005 |
| **Profile 手动** | ✗ 自动匹配 | Connect Sheet / ⚙ 默认 Profile | B-UART-P-06 | UART-12 |
| **失败→GATT** | ✗ 仅 error 行 | Error 卡 + 跳转 GATT 入口 | B-UART-C-05 | E-SBLE-003 |

---

## 11. E-SBLE / E-SBT 证据注册表

| Evidence ID | URL | 本清单 SBLE 簇 |
| --- | --- | --- |
| E-SBLE-001 | https://github.com/kai-morich/SimpleBluetoothLeTerminal | SBLE-META-*, DEV-LC-07, SC-07 |
| E-SBLE-003 | SerialSocket `no serial profile found` 分支 | SBLE-CONN-06, PROF 失败 |
| E-SBLE-004 | `ACTION_PAIRING_REQUEST` → pairing_request 串 | SBLE-CONN-02, PERM-06 |
| E-SBLE-005 | SerialService Read 合并（与 SPP 同构） | SBLE-SVC-*, TERM-RX-02 |
| E-SBT-005 | https://play.google.com/store/apps/details?id=de.kai_morich.serial_bluetooth_terminal | Play BLE Profile 列表 · Macros |
| E-SBT-004 | SimpleBluetoothTerminal TerminalFragment（Le 版同构） | SBLE-TERM-03~06 |
| E-SBT-003 | SerialService（Le 版同构） | SBLE-SVC-* |
| E-SBLE-19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §2 | UART-01~22 |

---

## 12. 映射至 YoWire `02-蓝牙模块/03-BLE-UART功能清单.md`

| 竞品 SBLE / UART | YoWire B-UART ID | 对齐度 |
| --- | --- | --- |
| SBLE-DEV-SC-07（10s LE scan） | B-UART-S-02~03 | **P0** |
| SBLE-DEV-LC-07（stopScan→连接） | B-UART-S-06 | **P0** · E-SBLE-001 |
| SBLE-PROF-N/C/M/T（四 Profile） | B-UART-P-01~04 | **P0**（YoWire 首期 NUS） |
| SBLE-CONN-06（无 Profile） | B-UART-C-05 | **P1** 失败 UX |
| SBLE-CONN-07~08（MTU 内部） | B-UART-M-01~02, C-06~07 | 底层 P0；**UI 为 YoWire 增值** |
| SBLE-TERM-03~06（终端四菜单） | B-UART-T-02 | **P0** 同 SPP |
| —（Filter） | B-UART-S-09 | **YoWire 增值** |
| —（阶段条 / MTU 顶栏） | B-UART-C-10, T-04 | **YoWire 增值** |
| —（SessionLog / 命令） | B-UART-T-05~07 | **YoWire 增值** |

---

## 13. Telit Credits 流控详表（SBLE-TELIT-*）

| ID | 事件 | 行为 | 日志 |
| --- | --- | --- | --- |
| **SBLE-TELIT-01** | connectCharacteristics | 写 RX Credits CCCD；return false → 异步 | writing read credits descriptor |
| **SBLE-TELIT-02** | Credits CCCD 成功 | → `connectCharacteristics2` MTU | status |
| **SBLE-TELIT-03** | RX data | `grantReadCredits()`；min 16 max 64 credits | grant read credits +N |
| **SBLE-TELIT-04** | TX credits indicate | `writeCredits += newCredits`；resume queue | got write credits |
| **SBLE-TELIT-05** | canWrite | `writeCredits > 0` | no write credits |
| **SBLE-TELIT-06** | onCharacteristicWrite TX | `writeCredits -= 1` | write finished credits |

证据：SerialSocket.java `TelitDelegate` · Telit TIO Implementation Guide（SerialSocket 注释 URL）

---

## 14. 竞品 vs BLE GATT 浏览器边界

| 能力 | SimpleBLE UART | nRF Connect GATT | YoWire |
| --- | --- | --- | --- |
| 全服务树浏览 | ✗ | ✓ | `01-BLE-GATT` |
| 任意 UUID Write | ✗ 仅 4 Profile | ✓ | GATT 入口 |
| UART 自动匹配 | ✓ | 需手选 | UART 入口 |
| Log pane 导出 | ✗ | ✓ SAVE | SessionLog |

**IA 铁律**：UART 失败 **不得** 在 UART 页复刻 GATT；YoWire 提供 **改用 GATT 调试** 按钮 → `03-BLE-UART` README。

---

## 15. 辅助类（SBLE-AUX-*）

| ID | 文件 | 职责 | 证据 |
| --- | --- | --- | --- |
| **SBLE-AUX-01** | `BluetoothUtil.Device` | 包装 `BluetoothDevice` + 缓存 name；二分排序键 | DevicesFragment |
| **SBLE-AUX-02** | `SerialListener` | GATT 事件 → UI 回调 | 与 SPP 共享设计 |
| **SBLE-AUX-03** | `TextUtil` | HEX / 换行 / Caret 显示 | E-SBT-004 |
| **SBLE-AUX-04** | `Constants` | 通知 / Disconnect Intent | 与 SPP 同构 |
| **SBLE-AUX-05** | `strings.xml` | `location_permission_*`, `pairing_request` | UART-07, UART-10 |

---

## 16. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：SBLE-* 全量 ID、四 Profile UUID、GATT 连接链、UART-01~22、YoWire 差分列 |
| 2026-07-03 | 增补 Telit Credits §13、GATT 边界 §14、辅助类 §15 |
