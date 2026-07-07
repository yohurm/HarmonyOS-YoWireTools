# AndroidNetworkTools（LAN 诊断）全量功能清单（竞品/库深研）

> **状态**：深研草稿，未定稿  
> **定位**：YoWire WiFi·**LAN 发现**与**网络诊断**子模块的 **库级 + 样例 App 能力全集**；功能 ID 前缀 **ANT-***  
> **上游**：stealthcopter/AndroidNetworkTools（MIT，Java 库 + 样例 App `com.stealthcotper.networktools`）  
> **证据**：`.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` §2.3–2.4 · README · `MainActivity.java` · `library/` 源码树  
> **YoWire 产品化正文**：`03-WiFi模块/03-LAN与网络诊断功能清单.md`（W-LAN-* / W-DIA-*）  
> **仓库说明**：用户提及 `github.com/magnussengard/AndroidNetworkTools` **不存在（404）**；权威仓库为 **stealthcopter/AndroidNetworkTools**。`inventory 12` **未出现 fbnetworktools**；DNS/TraceRoute/Whois 缺口参照 **Fing / Network Analyzer 类** 与 YoWire PRD §8（见 §17）。

---

## 0. 文档统计

| 维度 | 数量 | 说明 | Evidence URL |
| --- | ---: | --- | --- |
| 库核心类 | 6+ | Ping · PortScan · SubnetDevices · WakeOnLan · ARPInfo · IPTools | https://github.com/stealthcopter/AndroidNetworkTools/tree/main/library |
| 样例 App 工具按钮 | 4 | Ping · WOL · Port Scan · Subnet | `MainActivity.java` · `content_main.xml` |
| ANT 工具 ID | 8 | 含库无项 DNS/TRT/Whois 标注 | 本文 §4–§11 |
| 库版本（JitPack） | 0.4.5.3 | README 示例依赖 | https://github.com/stealthcopter/AndroidNetworkTools/releases |
| YoWire 映射 | W-LAN-01～13 · W-DIA-01～06 | PRD §8–§9 | `03-WiFi/03` |
| inventory 12 交叉 | §2.3 LAN · §2.4 诊断 | L-1～L-4 逐步 | `.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` |

---

## 1. 产品形态（库 vs 样例 App）

| 形态 ID | 名称 | 说明 | 分发 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-PROD-01 | **AndroidNetworkTools 库** | Gradle/JitPack 依赖；无独立「工具 UI 规范」 | JitPack `com.github.stealthcopter:AndroidNetworkTools` | https://github.com/stealthcopter/AndroidNetworkTools/blob/main/readme.md |
| ANT-PROD-02 | **样例 App** | 单 Activity 演示四按钮 + ScrollView 文本输出 | Play `com.stealthcotper.networktools` · F-Droid | readme.md Sample app 节 |
| ANT-PROD-03 | 许可 | MIT | LICENSE | https://github.com/stealthcopter/AndroidNetworkTools/blob/main/LICENSE |
| ANT-PROD-04 | 权限 | `INTERNET`（必需） | AndroidManifest | readme.md §Add permission |
| ANT-PROD-05 | 深研边界 | **库 API + 样例 UI** 为主；非 Fing 级产品 UI | — | 本文 §3 |

### 1.1 与 YoWire / inventory 12 关系

| 来源 | 覆盖 | 未覆盖（YoWire PRD 补） | Evidence URL |
| --- | --- | --- | --- |
| AndroidNetworkTools 库 | Ping · Subnet · TCP/UDP Port · WOL · ARP | **DNS · TraceRoute · Whois** | readme.md |
| inventory 12 §2.3 | LAN CIDR → 扫描 → 设备 → Port | — | `12-v2` L-1～L-4 |
| inventory 12 §2.4 / PRD | — | Ping/DNS/TRT/Whois 诊断 Segmented | PRD §8 · `03-WiFi/03` |
| Fing / Network Analyzer 类 | 设备识别 · 端口 · 安全提示 | 非本文库证据；作 UX 参照 | `.projectark/2-需求文档/无线调试工具/02-WiFi需求了解.md` |
| fbnetworktools | **inventory 12 无条目** | 不伪造 URL | `12-v2` 全文检索 |

---

## 2. 样例 App 信息架构（ANT-IA-*）

```text
AndroidNetworkTools Sample App（MainActivity）
├── Toolbar
│   └── menu_main → action_github（打开仓库 URL）
├── TextInputLayout + editIpAddress（目标 IP / 预填本机 IPv4）
├── 按钮行 1：Ping | WOL | Port Scan
├── 按钮行 2：Subnet（子网发现）
└── ScrollView → resultText（追加文本日志，无结构化表）
```

| IA ID | 区域 | 控件 ID | 行为 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-IA-01 | 目标输入 | `editIpAddress` | 启动时 `IPTools.getLocalIPv4Address()` 预填 | `MainActivity.java` onCreate |
| ANT-IA-02 | Ping | `pingButton` | 后台 Thread → `doPing()` | 同上 |
| ANT-IA-03 | Wake-on-LAN | `wolButton` | → `doWakeOnLan()` | 同上 |
| ANT-IA-04 | Port Scan | `portScanButton` | → `doPortScan()` | 同上 |
| ANT-IA-05 | Subnet | `subnetDevicesButton` | → `findSubnetDevices()` | 同上 |
| ANT-IA-06 | 输出 | `resultText` + `scrollView` | `appendResultsText` 逐行；自动滚底 | 同上 |
| ANT-IA-07 | 并发 UX | 各 Button | 执行中 `setEnabled(false)` → 结束恢复 | 同上 |

**YoWire 对标**：样例 App 为 **最小演示**；YoWire 840vp **B 设备列表 + C Timeline**（doc 16 §3.2），非 ScrollView 纯文本。

---

## 3. 库模块结构（ANT-LIB-*）

| 库 ID | 类 / 包 | 能力摘要 | Evidence URL |
| --- | --- | --- | --- |
| ANT-LIB-01 | `Ping` + `ping.*` | ICMP 原生 ping 或 TCP:7 回退 | https://github.com/stealthcopter/AndroidNetworkTools/blob/main/library/src/main/java/com/stealthcopter/networktools/Ping.java |
| ANT-LIB-02 | `PortScan` + `portscanning.*` | TCP / UDP connect 扫描 | PortScan.java |
| ANT-LIB-03 | `SubnetDevices` + `subnet.Device` | 本子网 Ping 发现主机 | SubnetDevices.java |
| ANT-LIB-04 | `WakeOnLan` | UDP 魔术包 | WakeOnLan.java |
| ANT-LIB-05 | `ARPInfo` | `/proc/net/arp` · `ip neigh` MAC 解析 | ARPInfo.java |
| ANT-LIB-06 | `IPTools` | 本机 IPv4 枚举 · localhost/LAN 判定 | IPTools.java |
| ANT-LIB-07 | `MACTools` | MAC 格式工具 | MACToolsTest.java |
| ANT-LIB-08 | **无** DNSLookup 类 | — | 仓库 tree 检索 |
| ANT-LIB-09 | **无** TraceRoute 类 | — | 同上 |
| ANT-LIB-10 | **无** Whois 类 | — | 同上 |

---

## 4. ANT-PING — Ping（ICMP / TCP 回退）

### 4.1 库 API（ANT-PING-API-*）

| API ID | 方法 / 链式调用 | 参数 | 返回 / 回调 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-PING-API-01 | `Ping.onAddress(String)` | IP 或主机名 | Builder | Ping.java |
| ANT-PING-API-02 | `setTimeOutMillis(int)` | 超时 ms | Builder | readme.md §Ping |
| ANT-PING-API-03 | `setTimes(int)` | 异步 ping 次数 | Builder | 同上 |
| ANT-PING-API-04 | `doPing()` | — | `PingResult` 同步 | 同上 |
| ANT-PING-API-05 | `doPing(PingListener)` | — | 逐次 `onResult` + `onFinished(PingStats)` | 同上 |
| ANT-PING-API-06 | 回退策略 | 无 `/system/bin/ping` | **TCP port 7** echo；发现设备数显著减少 | readme.md Note |

### 4.2 PingResult / PingStats 字段

| 字段 ID | 字段 | 说明 | Evidence URL |
| --- | --- | --- | --- |
| ANT-PING-F-01 | `address` | InetAddress | PingResult.java |
| ANT-PING-F-02 | `isReachable` | 是否可达 | 同上 |
| ANT-PING-F-03 | `timeTaken` | RTT ms | 同上 |
| ANT-PING-F-04 | `PingStats.noPings` | 总次数 | PingStats.java |
| ANT-PING-F-05 | `packetsLost` | 丢包 | 同上 |
| ANT-PING-F-06 | min/avg/max | 统计 | MainActivity `onFinished` 输出 |

### 4.3 样例 App UI 流程（ANT-PING-UI-*）

| 步 ID | 用户动作 | UI | 库调用 | 输出示例 | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| ANT-PING-UI-01 | 输入/确认 IP | `editIpAddress` | — | — | MainActivity |
| ANT-PING-UI-02 | 点 **Ping** | 禁用按钮 | 同步 `doPing()` 一次 | Address · HostName · RTT | doPing() |
| ANT-PING-UI-03 | 继续 | — | 异步 `setTimes(5).doPing(listener)` | 每行 RTT 或 timeout | 同上 |
| ANT-PING-UI-04 | 完成 | 恢复按钮 | `onFinished(PingStats)` | Pings/lost · Min/Avg/Max | 同上 |
| ANT-PING-UI-05 | 空 IP | Toast 文本 | — | "Invalid Ip Address" | 同上 |

### 4.4 YoWire 映射

| ANT 簇 | YoWire ID | 子 ID | Evidence URL |
| --- | --- | --- | --- |
| ANT-PING-* | **W-DIA-01** | W-PNG-C01～C05 · W-PNG-R01/R02 | `03-WiFi/03` §17.1 |

---

## 5. ANT-DNS — DNS Lookup（库无 · PRD 扩展）

> **库状态**：AndroidNetworkTools **无 DNS 专用 API**；`Device.hostname` / `InetAddress.getCanonicalHostName()` 仅为 **反向解析副作用**，非 DNS 工具。YoWire **W-DIA-02** 参照 Fing/Network Analyzer 类 + PRD §8.2。

| ID | 项 | AndroidNetworkTools | YoWire W-DIA-02 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-DNS-01 | A 记录查询 | **✗** | W-DNS-01 | PRD §8.2 |
| ANT-DNS-02 | AAAA 记录 | **✗** | W-DNS-02 | 同上 |
| ANT-DNS-03 | 自定义 DNS 服务器 | **✗** | W-DNS-04 专家 | 同上 |
| ANT-DNS-04 | 样例 App UI | **✗ 无入口** | 诊断 Segmented「DNS」 | inventory 12 §2.4 |
| ANT-DNS-05 | 间接：子网 hostname | `Device.hostname` | W-LAN-04 字段可选 | Device.java |

**inventory 12 对照**：§2.4 将 Ping/DNS/TraceRoute 列为 PRD 完整规划，**非 PacketSender / 非 ANT 库既有**。

| ANT-DNS ID | YoWire ID | 分级 | Evidence URL |
| --- | --- | --- | --- |
| ANT-DNS-01～05 | **W-DIA-02** | P0 YoWire PRD | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` §8.2 |

---

## 6. ANT-TRT — TraceRoute（库无 · PRD 扩展）

| ID | 项 | AndroidNetworkTools | YoWire W-DIA-03 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-TRT-01 | 逐跳路由 | **✗ 库无** | W-TRT-01～04 | PRD §8.3 |
| ANT-TRT-02 | maxHops / timeout | **✗** | W-TRT-02 | 同上 |
| ANT-TRT-03 | 样例 App UI | **✗** | 诊断 → TraceRoute → C Timeline | inventory 12 §2.4 |
| ANT-TRT-04 | HarmonyOS 实现参照 | — | Network Kit `queryTraceRoute` | `03-WiFi/03` §17.3 |

**第三方参照**（非 ANT 证据，仅供 YoWire 平台验证）：icmpenguin / TraceMeister 等 Android 库提供 Traceroute — **不得**记为 ANT 能力。

| ANT-TRT ID | YoWire ID | 分级 | Evidence URL |
| --- | --- | --- | --- |
| ANT-TRT-01～04 | **W-DIA-03** | P0 YoWire PRD | PRD §8.3 · `22` V-WF-019 |

---

## 7. ANT-WHO — Whois（库无 · PRD 扩展）

| ID | 项 | AndroidNetworkTools | YoWire W-DIA-04 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-WHO-01 | 公网 Whois 查询 | **✗ 库无** | W-WHO-01～04 | PRD §8.4 |
| ANT-WHO-02 | 需 INTERNET | ✓ 库需 INTERNET | Banner 说明 | readme.md permission |
| ANT-WHO-03 | 样例 App UI | **✗** | 诊断 Segmented「Whois」 | inventory 12 §2.4 |
| ANT-WHO-04 | 与 LAN MAC 区分 | ARP 非 Whois | W-WHO-04 文案 | `03-WiFi/03` §17.4 |

| ANT-WHO ID | YoWire ID | 分级 | Evidence URL |
| --- | --- | --- | --- |
| ANT-WHO-01～04 | **W-DIA-04** | P0 YoWire PRD | PRD §8.4 · `22` V-WF-020 |

---

## 8. ANT-WOL — Wake-on-LAN

### 8.1 库 API

| API ID | 方法 | 参数 | 行为 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-WOL-API-01 | `WakeOnLan.sendWakeOnLan(ip, mac)` | IP + MAC `01:23:45:67:89:ab` | UDP 魔术包 | readme.md §Wake-On-Lan |
| ANT-WOL-API-02 | MAC 来源 | 样例用 `ARPInfo.getMACFromIPAddress` | ARP 缓存缺失则失败 | MainActivity doWakeOnLan |

### 8.2 样例 App UI 流程

| 步 ID | 动作 | 输出 | Evidence URL |
| --- | --- | --- | --- |
| ANT-WOL-UI-01 | 输入目标 IP | — | MainActivity |
| ANT-WOL-UI-02 | 点 **WOL** | 查 ARP MAC | 同上 |
| ANT-WOL-UI-03 | MAC 为空 | 文案：无法从 ARP 获取 | 同上 |
| ANT-WOL-UI-04 | 成功 | "WOL Packet sent" | 同上 |
| ANT-WOL-UI-05 | 失败 | IOException message | 同上 |

### 8.3 YoWire 映射

| ANT 簇 | YoWire ID | 分级 | Evidence URL |
| --- | --- | --- | --- |
| ANT-WOL-* | **W-LAN-11** 扩展 / PRD LAN 专家 | P2 架构预留 | PRD §9 · PacketSender WOL P3 不做 |

---

## 9. ANT-SUB — Subnet Discovery（子网设备发现）

### 9.1 库 API（ANT-SUB-API-*）

| API ID | 方法 | 默认 | 说明 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-SUB-API-01 | `SubnetDevices.fromLocalAddress()` | — | 当前设备所在子网 | readme.md §Subnet Devices |
| ANT-SUB-API-02 | `findDevices(OnSubnetDeviceFound)` | 异步 | 增量 `onDeviceFound` + `onFinished` | 同上 |
| ANT-SUB-API-03 | `setTimeOutMillis` | **2500** | 单主机 ping 超时 | 同上 |
| ANT-SUB-API-04 | `setNoThreads` | **255** | 并发线程 | 同上 |
| ANT-SUB-API-05 | `cancel()` | — | 中断扫描 | MainActivity 注释 |

### 9.2 Device 输出字段

| 字段 ID | 字段 | 来源 | YoWire W-LAN-04 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-SUB-F-01 | `ip` | InetAddress | IP 列 | Device.java |
| ANT-SUB-F-02 | `hostname` | `getCanonicalHostName()` | 主机名列 | 同上 |
| ANT-SUB-F-03 | `mac` | 扫描后填充（若可得） | MAC/OUI | 同上 |
| ANT-SUB-F-04 | `time` | RTT float | 响应 ms | 同上 |

### 9.3 样例 App UI 流程（inventory 12 L-1～L-2 对齐）

| 步 ID | 用户动作 | 样例 UI | 库行为 | inventory 12 | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| ANT-SUB-UI-01 | 点 **Subnet** | 无需 CIDR 输入 | `fromLocalAddress()` | L-1 自动子网 | MainActivity |
| ANT-SUB-UI-02 | 扫描中 | 按钮禁用 | 并发 ping 子网 | L-2 Start Scan | 同上 |
| ANT-SUB-UI-03 | 每发现主机 | 追加行 | `onDeviceFound` | L-2 进度+列表 | 同上 |
| ANT-SUB-UI-04 | 完成 | 恢复按钮 | `onFinished` 数量+耗时 | L-2 | 同上 |
| ANT-SUB-UI-05 | **无** CIDR 手动 | — | 库支持 `fromIPAddress` 等扩展 | L-1 TextField | SubnetDevices.java |

### 9.4 YoWire 映射

| ANT 簇 | YoWire ID | 说明 | Evidence URL |
| --- | --- | --- | --- |
| ANT-SUB-API-01 | **W-LAN-01** | 自动识别子网 | `03-WiFi/03` §16 |
| 手动 CIDR | **W-LAN-02** | 样例无 UI；库可扩展 | inventory 12 L-1 |
| ANT-SUB-API-02～05 | **W-LAN-03～05** | 扫描/并发/超时 | 同上 |
| ANT-SUB-F-* | **W-LAN-04** | 设备列表字段 | Device.java |
| 行 → Ping/Port | **W-LAN-11** | 样例无；YoWire 上下文 Sheet | inventory 12 L-3 |

---

## 10. ANT-TCP / ANT-UDP — Port Scan

### 10.1 库 API（ANT-PORT-API-*）

| API ID | 方法 | 默认策略 | Evidence URL |
| --- | --- | --- | --- |
| ANT-PORT-API-01 | `PortScan.onAddress(String)` | 自动 localhost/LAN/remote 超时与线程 | PortScan.java |
| ANT-PORT-API-02 | `setMethodTCP()` / `setMethodUDP()` | TCP connect / UDP probe | readme.md §Port Scanning |
| ANT-PORT-API-03 | `setPort(int)` / `setPortsAll()` | 单端口 / 全端口 | PortScan.java |
| ANT-PORT-API-04 | `setTimeOutMillis` | localhost 25 · LAN 1000 · remote 2500 ms 默认 | PortScan.java 常量 |
| ANT-PORT-API-05 | `setNoThreads` | localhost 7 · LAN 50 | 同上 |
| ANT-PORT-API-06 | `doScan()` | 同步 `ArrayList<Integer>` open ports | readme.md |
| ANT-PORT-API-07 | `doScan(PortListener)` | 异步 `onResult(port, open)` + `onFinished` | 同上 |
| ANT-PORT-API-08 | `cancel()` | 中断 | MainActivity 注释 |

### 10.2 端口状态语义

| 状态 | TCP 判定 | UDP 判定 | YoWire W-PORT-R* | Evidence URL |
| --- | --- | --- | --- | --- |
| open | `connect()` 成功 | 收到响应（不可靠） | W-PORT-R01 | `03-WiFi/03` §17.5 |
| closed | 连接拒绝 | — | W-PORT-R03 | 同上 |
| filtered/timeout | 超时 | 超时 | W-PORT-R02/R04 | PortScan.java |

### 10.3 样例 App UI 流程

| 步 ID | 动作 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| ANT-PORT-UI-01 | 输入 IP | `editIpAddress` | MainActivity |
| ANT-PORT-UI-02 | 点 **Port Scan** | 先同步 TCP port **21** | doPortScan() |
| ANT-PORT-UI-03 | 再异步 | `setPortsAll().setMethodTCP()` | 逐行 "Open: {port}" |
| ANT-PORT-UI-04 | 完成 | 开放数 + 耗时秒 | onFinished |
| ANT-PORT-UI-05 | UDP 演示 | readme 示例 `setMethodUDP().setPort(21)` | **样例 App 未绑 UDP 按钮** | readme.md |

### 10.4 YoWire 映射

| ANT 簇 | YoWire ID | Evidence URL |
| --- | --- | --- |
| ANT-PORT TCP | **W-LAN-07** | `03-WiFi/03` §6 |
| ANT-PORT UDP | **W-LAN-08** | 同上 |
| 模板 HTTP/SSH/… | **W-LAN-09** | 样例无；YoWire ⚙·LAN |
| Stop/超时/并发 | **W-LAN-10** | W-LAN-S01～02 |

---

## 11. ANT-ARP / ANT-IP — 辅助 API

| ID | 类.方法 | 能力 | 样例使用 | YoWire | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| ANT-ARP-01 | `ARPInfo.getMACFromIPAddress` | ARP 缓存 → MAC | WOL 前置 | W-LAN-04 MAC | ARPInfo.java |
| ANT-ARP-02 | `ARPInfo.getIPAddressFromMAC` | 反查 IP | 调试输出 | W-LAN-04 | 同上 |
| ANT-ARP-03 | `getAllIPAddressesInARPCache` | 缓存 IP 列表 | — | W-SCAN-M03 | 同上 |
| ANT-IP-01 | `IPTools.getLocalIPv4Address` | 本机首个 IPv4 | 预填 EditText | **W-LAN-01** | IPTools.java |
| ANT-IP-02 | `IPTools.isIPv4Address` 等 | 地址校验 | — | W-LAN-02 CIDR 校验辅助 | 同上 |
| ANT-IP-03 | `isIpAddressLocalNetwork` | site-local 判定 | PortScan 默认超时 | W-LAN-05 | 同上 |

---

## 12. 样例 App 逐步流程总表（ANT-FLOW-*）

| 流程 ID | 工具 | 逐步摘要 | 对应 inventory 12 | Evidence URL |
| --- | --- | --- | --- | --- |
| **ANT-FLOW-01** | Ping | 输入 IP → Ping → 同步 1 次 + 异步 5 次 → 统计 | §2.4 诊断 Ping | MainActivity doPing |
| **ANT-FLOW-02** | WOL | IP → ARP 取 MAC → sendWakeOnLan | — | doWakeOnLan |
| **ANT-FLOW-03** | Port Scan | IP → sync port 21 → async all TCP → 列表 | L-4 Port Scan | doPortScan |
| **ANT-FLOW-04** | Subnet | Subnet 按钮 → fromLocalAddress 全子网 | §2.3 L-1～L-2 | findSubnetDevices |
| **ANT-FLOW-05** | GitHub | Toolbar → 浏览器打开仓库 | — | onOptionsItemSelected |

**inventory 12 §2.3 LAN 逐步（YoWire 目标，样例仅部分覆盖）**：

| 步 | inventory 12 | 样例 App 覆盖 | YoWire W-LAN-F | Evidence URL |
| --- | --- | --- | --- | --- |
| L-1 | 输入 CIDR | **仅自动 local** | W-LAN-F02 | `12-v2` §2.3 |
| L-2 | Start Scan 进度+列表 | Subnet 按钮+文本 | W-LAN-F03/F04 | 同上 |
| L-3 | 点设备 → Ping/Port | **无** | W-LAN-F05 | 同上 |
| L-4 | Port 范围结果表 | Port Scan 全 TCP | W-PORT-F01～05 | 同上 |

---

## 13. 权限 · 限制 · 平台差异（ANT-LIM-*）

| ID | 限制 | 库/README 说明 | YoWire 降级 | Evidence URL |
| --- | --- | --- | --- | --- |
| ANT-LIM-01 | 无 native ping | 回退 TCP:7；发现率低 | W-LAN-S04 Banner | readme.md Ping Note |
| ANT-LIM-02 | 无 raw socket ICMP | 非 root 标准 Android | HarmonyOS Network Kit | readme.md |
| ANT-LIM-03 | ARP 读 `/proc/net/arp` | 部分设备/ROM 受限 | W-SCAN-M03 隐藏 | ARPInfo.java |
| ANT-LIM-04 | UDP 扫描不可靠 | readme 未强调；YoWire 标注 | W-LAN-08 | `03-WiFi/03` |
| ANT-LIM-05 | 仅 INTERNET 权限 | 无 ACCESS_WIFI_STATE 等 | YoWire 读 LinkAddress | readme.md |
| ANT-LIM-06 | 子网扫描禁 Ping 环境 | 主机不应答 | TCP 80/443 fallback W-SCAN-M02 | `03-WiFi/03` §15.2 |

---

## 14. W-LAN-* 完整映射（ANT → YoWire）

| YoWire ID | 名称 | ANT 对照 | 样例 App | 分级 | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| **W-LAN-01** | 子网自动识别 | `SubnetDevices.fromLocalAddress` · `IPTools.getLocalIPv4` | ✓ 预填+Subnet | P1 | `03-WiFi/03` §16 |
| **W-LAN-02** | 手动 CIDR | 库可 `fromIPAddress`；样例无 | ✗ | P1 | inventory 12 L-1 |
| **W-LAN-03** | 子网扫描 | `findDevices` | ✓ Subnet 按钮 | P1 | SubnetDevices.java |
| **W-LAN-04** | 设备列表字段 | Device ip/hostname/mac/time | 文本行 | P1 | Device.java |
| **W-LAN-05** | 并发/超时 | setNoThreads 255 · timeout 2500 | 不可配 | P1 | readme.md |
| **W-LAN-06** | 「本地诊断」Banner | 样例无 | ✗ | P0 | PRD §9.1 |
| **W-LAN-07** | TCP 端口扫描 | `PortScan` TCP | ✓ | P1 | PortScan.java |
| **W-LAN-08** | UDP 探测 | `setMethodUDP` | readme 仅 | P1 | readme.md |
| **W-LAN-09** | 常用端口模板 | **无** | ✗ | P1 | YoWire ⚙ |
| **W-LAN-10** | Stop/超时/并发 | `cancel()` · setters | 不可配 | P1 | PortScan.java |
| **W-LAN-11** | 行 → Ping/Port | **无** | ✗ | P1 | inventory 12 L-3 |
| **W-LAN-12** | mDNS | **库无** | ✗ | P2 | PRD §11 |
| **W-LAN-13** | SSDP | **库无** | ✗ | P2 | PRD §11 |

---

## 15. W-DIA-* 完整映射（ANT → YoWire）

| YoWire ID | 名称 | ANT 库 | 样例 App | 分级 | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| **W-DIA-01** | Ping | **✓** `Ping` | ✓ 按钮 | P0 | readme.md §Ping |
| **W-DIA-02** | DNS | **✗** | ✗ | P0 PRD | PRD §8.2 · §5 ANT-DNS |
| **W-DIA-03** | TraceRoute | **✗** | ✗ | P0 PRD | PRD §8.3 · §6 ANT-TRT |
| **W-DIA-04** | Whois | **✗** | ✗ | P0 PRD | PRD §8.4 · §7 ANT-WHO |
| **W-DIA-05** | 诊断 SessionLog 导出 | **✗** 纯 TextView | ✗ | P1 | `06-统一后端` SL-* |
| **W-DIA-06** | 命令收藏/Panel | **✗** | ✗ | P1 | WiFi ⚙·命令与面板 |

### 15.1 诊断 Segmented UI（YoWire 目标 · 样例无）

```text
WiFi → 网络调试 → Segmented「诊断」
├── Ping      (ANT-PING ✓)
├── DNS       (ANT-DNS ✗ → PRD)
├── TraceRoute (ANT-TRT ✗ → PRD)
└── Whois     (ANT-WHO ✗ → PRD)
```

| 控件 | ANT 样例 | YoWire 840vp | Evidence URL |
| --- | --- | --- | --- |
| 目标输入 | 单 EditText | B 历史 + C 表单 | `03-WiFi/03` §18 |
| 输出 | ScrollView 文本 | C Timeline + 汇总卡 | 同上 |
| Export | 无 | WiFi ⚙·会话 W-DIA-05 | 同上 |

---

## 16. PacketSender / Fing 边界（inventory 12 交叉）

| 能力 | AndroidNetworkTools | PacketSender | Fing 类（UX 参照） | YoWire | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| Subnet/LAN 扫描 | **✓ 库** | Subnet 工具（桌面） | **✓** 高频 | W-LAN-* | `12-v2` §2.3 · `22` §5 |
| Ping | **✓** | ✗ 主路径 | **✓** | W-DIA-01 | readme.md |
| DNS | **✗** | ✗ | **✓** | W-DIA-02 PRD | inventory 12 §2.4 |
| TraceRoute | **✗** | ✗ | 部分 | W-DIA-03 PRD | 同上 |
| Whois | **✗** | ✗ | 部分 | W-DIA-04 PRD | 同上 |
| TCP/UDP Socket | **✗** | **✓** | ✗ | WF-NET-* | `06-PacketSender` |

**fbnetworktools**：`.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` **全文无此关键字**；若指 **Fing** 或 **FB 系 Network Tools**，见 `02-WiFi需求了解.md` Fing 行 — **不得**冒充 ANT 库证据。

---

## 17. YoWire 相对 ANT 增量摘要

| 竞品/库无 | YoWire 要求 | ID | Evidence URL |
| --- | --- | --- | --- |
| DNS / TRT / Whois API | PRD P0 完整诊断 | W-DIA-02～04 | PRD §8 |
| 结构化设备列表 UI | B 栏 Sort/Filter | W-LAN-F04 | doc 16 |
| SessionLog 三格式 | TXT/CSV/JSON | W-DIA-05 · SL-* | `06-统一后端` |
| 命令 Panel 预设 | Ping/DNS/TRT/Whois 一键 | W-DIA-06 | `03-WiFi/03` §18 |
| mDNS / SSDP | 架构预留 | W-LAN-12/13 | PRD §11 |
| 840vp 三分栏 | B LAN 列表 \| C 输出 | WF-NET-19 类 | doc 16 §3.2 |

---

## 18. 联网证据索引（E-ANT-*）

| Evidence ID | URL | 本文章节 |
| --- | --- | --- |
| E-ANT-001 | https://github.com/stealthcopter/AndroidNetworkTools | §1–§3 |
| E-ANT-002 | https://github.com/stealthcopter/AndroidNetworkTools/blob/main/readme.md | §4–§11 API |
| E-ANT-003 | https://github.com/stealthcopter/AndroidNetworkTools/blob/main/app/src/main/java/com/stealthcotper/networktools/MainActivity.java | §2 · §12 样例流程 |
| E-ANT-004 | https://github.com/stealthcopter/AndroidNetworkTools/blob/main/app/src/main/res/layout/content_main.xml | §2 IA |
| E-ANT-005 | https://play.google.com/store/apps/details?id=com.stealthcotper.networktools | §1.1 样例 App |
| E-ANT-006 | https://f-droid.org/packages/com.stealthcotper.networktools/ | §1.1 F-Droid |
| E-ANT-007 | https://github.com/stealthcopter/AndroidNetworkTools/releases | §0 版本 |
| E-ANT-008 | https://mvnrepository.com/artifact/com.github.stealthcopter/AndroidNetworkTools | JitPack 依赖 |
| E-ANT-GAP-01 | —（库无 DNS） | §5 · W-DIA-02 |
| E-ANT-GAP-02 | —（库无 TraceRoute） | §6 · W-DIA-03 |
| E-ANT-GAP-03 | —（库无 Whois） | §7 · W-DIA-04 |
| E-ANT-INV-12 | `.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` | §12 · §16 |
| E-ANT-PRD | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` §8–§9 | §14–§15 |
| E-ANT-FING | https://www.fing.com/products/fing-app | §16 UX 参照（非 ANT API） |

---

## 19. 相关文档

| 文档 | 路径 |
| --- | --- |
| YoWire 产品化清单 | `03-WiFi模块/03-LAN与网络诊断功能清单.md` |
| WiFi 逐步 inventory 12 | `.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` |
| 840vp LAN 线框 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |
| 架构 LAN 设计 | `.projectark/5-架构设计/无线调试工具/wifi_network/02-Socket诊断LAN发现与端口扫描设计.md` |
| 环境分析交叉 | `03-WiFi模块/01-WiFiAnalyzer环境分析功能清单.md` |
| 网络协议交叉 | `03-WiFi模块/02-网络协议调试功能清单.md` |
| 竞品 WiFiAnalyzer | `09-竞品APP功能清单/04-WiFiAnalyzer-Android-全量功能清单.md` |
| 差距矩阵 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` |

---

## 20. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初版：ANT-* 八工具 · 样例 MainActivity 流程 · W-LAN/W-DIA 映射 · DNS/TRT/Whois 库无标注 |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v1 |
| 功能 ID 前缀 | ANT-* |
| 权威仓库 | stealthcopter/AndroidNetworkTools（非 magnussengard） |
| 行数目标 | 350+ |
| 最后更新 | 2026-07-03 |
