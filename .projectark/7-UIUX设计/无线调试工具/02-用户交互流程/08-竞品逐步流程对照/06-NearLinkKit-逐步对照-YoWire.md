# 06 — NearLink Kit 逐步对照 YoWire

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **竞品/基线**：[07-HarmonyOS-NearLinkKit-全量功能清单.md](../../01-功能清单/09-竞品APP功能清单/07-HarmonyOS-NearLinkKit-全量功能清单.md) · [gitcode nearlink-kit sample](https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code)  
> **YoWire 流程**：[01-能力检测…](../04-星闪模块/01-能力检测与权限引导流程.md) · [02-SSAP-Client…](../04-星闪模块/02-SSAP-Client逐步交互流程.md) · [03-dataTransfer…](../04-星闪模块/03-dataTransfer逐步交互流程.md) · [04-星闪模块设置…](../04-星闪模块/04-星闪模块设置流程.md)  
> **深研**：`.research/feature-inventory/20-星闪模块-功能清单与逐步流程-v2.md`

---

## 0. 映射总览

| Kit 样例页 / API 域 | NLKIT ID | gitcode 样例步骤名（典型） | YoWire 文档 | YoWire 步号 |
| --- | --- | --- | --- | --- |
| 能力/权限 | NLKIT-DEG-* | Entry check / Permission | 01 能力检测 | E-* · U/P/SW/D/R |
| Discovery 扫描 | NLKIT-DSC-* | ScanPage · startScan/stopScan | 02 SSAP §扫描 · 01 NL-02～06 | NL-02～06 |
| SSAP Client | NLKIT-SSAP-C-* | SsapClientPage · connect/getServices | 02 SSAP | NL-A1～A9 |
| SSAP Server | NLKIT-SSAP-S-* | SsapServerPage | 04 设置 P3 | NL-DG-08 |
| dataTransfer | NLKIT-DT-* | DataTransferPage · createPort/writeData | 03 dataTransfer | NL-B1～B8 |
| Advertising | NLKIT-ADV-* | AdvertisingPage | 04 P3 | NL-DG-09 |

**说明**：NearLink **无 OSS 第三方 App 竞品**；本对照以 **HarmonyOS 官方样例 + Kit API** 为「竞品步」，YoWire 为产品化流程。

**UI 参照（非 Kit）**：

| 能力 | 参照竞品 UX | YoWire |
| --- | --- | --- |
| SSAP 树 R/W/N | nRF GATT | NL-A6～A8 |
| dataTransfer 终端 | SimpleBT E-SBT-005 | NL-B4～B6 |

---

## 1. 样例仓库页面 → YoWire IA

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕（gitcode 样例） | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| Sample-0 | 打开 nearlink-kit sample | 多页 Entry / Tab | E-01 | `TabItem_nearlink` | [01 §2](../04-星闪模块/01-能力检测与权限引导流程.md) | YoWire 单 Tab 自治 |
| Sample-Scan | 进入 Scan 页 | `ScanPage` / `startScan` 按钮 | NL-02 | `btnScanToggle` | 02 §4 · 01 NL-02 | 对齐 NLKIT-DSC-01 |
| Sample-SSAP-C | 进入 SSAP Client 页 | `SsapClientPage` | NL-A1 | `btnConnectSsap` | [02 §5](../04-星闪模块/02-SSAP-Client逐步交互流程.md) | 样例分散；YoWire 扫描→详情→SSAP |
| Sample-SSAP-S | 进入 SSAP Server 页 | `SsapServerPage` | — | P3 隐藏 | [04](../04-星闪模块/04-星闪模块设置流程.md) | v1 Client 优先 |
| Sample-DT | 进入 dataTransfer 页 | `DataTransferPage` | NL-B1 | `fieldPortUuid` | [03 §4](../04-星闪模块/03-dataTransfer逐步交互流程.md) | YoWire 统一终端 UX |
| Sample-Adv | Advertising 页 | `startAdvertising` | — | NL-DG-09 | 04 | v1 隐藏 |

---

## 2. 能力检测 NLKIT-DEG → 01 能力检测

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-DEG-01 | 样例启动检查 API | `@kit.NearLinkKit` 可用 | E-02 | `CapabilityCheckService` | 01 §2 E-* | YoWire 全量检测链 |
| NLKIT-APP-03 | 申请 ACCESS_NEARLINK | module.json5 + 运行时 | P-01～05 | `CapabilityBanner_denied` · `btnRequestPermission` | 01 §5 P-* | 对齐 E-NL-004 |
| NLKIT-DSC-12 | 未授权不扫描 | 样例 if-check | P-08 | 扫描按钮置灰 | 01 §5 · 02 | 对齐 |
| NLKIT-DSC-13 | 星闪系统开关 | 系统设置 | SW-01～03 | `CapabilityBanner_switchOff` | 01 §6 SW-* | 对齐 NL-DG-03 |
| NLKIT-APP-05 | 模拟器不支持 | 样例 README | S-01～05 | `CapabilityBanner_simulator` | 01 §4 S-* | 对齐 PRD §5 |
| PRD §4 | 设备不支持 | — | U-01～08 | `PlaceholderPage_unsupported` | 01 §3 U-* | **禁止空白扫描页** |
| PRD §5 | Degraded API | 样例部分能力 | D-01～06 | `CapabilityBanner_degraded` | 01 §7 D-* | YoWire 子能力清单 |
| Ready | 样例直接进入 Scan | Scan 按钮可用 | R-01 | `NearlinkScanPage` | 01 §8 R-* | YoWire L0 扫描列表 |

---

## 3. Discovery 扫描 NLKIT-DSC → NL-02～06

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-DSC-01 | 点 startScan | 样例 Scan 按钮 · `nearLink.startScan()` | NL-02 | `btnScanToggle` ON | 02 §3 · 01 NL-02 | 对齐 |
| NLKIT-DSC-02 | stopScan | 样例 Stop · 连接前 stop | NL-05 · **NL-03** | `btnScanToggle` OFF | 02 §3 · 01 NL-05 | **P0 对齐** BLE GATT |
| NLKIT-DSC-03 | deviceFound 回调 | 列表刷新 name/address/rssi | NL-03 | `NearlinkDeviceRow` | 02 §3 · 01 NL-03 | 对齐 |
| NLKIT-DSC-04 | 随机地址列 | ScanResult.address | NL-03 | `rowSubtitle` | 02 §3 | 对齐 PRD §6.2 |
| NLKIT-DSC-05 | RSSI 列 | ScanResult.rssi | NL-03 | `rssiBar` | 02 §3 | 对齐 |
| NLKIT-DSC-06 | Local Name | 广播解析 | NL-03 · NL-06 | `rowTitle` | 02 §4 · 01 NL-06 | 对齐 |
| NLKIT-DSC-07 | 发现次数 | 样例可简单累计 | NL-03 | `discoveryCountChip` | 02 §3 | **YoWire PRD** 稳定性指标 |
| NLKIT-DSC-08～11 | ScanRecord RAW / Service Data / Mfg | 样例详情区 | NL-06 | `AdvDetailSheet` · `btnRawScanRecord` | 02 §4 · 01 NL-06 | YoWire 详情页 |
| NLKIT-DSC-F01 | 样例名称 filter 弱 | 简单 Search | NL-04 | `filterNameField` | 02 §5 · 01 NL-04 | **YoWire 扩展** Filter 预设 |
| NLKIT-DSC-F02～03 | 无地址/组合 Filter | — | NL-04 专家 | `NearlinkFilterSheet` | 02 §5 · 04 | PRD §6.3 OR/AND |
| NLKIT-DSC-14 | 连接互斥 stopScan | 样例 connect 前 stop | NL-05 | `ConnectionStageBar` 前置 | 02 §6 · 01 NL-05 | 对齐 doc 20 NL-05 |

### 3.1 gitcode Scan 页典型步骤名对照

| 样例步骤名（nearlink-kit sample 常见） | NLKIT ID | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| `initNearLink` / Kit 初始化 | NLKIT-APP-02 | E-02 | `CapabilityCheckService` | 01 §2 | 样例隐式；YoWire 显式 Banner |
| `startScanButton` click | NLKIT-DSC-01 | NL-02 | `btnScanToggle` | 02 §3 | 1:1 |
| `onDeviceFound` list update | NLKIT-DSC-03 | NL-03 | `NearlinkDeviceList` | 02 §3 | 1:1 |
| `stopScanButton` / connect 前 stop | NLKIT-DSC-02 | NL-05 | stopScan 链 | 02 §6 | 1:1 |
| `deviceItem` click → 详情 | — | NL-05 | `NearlinkDeviceRow` | 02 §4 | YoWire 设备详情 L1 |
| `scanRecordHex` 展示 | NLKIT-DSC-08 | NL-06 | `rawScanRecordHex` | 02 §4 | 对齐 |

---

## 4. SSAP Client NLKIT-SSAP-C → 02 SSAP NL-A1～A9

### 4.1 连接生命周期

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-SSAP-C-01 | createClient(address) | 样例 Connect 入口 | NL-A1 | `SsapConnectionStage` step1 | [02 §6](../04-星闪模块/02-SSAP-Client逐步交互流程.md) | **增值** 阶段条 |
| NLKIT-SSAP-C-02 | client.connect() | 样例 Connecting… | NL-A2 | `stepIndicator_connecting` | 02 §6 | 对齐 |
| NLKIT-SSAP-C-03 | connectionStateChange | 状态回调 Log | NL-A2 | `ConnectionStateChip` | 02 §6 | 对齐 |
| NLKIT-SSAP-C-04 | requestMtuSize(n) | 样例 MTU 按钮/自动 | NL-A3 | `btnRequestMtu` · `[22,512]` | 02 §7 · 01 NL-A3 | 默认 256 PRD |
| NLKIT-SSAP-C-05 | getServices() | 服务列表渲染 | NL-A4 | `SsapServiceTree` | 02 §8 · 01 NL-A4 | 对齐 |
| NLKIT-SSAP-C-06 | Ready 树可操作 | 样例 UI enable | NL-A5 | `SsapTreePane` | 02 §8 · 01 NL-A5 | 对齐 |
| NLKIT-SSAP-C-07 | 单 Client 实例 | 样例一 address 一 client | NL-A5 | `SsapClientManager` | 02 §6 | N-NL-14 单连接 |
| NLKIT-SSAP-C-08 | disconnect | 样例 Disconnect | NL-A9 | `btnDisconnect` | 02 §10 | 对齐 |
| NLKIT-SSAP-C-09 | close 释放 | 样例 Close | NL-A9 | `btnCloseClient` | 02 §10 | 保留 Log 可重连 |

### 4.2 Property 读写订阅

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-SSAP-C-R01 | readProperty(handle) | 样例 Read 按钮 · 值 Text | NL-A6 | `btnPropertyRead` · `ReadResultSheet` | 02 §9 | 对齐 nRF Read 语义 |
| NLKIT-SSAP-C-W01 | writeProperty(handle, value) | 样例 Write 输入 | NL-A7 | `WritePropertySheet` | 02 §9 · 01 NL-A7 | **增值** 高风险二次确认 |
| NLKIT-SSAP-C-N01 | setPropertyNotification(true) | 样例 Subscribe Switch | NL-A8 | `btnPropertyNotify` | 02 §9 · 01 NL-A8 | 对齐 |
| NLKIT-SSAP-C-N02 | propertyChange 回调 | 样例 Log 区 | NL-A8 | `SsapLogPane` | 02 §11 · 01 | 对齐 BLE Log pane |
| NLKIT-SSAP-C-M01 | mtuChange 展示 | 样例 MTU Label | NL-A3 | `chipMtu` | 02 §7 · 01 NL-MTU-01 | 对齐 |
| NLKIT-SSAP-C-M02 | 超 MTU 写拒绝 | 平台错误码 | NL-A7 | `WriteMtuErrorBanner` | 02 §9 | NL-MTU-05 |

### 4.3 gitcode SsapClientPage 步骤名对照

| 样例步骤名 | Kit API | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| `createClient` | ssap.createClient | NL-A1 | `SsapClientFactory` | 02 §6 | 1:1 |
| `connectDevice` | client.connect | NL-A2 | `btnConnectConfirm` | 02 §6 | 1:1 |
| `requestMtu` | requestMtuSize | NL-A3 | `MtuRequestDialog` | 02 §7 | YoWire 阶段条内嵌 |
| `getServices` / 树渲染 | getServices | NL-A4～5 | `SsapServiceTree` | 02 §8 | 1:1 |
| `readCharacteristic` 等价 Property | readProperty | NL-A6 | `btnPropertyRead` | 02 §9 | SSAP 称 Property |
| `writeCharacteristic` | writeProperty | NL-A7 | `WritePropertySheet` | 02 §9 | +确认 Dialog |
| `subscribeNotify` | setPropertyNotification | NL-A8 | `btnPropertyNotify` | 02 §9 | 1:1 |
| `disconnect` | disconnect/close | NL-A9 | `btnDisconnect` | 02 §10 | 1:1 |

---

## 5. dataTransfer NLKIT-DT → 03 NL-B1～B8

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-DT-01 | createPort(uuid) | 样例 Port UUID 输入 | NL-B1 | `fieldPortUuid` | [03 §4](../04-星闪模块/03-dataTransfer逐步交互流程.md) | 对齐 |
| NLKIT-DT-02 | createPort 成功 | 按钮态 portReady | NL-B2 | `chipPortReady` | 03 §4 | 对齐 nearlink/03 |
| NLKIT-DT-03 | connect(device) | 样例 Connect | NL-B3 | `btnDtConnect` | 03 §5 | 对齐 PRD §8.1 |
| NLKIT-DT-04 | writeData(ArrayBuffer) | 样例 Send 按钮 | NL-B5 | `sendInput` · `btnSend` | 03 §6 · 01 NL-B5 | 对齐 SimpleBT 终端 |
| NLKIT-DT-05 | dataReceived 回调 | 样例 Log TextView | NL-B6 | `DataTerminal` | 03 §7 · 01 NL-B6 | 对齐 |
| NLKIT-DT-06 | disconnect | 样例 Disconnect | NL-B8 | `btnDtDisconnect` | 03 §8 | 对齐 |
| NLKIT-DT-07 | destroyPort | 样例 Destroy | NL-B8 | `btnDestroyPort` | 03 §8 | 对齐 |
| NLKIT-DT-08 | Port MTU | 样例部分展示 | NL-B2 | `chipPortMtu` | 03 §4 | N-NL-12 |
| NLKIT-DT-09 | 错误 1009700023 拥塞 | 样例 catch | NL-B7 | `CongestionBackoffBanner` | 03 §8 · 01 NL-B7 | **YoWire 退避 UX** |
| NLKIT-DT-10 | 换行 None/CR/LF/CRLF | 样例常 plain | NL-B5 | `newlinePicker` | 03 §6 | **增值** E-SBT-005 |
| NLKIT-DT-11 | HEX toggle | bytes 编解码 | NL-B5 | `chipHexMode` | 03 §6 | 对齐 UART |
| NLKIT-DT-12 | 收发统计 | 样例基础 | NL-B6 | `txRxStatsStrip` | 03 §7 | PRD §8.3 |

### 5.1 gitcode DataTransferPage 步骤名对照

| 样例步骤名 | Kit API | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| `inputPortUuid` | — | NL-B1 | `fieldPortUuid` | 03 §4 | 收藏/最近 ⚙ |
| `createPort` | createPort | NL-B2 | `btnCreatePort` | 03 §4 | 1:1 |
| `connectToDevice` | connect | NL-B3 | `btnDtConnect` | 03 §5 | +加密状态条 NL-C* |
| `sendData` | writeData | NL-B5 | `btnSend` | 03 §6 | +命令面板快捷 |
| `onDataReceived` | dataReceived | NL-B6 | `DataTerminal` | 03 §7 | SessionLog |
| `disconnectPort` | disconnect | NL-B8 | `btnDtDisconnect` | 03 §8 | 1:1 |
| `destroyPort` | destroyPort | NL-B8 | `btnDestroyPort` | 03 §8 | 1:1 |

---

## 6. 加密与配对 NLKIT-ENC → 01 NL-C + 03

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-ENC-01 | dataTransfer 不保证加密 | 样例 README 声明 | NL-C2 | `EncryptionRiskBanner` | 01 §9 NL-C · 03 §5 | **YoWire 强制提示** |
| NLKIT-ENC-02 | 加密状态未知 | 样例少展示 | NL-C1 | `chipEncryptionState` | 01 NL-C1 · 03 顶栏 | 禁止标「已加密」 |
| PRD §9 | startPairing / getAcbState | 样例 Codelab | NL-C4 | `PairingGuideSheet` | 01 NL-C4 | YoWire 引导链 |
| PRD §9 | 未加密禁止发送策略 | 样例无 | NL-C3 | `blockSendWhenUnencrypted` | 04 设置·连接 | **YoWire-only** |
| NL-C5 | 状态变化写 Log | — | NL-C5 | `SsapLogPane` / SessionLog | 01 · 04 | 对齐 N-NL-07 |

---

## 7. SSAP Server / Advertising（P3 预留）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NLKIT-SSAP-S-01 | createServer() | SsapServerPage | — | A 栏说明 | 04 · 01 NL-DG-08 | v1 隐藏 |
| NLKIT-SSAP-S-02～05 | addService · onRead/Write · notify | 样例 Server | — | P3 NL-SRV-* | 04 | 架构预留 |
| NLKIT-ADV-01～04 | startAdvertising / 模板 | AdvertisingPage | — | NL-DG-09 | 04 | v1 隐藏 |

---

## 8. 星闪 ⚙ 设置 · SessionLog（样例无）

| 样例能力 | 样例 UI | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| 无统一设置页 | 各页分散参数 | SET-1 | `btnModuleSettings` | [04](../04-星闪模块/04-星闪模块设置流程.md) | **YoWire 模块自治** |
| 无会话导出 | — | LOG-* | ⚙·会话与日志 | 04 · [06](../06-统一后端/01-会话日志导出逐步交互流程.md) | TXT/CSV/JSON |
| 无命令面板 | — | CMD-* | ⚙·命令与面板 | 04 · [06](../06-统一后端/02-命令面板与周期发送逐步交互流程.md) | SSAP Write + DT 发送 |
| 收藏设备 | 样例无 | NL-08 | ⚙·收藏 | 04 · 01 PRD §10 | 别名+广播特征 |

---

## 9. 840vp 宽屏对照

| 样例 | 样例 UI | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| 每页全屏 | 样例多 Activity/页 | W-NL | A Nav · B 扫描 · C SSAP/DT | 02 §12 · doc 18 | **GAP-840** |
| SSAP Log 区 | 样例底部 Text | NL-A8 | C 下半 `SsapLogPane` | 02 §11 | 同 BLE GATT 40% |
| dataTransfer | 样例单页 | NL-B4 | C `DataTerminal` | 03 §9 | B 列表 C 终端 |

---

## 10. NL-01～NL-B8 逐步索引（doc 20 → 本对照）

| doc20 步号 | 含义 | NLKIT 对照 | YoWire流程文档 | 章节 |
| --- | --- | --- | --- | --- |
| NL-01 | 进入 Tab Banner | NLKIT-DEG | 01 | §2 |
| NL-02 | 开始扫描 | NLKIT-DSC-01 | 02 · 01 | §3 |
| NL-03 | 扫描列表字段 | NLKIT-DSC-03～07 | 02 · 01 | §3 |
| NL-04 | 筛选 | NLKIT-DSC-F* | 02 · 01 | §3 |
| NL-05 | stopScan→详情 | NLKIT-DSC-02/14 | 02 · 01 | §3 |
| NL-06 | 广播详情 | NLKIT-DSC-08～11 | 02 · 01 | §3 |
| NL-A1～A9 | SSAP Client | NLKIT-SSAP-C-* | 02 | §4 |
| NL-B1～B8 | dataTransfer | NLKIT-DT-* | 03 | §5 |
| NL-C1～C5 | 加密配对 | NLKIT-ENC-* | 01 · 03 | §6 |

---

## 11. 与蓝牙模块差分（验收用）

| 项 | nRF BLE GATT | NearLink SSAP | 本对照节 |
| --- | --- | --- | --- |
| 扫描 stop 再连 | YoWire P0 | NL-05 同左 | §3 |
| 树节点 | Char/Desc | Property | §4 |
| MTU 范围 | 23–517 | 22–512 默认 256 | §4.1 |
| 终端路径 | UART Profile | dataTransfer | §5 |
| 加密 UI | 配对可选 | **必须展示** | §6 |
| 竞品对照文档 | [01-nRF](01-nRF-Connect-逐步对照-YoWire.md) | 本文 | — |

---

## 12. 验收勾选

- [ ] Unsupported/Denied 不空白扫描（01）  
- [ ] stopScan 再连接（NLKIT-DSC-02/14）  
- [ ] SSAP 阶段条 A1～A5 + 树 R/W/N（02）  
- [ ] Write 高风险确认（NL-A7）  
- [ ] dataTransfer B1～B8 + 拥塞 B7（03）  
- [ ] 加密状态始终可见（NL-C）  
- [ ] ⚙ SessionLog / 命令（04 · 06）  
- [ ] ≥840vp B/C（doc 18）  

---

## 13. 证据索引

| 键 | URL / 路径 |
| --- | --- |
| gitcode 样例 | https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code |
| gitee Codelab | https://gitee.com/harmonyos_codelabs/nearlink-kit_-codelab |
| 竞品清单 | `09/07-HarmonyOS-NearLinkKit-全量功能清单.md` |
| inventory 20 | `.research/feature-inventory/20-星闪模块-功能清单与逐步流程-v2.md` |
| doc 18 | `.research/feature-inventory/18-HarmonyOS-840vp-星闪模块三分栏线框-v2.md` |
| 架构 | `.research/feature-inventory/04-星闪与宽屏HarmonyOS-…` |

---

## 14. Codelab 与 gitcode 页面对照

| gitcode / Codelab 页面 | 典型文件名 | NLKIT 前缀 | YoWire 导航 | YoWire流程文档 |
| --- | --- | --- | --- | --- |
| Entry | Index.ets / MainPage | NLKIT-DEG | 星闪 Tab | 01 |
| Scan | ScanPage.ets | NLKIT-DSC | 扫描 L0 | 02 §3 · 01 NL-02 |
| SSAP Client | SsapClientPage.ets | NLKIT-SSAP-C | 设备详情→SSAP | 02 |
| SSAP Server | SsapServerPage.ets | NLKIT-SSAP-S | P3 隐藏 | 04 |
| DataTransfer | DataTransferPage.ets | NLKIT-DT | 设备详情→DT | 03 |
| Advertising | AdvPage.ets | NLKIT-ADV | P3 隐藏 | 04 |

---

## 15. NL-A6～A8 逐步细表（SSAP Property 操作）

| doc20 步 | 竞品样例动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NL-A6-1 | 点 Property 行 | 树节点 | NL-A6 | `SsapPropertyRow` | 02 §9 | 对齐 GATT char 行 |
| NL-A6-2 | 点 Read | 样例 Read 按钮 | NL-A6 | `btnPropertyRead` | 02 §9 | readProperty |
| NL-A6-3 | Sheet 展示 text/hex | Alert/Sheet | NL-A6 | `ReadResultSheet` | 02 §9 | 对齐 |
| NL-A7-1 | 点 Write | 输入框 | NL-A7 | `WritePropertySheet` | 02 §9 | writeProperty |
| NL-A7-2 | 高风险 UUID 二次确认 | 样例无 | NL-A7 | `WriteConfirmDialog` | 02 §9 · PRD §7.4 | **YoWire 增值** |
| NL-A7-3 | 超 MTU 拒绝 | 平台错误 | NL-A7 | `WriteMtuErrorBanner` | 02 §9 | NL-MTU-05 |
| NL-A8-1 | Toggle Notify | Switch | NL-A8 | `btnPropertyNotify` | 02 §9 | setPropertyNotification |
| NL-A8-2 | propertyChange Log | 文本区 | NL-A8 | `SsapLogPane` | 02 §11 | 对齐 nRF Log |

---

## 16. NL-B4～B7 终端细表（dataTransfer）

| doc20 步 | 竞品样例动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NL-B4-1 | 连接后终端布局 | Log+输入 | NL-B4 | `DtTerminalPage` | 03 §6 | E-SBT-005 同构 |
| NL-B4-2 | Clear 仅 UI | 样例 Clear | NL-B4 | `menuClear` | 03 §6 | 不清 SessionLog |
| NL-B5-1 | 文本发送 | Send 按钮 | NL-B5 | `btnSend` | 03 §6 | writeData |
| NL-B5-2 | HEX 模式 | toggle | NL-B5 | `chipHexMode` | 03 §6 | NL-DT-11 |
| NL-B5-3 | 换行 CR/LF | 样例少 | NL-B5 | `newlinePicker` | 03 §6 | NL-DT-10 |
| NL-B6-1 | 接收 append | dataReceived | NL-B6 | `DataTerminal` | 03 §7 | 对齐 |
| NL-B6-2 | 收发统计 | 样例基础 | NL-B6 | `txRxStatsStrip` | 03 §7 | NL-DT-12 |
| NL-B7-1 | 1009700023 拥塞 | catch 错误 | NL-B7 | `CongestionBackoffBanner` | 03 §8 | 退避 UX |
| NL-B7-2 | 暂停发送 | 样例阻塞 | NL-B7 | `btnSend` disabled | 03 §8 | YoWire 显式 |

---

## 17. 收藏与最近会话（YoWire PRD §10）

| 能力 | Kit 样例 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| 收藏别名 | 无 | NL-08 | `btnFavoriteStar` | 02 · 04 | 广播特征非单地址 |
| 最近会话 | 无 | L0 卡片 | `RecentSessionCard` | 01 · 04 | deep link |
| 默认 Port UUID | 样例手输 | NL-B1 | `pickerRecentPortUuid` | 03 · 04 | ⚙ 默认 |
| 默认模式 SSAP/DT | 分页独立 | 设备详情 | `modePickerSsapDt` | 02/03 · 04 | YoWire 合并 IA |

---

## 18. 与 nRF / SimpleBT 交叉引用

| 星闪能力 | 参照竞品对照 | 参照节 |
| --- | --- | --- |
| stopScan 再连 | nRF S-04 GAP-STOP | [01-nRF §2](01-nRF-Connect-逐步对照-YoWire.md) |
| SSAP 树 R/W/N | nRF CLIENT | [01-nRF §5](01-nRF-Connect-逐步对照-YoWire.md) |
| dataTransfer 终端 | SimpleBT SPP-21～29 | [02-SimpleBT §2.5](02-SimpleBT-SimpleBLE-逐步对照-YoWire.md) |
| SessionLog | nRF GAP-LOGFMT | [01-nRF §10](01-nRF-Connect-逐步对照-YoWire.md) |
| 840vp | nRF GAP-840 | [07-840vp](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md) |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `08-竞品逐步流程对照/` |
| 版本 | 深研草稿 v0.1 |
