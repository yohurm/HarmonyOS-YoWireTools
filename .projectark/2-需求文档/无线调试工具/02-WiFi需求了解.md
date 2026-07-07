# HarmonyOS 无线调试工具 - WiFi 需求了解

> 当前文档处于需求了解阶段，不是 PRD。WiFi 模块不只等同于“查看附近 WiFi”，它在主流工具中通常同时承担 WiFi 环境分析、局域网诊断、Socket/报文调试、网络连通性排查等角色。

## 1. 范围

WiFi 调试工具需要拆成四类能力理解：

| 分类 | 面向对象 | 典型功能 | 用户目标 |
| --- | --- | --- | --- |
| WiFi 环境分析 | 周边 AP、信道、频段、信号、安全类型 | 扫描、排序、信道图、时间图、导出 | 分析无线环境、选信道、定位干扰 |
| 设备与局域网发现 | 同网段设备、网关、DNS、MAC/OUI | Ping、ARP、Subnet scan、端口扫描 | 找设备、判断设备是否在线 |
| Socket/报文调试 | TCP、UDP、TLS、HTTP、组播 | Client/Server、发送/接收、日志、宏 | 调试设备协议、网关协议、局域网服务 |
| 网络状态诊断 | 当前网络、路由、代理、DNS、连接质量 | 网络类型、IP、DNS、代理、质量变化 | 判断当前手机网络是否可用、为何不可用 |

HarmonyOS 的 WLAN 能力和 Network Kit 能力需要组合使用：WLAN 负责 WiFi 状态与扫描，Network Kit 负责 TCP/UDP/TLS/组播等网络通信。

## 2. 调研来源

### 2.1 HarmonyOS 官方文档与样例

| 来源 | 用途 |
| --- | --- |
| HarmonyOS WLAN 服务开发概述 | 确认 STA、P2P、AP/热点模式范围 |
| HarmonyOS Wi-Fi 扫描开发指南 | 确认扫描信息、权限、扫描节流、系统约束 |
| HarmonyOS `ohos.wifiManager` API | 确认 WiFi 状态、扫描、ScanInfo、连接信息、频段、标准、安全类型 |
| HarmonyOS Socket 访问网络 | 确认 TCP、UDP、Multicast、TLS、服务端/客户端 |
| GitCode HarmonyOS network-query | 确认网络查询、诊断、WLAN 定位、WiFi 列表、网络状态监听的实际样例 |

### 2.2 Android/iOS 主流工具与开源源码

| 工具/项目 | 平台 | 重点功能 |
| --- | --- | --- |
| WiFiAnalyzer | Android 开源 | AP 列表、信道图、时间图、信道评分、过滤、导出、OUI |
| Fing | Android/iOS | 局域网设备发现、设备识别、端口/服务、网络安全提示 |
| Ubiquiti WiFiman | Android/iOS | WiFi 分析、测速、设备发现、信号漫游/覆盖分析 |
| Network Analyzer | Android/iOS | Ping、Traceroute、DNS、Whois、端口扫描、LAN 扫描 |
| AndroidNetworkTools | Android 开源 | Ping、ARP、Subnet、Port Scan、Wake-on-LAN |
| Packet Sender | 桌面/移动生态参考 | TCP、UDP、SSL、HTTP、服务器监听、面板、宏、日志 |

## 3. 主流 WiFi/网络调试 APP 功能点拆解

### 3.1 WiFi 环境扫描与 AP 分析

WiFiAnalyzer 类工具的核心是“让用户看懂无线环境”，不是简单列出 SSID。

| 功能点 | 说明 | 需求价值 |
| --- | --- | --- |
| AP 列表 | 展示 SSID、BSSID、RSSI、安全类型、频段、信道 | 基础入口 |
| 当前连接网络 | 单独突出当前连接 SSID/BSSID/IP/网关 | 判断当前调试上下文 |
| 信道显示 | 2.4GHz/5GHz/6GHz/60GHz 信道 | 分析拥塞和干扰 |
| 信道图 | 按信道绘制信号强度 | 选信道、看重叠 |
| 时间图 | 持续观察某 AP RSSI 变化 | 判断距离、稳定性、漫游 |
| 频段过滤 | 2.4G/5G/6G/60G | 大量 AP 环境下可用 |
| 安全类型过滤 | Open/WEP/WPA/WPA2/WPA3/OWE/WAPI/EAP 等 | 网络类型判断 |
| SSID/BSSID 搜索 | 过滤目标 AP | 实验室/工厂必备 |
| 信号强度过滤 | 隐藏弱信号 | 聚焦目标环境 |
| 厂商/OUI 查询 | 根据 BSSID 前缀识别厂商 | 设备定位 |
| 信道评分 | 给出推荐信道 | 专业增强 |
| 导出 AP 列表 | CSV/JSON/文本 | 测试报告和问题交付 |
| 扫描暂停/恢复 | 防止列表跳动 | 用户读取数据时必要 |

HarmonyOS 能力核对：

- `ScanInfo` 可提供 SSID、BSSID、RSSI、安全能力、频段、频率、信道宽度、时间戳、WiFi Category、HiLink 等信息。
- 支持 WiFi 6/6+/7/7+ 等 category 标识，标准枚举覆盖 802.11 a/b/g/n/ac/ax/ad。
- 支持 2G、5G、6G、60G 频段枚举。
- 获取真实 BSSID/MAC 类信息涉及 `GET_WIFI_PEERS_MAC` 或定位权限组合，普通应用权限边界要重点确认。
- 主动扫描接口存在版本和权限差异，且系统有扫描节流。产品不能承诺“实时强制刷新所有 WiFi”。

### 3.2 WiFi 扫描限制与用户体验

Android WiFiAnalyzer 和 HarmonyOS 官方文档都说明：WiFi 扫描不是应用可以无限调用的实时能力。

| 限制 | 影响 | 产品处理 |
| --- | --- | --- |
| 扫描结果可能来自系统缓存 | 列表不是绝对实时 | 显示最后更新时间 |
| 前台扫描频率受限 | 连续点击刷新可能无新结果 | 显示节流提示 |
| 连接中或高温可能阻止扫描 | 用户看到空列表或旧数据 | 给出原因解释 |
| 权限不足时结果受限 | BSSID/MAC 或列表不可用 | 权限说明和降级显示 |
| WiFi 关闭 | 无法扫描 | 引导用户打开 WiFi |

GitCode network-query 样例也体现了类似边界：WiFi 列表依赖系统扫描，结果可能延迟或缓存，必要时引导用户进入系统设置刷新。

### 3.3 当前网络状态与诊断

专业网络工具通常会先回答“当前网络到底是什么状态”。

| 功能点 | 说明 |
| --- | --- |
| 当前网络类型 | WiFi、蜂窝、以太网、VPN、蓝牙等 |
| 当前 WiFi 信息 | SSID、BSSID、RSSI、频段、IP、网关、DNS |
| 网络可用性 | 是否有默认网络、是否可访问互联网 |
| 网络能力 | 是否受限、是否 Portal、是否 VPN/代理 |
| 代理信息 | 当前代理 host/port |
| DNS 信息 | DNS 服务器列表 |
| IP 信息 | IPv4/IPv6、本机地址、子网 |
| 网络变化监听 | 连接/断开/质量变化/默认网络切换 |
| Portal 提示 | 需要认证时给出明确提示 |

HarmonyOS network-query 样例已经覆盖当前网络类型、网络状态、WiFi 信号、MAC、代理、IP、DNS、Portal 等诊断信息，可以作为需求理解的参考。

### 3.4 局域网设备发现

Fing、WiFiman、Network Analyzer、AndroidNetworkTools 都把 LAN 扫描作为高频能力。

| 功能点 | 说明 | 需求价值 |
| --- | --- | --- |
| 子网识别 | 根据当前 IP/掩码推断网段 | 自动化入口 |
| Ping 扫描 | 扫描同网段在线设备 | 找设备 |
| ARP 读取 | IP/MAC 对应关系 | 设备识别 |
| 设备命名 | 用户给设备起别名 | 工厂环境定位 |
| OUI 厂商识别 | MAC 前缀识别厂商 | 判断设备类型 |
| 端口扫描 | 扫描 TCP/UDP 开放端口 | 判断服务是否启动 |
| 服务识别 | HTTP、SSH、Telnet、MQTT 等 | 设备协议定位 |
| Wake-on-LAN | 通过 MAC 唤醒设备 | 网络维护工具能力 |
| 扫描历史 | 保存上次在线状态 | 对比设备变化 |

HarmonyOS 可行性理解：

- Ping、TCP 端口探测、UDP 探测可基于 Network Kit/Socket 能力实现。
- ARP 缓存读取在移动 OS 上可能受限，需要实际验证 HarmonyOS 是否开放。
- MAC/OUI 相关能力受隐私权限影响，需要做权限与降级策略。
- 子网扫描属于较敏感能力，应用市场合规边界需要确认，产品文案应定位为“本地网络诊断”，避免安全攻击用途表达。

### 3.5 Socket/报文调试能力

Packet Sender 类工具代表“网络协议调试台”的功能集合。

| 功能点 | TCP | UDP | TLS/SSL | HTTP/HTTPS | 组播 |
| --- | --- | --- | --- | --- | --- |
| Client 发送 | 支持 | 支持 | 支持 | 支持 | 支持 |
| Server 监听 | 支持 | 支持 | 支持 | 不典型 | 支持 |
| 自定义 IP/端口 | 支持 | 支持 | 支持 | 支持 | 支持 |
| IPv4/IPv6 | 支持 | 支持 | 支持 | 支持 | 视系统能力 |
| 文本/HEX | 支持 | 支持 | 支持 | Body 支持 | 支持 |
| 接收日志 | 支持 | 支持 | 支持 | 支持 | 支持 |
| 持久连接 | 支持 | 不适用 | 支持 | 可复用 | 不适用 |
| 自动重发 | 支持 | 支持 | 支持 | 支持 | 支持 |
| 宏变量 | 支持 | 支持 | 支持 | 支持 | 支持 |
| 文件发送 | 支持 | 支持 | 支持 | 支持 | 视协议 |

HarmonyOS Socket 官方能力覆盖：

- TCP Socket Client/Server。
- UDP Socket。
- Multicast Socket。
- TLS Socket Client/Server。
- 本地 Socket。
- 绑定本地 IP/端口、连接、发送、接收、关闭。

官方文档还提示：应用进入后台后 Socket 可能断开，回到前台通信异常时需要重建 TCP/UDP socket。该点会直接影响“后台长测”和“持续监听服务器”需求。

### 3.6 Ping、Traceroute、DNS、端口、测速

Network Analyzer 类工具常见工具箱如下：

| 工具 | 说明 | HarmonyOS 需求理解 |
| --- | --- | --- |
| Ping | 延迟、丢包、最小/最大/平均 | 可作为基础诊断 |
| Traceroute | 路由跳数 | 需验证底层命令/权限，可能受限 |
| DNS Lookup | A/AAAA/CNAME/MX/TXT 等 | 可用网络 API 或自实现 |
| Whois | 查询域名/公网 IP 信息 | 依赖外网服务，需确认是否需要 |
| Port Scan | TCP/UDP 端口探测 | 本地网络调试高价值 |
| Speed Test | 上下行测速、延迟 | 高价值但实现和服务成本较高 |
| mDNS/Bonjour | 发现局域网服务 | IoT 调试很有价值，需确认 |
| MQTT/WebSocket | IoT 常用协议调试 | 是否纳入无线工具范围需确认 |

## 4. HarmonyOS WiFi 能力完整性核对

| 能力 | HarmonyOS 状态 | 需求判断 |
| --- | --- | --- |
| WiFi 状态查询 | 支持 `isWifiActive` | 必备 |
| 开启/关闭 WiFi | API 存在但权限敏感 | 普通应用不应作为核心承诺 |
| WiFi 扫描结果 | 支持获取系统扫描列表 | 必备 |
| 主动扫描 | 存在版本/权限/系统限制 | 需降级为“刷新请求”体验 |
| SSID/BSSID/RSSI | 支持，但 BSSID/MAC 权限敏感 | 必备但需权限提示 |
| 安全类型 | 支持多种枚举 | 必备 |
| 信道/频段/宽度 | 支持 | 可做 WiFiAnalyzer 能力 |
| 当前连接信息 | 支持部分信息 | 必备 |
| P2P/Wi-Fi Direct | WLAN 概述提到 P2P，模拟器不支持 | 是否纳入待确认 |
| 热点/AP 管理 | 系统能力存在但权限可能受限 | 不建议默认纳入首期 |
| TCP/UDP | Network Kit 支持 | 必备 |
| TLS | Network Kit 支持 | 专业增强 |
| Multicast | Network Kit 支持 | IoT/发现增强 |
| 后台 Socket | 官方提示可能断开 | 高风险，需专项验证 |
| LAN 扫描 | 可基于 Ping/TCP 探测，ARP 需验证 | 建议作为网络诊断能力 |

## 5. 建议沉淀的 WiFi 需求池

### 5.1 WiFi 环境分析

| 编号 | 需求点 | 用户可感知结果 |
| --- | --- | --- |
| WF-001 | WiFi 状态与权限检查 | 用户知道 WiFi/权限/定位是否影响扫描 |
| WF-002 | AP 扫描列表 | 用户看到 SSID、BSSID、RSSI、安全类型、频段、信道 |
| WF-003 | 当前连接详情 | 用户看到当前网络 IP、网关、DNS、代理、RSSI |
| WF-004 | AP 过滤排序 | 用户按频段、信号、安全类型、SSID 筛选 |
| WF-005 | 信道图 | 用户看到不同 AP 在信道上的分布 |
| WF-006 | RSSI 时间图 | 用户观察目标 AP 信号变化 |
| WF-007 | 导出 WiFi 扫描结果 | 用户可提交测试报告 |
| WF-008 | 扫描限制提示 | 用户知道结果是否可能是缓存或被系统节流 |

### 5.2 网络诊断

| 编号 | 需求点 | 用户可感知结果 |
| --- | --- | --- |
| WF-101 | Ping | 用户看到延迟、丢包、统计值 |
| WF-102 | DNS 查询 | 用户验证域名解析是否正常 |
| WF-103 | 端口扫描 | 用户判断目标设备服务端口是否开放 |
| WF-104 | 局域网扫描 | 用户发现同网段设备 |
| WF-105 | 网络变化监听 | 用户看到网络切换、断开、质量变化 |
| WF-106 | Portal/代理/VPN 提示 | 用户理解网络不可用原因 |

### 5.3 Socket/协议调试

| 编号 | 需求点 | 用户可感知结果 |
| --- | --- | --- |
| WF-201 | TCP Client | 用户连接目标 IP/端口并发送/接收数据 |
| WF-202 | TCP Server | 用户在手机上监听端口并接收连接 |
| WF-203 | UDP 发送/监听 | 用户调试 UDP 设备协议 |
| WF-204 | TLS Client/Server | 用户调试加密 TCP 通道 |
| WF-205 | Multicast | 用户调试组播发现/通信 |
| WF-206 | 文本/HEX 输入输出 | 用户按协议字节级调试 |
| WF-207 | 命令收藏和周期发送 | 用户可复现协议交互 |
| WF-208 | 会话日志导出 | 用户保存报文与时间线 |

## 6. 关键限制与风险

| 风险 | 影响 | 产品处理 |
| --- | --- | --- |
| 主动扫描受限 | 不能保证每次刷新都有新 AP 数据 | 显示最后更新时间和系统限制说明 |
| BSSID/MAC 权限敏感 | 某些信息可能不可见 | 做降级展示和权限解释 |
| Android/iOS 功能不可完全迁移 | iOS WiFi 扫描开放度低，Android 权限模型不同 | 以 HarmonyOS 实测能力为准 |
| 后台 Socket 断开 | 长时间监听或压测不稳定 | 需要专项验证并明确使用边界 |
| LAN 扫描合规 | 可能被误认为安全扫描工具 | 产品定位必须限定本地网络诊断 |
| 热点/P2P 权限 | 普通应用可能无法完整控制 | 不应先承诺热点管理 |

## 7. 需要继续确认的问题入口

WiFi 部分的不确定项已汇总到《04-不确定需求确认.md》，重点包括：

- WiFi 模块主定位是“WiFiAnalyzer”、还是“网络工具箱”、还是“Socket 调试台”。
- 是否需要 LAN 扫描、端口扫描、Ping、DNS、Traceroute。
- 是否需要 TCP/UDP/TLS/HTTP/MQTT/WebSocket 等协议调试。
- 是否需要信道图、RSSI 时间图、导出报告。
- 是否要求后台持续监听和长时间压测。

## 8. 参考链接

- [HarmonyOS WLAN 服务开发概述](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/wlan-overview)
- [HarmonyOS Wi-Fi 扫描开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/scan-development-guide)
- [HarmonyOS WLAN API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-wifiManager)
- [HarmonyOS Socket 访问网络](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/socket-connection)
- [WiFiAnalyzer](https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer)
- [AndroidNetworkTools](https://github.com/stealthcopter/androidnetworktools)
- [Packet Sender](https://github.com/dannagle/PacketSender)
- [Fing](https://www.fing.com/products/fing-app)
- [Ubiquiti WiFiman](https://ui.com/wifiman)
