# 05 — HTTP · WebSocket · MQTT 逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` · `feature-inventory/15-PacketSender-源码级逐步流程-v2.md` P-04~P-06/P-16 · `01-功能清单/03-WiFi模块/02-网络协议调试功能清单.md` · `03-UI设计/03-WiFi模块/02-网络协议调试页面设计.md` · PRD `04-WiFi模块PRD.md` §10.2–10.4  
> **范围**：HTTP GET/POST Headers/Auth/Body/文件上传 · WebSocket Client · MQTT Connect/Publish/Subscribe  
> **竞品备注**：PacketSender **仅 HTTP**（无 WS/MQTT）；YoWire PRD 扩展 W-PRO-09/11

---

## 1. 流程总览

```text
WiFi Tab → Segmented [网络调试]
  └── C Segmented：Socket | HTTP | WS | MQTT
        ├── HTTP：GET/POST · Headers · Auth · Body · Upload
        ├── WS：Connect · Subscribe/Send · Close
        └── MQTT：Connect · Publish · Subscribe · QoS/retain
  └── Traffic Log（共用）+ Resend（HTTP/Socket；WS/MQTT 协议差异）
  └── ⚙·命令与面板 / ⚙·会话与日志
```

**P0 约束**：WS/MQTT 为 YoWire 独有；Traffic 与 SessionLog 统一写入 `network_traffic` 类型。

---

## 2. 进入 HTTP / WS / MQTT 子模式

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | WiFi Tab → **网络调试** | 加载 NetDebugPage | `SegmentedControl_netDebug` |
| 步2 | C 栏协议 Segmented 点 **HTTP** | 显示 Request 区 + Method 下拉 | `ProtocolSegmented_http` |
| 步3 | 点 **WS** | 显示 WS URL + Connect + Frame 编辑 | `ProtocolSegmented_ws` |
| 步4 | 点 **MQTT** | 显示 Broker 表单 + Pub/Sub Tab | `ProtocolSegmented_mqtt` |
| 步5 | — | 恢复上次子模式（restoreSession ON） | `restoreSessionPreference` |
| 步6 | 顶栏 **⚙** | push WiFi 设置 | `btnModuleSettings` |
| 步7 | 宽屏 ≥840vp | B 收藏列表 + C 编辑/Traffic 55/45 | `NetDebugSplitLayout` |

---

## 3. HTTP GET 逐步流程（P-04 · W-PRO-05）

### 3.1 基本 GET

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HGET-1 | Method 选 **GET** | Request path 区可见 | `httpMethodCombo` |
| HGET-2 | 填 **Host/Address** | 失焦校验 DNS/IPv4/IPv6 | `packetIPEdit` |
| HGET-3 | 填 **Port** | 空则默认 80 | `packetPortEdit` |
| HGET-4 | 填 **Request** URL path | 如 `/api/v1/status` | `requestPathEdit` |
| HGET-5 | 可选填 **包名** | 保存收藏用 | `packetNameEdit` |
| HGET-6 | 点 **Send** | 发起 HTTP GET；按钮 Loading | `btnSend` |
| HGET-7 | — | Traffic 追加：Time/TO/From/Method/Status/Body 摘要 | `trafficLogTable` |
| HGET-8 | 响应体大 | Traffic 行可展开；完整 body 写 SessionLog | `TrafficRow_expand` |
| HGET-9 | 失败（超时/DNS） | Traffic Error 行 + Toast | `trafficLogTable` |
| HGET-10 | 点 **Save** | 包进 B 栏收藏列表 | `btnSavePacket` |

### 3.2 Headers 与 Auth

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HHDR-1 | 点 **HTTP Headers** 按钮 | 升起 HeadersEditorSheet | `btnHttpHeaders` |
| HHDR-2 | 点 **+ 添加 Header** | Key/Value 行 | `btnAddHeader` |
| HHDR-3 | 填 `Content-Type` 等 | 发送时合并至请求 | `headerKeyValueRow` |
| HHDR-4 | 点 **Apply** | Sheet 关闭；Chip 显示 N headers | `btnHeadersApply` |
| HHDR-5 | ⚙·网络调试·HTTP **Generate Auth Header** ON | 按 Host 自动 Basic | `switchGenerateAuth` |
| HHDR-6 | 点 **HTTP Auth** | Basic Auth 凭证表 Sheet | `btnHttpAuth` |
| HHDR-7 | 填 Username / Password | 生成 `Authorization: Basic …` | `authUserField` / `authPassField` |
| HHDR-8 | 专家：**Bearer Token** | 自定义 Header 或 Auth Tab | `fieldBearerToken` |
| HHDR-9 | 凭证表按 host 存 | 下次同 host 自动应用 | `HttpCredentialTable` |
| HHDR-10 | Send 时 | Headers + Auth 合并；敏感字段 Log 脱敏 | `HttpClient` |

### 3.3 HTTPS GET（P-06 · W-PRO-07）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HSSL-1 | Method/协议选 **HTTPS Get** | Port 默认 443 | `httpMethodCombo` |
| HSSL-2 | ⚙ **Ignore SSL errors** ON | 自签证书可连；Banner 风险 | `switchIgnoreSsl` |
| HSSL-3 | 专家：加载 CA/Cert/Key | TLS 握手用自定义证书 | `btnSslCertPicker` |
| HSSL-4 | Send | HTTPS GET；证书错误按设置处理 | `btnSend` |
| HSSL-5 | 证书错误且未 ignore | Traffic Error + Dialog 是否继续 | `SslErrorDialog` |

---

## 4. HTTP POST 逐步流程（P-05 · W-PRO-06）

### 4.1 Body 与 Generate Data

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HPOST-1 | Method 选 **POST** | Body 编辑区激活 | `httpMethodCombo` |
| HPOST-2 | ASCII/HEX Body 互填 | editingFinished 同步 | `packetASCIIEdit` / `packetHexEdit` |
| HPOST-3 | ⚙ **Adjust Content-Type** ON | 无 Content-Type 时自动补 | `switchAdjustContentType` |
| HPOST-4 | 点 **Generate Data** | Dialog：key=value 多行 | `btnGenerateData` |
| HPOST-5 | Generate Dialog 确认 | 生成 `application/x-www-form-urlencoded` body | `GenerateDataDialog` |
| HPOST-6 | 点 **Send** | POST 请求 + Body | `btnSend` |
| HPOST-7 | — | Traffic 记录 Request/Response 大小 | `trafficLogTable` |

### 4.2 文件上传（Load File · PRD 扩展）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HFILE-1 | 点 **Load File** | DocumentPicker 选文件 | `btnLoadPostFile` |
| HFILE-2 | 选文件成功 | Body 区显示文件名 + 大小；可 HEX 预览 | `postFileChip` |
| HFILE-3 | 大文件 | 警告「将读取至内存」；超阈值需确认 | `LargeFileWarningDialog` |
| HFILE-4 | 自动设 `Content-Type` | 按扩展名或 octet-stream | `switchAdjustContentType` |
| HFILE-5 | Send | multipart 或 raw body（设置可选） | `btnSend` |
| HFILE-6 | 清除文件 | Body 恢复手动编辑 | `btnClearPostFile` |

### 4.3 PUT/PATCH/DELETE（专家 · PRD §10.2）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HREST-1 | Method 选 PUT/PATCH/DELETE | 同 POST Body/Headers 流程 | `httpMethodCombo` |
| HREST-2 | Send | 对应 HTTP 动词 | `btnSend` |
| HREST-3 | 405/501 | Traffic Error 行 | `trafficLogTable` |

### 4.4 HTTP Resend

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HRSN-1 | resendEdit > 0 + Send | 包入 Resend 队列 | `resendEdit` |
| HRSN-2 | — | Chip **Resending (N)** | `chipResending` |
| HRSN-3 | 周期重发 GET/POST | Traffic 多条记录 | `ResendScheduler` |
| HRSN-4 | 点 Chip | cancelResends | `chipResending` |

---

## 5. WebSocket Client 逐步流程（W-PRO-09 · PRD §10.3）

> **竞品**：PacketSender **无** WebSocket；YoWire P0 必达 WF-NET-06。

### 5.1 连接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WS-1 | 协议 Segmented **WS** | 显示 WS URL 栏 | `ProtocolSegmented_ws` |
| WS-2 | 填 **WS URL** | 如 `ws://host:8080/path` 或 `wss://` | `wsUrlField` |
| WS-3 | 点 **Custom Headers** | Sheet：Sec-WebSocket 扩展 headers | `btnWsHeaders` |
| WS-4 | 点 **Connect** | Loading；握手 | `btnWsConnect` |
| WS-5 | 连接成功 | Chip **已连接** 绿；Send 区激活 | `chipWsConnected` |
| WS-6 | 连接失败 | Error Banner + Traffic 行 | `WsErrorBanner` |
| WS-7 | wss 证书错误 | 同 HTTPS ignore SSL 策略 | `switchIgnoreSsl` |
| WS-8 | API 不足（Server 模式） | 本流程仅 Client；Server P2 灰显 | `WsServerGateBanner` |

### 5.2 收发 Frame

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WS-9 | 选 Frame 类型 **文本** | ASCII 编辑区 | `radioWsTextFrame` |
| WS-10 | 选 **二进制** | HEX 编辑区 | `radioWsBinaryFrame` |
| WS-11 | 填 Payload | 字节计数 | `wsPayloadField` |
| WS-12 | 点 **Send** | 发送 Frame；Traffic + Terminal 追加 TX | `btnWsSend` |
| WS-13 | 收到服务端 Frame | 自动 RX 行；Traffic 方向 IN | `trafficLogTable` |
| WS-14 | 宏变量 {{DATE}} 等 | translateMacro ON 时替换 | `translateMacroSendCheck` |
| WS-15 | Ping/Pong（平台支持） | 可选工具栏按钮 | `btnWsPing` |

### 5.3 Subscribe / 主题（YoWire PRD 扩展）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WS-16 | 填 **Subscribe path** 或 STOMP 子协议（专家） | 依 PRD 实现子集 | `wsSubscribeField` |
| WS-17 | 点 **Subscribe** | 注册监听；Log「已订阅 path」 | `btnWsSubscribe` |
| WS-18 | 匹配 path 的 Frame | 高亮 RX 行 | `trafficLogTable` |
| WS-19 | 点 **Unsubscribe** | 取消监听 | `btnWsUnsubscribe` |

### 5.4 关闭连接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WS-20 | 点 **Close** | 发送 Close frame；Chip 灰 | `btnWsClose` |
| WS-21 | 服务端断开 | Banner「连接已关闭」；Send 禁用 | `WsDisconnectBanner` |
| WS-22 | Resend 进行中 Close | Dialog 确认取消 Resend | `WsCloseConfirmDialog` |
| WS-23 | 会话结束 | SessionLog 写入 WS 会话段 | `SessionLogService` |

---

## 6. MQTT 逐步流程（W-PRO-11 · PRD §10.4）

> **竞品**：PacketSender **无** MQTT；YoWire P0 必达 WF-NET-08。

### 6.1 Broker 连接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MQ-1 | 协议 Segmented **MQTT** | 显示 Broker 表单 | `ProtocolSegmented_mqtt` |
| MQ-2 | 填 **Broker Host** | DNS/IP 校验 | `mqttBrokerHost` |
| MQ-3 | 填 **Port** | 默认 1883 | `mqttBrokerPort` |
| MQ-4 | 填 **Client ID** | 空则自动生成 | `mqttClientId` |
| MQ-5 | 可选 Username / Password | CONNECT packet 凭证 | `mqttUsername` / `mqttPassword` |
| MQ-6 | 点 **Connect** | TCP 连接 + MQTT CONNECT | `btnMqttConnect` |
| MQ-7 | CONNACK 成功 | Chip **MQTT 已连接** | `chipMqttConnected` |
| MQ-8 | CONNACK 拒绝 | Error：return code + Traffic | `MqttErrorBanner` |
| MQ-9 | TLS（P1/P2） | ⚙ 证书项；v1 可仅 TCP | `switchMqttTls` |
| MQ-10 | 点 **Disconnect** | DISCONNECT + 关闭 TCP | `btnMqttDisconnect` |

### 6.2 Publish

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MQ-11 | Pub Tab 填 **Topic** | 非空校验 | `mqttPublishTopic` |
| MQ-12 | 填 **Payload** ASCII/HEX | 字节计数 | `mqttPublishPayload` |
| MQ-13 | 选 **QoS** 0/1/2 | QoS2 P1 可降级提示 | `mqttQosPicker` |
| MQ-14 | **Retain** Switch | RETAIN flag | `switchMqttRetain` |
| MQ-15 | 点 **Publish** | PUBLISH packet；Traffic TX 行 | `btnMqttPublish` |
| MQ-16 | QoS1/2 | 等待 PUBACK/PUBCOMP；Log 记录 | `trafficLogTable` |
| MQ-17 | 周期 Publish | resendEdit 或 Dock「周期发送」 | `resendEdit` |
| MQ-18 | 点 **Stop Resending** | 取消周期 Publish | `btnStopPeriodicSend` |

### 6.3 Subscribe

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MQ-19 | Sub Tab 填 **Topic** | 支持 `#` `+` 通配（实现声明） | `mqttSubscribeTopic` |
| MQ-20 | 选 Sub **QoS** | SUBSCRIBE packet | `mqttSubQosPicker` |
| MQ-21 | 点 **Subscribe** | SUBACK；Log「已订阅 topic」 | `btnMqttSubscribe` |
| MQ-22 | 收到 PUBLISH | Traffic RX：topic + payload 摘要 | `trafficLogTable` |
| MQ-23 | 点行展开 | 完整 payload HEX/文本 | `TrafficRow_expand` |
| MQ-24 | 点 **Unsubscribe** | UNSUBSCRIBE | `btnMqttUnsubscribe` |
| MQ-25 | 多 Topic 订阅 | 列表管理已订阅项 | `MqttSubscriptionList` |

### 6.4 收藏与 Panel 衔接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MQ-26 | **Save** Publish 模板 | B 栏收藏；协议 MQTT | `btnSavePacket` |
| MQ-27 | C **从收藏选择** | 载入 Topic/Payload/QoS | `btnFavoritePicker` |
| MQ-28 | ⚙·命令与面板 | MQTT 命令 CRUD | `CommandPanelGroup` |
| MQ-29 | Panel Grid 绑定 | 见 `06-SmartResponse与PanelGrid` | `NavRow_panelGrid` |

---

## 7. Traffic Log 共用流程（WF-NET-11）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| TR-1 | HTTP/WS/MQTT 任意发送 | Traffic 表追加行 | `trafficLogTable` |
| TR-2 | 点 **Clear Log (N)** | 清空 UI；N 归零；SessionLog 策略按设置 | `btnClearTraffic` |
| TR-3 | 点 **Save Log** | 导出 traffic 文件或跳转会话 | `btnSaveLog` |
| TR-4 | 点 **Copy** | 选中行 raw/格式化 | `btnCopyTraffic` |
| TR-5 | **Save as Packet** | 选中响应 → 收藏 | `btnSaveAsPacket` |
| TR-6 | Rolling 上限 | 100 vs 10000 条（⚙ Display） | `rollingLogLimitPreference` |

---

## 8. 宽屏 ≥840vp 逐步摘要

| 步 | 用户动作 | B 栏 | C 栏 |
| --- | --- | --- | --- |
| W-1 | 选 HTTP/WS/MQTT | 收藏/会话列表 | Segmented + 编辑区 |
| W-2 | Send/Connect | 高亮当前包行 | Traffic 上 55% |
| W-3 | 点收藏行 | 预填编辑区 | — |
| W-4 | ⚙ | — | navigate 设置不断 Session |

---

## 9. 异常与空态

| 场景 | 用户路径 | 控件名 |
| --- | --- | --- |
| 无网络 | Banner + Send 禁用 | `NetworkUnavailableBanner` |
| HTTP 413/500 | Traffic Error 行可展开 body | `trafficLogTable` |
| WS 半开连接 | Close 强制断开 | `btnWsClose` |
| MQTT 重复 Client ID | CONNACK 2；提示改 ID | `MqttErrorBanner` |
| 专家关闭 WS/MQTT Tab | 轻量模式隐藏 Segmented 项 | `ProtocolSegmented` |

---

## 10. 验收要点

- [ ] HTTP GET/POST Headers/Auth/Body/Load File 全路径可走通
- [ ] HTTPS ignore SSL 与证书加载互斥逻辑正确
- [ ] WS Connect/Send/Close + Traffic 记录（竞品无对照，PRD P0）
- [ ] MQTT Connect/Publish/Subscribe/QoS/retain（PRD P0）
- [ ] Resend 与 Stop Resending 对 HTTP 生效；MQTT 周期 Publish 可停
- [ ] 敏感 Auth Header Log 脱敏
- [ ] 840vp B 收藏 + C Traffic/编辑，无全局命令 Tab
- [ ] 会话可经 WiFi ⚙·会话与日志导出 TXT/CSV/JSON

---

## 11. 相关文档

| 文档 | 路径 |
| --- | --- |
| Socket/TCP/UDP 主流程 | `02-网络调试逐步交互流程.md` |
| Smart Response / Panel | `06-SmartResponse与PanelGrid逐步交互流程.md` |
| WiFi 设置 | `04-WiFi模块设置与会话命令流程.md` |
| 功能清单 | `../../01-功能清单/03-WiFi模块/02-网络协议调试功能清单.md` |
| PacketSender 证据 | `.research/feature-inventory/15-PacketSender-源码级逐步流程-v2.md` |

---

## 12. HTTP 响应解析与收藏联动

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HR-1 | Traffic 点 HTTP 响应行 | 展开 Status/Headers/Body 摘要 | `TrafficRow_expand` |
| HR-2 | 点 **Save as Packet** | 响应保存为新收藏（POST 模板） | `btnSaveAsPacket` |
| HR-3 | WS 收到 JSON Frame | 可选 Format JSON 预览 | `btnFormatJson` |
| HR-4 | MQTT RX | Topic 分组折叠 | `MqttTrafficGroup` |
| HR-5 | ⚙·命令 **导入 Traffic 行** | 从选中行生成收藏 | `btnImportFromTraffic` |

---

## 13. 与 PacketSender 差异速查

| 能力 | PacketSender | YoWire 本文档 |
| --- | --- | --- |
| HTTP GET/POST | ✓ P-04/P-05 | HGET/HPOST 步表 |
| Headers/Auth | ✓ HTTP Tab | HHDR 步表 |
| HTTPS | ✓ P-06 | HSSL 步表 |
| WebSocket | ✗ | WS-1～WS-23 |
| MQTT | ✗ | MQ-1～MQ-29 |
| Resend | ✓ P-10 | HRSN + 02-网络调试 RS-* |

---

## 14. 折叠屏接续

| 步 | 接续项 | 控件名 |
| --- | --- | --- |
| FC-1 | 协议 Segmented 选中项 | `ProtocolSegmented` |
| FC-2 | HTTP Headers 草稿 | `HeadersEditorSheet` |
| FC-3 | WS URL + 未发送 Payload | `wsUrlField` |
| FC-4 | MQTT 已订阅 Topic 列表 | `MqttSubscriptionList` |

---

## 15. MQTT QoS 与 Will（扩展 · P1）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MQX-1 | QoS 2 选中但 broker 不支持 | 降级 QoS1 + Banner | `mqttQosPicker` |
| MQX-2 | 专家 **Last Will** 配置 | ⚙·网络调试·MQTT Tab | `NavRow_mqttWill` |
| MQX-3 | Connect 带 Will | 断线 broker 发 Will | `btnMqttConnect` |
| MQX-4 | Clean Session Switch | CONNECT flags | `switchMqttCleanSession` |

---

## 16. WebSocket 子协议与 Ping 逐步

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| WSX-1 | Header 填 `Sec-WebSocket-Protocol` | 握手携带 | `btnWsHeaders` |
| WSX-2 | 服务端选子协议 | Log 协商结果 | `trafficLogTable` |
| WSX-3 | 自动 Ping 间隔 ⚙ | 保活帧 | `wsPingIntervalPreference` |
| WSX-4 | Pong 超时 | Banner 断开建议 | `WsDisconnectBanner` |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `02-用户交互流程/03-WiFi模块/` |
| 版本 | 深研草稿 v1 |
| 步骤域 | W-PRO-05~11 · WF-NET-04/06/08 |

