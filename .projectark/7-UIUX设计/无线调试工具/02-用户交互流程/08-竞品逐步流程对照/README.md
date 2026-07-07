# 08 · 竞品逐步流程对照索引

> **状态**：规划中（索引已定稿，7 篇对照待写）  
> **定位**：竞品 App **逐步操作路径** → YoWire **02-用户交互流程** 逐步表 **行级映射**  
> **上游**：[`01-功能清单/09-竞品APP功能清单/`](../../01-功能清单/09-竞品APP功能清单/README.md)（功能 ID）  
> **下游**：[`09-交互流程全量索引与PRD映射.md`](../09-交互流程全量索引与PRD映射.md) · 各模块 README

---

## 1. 对照文规划（7 篇）

| # | 文件（规划） | 竞品 App | 09-功能清单 | YoWire 02-流程 | 步骤 ID 映射 |
| --- | --- | --- | --- | --- | --- |
| 01 | `01-nRF-Connect-逐步流程对照.md` | nRF Connect | [09/01](../../01-功能清单/09-竞品APP功能清单/01-nRF-Connect-Android-全量功能清单.md) | [02-蓝牙/01](../02-蓝牙模块/01-BLE-GATT逐步交互流程.md) · [05](../02-蓝牙模块/05-BLE实验室Macros与DFU逐步交互流程.md) · [04](../02-蓝牙模块/04-模块设置与会话命令流程.md) | NRF-* / S-* → 步* · ADV-* · MAC-* |
| 02 | `02-SimpleBT-SPP-逐步流程对照.md` | SimpleBluetoothTerminal | [09/02](../../01-功能清单/09-竞品APP功能清单/02-SimpleBluetoothTerminal-经典SPP-全量功能清单.md) | [02-蓝牙/02](../02-蓝牙模块/02-经典SPP逐步交互流程.md) | SBT-* / SPP-* → INQ-* · T-* |
| 03 | `03-SimpleBLE-UART-逐步流程对照.md` | SimpleBluetoothLeTerminal | [09/03](../../01-功能清单/09-竞品APP功能清单/03-SimpleBluetoothLeTerminal-BLE-UART-全量功能清单.md) | [02-蓝牙/03](../02-蓝牙模块/03-BLE-UART逐步交互流程.md) | SBLE-* → SCAN-* · PROF-* |
| 04 | `04-WiFiAnalyzer-逐步流程对照.md` | WiFiAnalyzer (VREM) | [09/04](../../01-功能清单/09-竞品APP功能清单/04-WiFiAnalyzer-Android-全量功能清单.md) | [03-WiFi/01](../03-WiFi模块/01-环境分析逐步交互流程.md) | WFA-* → F-* · W-ENV-* |
| 05 | `05-PacketSender-逐步流程对照.md` | PacketSender | [09/05](../../01-功能清单/09-竞品APP功能清单/05-PacketSender-全量功能清单.md) | [03-WiFi/02](../03-WiFi模块/02-网络调试逐步交互流程.md) · [05](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) · [06](../03-WiFi模块/06-SmartResponse与PanelGrid逐步交互流程.md) | PS-* → P-* · W-SMR-* · W-PNL-* |
| 06 | `06-AndroidNetworkTools-逐步流程对照.md` | AndroidNetworkTools | [09/06](../../01-功能清单/09-竞品APP功能清单/06-AndroidNetworkTools-LAN诊断-全量功能清单.md) | [03-WiFi/03](../03-WiFi模块/03-LAN与诊断逐步交互流程.md) | ANT-* → L-* · DIA-* |
| 07 | `07-NearLinkKit-逐步流程对照.md` | HarmonyOS NearLink Kit | [09/07](../../01-功能清单/09-竞品APP功能清单/07-HarmonyOS-NearLinkKit-全量功能清单.md) | [04-星闪/01~04](../04-星闪模块/README.md) | NLKIT-* → NL-* · NL-A* · NL-B* |

---

## 2. 对照表格式约定

每篇对照文含：

1. **竞品逐步表**（来源：09 功能清单 + 公开文档/源码）  
2. **YoWire 逐步表**（链接 02 流程 § 与步号）  
3. **映射矩阵**：竞品步 | YoWire 步 | 差异/GAP | PRD ID  
4. **840vp 差异**（若竞品无宽屏，标 YoWire 扩展 IA-04）  
5. **YoWire 独有步**（Mfg Mask · WS/MQTT · 模块 ⚙ · Inquiry 等）

---

## 3. 锚点速查（README 内链）

### 01 nRF Connect {#01-nrf-connect}

- Scanner → Connection：`02-蓝牙/01` §2–§9  
- Macros/DFU/Advertiser：`02-蓝牙/05`  
- Settings/Export：`02-蓝牙/04` · `06-统一后端/01`

### 02 SimpleBluetoothTerminal {#02-simplebluetoothterminal}

- 已配对/Inquiry/终端：`02-蓝牙/02` §3–§8  
- SerialService 后台：`02-蓝牙/02` §11 · `05-全局/01` §4

### 03 SimpleBluetoothLeTerminal {#03-simplebluetoothleterminal}

- SCAN/Profile/终端：`02-蓝牙/03` §3–§8

### 04 WiFiAnalyzer {#04-wifianalyzer}

- 9 屏 → 4 Sub-Tab：`03-WiFi/01` §5–§12  
- Export/Settings：`03-WiFi/01` §13 · §18

### 05 PacketSender {#05-packetsender}

- TCP/UDP/HTTP：`03-WiFi/02` · `03-WiFi/05`  
- **GAP**：无 WS/MQTT → YoWire `03-WiFi/05` §5–§6（WF-NET-06/08）  
- Panel/Smart/Resend：`03-WiFi/06`

### 06 AndroidNetworkTools {#06-androidnetworktools}

- 子网/Ping/端口：`03-WiFi/03` §3–§5  
- DNS/Trace/Whois：YoWire PRD 扩展（竞品部分缺失）

### 07 HarmonyOS NearLink Kit {#07-harmonyos-nearlink-kit}

- 能力/扫描：`04-星闪/01`  
- SSAP/DT：`04-星闪/02` · `04-星闪/03`

---

## 4. 阅读顺序

1. [`09-竞品APP功能清单/README.md`](../../01-功能清单/09-竞品APP功能清单/README.md)  
2. **本目录** 对应竞品对照文（待写）  
3. YoWire [`02-用户交互流程`](../README.md) 模块逐步文  
4. [`09-交互流程全量索引`](../09-交互流程全量索引与PRD映射.md) §5 完成度矩阵

---

## 5. 完成度

| 文档 | 状态 |
| --- | --- |
| 08/README（本文件） | ✅ |
| 01～07 对照正文 | 📋 待写 |

---

*竞品逐步流程对照子目录 · 2026-07-03*
