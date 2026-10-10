---
id: checklist.wifi-network
type: checklist
status: active
when: research
when_to_use: 验收 Wi-Fi 与网络调试能力是否按官方边界可观察、可二判时
related: [research.wifi-network, rule.common.acceptance]
---

# Wi-Fi 与网络调试验收清单

每条只判定一个可见结果。证据是界面文案、错误码、或本应用日志行。实现类名不作为通过条件。

标记含义：

| 标记 | 判定 |
| --- | --- |
| 普通应用 | 仅用 normal 级系统授权权限，必要时加上文档写明的用户授权位置权限，在 Phone 真机上可出现该结果 |
| 受限 | 文档把该权限放在受限开放或企业列表，未获 AGC 授权时必须出现拒绝结果，不能出现成功数据 |
| 系统或企业 | 文档写明仅系统应用或企业/MDM 应用可用。普通安装包必须出现拒绝或入口不可用 |
| 开发者选项 | 结果只出现在系统设置或 PC 工具里，应用内入口必须说明路径 |
| 缺口 | 官方结构没有该字段或没有对等 API。界面必须标明未提供，不能填估算值冒充测量值 |
| 真机 | 模拟器与真机差异已在文档中写明，模拟器上的失败不能记成功能通过 |

计数以文末汇总为准。研究依据见 `docs/goal/research/wifi-network.md`。

## 权限与能力

- [ ] **WN-001** [普通应用] Given 安装包已声明 `ohos.permission.GET_WIFI_INFO`、`SET_WIFI_INFO`、`GET_NETWORK_INFO`、`INTERNET`，When 打开 Wi-Fi 调试页，Then 不出现运行时授权弹窗。
- [ ] **WN-002** [普通应用] Given 未声明 `GET_WIFI_INFO`，When 读取 WLAN 开关或连接信息，Then 界面显示权限被拒绝及错误码 201，列表不为成功空态。
- [ ] **WN-003** [普通应用] Given 未声明 `SET_WIFI_INFO`，When 点击刷新扫描，Then 扫描不启动，界面显示错误码 201。
- [ ] **WN-004** [普通应用] Given 未声明 `INTERNET`，When 发起 DNS 或 HTTP，Then 请求失败且可见错误码 201。
- [ ] **WN-005** [普通应用] Given 未声明 `GET_NETWORK_INFO`，When 读取默认网络或路由，Then 失败可见，不显示编造的网关。
- [ ] **WN-006** [普通应用] Given 设备返回错误码 801，When 查看对应能力，Then 文案为「本机不支持」并带 801，而不是无限加载。
- [ ] **WN-007** [普通应用] Given 调用 `isFeatureSupported`，When 查看能力页，Then 分别显示基础结构、5 GHz、Wi-Fi Direct、Soft AP、SAE、增强开放的支持与否，每项为是或否。
- [ ] **WN-008** [受限] Given 未授予 `GET_WIFI_PEERS_MAC`，When 查看扫描行与已连接 BSSID，Then 地址类型为随机设备地址，或界面标明随机地址。
- [ ] **WN-009** [受限] Given 未授予 `GET_WIFI_LOCAL_MAC` 且设备不是已开放该权限的 PC/2in1，When 读取本机 WLAN MAC，Then `macAddress` 为空或界面写明无权限，不显示占位 MAC。
- [ ] **WN-010** [系统或企业] Given 普通签名应用，When 点击打开系统 WLAN 或关闭系统 WLAN，Then 操作失败并说明需要系统应用或企业权限，WLAN 开关状态保持不变。

## WLAN 状态

- [ ] **WN-011** [普通应用] Given WLAN 已打开，When 进入状态页，Then 显示已激活。
- [ ] **WN-012** [普通应用] Given 用户在系统设置关闭 WLAN，When 调试页仍在前台，Then 状态变为未激活，已连接详情被清空或标为 STA 未打开。
- [ ] **WN-013** [普通应用] Given 已订阅开关事件，When 系统设置打开 WLAN，Then 日志按顺序出现 ENABLING 与 ENABLED 中实际回调到的状态，最终显示已激活。
- [ ] **WN-014** [普通应用] Given WLAN 关闭，When 读取连接信息，Then 得到错误码 2501001，界面写明 STA 未打开。
- [ ] **WN-015** [普通应用] Given WLAN 已连接，When 查看 `isConnected`，Then 显示已连接。
- [ ] **WN-016** [普通应用] Given WLAN 打开但未关联 AP，When 查看 `isConnected`，Then 显示未连接，且不保留上一次 SSID。
- [ ] **WN-017** [普通应用] Given 热点由系统打开，When 查看热点状态，Then `isHotspotActive` 为是。
- [ ] **WN-018** [系统或企业] Given 普通应用，When 查找打开热点的操作，Then 没有可用的打开热点动作；废弃接口不被当成成功路径。

## 扫描、过滤与信道

- [ ] **WN-019** [普通应用] Given WLAN 已打开且位于前台，When 第一次点击扫描并等到 `wifiScanStateChange` 为 1，Then 列表来自随后的 `getScanInfoList`，每行至少有 SSID、加密类型、RSSI（dBm）、频率、带宽。
- [ ] **WN-020** [普通应用] Given 距上次成功扫描不足 30 秒且未再调用 `startScan`，When 只刷新列表，Then 界面标明「缓存」并显示缓存时间，不把该次刷新写成新扫描。
- [ ] **WN-021** [普通应用] Given 前台 2 分钟内已经成功发起 4 次 `startScan`，When 第 5 次点击扫描，Then 扫描不启动，界面显示剩余冷却，已有列表仍保留。
- [ ] **WN-022** [普通应用] Given 应用在后台，When 距离上次后台扫描不足 30 分钟再次扫描，Then 扫描被拒绝或无新的成功事件，前台恢复后能看到该次未执行。
- [ ] **WN-023** [普通应用] Given `wifiScanStateChange` 回调为 0，When 查看列表，Then 显示扫描失败，不清空上一次成功结果，除非上一次也不存在。
- [ ] **WN-024** [普通应用] Given WLAN 关闭，When 点击扫描，Then 不出现新的 AP 列表，提示先打开 WLAN。
- [ ] **WN-025** [普通应用] Given 正在关联 AP，When 此时点击扫描，Then 遵守指南「连接过程中不允许扫描」：失败可见，或系统未给出新结果时界面不显示成功。
- [ ] **WN-026** [普通应用] Given 设备静止并返回 `moving freeze scanning control`，When 查看扫描，Then 文案说明静止管控，并保留错误码 2501000。
- [ ] **WN-027** [普通应用] Given 扫描结果含多条记录，When 按 SSID 子串过滤，Then 只保留 SSID 包含该子串的行，清空过滤后行数恢复。
- [ ] **WN-028** [普通应用] Given 结果含不同 RSSI，When 只保留信号档 0–4 中的某一档，Then 其他档消失；档位来自 `getSignalLevel` 或与之相同的 0–4 划分，并在行上同时保留 dBm。
- [ ] **WN-029** [普通应用] Given 结果含 OPEN、PSK、SAE、EAP 中至少两种，When 按一种加密类型过滤，Then 只剩该类型。
- [ ] **WN-030** [普通应用] Given 结果同时有 2.4 GHz 与 5 GHz，When 只选 2.4 GHz，Then 频率落在 5 GHz 的行消失。
- [ ] **WN-031** [普通应用] Given 同一 SSID 有多条 BSSID，When 按 SSID 分组，Then 组内仍能展开每一条的频率与 RSSI。
- [ ] **WN-032** [普通应用] Given 列表不少于两条，When 按 RSSI 从强到弱排序，Then 第一条 RSSI 大于或等于最后一条。
- [ ] **WN-033** [普通应用] Given 已知频率，When 查看信道列，Then 信道号由频率换算并标注「由频率换算」，API 未返回信道号时不显示成驱动字段。
- [ ] **WN-034** [普通应用] Given 2.4 GHz 上有重叠 AP，When 打开信道占用，Then 每个信道显示落入其频率范围的 AP 数量，当前已连接 AP 在「最强干扰」统计中被排除。
- [ ] **WN-035** [普通应用] Given 存在占用很低的信道，When 查看推荐信道，Then 推荐列表只含干扰强度为最低两档的信道，并写明这是重叠估计。
- [ ] **WN-036** [缺口] Given 任意扫描结果，When 查找噪声、SNR、MCS、重传次数，Then 这些列标明未提供，单元格不是 0 或空被当成测量值。平台墙：`WifiScanInfo` 没有这四列，本树也不显示「未提供」。
- [ ] **WN-037** [普通应用] Given 扫描进行中，When 点击暂停，Then 不再发起新的 `startScan`，已显示的缓存保留。
- [ ] **WN-038** [普通应用] Given 用户导出当前列表，When 打开导出文本，Then 含 SSID、频率、RSSI、加密、时间戳，不含候选网络密钥。
- [ ] **WN-039** [真机] Given 仅模拟器，When 对照真机扫描，Then 模拟器结果不作为扫描通过证据；记录写明未用真机。

## 已连接链路

- [ ] **WN-040** [普通应用] Given 已连接到 AP，When 打开链路页，Then 显示 SSID、RSSI dBm、频率、上行速率 Mbps、下行速率 Mbps、信道带宽、Wi-Fi 标准、`ConnState` 为 CONNECTED。
- [ ] **WN-041** [普通应用] Given 链路含最大协商上下行速率，When 查看速率，Then 协商速率与瞬时 `linkSpeed` 分成两行。
- [ ] **WN-042** [普通应用] Given RSSI 发生变化且已订阅 `wifiRssiChange`，When 信号变化，Then 链路页 RSSI 更新为新的 dBm。
- [ ] **WN-043** [普通应用] Given `getSignalLevel` 输入当前 RSSI 与频段，When 查看档位，Then 显示 0 到 4 的整数，并同时显示原始 dBm。
- [ ] **WN-044** [普通应用] Given 连接的是隐藏网络，When 查看链路，Then 隐藏标记为是。
- [ ] **WN-045** [普通应用] Given `isRestricted` 为 true，When 查看链路，Then 显示数据量受限。
- [ ] **WN-046** [普通应用] Given API 18 且 `wifiLinkType` 有值，When 查看链路，Then 显示默认、Wi-Fi 7 单链路、MLSR、EMLSR 或 STR 之一。API 低于 18 时该行写明当前系统无此字段。
- [ ] **WN-047** [普通应用] Given 已连接，When 查看 IPv4，Then 地址为点分十进制，并有网关、掩码、主 DNS、备 DNS、DHCP 服务器与租约秒数；数值 0 的字段显示为未获得而不是 `0.0.0.0` 被当成有效地址。
- [ ] **WN-048** [普通应用] Given 网络有 IPv6，When 查看 IPv6，Then 显示链路地址、全局地址、网关与 DNS。随机全局地址字段按文档「暂不支持」显示为未提供。
- [ ] **WN-049** [缺口] Given 已连接，When 查找噪声底或 SNR，Then 标明未提供。平台墙：`WifiLinkedInfo` 没有这两列，本树也不显示「未提供」。
- [ ] **WN-050** [普通应用] Given 用户开启距离估算，When 查看 AP 详情，Then 距离标注「按自由空间路径损耗估算」，单位米，并同时保留 RSSI 与频率。

## 连接与认证

- [ ] **WN-051** [普通应用] Given WLAN 已打开且密钥满足 PSK 最短 8 字节，When 添加 PSK 候选网络并连接，Then 日志出现 `CONNECTING` 或 `AUTHENTICATING` 之后的终态：`CONNECTED` 或 `UNKNOWN`。
- [ ] **WN-052** [普通应用] Given 加密类型为 OPEN，When 提交非空密钥，Then 提交前被拒绝并说明开放网络密钥必须为空，不调用添加接口。
- [ ] **WN-053** [普通应用] Given 加密类型为 WEP，When 尝试加入候选网络，Then 界面说明候选配置不支持 WEP，不把失败显示成密码错误。
- [ ] **WN-054** [普通应用] Given SAE 网络且密钥至少 1 字节，When 添加并连接，Then 终态为已连接或带 Wi-Fi 错误码的失败。
- [ ] **WN-055** [普通应用] Given EAP-PEAP 且身份或密码为空，When 提交，Then 本地校验失败并指出空字段，不发送空身份。
- [ ] **WN-056** [普通应用] Given 隐藏 SSID 且 `isHiddenSsid` 为 true，When 用完整 SSID 添加候选网络，Then 配置可被 `getCandidateConfigs` 列出。
- [ ] **WN-057** [普通应用] Given 使用 `connectToCandidateConfigWithUserAction`，When 用户拒绝，Then 界面显示错误码 2501006，连接状态不是 CONNECTED。
- [ ] **WN-058** [普通应用] Given 使用用户确认连接且用户在超时前没有操作，When 对话框结束，Then 显示错误码 2501005。
- [ ] **WN-059** [普通应用] Given 使用不带用户确认的 `connectToCandidateConfig`，When 连接结束，Then 界面不出现「用户已允许」或「用户已拒绝」字样。
- [ ] **WN-060** [普通应用] Given 候选网络 ID 小于 0，When 调用用户确认连接，Then 显示参数校验失败 2501007。
- [ ] **WN-061** [普通应用] Given 已添加候选网络，When 移除该配置后再连接同一 ID，Then 连接失败可见，列表中不再有该 SSID。
- [ ] **WN-062** [系统或企业] Given 普通应用，When 对系统已保存网络调用断开当前 STA，Then 失败可见，系统连接保持到用户在系统设置中断开。
- [ ] **WN-063** [受限] Given 普通应用没有 `GET_WIFI_CONFIG`，When 读取系统已保存的预共享密钥，Then 不显示 PSK，失败原因为企业权限。
- [ ] **WN-064** [普通应用] Given 密钥输入框，When 离开页面或导出日志，Then 日志与导出文件中的密钥为掩码，不明文出现。

## 重连与默认网络

- [ ] **WN-065** [普通应用] Given 已订阅 `wifiConnectionChange`，When 系统设置中断开 WLAN，Then 调试页状态变为 DISCONNECTED 或 UNKNOWN，时间顺序晚于断开动作。
- [ ] **WN-066** [普通应用] Given 候选网络仍在且 WLAN 已打开，When 用户再次连接该候选网络，Then 新的一次日志以新的时间开始，不覆盖上一次终态。
- [ ] **WN-067** [普通应用] Given 已注册默认网络回调，When 从无网络连上 Wi-Fi，Then 先出现 `netAvailable`，并伴随能力或属性变化；`netId` 不为 0。
- [ ] **WN-068** [普通应用] Given 从未连上任何网络，When 注册回调，Then 出现 `netUnavailable`，且在此之前没有 `netAvailable`。
- [ ] **WN-069** [普通应用] Given 同时有 Wi-Fi 与蜂窝，When Wi-Fi 断开并落到蜂窝，Then 日志先记录 Wi-Fi `netLost`，再记录蜂窝 `netAvailable`。
- [ ] **WN-070** [普通应用] Given 能力位含 `CHECKING_CONNECTIVITY`，When 查看上网状态，Then 不把 `VALIDATED` 显示为最终结论，文案为检测中。
- [ ] **WN-071** [普通应用] Given 能力位含 `PORTAL`，When 查看上网状态，Then 显示需要门户认证。
- [ ] **WN-072** [普通应用] Given 只有 `NET_CAPABILITY_INTERNET` 且没有 `VALIDATED`，When 查看上网状态，Then 文案为「网络提供者标记可上网，连通性未验证」。
- [ ] **WN-073** [普通应用] Given 默认网络被系统阻塞，When `netBlockStatusChange` 的 blocked 为 true，Then 界面显示网络阻塞。

## 地址、DNS、路由与端口

- [ ] **WN-074** [普通应用] Given 已有默认网络，When 查看连接属性，Then 显示网卡名、MTU；路由每条含目的前缀、网关、是否默认路由。
- [ ] **WN-075** [普通应用] Given `linkAddresses`、`routes` 或 `dnses` 为空，When 打开属性页，Then 对应区块显示「系统未返回」，不崩溃，不补 0.0.0.0。
- [ ] **WN-076** [普通应用] Given API 24 且属性含地址族有效位，When 查看 IPv4/IPv6，Then 分别显示可用或不可用。低于该版本时写明无此字段。
- [ ] **WN-077** [普通应用] Given 有默认网络且声明 `INTERNET`，When 解析一个公网域名，Then 结果至少有一条 IP，并标明使用的是默认网络。
- [ ] **WN-078** [普通应用] Given `netId` 为 0，When 解析域名，Then 失败可见，不返回空字符串当成成功。
- [ ] **WN-079** [普通应用] Given API 23 且主机名含中文，When 先转 ASCII 再解析，Then 界面同时显示 Unicode 与转码后的主机名；未转码失败时错误与转码后的结果分成两次记录。
- [ ] **WN-080** [普通应用] Given API 23，When 指定只要 IPv4，Then 结果地址族为 IPv4；指定 IPv6 时地址族为 IPv6 或明确失败。
- [ ] **WN-081** [普通应用] Given 用户输入非法主机名，When 解析，Then 失败可见，不发起后续端口扫描。
- [ ] **WN-082** [受限] Given 没有 `ACCESS_NET_TRACE_INFO` 或没有精确位置授权，When 点击路由跟踪，Then 失败码 201 或位置未授权，不显示跳数表。
- [ ] **WN-083** [受限] Given 已具备路由跟踪权限且 API 不低于 26.0.0，When 对可达 IP 跟踪且最大跳数为 5，Then 每跳有序号、地址、以及 4 个 RTT 统计值，跳数不超过 5。
- [ ] **WN-084** [普通应用] Given API 不低于 26.0.0 且只有 `INTERNET`，When 对可达主机探测 3 秒，Then 显示丢包率 0–100 与 4 个 RTT 统计，并标明方法为系统探测。
- [ ] **WN-085** [普通应用] Given 探测过程中关闭网络，When 探测尚未到时，Then 立即结束并显示失败，而不是停在进度上。
- [ ] **WN-086** [普通应用] Given API 低于 26.0.0，When 打开探测与路由跟踪，Then 两项标明当前系统版本没有该接口。
- [ ] **WN-087** [普通应用] Given 用户对私网地址做 TCP 端口检查且超时已设置，When 端口可连接，Then 该端口记为开，记录含地址、端口、耗时。
- [ ] **WN-088** [普通应用] Given 端口无服务，When TCP 连接超时或被拒绝，Then 该端口记为未打开或未知，不记为开。
- [ ] **WN-089** [普通应用] Given 端口检查进行中，When 用户取消，Then 不再出现新的端口结果，已完成的行保留。
- [ ] **WN-090** [受限] Given 没有 `GET_IP_MAC_INFO`，When 查看整机 TCP/UDP 监听表或邻居 MAC，Then 拒绝可见，不列出其他进程的端口。

## 吞吐

- [ ] **WN-091** [普通应用] Given 用户填写的 HTTP 下载地址可访问，When 开始测速，Then 进度从下载阶段更新，结束后显示 Mbps，且与系统带宽估计不是同一字段。
- [ ] **WN-092** [普通应用] Given 下载进行中，When 用户中止，Then 未完成请求停止，终态为中止，速率不写成完成值。
- [ ] **WN-093** [普通应用] Given 同一轮测速包含上传，When 下载已结束，Then 才进入上传阶段，两段速率分开。
- [ ] **WN-094** [普通应用] Given `linkDownBandwidthKbps` 为 0，When 查看系统估计，Then 显示「无法评估」，不显示 0 Mbps。
- [ ] **WN-095** [普通应用] Given 一次 HTTP 请求返回 `PerformanceTiming`，When 查看该次请求，Then 分列 DNS、TCP、TLS、首字节、总完成时间，单位毫秒。
- [ ] **WN-096** [普通应用] Given 测速地址不可达，When 开始，Then 失败原因可见，进度回到未开始。

## 本应用连接检查

- [ ] **WN-097** [普通应用] Given 用户指定可达 TCP 主机与端口，When 连接并发送一段文本，Then 日志有去向、地址、端口、字节数、成功。
- [ ] **WN-098** [普通应用] Given TCP 对端关闭，When 会话仍打开，Then 日志出现关闭，发送按钮不可用直到重新连接。
- [ ] **WN-099** [普通应用] Given UDP 目标可达，When 发送一份数据报，Then 日志标明 UDP、目标地址与字节数；没有连接成功字样。
- [ ] **WN-100** [普通应用] Given 本机 TCP 服务已监听，When 另一台设备连入并发送字节，Then 服务端日志出现对端地址与收到的字节数。
- [ ] **WN-101** [普通应用] Given TLS 服务证书与主机名匹配，When 建立 TLS，Then 会话标记为 TLS，错误日志不含私钥。
- [ ] **WN-102** [普通应用] Given 证书主机名不匹配，When 连接，Then 失败可见，不把会话标为已加密成功。
- [ ] **WN-103** [普通应用] Given WebSocket 服务可连，When 发送一条文本，Then 日志有发出与收到，断开后不能继续发送。
- [ ] **WN-104** [普通应用] Given API 不低于 19，When 启动本应用 WebSocket 服务并让客户端连入，Then 能看到客户端连接与一条消息。API 更低时入口标明不可用。
- [ ] **WN-105** [普通应用] Given HTTP GET 与 POST 各一次，When 查看交换日志，Then 方法、URL、状态码、耗时分别存在；响应体可展开。
- [ ] **WN-106** [普通应用] Given 用户取消进行中的 HTTP，When 取消完成，Then 该条状态为已取消，没有状态码 200。
- [ ] **WN-107** [普通应用] Given 系统设置了 HTTP 代理，When 查看网络页，Then 显示 `getDefaultHttpProxy` 的主机与端口；排除列表按返回值显示。
- [ ] **WN-108** [普通应用] Given 明文 HTTP 被网络安全配置禁止，When 请求 http URL，Then 失败说明明文被拒绝。
- [ ] **WN-109** [普通应用] Given 组播地址与端口合法且当前网络允许，When 加入组并收到一份数据报，Then 日志含组地址。失败时显示 Socket 错误码，不重试成死循环。
- [ ] **WN-110** [普通应用] Given 本应用流量查询 API 不低于 22，When 查询最近 1 天 Wi-Fi 流量，Then 显示本应用收发字节。查询早于 31 天的起点时显示错误码 2103019。
- [ ] **WN-111** [受限] Given 没有 `GET_NETWORK_STATS`，When 查询其他应用 UID 流量，Then 拒绝可见，不出现其他应用的字节数。

## 局域网发现

- [ ] **WN-112** [普通应用] Given 已连接 Wi-Fi 且局域网有 `_http._tcp` 服务，When 开始 mDNS 发现，Then 出现 `serviceFound`，行内有服务名、类型、端口。
- [ ] **WN-113** [普通应用] Given 发现进行中且对端服务下线，When 收到 `serviceLost`，Then 该行从在线列表消失或标为离开。
- [ ] **WN-114** [普通应用] Given 用户停止发现，When 再无新服务上线，Then 不再新增行。
- [ ] **WN-115** [普通应用] Given WLAN 未连接，When 开始 mDNS，Then 失败可见并提示需要 Wi-Fi，不显示旧局域网的服务为在线。
- [ ] **WN-116** [普通应用] Given 本机发布一条本地服务，When 同一局域网另一发现端查询，Then 能看到所填服务名与端口；本机移除后对端收到离开。
- [ ] **WN-117** [普通应用] Given 服务类型为空，When 开始发现，Then 本地拒绝并说明类型为空，不调用开始搜索。

## 抓包、加速与权限墙

- [ ] **WN-118** [开发者选项] Given Phone 或 Tablet 已开开发者模式且 USB 连接到 Windows，When 用户按指南打开网络报文分析，Then 应用内只提供说明：开关在开发者选项，抓包在 PC 的 Wireshark，且与 USB 调试互斥。应用内没有开始抓包按钮。
- [ ] **WN-119** [开发者选项] Given USB 未连接，When 查看报文分析说明，Then 写明开关会不可用。
- [ ] **WN-120** [支持] Given 普通应用，When 查找捕获其他应用流量或导出整机 pcap 的动作，Then 没有该动作。证据：`features/wifi_network` 与 `product/phone` 没有该动作。未在真机执行，射频仍是待真机。
- [ ] **WN-121** [缺口] Given PC/2in1 上的普通界面应用，When 查找 PF_PACKET 原始帧，Then 说明仅限带 `kernel.NET_RAW` 且 sudo 的二进制，本应用不提供。平台墙：本应用没有原始套接字，也没有这条说明文案。
- [ ] **WN-122** [开发者选项] Given 手机或平板开发者选项，When 查看弱网模拟，Then 应用内说明场景在网络领航员，入口不是应用内的带宽滑杆。
- [ ] **WN-123** [受限] Given 没有 `LINKTURBO`，When 查看多网并发，Then 标明需要受限权限，不发起多网激活。
- [ ] **WN-124** [真机] Given 模拟器，When 打开 P2P 或 VPN 或网络加速，Then 界面写明模拟器不支持对应项，不把失败记成真机缺陷。
- [ ] **WN-125** [受限] Given 没有 `GET_WIFI_PEERS_MAC`，When 发起 P2P 连接，Then 失败可见；P2P 页写明模拟器不支持。
- [ ] **WN-126** [受限] Given 没有以太网本机 MAC 权限，When 在 Phone 上读取以太网 MAC，Then 拒绝可见。
- [ ] **WN-127** [系统或企业] Given 普通应用，When 查找防火墙规则编辑，Then 没有编辑入口；说明该能力面向企业或系统应用且当前仅 2in1 可申请。

## 日志与失败总则

- [ ] **WN-128** [普通应用] Given 任一成功的扫描、连接、探测或 HTTP，When 打开会话日志，Then 每行有时间、动作、终态。
- [ ] **WN-129** [普通应用] Given 错误码 2501000、2501001、2501005、2501006、2501007 之一，When 查看该行，Then 同时有数字码和一句对应说明：操作失败、STA 未打开、用户未响应、用户拒绝、参数无效。
- [ ] **WN-130** [普通应用] Given 日志超过一屏，When 清空，Then 列表为空，下一次新动作仍能写入。
- [ ] **WN-131** [普通应用] Given 页面离开，When 再进入，Then 订阅成对取消，不会对同一次开关事件写出两行重复来源。
- [ ] **WN-132** [支持] Given 任意页面，When 查找洪泛、其他应用阻断、密码破解，Then 没有这些入口。证据：`features/wifi_network`、`product/phone` 路由和命令模板都没有这三类动作。未在真机执行，射频仍是待真机。

## 汇总

一条只归入一个主标记。编号 WN-001 至 WN-132 连续，无缺号。普通应用条目里包含权限失败、缓存语义、版本无字段和取消路径，那些路径的期望结果仍是普通安装包上可见的失败或说明。

| 主标记 | 条数 |
| --- | --- |
| 普通应用 | 108 |
| 受限 | 10 |
| 系统或企业 | 4 |
| 开发者选项 | 3 |
| 缺口 | 3 |
| 支持 | 2 |
| 真机 | 2 |
| 合计 | 132 |
