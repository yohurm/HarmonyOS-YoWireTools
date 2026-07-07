# LAN 与网络诊断功能清单

> **状态**：深研草稿  
> **证据**：`.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` §2.3–2.4、`16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` §3.2  
> **PRD 映射**：`04-WiFi模块PRD.md` §7–§9 · 差距矩阵 `22` §5（WF-NET-13～16）  
> **竞品参照**：PacketSender Subnet 工具（LAN 部分）；Network Analyzer / Fing 类（诊断）；**Ping/DNS/TraceRoute/Whois 为 PRD 完整规划，PacketSender 无**

---

## 1. 文档目的

枚举 YoWire **WiFi·LAN 发现**与**网络诊断**功能 ID，覆盖子网扫描、端口扫描、Ping/DNS/TraceRoute/Whois 及当前网络摘要。日志/导出归属 **WiFi ⚙·会话与日志**。

---

## 2. 模块 IA 位置

```text
WiFi 模块 L0
├── 环境分析（见 01-WiFiAnalyzer…）
├── 网络调试 · Segmented
│   ├── Socket / HTTP / WS / MQTT（见 02-网络协议…）
│   ├── LAN（本子文档 W-LAN-*）
│   └── 诊断（本子文档 W-DIA-*）
└── ⚙ WiFi 设置 · LAN 分组
```

**840vp**：B 栏 LAN/诊断目标列表；C 栏进度 + 结果表 + 输出 Timeline（WF-NET-19）。

---

## 3. 功能 ID 总表

| 功能 ID | 名称 | 分级 | 竞品/PRD | Gap | 主 UI |
| --- | --- | --- | --- | --- | --- |
| W-NET-01 | 当前网络摘要（Connection 扩展） | 必须 | PRD §7.1 | P0 | WiFi 首页 / C Connection 条 |
| W-NET-02 | 网络变化监听与日志 | 必须 | PRD §7.2 | P0 | 摘要 + SessionLog |
| W-LAN-01 | 子网自动识别（IP+掩码） | 完整规划 | PRD §9.1 · PS Subnet | P1 | LAN 入口 |
| W-LAN-02 | 子网手动 CIDR 输入 | 完整规划 | PRD §9.1 | P1 | TextField |
| W-LAN-03 | 子网扫描（Ping/TCP/ARP 降级） | 完整规划 | PRD §9.1 | P1 | 进度 + 设备列表 |
| W-LAN-04 | 设备列表字段 | 完整规划 | PRD §9.1 | P1 | IP/MAC/OUI/响应/端口摘要 |
| W-LAN-05 | 扫描频率/并发限制 | 必须 | PRD §9.1 | P1 | **WiFi ⚙·LAN** |
| W-LAN-06 | 文案「本地诊断」边界 | 必须 | PRD §9.1 | P0 | Banner + 关于 |
| W-LAN-07 | TCP 端口扫描 | 完整规划 | PRD §9.2 | P1 | 端口范围 → 结果表 |
| W-LAN-08 | UDP 端口探测 | 完整规划 | PRD §9.2 | P1 | 不可靠说明 |
| W-LAN-09 | 常用端口模板 | 完整规划 | PRD §9.2 | P1 | HTTP/SSH/Telnet/MQTT/CoAP |
| W-LAN-10 | 端口扫描停止/超时/并发 | 完整规划 | PRD §9.2 | P1 | **WiFi ⚙·LAN** |
| W-LAN-11 | 从子网设备 → Ping/Port 入口 | 完整规划 | doc 12 L-3 | P1 | 行操作 |
| W-LAN-12 | mDNS 服务发现 | 架构预留 | PRD §11 | P2 | LAN Segmented 预留 |
| W-LAN-13 | SSDP 发现 | 架构预留 | PRD §11 | P2 | UDP 组播规划 |
| W-DIA-01 | **Ping** | 完整规划 | PRD §8.1 | P0 | 诊断列表 + C 输出 |
| W-DIA-02 | **DNS** 解析 | 完整规划 | PRD §8.2 | P0 | 同上 |
| W-DIA-03 | **TraceRoute** | 完整规划 | PRD §8.3 · Network Kit | P0 | 同上 |
| W-DIA-04 | **Whois** | 完整规划 | PRD §8.4 | P0 | 同上 |
| W-DIA-05 | 诊断会话 Timeline 导出 | 必须 | 统一日志 | P1 | **WiFi ⚙·会话** |
| W-DIA-06 | 诊断命令收藏/Panel | 首期 | 命令面板 | P1 | **WiFi ⚙·命令与面板** |

---

## 4. 当前网络诊断（W-NET-01/02）

### 4.1 网络摘要字段

| 字段 ID | 字段 | 空值策略 |
| --- | --- | --- |
| W-CONN-01 | 默认网络类型 | WiFi / 蜂窝 / 以太 / 无 |
| W-CONN-02 | WiFi SSID / BSSID / RSSI / 频段 | BSSID 受权限降级 |
| W-CONN-03 | IPv4 / IPv6 / 子网 | LinkAddresses 可能空 |
| W-CONN-04 | 网关 / 默认路由 | routes 可能空 |
| W-CONN-05 | DNS 服务器 | dnses 可能空 |
| W-CONN-06 | HTTP/系统代理 | |
| W-CONN-07 | VPN 状态 | |
| W-CONN-08 | Captive Portal | |
| W-CONN-09 | 互联网可用性 | 默认网络能力 |

**与 WiFiAnalyzer Connection 条关系**：环境分析 W-ENV-10 展示精简版；本节为 **网络诊断**完整摘要（PRD §7）。

### 4.2 网络变化监听（W-NET-02）

| 事件 ID | 事件 | 行为 |
| --- | --- | --- |
| W-EVT-01 | 网络可用 | 更新摘要 + SessionLog |
| W-EVT-02 | 网络丢失 | Banner + Log |
| W-EVT-03 | 网络不可用 | 原因展示 |
| W-EVT-04 | 能力变化 | WiFi/蜂窝/VPN 更新 |
| W-EVT-05 | 连接属性变化 | IP/DNS/路由更新 |

---

## 5. 子网扫描（W-LAN-01～06）

### 5.1 逐步流程

| 步 ID | 用户动作 | UI 控件 | 结果 |
| --- | --- | --- | --- |
| W-LAN-F01 | 进入 WiFi → LAN | Segmented「LAN」 | 子网表单 |
| W-LAN-F02 | 自动识别 / 手动 CIDR | TextField + 芯片 | 校验 CIDR |
| W-LAN-F03 | Start Scan | 进度条 + 取消 | 并发 Ping/TCP |
| W-LAN-F04 | 列表刷新 | IP、主机名、MAC/OUI、RTT | 排序/Filter |
| W-LAN-F05 | 点设备行 | 上下文 | → Ping / Port Scan |
| W-LAN-F06 | 导出 | Sheet | TXT/CSV/JSON → **WiFi ⚙·会话** |

### 5.2 扫描方式与降级

| 方式 ID | 方式 | 优先级 | 降级 |
| --- | --- | --- | --- |
| W-SCAN-M01 | ICMP Ping | 首选 | 权限/禁 Ping 说明 |
| W-SCAN-M02 | TCP connect 探测 | 备选 | 常用端口 80/443/22 |
| W-SCAN-M03 | ARP | 待验证 | 不可用则隐藏（PRD §7.2 降级） |

### 5.3 WiFi ⚙·LAN 设置项

| 项 ID | 名称 | 默认 | 说明 |
| --- | --- | --- | --- |
| W-LAN-S01 | 扫描超时 (ms) | 3000 | 单主机 |
| W-LAN-S02 | 最大并发 | 32 | 专家可调 |
| W-LAN-S03 | 线程/任务池 | Worker | 不阻塞 UI |
| W-LAN-S04 | 禁 Ping 说明 | 只读 | 平台策略 |
| W-LAN-S05 | 危险操作确认 | 继承全局 | LAN 扫描二次确认 |

---

## 6. 端口扫描（W-LAN-07～11）

### 6.1 配置项

| 项 ID | 配置 | 要求 |
| --- | --- | --- |
| W-PORT-C01 | 目标 IP | 来自 LAN 列表或手动 |
| W-PORT-C02 | TCP 端口范围 | 1–65535 或模板 |
| W-PORT-C03 | UDP 探测 | 可选；结果标注不可靠 |
| W-PORT-C04 | 常用模板 | HTTP 80/443、SSH 22、Telnet 23、MQTT 1883、CoAP 5683 |
| W-PORT-C05 | 最大并发 | **WiFi ⚙·LAN** |
| W-PORT-C06 | 单端口超时 | ms |
| W-PORT-C07 | 扫描中 Stop | 按钮 |

### 6.2 结果状态

| 状态 ID | 状态 | 展示 |
| --- | --- | --- |
| W-PORT-R01 | open | 绿色 |
| W-PORT-R02 | closed | 灰色 |
| W-PORT-R03 | filtered | 黄色 |
| W-PORT-R04 | timeout | 橙色 |

每端口结果写入诊断 SessionLog（W-DIA-05）。

### 6.3 逐步流程

| 步 ID | 动作 | 结果 |
| --- | --- | --- |
| W-PORT-F01 | 选目标 + 端口范围 | 表单校验 |
| W-PORT-F02 | Start | 进度 N/M |
| W-PORT-F03 | 实时追加结果表 | 可 Sort |
| W-PORT-F04 | Stop / 完成 | 摘要 open 数 |
| W-PORT-F05 | 导出 | **WiFi ⚙·会话** |

---

## 7. Ping（W-DIA-01）

| 配置 ID | 配置 | 要求 |
| --- | --- | --- |
| W-PNG-C01 | 目标 | IP 或域名 |
| W-PNG-C02 | 次数 | 可配置 |
| W-PNG-C03 | 间隔 | ms |
| W-PNG-C04 | 超时 | ms |
| W-PNG-C05 | 包大小 | 可选（专家） |

| 结果 ID | 结果字段 |
| --- | --- |
| W-PNG-R01 | 每次：序号 / 成功失败 / RTT |
| W-PNG-R02 | 汇总：min / max / avg / 丢包率 |

**逐步**：诊断 → Ping → 填目标 → Start → C 栏 Timeline 追加 → Stop → 导出。

---

## 8. DNS（W-DIA-02）

| 功能 ID | 要求 |
| --- | --- |
| W-DNS-01 | 域名 → A / AAAA 基础解析 |
| W-DNS-02 | IPv4 / IPv6 查询选项 |
| W-DNS-03 | 默认网络或指定 NetHandle |
| W-DNS-04 | 自定义 DNS 规则 | 专家 · HarmonyOS 能力规划 |
| W-DNS-05 | 日志：请求、结果、耗时、错误 |

---

## 9. TraceRoute（W-DIA-03）

| 功能 ID | 要求 | API |
| --- | --- | --- |
| W-TRT-01 | 目标域名/IP | 输入 |
| W-TRT-02 | 超时 / 最大跳数 | 配置 |
| W-TRT-03 | 每跳：地址 / 耗时 / 错误 | 结果表 |
| W-TRT-04 | 进入诊断 SessionLog | W-DIA-05 |

**HarmonyOS**：Network Kit `queryTraceRoute`（PRD §8.3）。

---

## 10. Whois（W-DIA-04）

| 功能 ID | 要求 |
| --- | --- |
| W-WHO-01 | 查询公网 IP 或域名 |
| W-WHO-02 | 需互联网；明确说明 |
| W-WHO-03 | 失败分类：网络不可达 / 服务不可达 / 对象无效 |
| W-WHO-04 | **不**作为局域网设备识别主路径 |

实现：外部服务或协议（PRD §8.4）；非 HarmonyOS 本地 API。

---

## 11. 诊断 UI 与命令面板（W-DIA-05/06）

### 11.1 诊断列表 Segmented

```text
诊断
├── Ping
├── DNS
├── TraceRoute
└── Whois
```

C 栏：配置表单 + 输出 Timeline（逐步追加）+ 汇总卡。

### 11.2 命令收藏（W-DIA-06）

| 类型 | 收藏字段 | Panel |
| --- | --- | --- |
| Ping 预设 | 名称、目标、次数 | 一键执行 |
| DNS 预设 | 域名、记录类型 | 同上 |
| TraceRoute 预设 | 目标、最大跳 | 同上 |

编辑：**WiFi ⚙·命令与面板** → 诊断一键分组；运行时 C 工具栏「从收藏选择」。

---

## 12. 权限与降级（PRD 06 §7.2）

| 受限项 | UI | 行为 |
| --- | --- | --- |
| 无 GET_WIFI_INFO | Banner | 不展示 AP/当前 WiFi 详情 |
| 无 GET_WIFI_PEERS_MAC | Chip「受限」 | MAC/BSSID 随机或隐藏 |
| 主动扫描不可用 | 时间戳 | 缓存结果 + 最后更新 |
| ARP 不可用 | 说明 | LAN 用 Ping/TCP |
| 无 INTERNET | Banner | Whois/部分 DNS 不可用 |
| 定位相关 | Banner | 部分 WiFi 扫描 API |

---

## 13. 840vp 布局要点

| 栏 | 内容 |
| --- | --- |
| A | 模块 Nav · WiFi ● |
| B | LAN 主机列表 / 诊断历史目标；标题 ≤3：扫描、Filter、⚙ |
| C | 子网进度+表 / 诊断 Timeline；工具栏 Export |

**禁止**第四 Inspector；诊断大输出用 C 全高滚动。

---

## 14. 相关文档

| 文档 | 路径 |
| --- | --- |
| WiFi 逐步流程 | `.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` |
| 840vp 线框 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |
| 架构 LAN | `.projectark/5-架构设计/无线调试工具/wifi_network/02-Socket诊断LAN发现与端口扫描设计.md` |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` §7–§9 |
| 权限降级 | `.projectark/2-需求文档/无线调试工具/PRD/06-权限后台兼容与降级PRD.md` §7.2 |
| AndroidNetworkTools | [stevewalter/AndroidNetworkTools](https://github.com/stevewalter/AndroidNetworkTools) |
| 环境分析交叉 | [`01-WiFiAnalyzer环境分析功能清单.md`](01-WiFiAnalyzer环境分析功能清单.md) |
| 网络协议交叉 | [`02-网络协议调试功能清单.md`](02-网络协议调试功能清单.md) |

---

## 15. AndroidNetworkTools 能力对照（竞品/库级）

> **证据**：`.research/feature-inventory/README.md` 列出 `AndroidNetworkTools` · [stevewalter/AndroidNetworkTools](https://github.com/stevewalter/AndroidNetworkTools) · PRD §8–§9 · `12` §2.3–2.4  
> **说明**：库未 clone 至本地；以下以开源 API + PRD 完整规划映射 YoWire `W-LAN-*` / `W-DIA-*`。

### 15.1 库能力 × YoWire ID

| AndroidNetworkTools API | 能力 | YoWire ID | YoWire UI | PRD |
| --- | --- | --- | --- | --- |
| `Ping.ping()` / ICMP | 单主机 Ping | **W-DIA-01** | 诊断 → Ping → C Timeline | §8.1 |
| `DNSLookup` / `InetAddress` | A/AAAA 解析 | **W-DIA-02** | 诊断 → DNS | §8.2 |
| `TraceRoute` / tracepath | 逐跳路由 | **W-DIA-03** | 诊断 → TraceRoute | §8.3 · HarmonyOS Network Kit |
| `Whois` / 外部查询 | 公网 Whois | **W-DIA-04** | 诊断 → Whois | §8.4 |
| `SubnetDevices` / `Subnet` | 子网主机发现 | **W-LAN-01~04** | LAN → 扫描列表 | §9.1 |
| `PortScan` / TCP connect | TCP 端口扫描 | **W-LAN-07** | 端口扫描页 | §9.2 |
| UDP probe | UDP 不可靠探测 | **W-LAN-08** | 同页 UDP 选项 | §9.2 |
| `Subnet.from()` | CIDR 解析 | **W-LAN-02** | 手动 CIDR TextField | §9.1 |

**PacketSender 边界**：Subnet 工具仅 LAN 发现部分；**Ping/DNS/TraceRoute/Whois 为 PRD P0，PacketSender 无** [`22` §5]。

### 15.2 扫描方式优先级（W-SCAN-M-* 扩展）

| 方式 ID | 协议 | AndroidNetworkTools 典型实现 | HarmonyOS 降级 |
| --- | --- | --- | --- |
| W-SCAN-M01 | ICMP Echo | `Ping` 类 | 禁 Ping → Banner W-LAN-S04 |
| W-SCAN-M02 | TCP connect 80/443/22 | 子网扫描 fallback | W-LAN-03 备选 |
| W-SCAN-M03 | ARP | 平台 raw socket | 不可用则隐藏 [`06-权限PRD` §7.2] |
| W-SCAN-M04 | DNS reverse | 主机名列 | W-LAN-04 字段可选 |

---

## 16. W-LAN-* 功能 ID 扩展详表

| ID | 名称 | 配置项 | 输出字段 | 逐步 ID | ⚙ 设置 |
| --- | --- | --- | --- | --- | --- |
| **W-LAN-01** | 子网自动识别 | 读 LinkAddress | CIDR 芯片 | W-LAN-F02 | — |
| **W-LAN-02** | 手动 CIDR | TextField 校验 | — | W-LAN-F02 | — |
| **W-LAN-03** | 子网扫描 | Start/Stop/Cancel | IP 列表 | W-LAN-F03 | W-LAN-S01~03 |
| **W-LAN-04** | 设备列表字段 | — | IP, 主机名, MAC/OUI, RTT, 开放端口摘要 | W-LAN-F04 | — |
| **W-LAN-05** | 并发/频率限制 | maxConcurrent, timeout | 进度 N/M | W-LAN-F03 | W-LAN-S01~02 |
| **W-LAN-06** | 「本地诊断」Banner | 只读文案 | — | W-LAN-F01 | 关于 |
| **W-LAN-07** | TCP 端口扫描 | IP + 范围/模板 | open/closed/filtered | W-PORT-F01~05 | W-PORT-C05~06 |
| **W-LAN-08** | UDP 探测 | 端口列表 | 不可靠结果标注 | W-PORT-F02 | — |
| **W-LAN-09** | 常用端口模板 | HTTP/SSH/Telnet/MQTT/CoAP | 一键填范围 | W-PORT-C04 | ⚙·LAN |
| **W-LAN-10** | Stop/超时/并发 | 扫描中 Stop | 摘要卡 | W-PORT-F04 | W-LAN-S01~02 |
| **W-LAN-11** | 行 → Ping/Port | 上下文 Sheet | deep link | W-LAN-F05 | — |
| **W-LAN-12** | mDNS | 服务类型 | `_http._tcp` 等 | — | P2 预留 |
| **W-LAN-13** | SSDP | UDP 1900 | UPnP 设备 | — | P2 预留 |

### 16.1 子网扫描逐步（W-LAN-F01～F06 扩展）

| 步 ID | 用户动作 | UI | 后端 | SessionLog |
| --- | --- | --- | --- | --- |
| W-LAN-F01 | WiFi → 网络调试 → Segmented「LAN」 | 子网表单 + 摘要 | 读默认路由 | EVT 开始 |
| W-LAN-F02 | 自动识别 / 输入 `192.168.1.0/24` | CIDR Chip 校验 | Subnet 解析 | — |
| W-LAN-F03 | Start Scan | 进度条 + 取消 | 线程池 Ping/TCP 并发 | 每主机一行 |
| W-LAN-F04 | 列表刷新 | Sort/Filter IP | onDeviceFound 增量 | — |
| W-LAN-F05 | 点设备行 | Bottom Sheet | → W-DIA-01 Ping 或 W-LAN-07 Port | 继承目标 IP |
| W-LAN-F06 | 导出 | Share Sheet | TXT/CSV/JSON | **WiFi ⚙·会话** W-DIA-05 |

---

## 17. W-DIA-* 诊断功能 ID 扩展详表

### 17.1 Ping（W-DIA-01）

| 子 ID | 项 | 规格 | AndroidNetworkTools 对齐 |
| --- | --- | --- | --- |
| W-PNG-C01 | 目标 | IP 或域名 | `Ping.onAddress()` |
| W-PNG-C02 | 次数 | 默认 4，可配置 | loop count |
| W-PNG-C03 | 间隔 | ms | delayBetween |
| W-PNG-C04 | 超时 | ms | timeout |
| W-PNG-C05 | 包大小 | 可选专家 | payload size |
| W-PNG-R01 | 单次结果 | seq / success / RTT ms | 逐行 Timeline |
| W-PNG-R02 | 汇总 | min/max/avg/loss% | 汇总卡 |

### 17.2 DNS（W-DIA-02）

| 子 ID | 项 | 规格 |
| --- | --- | --- |
| W-DNS-01 | A 记录 | 域名 → IPv4 列表 |
| W-DNS-02 | AAAA 记录 | 域名 → IPv6 列表 |
| W-DNS-03 | 网络 | 默认网络 NetHandle |
| W-DNS-04 | 自定义 DNS | 专家；HarmonyOS 能力规划 |
| W-DNS-05 | 日志 | 请求/结果/耗时/错误码 |

### 17.3 TraceRoute（W-DIA-03）

| 子 ID | 项 | HarmonyOS |
| --- | --- | --- |
| W-TRT-01 | 目标 | 域名/IP 输入 |
| W-TRT-02 | maxHops / timeout | 配置 Sheet |
| W-TRT-03 | 每跳 | hop#, address, RTT, error |
| W-TRT-04 | SessionLog | W-DIA-05 | Network Kit `queryTraceRoute` |

### 17.4 Whois（W-DIA-04）

| 子 ID | 项 | 说明 |
| --- | --- | --- |
| W-WHO-01 | 查询对象 | 公网 IP 或域名 |
| W-WHO-02 | 需 INTERNET | Banner 说明 |
| W-WHO-03 | 失败分类 | 网络不可达 / 服务不可达 / 无效对象 |
| W-WHO-04 | 非 LAN 主路径 | 不与 W-LAN-04 MAC 识别混淆 |

### 17.5 端口扫描（W-LAN-07/08 与 W-DIA 交叉）

| 子 ID | TCP | UDP |
| --- | --- | --- |
| W-PORT-C01 | 目标 IP | 同左 |
| W-PORT-C02 | 1–65535 或模板 | 端口列表 |
| W-PORT-C03 | connect 超时 | probe 不可靠 |
| W-PORT-R01~04 | open/closed/filtered/timeout | UDP 标注「不可靠」 |

**AndroidNetworkTools PortScan 语义**：TCP `connect()` 成功 → open；超时 → filtered/timeout；拒绝 → closed。

---

## 18. 诊断 Segmented UI 与命令收藏（W-DIA-05/06 扩展）

```text
WiFi → 网络调试 → Segmented「诊断」
├── Ping      (W-DIA-01)
├── DNS       (W-DIA-02)
├── TraceRoute (W-DIA-03)
└── Whois     (W-DIA-04)
```

| 控件 | 行为 | 840vp |
| --- | --- | --- |
| B 栏 | 历史目标 / 收藏预设 | 选中 → C 预填 |
| C 栏 | 配置表单 + Timeline + 汇总 | 全高滚动 |
| 工具栏 Export | → **WiFi ⚙·会话** | W-DIA-05 |
| 「从收藏选择」 | Panel 一键 | W-DIA-06 |

**命令收藏字段（W-DIA-06）**：

| 类型 | 收藏字段 | Panel 行为 |
| --- | --- | --- |
| Ping 预设 | 名称、目标、次数、间隔 | 一键 Start |
| DNS 预设 | 域名、记录类型 A/AAAA | 同上 |
| TraceRoute 预设 | 目标、maxHops | 同上 |
| Whois 预设 | 目标 | 同上 |

---

## 19. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 深扩：§15 AndroidNetworkTools 对照、§16 W-LAN 详表、§17 W-DIA 详表、§18 UI 扩展 |
