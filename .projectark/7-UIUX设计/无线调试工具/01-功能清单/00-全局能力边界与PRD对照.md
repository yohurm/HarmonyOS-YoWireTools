# 00-全局能力边界与 PRD 对照

> **状态：深研草稿，未定稿。**  
> **用途**：YoWire 无线调试工具跨模块能力边界、统一后端模型与信息架构原则的权威对照表；实现/UI 设计不得与此冲突。  
> **证据链**：`.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` · `22-YoWire-PRD与竞品能力差距矩阵-v2.md` §1–§3 · `21-nRF-Connect-UNKNOWN项交叉验证-v2.md` · PRD `03-蓝牙模块PRD.md` · PRD `02-统一日志与命令面板PRD.md`（数据面）

---

## 1. 文档定位与阅读顺序

| 顺序 | 文档 | 读者 |
| --- | --- | --- |
| 1 | 本文（00） | 全员：IA 边界、后端统一、跨模块对照 |
| 2 | `02-蓝牙模块/README.md` | 蓝牙模块索引 |
| 3 | `02-蓝牙模块/01`–`04` | 蓝牙子路径全量功能 ID |
| 4 | `.research/feature-inventory/22-…` §4–§7 | WiFi / 星闪 / 跨模块（后续迁入 01-功能清单） |

**设计原则一句话**：**后端统一 SessionLog / Command；UI 模块自治；禁止全局「日志中心」「命令中心」Tab。**

---

## 2. 信息架构原则（修订后，相对 PRD 01）

### 2.1 一级 Tab 结构

| Tab | 内容 | **明确不含** |
| --- | --- | --- |
| **工作台** | 能力摘要、跨模块**最近会话卡片**（deep link 至模块内页） | 日志中心、命令编辑台 |
| **蓝牙** | 经典 SPP / BLE GATT / BLE UART 三入口自治工作台 | 全局命令面板 |
| **WiFi** | 环境分析 + 网络调试自治工作台 | 全局命令面板 |
| **星闪** | SSAP Client + dataTransfer 自治工作台 | 全局命令面板 |
| **更多** | 专家/轻量、权限与后台、存储上限、安全脱敏、关于 | 日志中心、命令中心 |

**证据**：`.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` §3–§4 · `22-…` §9.1–§9.3

### 2.2 PRD 01 冲突修订对照

| PRD 01 原描述 | 修订结论 | 依据 |
| --- | --- | --- |
| 顶层「日志中心」页 | **取消独立页面** | 用户评审 2026-07-03；`00` §1 |
| 顶层「命令面板」全局入口 | **迁入各模块 ⚙ → 命令与面板** | `00` §5–§7 |
| 首页「快捷命令面板」全局编辑 | **最近会话/收藏卡片 → deep link** | `22` §9.1 |
| 「更多」Tab 含日志/命令 | **更多 Tab 仅全局设置** | `00` §3 |

### 2.3 模块顶栏规范（手机）

```text
[← 返回]  模块/页面标题          [扫描/暂停] [⚙ 设置]
```

| 按钮 | 行为 |
| --- | --- |
| ⚙ 设置 | push **模块设置 NavDestination**（全屏，非 Sheet） |
| 上下文 | 扫描、Filter、导出等按页面替换 |

**禁止**：在「更多」Tab 或第四 Inspector 栏放置日志中心 / 命令中心。

**宽屏（≥840vp）**：HarmonyOS 官方 A/B/C 三分栏；B 栏 ≤3 主按钮、C 栏 ≤6 工具栏项；禁止 V5 原型第四 Inspector。  
**证据**：`.research/feature-inventory/07-HarmonyOS宽屏规范-深读摘要-v2.md` · `10/16/17/18-HarmonyOS-840vp-*`

---

## 3. 统一后端：SessionLog 与 Command

### 3.1 分层架构

```text
┌─────────────────────────────────────────┐
│ UI 层：模块自治                          │
│  蓝牙 / WiFi / 星闪 各自工作台 + 各自 ⚙    │
│  会话日志、命令面板、导出在模块内可达        │
└─────────────────────────────────────────┘
                    ↕
┌─────────────────────────────────────────┐
│ 领域层：统一 SessionLog / Command 模型     │
│ （PRD 02 数据面仍有效；入口不在全局 Tab）   │
└─────────────────────────────────────────┘
```

### 3.2 SessionLog 模型（八种会话类型）

| 会话类型 | 模块 | 主 UI 入口 | 完整记录/导出 |
| --- | --- | --- | --- |
| `spp_terminal` | 蓝牙 | C 终端流 + 折叠 Log | **蓝牙 ⚙·会话与日志** |
| `ble_gatt` | 蓝牙 | C Log pane / Tab（40%） | **蓝牙 ⚙·会话与日志** |
| `ble_uart` | 蓝牙 | C 终端流（同 SPP） | **蓝牙 ⚙·会话与日志** |
| `wifi_scan` | WiFi | C 图表区（无独立日志页） | **WiFi ⚙·会话与日志** |
| `network_traffic` | WiFi | C Traffic 表 | **WiFi ⚙·会话与日志** |
| `network_diagnostic` | WiFi | C 诊断输出 | **WiFi ⚙·会话与日志** |
| `nearlink_ssap` | 星闪 | C Log pane | **星闪 ⚙·会话与日志** |
| `nearlink_datatransfer` | 星闪 | C 终端 + 加密条 | **星闪 ⚙·会话与日志** |

**导出格式（PRD 02）**：TXT / CSV / JSON；敏感字段脱敏策略统一。  
**nRF 对照**：nRF 单文件 SAVE + 可选 nRF Logger 独立 App；YoWire 强于竞品多格式与模块内统一模型。  
**证据**：`22-…` §7 LOG-01/02 · `21` §2.2 LOG-04（Copy/Save/Share/Clear 四动作对齐 nRF Log pane）

### 3.3 Command 模型与 UI 归属

| 模块 | ⚙ 子页 | 命令类型 | 运行时快捷 |
| --- | --- | --- | --- |
| 蓝牙 | **命令与面板** | SPP 发送、BLE Write/Read/Subscribe、Macro 步骤 | C 工具栏「从收藏选择」Sheet |
| WiFi | **命令与面板** | TCP/UDP/HTTP/MQTT 包、诊断一键 | C「从收藏选择」 |
| 星闪 | **命令与面板** | SSAP Write、dataTransfer | C「从收藏选择」 |

**Panel Grid（3 列）**：仅在 **模块 ⚙·命令与面板** 编辑；终端页不做全局 Panel Grid。  
**周期发送**：各终端 C 工具栏 + 模块 ⚙ 默认间隔/风险提示（PRD 02 §7）。  
**证据**：`00` §7 · `22` §7 CMD-01/02/03

---

## 4. 跨模块能力边界总表

### 4.1 蓝牙模块（三路径并列）

| 子路径 | 竞品基准 | YoWire 首期边界 | 功能清单 |
| --- | --- | --- | --- |
| **BLE GATT** | nRF Connect 全量 | P0 扫描+GATT 闭环；P1 专家深度；P3 DFU/Macro 全引擎 | `02-蓝牙模块/01` |
| **经典 SPP** | SimpleBluetoothTerminal | P0 已配对+Inquiry+UUID；P1 重连/命令 | `02-蓝牙模块/02` |
| **BLE UART** | SimpleBluetoothLeTerminal | P0 Nordic Profile；P1 四 Profile 扩展 | `02-蓝牙模块/03` |
| **BLE 实验室** | nRF Advertiser/GATT Server/DFU | P2–P3 架构预留 | `02-蓝牙模块/04` |

**IA 铁律**：蓝牙首页 **三入口并列**（经典 SPP / BLE GATT / BLE UART）；UART 失败引导 GATT，不在 UART 页复刻 GATT 树。

### 4.2 蓝牙 vs WiFi vs 星闪 — 能力域对照

| 能力域 | 蓝牙 | WiFi | 星闪 | 全局 |
| --- | --- | --- | --- | --- |
| 扫描/发现 | BLE 扫描、经典 Inquiry | AP 周期扫描 | 星闪扫描 | — |
| 连接会话 | GATT/SPP/UART | Socket/HTTP/WS/MQTT | SSAP/dataTransfer | — |
| 终端/Traffic | SPP/UART 字节流 | TCP/UDP Traffic 表 | dataTransfer 终端 | — |
| 服务树 | GATT/SSAP 树 | — | SSAP 树 | — |
| 图表 | Notify/RSSI 曲线（P2） | 信道图/时间图 | Property 曲线（P2） | — |
| 命令收藏 | SPP/BLE/Macro | Socket/HTTP/MQTT | SSAP/DT | 模型统一、存储分模块 |
| 会话导出 | ⚙·会话 | ⚙·会话 | ⚙·会话 | 格式统一 |
| 实验室/专家 | Advertiser/GATT Server/DFU | Smart Response/TLS | SSAP Server | 专家/轻量全局开关 |
| 后台 | SerialService 模式 | 持久 TCP | 平台待验证 | **更多·权限与后台** |

### 4.3 Gap 分级定义（全项目统一）

| 级别 | 含义 | 交付阶段 |
| --- | --- | --- |
| **P0** | 阻塞调试闭环 / v1 必达 | 首期 |
| **P1** | v1 专家模式或 v1.1 必补 | 首期专家 / 快速跟进 |
| **P2** | 完整规划 / 架构预留 | 不阻塞 v1 主路径 |
| **P3** | 竞品生态级 / 明确不纳入 v1 承诺 | 后续增强 |

**证据**：`22-…` §8

---

## 5. 蓝牙模块 PRD 需求 ID ↔ 功能清单映射

| PRD ID | 摘要 | 功能清单落点 | Gap |
| --- | --- | --- | --- |
| BT-GATT-01~19 | BLE GATT 全链路 | `02-蓝牙模块/01` | 见 `22` §1 |
| BT-SPP-01~14 | 经典 SPP | `02-蓝牙模块/02` | 见 `22` §2 |
| BT-UART-01~13 | BLE UART | `02-蓝牙模块/03` | 见 `22` §3 |
| — | Advertiser/GATT Server/DFU/Macros | `02-蓝牙模块/04` | P2–P3 |
| IA-01~04 | 跨模块 IA | 本文 §2–§3 | P0 IA 冲突已修订 |
| LOG-01/02 | SessionLog | 本文 §3.2 | P0 后端 |
| CMD-01~03 | Command | 本文 §3.3 | P0–P1 |

**PRD 原文**：`.projectark/2-需求文档/无线调试工具/PRD/03-蓝牙模块PRD.md`

---

## 6. v1 必达能力摘要（P0 跨模块）

| 模块 | 必达能力 |
| --- | --- |
| **BLE GATT** | 扫描+Mask 过滤、GATT R/W/N/I、MTU、连接 Log pane、会话持久化导出、840 基本三分栏 |
| **SPP** | 已配对+附近 Inquiry、UUID Connect Sheet、终端 HEX/换行、后台通知、SessionLog |
| **BLE UART** | 独立入口、Nordic 自动匹配、MTU 展示、失败转 GATT、终端闭环 |
| **跨模块 IA** | 统一 SessionLog/Command **后端**；**取消全局日志/命令 Tab**；模块 ⚙ 可达导出 |

**完整 P1/P2/P3 分级**：`22-YoWire-PRD与竞品能力差距矩阵-v2.md` §8.1–§8.4

---

## 7. 模块 ⚙ 设置分组对照（蓝牙为例）

| 分组 | 项 | nRF/Simple 映射 |
| --- | --- | --- |
| **会话与日志** | 会话列表、导出、清历史、落盘开关 | nRF Log pane SAVE；Simple 无持久化 |
| **命令与面板** | SPP/BLE Write/Macro 步骤、Panel Grid | nRF Macros FAB；PS Panel Generator |
| **连接** | SPP UUID、自动重连、MTU、PHY、auto discover | SET-CONN-* · CM-* |
| **扫描** | 模式、Filter 预设、RSSI 阈值 | SET-SCAN-* · SET-FIL-* |
| **收藏与设备** | 别名、持久化地址（ACL 允许时） | S-03 Only Favorites |
| **经典蓝牙** | Inquiry 时长、默认 UUID | YoWire PRD 增值 |
| **BLE 高级** | Reliable Write、Parse UUIDs、实验室门控 | nRF 专家项 |

**WiFi / 星闪 分组**：`00-UI架构修正` §5.2–§5.3

---

## 8. 证据索引

| 键 | 路径 / URL |
| --- | --- |
| UI-ARCH | `.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` |
| GAP-MATRIX | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` |
| UNKNOWN-X | `.research/feature-inventory/21-nRF-Connect-UNKNOWN项交叉验证-v2.md` |
| PRD-BT | `.projectark/2-需求文档/无线调试工具/PRD/03-蓝牙模块PRD.md` |
| nRF-01 | `.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` |
| nRF-08 | `.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` |
| nRF-09 | `.research/feature-inventory/09-nRF-Connect-Settings与ReleaseNotes-v2.md` |
| SPP-UART-19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` |
| nRF-DOC | `.research/reference-apps/nRF-Connect-docs/` |
| Nordic GitHub | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation |

---

## 6. 联网证据摘要（2026-07-03 检索）

> 完整 E-* 注册表：`07-联网调研证据/01-竞品版本基线与公开证据索引.md`  
> 本节选录与 **跨模块边界** 直接相关的公开 URL，供各功能清单 Evidence 列引用。

### 6.1 竞品版本基线

| 竞品 | 版本/日期线索 | 能力边界摘要 | 证据 URL | YoWire 差距要点 |
| --- | --- | --- | --- | --- |
| nRF Connect Android | Play 2024–2025 持续更新；文档 main 分支 | 无源码；Scanner/Connection/Macros/Automated tests 文档 | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/README.md | YoWire TXT/CSV/JSON 强于单文件 SAVE（LOG-02） |
| nRF Macros | v4.4.0+ | 28-tag XML；App 内 FAB | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Macros/README.md | v1 单命令 P1；全 Macro 引擎 P3（BT-GATT-15） |
| nRF Automated Tests | XML `<test-suite>` | PC+ADB；scan/connect/DFU | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Automated%20tests/README.md | P3 架构预留；非用户面板 |
| WiFiAnalyzer | **Play Updated Jan 10, 2026** | AP/Filter/Rating/Export/Graph | https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer | YoWire SessionLog 持久化（WF-ENV-15） |
| WiFiAnalyzer 手册 | 站点维护 | Filter 四维；Channel Rating；Export | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html | WF-ENV-04/08/11 |
| PacketSender | v8.x 2025–2026 | TCP/UDP/SSL/HTTP/Panel/Resend/Smart | https://packetsender.com/ · https://github.com/dannagle/PacketSender | **无 WS/MQTT**（WF-NET-06/08 YoWire P0） |
| SimpleBluetoothTerminal | master 持续 | SPP UUID；hex/newline；SerialService | https://github.com/kai-morich/SimpleBluetoothTerminal | 无 Inquiry/SessionLog（BT-SPP-02/06） |
| NearLink Kit 样例 | HarmonyOS 5.0.1+ / API 13+ | ssap.createClient/Server；ACCESS_NEARLINK | https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code | 无 OSS 竞品；UX 参照 nRF+SimpleBT |

### 6.2 IA 修订证据链

| 决策 | 用户/文档证据 | URL 或路径 | 影响 ID |
| --- | --- | --- | --- |
| 取消全局日志中心 Tab | 用户评审 2026-07-03 | `.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` | IA-01 · W-HOME-15 |
| 命令面板迁入模块 ⚙ | 同上 + `22` §9 | E-HMS-002 | CMD-02 · PNL-* |
| 工作台 deep link 非全局编辑 | `22` §9.1 | — | IA-02 · W-HOME-07/08 |
| 后端 SessionLog 仍有效 | PRD 02 数据面 | `.projectark/.../PRD/02-统一日志与命令面板PRD.md` | LOG-01/02 |

### 6.3 跨模块能力 vs 竞品证据对照

| YoWire 统一能力 | nRF | WiFiAnalyzer | PacketSender | SimpleBT | 证据 URL |
| --- | --- | --- | --- | --- | --- |
| 八种 SessionLog | Connection Log 分散 | Export 快照无会话 | Traffic rolling | 无持久化 | `06-统一后端/01` SL-TYPE-* |
| TXT/CSV/JSON 导出 | 单文件 | `\|` 管道 CSV | Save Log | — | E-WFA-004 · E-PS-001 |
| Panel Grid | Macro UI（不同范式） | — | Generate Panel | — | E-PS-001 · E-nRF-006 |
| 周期 Resend | Macro delay | — | resendEdit 队列 | — | E-PS-003 |
| 模块 ⚙ 导出 | — | — | — | — | E-HMS-002 |
| Smart Response ×5 | — | — | Smart Tab | — | E-PS-003 · WF-NET-12 |

### 6.4 PRD 扩展项（无竞品 URL）

| ID | 能力 | 证据类型 | 说明 |
| --- | --- | --- | --- |
| WF-NET-06 | WebSocket Client | HarmonyOS V-WF-015 | PacketSender 无；见 `03-WiFi/02` §16 |
| WF-NET-08 | MQTT | V-WF-026 方案待确认 | PacketSender 无 |
| BT-SPP-02 | 经典 Inquiry | PRD 03 §5.2 | SimpleBT 仅已配对 E-SBT-001 |
| BT-GATT-02 | Mfg Data Mask | PRD 03 §7.2 | nRF Filter 弱于 PRD E-nRF-001 |
| NL-09 | dataTransfer 加密条 | PRD 05 §9 | 无 OSS E-NL-* |

---

## 7. 文档完成度自检清单

> **用途**：设计/开发启动前勾选；与 `08-PRD全量需求ID主索引.md` 交叉。  
> **Evidence 列**：未完成项须补 URL 或标 `V-*` 待验证。

### 7.1 01-功能清单目录完成度

| 路径 | 状态 | 行数目标 | Evidence 列 | 交叉索引 |
| --- | --- | --- | --- | --- |
| `README.md` | ✅ 含 06/07/08 | — | 深研链接 | §2 文档树 |
| `00-全局能力边界与PRD对照.md` | ✅ 含 §6–§7 | 200+ | §6 URL 表 | 本文 |
| `01-首页工作台/01` | ✅ | 150+ | §2 证据 | W-HOME-* |
| `02-蓝牙模块/01`–`04` | ✅ | 各 200+ | 各文 §证据 | BT-* |
| `03-WiFi模块/01`–`03` | ✅ 02 已扩展 | 各 200+ | E-WFA/E-PS | WF-* |
| `04-星闪模块/01` | ✅ 已扩展 API 映射 | 400+ | E-NL-* | NL-* |
| `05-全局与权限/01` | ✅ | 300+ | PRD 06 | G-* |
| `06-统一后端/01` | ✅ 新建 | ~350 | 全表 E-* | SL/CMD/PNL |
| `07-联网调研证据/01` | ✅ 新建 | ~400 | E-* 主表 | 全文 |
| `08-PRD全量需求ID主索引.md` | ✅ 新建 | ~500 | 竞品 ref 列 | 150+ ID |

### 7.2 PRD 00–07 回填状态

| PRD | 索引章节 | 功能清单覆盖 | 流程覆盖 | 缺口 |
| --- | --- | --- | --- | --- |
| 00 总览 | `08` §2 DEC-* | `00-全局` | `00-全局导航` | — |
| 01 IA | `08` §3 IA/W-HOME | `01-首页` `00-全局` §2 | `01-首页/01` | PRD 01 原文待变更记录回写 |
| 02 日志命令 | `08` §4 LOG/CMD | `06-统一后端/01` | 各模块/04 | — |
| 03 蓝牙 | `08` §5 BT-* | `02-蓝牙/*` | `02-蓝牙/*` | BT-GATT-15 P3 实验室 |
| 04 WiFi | `08` §6 WF-* | `03-WiFi/*` | `03-WiFi/*` | WF-NET-08 方案 V-WF-026 |
| 05 星闪 | `08` §7 NL-* | `04-星闪/01` | `04-星闪/*` | V-NL-011 加密真机 |
| 06 权限 | `08` §8 G-* | `05-全局与权限/01` | `05-全局与权限/01` | — |
| 07 验证 | `08` §9 V-* | 分散各模块 | — | 真机回填 PRD 07 §8 |

### 7.3 P0 必达自检（v1 最小闭环）

| 检查项 | 功能 ID | 文档 | Evidence | ☐ |
| --- | --- | --- | --- | --- |
| 无全局日志/命令 Tab | IA-01, W-HOME-15 | `00` §2 · `01-首页` | E-HMS-002 | ☐ |
| 八种 SessionLog 后端 | LOG-01, SL-TYPE-* | `06-统一后端/01` | PRD 02 | ☐ |
| 三格式模块导出 | LOG-02, SL-EXP-* | `06-统一后端/01` | E-WFA-004 | ☐ |
| BLE GATT 闭环 | BT-GATT-01~04,06,10 | `02-蓝牙/01` | E-nRF-003 | ☐ |
| SPP Inquiry+UUID+SessionLog | BT-SPP-02,03,06 | `02-蓝牙/02` | E-SBT-002 | ☐ |
| WiFi 环境 AP+Filter+图 | WF-ENV-01~04,06,07 | `03-WiFi/01` | E-WFA-002 | ☐ |
| TCP/UDP/HTTP+Traffic | WF-NET-01~04,11 | `03-WiFi/02` | E-PS-001 | ☐ |
| **WebSocket Client** | WF-NET-06 | `03-WiFi/02` §16 | E-PS-GAP-01 · V-WF-015 | ☐ |
| **MQTT** | WF-NET-08 | `03-WiFi/02` §17 | E-PS-GAP-02 · V-WF-026 | ☐ |
| 星闪 Banner+SSAP+DT+加密 | NL-01~09, NL-05~09 | `04-星闪/01` | E-NL-001 | ☐ |
| 周期发送最小间隔 | CMD-03, RSN-01 | `06-统一后端/01` | E-PS-003 | ☐ |

### 7.4 深研 ↔ 功能清单同步规则

| 触发 | 动作 | 负责人 |
| --- | --- | --- |
| `feature-inventory/22` 更新 Gap | 同步 `08-PRD全量需求ID主索引` P0–P3 列 | 产品 |
| 新增 E-* URL | 写入 `07-联网调研证据/01` 并回写各模块 Evidence 列 | 文档 |
| PRD 01 IA 正式修订 | 更新 `00-全局` §2.2 与 PRD 01 变更记录 | 产品 |
| 真机完成 V-* | PRD 07 §8 回填 + 本表 §7.2 缺口列 | 平台 |

### 7.5 下游文档依赖

| 消费者 | 依赖本文章节 | 说明 |
| --- | --- | --- |
| `03-UI设计/00-全局框架/03` | §2–§3 | 模块自治与会话命令模型 |
| `02-用户交互流程/00` | §2.2 · §3 | 无日志中心路由 |
| `08-PRD全量需求ID主索引` | §5 · §6 | ID ↔ 路径 |
| 架构设计 SessionLog | §3.2 | 八种 sessionType schema |
| 验收 `03-UI/08-验收` | §7.3 | P0 勾选 |

---

## 8. 证据索引（扩展）

| 键 | 路径 / URL |
| --- | --- |
| E-INDEX | `07-联网调研证据/01-竞品版本基线与公开证据索引.md` |
| SL-CMD | `06-统一后端/01-SessionLog与Command能力清单.md` |
| PRD-INDEX | `08-PRD全量需求ID主索引.md` |
| UI-ARCH | `.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` |
| GAP-MATRIX | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` |
| UNKNOWN-X | `.research/feature-inventory/21-nRF-Connect-UNKNOWN项交叉验证-v2.md` |
| PRD-BT | `.projectark/2-需求文档/无线调试工具/PRD/03-蓝牙模块PRD.md` |
| nRF-01 | `.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` |
| nRF-08 | `.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` |
| nRF-09 | `.research/feature-inventory/09-nRF-Connect-Settings与ReleaseNotes-v2.md` |
| SPP-UART-19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` |
| nRF-DOC | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation |
| Nordic GitHub | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation |
| WiFiA Manual | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html |
| PacketSender | https://github.com/dannagle/PacketSender |
| NearLink Sample | https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code |

---

## 9. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：跨模块边界、SessionLog/Command 后端、IA 无日志中心原则、PRD 对照 |
| 2026-07-03 | 增 §6 联网证据摘要、§7 文档完成度自检；证据索引扩展；目录 06/07/08 |
