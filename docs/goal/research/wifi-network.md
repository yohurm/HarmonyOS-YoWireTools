---
id: research.wifi-network
type: topic-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [ArkTS, Kotlin, Java, JavaScript, C++]
  frameworks: [HarmonyOS Connectivity Kit, HarmonyOS Network Kit, Android WifiManager]
also_relevant: [research.client-runtime]
utilization: [adapt, lesson-only, anti-pattern]
source:
  platform: github
  url: https://github.com/yohurm/HarmonyOS-Developer-docs
  repos:
    - VREMSoftwareDevelopment/WiFiAnalyzer
    - emanuele-f/PCAPdroid
    - stealthcopter/AndroidNetworkTools
    - librespeed/speedtest
    - dannagle/PacketSender
  cloned_to:
    - /tmp/YoAgentResearch/VREMSoftwareDevelopment--WiFiAnalyzer
    - /tmp/YoAgentResearch/emanuele-f--PCAPdroid
    - /tmp/YoAgentResearch/stealthcopter--AndroidNetworkTools
    - /tmp/YoAgentResearch/librespeed--speedtest
    - /tmp/YoAgentResearch/dannagle--PacketSender
studied_at: 2026-10-09
related: [checklist.wifi-network]
---

# Wi-Fi 与网络专业调试能力

## 背景

主题是手机工具箱里可以诚实提供的 Wi-Fi / WLAN / 网络调试与测试能力：扫描与过滤、连接与认证、信号与链路统计、吞吐、本应用连接检查、重连、日志、权限流程，以及 DNS / 探测 / 路由类诊断。

官方规范先于开源实现。HarmonyOS 文档镜像是 `yohurm/HarmonyOS-Developer-docs`（默认分支 `main`）。该仓库体积约 7 GB，本轮用 GitHub API 拉取下列仓库相对路径的正文，没有把整库克隆进工作区。开源实现按联网深研手册浅克隆到 `/tmp/YoAgentResearch/<owner>--<repo>`。手册要求 GitHub 默认 SSH；本环境没有可用 SSH 密钥，五份仓库改用 HTTPS `--depth 1`。源码留在临时目录，不进入本仓库。

本文件是主题笔记，把官方能力边界和五个实现的可抄模式放在一起。细项验收在 `docs/goal/checklist/wifi-network.md`。YoAgentDocs 知识库的归档位置是 `research/by-stack/client-runtime/`；本阶段合同把产品仓库产物放在 `docs/goal/`，因此没有把知识库目录树复制进应用仓库。

## 关键结论

手机工具箱能稳定做成的，是「本机 WLAN 状态 + 缓存扫描结果 + 本应用发起的连接与计时 + 用户可见的权限失败」。射频级抓包、其他应用流量、原始 ICMP、真实 MAC、开关系统 Wi-Fi、整机端口表，分别落在系统应用、企业应用、受限 ACL、或开发者选项，不能伪装成普通应用已接通。

### 能力对照

| 行业能力 | 普通应用可观察的结果 | 权限墙 | 依据 |
| --- | --- | --- | --- |
| 周围 AP 列表：SSID、加密、RSSI、频段、频率、带宽、中心频率、capabilities、信息元素 | `getScanInfoList()` 返回当前时刻前 30 秒缓存。未持有对端 MAC 权限时 BSSID 为随机地址 | `ohos.permission.GET_WIFI_INFO`（normal，系统授权） | `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.wifiManager WLAN.md` 的 `getScanInfoList10+`、`WifiScanInfo` |
| 主动刷新扫描 | `startScan()`：前台 2 分钟最多 4 次，后台 30 分钟最多 1 次；完成看 `wifiScanStateChange`（0 失败，1 成功） | `ohos.permission.SET_WIFI_INFO`（normal，系统授权） | 同文件 `startScan21+`；指南 `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/Wi-Fi扫描开发指南.md` |
| 按 SSID / 信号档 / 加密 / 频段过滤、按强度或信道排序、同 SSID 分组 | 过滤与排序在应用内完成。频段枚举含 2.4/5/6/60 GHz，但 `WifiScanInfo.band` 正文只写 1=2.4 GHz、2=5 GHz | 无额外权限；6 GHz 结果是否出现须真机核对 | `WifiBandType10+`、`WifiScanInfo.band`；WiFiAnalyzer `FiltersAdapter` |
| 信道号、重叠计数、空信道建议 | API 给频率与带宽，不给信道号。信道号、重叠、评分由频率表在本地计算 | 计算结果是估计，不是驱动测量 | WiFiAnalyzer `ChannelRating`、`WiFiChannel` |
| 信号档位 | `getSignalLevel(rssi, band)` 返回 0–4。RSSI 常见有效范围文档写为 -100 dBm 到 -30 dBm | `GET_WIFI_INFO` | `getSignalLevel`、`WifiLinkedInfo.rssi` |
| 已连接链路：SSID、RSSI、上下行速率、最大协商速率、频率、带宽、Wi-Fi 标准、隐藏、限流、连接状态、Wi-Fi 7 链路类型 | `getLinkedInfo` / `getLinkedInfoSync18+`。STA 关闭时错误码 2501001 | `GET_WIFI_INFO`。真实 BSSID 另要 `GET_WIFI_PEERS_MAC`。本机 MAC 在 `macType=1` 时另要 `GET_WIFI_LOCAL_MAC`，否则 `macAddress` 为空 | `WifiLinkedInfo`、`ConnState`、`WifiLinkType18+` |
| 噪声、SNR、MCS、空间流、重传、Beacon 间隔 | 扫描结果与连接信息结构里没有这些字段 | 缺口。不能用 RSSI 档位冒充 SNR | `WifiScanInfo`、`WifiLinkedInfo` 字段表 |
| 连接开放 / PSK / SAE / EAP / WAPI / OWE / 隐藏 SSID | 候选网络：`addCandidateConfig` + `connectToCandidateConfig` 或 `connectToCandidateConfigWithUserAction20+`。WEP 不能作为候选网络配置 | `SET_WIFI_INFO`。用户确认路径会返回 2501005 未响应、2501006 拒绝 | `WifiDeviceConfig`、`WifiSecurityType`、STA 指南 `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/STA模式开发指南.md` |
| 打开或关闭系统 Wi-Fi、断开当前 STA、按系统已保存网络 `connectToNetwork` | 接口存在 | `SET_WIFI_INFO` 再加上 `MANAGE_WIFI_CONNECTION`（仅系统应用）或 `MANAGE_ENTERPRISE_WIFI_CONNECTION`（仅企业应用） | `enableWifi15+`、`disableWifi20+`、`disconnect15+`、`connectToNetwork15+` |
| 读取已保存 SSID/PSK | `getDeviceConfigs15+` | `GET_WIFI_CONFIG`：API 15 起为企业普通应用，AGC 审核 | `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/企业类应用可用权限.md` |
| IPv4/IPv6、网关、掩码、DNS、DHCP 租约、国家码 | `getIpInfo`、`getIpv6Info10+`、`getCountryCode`。IPv4 地址是 number，须转点分十进制。`randomGlobalIpv6Address` 标注暂不支持 | `GET_WIFI_INFO` | `IpInfo`、`Ipv6Info10+` |
| 默认网络、能力位、路由表、MTU、网卡名 | `getDefaultNet`、`getNetCapabilities`、`getConnectionProperties`。`linkAddresses` / `routes` / `dnses` 可能为空。带宽字段为 0 表示无法评估 | `ohos.permission.GET_NETWORK_INFO`（normal，系统授权） | `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.connection 网络连接管理.md` 的 `ConnectionProperties`、`NetCapabilities`、`NetCap` |
| DNS 解析、中文域名转码、按 IPv4/IPv6 或指定网络解析 | `getAddressesByName`、`NetHandle.getAddressByName`、API 23 的 `getDnsAscii` / `getDnsUnicode` / `getAddressesByNameWithOptions23+`。无默认网络时 `netId` 为 0 | `ohos.permission.INTERNET` | `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用DNS解析域名.md` |
| 持续探测丢包率与 RTT | `queryProbeResult(destination, duration)`，duration 1–1000 秒，间隔 1 秒。断网立即返回。起始版本 26.0.0 | 仅 `INTERNET` | 同 connection API `queryProbeResult`、`ProbeResultInfo` |
| 路由跟踪 | `queryTraceRoute`，最大跳数 1–30，ICMP 或 UDP，每跳 5 个探测的最小/平均/最大/标准差 RTT。起始版本 26.0.0 | `INTERNET` + `ACCESS_NET_TRACE_INFO`（system_basic，AGC，场景限于时延敏感类应用）+ 精确位置 `LOCATION` 与 `APPROXIMATELY_LOCATION` | connection API；`开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/受限开放权限.md` |
| 吞吐测速 | 没有 iperf 接口。可用 HTTP 多连接下载/上传计时，或读取 `NetCapabilities` 的链路带宽估计 | HTTP 走 `INTERNET`。带宽估计为 0 时不得显示成 0 Mbps 测速结果 | LibreSpeed `speedtest_worker.js`；`NetCapabilities.linkUpBandwidthKbps` |
| HTTP 分段耗时 | `PerformanceTiming11+`：DNS、TCP、TLS、首字节发送、请求完成 | `INTERNET` | `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.http 数据请求.md` |
| 本应用 TCP/UDP/TLS/组播/本地套接字、TCP/TLS 服务端 | Socket 指南覆盖客户端、服务端、组播、LocalSocket、TLS 升级 | `INTERNET` | `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用Socket访问网络.md` |
| 本应用 WebSocket 客户端与服务端 | 客户端双向消息；API 19 起 `createWebSocketServer` | `INTERNET` | `ohos.net.webSocket`；指南 `使用WebSocket访问网络.md` |
| mDNS 发现与发布 | 发现 `serviceFound` / `serviceLost`；发布 `addLocalService`。指南要求先连上 Wi-Fi | 指南未单独列出超出 Network Kit 总表的权限；总表为 `GET_NETWORK_INFO` 与 `INTERNET` | `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用MDNS访问局域网服务.md` |
| 本应用蜂窝/Wi-Fi 历史流量 | `getSelfTrafficStats22+`，最长 31 天，只含蜂窝与 Wi-Fi，频繁调用会慢 | 查本应用不要求 `GET_NETWORK_STATS` | `ohos.net.statistics` |
| 其他应用流量、整机 TCP/UDP 监听表、邻居 MAC | 接口存在：`getUidRxBytes`、`getSystemNetPortStates24+`、`getIpNeighTable22+` | `GET_NETWORK_STATS`、`GET_IP_MAC_INFO` 均为受限 ACL | statistics API、connection API、受限权限列表 |
| 其他应用报文、链路层原始帧 | 手机/平板：开发者选项「网络报文分析」经 USB 镜像到 Windows Wireshark，API 26.0.0 起。PC/2in1 二进制可申请 `kernel.NET_RAW` 后 sudo 使用 PF_PACKET | 应用内无对等抓包 API。与 USB 调试互斥 | `开发/指南/开发/系统/网络/网络调试调优/使用网络报文分析功能实现tcpdump抓包/使用网络报文分析功能实现tcpdump抓包.md`；`开发/指南/开发/系统/安全/程序访问控制/应用权限管控/抓包／调试权限常见问题.md` |
| 弱网场景模拟、网络质量/多网并发 | 开发者选项「网络领航员」预置电梯、地铁等场景，手机和平板，API 20 起。Network Boost 的多网并发要 `LINKTURBO` | 工具箱不能把系统模拟器或加速套件写成普通调试按钮 | `开发/指南/开发/系统/网络/网络调试调优/使用网络领航员进行网络模拟.md`；`Network Boost Kit（网络加速服务）/开发准备.md` |

### 扫描文档与 API 参考不一致

扫描指南（页面更新时间 2026-09-09）写明：主动扫描从 API 10 废弃，替代接口只向系统应用开放；并列出前台 2 分钟 4 次、连接过程中不允许扫描、Wi-Fi 关闭不做周期扫描和 PNO、温度达阈值会管控。

API 参考（页面更新时间 2026-09-24）把 `startScan21+` 写成带 `SET_WIFI_INFO` 的应用接口，并写明前台 2 分钟 4 次、后台 30 分钟 1 次，正文没有「仅系统应用」。`getScanInfoList` 明确是 30 秒缓存，不是一次新扫描的返回值。

后续实现以 API 参考的 `startScan` + `wifiScanStateChange` + `getScanInfoList` 为准，同时把指南里的连接中禁扫、关闭 WLAN 不扫、温度管控、静止管控保留为失败路径。静止管控的错误信息是 `moving freeze scanning control`，归在 `2501000` 下（`开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/错误码/WIFI错误码.md`）。指南与 API 参考冲突处在验收里单列一条，要求界面写出「缓存结果」和「距下次可扫描的剩余次数」，避免把缓存列表说成刚刚扫到。

旧接口 `scan()` / `getScanResults()` 从 API 10 废弃，且要求位置权限。现行 `startScan` / `getScanInfoList` 的权限表没有位置权限。这与 Android WiFiAnalyzer 必须持有 `ACCESS_FINE_LOCATION` 不同，不能把 Android 位置弹窗原样搬过来。

### 连接状态

`ConnState`：`SCANNING`、`CONNECTING`、`AUTHENTICATING`、`OBTAINING_IPADDR`、`CONNECTED`、`DISCONNECTING`、`DISCONNECTED`、`UNKNOWN`。

`wifiStateChange`：0 `DISABLED`，1 `ENABLED`，2 `ENABLING`，3 `DISABLING`。

`wifiConnectionChange` 只说明结果是 number，指南要求对照 `ConnState`。订阅本身要 `GET_WIFI_INFO`。

`connectToCandidateConfig` 不返回用户是否点了确认。需要把未响应和拒绝显示出来时，用 `connectToCandidateConfigWithUserAction`，并在连接前先 `startScan`，等 `wifiScanStateChange` 成功后再连。API 参考把这一步写成提高成功率的建议。

`WifiSecurityType`：INVALID、OPEN、WEP、PSK、SAE、EAP、EAP_SUITE_B、OWE、WAPI_CERT、WAPI_PSK。候选配置不支持 WEP。EAP 第二阶段含 PAP、MSCHAP、MSCHAPV2、GTC、SIM、AKA。PSK 密钥最短 8 字节，SAE 最短 1 字节，OPEN 的密钥必须是空串。

### 网络连接事件

`NetConnection` 事件顺序写在 connection API：无网到有网会依次出现 `netAvailable`、`netCapabilitiesChange`、`netConnectionPropertiesChange`；之后掉网出现 `netLost`；若从未 `netAvailable` 则直接 `netUnavailable`；Wi-Fi 切到蜂窝时先 `netLost`（Wi-Fi）再 `netAvailable`（蜂窝）。`netId === 0` 表示当前没有已连接网络。

`NetCap` 里 `NET_CAPABILITY_INTERNET` 只表示提供者声称可上网，连通性看 `VALIDATED`；检测进行中时 `CHECKING_CONNECTIVITY` 会使 `VALIDATED` 不准确。`PORTAL` 表示强制门户。这些位可以诚实显示，不能把 `INTERNET` 位写成「已经 ping 通」。

### 设备与模拟器

`wifiManager` 支持 Phone、PC/2in1、Tablet、TV、Wearable。WLAN 指南写模拟器支持 WLAN，但 P2P 不支持模拟器。Network Kit 支持模拟器，不支持 VPN。Network Boost 不支持模拟器，且只覆盖 Wi-Fi 与蜂窝。报文分析只覆盖 Phone 与 Tablet，要开发者模式、USB 连到 Windows，并与 USB 调试互斥。网络领航员只支持手机和平板。

`isFeatureSupported` 可探测基础结构、5 GHz、GAS/ANQP、Wi-Fi Direct、Soft AP、Wi-Fi Aware、AP/STA 共存、WPA3-Personal SAE、WPA3-Enterprise Suite-B、增强开放。特性不支持时返回 false 或错误码 801，界面应写「本机不支持」，而不是空白。

热点开关 `wifiManagerExt.enableHotspot` / `disableHotspot` / `setPowerMode` 已废弃。普通应用可以 `isHotspotActive15+` 查询热点是否打开（`GET_WIFI_INFO`）。

P2P：`GET_WIFI_INFO` 从 API 22 起包含使用 P2P 的说明。`p2pConnect` 与对端设备列表另要 `GET_WIFI_PEERS_MAC`。模拟器不做 P2P。本阶段工具箱若做 P2P，只能做成「能力探测 + 发现/建组失败可见」，不能默认承诺直连成功。

## 单项目

### VREMSoftwareDevelopment/WiFiAnalyzer

- 仓库：`VREMSoftwareDevelopment/WiFiAnalyzer`，HEAD `7e2019d294d4ac40b70e770d9e2c55fdc1b18281`（2026-10-03）。克隆：`/tmp/YoAgentResearch/VREMSoftwareDevelopment--WiFiAnalyzer`。
- 入选理由：仍在维护的 Android AP 分析器，模块按扫描、过滤、信道图、时间图、信道评分拆开，直接回答「扫描结果怎么筛、怎么评」。
- 架构：`Scanner` 在权限通过后注册接收器并 `startScan`，再用 `Transformer` 把结果收成 `WiFiData` 状态流。`PeriodicScan` 按设置的扫描间隔循环，默认 5 秒。`FiltersAdapter` 同时持有 SSID、频段、强度、加密四套过滤器，列表页四套都生效，非列表页去掉频段。`ChannelRating` 用频率重叠收集 AP，已连接 AP 不参与「最强干扰」计算，强度为 ZERO 或 ONE 的信道进入推荐。`Strength.colorForRssi` 把 ≥ -67 dBm 视为强、≥ -70 dBm 视为中、更低视为弱；五档插值用 -100 到 -55 dBm。`WarningView` 在系统扫描节流打开时显示节流条。距离用自由空间路径损耗估算。
- 可改编：过滤器与排序（强度、SSID、信道）、同 SSID 分组、节流/冷却可见、信道评分与当前连接排除、导出列表、暂停/继续。
- 必须改写：Android 位置权限与 `WifiManager.startScan` 节流模型换成鸿蒙 `SET_WIFI_INFO` + 前台 4 次/2 分钟；BSSID 默认随机；没有噪声和 MCS，不能做厂商级射频图；距离只标注「估算」。
- 明确不抄：README 已声明它不是破解或钓鱼工具。OUI 厂商库可以后补，但随机 BSSID 下厂商查询会错，未持有 `GET_WIFI_PEERS_MAC` 时不要显示厂商。
- 读过：`README.md`，`wifi/scanner/Scanner.kt`，`wifi/scanner/PeriodicScan.kt`，`wifi/filter/adapter/FiltersAdapter.kt`，`wifi/model/Strength.kt`，`wifi/model/ChannelRating.kt`，`wifi/model/WiFiUtils.kt`，`wifi/model/WiFiSecurity.kt`，`wifi/model/GroupBy.kt`，`wifi/model/SortBy.kt`，`permission/ApplicationPermission.kt`。测试目录未逐份读。

### emanuele-f/PCAPdroid

- 仓库：`emanuele-f/PCAPdroid`，HEAD `66f7b3514540c20add8655a74dfee93d00a9563b`（2026-09-26）。克隆：`/tmp/YoAgentResearch/emanuele-f--PCAPdroid`。
- 入选理由：无 root 的手机连接检查与 PCAP 导出，用来划定「别人家能做、鸿蒙普通应用做不到」的边界。
- 架构：README 写明用本地 VPN 处理流量，不把流量送到远程 VPN 服务器。连接记录 `ConnectionDescriptor` 有五元组、首末时间、收发字节和包数、UID、L7 协议、URL、状态、阻塞标记。付费能力含防火墙规则与黑名单。另有 PCAP-over-IP 和根设备上的 pcapd。
- 可改编：连接行要有协议、对端、端口、起止时间、字节数、状态；导出的是本应用自己的会话，不是整机报文。
- 必须改写：鸿蒙对等能力是开发者选项 USB 镜像到 Wireshark，或 PC 上带 `kernel.NET_RAW` 的已签名二进制。应用内 VPN 扩展是「本应用提供 VPN」，指南写的是连接 VPN，不是抓取其他应用。
- 明确不抄：本地 VPN 拦截其他应用、TLS 解密、按应用阻断、恶意软件黑名单。这些不是本工具箱的普通应用能力。
- 读过：`README.md`，`app/src/main/java/com/emanuelef/remote_capture/model/ConnectionDescriptor.java` 的字段定义。JNI 抓包实现未展开，避免把拦截步骤写进产品结论。

### stealthcopter/AndroidNetworkTools

- 仓库：`stealthcopter/AndroidNetworkTools`，HEAD `a82af8a530988f1ace4c0579762d7620aeea7561`（2024-02-05）。星数与模块边界够用，近期提交少，仍入选是因为它把 ping、TCP 端口、子网设备拆成独立类。
- 入选理由：手机侧诊断库，能看清「ICMP 失败后用 TCP 探测」的诚实降级。
- 架构：`PortScanTCP.scanAddress` 对目标地址做带超时的 TCP `connect`，连接成功视为端口开，`IOException` 视为不开或未知。`PingTools.doJavaPing` 先走 ICMP echo，失败再退到对端 TCP 7 端口；`doNativePing` 调用系统 ping 二进制。
- 可改编：端口扫描是「TCP 连接是否在超时内建立」，结果三态：开、拒绝/超时、调用失败。并发和取消放在应用侧。子网遍历只能基于本机已获得的地址与前缀。
- 必须改写：鸿蒙普通应用没有 raw ICMP。API 26 起 `queryProbeResult` 给出丢包率和 RTT，但要用户指定时长。更低 API 只能用 TCP 连接耗时或 HTTP `PerformanceTiming` 代替，并在界面写明方法。不要调用原生 ping 二进制。
- 明确不抄：`WakeOnLan` 与 ARP 读取不作为本阶段默认能力；邻居 MAC 在鸿蒙侧要 `GET_IP_MAC_INFO`。
- 读过：`library/src/main/java/com/stealthcopter/networktools/portscanning/PortScanTCP.java`，`library/src/main/java/com/stealthcopter/networktools/ping/PingTools.java`。仓库根目录没有 README。

### librespeed/speedtest

- 仓库：`librespeed/speedtest`，HEAD `aa84692df3f0de19021153ada69572335cff8547`（2026-09-27）。克隆：`/tmp/YoAgentResearch/librespeed--speedtest`。
- 入选理由：吞吐测试的状态机清楚，且与「没有 iperf 接口时用 HTTP 测」直接对应。OpenSpeedTest 结构同类，本轮不重复入选。
- 架构：`speedtest_worker.js` 的 `testState` 从下载、ping+抖动、上传走到结束或中止。状态字段是下载/上传 Mbps（两位小数）、ping、jitter，以及三段进度。默认 ping 次数 10。下载和上传各自有最长时间配置。中止时 `clearRequests` 停掉未完成的 XHR。
- 可改编：分阶段、可中止、同时给出速率和进度；失败与中止分开。服务器地址由用户填写，不内置公共测速点。
- 必须改写：鸿蒙用 `@ohos.net.http` 或 Remote Communication Kit 做传输。`NetCapabilities` 的 Kbps 是系统估计，与实测分开显示。
- 明确不抄：遥测上报、公共服务器列表。
- 读过：`speedtest_worker.js` 的状态常量、设置默认值和 `message` 处理开头，`README.md` 只看了仓库定位。PHP/Node 后端未逐行读。

### dannagle/PacketSender

- 仓库：`dannagle/PacketSender`，HEAD `9714b2ef7ad30b5d19b6c8bb5b0c4a56df65e7d3`（2026-08-08）。克隆：`/tmp/YoAgentResearch/dannagle--PacketSender`。
- 入选理由：TCP/UDP/SSL/HTTP 的发送面板与收发日志是桌面工具箱的成熟形状，和手机「本应用连接检查」同层。
- 架构：`Packet` 保存名称、十六进制负载、ASCII、来源/目的地址、解析后的 IP、错误串、TCP 或 UDP、HTTP 方法与路径。宏替换、十六进制与 ASCII 互转、从 URL 拆主机/端口/方法是纯本地函数。持久连接、组播设置、分包日志分文件。
- 可改编：一次发送就是一条带时间、方向、地址、端口、编码、错误的日志；十六进制与文本两种视图；目标地址可保存。
- 必须改写：绑定与收发走 `@ohos.net.socket`。系统代理用 `getDefaultHttpProxy`，不要另做一套隐藏代理。
- 明确不抄：`udpflooding` 一类流量灌送。工具箱不做洪泛。
- 读过：`src/packet.h` 的字段与转换函数声明，以及源文件列表中的 `packetlogmodel`、`persistentconnection`、`multicastsetup`、`udpflooding` 文件名。`mainwindow.cpp` 未逐段读。

## 横向总结

五个实现分成三类：射频侧只分析扫描缓存（WiFiAnalyzer），传输侧只测量本应用发出的 HTTP/TCP（LibreSpeed、PacketSender、AndroidNetworkTools），整机报文侧依赖特权数据面（PCAPdroid）。鸿蒙普通应用只覆盖前两类，第三类指向开发者选项或 ACL。

共同经验：

- 扫描、过滤、评分、导出分成独立数据，界面不要在一次点击里兼做连接。
- 节流、权限、开关关闭、目标不可达都要变成可见状态，而不是空列表。
- 诊断结果带方法标签：缓存扫描、TCP 连接、HTTP 计时、系统探测、系统带宽估计。
- 日志一行一件事：时间、方向、对端、结果、错误码。

分歧：

- Android 扫描绑定精确位置；鸿蒙现行扫描接口绑定 `SET_WIFI_INFO`，位置权限只出现在已废弃扫描和 `queryTraceRoute`。
- Android 无 root 抓包走本地 VPN；鸿蒙手机抓包走 USB 镜像，应用 VPN 不是抓包入口。
- 桌面 PacketSender 可以原始 UDP；鸿蒙组播有 Socket API，但整机链路层帧没有普通应用入口。

## 与当前工作

`features/wifi_network` 里已有扫描冷却、信道换算、端口队列、HTTP/WebSocket/MQTT、mDNS/SSDP、TCP/UDP 等域类型。那是既有代码上下文。PR #1「补齐工作台、网络与星闪入口页」只是入口页，本轮不把它当成架构，也不改那些文件。

能直接用的结论是权限名、错误码、缓存扫描语义、候选网络与用户确认、`ConnState`、连接属性可能为空、探测与路由跟踪的版本和 ACL。必须改写的是 Android 位置权限、本地 VPN 抓包、原生 ping、公共测速服务器。明确不要用的是洪泛、其他应用阻断、把 RSSI 估算距离或系统带宽估计说成实测。

## 来源与阅读范围

官方镜像，仓库相对路径：

- `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/Connectivity Kit简介.md`
- `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/WLAN服务开发概述.md`
- `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/Wi-Fi扫描开发指南.md`
- `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/STA模式开发指南.md`
- `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/P2P模式开发指南.md`
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/Network Kit简介.md`
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用DNS解析域名.md`
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用Socket访问网络.md`
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用MDNS访问局域网服务.md`
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用HTTP访问网络.md`（场景与权限段，示例未逐行抄）
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/访问网络/使用WebSocket访问网络.md`
- `开发/指南/开发/系统/网络/Network Kit（网络服务）/连接网络/管理网络连接.md`
- `开发/指南/开发/系统/网络/网络调试调优/使用网络报文分析功能实现tcpdump抓包/使用网络报文分析功能实现tcpdump抓包.md`
- `开发/指南/开发/系统/网络/网络调试调优/使用网络领航员进行网络模拟.md`
- `开发/指南/开发/系统/网络/Network Boost Kit（网络加速服务）/Network Boost Kit简介.md`
- `开发/指南/开发/系统/网络/Network Boost Kit（网络加速服务）/开发准备.md`
- `开发/指南/开发/系统/网络/Network Boost Kit（网络加速服务）/网络质量/网络质量评估.md`（只确认它属于加速套件）
- `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/开放权限（系统授权）.md`
- `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/受限开放权限.md`（抽了 Wi-Fi MAC、路由跟踪、流量、IP/MAC、LINKTURBO）
- `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/企业类应用可用权限.md`
- `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/仅MDM应用可用权限.md`（企业 Wi-Fi 条目）
- `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/抓包／调试权限常见问题.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.wifiManager WLAN.md`
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.wifiManagerExt WLAN扩展接口.md`（热点开关废弃标记）
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/错误码/WIFI错误码.md`
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.connection 网络连接管理.md`（事件、属性、探测、路由跟踪、端口表）
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.http 数据请求.md`（方法枚举与 `PerformanceTiming`）
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.socket Socket连接.md`（目录级：TCP/UDP/TLS/组播/LocalSocket）
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.webSocket WebSocket连接.md`（目录级：客户端与 API 19 服务端）
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.mdns MDNS管理.md`（目录级）
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.statistics 流量管理.md`（本应用与 UID 流量）
- `开发/API参考/系统/网络/Network Kit（网络服务）/ArkTS API/ohos.net.ethernet 以太网连接管理.md`

未读因而没有下结论的部分：Network Kit C API 结构体全文、Remote Communication Kit 的拦截器实现、防火墙与 VPN 扩展的调用序列、`ohos.wifi` 已停止维护接口全文、蓝牙/星闪/NFC 章节。

## 入选与落选

入选五份，理由是分别覆盖扫描过滤、整机抓包边界、TCP/端口诊断、HTTP 吞吐、收发日志，结构不重复。

落选：

- `openspeedtest/Speed-Test`：与 LibreSpeed 同为浏览器测速，留 LibreSpeed 的状态机即可。
- `emqx/MQTTX`：MQTT 5 客户端，和「本应用连接检查」相邻，但本轮范围停在传输计时与套接字，不单开协议客户端深研。
- `usebruno/bruno`：YoAgentDocs 已有 HTTP 集合运行笔记，本轮 HTTP 证据用鸿蒙 `PerformanceTiming`。
- aircrack-ng、bettercap、Kismet：攻击、监听或长期采集，不进入工具箱能力表。
