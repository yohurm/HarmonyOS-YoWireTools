# 05 — WiFi 840vp 三分栏逐步交互流程

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **类型**：用户交互流程 · 840vp 模块专篇  
> **依据**：`.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` · `03-UI设计/03-WiFi模块/`  
> **范围**：A 栏环境/网络 Segmented；B AP 列表常驻；C Sub-Tab 图表；网络调试 B 会话 + C Traffic/Terminal

---

## 1. 进入 WiFi 840 三分栏

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WF-A1 | 宽度 ≥840vp 点 A **WiFi** | B/C 加载 WiFi 骨架 | `SideNavItem_wifi` |
| WF-A2 | A 栏二级 Segmented | **环境分析 \| 网络调试**（doc 16 §2） | `SideNavSegmented_envNet` |
| WF-A3 | 默认项 | 上次选中或 **环境分析** | `SideNavSegmented_envNet` |
| WF-A4 | 切换 Segmented | B/C 整体切换；各自 Session 保留 | `WifiModuleController` |
| WF-A5 | 收起 A | B 标题「WiFi · 环境分析」或「WiFi · 网络调试」 | `SideNavCollapse` |

**核心差异（vs 错误 IA）**：**AP 列表在 B 栏**，不在 C Sub-Tab 内。

---

## 2. A 栏 WiFi 分段模型

```text
A 栏
├── WiFi ●
│   ├── [环境分析 | 网络调试]  ← A 栏 Segmented（非 C）
│   └── （LAN/诊断归入网络调试 B Segmented）
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WF-A6 | A 选 **环境分析** | B=AP 列表；C=图表 Sub-Tab | `SideNavSegment_env` |
| WF-A7 | A 选 **网络调试** | B=会话/LAN 列表；C=Terminal+Traffic | `SideNavSegment_net` |
| WF-A8 | 从工作台 WiFi Card | A 环境分析 + B 扫描态 | `ModuleCapabilityCard_wifi` |
| WF-A9 | deep link traffic | A 网络调试 + B 会话高亮 | `DeepLinkRouter` |

---

## 3. 环境分析 — A/B/C 逐步流程

> 手机对照：[`../03-WiFi模块/01-环境分析逐步交互流程.md`](../03-WiFi模块/01-环境分析逐步交互流程.md)

### 3.1 B 栏 — AP 列表（常驻）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| E-B1 | — | B：**AP 列表** + 扫描/Filter/⚙ | `ApListPanel_B` |
| E-B2 | 点 **扫描** | 启动 WiFi 扫描；PeriodicScan 按 ⚙ | `btnScanToggle` |
| E-B3 | 点 **Filter** | 居中 Sheet 480×560（SSID/BSSID/频段/安全） | `WifiFilterSheet` |
| E-B4 | Apply Filter | B 列表过滤；Chip 高亮 | `btnFilterApply` |
| E-B5 | 点 AP 行 | 行高亮；C 图表绑定该 AP | `ApListRow` |
| E-B6 | 无选中 | C Empty「选择 AP 查看详情」 | `EmptyState_wifiEnv` |
| E-B7 | 点 ⚙ | C navigate WiFi 设置 | `btnModuleSettings` |

### 3.2 C 栏 — Sub-Tab 图表区

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| E-C1 | — | C Sub-Tab：**详情 \| 信道图 \| 时间图 \| 评分** | `WifiEnvSubTabs_C` |
| E-C2 | 切换 **详情** | SSID/BSSID/信道/RSSI/安全 | `Tab_apDetail` |
| E-C3 | 切换 **信道图** | 2.4/5GHz 柱状图 | `Tab_channelChart` |
| E-C4 | 切换 **时间图** | RSSI 时序（PeriodicScan） | `Tab_timeChart` |
| E-C5 | 切换 **评分** | 干扰/推荐信道 | `Tab_score` |
| E-C6 | 专家模式 | BSSID 完整；图表 Y 轴可调（⚙） | `ExpertModeObserver` |
| E-C7 | C **Export** | 持久化 wifi_scan Session | `btnExport` |
| E-C8 | C 工具栏 ≤6 | Export · 分享 · 放大 · … | `Toolbar_wifiEnvC` |

### 3.3 环境 vs 网络 A 栏切换

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| E-SW1 | A 从环境切 **网络调试** | B 切会话列表；C 切 Terminal | `SideNavSegment_net` |
| E-SW2 | 再切回环境 | B 恢复 AP 列表；**上次 AP 选中保留** | `ApSelectionStore` |
| E-SW3 | PeriodicScan 运行 | 环境 B RSSI 刷新；切网络不停止 scan* | `WifiScanSession` |

*默认 G-BG-04 后台可暂停。

---

## 4. 网络调试 — A/B/C 逐步流程

> 手机对照：[`../03-WiFi模块/02-网络调试逐步交互流程.md`](../03-WiFi模块/02-网络调试逐步交互流程.md)

### 4.1 B 栏 — 会话 / LAN / 诊断

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| N-B1 | A 选 **网络调试** | B Segmented：**会话 \| LAN \| 诊断** | `NetworkListSegmented_B` |
| N-B2 | **会话** Tab | Socket/HTTP/WS/MQTT 会话行 | `NetworkSessionList` |
| N-B3 | 点 **新建** | B 新增行 + C 配置区 | `btnNewSession` |
| N-B4 | 点会话行 | 行高亮；C 加载协议工作区 | `NetworkSessionRow` |
| N-B5 | **LAN** Tab | 主机列表 / 子网扫描 | `LanHostList` |
| N-B6 | **诊断** Tab | Ping/Traceroute 历史 | `DiagHistoryList` |

### 4.2 C 栏 — Terminal + Traffic

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| N-C1 | 会话已连接 | C：**Terminal 55% + Traffic 45%** | `NetworkTerminal` / `TrafficPanel` |
| N-C2 | Terminal 发送 | Traffic 表追加行 | `CommandDock` |
| N-C3 | **周期发送 Resend** | Chip + Stop；工作台 RiskStrip | `btnPeriodicSend` |
| N-C4 | Traffic 筛选 | 列 Chip；专家 HEX 默认 | `TrafficFilterBar` |
| N-C5 | **Save Log** | navigate WiFi ⚙·会话 | `btnSaveLog` |
| N-C6 | HTTP/WebSocket 子 Tab | C 内协议 Tab（非 AP 列表） | `ProtocolSubTabs_C` |
| N-C7 | LAN 诊断输出 | C 全高输出区（无 Traffic） | `LanDiagOutput` |

---

## 5. HTTP / WebSocket / MQTT 840 布局

> 详见 [`../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md`](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md)

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| P-C1 | B 选 HTTP 会话 | C Request/Response 分 pane | `HttpWorkbench_C` |
| P-C2 | B 选 WebSocket | C 消息流 + Traffic | `WsMessagePanel` |
| P-C3 | B 选 MQTT | C Topic 树 + 消息 | `MqttTopicPanel` |
| P-C4 | SmartResponse（专家） | C 内嵌；非独立第四栏 | `SmartResponsePanel` |

---

## 6. Filter Sheet（WiFi 840）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| F-1 | B Filter | 居中 480×560 | `WifiFilterSheet` |
| F-2 | SSID 部分匹配 | 实时预览 AP 数 | `filterSsid` |
| F-3 | 频段 2.4/5/6 | Checkbox | `filterBand` |
| F-4 | 安全类型 | WPA3/WPA2/开放 | `filterSecurity` |
| F-5 | 专家 BSSID | 完整或前缀 | `filterBssid` |
| F-6 | Apply | B 列表刷新 | `btnFilterApply` |

---

## 7. 模块设置 840 navigate

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SET-1 | B ⚙ | C WiFi 设置 | `WifiSettingsPage` |
| SET-2 | 会话/命令/扫描分组 | 见 [`../03-WiFi模块/04-WiFi模块设置与会话命令流程.md`](../03-WiFi模块/04-WiFi模块设置与会话命令流程.md) | `SessionLogGroup` |
| SET-3 | ← 返回 | C 恢复 AP 图表或 Terminal；scan/session **不断** | `btnSettingsBack` |

---

## 8. 断点与折叠接续（WiFi 专项）

| 状态 | 环境分析 | 网络调试 | 键 |
| --- | --- | --- | --- |
| A Segmented env/net | ✓ | ✓ | `SideNavSegmented_envNet` |
| B AP 选中 bssid | ✓ | — | `ApSelectionStore` |
| C Sub-Tab 索引 | ✓ | — | `WifiEnvTabStore` |
| C Terminal scroll | — | ✓ | `ScrollStateStore` |
| Traffic 筛选 | — | ✓ | `TrafficFilterStore` |
| PeriodicScan 态 | ✓ | 切 Tab 策略 | `WifiScanSession` |

全局清单：[`03-840vp三分栏与折叠屏接续流程.md`](03-840vp三分栏与折叠屏接续流程.md) §5.1 R-09～R-11。

---

## 9. 840 ↔ 600 布局差异

| 能力 | 840vp | 600–839vp |
| --- | --- | --- |
| A 栏 env/net 分段 | A 栏 Segmented | WiFi L0 Segmented 或 B 标题 |
| AP 列表位置 | **B 常驻** | **B 常驻**（同） |
| C 图表 | Sub-Tab 四页 | Sub-Tab 四页 |
| 网络 C | Terminal 55 + Traffic 45 | 同比例 |
| 工作台 deep link | A 自动分段 | Tab + navigate |

---

## 10. 与统一后端交叉引用

| 能力 | 文档 |
| --- | --- |
| wifi_scan / traffic 导出 | [`../06-统一后端/01-会话日志导出逐步交互流程.md`](../06-统一后端/01-会话日志导出逐步交互流程.md) |
| Panel / 周期发送 | [`../06-统一后端/02-命令面板与周期发送逐步交互流程.md`](../06-统一后端/02-命令面板与周期发送逐步交互流程.md) |
| 功能清单 | `01-功能清单/03-WiFi模块/` |

---

## 11. 验收要点

- [ ] A 栏 env/net Segmented；AP **仅在 B**
- [ ] C 环境 Sub-Tab 四页；无 AP 列表 Tab
- [ ] 网络 B 会话/LAN/诊断；C Terminal+Traffic
- [ ] Filter 居中 Sheet；B≤3 C≤6
- [ ] Resend → 工作台 RiskStrip
- [ ] ⚙ C navigate 返回不断 scan/session
- [ ] 无第四 Inspector

---

## 12. 相关文档

| 文档 | 路径 |
| --- | --- |
| 环境分析手机 | `../03-WiFi模块/01-环境分析逐步交互流程.md` |
| 网络调试手机 | `../03-WiFi模块/02-网络调试逐步交互流程.md` |
| LAN 诊断 | `../03-WiFi模块/03-LAN与诊断逐步交互流程.md` |
| 600–839 | `02-600-839双栏切换流程.md` §7–8 |
| 840 总览 | `03-840vp三分栏与折叠屏接续流程.md` |
| 线框 doc 16 | `.research/feature-inventory/16-…` |

---

## 13. PeriodicScan 840 行为

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PS-1 | B 开启周期扫描 | C 时间图实时追加点 | `PeriodicScanIndicator` |
| PS-2 | A 切网络调试 | 扫描继续或按 G-BG-04 暂停 | `WifiScanSession` |
| PS-3 | App 后台 | 扫描暂停；回前台恢复 | `BackgroundScanPolicy` |
| PS-4 | 专家：扫描间隔 | ⚙·扫描 可调；轻量锁定默认 | `inputScanInterval` |

---

## 14. SmartResponse / PanelGrid（专家 · 网络 C）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-1 | HTTP 会话 C 内嵌 SmartResponse | 非第四栏；C 子 pane | `SmartResponsePanel` |
| SR-2 | PanelGrid 编辑 | 仅 WiFi ⚙；运行时 Sheet 选择 | `PanelGridEditor` |
| SR-3 | 840 放大 C | SmartResponse 随 C 全屏 | `btnExpandC` |

详见 [`../03-WiFi模块/06-SmartResponse与PanelGrid逐步交互流程.md`](../03-WiFi模块/06-SmartResponse与PanelGrid逐步交互流程.md)。

---

## 15. LAN 与诊断 840 B/C

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| LAN-1 | B **LAN** Tab | 子网扫描主机列表 | `LanHostList` |
| LAN-2 | 点主机 | C Ping/Port 输出 | `LanDiagOutput` |
| LAN-3 | B **诊断** Tab | Traceroute 历史 | `DiagHistoryList` |
| LAN-4 | 危险 LAN 扫描 | G-SEC-03 二次确认 | `LanScanConfirmDialog` |

详见 [`../03-WiFi模块/03-LAN与诊断逐步交互流程.md`](../03-WiFi模块/03-LAN与诊断逐步交互流程.md)。

---

## 16. WiFi 840 演示脚本（验收用）

| 序 | 操作 | 期望 |
| --- | --- | --- |
| 1 | A 环境→B 扫描→选 AP | C 信道图 |
| 2 | C 四 Sub-Tab 切换 | 同一 AP 绑定 |
| 3 | A 网络→B 新建 TCP | C Terminal+Traffic |
| 4 | Resend | 工作台 RiskStrip |
| 5 | B ⚙→返回 | scan/session 不断 |
| 6 | 验证 AP **不在** C Tab | IA P0 |

---

## 17. 与 03-WiFi模块流程对照

| 手机流程 | 840 本文档 |
| --- | --- |
| 01-环境 §3 AP 列表 | §3.1 E-B1～B7 |
| 01-环境 §5 图表 | §3.2 E-C1～C8 |
| 02-网络 §4 会话 | §4.1 N-B1～B6 |
| 02-网络 §6 Traffic | §4.2 N-C1～C7 |
| 04-设置 | §7 SET-1～3 |

---

## 18. WiFi 840 权限 Banner

| 步 | 条件 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PB-1 | 无 GET_WIFI_INFO | B 扫描钮灰；Banner | `ModulePermissionBanner_wifi` |
| PB-2 | 无 INTERNET | A 网络 Segmented 可用；连接失败 Banner | `G-BNR-WF04` |
| PB-3 | 位置拒绝 | 环境 B 空列表 + 引导 | `ModuleCardBanner_wifi` |

---

*WiFi 840vp 三分栏逐步交互流程 · 深研草稿 v0.1*
