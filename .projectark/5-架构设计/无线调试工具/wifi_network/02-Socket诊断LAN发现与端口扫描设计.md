# Socket、网络诊断、LAN 发现与端口扫描设计

## 1. 官方能力边界

依据 WSL Network Kit 官方文档：

1. `@ohos.net.socket` 支持 TCPSocket、UDPSocket、WebSocket、TLSSocket。
2. Socket API 建议放在 Worker 或 TaskPool 中执行，否则可能导致 UI 线程卡顿。
3. UDP 使用前需 `constructUDPSocketInstance()`，发送前需 `bind()`。
4. UDP `send()` 需要 `INTERNET`。
5. UDP 支持 `message`、`listening`、`close`、`error` 事件，必须有 `off`。
6. UDP 错误码常见映射为 `2301000 + Linux errno`。
7. Multicast 支持 `constructMulticastSocketInstance()`、`addMembership()` 等能力，API 26 增加 `setReuseAddress()`。
8. WebSocket 独立在 `ohos.net.webSocket`，不混入 Socket 终端的 TCP/UDP 设计。
9. 应用进入后台后网络连接可能断开，前台恢复时必须 reconcile 并必要时重建 socket。

## 2. 功能范围

首期实现：

1. Ping/DNS/HTTP/TCP 连通性诊断。
2. TCP Client。
3. TCP Server。
4. UDP 终端。
5. UDP 广播。
6. Multicast 实验入口。
7. LAN 主机发现。
8. TCP 端口扫描。
9. UDP 探测。
10. 扫描任务取消。
11. 前后台恢复。

暂不承诺：

1. 完整 ICMP Traceroute，需平台验证。
2. 原始 socket 或 root 能力。
3. 高强度公网扫描。

## 3. Socket 工作台架构

```text
SocketWorkbench
  TcpClientSession
  TcpServerSession
    TcpAcceptedConnectionSession[]
  UdpSession
  MulticastSession
```

统一接口：

```text
NetworkTransportSession
  sessionId
  protocol: tcp_client | tcp_server_connection | udp | multicast
  state
  localAddress
  remoteAddress?
  write(payload, options)
  close()
  observeMessage()
  observeState()
```

## 4. TCP Client

### 4.1 数据流

```text
TcpClientViewModel.connect()
  -> OpenTcpClientUseCase
  -> EnsurePermission(INTERNET)
  -> TcpSocketDataSource.construct
  -> socket.on(message/close/error)
  -> connect(host, port)
  -> SessionRuntimeStore.connected
```

### 4.2 状态

```text
TcpClientState
  idle
  resolving
  connecting
  connected
  sending
  halfClosed
  reconnecting
  closing
  closed
  failed
```

### 4.3 模型

```text
TcpClientConfig
  host
  port
  family: ipv4 | ipv6 | domain
  connectTimeoutMs
  readMode: stream
  autoReconnect
  socks5Proxy?
```

## 5. TCP Server

功能：

1. 绑定本地端口。
2. 监听连接。
3. 显示客户端列表。
4. 单客户端发送。
5. 广播发送。
6. 关闭客户端。
7. 停止 server。

会话关系：

```text
TcpServerSession
  serverSessionId
  bindAddress
  port
  state
  clients: TcpServerClient[]

TcpServerClient
  clientId
  remoteAddress
  connectedAtMs
  bytesIn
  bytesOut
```

日志：

1. server listen/close 为 internal。
2. client connect/close 为 state。
3. client payload 为 inbound/outbound，附 `clientId`。

## 6. UDP 与 Multicast

### 6.1 UDP Session

创建流程：

```text
constructUDPSocketInstance()
  -> on('message')
  -> on('close')
  -> on('error')
  -> bind(localAddress)
  -> ready
```

发送前约束：

1. 必须已 bind。
2. 必须有 remote address 或本次发送指定 address。
3. 广播前必须显式开启 broadcast extra option。
4. 广播发送在 UI 上标注局域网影响。

模型：

```text
UdpSessionConfig
  localAddress
  localPort
  defaultRemoteAddress?
  defaultRemotePort?
  allowBroadcast
  proxy?
```

### 6.2 Multicast

实验能力：

1. 创建 MulticastSocket。
2. 可选 `setReuseAddress(true)`，仅 API 26+。
3. bind `0.0.0.0:port`。
4. addMembership(group)。
5. receive/send。
6. dropMembership/close。

限制：

1. 不默认后台运行。
2. 网络切换后重新加入组。
3. API 版本不足时隐藏 reuseAddress。

## 7. 网络诊断

### 7.1 DiagnosticPipeline

```text
NetworkDiagnosticPlan
  targetHost
  targetPort?
  steps:
    networkState
    dnsLookup
    tcpConnect
    httpProbe
    pingLike
    tracerouteLike
```

步骤输出：

```text
DiagnosticStepResult
  step
  state: pending | running | success | failed | skipped
  startAtMs
  endAtMs
  latencyMs?
  nativeCode?
  appCode?
  detail
```

### 7.2 Traceroute 边界

普通应用可用能力不一定支持传统 ICMP TTL 控制。设计：

1. 先做 Capability 探测。
2. 不可用时提供 TCP connect path 近似诊断。
3. UI 明确写“非 ICMP Traceroute”。
4. 不调用未公开 shell 命令作为默认实现。

## 8. LAN 主机发现

### 8.1 数据流

```text
StartLanDiscoveryUseCase
  -> get current network prefix
  -> generate candidate IPs
  -> PortScanQueue with concurrency limit
  -> tcp connect / udp probe / mdns result merge
  -> HostDiscoveryStore
  -> LogCaptureService(metric)
```

### 8.2 模型

```text
LanDiscoveryConfig
  cidr
  method: tcpProbe | udpProbe | mixed
  probePorts: number[]
  timeoutMs
  concurrency
  includeMdns
  includeSsdp

LanHostResult
  ip
  hostName?
  macVisible: false
  aliveState: alive | unknown | unreachable
  latencyMs?
  openPorts: PortProbeResult[]
  firstSeenAtMs
  lastSeenAtMs
```

## 9. 端口扫描

### 9.1 扫描限制

1. 默认只允许私有网段。
2. 公网地址或大范围扫描需要二次确认。
3. 并发默认 32，上限由设置控制。
4. 每个扫描任务必须有取消令牌。
5. 页面退出不自动后台继续扫描。

### 9.2 状态

```text
PortScanState
  idle
  preparing
  running
  cancelling
  completed
  cancelled
  failed
```

### 9.3 结果

```text
PortProbeResult
  host
  port
  protocol: tcp | udp
  state: open | closed | filtered | unknown
  latencyMs?
  bannerRef?
  error?
```

## 10. 后台与恢复

进入后台：

1. TCP/UDP 终端记录 lifecycle。
2. LAN/端口扫描暂停或取消，按用户设置决定。
3. 长连接若用户允许，尝试后台任务；否则标记可能中断。

回到前台：

1. 查询 socket state。
2. 若已断开，更新 UI，不沿用旧 connected。
3. 自动重连仅对用户开启的 TCP Client 生效。
4. Server 端口监听失败时提示重新启动。

## 11. 错误与降级

| 场景 | appCode | 处理 |
| --- | --- | --- |
| 无 INTERNET | `YW-PERM-2001` | 请求权限 |
| UDP 未 bind 发送 | `YW-NET-2101` | 禁用发送 |
| 端口占用 | `YW-NET-2102` | 更换端口 |
| Socket errno | `YW-NET-2103` | 保留 native 2301000+errno |
| 后台断连 | `YW-NET-2104` | 前台 reconcile |
| 扫描范围过大 | `YW-NET-2201` | 二次确认或拒绝 |
| 任务取消 | `YW-NET-2202` | 标记 cancelled |

## 12. 验证清单

1. TCP Client 连接本地 server。
2. TCP Client 断网重连。
3. TCP Server 多客户端。
4. TCP Server 广播发送。
5. UDP bind 后收发。
6. UDP 未 bind 发送禁止。
7. UDP broadcast。
8. Multicast 加入/退出组。
9. Socket error 进入日志。
10. 后台后前台 reconcile。
11. LAN 扫描取消。
12. 端口扫描并发限制。
13. 私有网段默认限制。
14. 大范围扫描二次确认。
