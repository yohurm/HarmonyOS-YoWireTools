# 01 · 功能清单索引

> **状态**：深研草稿，未定稿  
> **定位**：YoWire 无线调试工具 **能力域功能 ID 与竞品对照** 的 UIUX 包入口  
> **权威深研源**：`.research/feature-inventory/`（v2 草稿）  
> **本目录**：从深研提炼、面向设计与验收的功能清单正文

---

## 1. 与 `.research/feature-inventory` 的关系

| 层级 | 路径 | 用途 |
| --- | --- | --- |
| **深研证据（源）** | `.research/feature-inventory/` | 竞品源码级清单、逐步流程、840vp 线框、差距矩阵 |
| **本目录（产品化）** | `01-功能清单/` | 按模块整理的功能 ID、分级、与 UI/流程文档交叉引用 |
| **UI 设计** | `03-UI设计/` | 页面规格、组件、状态 |
| **交互流程** | `02-用户交互流程/` | 逐步用户路径 |

**规则**：inventory v2 与本目录冲突时，先更新 inventory，再回写本目录。

---

## 2. 本目录文档树

```text
01-功能清单/
├── README.md
├── 00-全局能力边界与PRD对照.md          ✅ 跨模块 SessionLog/Command、IA 边界、§6–§7 证据
├── 08-PRD全量需求ID主索引.md            ✅ 150+ ID 主表（PRD 00–07）
├── 01-首页工作台/
│   └── 01-首页工作台功能清单.md          ✅ W-HOME-01～15
├── 02-蓝牙模块/                          ✅ 4 篇 + README
│   ├── 01-BLE-GATT全量功能清单.md
│   ├── 02-经典SPP功能清单.md
│   ├── 03-BLE-UART功能清单.md
│   └── 04-BLE实验室与高级功能清单.md
├── 03-WiFi模块/                          ✅ 3 篇 + README
│   ├── 01-WiFiAnalyzer环境分析功能清单.md
│   ├── 02-网络协议调试功能清单.md        ← §15–18 WS/MQTT/Smart/Panel 扩展
│   └── 03-LAN与网络诊断功能清单.md
├── 04-星闪模块/                          ✅ 1 篇 + README
│   └── 01-星闪全量功能清单.md            ← N-NL-01～14 · §16 NearLink Kit API
├── 05-全局与权限/
│   └── 01-全局设置与权限功能清单.md      ✅ 更多 Tab、六域权限、专家/轻量
├── 06-统一后端/                          ✅ 新建
│   └── 01-SessionLog与Command能力清单.md ← SL-* CMD-* PNL-* · PRD 02 全映射
├── 07-联网调研证据/                      ✅ 新建
│   └── 01-竞品版本基线与公开证据索引.md  ← E-* → URL → YoWire 路径
└── 09-竞品APP功能清单/                   ✅ 7 篇竞品/平台穷尽清单（~3275 行）
    ├── README.md
    ├── 01-nRF-Connect-Android-全量功能清单.md      ← NRF-* 544 行
    ├── 02-SimpleBluetoothTerminal-经典SPP-…md       ← SBT-* 365 行
    ├── 03-SimpleBluetoothLeTerminal-BLE-UART-…md   ← SBLE-* 385 行
    ├── 04-WiFiAnalyzer-Android-全量功能清单.md       ← WFA-* 549 行
    ├── 05-PacketSender-全量功能清单.md             ← PS-* 555 行 · GAP WS/MQTT
    ├── 06-AndroidNetworkTools-LAN诊断-…md          ← ANT-* 474 行
    └── 07-HarmonyOS-NearLinkKit-全量功能清单.md    ← NLKIT-* 403 行
```

---

## 3. 深研文档全索引

### 3.1 全局与 IA

| 文件 | 内容 |
| --- | --- |
| [`00-UI架构修正-模块自治与后端统一.md`](../../../.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md) | 模块 ⚙、无全局日志/命令中心 |
| [`07-HarmonyOS宽屏规范-深读摘要-v2.md`](../../../.research/feature-inventory/07-HarmonyOS宽屏规范-深读摘要-v2.md) | 600/840 断点、A/B/C、Sheet |
| [`22-YoWire-PRD与竞品能力差距矩阵-v2.md`](../../../.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md) | P0～P3、IA 冲突 |
| [`23-深研文档导航与阅读顺序-v2.md`](../../../.research/feature-inventory/23-深研文档导航与阅读顺序-v2.md) | 设计师 Phase 0～4 |
| [`24-原型docs回写大纲-v2.md`](../../../.research/feature-inventory/24-原型docs回写大纲-v2.md) | 原型回写计划 |

### 3.2 蓝牙模块

| 文件 | 设备 | 内容 |
| --- | --- | --- |
| [`01-nRF-Connect-BLE-全量功能清单-v2.md`](../../../.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md) | 手机 | BLE GATT 功能 ID |
| [`08-nRF-Connect-Scanner到Connection逐步流程-v2.md`](../../../.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md) | 手机 | Scanner→Connection |
| [`10-HarmonyOS-840vp-蓝牙模块三分栏线框-v2.md`](../../../.research/feature-inventory/10-HarmonyOS-840vp-蓝牙模块三分栏线框-v2.md) | 宽屏 | GATT A/B/C |
| [`17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md`](../../../.research/feature-inventory/17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md) | 宽屏 | SPP/UART |
| [`19-经典SPP与BLE-UART-源码级逐步流程-v2.md`](../../../.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md) | 手机 | SPP + UART 源码流 |
| [`11`](../../../.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md) · [`13`](../../../.research/feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md) · [`21`](../../../.research/feature-inventory/21-nRF-Connect-UNKNOWN项交叉验证-v2.md) | 参考 | Macros / DFU / UNKNOWN |

**v1 废弃**：`02-蓝牙模块-经典与UART-功能清单与流程.md` → 见 `19`+`17`

### 3.3 WiFi 模块

| 文件 | 设备 | 内容 |
| --- | --- | --- |
| [`05-WiFiAnalyzer-全量功能清单-v2.md`](../../../.research/feature-inventory/05-WiFiAnalyzer-全量功能清单-v2.md) | 手机 | 环境分析 F-ID |
| [`14-WiFiAnalyzer-源码级逐步流程-v2.md`](../../../.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md) | 手机 | F-01～F-16 |
| [`06-PacketSender-全量功能清单-v2.md`](../../../.research/feature-inventory/06-PacketSender-全量功能清单-v2.md) | 手机 | 网络调试功能 ID |
| [`15-PacketSender-源码级逐步流程-v2.md`](../../../.research/feature-inventory/15-PacketSender-源码级逐步流程-v2.md) | 手机 | P-01～P-16 |
| [`12-WiFi与网络调试-逐步流程-v2.md`](../../../.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md) | 手机 | 综合 IA |
| [`16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md`](../../../.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md) | 宽屏 | WiFi A/B/C |

**v1 废弃**：`03-WiFi模块-功能清单与逐步流程.md` → 见 `14`+`15`+`16`+`12`

### 3.4 星闪模块

| 文件 | 设备 | 内容 |
| --- | --- | --- |
| [`20-星闪模块-功能清单与逐步流程-v2.md`](../../../.research/feature-inventory/20-星闪模块-功能清单与逐步流程-v2.md) | 手机 | N-NL-01～14、NL-A/B 步骤 |
| [`18-HarmonyOS-840vp-星闪模块三分栏线框-v2.md`](../../../.research/feature-inventory/18-HarmonyOS-840vp-星闪模块三分栏线框-v2.md) | 宽屏 | SSAP/DT A/B/C |

**v1 废弃**：`04-星闪与宽屏HarmonyOS-功能清单与布局重设计.md` → 见 `20`+`18`+`07`

---

## 4. 模块功能 ID 速查

| 模块 | 本目录正文 | 主要 ID 前缀 |
| --- | --- | --- |
| 全局 | [00-全局能力边界与PRD对照.md](00-全局能力边界与PRD对照.md) | SessionLog / Command / IA |
| **PRD 索引** | [08-PRD全量需求ID主索引.md](08-PRD全量需求ID主索引.md) | BT-* / WF-* / NL-* / IA-* / V-* |
| **统一后端** | [06-统一后端/01-SessionLog与Command能力清单.md](06-统一后端/01-SessionLog与Command能力清单.md) | SL-* / CMD-* / PNL-* / RSN-* |
| **联网证据** | [07-联网调研证据/01-竞品版本基线与公开证据索引.md](07-联网调研证据/01-竞品版本基线与公开证据索引.md) | E-nRF-* / E-WFA-* / E-PS-* / E-NL-* |
| **竞品 APP 清单** | [09-竞品APP功能清单/](09-竞品APP功能清单/) | PS-* / SBT-* / NLKIT-* → 模块正文 |
| 首页 | [01-首页工作台/01-首页工作台功能清单.md](01-首页工作台/01-首页工作台功能清单.md) | W-HOME-* |
| 蓝牙 | [02-蓝牙模块/](02-蓝牙模块/) | S-* / CM-* / B-SPP-* / UART-* |
| WiFi | [03-WiFi模块/](03-WiFi模块/) | W-ENV-* / W-NET-* / W-LAN-* |
| 星闪 | [04-星闪模块/01-星闪全量功能清单.md](04-星闪模块/01-星闪全量功能清单.md) | N-NL-* |
| 权限 | [05-全局与权限/01-全局设置与权限功能清单.md](05-全局与权限/01-全局设置与权限功能清单.md) | G-* |

差距分级见 [`22`](../../../.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md)。

---

## 5. 推荐阅读顺序

1. [`../README.md`](../README.md) 四支柱总览  
2. [08-PRD全量需求ID主索引.md](08-PRD全量需求ID主索引.md) — 全 ID 检索入口  
3. [00-全局能力边界与PRD对照.md](00-全局能力边界与PRD对照.md) + [07-联网调研证据/01](07-联网调研证据/01-竞品版本基线与公开证据索引.md) + [09-竞品APP功能清单/README.md](09-竞品APP功能清单/README.md) + `feature-inventory/22`  
4. [06-统一后端/01-SessionLog与Command能力清单.md](06-统一后端/01-SessionLog与Command能力清单.md) — PRD 02 后端映射  
5. 按模块读本目录正文 → 对照 `02-用户交互流程/` 与 `03-UI设计/`  
6. 宽屏线框：`feature-inventory/10` `16` `17` `18`

---

## 6. 竞品源码路径

`.research/reference-apps/` — SimpleBT、SimpleBLE、WiFiAnalyzer、PacketSender、AndroidNetworkTools、nRF-Connect-docs

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v2 |
| 最后更新 | 2026-07-03 |
