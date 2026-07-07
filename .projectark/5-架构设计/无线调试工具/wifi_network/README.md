# WiFi 与网络模块详细设计索引

本目录细化 WiFi 与网络模块设计。依据 PRD、`03-WiFi与网络模块架构设计.md`、WSL 官方参考文档中的 WLAN、Network Kit Socket、HTTP、WebSocket、mDNS、后台网络恢复和权限约束编写。

## 文档列表

1. `01-WiFi扫描STA信息与环境分析设计.md`
   - WiFi 状态、扫描结果、链路信息、信道/RSSI、权限和扫描频率限制。
2. `02-Socket诊断LAN发现与端口扫描设计.md`
   - TCP/UDP/Multicast、网络诊断、LAN 主机发现、端口扫描、并发和后台恢复。
3. `03-HTTP-WebSocket-MQTT调试设计.md`
   - HTTP 请求、流式响应、WebSocket Client/Server、MQTT 选型和统一日志。

## 模块总原则

1. WiFi 控制类功能受系统/企业权限限制，不作为普通应用默认主路径。
2. WiFi 扫描不是无限制实时能力，必须设计扫描冷却、缓存标注和后台降级。
3. Socket、HTTP、WebSocket 需要 `INTERNET`，耗时网络操作避免阻塞 UI。
4. HTTP 请求对象不可复用，用完必须 `destroy()`。
5. WebSocket `connect` 返回请求创建结果，真实连接以 `open` 事件为准。
6. LAN 扫描和端口扫描必须可取消、有限并发、可审计。
