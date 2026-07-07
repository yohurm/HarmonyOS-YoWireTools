# 02 — SimpleBT / SimpleBLE 逐步对照 YoWire

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **竞品**：[02-SimpleBluetoothTerminal…](../../01-功能清单/09-竞品APP功能清单/02-SimpleBluetoothTerminal-经典SPP-全量功能清单.md) · [03-SimpleBluetoothLeTerminal…](../../01-功能清单/09-竞品APP功能清单/03-SimpleBluetoothLeTerminal-BLE-UART-全量功能清单.md)  
> **YoWire 流程**：[02-经典SPP…](../02-蓝牙模块/02-经典SPP逐步交互流程.md) · [03-BLE-UART…](../02-蓝牙模块/03-BLE-UART逐步交互流程.md)  
> **深研**：`.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md`

---

## 0. 映射总览

| 竞品 App | 竞品步号域 | YoWire 文档 | YoWire 步号域 |
| --- | --- | --- | --- |
| SimpleBluetoothTerminal | SPP-01～29 | 02-经典SPP | 步1～ · INQ-* · CS-* · T-* |
| SimpleBluetoothLeTerminal | UART-01～22 | 03-BLE-UART | U-* · ST-* · F-* · MTU-* |
| Play 完整版增量 | SBT-META-P01 Macros 等 | 04 模块设置·命令 | CMD-* |

**YoWire 增值（相对两竞品）**：

| 增值项 | 竞品 | YoWire |
| --- | --- | --- |
| Inquiry 附近发现 | **无**（E-SBT-002） | Segmented「附近」INQ-1～9 |
| Filter | **无** | SppFilterSheet / BleUartFilterSheet |
| 连接阶段条 | status 混排 | `UartStageBar` 四步 ST-0～6 |
| Connect Sheet UUID | 硬编码 RFCOMM | CS-1～9 |
| GATT fallback | SBLE 失败仅 status | `btnSwitchToGatt` F-3 |
| SessionLog / 命令面板 | **无** | 蓝牙 ⚙ |

---

## 1. 应用骨架 0-* → YoWire 三路径 IA

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| 0-1 | 冷启动 | MainActivity → DevicesFragment | 步1～2 | `TabItem_bluetooth` · `NavItem_classicSpp` / `NavItem_bleUart` | [02 §2](../02-蓝牙模块/02-经典SPP逐步交互流程.md) · [03 §2](../02-蓝牙模块/03-BLE-UART逐步交互流程.md) | **IA 差**：YoWire L0 三入口 |
| 0-2 | 仅 2 屏 IA | 列表 → 终端 | — | L1 扫描 + L2 终端 + ⚙ | 02 · 03 | **增值** Connect Sheet / 设置 |

---

## 2. 经典 SPP SPP-01～29 → 02-经典SPP

### 2.1 设备列表 DevicesFragment

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-01 | 冷启动 | 空态 `initializing...` | 步3～5 | `EmptyState_paired` · `CapabilityBanner_bt` | 02 §2 · §3.1 | 对齐 + Banner |
| SPP-02 | onResume 自动 refresh | 列表刷新 | 步4 | `SegmentedTab_paired` | 02 §3.1 | 对齐 |
| SPP-03 | 枚举已配对非 LE | getBondedDevices 过滤 | 步1 | `SppDeviceList` | 02 §3.1 | 对齐 |
| SPP-04 | 列表空 | no paired / disabled / permission | 步3 | `EmptyState_paired` | 02 §3.1 | **增值** 具体原因 Chip |
| SPP-05 | ⋮ → **Refresh** | menu_devices bt_refresh | 步4 | `btnScanToggle`（已配对=刷新） | 02 §2.1 · §3.1 | **IA 差**：顶栏图标非 ⋮ |
| SPP-06 | ⋮ → **Bluetooth settings** | ACTION_BLUETOOTH_SETTINGS | Pairing步6 · CS | `btnSystemBtSettings` | 02 §5 · §6 | 对齐 |
| SPP-07 | API31+ 无 CONNECT 权限 | Refresh 引导授权 | 步5 | `CapabilityBanner_bt` | 02 §2 | HarmonyOS 对照 |
| SPP-08 | **点击列表行** | 立即 push TerminalFragment | 步5～6 | `SppDeviceRow` → `ConnectSheet` | 02 §3.1 | **增值** Connect Sheet 非直进 |

### 2.2 YoWire-only：Inquiry / Filter / 收藏

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **无 Inquiry** | — | INQ-1～9 | `SegmentedTab_nearby` · `InquiryTimer` | 02 §3.2 | **YoWire P0 增值** |
| — | **无 Filter** | — | Filter步1～5 | `SppFilterSheet` · `filterNameMac` | 02 §4 | **YoWire P1 增值** |
| — | **无收藏 Tab** | — | §3.3 | `SegmentedTab_favorites` · `btnFavoriteStar` | 02 §3.3 | **YoWire P1 增值** |
| — | **无 ⚙ 设置** | — | 顶栏 | `btnModuleSettings` | 02 §2.1 · [04](../02-蓝牙模块/04-模块设置与会话命令流程.md) | **YoWire 模块自治** |

### 2.3 终端生命周期 SPP-09～14

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-09 | 进入终端读 MAC 参数 | Bundle "device" | CS-1 | `ConnectSheet` TargetSummary | 02 §6 | **增值** Sheet 显 UUID |
| SPP-10 | setRetainInstance | 防旋转 | FC | 状态持久 | [07-840vp](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md) | 对齐 |
| SPP-11 | onAttach bind SerialService | bindService | 步3 | `SerialService` | 02 §7.1 | 对齐 |
| SPP-12 | onStart startService | 防 unbind 销毁 | 步3 | `SerialService` | 02 §7.1 | 对齐 |
| SPP-13 | onResume **auto-connect** | 首次 connect() | 步2 · CS | `SppAutoConnect` | 02 §7.1 | ⚙ 可关 auto-connect |
| SPP-14 | onServiceConnected attach | 队列回放 | 步3 | `SerialService.attach` | 02 §7.1 | **增值** SessionLog 回放 |

### 2.4 连接阶段 SPP-15～20 → Connect Sheet + status

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-15 | connecting... | status 色 TextView | CS-10 | `DataTerminal_status` | 02 §6.2 | **增值** Connect Sheet 超时 Slider |
| SPP-16 | RFCOMM SPP UUID 硬编码 | 00001101-… | CS-2 | `radioUuidStandard` | 02 §6.1 | **增值** 收藏/手动 UUID |
| SPP-17 | connected | status 行 | CS-11 | `ConnectionChip_connected` | 02 §6.2 | **增值** 时长/统计 ContextStrip |
| SPP-18 | connection failed | status + disconnect | CS-12 | `DataTerminal_status` | 02 §6.2 | **增值** 错误码卡 |
| SPP-19 | 读循环 append | receive_text | T-5～9 | `DataTerminal` | 02 §8 | **增值** SessionLog 落盘 |
| SPP-20 | connection lost | onSerialIoError | CS-13 | `DataTerminal_status` | 02 §6.2 | **增值** ⚙ 自动重连 CS-6 |

### 2.5 终端菜单 SPP-21～24

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-21 | **Clear** | 清 receiveText | T-3 | `menuClear` | 02 §7.2 · §8 | 不清 SessionLog 对齐 |
| SPP-22 | **Newline** Dialog | CR+LF / LF / none | T-2 | `NewlineDialog` · `menuNewline` | 02 §8 | 对齐 |
| SPP-23 | **HEX** toggle | hexEnabled · HexWatcher | T-1 · T-4 | `menuHex` · `chipHexMode` | 02 §8 | 对齐 |
| SPP-24 | **Background notification** | detach 前台通知 | 步2 ⋮ | `menuBgNotification` | 02 §7.2 | **增值** ⚙ 后台策略 |

### 2.6 发送接收 SPP-25～29

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-25 | 文本发送 + newline | send_btn | T-5 | `sendInput` · `btnSend` | 02 §8 | 对齐 |
| SPP-26 | HEX 发送 | fromHexString | T-6 | `sendInput` | 02 §8 | 对齐 |
| SPP-27 | 未连接 Toast | not connected | T-7 | `btnSend` | 02 §8 | 对齐 |
| SPP-28 | CRLF 跨 chunk | pendingNewline | T-8 | `DataTerminal` | 02 §8 | 对齐 |
| SPP-29 | 接收节流合并 | SerialService queue | T-9 | `SerialService` | 02 §8 | 对齐 E-SBLE-005 同源 |

### 2.7 Play 完整版 vs YoWire（SBT-META-P*）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SBT-META-P01 | Play **Macros** | 终端内宏 | — | ⚙·命令与面板 | [04](../02-蓝牙模块/04-模块设置与会话命令流程.md) · [06](../06-统一后端/02-命令面板与周期发送逐步交互流程.md) | **YoWire** 周期发送在 ⚙ 非终端编辑器 |
| SBT-META-P03 | Pinch 缩放字体 | Play v1.52 | — | ⚙ 显示 | 04 | YoWire 规划 P2 |
| — | 周期发送 | 竞品无（开源） | §9 | `menuPeriodicSend` | 02 §9 | **YoWire PRD** |
| — | 会话记录… | 竞品无 | ⋮步7 | `menuSessionLog` | 02 §7.2 · 04 | **YoWire-only** |
| — | 返回 Keep Dialog | detach 无 Dialog | §15 | `KeepConnectionDialog` | 02 §15 | **YoWire PRD** |

---

## 3. BLE UART UART-01～22 → 03-BLE-UART

### 3.1 扫描页 DevicesFragment

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| UART-01 | 进入页 | 空态 use LE scan / disabled | 步3～5 | `BleUartScanPage` · Banner | 03 §2 | 对齐 + Banner |
| UART-02 | ⋮ → **Scan** | menu ble_scan | 步6 · U-1 | `btnScanToggle` ON | 03 §2 · §3 | **IA 差**：顶栏 Toggle |
| UART-03 | 异步 startScan | LE_SCAN 10s | U-2～4 | `BleScanner` · `ScanTimer_10s` | 03 §3 | ⚙ 可配 duty |
| UART-04 | 扫描结果 | `<unnamed>` + MAC | U-5 | `BleUartDeviceRow` | 03 §3.1 | **增值** RSSI 条 |
| UART-05 | ⋮ → **Stop** | ble_scan_stop | U-6 · 步7 | `btnScanToggle` OFF | 03 §3 | 对齐 |
| UART-06 | **点击设备先 stopScan** | onListItemClick 第一行 stop | U-7 | `BleUartDeviceRow` | 03 §3 | **P0 对齐** nRF/GATT |
| UART-07 | 无定位权限 M | AlertDialog → FINE_LOCATION | 步4 | `CapabilityBanner_location` | 03 §2 | HarmonyOS 合一说明 |
| UART-08 | 定位关 fallback Discovery | startDiscovery | 步5 | `Banner_locationService` | 03 §2 | 平台降级文案 |

### 3.2 YoWire-only：Filter / ⚙ / 阶段条

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **无 Filter** | — | F-1～5 | `BleUartFilterSheet` | 03 §3.2 | **YoWire P1** |
| — | **无 MTU UI** | payload 仅 Log | MTU-1～6 · 步2 | `chipMtu` · `ContextStrip` | 03 §6 · §8 | **YoWire P0 增值** |
| — | status 混排连接阶段 | Terminal status 行 | ST-0～6 | `UartStageBar` · `stepIndicator_*` | 03 §4 | **YoWire P0 增值 阶段条** |
| — | **无 Profile 选手动** | 自动 4 Profile | ST-4 · CS | `chipMatchedProfile` · Connect Sheet | 03 §4.3 · ⚙ | 专家 Profile 选择 |

### 3.3 连接链 UART-09～17 → 四步 Profile

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| UART-09 | connectGatt LE | Log connectGatt | ST-1 | `UartStage_step1` | 03 §4.2 | **增值** 显式 Stepper |
| UART-10 | pairing request | status 字符串 | PR-1～2 | `PairingSheet` | 03 §5 | **增值** Sheet ≥600vp |
| UART-11 | discoverServices | onConnected | ST-2 | `UartStage_step2` | 03 §4.2 | 对齐 |
| UART-12 | Profile 匹配 | NUS/CC254x/Microchip/Telit | ST-4 | `chipMatchedProfile` | 03 §4.3 | 对齐 4 预设 |
| UART-13 | no serial profile found | connection failed status | F-1 | `UartErrorCard` | 03 §7 | **增值 GATT fallback** |
| UART-14 | request max MTU 512 | connectCharacteristics2 | ST-5 · MTU-1 | `MtuNegotiator` | 03 §4 · §6 | 对齐 |
| UART-15 | payload = mtu-3 | onMtuChanged Log | MTU-2～3 | `chipMtu` · `ContextStrip` | 03 §6 | **增值** 顶栏 MTU Chip |
| UART-16 | enable Notify CCCD | connectCharacteristics3 | ST-5 | `UartStage_step4` | 03 §4.2 | 对齐 |
| UART-17 | connected | onSerialConnect | ST-5 完成 | `UartTerminalPage` | 03 §8 | 进入终端 |

### 3.4 GATT Fallback（YoWire-only）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| UART-13 | 仅 status 失败 | 无跳转 | F-3 | `btnSwitchToGatt` | 03 §7 | **YoWire P0 增值** |
| — | — | — | F-3 步1～3 | `NavItem_bleGatt` · `BleDeviceRow_selected` | 03 §7.1 | 预选 MAC + Banner |
| — | — | — | F-4 | `btnRescan` | 03 §7 | YoWire-only |

### 3.5 终端 UART-18～22（与 SPP 同构）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| UART-18 | fragment_terminal 布局 | receive + send + btn | 步1 | `UartTerminalPage` | 03 §8 | 同构 + Profile/MTU Chip |
| UART-19 | Clear/Newline/HEX/Bg | menu_terminal | ⋮ | 同 SPP T-* | 03 §8 | 对齐 SPP-21～24 |
| UART-20 | auto-connect SerialSocket | onResume connect | 步4 | `SerialService` | 03 §8.2 | 对齐 |
| UART-21 | write 按 payloadSize 分包 | writeBuffer 队列 | MTU-4 | `WriteQueue` | 03 §6 | 对齐 |
| UART-22 | **无 MTU UI** | — | 步2～3 | `chipMtu` · `chipProfile` | 03 §8.1 | **YoWire 增值** |

---

## 4. 宽屏 840vp 对照

| 竞品 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| push 全屏终端 | TerminalFragment 全屏 | W-SPP | B 列表 C Terminal | 02 §16 · doc 17 | **GAP-840** |
| push 全屏 UART 终端 | 同上 | W-UART | B SCAN 列表 C Stage/Terminal | 03 §10 · doc 17 | 三分栏 |
| Connect 无 Sheet | 直进 | CS 宽屏 | 居中 480×560 | 02 §6 | 对齐 |
| Pairing 系统 Dialog | 仅系统 UI | PR 宽屏 | PairingSheet 600vp+ | 03 §5 | **增值** |

---

## 5. 蓝牙 ⚙ 映射（竞品均无设置页）

| 竞品能力 | 竞品 | YoWire分组 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- |
| UUID 硬编码 | SPP SerialSocket | ⚙·经典蓝牙 | 02 §6 · 04 | Connect Sheet + 设置 |
| Inquiry 时长 | 无 | ⚙·连接·Inquiry Slider | 02 §3.2 | YoWire-only |
| 扫描 10s duty | SBLE LE_SCAN_PERIOD | ⚙·BLE 扫描 | 03 · 04 | YoWire-only |
| UART Profile 默认 | 自动匹配 | ⚙·UART Profile | 03 §4.3 · 04 | YoWire-only |
| SessionLog 导出 | 无 | ⚙·会话与日志 | 04 · [06](../06-统一后端/01-会话日志导出逐步交互流程.md) | YoWire-only |
| 命令/周期发送 | Play Macros 部分 | ⚙·命令与面板 | 04 · 06 | YoWire-only |

---

## 6. SBLE Profile UUID 对照表（步骤 3 展示）

| Profile | Service UUID（竞品源码） | 竞品步号 | YoWire Step3 文案 | YoWire控件名 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Nordic UART | 6e400001-… | UART-12 | Nordic UART | `chipMatchedProfile` | P0 默认 |
| TI CC254x | 0000ffe0-… | UART-12 | CC254x | 同上 | P1 |
| Microchip | 49535343-FE7D-… | UART-12 | Microchip | 同上 | P1 |
| Telit Bluemod | 0000FEFB-… | UART-12 | Telit | 同上 | P2 credits 流控 |

---

## 7. 验收勾选

- [ ] SPP 已配对列表 + Refresh 对齐 SPP-01～08  
- [ ] Inquiry + Filter + Connect Sheet（YoWire 增值）  
- [ ] 终端 Clear/HEX/Newline/发送 对齐 SPP-21～29  
- [ ] UART SCAN/STOP + **点击 stopScan** 对齐 UART-06  
- [ ] **UartStageBar** 四步 + MTU Chip（YoWire 增值）  
- [ ] Profile 失败 → **改用 GATT**（YoWire 增值）  
- [ ] ⚙ SessionLog / 周期发送（YoWire-only）  
- [ ] ≥840vp B/C 分栏（doc 17）

---

## 8. 证据索引

| 键 | 路径 |
| --- | --- |
| SPP 清单 | `09/02-SimpleBluetoothTerminal-经典SPP-全量功能清单.md` |
| SBLE 清单 | `09/03-SimpleBluetoothLeTerminal-BLE-UART-全量功能清单.md` |
| inventory 19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` |
| doc 17 | `.research/feature-inventory/17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md` |

---

## 9. SerialService 双队列对照（E-SBT-006）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-14 | service.attach 回放 queue | SerialService | 步3 | `SerialService.attach` | 02 §7.1 · 03 §8 | 对齐 |
| SPP-24 | detach → 前台通知 | Background notification | 步2 ⋮ | `menuBgNotification` | 02 §7.2 | ⚙ 后台可覆盖 |
| — | 通知 Disconnect 动作 | Notification action | — | `NotificationDisconnectAction` | 04 设置·后台 | YoWire 规划 |
| — | queue2 无 listener 缓存 | SerialService 内部 | — | `SessionLogService` | 04 · 06 | **YoWire 持久化** |

---

## 10. BLE UART 权限分支逐步（SBLE-PERM）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SBLE-PERM-01 | API31+ SCAN+CONNECT | RequestMultiplePermissions | 步4 | `CapabilityBanner_ble` | 03 §2 | HarmonyOS 对照 |
| SBLE-PERM-02 | API23-30 FINE_LOCATION | AlertDialog | 步4 | `CapabilityBanner_location` | 03 §2 | 对齐 UART-07 |
| SBLE-PERM-03 | 定位关 → Discovery | startDiscovery fallback | 步5 | `Banner_locationService` | 03 §2 | 对齐 UART-08 |
| SBLE-PERM-04 | LeScanner null | fallback DISCOVERY | 步5 | 平台降级文案 | 03 §2 | 对齐 |
| SBLE-PERM-06 | 配对广播 | pairing request status | PR-1 | `PairingSheet` | 03 §5 | 对齐 UART-10 |

---

## 11. Telit Credits 流控链（竞品独有复杂度）

| 竞品步号 | 竞品阶段 | 竞品 Log/status | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SBLE-PROF-T-06-1 | 写 RX Credits CCCD | connectCharacteristics 子步 | ST-4 子步 | `UartStage_telitCredits` | 03 §4 | P2 Profile |
| SBLE-PROF-T-06-2 | MTU 后写 RX CCCD | 多步 CCCD | ST-5 | `UartStage_step4` | 03 §4 | 合并为步骤4 |
| SBLE-PROF-T-06-3 | grantReadCredits 异步 | status 混排 | ST-5 | `TelitCreditsIndicator` | 03 §4 | **增值** 阶段条显式 |

---

## 12. 周期发送与命令收藏（YoWire vs Play）

| 能力 | SimpleBT 开源 | Play 完整版 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| 周期发送 | ✗ | 部分 Macros delay | §9 | `menuPeriodicSend` · `IntervalSheet` | 02 §9 · 06 | **YoWire PRD** |
| 命令收藏 | ✗ | Macros | ⚙ | `CommandPanel` | 04 · 06 | 编辑在 ⚙ |
| Panel Grid | ✗ | ✗ | ⚙ | `PanelGridEditor` | 04 · 06 | PacketSender 吸收 WiFi |
| 从收藏选择 | ✗ | ✗ | T-* | `btnPickFromFavorites` | 02 §8 · 03 §8 | 终端快捷 Sheet |

---

## 13. 840vp 经典/UART 线框逐步（doc 17 摘要）

| 场景 | 竞品 | YoWire B 栏 | YoWire C 栏 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| SPP 已配对 | 全屏列表 | Segmented + 列表 | ConnectSheet / Terminal | 02 §16 | doc 17 |
| SPP 终端 | 全屏 Terminal | 活跃 Session 摘要 | DataTerminal 70% | 02 §16 | 无第四 Inspector |
| UART 扫描 | 全屏 Scan | SCAN toggle + 列表 | Stage/Terminal | 03 §10 | doc 17 |
| ⚙ 设置 | 无 | A 保持 | C navigate 设置 | 04 · 07/03 | push 非 Sheet |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `08-竞品逐步流程对照/` |
| 版本 | 深研草稿 v0.1 |
