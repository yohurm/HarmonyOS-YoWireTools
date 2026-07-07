# WiFi 模块功能清单 — 索引

> **状态**：深研草稿  
> **目录**：`.projectark/7-UIUX设计/无线调试工具/01-功能清单/03-WiFi模块/`  
> **上游深研**：`.research/feature-inventory/05`、`06`、`12`、`14`、`15`、`16`、`22` §4–§5  
> **PRD**：`.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md`  
> **IA 原则**：模块自治；日志/命令在 **WiFi ⚙ 设置**；无全局日志中心（`00-UI架构修正`）

---

## 1. 子文档索引

| 文档 | 范围 | 功能 ID 前缀 | 竞品 | 行数 | 深扩章节 |
| --- | --- | --- | --- | --- | --- |
| [01-WiFiAnalyzer环境分析功能清单.md](./01-WiFiAnalyzer环境分析功能清单.md) | 9 屏 · 13 Settings · Filter 4 维 · Export 14 列 · F-01～F-16 | `W-ENV-*` `W-AP-*` `W-FLT-*` `W-SCR-*` `W-SET-*` | WiFiAnalyzer | **~410 行** | §12 W-SET-01~13 · §13 W-SCR-01~09 · §14 Export · §15 Play |
| [02-网络协议调试功能清单.md](./02-网络协议调试功能清单.md) | 8 协议 · Settings 4 Tab · Smart Response · Panel · WS/MQTT | `WF-NET-*` `W-PRO-*` `W-SMR-*` `W-PNL-*` | PacketSender + PRD | ~280 行 | — |
| [03-LAN与网络诊断功能清单.md](./03-LAN与网络诊断功能清单.md) | Ping/DNS/TraceRoute/Whois · 子网 · 端口扫描 | `W-LAN-*` `W-DIA-*` `W-NET-01/02` | PRD + AndroidNetworkTools | **~430 行** | §15 ANT 对照 · §16 W-LAN · §17 W-DIA · §18 UI |

**交叉链接**：

- 环境分析 ↔ LAN/诊断：[`01`](01-WiFiAnalyzer环境分析功能清单.md) §10 增量 · [`03`](03-LAN与网络诊断功能清单.md) §4 W-NET-01 Connection 扩展
- 网络协议 ↔ LAN：[`02`](02-网络协议调试功能清单.md) Segmented 与 [`03`](03-LAN与网络诊断功能清单.md) §2 IA 树
- 深研源稿：`.research/feature-inventory/05` · `12` · `14` · `16` · `22` §4–§5

---

## 2. 模块 IA 树

```text
WiFi Tab（模块自治）
├── L0 工作台
│   ├── 当前网络摘要
│   ├── 环境分析入口
│   ├── 网络调试入口
│   └── 最近目标 / 最近会话 deep link
├── 环境分析（01）
│   ├── B：AP 列表 + Filter + 暂停扫描
│   └── C：Rating / 信道图 / 时间图 / Connection
├── 网络调试（02 + 03）
│   ├── Segmented：Socket | HTTP | WS | MQTT | LAN | 诊断
│   ├── B：会话/包/主机列表
│   └── C：Terminal + Traffic / 图表 / Timeline
└── ⚙ WiFi 设置（五分组）
    ├── 会话与日志
    ├── 命令与面板
    ├── 环境分析（13 项映射）
    ├── LAN
    └── 网络调试（四 Tab 映射）
```

---

## 3. PRD 差距分级速查（doc 22 §4–§5）

| 分级 | WiFi 环境 | 网络/LAN |
| --- | --- | --- |
| **P0** | AP 列表、Filter、信道图、时间图、Connection、暂停扫描 | TCP/UDP C/S、HTTP、**WS**、**MQTT**、Traffic、Ping/DNS/TraceRoute/Whois |
| **P1** | 信道评分、13 Settings、三格式导出、收藏 AP、840vp | 宏、Panel、LAN/端口扫描、Smart Response（可选） |
| **P2** | Channel Available、Vendors、mDNS | WS Server、TLS、SSDP |
| **P3** | — | Cloud/WOL/CLI |

---

## 4. 证据 ID 对照

| 前缀 | 含义 | 深研文档 |
| --- | --- | --- |
| **F-xx** | WiFiAnalyzer Fragment 流程 | `14-WiFiAnalyzer-源码级逐步流程-v2.md` |
| **P-xx** | PacketSender 包/协议流程 | `15-PacketSender-源码级逐步流程-v2.md` |
| **WF-ENV-xx** | PRD 环境分析需求 | `22` §4 |
| **WF-NET-xx** | PRD 网络需求 | `22` §5 |
| **W-LAN-*** / **W-DIA-*** | 本目录 LAN/诊断枚举 | `03-LAN与网络诊断功能清单.md` |

---

## 5. UI 设计下游

| 功能清单 | 页面设计 |
| --- | --- |
| 01 环境分析 | `03-UI设计/03-WiFi模块/01-WiFi环境分析页面设计.md` |
| 02 网络协议 | `03-UI设计/03-WiFi模块/02-网络协议调试页面设计.md` |
| 03 LAN/诊断 | `03-UI设计/03-WiFi模块/03-LAN与网络诊断页面设计.md` |
| 模块设置 | `03-UI设计/03-WiFi模块/04-WiFi模块设置页设计.md` |
| 840vp | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |

---

## 6. 阅读顺序

1. 本 README → 模块 IA  
2. **01** — 环境分析全量 ID + F-01～F-16  
3. **02** — Socket/HTTP/WS/MQTT + Panel/Smart Response  
4. **03** — LAN + 诊断  
5. `22` §4–§5 — PRD Gap 与 P0 验收  
6. `04-WiFi模块PRD.md` — 产品边界确认

---

## 7. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 更新子文档行数、深扩章节索引与 01↔03 交叉链接 |
