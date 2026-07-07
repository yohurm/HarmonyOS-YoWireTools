# HarmonyOS 无线调试工具 PRD - WiFi 模块

## 1. 文档定位

本文描述 WiFi 模块的产品需求，覆盖 WiFi 环境分析、网络状态诊断、LAN 设备发现、端口扫描、TCP/UDP/HTTP/WebSocket/MQTT 调试、mDNS/SSDP 预留、WiFi 控制类能力预留。

WiFi 模块优先级为 P1。用户已确认 WiFi 模块三类能力都需要：WiFi 环境分析、网络诊断、Socket/协议调试。

## 2. WiFi 模块目标

| 目标 | 说明 |
| --- | --- |
| 看清无线环境 | 扫描周边 AP，分析 RSSI、频段、信道、安全类型 |
| 判断当前网络 | 展示当前连接、IP、DNS、网关、代理、VPN、Portal 等 |
| 找到局域网设备 | 子网扫描、端口扫描、服务发现 |
| 调试网络协议 | TCP、UDP、HTTP、WebSocket、MQTT 等收发 |
| 记录诊断过程 | 保存扫描、诊断、报文、错误和导出结果 |

## 3. 范围与分级

| 功能 | 分级 | 说明 |
| --- | --- | --- |
| WiFi 状态与权限检查 | 必须支持 | 判断 WiFi、权限、定位/隐私限制 |
| AP 扫描列表 | 必须支持 | 展示 SSID、BSSID、RSSI、频段、信道、安全类型 |
| 信道图 | 首期优先 | 对齐 WiFiAnalyzer |
| RSSI 时间图 | 首期优先 | 支持观察信号变化 |
| 信道评分 | 后续增强 | 用户确认后续增强 |
| 当前网络诊断 | 必须支持 | 当前网络类型、IP、DNS、代理、网关 |
| Ping/DNS/TraceRoute/Whois | 完整规划 | 用户确认都需要完整功能 |
| LAN 子网扫描 | 完整规划 | 文案限定本地诊断 |
| TCP/UDP 端口扫描 | 完整规划 | 范围和频率可配置 |
| TCP/UDP Client/Server | 完整规划 | 用户确认都需要完整功能 |
| HTTP/HTTPS | 完整规划 | 需要明确工具边界 |
| WebSocket | 完整规划 | HarmonyOS 有官方能力 |
| MQTT | 完整规划 | 需确定使用库或协议能力，需求先规划 |
| TLS/SSL | 架构预留 | 后续增强 |
| mDNS/Bonjour/SSDP | 架构预留 | mDNS 官方支持，SSDP 需基于 UDP/组播规划 |
| WiFi 开关/连接/热点/P2P 控制 | 架构预留 | 权限敏感 |

## 4. WiFi 首页

| 区域 | 内容 |
| --- | --- |
| 当前网络摘要 | 当前连接网络、网络类型、IP、RSSI、可用性 |
| WiFi 环境分析 | AP 列表、信道图、时间图 |
| 网络诊断工具 | Ping、DNS、TraceRoute、Whois |
| LAN 工具 | 子网扫描、端口扫描、服务发现 |
| 协议调试 | TCP、UDP、HTTP、WebSocket、MQTT |
| 最近目标 | 最近 IP、端口、域名、HTTP 请求、MQTT Broker |

## 5. WiFi 环境分析

### 5.1 AP 列表

| 字段 | 要求 |
| --- | --- |
| SSID | 展示网络名称，隐藏网络明确标识 |
| BSSID | 有权限时展示真实 BSSID，否则说明随机/不可用 |
| RSSI | dBm 数值和强度等级 |
| 频段 | 2.4G、5G、6G、60G |
| 频率 | MHz |
| 信道 | 根据频率换算展示 |
| 信道宽度 | 20/40/80/160/320MHz 等 |
| 安全类型 | OPEN、WEP、PSK、SAE、EAP、OWE、WAPI 等 |
| WiFi 标准 | 802.11 a/b/g/n/ac/ax/ad 等可用信息 |
| WiFi Category | WiFi 6、WiFi 6+、WiFi 7、WiFi 7+ 等可用信息 |
| 时间戳 | 扫描结果时间 |
| 厂商/OUI | 有真实 BSSID 时可查 |

HarmonyOS `getScanInfoList` 可返回扫描热点列表。若应用拥有 `GET_WIFI_PEERS_MAC`，结果中的 BSSID 可为真实设备地址，否则可能是随机地址。产品必须把这一点写入权限和降级体验。

### 5.2 过滤与排序

| 能力 | 要求 |
| --- | --- |
| SSID 搜索 | 支持包含匹配 |
| 频段过滤 | 2.4G、5G、6G、60G |
| 信号过滤 | 按 RSSI 区间 |
| 安全类型过滤 | 按 OPEN/WPA/WPA3/WAPI/EAP 等 |
| 收藏过滤 | 只看收藏 AP |
| 排序 | RSSI、SSID、信道、频段、最近发现 |
| 分组 | 按 SSID、信道、频段分组 |

### 5.3 信道图

信道图用于展示 AP 在信道上的重叠关系。

| 要求 | 描述 |
| --- | --- |
| 频段切换 | 支持 2.4G/5G/6G |
| 图形宽度 | 根据信道宽度展示占用范围 |
| 强度轴 | Y 轴为 RSSI |
| AP 选择 | 点击图形查看 AP 详情 |
| 暂停刷新 | 支持暂停，避免图形跳动 |
| 导出 | 导出当前图表数据 |

### 5.4 RSSI 时间图

| 要求 | 描述 |
| --- | --- |
| 选择 AP | 可选择一个或多个 AP |
| 时间范围 | 最近 30 秒、1 分钟、5 分钟等 |
| 暂停 | 暂停曲线更新 |
| 标记 | 标记明显波动点 |
| 导出 | 导出时间序列数据 |

## 6. WiFi 扫描限制

WiFi 扫描结果可能受系统缓存、扫描节流、权限、WiFi 开关、温控、连接状态影响。产品要求：

| 场景 | 展示 |
| --- | --- |
| 无权限 | 提示缺少 `GET_WIFI_INFO` 或相关权限 |
| BSSID 不真实 | 标识为随机或受限 |
| 扫描结果旧 | 显示最后更新时间 |
| 主动扫描受限 | 告知系统限制，提供进入系统设置或等待刷新 |
| WiFi 关闭 | 引导打开 WiFi |

主动扫描能力在 HarmonyOS 中存在版本和权限差异，例如 `startScan` 需要 `SET_WIFI_INFO`。PRD 不承诺所有设备都能强制实时刷新。

## 7. 当前网络诊断

### 7.1 网络摘要

| 字段 | 要求 |
| --- | --- |
| 默认网络 | 展示当前默认网络类型 |
| WiFi 连接 | SSID、BSSID、RSSI、频段、IP |
| IP 信息 | IPv4、IPv6、子网信息 |
| 网关 | 默认路由 |
| DNS | DNS 服务器 |
| 代理 | HTTP/系统代理 |
| VPN | 是否处于 VPN |
| Portal | 是否需要认证 |
| 网络可用性 | 是否有默认网络、是否能访问互联网 |

HarmonyOS Network Kit 可通过默认网络、网络能力、连接属性获取网络信息。LinkAddresses、routes、dnses 可能为空，产品必须有空值展示策略。

### 7.2 网络变化监听

| 事件 | 要求 |
| --- | --- |
| 网络可用 | 记录日志并更新摘要 |
| 网络丢失 | 记录日志并提示 |
| 网络不可用 | 展示原因 |
| 网络能力变化 | 更新 WiFi/蜂窝/VPN 等能力 |
| 连接属性变化 | 更新 IP、DNS、路由 |

## 8. 网络诊断工具

### 8.1 Ping

| 配置 | 要求 |
| --- | --- |
| 目标 | IP 或域名 |
| 次数 | 可配置 |
| 间隔 | 可配置 |
| 超时 | 可配置 |
| 结果 | 成功/失败、延迟、丢包、最小/最大/平均 |
| 日志 | 每次响应都记录 |

### 8.2 DNS

| 功能 | 要求 |
| --- | --- |
| 域名解析 | 支持 A/AAAA 基础解析 |
| IP 类型 | 支持 IPv4/IPv6 查询选项 |
| 当前网络解析 | 支持使用默认网络或指定 NetHandle |
| 自定义 DNS | HarmonyOS 支持自定义 DNS 规则，作为专家能力规划 |
| 日志 | 记录请求、结果、耗时、错误 |

### 8.3 TraceRoute

HarmonyOS Network Kit 有 `queryTraceRoute` 能力。产品需求：

- 支持输入目标域名/IP。
- 支持超时、最大跳数等选项。
- 展示每跳地址、耗时、错误。
- 结果进入诊断会话日志。

### 8.4 Whois

Whois 不是 HarmonyOS 本地网络能力，需要通过外部服务或协议实现。产品需求先完整规划：

- 支持查询公网 IP 或域名。
- 明确需要互联网。
- 失败时区分网络不可达、服务不可达、查询对象无效。
- 不用于局域网设备识别主路径。

## 9. LAN 发现与端口扫描

### 9.1 子网扫描

| 需求 | 描述 |
| --- | --- |
| 自动识别网段 | 根据当前 IP 和掩码推断 |
| 手动输入网段 | 支持 CIDR 输入 |
| 扫描方式 | Ping、TCP 探测、ARP 能力待验证 |
| 设备列表 | IP、MAC/OUI 可用时展示、响应时间、开放端口摘要 |
| 频率限制 | 控制并发和速率 |
| 文案边界 | 明确仅用于本地网络诊断 |

### 9.2 端口扫描

| 需求 | 描述 |
| --- | --- |
| TCP 扫描 | 支持端口范围 |
| UDP 扫描 | 支持 UDP 探测，明确不一定可靠 |
| 常用端口模板 | HTTP、SSH、Telnet、MQTT、CoAP、自定义 |
| 并发 | 可配置最大并发 |
| 超时 | 可配置 |
| 停止 | 扫描中可停止 |
| 结果 | open、closed、filtered、timeout 等 |
| 日志 | 每个端口结果写入会话 |

## 10. 协议调试

### 10.1 TCP/UDP

| 功能 | TCP | UDP |
| --- | --- | --- |
| Client 发送 | 必须 | 必须 |
| Server 监听 | 必须 | 必须 |
| 自定义本地端口 | 需要 | 需要 |
| IPv4/IPv6 | 需要 | 需要 |
| 文本/HEX | 需要 | 需要 |
| 周期发送 | 需要 | 需要 |
| 接收日志 | 需要 | 需要 |
| 持久连接 | TCP 需要 | UDP 不适用 |

HarmonyOS Socket 文档提示 UDP send 是耗时操作，建议在 Worker 或 taskpool 调用。PRD 不写实现，但需要把“长任务不阻塞 UI、发送中有状态”作为体验要求。

### 10.2 HTTP/HTTPS

HTTP/HTTPS 与专业 HTTP 工具存在重叠。无线调试工具中的 HTTP 功能边界为：

| 范围 | 要求 |
| --- | --- |
| 请求方法 | GET、POST、PUT、DELETE、PATCH 规划 |
| Header | 支持自定义 |
| Body | 文本、JSON、表单、HEX/文件后续 |
| 认证 | Basic/Bearer 规划 |
| 响应 | 状态码、Header、Body、耗时 |
| 保存 | 请求可收藏为命令 |
| 日志 | 请求和响应进入会话日志 |

不把复杂 API 集合管理、环境变量系统、接口自动化测试作为首期目标，但架构上不阻塞命令面板复用。

### 10.3 WebSocket

HarmonyOS 支持 WebSocket Client，并且 WebSocket Server 从 API version 23 起全设备支持，之前仅 TV。产品需求：

- 支持 WebSocket Client 连接、发送、接收、关闭。
- 支持文本和二进制消息。
- 支持 Header 配置。
- 支持连接状态、错误、消息日志。
- WebSocket Server 作为完整规划项，按 API 版本做能力提示。

### 10.4 MQTT

MQTT 是 IoT 调试常见协议，用户已确认需要完整功能。需求范围：

| 功能 | 要求 |
| --- | --- |
| Broker 配置 | host、port、clientId、username、password |
| 连接 | TCP 或 TLS 后续 |
| Publish | topic、payload、QoS、retain |
| Subscribe | topic、QoS |
| 消息日志 | topic、payload、方向、时间 |
| 命令收藏 | 保存 publish 命令 |
| 面板 | 常用 topic 操作按钮 |

MQTT 是否使用三方库或自研协议栈属于技术方案，不在本文确定。但 PRD 要求保留完整产品能力。

## 11. mDNS/SSDP 预留

HarmonyOS 提供 MDNS 管理能力，可添加、移除、发现、解析局域网服务。产品架构应预留服务发现页：

| 能力 | 状态 |
| --- | --- |
| mDNS 发现 | 官方能力支持，后续扩展 |
| mDNS 解析 | 官方能力支持，后续扩展 |
| mDNS 本地服务 | 官方能力支持，后续扩展 |
| SSDP | 可基于 UDP/组播规划，后续验证 |

## 12. WiFi 控制类能力预留

WiFi 开关、连接指定 WiFi、热点、P2P 等能力受权限限制。产品要求：

- 普通用户主路径以查询和诊断为主。
- 设置或高级页预留“控制类能力”分区。
- 若当前应用权限不可用，则展示不可用原因。
- 不把系统应用/企业应用权限能力承诺给普通用户。

## 13. 参考来源

- HarmonyOS WLAN 服务开发概述、Wi-Fi 扫描开发指南。
- HarmonyOS `ohos.wifiManager`、`ohos.net.socket`、`ohos.net.connection`、`ohos.net.http`、`ohos.net.webSocket`、`ohos.net.mdns`。
- GitCode HarmonyOS `network-query`。
- WiFiAnalyzer、AndroidNetworkTools、Packet Sender、Fing、WiFiman、Network Analyzer。
