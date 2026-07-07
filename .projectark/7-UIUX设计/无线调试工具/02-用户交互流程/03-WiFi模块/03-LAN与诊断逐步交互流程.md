# 03 — LAN 与网络诊断逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` §2.3、`03-UI设计/03-WiFi模块/03-LAN与网络诊断页面设计.md`、`22-YoWire-PRD与竞品能力差距矩阵-v2.md` §5  
> **范围**：子网扫描 · 端口扫描 · Ping/DNS/TraceRoute/Whois · Filter · 导出

---

## 1. 流程总览

```text
WiFi·网络调试 Segmented
  ├── LAN：RangePanel → 增量 DiscoveryResultTable → 主机 drill-down → 端口扫描
  └── 诊断：任务创建 → ResultTimeline 增量输出 → 历史回放
```

**共用**：B 任务/主机列表 + C 输出 + Filter Sheet + ⚙ LAN/诊断设置。

---

## 2. 进入 LAN / 诊断模式

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | WiFi → **网络调试** | 网络调试根页 | `SegmentedControl_netDebug` |
| 步2 | 协议 Segmented 点 **LAN** | LAN 子模式 UI | `ProtocolSegmented_lan` |
| 步3 | 或点 **诊断** | 诊断子模式 UI | `ProtocolSegmented_diag` |
| 步4 | 顶栏 | `[新建任务] [Filter] [⚙]` | `LanDiagTitleBar` |
| 步5 | 切换 LAN↔诊断 | **不断** Socket Session（同模块） | `SessionManager` |

---

## 3. LAN — 子网扫描主屏

### 3.1 RangePanel 控件

```text
RangePanel：CIDR · 起止 IP · [从当前 WiFi 填充子网]
RiskSummary · RunControl · Progress · DiscoveryResultTable
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| L-1 | 进入 LAN | 显示 RangePanel 空态 | `LanScanPage` |
| L-2 | 输入 CIDR `192.168.1.0/24` | 校验格式 | `fieldCidr` |
| L-3 | 点 **从 WiFi 填充子网** | 读当前连接网段填入 | `btnFillFromWifi` |
| L-4 | 可选起止 IP | 缩小范围 | `fieldIpStart` / `fieldIpEnd` |
| L-5 | — | RiskSummary：目标数、并发、超时、预计耗时 | `RiskSummaryCard` |
| L-6 | 点 **开始** | 启动子网扫描 | `btnScanStart` |
| L-7 | — | Progress：已发现 N / 已扫描 M | `ScanProgressBar` |
| L-8 | 发现主机 | **append** 行到 DiscoveryResultTable | `DiscoveryResultTable` |
| L-9 | 新行到达 | 300ms 高亮动画 | `DiscoveryResultRow` |
| L-10 | 点 **暂停** | 保留结果；Resume 从未完成 IP 继续 | `btnScanPause` |
| L-11 | 点 **停止** | 标记「已中止」；可导出部分 | `btnScanStop` |
| L-12 | 点 **导出** | → WiFi ⚙·会话·LAN | `btnExportLan` |

### 3.2 增量 UI 规则

| 步 | 系统行为 | 控件名 |
| --- | --- | --- |
| L-13 | 扫描中 **禁止** 全表刷新闪烁 | `DiscoveryResultTable` |
| L-14 | 新主机 append 顶或底（设置可选） | `appendDirectionPreference` |
| L-15 | 仅私有网段 Switch OFF + 公网 | RiskConfirmDialog | `privateNetOnlySwitch` |

---

## 4. LAN — 主机 drill-down Sheet

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| L-16 | 点 DiscoveryResultTable 行 | HostDrilldownSheet 升起 | `DiscoveryResultRow` |
| L-17 | 行字段 | IP、主机名、MAC（权限允许）、latency | `hostSummary` |
| L-18 | 点 **Ping** | 快捷诊断子任务（跳转诊断 Segmented） | `btnHostPing` |
| L-19 | 点 **端口扫描** | 打开端口范围 Sheet | `btnHostPortScan` |
| L-20 | 点 **存为目标** | 写入 B 栏收藏主机 | `btnSaveHostFavorite` |
| L-21 | 点 **复制 IP/MAC** | 剪贴板 | `btnCopyHostInfo` |

---

## 5. LAN — 端口扫描

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PS-1 | 打开端口扫描 Sheet | 目标 IP 带入 | `PortScanSheet` |
| PS-2 | 填 **端口范围** `1-1024` 或 `22,80,443` | 解析校验 | `fieldPortRange` |
| PS-3 | 专家：调整 **并发** | 默认上限；超 ⚙ 上限 → RiskConfirm | `stepperPortConcurrency` |
| PS-4 | 填 **超时** ms | 单端口 | `fieldPortTimeout` |
| PS-5 | 范围 >1024 或非私有网 | RiskConfirmDialog | `PortScanRiskDialog` |
| PS-6 | 点 **开始** | 增量 PortResultTable append | `btnPortScanStart` |
| PS-7 | 每端口结果 | 端口、open/closed/filtered、耗时 | `PortResultRow` |
| PS-8 | 点 **停止** | 部分结果可导出 | `btnPortScanStop` |
| PS-9 | **导出** | ⚙·会话·端口扫描 | `btnExportPortScan` |

---

## 6. LAN Filter Sheet

| 维度 | 控件 | 行为 |
| --- | --- | --- |
| IP 范围 | 起止或 CIDR | 过滤 B/C 列表 |
| 状态 | 在线/离线/未知 | Checkbox |
| 延迟 | <50 / 50-200 / >200ms | Radio |
| 仅收藏 | Switch | filterFavoritesOnly |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| LF-1 | 点 **Filter** | LanFilterSheet | `btnFilter` |
| LF-2 | 设维度 | 编辑未保存 | `LanFilterSheet` |
| LF-3 | **Apply** | save + 刷新列表 | `btnFilterApply` |
| LF-4 | **Reset** | 清空四维 | `btnFilterReset` |
| LF-5 | **Close** | reload 丢弃 | `btnFilterClose` |

---

## 7. 诊断模式 — 任务创建

### 7.1 任务类型输入

| 类型 | 输入控件 | 说明 |
| --- | --- | --- |
| Ping | `fieldPingHost` | 文案：无 ICMP 则 TCP 探测 port |
| DNS | `fieldDnsDomain` + 记录类型 A/AAAA/CNAME | `radioDnsRecordType` |
| TraceRoute | `fieldTraceHost` + 最大跳数 | 专家可调 |
| Whois | `fieldWhoisTarget` | 域名或 IP |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| D-1 | Segmented **诊断** | 显示任务创建区 + 历史列表 | `ProtocolSegmented_diag` |
| D-2 | 点 **新建任务** | TaskCreateSheet | `btnNewDiagTask` |
| D-3 | 选 **Ping** | 显示 host + TCP port 说明 | `TaskTypePicker_ping` |
| D-4 | 选 Preset **网关** | 填入当前网关 IP | `PresetTarget_gateway` |
| D-5 | 选 **当前 DNS** | 填入系统 DNS | `PresetTarget_dns` |
| D-6 | 选收藏主机 | 从 LAN 收藏带入 | `PresetTarget_favorite` |
| D-7 | 点 **开始** | 创建任务；C 栏 Timeline 清空并 append | `btnDiagStart` |

### 7.2 禁 Ping 诚实文案

| 步 | 系统响应 | 控件名 |
| --- | --- | --- |
| D-8 | 设置/ Banner 显示：Ping 可能为 **TCP 连接探测** | `IcmpDisclaimerBanner` |
| D-9 | 结果禁止写「ICMP ping」当实际为 TCP | `ResultTimeline` |

---

## 8. 诊断 — ResultTimeline 增量输出

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| D-10 | 任务运行中 | 当前步骤 spinner | `DiagStepSpinner` |
| D-11 | 每步完成 | Timeline **append**：名称、目标、状态、耗时、摘要 | `ResultTimelineRow` |
| D-12 | 失败 | 明确分类：无网络/DNS失败/超时/拒绝/TLS错误/权限 | `ErrorCategoryChip` |
| D-13 | 点 **停止** | 标记中止；保留已完成步骤 | `btnDiagStop` |
| D-14 | 点 **导出** | → ⚙·会话·诊断 | `btnExportDiag` |
| D-15 | 点 **保存为会话** | 写入 SessionLog wifi_diag | `btnSaveDiagSession` |
| D-16 | 已完成步骤 | 可折叠 | `TimelineRow_collapse` |

### 8.1 Ping 逐步示例

| 步 | Timeline 行 | 控件名 |
| --- | --- | --- |
| 1 | 解析 host → IP | `stepResolve` |
| 2 | TCP connect port 80（若 ICMP 不可用） | `stepTcpProbe` |
| 3 | 结果：latency ms 或失败原因 | `stepResult` |

### 8.2 DNS 逐步示例

| 步 | Timeline 行 | 控件名 |
| --- | --- | --- |
| 1 | 查询 A 记录 | `stepDnsQuery` |
| 2 | 返回 IP 列表或 NXDOMAIN | `stepDnsResult` |

### 8.3 TraceRoute 逐步示例

| 步 | Timeline 行 | 控件名 |
| --- | --- | --- |
| 1 | Hop 1 … latency | `stepTraceHop` |
| 2 | 至最大跳或到达目标 | `stepTraceComplete` |

---

## 9. 诊断任务历史（B 栏）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| D-17 | 手机：诊断下 **任务历史** Tab | 列表：类型、目标、时间、成功/失败 | `DiagTaskHistoryList` |
| D-18 | 点历史任务 | C 栏回放 Timeline（只读） | `DiagTaskHistoryRow` |
| D-19 | 点 **重新运行** | 用相同参数新建任务 | `btnRerunTask` |
| D-20 | 长按删除 | ConfirmDialog | `btnDeleteTask` |

---

## 10. 诊断 Filter Sheet

| 维度 | 控件 |
| --- | --- |
| 任务类型 | Ping/DNS/Trace/Whois 多选 |
| 时间范围 | 今天/7天/自定义 |
| 仅失败 | Switch |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DF-1 | 点 Filter | DiagFilterSheet | `btnFilter` |
| DF-2 | Apply/Reset/Close | 同环境分析三按钮规范 | `btnFilterApply` 等 |

---

## 11. 840vp 三分栏 — LAN / 诊断

```text
A WiFi ● | B 主机/任务列表 | C RangePanel + Progress + 表/Timeline
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| W-1 | LAN 模式 | B：DiscoveryResultTable 列表 | `HostListPane_B` |
| W-2 | 点 B 主机 | C：drill-down 摘要 + 端口扫描入口 | `DiscoveryResultRow` |
| W-3 | 诊断模式 | B：DiagTaskHistoryList | `DiagHistoryPane_B` |
| W-4 | 点 B 任务 | C：ResultTimeline 回放 | `DiagTaskHistoryRow` |
| W-5 | C 工具栏 ≤6 | 开始/停止、暂停、导出、清结果、填充子网、专家参数 | `CToolbar_lanDiag` |
| W-6 | **专家参数** | 跳转 WiFi ⚙·LAN（轻量隐藏） | `btnExpertLanSettings` |

---

## 12. WiFi ⚙ LAN 设置联动

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SET-1 | ⚙ → LAN → **子网扫描超时** | 单 IP ms | `fieldSubnetTimeout` |
| SET-2 | **扫描线程数** | 专家可调 | `stepperScanThreads` |
| SET-3 | **端口扫描默认范围** | 1-1024 | `fieldDefaultPortRange` |
| SET-4 | **仅允许私有网段** | Switch | `switchPrivateNetOnly` |
| SET-5 | **禁 Ping 说明** | 只读文案 | `textIcmpDisclaimer` |
| SET-6 | **TraceRoute 最大跳** | 20 默认 | `stepperMaxHops` |

---

## 13. 会话导出路径

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| EX-1 | LAN 扫描完成点导出 | WiFi ⚙ → 会话 → LAN 子网类型 | `btnExportLan` |
| EX-2 | 端口扫描导出 | 会话 → 端口扫描 | `btnExportPortScan` |
| EX-3 | 诊断 Timeline 导出 | TXT/CSV/JSON | `btnExportDiag` |
| EX-4 | 批量 ⚙ | 按类型清理 LAN/诊断 | `btnClearLanDiagSessions` |

---

## 14. 与 Socket 模式共存

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | LAN 扫描中切 **Socket** Segmented | LAN 任务后台继续或暂停（设置） | `ProtocolSegmented` |
| 步2 | 从 LAN 主机 **Ping** | 带参数跳转诊断 Segmented | `btnHostPing` |
| 步3 | Traffic 与 LAN 结果 | **分离** SessionType | `SessionLogRepository` |

---

## 15. 验收检查清单

- [ ] 子网 CIDR + 从 WiFi 填充  
- [ ] 增量 append 不闪烁 + 暂停/停止  
- [ ] 主机 drill-down：Ping/端口/收藏  
- [ ] 端口扫描 RiskConfirm  
- [ ] 诊断四类任务 + Timeline append  
- [ ] ICMP 免责声明 + TCP 探测诚实文案  
- [ ] LAN/诊断 Filter Apply/Reset/Close  
- [ ] 840vp B 列表 + C 输出  
- [ ] 导出至 WiFi ⚙·会话  

---

## 16. mDNS/SSDP 预留（灰显）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MD-1 | LAN 页 **mDNS 扫描** 入口（P3） | 灰显 + 「后续版本支持」 | `btnMdnsScan_disabled` |
| MD-2 | ⚙ → LAN → mDNS/SSDP | 只读说明文案 | `NavRow_mdnsReserved` |
| MD-3 | 用户点击灰显项 | Toast 能力未接入 | `Toast_featurePending` |

---

## 17. 并发扫描与多任务

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MT-1 | 子网扫描进行中新建第二任务 | Dialog「停止当前扫描？」 | `MultiTaskConflictDialog` |
| MT-2 | 端口扫描 + 子网扫描并行 | 默认不允许；专家设置可选 | `parallelScanPreference` |
| MT-3 | 诊断 Ping 运行中切 LAN | 诊断后台继续 | `SessionManager` |
| MT-4 | B 栏多任务 | 任务 Tab 或列表分段显示 | `TaskListSegmented` |

---

## 18. Whois 结果展示

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WH-1 | 诊断选 **Whois** | 填域名或 IP | `TaskTypePicker_whois` |
| WH-2 | 点 **开始** | Timeline append 查询步骤 | `btnDiagStart` |
| WH-3 | 成功 | append 原始 Whois 文本块（可折叠） | `TimelineRow_whoisRaw` |
| WH-4 | 失败 | 「Whois 服务器无响应 / 配额限制」 | `ErrorCategoryChip` |
| WH-5 | **导出** | TXT 含完整 Whois 响应 | `btnExportDiag` |

---

## 19. TraceRoute 逐步 UI 示例

| 步 | Timeline 显示 | 控件名 |
| --- | --- | --- |
| TR-1 | Hop 1 · 192.168.1.1 · 2ms | `TimelineRow_hop` |
| TR-2 | Hop 2 · 10.0.0.1 · 15ms | `TimelineRow_hop` |
| TR-3 | Hop 3 · * · timeout | `TimelineRow_timeout` |
| TR-4 | 到达目标或 max hops | `TimelineRow_complete` |
| TR-5 | 用户点 **停止** | 保留已完成 hops | `btnDiagStop` |

---

## 20. DNS 失败分类 UI

| 步 | 失败类型 | Timeline 文案 | 控件名 |
| --- | --- | --- | --- |
| DNS-E1 | NXDOMAIN | 「域名不存在」 | `ErrorCategoryChip` |
| DNS-E2 | 超时 | 「DNS 查询超时」 | `ErrorCategoryChip` |
| DNS-E3 | 无网络 | 「当前无网络连接」 | `ErrorCategoryChip` |
| DNS-E4 | 成功 AAAA | 列出 IPv6 地址块 | `TimelineRow_dnsResult` |

---

## 21. 导出格式对照

| 类型 | TXT | CSV | JSON |
| --- | --- | --- | --- |
| LAN 子网 | IP 列表可读 | IP,MAC,latency | SessionLog schema |
| 端口扫描 | open/closed 表 | port,status,ms | 同上 |
| 诊断 | Timeline 逐步 | step,status,ms | 同上 |

---

*LAN 与网络诊断逐步交互流程；模块设置见 `04-WiFi模块设置与会话命令流程.md`。*
