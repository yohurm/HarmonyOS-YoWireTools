# 06 — 统一后端 · 用户交互流程索引

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **目录**：`02-用户交互流程/06-统一后端/`  
> **定位**：SessionLog 与 Command 能力的 **跨模块交互流程**；入口 **仅** 各模块 ⚙，**无** 全局 LOG/CMD Tab

---

## 1. 文档目的

本目录收录 YoWire **统一后端**（SessionLog + Command Panel）的用户逐步交互流程，与 UI 壳层 IA 修订一致：

- **SessionLog**：八种会话类型统一模型；筛选、预览、TXT/CSV/JSON 导出、清理  
- **Command**：分协议收藏、Panel Grid 编辑（专家）、运行时 Sheet 选择、周期发送与风险  

**铁律**（IA-01 P0）：工作台、更多 Tab **不得** 出现「日志中心」「命令中心」入口。

---

## 2. 流程文档索引

| # | 文档 | 范围 | 关键控件 |
| --- | --- | --- | --- |
| 01 | [01-会话日志导出逐步交互流程.md](01-会话日志导出逐步交互流程.md) | 三模块 ⚙·会话与日志：筛选 · 详情 · 导出 · Share Sheet · 清理 | `SessionLogGroup` / `ExportFlow` |
| 02 | [02-命令面板与周期发送逐步交互流程.md](02-命令面板与周期发送逐步交互流程.md) | 三模块 ⚙·命令与面板：CRUD · Grid · 运行时 Sheet · Resend 风险 | `CommandPanelGroup` / `PeriodicSendScheduler` |

---

## 3. 与功能清单对照

> 主索引：`01-功能清单/06-统一后端/01-SessionLog与Command能力清单.md`

| 功能 ID | 名称 | 流程文档 | 模块落点 |
| --- | --- | --- | --- |
| LOG-01 | 统一 SessionLog 八种会话 | 01 §1、§2 | 各模块 ⚙·会话与日志 |
| LOG-02 | 导出 TXT/CSV/JSON + 脱敏 | 01 §4–§6 | 导出 Flow；脱敏链 G-SEC-02 |
| CMD-01 | 命令收藏分协议 | 02 §3–§5 | 蓝牙/ WiFi/ 星闪 ⚙·命令 |
| CMD-02 | Panel Grid 编辑 | 02 §4 | 专家模式；轻量隐藏 G-EXP-05 |
| CMD-03 | 周期发送 + 最小间隔/风险 | 02 §6–§8 | C 工具栏 + 模块 ⚙ 默认 |

**跨模块引用**：

| 模块 | 设置流程中的 LOG/CMD 章节 |
| --- | --- |
| 蓝牙 | `02-蓝牙模块/04-模块设置与会话命令流程.md` |
| WiFi | `03-WiFi模块/04-WiFi模块设置与会话命令流程.md` |
| 星闪 | `04-星闪模块/04-星闪模块设置流程.md` §3–§4 |

---

## 4. 八种 SessionLog 类型速查

| 类型 ID | 模块 | 运行时快捷入口 | deep link（工作台） |
| --- | --- | --- | --- |
| `spp_terminal` | 蓝牙 | SPP ⋮ 会话记录 / Log 条 | `/bluetooth/spp-terminal?sessionId=` |
| `ble_gatt` | 蓝牙 | GATT Log SAVE | `/bluetooth/gatt-detail?sessionId=` |
| `ble_uart` | 蓝牙 | UART ⋮ 会话记录 | `/bluetooth/uart-terminal?sessionId=` |
| `wifi_scan` | WiFi | 环境 C Export | `/wifi/env?sessionId=` |
| `network_traffic` | WiFi | Traffic Save Log | `/wifi/net/traffic?sessionId=` |
| `network_diagnostic` | WiFi | LAN/诊断 Save | `/wifi/net/lan?` / `diag?` |
| `nearlink_ssap` | 星闪 | SSAP Log SAVE | `/nearlink/ssap-client?sessionId=` |
| `nearlink_datatransfer` | 星闪 | DT 会话记录 | `/nearlink/data-transfer?sessionId=` |

**禁止**：`/log/list`、`/log/detail` 作为任何卡片或 Tab 目标。

---

## 5. 入口矩阵（三模块通用）

| 入口 | 会话日志 01 | 命令面板 02 | 全局更多 Tab |
| --- | --- | --- | --- |
| 模块 ⚙ → 会话与日志 | ✓ 主入口 | — | ✗ |
| 模块 ⚙ → 命令与面板 | — | ✓ 主入口 | ✗ |
| C 栏 SAVE / 会话记录 | ✓ 快捷 | — | ✗ |
| C 栏「从收藏选择」 | — | ✓ 运行时 | ✗ |
| 工作台 Active/Recent | deep link 模块内页 | ✗ | ✗ |
| 工作台「更多会话」 | ✓ → 模块 ⚙ | ✗ | ✗ |
| 更多 Tab | ✗ | ✗ | 仅 G-STOR/G-SEC |

---

## 6. 呈现断点（设置子页）

| 宽度 | 会话/命令设置呈现 |
| --- | --- |
| <600vp | 全屏 NavDestination push |
| 600–839vp | C 栏 navigate 或全屏（模块定） |
| ≥840vp | C 栏 navigate；A/B 保留；← 返回不断 Session |

见 `07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md` §5 R-19。

---

## 7. 与全局设置联动

| 全局项 | 影响统一后端 |
| --- | --- |
| G-SEC-02 导出脱敏 | LOG-02 导出 Flow 默认 |
| G-STOR-01 存储上限 | 会话列表 StorageSummaryCard |
| G-MODE-02 专家/轻量 | CMD-02 Grid 显隐；Log 字段 |
| G-BG-02 后台写日志 | SessionLog 落盘 |
| G-BG-06 后台周期发送 | CMD-03 默认关 |
| G-SEC-03 危险操作确认 | 周期发送首次 Sheet |

流程：`05-全局与权限/01-全局设置逐步交互流程.md`

---

## 8. Resend 全局可见性

| 位置 | 文档 |
| --- | --- |
| C 工具栏周期发送 | 02 §6–§8 |
| 工作台 Active Chip + Stop | `01-首页工作台/01-首页工作台逐步交互流程.md` §5、§9 |
| 840vp 工作台 C RiskStrip | 同上 §9 |
| 模块 ⚙ 默认间隔 | 02 §7；各模块设置流程 |

---

## 9. 验收清单（统一后端 P0）

- [ ] 无全局 LOG/CMD Tab（LOG-01 入口仅模块 ⚙）
- [ ] 八种 SessionLog 类型均可导出 TXT/CSV/JSON（LOG-02）
- [ ] 导出脱敏跟随 G-SEC-02
- [ ] 三模块命令 CRUD + 运行时 Sheet（CMD-01）
- [ ] 专家 Panel Grid；轻量隐藏（CMD-02 / G-EXP-05）
- [ ] 周期发送最小间隔 + 风险 Dialog（CMD-03）
- [ ] 840vp 设置 navigate 返回不断 Session
- [ ] 与 `01-功能清单/06-统一后端/` ID 一一对应

---

## 10. 相关文档

| 文档 | 路径 |
| --- | --- |
| **功能清单（主索引）** | `../../01-功能清单/06-统一后端/01-SessionLog与Command能力清单.md` |
| 模块自治模型 | `../../03-UI设计/00-全局框架/03-模块自治与会话命令模型.md` |
| 全局导航 deep link | `../00-全局导航与会话流程.md` §7 |
| PRD 02 | `.projectark/` PRD `02-统一日志与命令面板PRD.md` |
| 架构修正 | `.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` |

---

## 11. 01-会话日志导出 — 章节索引

| 章节 | 内容 | 步 ID 示例 |
| --- | --- | --- |
| §1 总览 | 八种 SessionLog；无全局 Tab | — |
| §2 进入 | EN-1～EN-13 三模块入口 | `btnModuleSettings` |
| §3 筛选 | FL-1～FL-8 SessionFilterBar | `filterSessionType` |
| §4 详情 | DT-1～DT-6 LogViewer 预览 | `SessionDetailPage` |
| §5 导出 | EX-1～EX-12 TXT/CSV/JSON | `ExportFlow` |
| §6 清理 | CL-1～CL-6 批量/全部 | `btnCleanupAll` |
| §7 脱敏 | 链 G-SEC-02；专家警告 | `switchExportDesensitize` |
| §8 异常 | 存储满/导出失败 | `ExportErrorToast` |

---

## 12. 02-命令面板 — 章节索引

| 章节 | 内容 | 步 ID 示例 |
| --- | --- | --- |
| §1 总览 | 分协议 CRUD；无全局 CMD Tab | — |
| §2 进入 | 各模块 ⚙·命令与面板 | `CommandPanelGroup` |
| §3 蓝牙 | SPP/GATT/UART 命令字段 | `BluetoothCommandEditor` |
| §4 WiFi | Socket/HTTP Panel | `WifiCommandList` |
| §5 星闪 | SSAP Write / DT 面板 | `SsapWriteCommandList` |
| §6 运行时 | C「从收藏选择」→ Sheet | `btnPickFromFavorites` |
| §7 周期发送 | 间隔/次数/最小阈值 | `btnPeriodicSend` |
| §8 风险 | CMD-03 Dialog；G-SEC-03 | `PeriodicSendRiskSheet` |

---

## 13. 模块 ⚙ 设置流程交叉链接

| 模块 | 设置流程文档 | LOG 章节 | CMD 章节 |
| --- | --- | --- | --- |
| 蓝牙 | `02-蓝牙模块/04-模块设置与会话命令流程.md` | 会话与日志 | 命令与面板 |
| WiFi | `03-WiFi模块/04-WiFi模块设置与会话命令流程.md` | 同上 | PanelGrid |
| 星闪 | `04-星闪模块/04-星闪模块设置流程.md` | §3 LOG-* | §4 CMD-* |

---

## 14. 导出格式字段对照（LOG-02）

| 格式 | 适用场景 | 主要列/字段 |
| --- | --- | --- |
| TXT | 人类阅读、分享 | time, direction, summary |
| CSV | 表格分析 | time, direction, type, payload_hex, session_id |
| JSON | 完整归档 | SessionLog PRD 02 全模型 |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| EX-F1 | 选 TXT | 单行时间线文本 | `ExportFormat_txt` |
| EX-F2 | 选 CSV | 逗号分隔；UTF-8 BOM 可选 | `ExportFormat_csv` |
| EX-F3 | 选 JSON | pretty-print；含 metadata | `ExportFormat_json` |
| EX-F4 | Share Sheet | 系统分享/保存 | `ShareSheet` |

---

## 15. 周期发送跨模块可见性（CMD-03）

| 模块 | C 栏入口 | 工作台 Active | 840 RiskStrip |
| --- | --- | --- | --- |
| 蓝牙 SPP | CommandDock | Chip + Stop | 若从工作台 C |
| 蓝牙 UART | 同上 | 同上 | 同上 |
| WiFi TCP/WS | CommandDock | Chip + Stop | W-HOME-11 |
| 星闪 DT | CommandDock | Chip + Stop | 同上 |
| SSAP Write 周期 | P2 预留 | — | — |

---

## 16. 存储与 LOG 联动（G-STOR）

| 步 | 条件 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| ST-1 | 接近 G-STOR-01 上限 | SessionLogGroup 顶 Warning | `StorageWarningBanner` |
| ST-2 | 暂停落盘 ON | 新 Log 不写；列表标注 | `switchPauseLogging` |
| ST-3 | 按模块清理 | 更多 Tab·存储 或 模块 ⚙·清理 | `btnCleanupByModule` |
| ST-4 | 大 payload G-STOR-05 | LogViewer 折叠显示 | `LogEntry_collapsed` |

---

## 17. 验收逐步脚本（统一后端）

| 序 | 操作 | 期望 |
| --- | --- | --- |
| 1 | 蓝牙 SPP 运行 → ⋮ 会话记录 | ⚙ 会话列表定位 |
| 2 | 筛选 GATT → 导出 CSV 脱敏 | MAC 脱敏 |
| 3 | WiFi Traffic Save Log | traffic 类型行 |
| 4 | 星闪 SSAP SAVE → 导出 JSON | 八种类型之一 |
| 5 | ⚙ 新建 DT 命令 → C 从收藏选 | Sheet 非 Grid |
| 6 | 周期发送 → Stop | 工作台 Chip 同步 |
| 7 | 更多 Tab 搜索「日志」 | **无** 入口 |

---

## 18. PRD / 架构文档索引

| 文档 | 用途 |
| --- | --- |
| `01-功能清单/06-统一后端/01-SessionLog与Command能力清单.md` | 功能 ID 主表 |
| `03-UI设计/00-全局框架/03-模块自治与会话命令模型.md` | 数据模型 |
| `.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` | IA 铁律 |
| PRD `02-统一日志与命令面板PRD.md` | 产品需求 |

---

## 19. 轻量 vs 专家 — 统一后端显隐

| 能力 | 轻量 | 专家 | 功能 ID |
| --- | --- | --- | --- |
| Panel Grid 编辑 | 隐藏 | ⚙ 可达 | G-EXP-05 / CMD-02 |
| Log sessionId | 隐藏 | 详情可见 | G-EXP-02 |
| 导出关脱敏 | 不可 | 可 + 警告 | G-EXP-09 |
| Traffic HEX 默认 | ASCII | 可 HEX | G-EXP-03 |
| 命令高风险标记编辑 | 可见 | 可见 | CMD-01 |

---

## 20. 三模块 SAVE 入口对照

| 模块 | 运行时 SAVE 控件 | 设置默认 Tab |
| --- | --- | --- |
| 蓝牙 GATT | C Log `btnLogSave` | 会话与日志 |
| 蓝牙 SPP | ⋮ `menuSessionLog` | 同上 |
| WiFi 环境 | C `btnExport` | wifi_scan 行 |
| WiFi Traffic | C `btnSaveLog` | traffic 行 |
| 星闪 SSAP | C Log SAVE | nearlink_ssap |
| 星闪 DT | `menuSessionLog` | nearlink_datatransfer |

---

## 21. 版本记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v0.1 | 2026-07-03 | 初稿：索引 2 流程 + 功能清单链接 |

---

*06-统一后端 · 用户交互流程索引 · 深研草稿 v0.1*
