# 05 — AndroidNetworkTools 逐步对照 YoWire

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **竞品**：[06-AndroidNetworkTools-LAN诊断-全量功能清单.md](../../01-功能清单/09-竞品APP功能清单/06-AndroidNetworkTools-LAN诊断-全量功能清单.md)  
> **YoWire 流程**：[03-LAN与诊断逐步交互流程.md](../03-WiFi模块/03-LAN与诊断逐步交互流程.md)  
> **深研**：`.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` §2.3～2.4

---

## 0. 映射总览

| 竞品域 | 样例 App 按钮 | 库 API | YoWire 文档 | YoWire 步号 |
| --- | --- | --- | --- | --- |
| Ping | pingButton | Ping.doPing | 03 §7 Ping | W-PNG-* |
| Wake-on-LAN | wolButton | WakeOnLan | 03 §8 WOL | W-WOL-* |
| Port Scan | portScanButton | PortScan | 03 §5 端口 | PS-* |
| Subnet | subnetDevicesButton | SubnetDevices | 03 §3 LAN | L-* |
| **DNS** | **无 UI** | **库无** | 03 §7 DNS | W-DNS-* **YoWire-only** |
| **TraceRoute** | **无 UI** | **库无** | 03 §7 TRT | W-TRT-* **YoWire-only** |
| **Whois** | **无 UI** | **库无** | 03 §7 Whois | W-WHO-* **YoWire-only** |

**形态差**：

| 项 | ANT 样例 App | YoWire |
| --- | --- | --- |
| 输出 | ScrollView resultText 纯文本 | B 列表 + C ResultTimeline 结构化 |
| IA | 单 Activity 四按钮 | Segmented LAN / 诊断 |
| 840vp | 无 | B 设备表 C Timeline（doc 16） |

---

## 1. 样例 App 壳层 → YoWire 进入 LAN/诊断

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| ANT-IA-01 | 启动样例 App | MainActivity | 步1～2 | `TabItem_wifi` · `ProtocolSegmented_lan` | [03 §2](../03-WiFi模块/03-LAN与诊断逐步交互流程.md) | **IA 差** |
| ANT-IA-01 | editIpAddress 预填本机 IPv4 | TextInputLayout | L-3 · Ping-1 | `fieldCidr` · `btnFillFromWifi` | 03 §3 · §7 | **增值** CIDR 非单 IP |
| ANT-IA-07 | 执行中 Button setEnabled false | 四按钮 | L-6 · PS-6 | `btnScanStart` 等 | 03 §3 · §5 | 对齐并发 UX |
| ANT-IA-06 | resultText append 滚底 | ScrollView | L-8 · Timeline | `DiscoveryResultTable` · `ResultTimeline` | 03 §3 · §7 | **增值** 结构化增量 UI |
| ANT-IA-07 | ⋮ action_github | 打开仓库 | — | About 链接 | 04 | 参考用 |

---

## 2. ANT-PING → 诊断 Ping（库有 · 样例有）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| ANT-PING-UI-01 | 输入/确认 IP | editIpAddress | PNG-1 | `diagTargetField` | 03 §7.1 | **增值** 支持域名 |
| ANT-PING-UI-02 | 点 **Ping** | pingButton 同步一次 | PNG-2 | `btnPingStart` | 03 §7.2 | 对齐 |
| ANT-PING-UI-03 | 异步 5 次 | setTimes(5).doPing(listener) | PNG-3 | `pingRepeatStepper` | 03 §7.2 | 对齐 ANT-PING-API-03 |
| ANT-PING-UI-04 | onFinished PingStats | Min/Avg/Max 文本 append | PNG-4 | `ResultTimeline` 统计行 | 03 §7.2 | **增值** Timeline 非纯文本 |
| ANT-PING-UI-05 | 空 IP Toast | Invalid Ip Address | PNG-5 | `diagTargetField` 校验 | 03 §7.2 | 对齐 |
| ANT-PING-API-06 | 无 /system/bin/ping | TCP:7 回退 | PNG-6 | `pingMethodBanner` | 03 §7.2 | 对齐 readme Note |
| — | 从 LAN 主机 drill-down Ping | 样例无 | L-18 | `btnHostPing` | 03 §4 | **YoWire-only** |

---

## 3. ANT-SUBNET → LAN 子网扫描 L-*

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| ANT-SUB-UI-01 | 点 **Subnet** | subnetDevicesButton | L-6 | `btnScanStart` | 03 §3.1 | **增值** CIDR RangePanel |
| ANT-SUB-UI-02 | 后台 Thread 扫描 | findSubnetDevices | L-7～8 | `ScanProgressBar` · `DiscoveryResultTable` | 03 §3.1 | **增值** 增量 append 非 append 文本 |
| ANT-SUB-API | Device IP/hostname/MAC | Device.java | L-8 行字段 | `DiscoveryResultRow` | 03 §3.1 | hostname 非 DNS 工具 |
| — | CIDR 输入 | 样例无 | L-2 | `fieldCidr` | 03 §3.1 | **YoWire PRD** |
| — | 暂停/停止/导出 | 样例无 | L-10～12 | `btnScanPause` · `btnExportLan` | 03 §3.1 | **YoWire-only** |
| — | Host drill-down Sheet | 样例无 | L-16～21 | `HostDrilldownSheet` | 03 §4 | **YoWire-only** |
| — | Filter Apply/Reset/Close | 样例无 | LF-1～5 | `LanFilterSheet` | 03 §6 | **YoWire-only** |

---

## 4. ANT-PORT → 端口扫描 PS-*

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| ANT-PORT-UI-01 | 点 **Port Scan** | portScanButton | PS-6 | `btnPortScanStart` | 03 §5 | **增值** 范围 Sheet |
| ANT-PORT-UI-02 | 目标 editIpAddress | 单 IP | PS-1 | `PortScanSheet` 带入 IP | 03 §5 | 对齐 |
| ANT-PORT-API | TCP/UDP connect 扫描 | PortScan.java | PS-7 | `PortResultTable` | 03 §5 | **增值** open/closed/filtered 列 |
| — | 端口范围 1-1024 | 样例固定逻辑 | PS-2 | `fieldPortRange` | 03 §5 | **YoWire PRD** |
| — | 并发/超时/风险确认 | 样例无 | PS-3～5 | `PortScanRiskDialog` | 03 §5 | **YoWire-only** |
| — | 从主机 drill-down | 样例无 | L-19 | `btnHostPortScan` | 03 §4 | **YoWire-only** |

---

## 5. ANT-WOL → WOL W-*

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| ANT-WOL-UI-01 | 点 **WOL** | wolButton | WOL-1 | `btnWakeOnLan` | 03 §8 | 对齐 |
| ANT-WOL-UI-02 | MAC 来自 IP/ARP | ARPInfo 间接 | WOL-2 | `fieldWolMac` | 03 §8 | **增值** 显式 MAC 字段 |
| ANT-WOL-API | UDP 魔术包 | WakeOnLan.java | WOL-3 | `WolSender` | 03 §8 | 对齐 |
| — | 广播地址/端口 | 样例简化 | WOL-4 | `fieldWolBroadcast` | 03 §8 | **YoWire 专家** |

---

## 6. ANT-DNS — YoWire-only（库无 · 诊断 Segmented）

> **竞品步号列填 `—`**：AndroidNetworkTools **无 DNS 工具**；YoWire **W-DIA-02** 参照 PRD §8.2 + Fing 类 UX。

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **无 DNS 入口** | 样例 App 无按钮 | DNS-1 | `ProtocolSegmented_diag` → DNS | 03 §7.3 | **YoWire P0 PRD** |
| — | **无 A/AAAA 查询 UI** | — | DNS-2 | `dnsQueryTypePicker` | 03 §7.3 | **YoWire-only** W-DNS-01/02 |
| — | **无自定义 DNS 服务器** | — | DNS-3 | `fieldDnsServer` | 03 §7.3 | **YoWire-only** W-DNS-04 专家 |
| ANT-DNS-05 | 间接 hostname | Subnet Device.hostname | L-8 字段 | `DiscoveryResultRow_hostname` | 03 §3 | 反向解析副作用，非 DNS 工具 |
| — | 创建 DNS 任务 | — | DNS-4 | `btnDiagStart` | 03 §7.1 | Timeline 增量输出 |
| — | 结果展示 | resultText 若伪造 | DNS-5 | `ResultTimeline` A/AAAA/CNAME 行 | 03 §7.3 | **YoWire-only** |
| — | 导出 | — | DNS-6 | `btnExportDiag` → ⚙ | 03 §7 · 04 | SessionLog |

---

## 7. ANT-TRT — TraceRoute YoWire-only

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **库无 TraceRoute** | 仓库 tree 无类 | TRT-1 | 诊断 Segmented TraceRoute | 03 §7.4 | **YoWire P0** W-DIA-03 |
| — | **样例无 UI** | — | TRT-2 | `fieldTrtTarget` · maxHops | 03 §7.4 | W-TRT-01～02 |
| — | — | — | TRT-3 | `btnTrtStart` | 03 §7.4 | HarmonyOS Network Kit 参照 |
| — | — | — | TRT-4 | `ResultTimeline` 逐跳 append | 03 §7.4 | **YoWire-only** 结构化 |
| — | 超时/不可达 hop | — | TRT-5 | `TrtHopRow_timeout` | 03 §7.4 | PRD §8.3 |
| inventory 12 | §2.4 列 TRT 为 PRD 规划 | — | TRT-* | 全文 | 03 §7.4 | **非 ANT 能力** |

---

## 8. ANT-WHO — Whois YoWire-only

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **库无 Whois** | — | WHO-1 | 诊断 Segmented Whois | 03 §7.5 | **YoWire P0** W-DIA-04 |
| — | **样例无 UI** | — | WHO-2 | `fieldWhoisTarget` 域名/IP | 03 §7.5 | W-WHO-01 |
| — | — | — | WHO-3 | `btnWhoisStart` | 03 §7.5 | INTERNET 权限 Banner |
| — | — | — | WHO-4 | `ResultTimeline` 注册商/日期 摘要 | 03 §7.5 | **YoWire-only** |
| — | ARP MAC 非 Whois | ARPInfo /proc/net/arp | L-8 MAC 列 | `DiscoveryResultRow_mac` | 03 §3 | 文案区分 W-WHO-04 |
| — | 导出 | — | WHO-5 | ⚙·会话·诊断 | 03 · 04 | SessionLog |

---

## 9. LAN Filter Apply/Reset/Close（YoWire · 样例无）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | 样例无 Filter | — | LF-1 | `btnFilter` · `LanFilterSheet` | 03 §6 | **YoWire-only** |
| — | IP 范围/CIDR | — | LF-2 | `filterIpRange` | 03 §6 | YoWire-only |
| — | 在线/延迟/收藏 | — | LF-2 | `filterStatus` · `filterLatency` | 03 §6 | YoWire-only |
| — | **Apply** | — | LF-3 | `btnFilterApply` | 03 §6 | 语义同 WiFiAnalyzer F-06 |
| — | **Reset** | — | LF-4 | `btnFilterReset` | 03 §6 | 清空 |
| — | **Close** | — | LF-5 | `btnFilterClose` | 03 §6 | reload 丢弃 |

---

## 10. inventory 12 L-1～L-4 逐步对照

| inventory 步 | 描述 | 竞品 ANT | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| L-1 | CIDR → 扫描 | Subnet 按钮近似 | L-1～6 | `RangePanel` | 03 §3 | YoWire 完整 RangePanel |
| L-2 | 增量发现列表 | resultText 文本 | L-8～9 | `DiscoveryResultTable` | 03 §3.2 | **增值** 动画 append |
| L-3 | 主机 drill-down | 无 | L-16～21 | `HostDrilldownSheet` | 03 §4 | YoWire-only |
| L-4 | 端口扫描 | portScanButton | PS-1～9 | `PortScanSheet` | 03 §5 | YoWire 增强 |

---

## 11. 库 API → YoWire 功能 ID

| ANT-LIB | 库类 | YoWire ID | YoWire流程文档 | 竞品样例 UI |
| --- | --- | --- | --- | --- |
| ANT-LIB-01 | Ping | W-DIA-01 W-PNG-* | 03 §7.2 | ✓ pingButton |
| ANT-LIB-02 | PortScan | W-LAN-03 PS-* | 03 §5 | ✓ portScanButton |
| ANT-LIB-03 | SubnetDevices | W-LAN-01 L-* | 03 §3 | ✓ subnetButton |
| ANT-LIB-04 | WakeOnLan | W-LAN-05 WOL-* | 03 §8 | ✓ wolButton |
| ANT-LIB-05 | ARPInfo | W-LAN-04 MAC 字段 | 03 §3 | 间接 |
| ANT-LIB-06 | IPTools | L-3 fillFromWifi | 03 §3 | 预填 IP 近似 |
| ANT-LIB-08 | **无 DNS** | W-DIA-02 | 03 §7.3 | **✗ YoWire-only** |
| ANT-LIB-09 | **无 TRT** | W-DIA-03 | 03 §7.4 | **✗ YoWire-only** |
| ANT-LIB-10 | **无 Whois** | W-DIA-04 | 03 §7.5 | **✗ YoWire-only** |

---

## 12. 840vp · SessionLog

| 竞品 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| ScrollView 纯文本 | resultText | W-LAN | B `DiscoveryResultTable` C `ResultTimeline` | 03 · doc 16 | **GAP-840** |
| 无持久化 | — | L-12 · 导出 | `btnExportLan` → ⚙ | 03 · [06](../06-统一后端/01-会话日志导出逐步交互流程.md) | SessionLog |
| 单任务 | 四按钮并行禁用 | 步5 | `SessionManager` 多任务 | 03 §2 | YoWire 任务历史 |

---

## 13. 验收勾选

- [ ] Ping 同步+异步+Stats 对齐 ANT-PING  
- [ ] Subnet → YoWire CIDR 扫描 L-*  
- [ ] Port Scan 增量表 PS-*  
- [ ] WOL 魔术包  
- [ ] **DNS/TRT/Whois 诊断** 可走通（YoWire-only，不标 ANT 步号）  
- [ ] LAN Filter Apply/Reset/Close  
- [ ] ≥840vp B/C 分栏  
- [ ] ⚙ 会话导出  

---

## 14. 证据索引

| 键 | 路径 |
| --- | --- |
| 竞品清单 | `09/06-AndroidNetworkTools-LAN诊断-全量功能清单.md` |
| inventory 12 | `.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` |
| YoWire PRD | `04-WiFi模块PRD.md` §8 |
| 库 README | https://github.com/stealthcopter/AndroidNetworkTools |

---

## 15. ARPInfo 与 LAN 字段对照

| 竞品步号 | 竞品 API | 竞品样例输出 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| ANT-LIB-05-1 | ARPInfo.getMACFromIPAddress | /proc/net/arp | L-8 | `DiscoveryResultRow_mac` | 03 §3 | 权限允许时显示 |
| ANT-LIB-05-2 | ip neigh 回退 | 部分机型 | L-8 | `macResolveBanner` | 03 §3 | HarmonyOS 对照 |
| ANT-DNS-05 | Device.hostname 副作用 | Subnet 文本 | L-8 | `rowHostname` | 03 §3 | **非** DNS 工具 |
| — | 样例无结构化 MAC 列 | resultText 混排 | L-8 | 独立列 | 03 §3 | **YoWire 增值** |

---

## 16. 诊断 Segmented 任务生命周期（YoWire-only 框架）

| 任务类型 | 竞品 ANT | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Ping | ✓ pingButton | PNG-* | `DiagTask_ping` | 03 §7.2 | 库对齐 |
| DNS | ✗ | DNS-* | `DiagTask_dns` | 03 §7.3 | **PRD P0** |
| TraceRoute | ✗ | TRT-* | `DiagTask_trt` | 03 §7.4 | **PRD P0** |
| Whois | ✗ | WHO-* | `DiagTask_whois` | 03 §7.5 | **PRD P0** |
| — | 无任务历史 | — | B 栏任务列表 | 03 §7 | YoWire-only |
| — | 无 Timeline | ScrollView | C `ResultTimeline` | 03 §7 | 增量 append |

---

## 17. PortScan 库参数 → YoWire Sheet

| ANT-PORT-API | 库参数 | 样例 App | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| method TCP | PortScan.setMethodTCP | 默认 | PS-6 | `portScanMethodTcp` | 03 §5 | 对齐 |
| method UDP | setMethodUDP | 样例未暴露 | PS-6 专家 | `portScanMethodUdp` | 03 §5 | YoWire 扩展 |
| ports string | setPorts("22,80") | 简化 | PS-2 | `fieldPortRange` | 03 §5 | 对齐 |
| timeout | setTimeoutMillis | 固定 | PS-4 | `fieldPortTimeout` | 03 §5 | YoWire 可调 |
| concurrency | 库内部 | 无 UI | PS-3 | `stepperPortConcurrency` | 03 §5 | **YoWire 风险确认** |

---

## 18. inventory 12 §2.4 诊断 PRD 行对照

| inventory 12 条目 | AndroidNetworkTools | YoWire W-DIA | 本对照节 |
| --- | --- | --- | --- |
| Ping 完整 | ✓ 库+样例 | W-DIA-01 | §2 |
| DNS Lookup | ✗ | W-DIA-02 | §6 |
| TraceRoute | ✗ | W-DIA-03 | §7 |
| Whois | ✗ | W-DIA-04 | §8 |
| 结构化输出 | ✗ | Timeline | §16 |
| 840vp | ✗ | B/C | §12 |

---

## 19. WOL 与 Subnet 组合场景（YoWire 规划）

| 场景 | 竞品 ANT | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Subnet 发现后 WOL | 样例分离两按钮 | L-16 | Host drill-down WOL | 03 §4 · §8 | **YoWire 串联** |
| 无 MAC 时 WOL | ARP 失败静默 | WOL-2 | `fieldWolMac` 手填 | 03 §8 | 专家 |
| 跨子网 WOL | 样例未文档 | WOL-4 | `fieldWolBroadcast` | 03 §8 | YoWire 专家 |
| 导出 WOL 事件 | 无 | WOL-5 | ⚙ SessionLog | 04 · 06 | YoWire-only |

**维护**：ANT 库版本 JitPack 0.4.5.3 变更时同步 §3 库 API 表与样例 `MainActivity` 按钮 ID。

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `08-竞品逐步流程对照/` |
| 版本 | 深研草稿 v0.1 |
