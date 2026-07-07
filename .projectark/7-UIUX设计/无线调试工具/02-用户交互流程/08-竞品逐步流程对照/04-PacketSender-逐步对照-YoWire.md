# 04 — PacketSender 逐步对照 YoWire

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **竞品**：[05-PacketSender-全量功能清单.md](../../01-功能清单/09-竞品APP功能清单/05-PacketSender-全量功能清单.md)  
> **YoWire 流程**：[02-网络调试…](../03-WiFi模块/02-网络调试逐步交互流程.md) · [05-HTTP-WebSocket-MQTT…](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) · [06-SmartResponse与PanelGrid…](../03-WiFi模块/06-SmartResponse与PanelGrid逐步交互流程.md)  
> **深研**：`.research/feature-inventory/15-PacketSender-源码级逐步流程-v2.md`

---

## 0. 映射总览

| 竞品流程 P-* | 竞品区域 | YoWire 主文档 | YoWire 步号域 |
| --- | --- | --- | --- |
| P-01～P-03 | TCP/UDP/SSL Client | 02 §4～§6 | P01-* · P02-* · P03-* |
| P-04～P-06 | HTTP/HTTPS | 02 §7～§8 · **05** | P04-* · P05-* · HTTP-* |
| P-07 | Save/Load 包 | 02 §9 · 04 设置 | SAV-* |
| P-08 | Server Respond | 02 §10 · 06 Smart | SMR-* |
| P-11 | Traffic Log | 02 §3 | TRF-* |
| P-12～P-16 | Panel / Resend Stop | **06** | PNL-* · RS-* |
| **GAP WS/MQTT** | **竞品无** | **05 only** | WS-* · MQTT-* |

**GAP 专节**：

| GAP ID | PacketSender | YoWire |
| --- | --- | --- |
| PS-GAP-01/02 | 无 WebSocket Client/Server | WF-NET-06/07 · [05](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) |
| PS-GAP-03 | 无 MQTT | WF-NET-08 · [05](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) |
| IA | Qt 单窗三区 | WiFi B 会话 + C Traffic/Terminal |
| SessionLog | saveLogButton 文件 | ⚙·会话 TXT/CSV/JSON |

---

## 1. 主窗三区 → YoWire 网络调试布局

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| 0-布局 | 包编辑 + Saved + Traffic | mainwindow 三区 | 步2 · §3 | `trafficLogTable` + 包编辑区 | [02 §3](../03-WiFi模块/02-网络调试逐步交互流程.md) | **IA 差**：YoWire 上 Traffic 下 Terminal |
| 0-状态栏 | UDP/TCP/SSL/DTLS 按钮 | 右下角 Server toggle | §10 | `serverStatusButtons` | 02 §10 | 对齐 PS-SRV-16 |
| 0-Settings | File→Settings 四 Tab | Network/HTTP/Display/Smart | 04 | `WifiSettingsPage` | [04](../03-WiFi模块/04-WiFi模块设置与会话命令流程.md) | 进 WiFi ⚙ |

---

## 2. P-01 TCP 客户端 → 02 §4

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-01-1 | 协议选 TCP | udptcpComboBox | P01-1 | `protocolComboBox` | 02 §4 | 对齐 PS-PRO-01 |
| P-01-2 | 填 Address | packetIPEdit 失焦校验 | P01-2 | `packetIPEdit` | 02 §4 | 对齐 PS-CLI-02 |
| P-01-3 | 填 Port | packetPortEdit Invalid Port | P01-3 | `packetPortEdit` | 02 §4 | 对齐 PS-CLI-03 |
| P-01-4 | ASCII/HEX 互同步 | packetASCIIEdit/HexEdit | P01-4 | `packetASCIIEdit` · `packetHexEdit` | 02 §4 | 对齐 PS-CLI-04/05 |
| P-01-5 | Resend Delay 秒 | resendEdit oneDecimal | P01-5 | `resendEdit` | 02 §4 · §3.3 | 对齐 PS-CLI-08 |
| P-01-6 | 点 Send | testPacketButton → sendPacket | P01-6 | `btnSend` | 02 §4 | 对齐 PS-CLI-10 |
| P-01-7 | Traffic Log 追加 | trafficLogTable | P01-7 | `trafficLogTable` | 02 §4 | 对齐 PS-TRF-01 |
| P-01-8 | Resend>0 入队 | Resending (N) 状态栏 | P01-8 · RS-1 | `chipResending` | 02 §3.3 | 对齐 |
| P-01-9 | Persistent TCP + Resend | 警告多连接 | P01-9 | `switchPersistentTcp` | 02 §4 | 对齐 PS-CLI-14 |

---

## 3. P-02 UDP + 组播 → 02 §5

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-02-1～6 | 同 P-01 协议 UDP | — | P02-1～2 | `protocolComboBox` | 02 §5 | 对齐 PS-PRO-02 |
| P-02-7 | 组播未 join 弹窗 | Join multicast? | P02-3～4 | `MulticastJoinDialog` | 02 §5 | 对齐 PS-CLI-16 |
| P-02-8 | 255.255.255.255 洪泛 | traffic flooding 确认 | P02-5 | `FloodRiskDialog` | 02 §5 | 对齐 PS-CLI-17 |

---

## 4. P-03 SSL · P-06 HTTPS → 02 §6

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-03-1 | 协议 SSL/HTTPS | QSslSocket.supportsSsl | P03-1 | `protocolComboBox` | 02 §6 | 对齐 PS-PRO-03/07/08 |
| P-03-2 | 不支持 SSL 警告 return | 对话框 | P03-2 | `SslUnsupportedBanner` | 02 §6 | 对齐 PS-CLI-18 |
| P-03-3 | 握手写 Traffic | 算法名 | P03-3 | `trafficLogTable` | 02 §6 | 对齐 |
| P-03-4 | ignoreSSLCheck 默认 true | settings | P03-4 | `ignoreSSLCheckPreference` | 02 §6 · 04 | 对齐 |
| P-06-1 | HTTPS port 443 | 默认 | P06 | `packetPortEdit` | 02 §6 · 05 | 对齐 |

---

## 5. P-04 HTTP GET · P-05 POST → 02 §7 + 05

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-04-1 | HTTP Get | Request/Address/Port 80 | P04-1 | `ProtocolSegmented_http` · `requestPathEdit` | 02 §7 · [05 §2](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) | 对齐 PS-PRO-05 |
| P-04-2 | 整 URL 粘贴 Request | 自动 host/port/path | P04-2 | `requestPathEdit` paste parser | 02 §7 · 05 | 对齐 PS-CLI-07 |
| P-04-3 | Send GET | Traffic 显示 headers+body | P04-3 | `btnSend` | 02 §7 | 对齐 |
| P-05-1 | HTTP Post + Data | Generate Data 对话框 | P05-1～3 | `httpPostDataField` · `GenerateDataDialog` | 02 §8 · 05 §3 | 对齐 PS-PRO-06 |
| P-05-4 | Load File body | POST 文件 | P05-4 | `btnLoadPostFile` | 05 §3 | 对齐 PS-CLI-12 |
| P-05-5 | Content-Type 自动 | httpAdjustContentTypeCheck | P05-5 | `adjustContentTypePreference` | 04 · 05 | 对齐 settings |
| — | Auth Header 生成 | HTTP Tab 凭证表 | HTTP-A1 | `btnGenerateAuthHeader` | 05 §4 | 对齐 settings §8.2 |

---

## 6. P-07 保存/加载包 → 02 §9

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-07-1 | Save → packets.ini | savePacketButton | SAV-1 | `btnSavePacket` | 02 §9 | HarmonyOS 本地 DB |
| P-07-2 | 单击 packetsTable 加载 | 编辑区回填 | SAV-2 | `savedPacketTable` | 02 §9 | 对齐 PS-SAV-* |
| P-07-3 | searchLineEdit 过滤 | 已保存表 | SAV-3 | `searchSavedPackets` | 02 §9 | 对齐 |
| P-07-4 | Delete 多选 | removeFromDBList | SAV-4 | `btnDeletePacket` | 02 §9 | 对齐 |

---

## 7. P-08 Server Respond · P-11 Traffic → 02 §10 + 06

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-08-1 | Respond to all | sendReponse + Response payload | SMR-0 | `switchServerRespondAll` | 02 §10 · [06 §2](../03-WiFi模块/06-SmartResponse与PanelGrid逐步交互流程.md) | 对齐 PS-SRV-10 |
| P-08-2 | Smart Response 规则 1～5 | Settings Smart Tab | SMR-1～5 | `smartRuleRow1_5` | 06 §3 | 对齐 PS-SMR-* |
| P-11-1 | trafficLogTable 排序 | 列 Time/Dir/From/To… | TRF-1 | `trafficLogTable` | 02 §3.1 | 对齐 PS-TRF-01 |
| P-11-2 | Clear Log (N) | trafficLogClearButton | TRF-2 | `btnClearTraffic` | 02 §3.1 | 对齐 PS-TRF-02 |
| P-11-3 | Save Traffic → Saved | saveTrafficPacket | TRF-4 | `btnSaveAsPacket` | 02 §3.1 | 对齐 PS-TRF-04 |
| P-11-4 | Copy / Save Log 文件 | toClipboard · saveLogButton | TRF-5～6 | `btnCopyTraffic` · `btnSaveLog` | 02 §3.1 | **增值** ⚙ SessionLog |

---

## 8. P-12～P-16 Panel / Resend Stop → 06

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-12-1 | Generate Panel | generatePanelButton 多选 | PNL-1 | `btnGeneratePanel` | 06 §4 | 对齐 PS-PNL-* |
| P-12-2 | Panel HTML 网格 | panelgenerator | PNL-2 | `PanelGridWebView` | 06 §5 | YoWire 原生 Grid |
| P-13-1 | Persistent Connection 窗 | TCP/SSL 长连接 | P13 | `PersistentConnectionSheet` | 02 · 06 | 对齐 README |
| P-14-1 | 状态栏 Server 一键 toggle | UDP/TCP/SSL/DTLS | SRV-T1 | `serverStatusButtons` | 02 §10 | 对齐 PS-SRV-16 |
| P-15-1 | stopResendingButton | 清 packetsRepeat | RS-5 | `chipResending` tap cancel | 02 §3.3 · 06 §6 | 对齐 |
| P-16-1 | Intense Traffic / WOL / Subnet | Toolbar Tools | — | LAN 模式 | [03-LAN](../03-WiFi模块/03-LAN与诊断逐步交互流程.md) | YoWire LAN 分离模块 |

---

## 9. GAP — WebSocket / MQTT（YoWire-only · 05）

> PacketSender **无** WS/MQTT — 以下行 **竞品步号** 标 `—`；YoWire 独有。

### 9.1 WebSocket Client/Server

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **无 WS Client** | — | WS-C1 | `ProtocolSegmented_ws` | [05 §5](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) | **YoWire P0 PS-GAP-01** |
| — | 填 ws:// URL | — | WS-C2 | `wsUrlField` | 05 §5 | YoWire-only |
| — | Connect + 发帧 | — | WS-C3～6 | `btnWsConnect` · `btnWsSend` | 05 §5 | YoWire-only |
| — | **无 WS Server** | — | WS-S1 | `switchWsServerEnable` | 05 §6 | **YoWire P2 PS-GAP-02** |
| — | 入站帧 Traffic | — | WS-S2 | `trafficLogTable` | 05 §6 | YoWire-only |

### 9.2 MQTT Pub/Sub

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| — | **无 MQTT** | — | MQTT-1 | `ProtocolSegmented_mqtt` | [05 §7](../03-WiFi模块/05-HTTP-WebSocket-MQTT逐步交互流程.md) | **YoWire P0 PS-GAP-03** |
| — | Broker host/port | — | MQTT-2 | `mqttBrokerField` | 05 §7 | YoWire-only |
| — | Connect + Subscribe | — | MQTT-3～5 | `btnMqttConnect` · `mqttTopicSubscribe` | 05 §7 | YoWire-only |
| — | Publish QoS | — | MQTT-6 | `btnMqttPublish` | 05 §7 | YoWire-only |
| — | 消息 Traffic | — | MQTT-7 | `trafficLogTable` | 05 §7 | YoWire-only |

**设计边界**：HTTP GET/POST 在 **02 + 05** 双线对照 PacketSender P-04～06；WS/MQTT **仅 05**，不强行虚构竞品步号。

---

## 10. Settings 四 Tab → WiFi ⚙ 映射

| 竞品 Tab | 竞品 key 示例 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Network | udpServerEnable · sendReponse | SET-NET | `udpServerEnable` 等 | 04 §网络服务 | 对齐 inventory 15 §8.1 |
| HTTP | Auth Header 凭证表 | SET-HTTP | `httpCredentialTable` | 04 · 05 §4 | 对齐 §8.2 |
| Display | rolling500 · restoreSession | SET-DISP | `rollingLogPreference` | 04 | 对齐 §8.3 |
| Smart Responses | responseEnableCheck#N | SET-SMR | `smartResponseEnable` | 04 · 06 | 对齐 §8.4 |

---

## 11. Smart Response 匹配语义对照

| 竞品 Match method | packet.cpp 行为 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Starts With | data.startsWith | SMR-M1 | `smartMatchStartsWith` | 06 §3 | 1:1 |
| Contains | data.contains | SMR-M2 | `smartMatchContains` | 06 §3 | 1:1 |
| Ends With | data.endsWith | SMR-M3 | `smartMatchEndsWith` | 06 §3 | 1:1 |
| Exact Match | testData==data | SMR-M4 | `smartMatchExact` | 06 §3 | 1:1 |
| macroSwap {{DATE}} | translateMacroSendCheck | SMR-M5 | `translateMacroOnSend` | 06 §3 · 04 | 对齐 |

---

## 12. 840vp · SessionLog GAP

| 竞品 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| 单窗三区固定 | Qt mainwindow | W-NET | B 会话列表 C Traffic+编辑 | 02 · doc 16 | **GAP-840** |
| saveLogButton 单文件 | Traffic 导出 | TRF → ⚙ | `NavRow_netSessions` | 04 · [06](../06-统一后端/01-会话日志导出逐步交互流程.md) | 多格式 SessionLog |
| Panel HTML | panelgenerator | PNL | ⚙·命令 Panel Grid 编辑 | 06 · 04 | 编辑仅在 ⚙ |

---

## 13. P-01～P-16 逐步索引表

| 竞品步号 | 流程名 | YoWire 主文档 | YoWire 步号前缀 | 差异摘要 |
| --- | --- | --- | --- | --- |
| P-01 | TCP Client | 02 §4 | P01-* | 对齐 |
| P-02 | UDP 组播 | 02 §5 | P02-* | 对齐 |
| P-03 | SSL Client | 02 §6 | P03-* | 对齐 |
| P-04 | HTTP GET | 02 §7 · 05 | P04-* | 对齐 |
| P-05 | HTTP POST | 02 §8 · 05 | P05-* | 对齐 |
| P-06 | HTTPS | 02 §6 · 05 | P06-* | 对齐 |
| P-07 | Save/Load | 02 §9 | SAV-* | 对齐 |
| P-08 | Server Respond | 02 §10 · 06 | SMR-* | Smart 在 06 |
| P-11 | Traffic Log | 02 §3 | TRF-* | SessionLog 增值 |
| P-12～13 | Panel / Persistent | 06 | PNL-* | 对齐 |
| P-14 | Server toggle | 02 §10 | SRV-T1 | 对齐 |
| P-15 | Stop Resend | 02 §3.3 · 06 | RS-* | 对齐 |
| P-16 | Tools WOL/Subnet | 03-LAN | L-* | YoWire 分离 |
| **—** | **WebSocket** | **05 only** | WS-* | **YoWire-only GAP** |
| **—** | **MQTT** | **05 only** | MQTT-* | **YoWire-only GAP** |

---

## 14. 验收勾选

- [ ] P-01～P-08 TCP/UDP/SSL/HTTP 可走通  
- [ ] Traffic Clear/Save/Copy 对齐 P-11  
- [ ] Smart Response 5 规则 + 匹配语义  
- [ ] Panel Grid 生成与运行（06）  
- [ ] **WS/MQTT 05 文档** 不依赖 PacketSender 竞品步  
- [ ] Resend 队列 + Stop（RS-5）  
- [ ] ⚙ SessionLog 导出  

---

## 15. 证据索引

| 键 | 路径 |
| --- | --- |
| 竞品清单 | `09/05-PacketSender-全量功能清单.md` |
| inventory 15 | `.research/feature-inventory/15-PacketSender-源码级逐步流程-v2.md` |
| inventory 22 | `22-YoWire-PRD与竞品能力差距矩阵-v2.md` E-PS-GAP-* |
| doc 16 | `16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |

---

## 16. DTLS 与 Server 子流程

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-03-D1 | DTLS Cipher Suite | 主窗下拉 | P03-D1 | `dtlsCipherSuitePicker` | 02 §6 | Qt6+ |
| P-03-D2 | DTLS Server CN | CN 字段 | P03-D2 | `dtlsServerCnField` | 02 §6 | 对齐 |
| P-03-D3 | DTLS Persistent | checkbox | P03-D3 | `switchDtlsPersistent` | 04 | 对齐 |
| P-08-1 | Respond to all | sendReponse | SMR-0 | `switchServerRespondAll` | 06 §2 | 对齐 |
| P-14-1 | 状态栏 Server toggle | UDP/TCP/SSL/DTLS | SRV-T1 | `serverStatusButtons` | 02 §10 | 对齐 |

---

## 17. HTTP 凭证表（Settings §8.2）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| HTTP-S1 | Generate Auth ON | httpAuthCheck | HTTP-A1 | `switchHttpAuth` | 05 §4 · 04 | 对齐 |
| HTTP-S2 | Host/UN/PW | 表单 | HTTP-A2 | `httpAuthFields` | 05 §4 | 对齐 |
| HTTP-S3 | Basic Auth 按钮 | 写凭证表 | HTTP-A3 | `btnGenerateBasicAuth` | 05 §4 | 对齐 |
| HTTP-S4 | 自定义 Header | HTTP Header 按钮 | HTTP-A4 | `btnCustomHttpHeader` | 05 §4 | 对齐 |

---

## 18. Panel Grid（P-12 → 06）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| P-12-1 | 多选 Saved 包 | packetsTable | PNL-1 | `savedPacketMultiSelect` | 06 §4 | 对齐 |
| P-12-2 | Generate Panel | HTML 网格 | PNL-2 | `btnGeneratePanel` | 06 §4 | YoWire 原生 |
| P-12-3 | Panel 按钮 Send | onclick | PNL-3 | `PanelGridButton` | 06 §5 | 语义对齐 |
| P-12-4 | autolaunch panel | Display 设置 | PNL-4 | `autolaunchPanelPreference` | 06 · 04 | 对齐 |

---

## 19. WS/MQTT 验收边界（YoWire-only）

| 协议 | 竞品 P-* | YoWire 文档 | 验收要点 |
| --- | --- | --- | --- |
| WebSocket Client | — | 05 §5 | 不得回退到 P-01 TCP 语义 |
| WebSocket Server | — | 05 §6 | P2 可选 |
| MQTT Pub/Sub | — | 05 §7 | Broker+Topic+QoS |
| 与 Smart Response | P-08 无 WS | 06 + 05 | 入站匹配仍用 SMR |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `08-竞品逐步流程对照/` |
| 版本 | 深研草稿 v0.1 |
