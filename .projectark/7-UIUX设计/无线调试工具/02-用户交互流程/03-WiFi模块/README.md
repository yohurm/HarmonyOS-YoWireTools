# 03-WiFi模块 — 用户交互流程索引

> **状态**：深研草稿（未定稿）  
> **版本**：v0.2 · 2026-07-03  
> **主索引**：[`../09-交互流程全量索引与PRD映射.md`](../09-交互流程全量索引与PRD映射.md)  
> **功能清单**：[`01-功能清单/03-WiFi模块/`](../../01-功能清单/03-WiFi模块/README.md)

---

## 1. 文档列表

| 文件 | 范围 | 行数 | 840vp § |
| --- | --- | ---: | --- |
| [01-环境分析逐步交互流程.md](./01-环境分析逐步交互流程.md) | AP 列表、四 Sub-Tab、Filter、Export 14 列 | 334 | §16 |
| [02-网络调试逐步交互流程.md](./02-网络调试逐步交互流程.md) | TCP/UDP/SSL/HTTP、Resend、Traffic | 333 | §17 |
| [03-LAN与诊断逐步交互流程.md](./03-LAN与诊断逐步交互流程.md) | 子网/端口扫描、Ping/DNS/Trace/Whois | 339 | §11 |
| [04-WiFi模块设置与会话命令流程.md](./04-WiFi模块设置与会话命令流程.md) | WiFi ⚙ 五分组、Panel Grid、会话导出 | 323 | §8 |
| [05-HTTP-WebSocket-MQTT逐步交互流程.md](./05-HTTP-WebSocket-MQTT逐步交互流程.md) | HTTP · WS · MQTT（YoWire P0 扩展） | 359 | §8 |
| [06-SmartResponse与PanelGrid逐步交互流程.md](./06-SmartResponse与PanelGrid逐步交互流程.md) | W-SMR 5 规则 · W-PNL DSL · Stop Resending | 337 | §11 |

**840vp 横切**：[`../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md`](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md) §3.2 T-3~4（环境 AP 列表 + 网络 Traffic）。

---

## 2. 竞品逐步对照（08）

| YoWire 流程 | 08-竞品对照 | 09-竞品功能清单 |
| --- | --- | --- |
| 01 环境分析 | [08/04-WiFiAnalyzer](../08-竞品逐步流程对照/README.md#04-wifianalyzer) 📋 | [04-WiFiAnalyzer](../../01-功能清单/09-竞品APP功能清单/04-WiFiAnalyzer-Android-全量功能清单.md) |
| 02 网络调试 | [08/05-PacketSender](../08-竞品逐步流程对照/README.md#05-packetsender) 📋 | [05-PacketSender](../../01-功能清单/09-竞品APP功能清单/05-PacketSender-全量功能清单.md) |
| 03 LAN/诊断 | [08/06-AndroidNetworkTools](../08-竞品逐步流程对照/README.md#06-androidnetworktools) 📋 | [06-AndroidNetworkTools](../../01-功能清单/09-竞品APP功能清单/06-AndroidNetworkTools-LAN诊断-全量功能清单.md) |
| 04 设置 | [08/05 §Settings](../08-竞品逐步流程对照/README.md#05-packetsender) 📋 | 09/04·05 |
| 05 HTTP/WS/MQTT | [08/05 §GAP](../08-竞品逐步流程对照/README.md#05-packetsender) 📋 | 09/05（无 WS/MQTT） |
| 06 Smart/Panel | [08/05 §Panel](../08-竞品逐步流程对照/README.md#05-packetsender) 📋 | 09/05 |

---

## 3. 上游依据

| 类型 | 路径 |
| --- | --- |
| 深研清单 | `.research/feature-inventory/03` `12` `14` `15` |
| UI 设计 | [`03-UI设计/03-WiFi模块/`](../../03-UI设计/03-WiFi模块/) |
| 840 线框 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |
| 全局 IA | [`03-UI设计/00-全局框架/01-信息架构与导航设计.md`](../../03-UI设计/00-全局框架/01-信息架构与导航设计.md) |
| 统一后端 | [`06-统一后端/README.md`](../06-统一后端/README.md) |

---

## 4. 流程格式约定

每步表格四列：| 步 | 用户动作 | 系统响应 | 控件名 |

- **步**：`步1` 或 `F-*`（环境）· `P-*`（网络）· `L-*`（LAN）  
- **Filter 三按钮**：Apply / Close / Reset — 环境分析与 LAN **必须**一致  

---

## 5. 模块共性

1. WiFi Tab Segmented：**环境分析 | 网络调试**  
2. 日志/命令 **仅** WiFi ⚙；无全局 Tab  
3. 840vp：B 栏列表常驻 + C 工作区；标题栏 ≤3  
4. 运行时 Export（14 列）vs ⚙ 持久会话归档  
5. PacketSender 无 WS/MQTT → YoWire [`05-HTTP-WebSocket-MQTT`](./05-HTTP-WebSocket-MQTT逐步交互流程.md)（WF-NET-06/08）

---

## 6. 与竞品差异（摘要）

| YoWire 流程 | 竞品 | 差异 |
| --- | --- | --- |
| 01 环境分析 | WiFiAnalyzer 9 屏 | AP 列表提升 B 栏；Drawer→工具栏 |
| 02 网络调试 | PacketSender | + WS/MQTT；Panel 仅 ⚙ |
| 03 LAN/诊断 | PS Subnet + ANT | + DNS/Trace/Whois 完整链 |
| 04 设置 | settings.xml + ps_settings.ini | 五组合并 IA |

详情见 [08-竞品逐步流程对照](../08-竞品逐步流程对照/README.md)（待写正文）。

---

## 7. 阅读顺序

1. [01-环境分析](./01-环境分析逐步交互流程.md)  
2. [02-网络调试](./02-网络调试逐步交互流程.md) → [05-HTTP-WS-MQTT](./05-HTTP-WebSocket-MQTT逐步交互流程.md)  
3. [03-LAN与诊断](./03-LAN与诊断逐步交互流程.md)  
4. [06-SmartResponse与PanelGrid](./06-SmartResponse与PanelGrid逐步交互流程.md)  
5. [04-WiFi设置](./04-WiFi模块设置与会话命令流程.md)  
6. 840vp：[07/03](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md)

---

## 8. 下游

- Navigation `/wifi/*`  
- [`03-UI设计/08-验收与状态/02-模块验收清单.md`](../../03-UI设计/08-验收与状态/02-模块验收清单.md)  
- P0 清单：[`09-索引`](../09-交互流程全量索引与PRD映射.md) §4.3

---

*WiFi 模块用户交互流程子目录索引 · v0.2*
