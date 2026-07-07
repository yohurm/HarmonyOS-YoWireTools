# 09 · 竞品 APP 功能清单索引

> **状态**：深研草稿，未定稿  
> **定位**：上游竞品 / 平台参考 App 的 **穷尽级功能 ID**（NRF-* / SBT-* / SBLE-* / WFA-* / PS-* / ANT-* / NLKIT-*）  
> **与模块正文关系**：本目录 **复述竞品**；`02-蓝牙模块/`、`03-WiFi模块/`、`04-星闪模块/` 为 **YoWire 产品化 ID**（BT-* / WF-* / N-NL-*）  
> **深研源**：`.research/feature-inventory/` v2 · **证据 URL**：[`07-联网调研证据/`](../07-联网调研证据/01-竞品版本基线与公开证据索引.md)（E-*）

---

## 1. 索引总表（7 篇 · 已完成）

| # | App / 参考 | 文件 | YoWire 模块 | 行数 | 功能 ID 前缀 | YoWire 功能清单路径 | E-* 证据簇 |
| --- | --- | --- | --- | ---: | --- | --- | --- |
| 01 | **nRF Connect** (Android) | [01-nRF-Connect-Android-全量功能清单.md](01-nRF-Connect-Android-全量功能清单.md) | 蓝牙 · BLE-GATT | 544 | NRF-* / S-* / CM-* | [02-蓝牙模块/01](../02-蓝牙模块/01-BLE-GATT全量功能清单.md) · [04 实验室](../02-蓝牙模块/04-BLE实验室与高级功能清单.md) | E-nRF-001～010 |
| 02 | **SimpleBluetoothTerminal** | [02-SimpleBluetoothTerminal-经典SPP-全量功能清单.md](02-SimpleBluetoothTerminal-经典SPP-全量功能清单.md) | 蓝牙 · 经典 SPP | 365 | SBT-* / SPP-* | [02-蓝牙模块/02](../02-蓝牙模块/02-经典SPP功能清单.md) | E-SBT-001～005 |
| 03 | **SimpleBluetoothLeTerminal** | [03-SimpleBluetoothLeTerminal-BLE-UART-全量功能清单.md](03-SimpleBluetoothLeTerminal-BLE-UART-全量功能清单.md) | 蓝牙 · BLE-UART | 385 | SBLE-* / B-UART-* | [02-蓝牙模块/03](../02-蓝牙模块/03-BLE-UART功能清单.md) | E-SBLE-001～005 |
| 04 | **WiFiAnalyzer** (VREM) | [04-WiFiAnalyzer-Android-全量功能清单.md](04-WiFiAnalyzer-Android-全量功能清单.md) | WiFi · 环境分析 | 549 | WFA-* | [03-WiFi模块/01](../03-WiFi模块/01-WiFiAnalyzer环境分析功能清单.md) | E-WFA-001～007 |
| 05 | **PacketSender** | [05-PacketSender-全量功能清单.md](05-PacketSender-全量功能清单.md) | WiFi · 网络协议调试 | 555 | PS-* | [03-WiFi模块/02](../03-WiFi模块/02-网络协议调试功能清单.md) | E-PS-001～005 · E-PS-GAP-01/02 |
| 06 | **AndroidNetworkTools** | [06-AndroidNetworkTools-LAN诊断-全量功能清单.md](06-AndroidNetworkTools-LAN诊断-全量功能清单.md) | WiFi · LAN/诊断 | 474 | ANT-* | [03-WiFi模块/03](../03-WiFi模块/03-LAN与网络诊断功能清单.md) | E-ANT-*（见 §2） |
| 07 | **HarmonyOS NearLink Kit** | [07-HarmonyOS-NearLinkKit-全量功能清单.md](07-HarmonyOS-NearLinkKit-全量功能清单.md) | 星闪 · **平台参考** | 403 | NLKIT-* | [04-星闪模块/01](../04-星闪模块/01-星闪全量功能清单.md) | E-NL-001～005 |

**合计**：约 **3,275 行** 竞品/平台穷尽清单（2026-07-03）。

---

## 2. 与 `07-联网调研证据` E-* 的链接

| E-* 簇 | 用途 | 本目录文件 |
| --- | --- | --- |
| **E-nRF-*** | nRF 文档/README/Play/Macros/Automated tests | 01 |
| **E-SBT-*** | SimpleBT 源码 TerminalFragment / SerialService | 02 |
| **E-SBLE-*** | SimpleBLE 四 Profile / GATT 链 | 03 |
| **E-WFA-*** | WiFiAnalyzer README/手册/Play/Export | 04 |
| **E-PS-*** | PacketSender 官网/GitHub/man | 05 |
| **E-PS-GAP-01/02** | **无 WS / 无 MQTT** → YoWire WF-NET-06/08 | 05 §GAP |
| **E-ANT-*** | [stealthcopter/AndroidNetworkTools](https://github.com/stealthcopter/AndroidNetworkTools) | 06（Ping/子网/端口）；DNS/TRT/Whois 标 YoWire PRD 扩展 |
| **E-NL-*** | NearLink 样例 / 开发者文档 | 07 |
| **E-HMS-001～003** | 宽屏 ABC / IA 修订 | 各文 YoWire 映射节 |

---

## 3. 推荐阅读顺序

### 3.1 首次进入

1. [01-功能清单/README.md](../README.md)  
2. [07-联网调研证据/01](../07-联网调研证据/01-竞品版本基线与公开证据索引.md)  
3. [08-PRD全量需求ID主索引.md](../08-PRD全量需求ID主索引.md)  
4. **本目录竞品清单 → 对应模块正文**

### 3.2 按 YoWire 模块（竞品 → 产品化）

| 模块 | 阅读顺序 |
| --- | --- |
| **蓝牙 GATT** | **01 nRF** → `02-蓝牙模块/01` → `02-用户交互流程/02-蓝牙模块/01` |
| **蓝牙 SPP** | **02 SimpleBT** → `02-蓝牙模块/02` → `02-…/02` |
| **蓝牙 BLE-UART** | **03 SimpleBLE** → `02-蓝牙模块/03` → `02-…/03` |
| **蓝牙 实验室** | **01 nRF** §Macros/DFU/Advertiser → `02-蓝牙模块/04` → `02-…/05` |
| **WiFi 环境** | **04 WiFiAnalyzer** → `03-WiFi模块/01` → `02-…/03-WiFi/01` |
| **WiFi 网络** | **05 PacketSender**（必读 GAP WS/MQTT）→ `03-WiFi模块/02` |
| **WiFi LAN** | **06 AndroidNetworkTools** → `03-WiFi模块/03` |
| **星闪** | **07 NearLink Kit** → `04-星闪模块/01` → `02-…/04-星闪/*` |

### 3.3 与 `.research/feature-inventory` 对照

| 本目录 | feature-inventory v2 |
| --- | --- |
| 01 | `01-nRF-Connect-BLE-全量功能清单-v2.md` + `08` `09` `11` `13` |
| 02 | `19-…-v2.md` §1 |
| 03 | `19-…-v2.md` §2 |
| 04 | `05-WiFiAnalyzer-全量功能清单-v2.md` + `14` |
| 05 | `06-PacketSender-全量功能清单-v2.md` + `15` |
| 06 | `12-WiFi与网络调试-逐步流程-v2.md` §2 |
| 07 | `20-星闪模块-功能清单与逐步流程-v2.md` |

---

## 4. 竞品 vs 平台参考 vs YoWire 独有

| 类型 | 文件 | 说明 |
| --- | --- | --- |
| **第三方竞品** | 01～06 | 开源或文档级穷尽；nRF **无 APK 源码** |
| **平台参考** | **07** | NearLink Kit 官方样例 = 星闪能力上限 |
| **YoWire 独有** | 见各文 GAP 节 | Mfg Data Mask · WS/MQTT · 840vp ABC · 模块 ⚙ SessionLog/Command · Inquiry/重连 |

---

## 5. 公开仓库速查

| App | URL |
| --- | --- |
| nRF Connect 文档 | https://github.com/NordicSemiconductor/Android-nRF-Connect |
| SimpleBT | https://github.com/kai-morich/SimpleBluetoothTerminal |
| SimpleBLE | https://github.com/kai-morich/SimpleBluetoothLeTerminal |
| WiFiAnalyzer | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer |
| PacketSender | https://github.com/dannagle/PacketSender |
| AndroidNetworkTools | https://github.com/stealthcopter/AndroidNetworkTools |
| NearLink 样例 | https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v2 |
| 最后更新 | 2026-07-03 |
