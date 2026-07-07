# PacketSender 全量功能清单（竞品深研）

> **状态**：深研草稿，未定稿  
> **定位**：YoWire WiFi·网络协议调试模块的 **上游竞品能力全集**；功能 ID 前缀 **PS-***  
> **上游**：Packet Sender（Dan Nagle / NagleCode，GPLv2+）  
> **证据**：`.research/feature-inventory/06-PacketSender-全量功能清单-v2.md`、`15-PacketSender-源码级逐步流程-v2.md` · [packetsender.com](https://packetsender.com/) · [GitHub dannagle/PacketSender](https://github.com/dannagle/PacketSender) · [Debian man packetsender(1)](https://manpages.debian.org/trixie/packetsender/packetsender.1.en.html)  
> **YoWire 产品化正文**：`03-WiFi模块/02-网络协议调试功能清单.md`（WF-NET-*）  
> **显式 GAP**：上游 **无 WebSocket、无 MQTT** → YoWire PRD **WF-NET-06/08** 为独有扩展（E-PS-GAP-01/02）

---

## 1. 文档目的

将 PacketSender 桌面 Qt 主程序、CLI、官网文档与 **已归档 Xamarin 移动版** 的能力，枚举为可验收的 **PS-*** 功能 ID，供 YoWire 网络调试子模块对标、差距矩阵与 UI 设计引用。本文 **复述竞品**，不替代 YoWire PRD。

---

## 2. 应用版本与平台基线

| 项 ID | 项 | 内容 | 证据 |
| --- | --- | --- | --- |
| PS-APP-01 | 桌面主分支 | Qt/C++；Win / Mac / Desktop Linux 官方支持 | E-PS-003 |
| PS-APP-02 | 许可 | GPLv2 或更新；商用/个人均可 | E-PS-003 README |
| PS-APP-03 | 移动 Android（旧） | **Xamarin.Forms C#**，仓库 **ARCHIVED** | [Packet_Sender_Mobile](https://github.com/dannagle/Packet_Sender_Mobile) |
| PS-APP-04 | 移动 Android（新） | Kotlin + Jetpack Compose 重写；Play `com.packetsender.compose`；维护状态不稳定 | GitHub Discussion #219 |
| PS-APP-05 | 移动 iOS | 原生 Swift；App Store 在售 | packetsender.com Downloads |
| PS-APP-06 | CLI | `packetsender.com`（Win）/ `packetsender`（Linux/Mac）；`.exe` 启动 GUI | E-PS-005 man page |
| PS-APP-07 | 深研主证据 | **桌面 Qt 源码** + 官网文档；移动仅作 IA 对照 | 本清单 §20 |

**YoWire 对标基准**：以 **桌面 Qt v8.x 能力** 为主（Panel / Smart Response / SSL / HTTP / DTLS / Intense Traffic）；HarmonyOS 实现不复制 Cloud/CLI/WOL（WF-NET-18 P3）。

---

## 3. 信息架构（桌面 GUI 主窗）

桌面版为 **单窗三区 + 状态栏 + Settings 四 Tab**；移动 Xamarin 版简化为 **Bottom Tab：Client / Servers / Traffic / Saved / Settings**（无 Panel 独立入口、无 HTTP/SSL 完整集）。

```text
PacketSender Desktop（Qt mainwindow）
├── ① 包编辑区（Client 发送）
├── ② 已保存包表（Saved Packets）
├── ③ Traffic Log（底部表）
├── 状态栏：UDP/TCP/SSL/DTLS 端口按钮 · Resending(N) · IPv4/IPv6 切换
├── File → Settings → Network | HTTP | Display | Smart Responses
└── Toolbar：Panels · Tools（WOL · Subnet · Intense Traffic · Multicast）
```

| IA ID | 桌面区域 | 移动 Tab（Xamarin 归档） | PS-ID 前缀 |
| --- | --- | --- | --- |
| PS-IA-01 | 包编辑区 | **Client** | PS-CLI-* |
| PS-IA-02 | 状态栏四协议 Server 按钮 | **Servers** | PS-SRV-* |
| PS-IA-03 | Traffic Log 表 | **Traffic** | PS-TRF-* |
| PS-IA-04 | 已保存包表 + 搜索 | **Saved** | PS-SAV-* |
| PS-IA-05 | Settings 四 Tab | **Settings**（子项较少） | PS-SET-* |

---

## 4. 八种发送协议（PS-PRO-*）

协议下拉 `udptcpComboBox` + `Packet::isTCP/isUDP/isSSL/isHTTP/isHTTPS/isPOST()`（`packet.cpp` L61–96）。

| 功能 ID | 协议 | Client | Server 监听 | HTTP 字段 | 默认端口 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| PS-PRO-01 | **TCP** | ✓ | ✓ Network Tab | — | 用户指定 | E-PS-003 P-01 |
| PS-PRO-02 | **UDP** | ✓ | ✓ | — | 用户指定 | P-02 |
| PS-PRO-03 | **SSL**（加密 TCP） | ✓ | ✓ | — | 用户指定 | P-03 |
| PS-PRO-04 | **DTLS** | ✓ GUI（Win 完整；他平台需 Qt6 编译） | ✓ | Cipher Suite · Persistent Session | 用户指定 | packetsender.com DTLS 节 |
| PS-PRO-05 | **HTTP Get** | ✓ | — | Name · **Request** · Address · Port | 80 | E-PS-002 |
| PS-PRO-06 | **HTTP Post** | ✓ | — | + **Data** · Generate Data · Load File | 80 | P-05 |
| PS-PRO-07 | **HTTPS Get** | ✓ | — | 同 HTTP + SSL 握手 | 443 | P-06 |
| PS-PRO-08 | **HTTPS Post** | ✓ | — | 同左 | 443 | P-06 |

**YoWire 无对标项（竞品空白）**：

| GAP ID | 协议 | PacketSender | YoWire | 证据 |
| --- | --- | --- | --- | --- |
| PS-GAP-01 | WebSocket Client | **✗** | WF-NET-06 P0 | E-PS-GAP-01 |
| PS-GAP-02 | WebSocket Server | **✗** | WF-NET-07 P2 | E-PS-GAP-01 |
| PS-GAP-03 | MQTT Pub/Sub | **✗** | WF-NET-08 P0 | E-PS-GAP-02 |

---

## 5. Client Tab / 包编辑区（PS-CLI-*）

| 功能 ID | 名称 | 控件 / 行为 | 协议范围 | 证据 |
| --- | --- | --- | --- | --- |
| PS-CLI-01 | 包名称 | `packetNameEdit` | 全部 | mainwindow.cpp |
| PS-CLI-02 | 目标地址 | `packetIPEdit`；失焦校验 IPv4/IPv6/DNS | TCP/UDP/SSL/DTLS/HTTP(S) | P-01 |
| PS-CLI-03 | 端口 | `packetPortEdit`；≤0 → "Invalid Port" | 同上 | P-01 |
| PS-CLI-04 | ASCII Payload | `packetASCIIEdit`；与 HEX 互相同步 | TCP/UDP/SSL/DTLS/HTTP POST | P-01 |
| PS-CLI-05 | HEX Payload | `packetHexEdit`；容错分隔符自动纠正 | 同上 | packetsender.com GUI |
| PS-CLI-06 | Request URL 路径 | `requestPathEdit`；HTTP(S) 显示 | HTTP/HTTPS | E-PS-002 |
| PS-CLI-07 | 整 URL 粘贴解析 | Request 粘贴完整 URL → 自动填 host/port/path | HTTP(S) | README L371–381 |
| PS-CLI-08 | Resend Delay | `resendEdit`；秒，一位小数 `Packet::oneDecimal` | TCP/UDP/SSL/DTLS/HTTP(S) | P-01 §10 |
| PS-CLI-09 | 协议下拉 | `udptcpComboBox` 八种 | — | §4 |
| PS-CLI-10 | Send | `testPacketButton` → `emit sendPacket` | 全部 Client | P-01 |
| PS-CLI-11 | Save 到 DB | `savePacketButton` → `packets.ini` | 全部 | P-07 |
| PS-CLI-12 | Load File → HEX | 文件载入 HEX；上限 ~10,922 字节（GUI） | TCP/UDP/SSL/POST body | GUI 文档 |
| PS-CLI-13 | Generate Data（POST） | Key/Value 对话框 → `key=value&…` | HTTP(S) POST | P-05 |
| PS-CLI-14 | Persistent TCP 勾选 | 主窗 checkbox；TCP/SSL 打开独立窗 | TCP/SSL/HTTPS | P-13 |
| PS-CLI-15 | 混合 ASCII+HEX 编码 | 标准 PS 混排记法 | 全部 payload | packetsender.com |
| PS-CLI-16 | 组播发送确认 | 目标组播且未 join → 弹窗 Join multicast? | UDP | P-02 |
| PS-CLI-17 | 广播洪泛警告 | 255.255.255.255 + Server Respond 开 → 确认 | UDP | P-02 |
| PS-CLI-18 | SSL 不支持检测 | `QSslSocket::supportsSsl()` 失败则警告 return | SSL/HTTPS | P-03 |
| PS-CLI-19 | DTLS Cipher Suite 下拉 | 主窗 DTLS 专用控件 | DTLS | DTLS 文档 |
| PS-CLI-20 | DTLS Server Common Name | 客户端校验 CN 字段 | DTLS Client | DTLS 文档 |
| PS-CLI-21 | DTLS Persistent Session | 首次握手后保存 session key | DTLS | DTLS 文档 |
| PS-CLI-22 | DTLS Optional Server Verification | 双向校验选项 | DTLS | DTLS 文档 |

### 5.1 快捷键（PS-CLI-HOT-*）

| 功能 ID | 快捷键 | 目标字段 | 证据 |
| --- | --- | --- | --- |
| PS-CLI-HOT-01 | Ctrl+1（Mac ⌘+1） | Name | E-PS-002 文档 |
| PS-CLI-HOT-02 | Ctrl+2 | ASCII | 同上 |
| PS-CLI-HOT-03 | Ctrl+3 | HEX | 同上 |
| PS-CLI-HOT-04 | Ctrl+4 | Address | 同上 |
| PS-CLI-HOT-05 | Ctrl+5 | Port | 同上 |
| PS-CLI-HOT-06 | Ctrl+6 | Resend Delay | 同上 |
| PS-CLI-HOT-07 | Ctrl+7 | Protocol | 同上 |
| PS-CLI-HOT-08 | Ctrl+8 | Send 执行 | 同上 |
| PS-CLI-HOT-09 | 协议下拉内 t/u/s/h + ↑↓ | 快速选 TCP/UDP/SSL/HTTP | 同上 |

### 5.2 逐步流程索引（Client 发送）

| 流程 ID | 名称 | 关联 PS-ID | 深研 |
| --- | --- | --- | --- |
| PS-FLOW-01 | TCP Client 发送 | PS-PRO-01, PS-CLI-* | P-01 |
| PS-FLOW-02 | UDP + 组播 | PS-PRO-02, PS-CLI-16/17 | P-02 |
| PS-FLOW-03 | SSL Client | PS-PRO-03, PS-SSL-* | P-03 |
| PS-FLOW-04 | HTTP GET | PS-PRO-05, PS-HTTP-* | P-04 |
| PS-FLOW-05 | HTTP POST + Generate Data | PS-PRO-06 | P-05 |
| PS-FLOW-06 | HTTPS GET/POST | PS-PRO-07/08 | P-06 |

---

## 6. Servers Tab / 内置服务端（PS-SRV-*）

主窗右下角 **UDP / TCP / SSL / DTLS** 状态按钮切换；Settings Network Tab 配置端口与行为。

| 功能 ID | 名称 | settings key / 行为 | 证据 |
| --- | --- | --- | --- |
| PS-SRV-01 | UDP Server Enable | `udpServerEnable` | settings.cpp L230+ |
| PS-SRV-02 | UDP Port(s) | `udpPort`；`0`=随机；逗号多端口 | E-PS-002 Basic Settings |
| PS-SRV-03 | TCP Server Enable | `tcpServerEnable` | 同上 |
| PS-SRV-04 | TCP Port(s) | `tcpPort`；与 SSL 非零端口不可冲突 | 同上 |
| PS-SRV-05 | SSL Server Enable | `sslServerEnable` | 同上 |
| PS-SRV-06 | SSL Port(s) | `sslPort` | 同上 |
| PS-SRV-07 | DTLS Server Enable | `dtlsServerEnable`（Qt6+） | DTLS 文档 |
| PS-SRV-08 | DTLS Port(s) | `dtlsPort` | 同上 |
| PS-SRV-09 | DTLS Send Simple Ack | Network Tab checkbox | DTLS Settings |
| PS-SRV-10 | Respond to all requests | `sendReponse` — 入站统一回复同一 payload | P-08 §8.1 |
| PS-SRV-11 | Response ASCII/HEX | `responseHex` + Load saved packet | 同上 |
| PS-SRV-12 | Receive Before Send | `attemptReceiveCheck` — 服务端先发（telnet 类） | E-PS-002 |
| PS-SRV-13 | 500 ms delay after connect | `delayAfterConnectCheck` — 慢设备 | 同上 |
| PS-SRV-14 | 入站 Persistent 连接 | 服务端 accept → 打开 PersistentConnection 窗 | README Persistent |
| PS-SRV-15 | Smart Response 入站匹配 | 见 PS-SMR-*；DTLS 亦支持 | DTLS Smart 节 |
| PS-SRV-16 | 状态栏一键切换 Server | 点 UDP/TCP/SSL/DTLS 按钮 toggle enable | P-14 |
| PS-SRV-17 | Settings OK 后重启网络栈 | `packetNetwork.kill()` → `init()` | mainwindow.cpp |

**CLI Server 模式**（PS-SRV-CLI-*）：`packetsender -l [-t|-u|-s] -b <port> -B <ip> -r "{{TIME}}"`（E-PS-005）。

---

## 7. Traffic Log Tab（PS-TRF-*）

| 功能 ID | 名称 | 控件 / 行为 | 证据 |
| --- | --- | --- | --- |
| PS-TRF-01 | 日志表 | `trafficLogTable`；可排序 | P-11 |
| PS-TRF-02 | Clear Log (N) | `trafficLogClearButton`；N 计数归零 | 同上 |
| PS-TRF-03 | Log toggle | Settings Rolling 500 → max 100 vs 10000 | settings rolling500entryCheck |
| PS-TRF-04 | Save Traffic Packet | 选中行 → 命名 → `saveToDB()` 进 Saved | P-11 |
| PS-TRF-05 | Copy | `toClipboardButton`；formatted vs raw（copyUnformattedCheck） | 同上 |
| PS-TRF-06 | Save Log 导出文件 | `saveLogButton` 完整 traffic 导出 | 同上 |
| PS-TRF-07 | 列：Time | 时间戳 | packetTableHeaders |
| PS-TRF-08 | 列：Direction | 收/发 | 同上 |
| PS-TRF-09 | 列：From | 源地址 | 同上 |
| PS-TRF-10 | 列：To | 目标地址 | 同上 |
| PS-TRF-11 | 列：Method | 协议方法 | 同上 |
| PS-TRF-12 | 列：ASCII | ASCII 视图 | 同上 |
| PS-TRF-13 | 列：HEX | HEX 视图 | 同上 |
| PS-TRF-14 | Ellipsis 长 payload | `ellipsisCheck` 省略显示 | Display Tab |
| PS-TRF-15 | SSL 握手进度写入 Log | 算法名、证书信息 | E-PS-002 SSL 节 |
| PS-TRF-16 | Persistent 窗流量双写 | 独立窗收发同时写主 Log | README Persistent |
| PS-TRF-17 | HTTP 响应 headers+body | GET/POST 响应完整记录 | P-04 |

---

## 8. Saved Packets Tab（PS-SAV-*）

| 功能 ID | 名称 | 行为 | 证据 |
| --- | --- | --- | --- |
| PS-SAV-01 | 包列表表 | `packetsTable` | P-07 |
| PS-SAV-02 | 搜索过滤 | `searchLineEdit` | 同上 |
| PS-SAV-03 | 单击行加载到编辑区 | name/hex/ip/port/resend/protocol | 同上 |
| PS-SAV-04 | 双击表内直接编辑 |  inline edit 字段 | packetsender.com GUI |
| PS-SAV-05 | Delete 多选 | `Packet.removeFromDBList` | P-07 |
| PS-SAV-06 | Generate Panel | 多选 → `generatePanelButton` | PS-PNL-* |
| PS-SAV-07 | 持久化存储 | `packets.ini`（portable 模式同目录） | README Portable |
| PS-SAV-08 | Cloud 同步/分享 | cloud.packetsender.com 公开 URL 导入 | E-PS-001 Cloud 节 |
| PS-SAV-09 | CLI 按名发送 | `-n <name>` 覆盖其他参数 | E-PS-005 |
| PS-SAV-10 | 列顺序自定义 | Display Tab `packetSavedTableHeaders` 拖拽 | settings.cpp |

---

## 9. Settings 四 Tab（PS-SET-*）

保存：**OK** → `ps_settings.ini` → `applyNetworkSettings()`。

### 9.1 Network Tab（PS-SET-NET-*）

| 功能 ID | 控件 | settings key | 作用 |
| --- | --- | --- | --- |
| PS-SET-NET-01 | UDP Server Enable + Port | udpServerEnable, udpPort | §6 |
| PS-SET-NET-02 | TCP Server Enable + Port | tcpServerEnable, tcpPort | §6 |
| PS-SET-NET-03 | SSL Server Enable + Port | sslServerEnable, sslPort | §6 |
| PS-SET-NET-04 | DTLS Server Enable + Port | dtlsServerEnable, dtlsPort | §6 |
| PS-SET-NET-05 | Respond to all | sendReponse | PS-SRV-10 |
| PS-SET-NET-06 | Response payload | responseHex, responseName | PS-SRV-11 |
| PS-SET-NET-07 | Translate macros when sending | translateMacroSendCheck | PS-MAC-* |
| PS-SET-NET-08 | Persistent TCP 默认勾选 | persistentTCPCheck | PS-CLI-14 |
| PS-SET-NET-09 | IPv4 / IPv6 / Bind specific IP | ipMode | PS-NET-IP-* |
| PS-SET-NET-10 | Receive Before Send | attemptReceiveCheck | PS-SRV-12 |
| PS-SET-NET-11 | 500 ms delay after connect | delayAfterConnectCheck | PS-SRV-13 |
| PS-SET-NET-12 | Ignore SSL errors | ignoreSSLCheck（默认 true） | PS-SSL-* |
| PS-SET-NET-13 | SSL CA 路径 | sslCaPath | PS-SSL-* |
| PS-SET-NET-14 | Local Cert 路径 | sslLocalCertPath | 同上 |
| PS-SET-NET-15 | Private Key 路径 | sslPrivateKeyPath | 同上 |
| PS-SET-NET-16 | Use Snake Oil cert | serverSnakeOilCheck | 同上 |
| PS-SET-NET-17 | Cancel resend after N | cancelResendNum（0=无限） | PS-RSN-* |
| PS-SET-NET-18 | Multi-send delay | multiSendDelay | PS-RSN-* |
| PS-SET-NET-19 | Date format | dateFormat → {{DATE}} | PS-MAC-01 |
| PS-SET-NET-20 | Time format | timeFormat → {{TIME}} | PS-MAC-02 |

### 9.2 HTTP Tab（PS-SET-HTTP-*）

| 功能 ID | 名称 | 行为 | 证据 |
| --- | --- | --- | --- |
| PS-SET-HTTP-01 | Adjust Content-Type | POST 自动补 Content-Type；`httpAdjustContentTypeCheck` | P-05 |
| PS-SET-HTTP-02 | Generate Auth Header 总开关 | 显示 Host / UN / PW 字段 | E-PS-002 HTTP 节 |
| PS-SET-HTTP-03 | HTTP Auth Header 按钮 | 生成 Basic Auth header | 同上 |
| PS-SET-HTTP-04 | HTTP Header 按钮 | 自定义 header 写入凭证表 | 同上 |
| PS-SET-HTTP-05 | 凭证表（按 host） | 增删改 → saveHTTPHeader / deleteHTTPHeader | settings.cpp L818+ |
| PS-SET-HTTP-06 | HTTPS 发送时使用凭证 | 自动附加已存 header | P-06 |

### 9.3 Display Tab（PS-SET-DSP-*）

| 功能 ID | 名称 | settings key | 证据 |
| --- | --- | --- | --- |
| PS-SET-DSP-01 | Dark Mode | darkModeCheck（Qt6.5+ 系统自动则 hide） | P-08 §8.3 |
| PS-SET-DSP-02 | Restore session on launch | restoreSessionCheck — 恢复 IP/hex/port/protocol/resend | 同上 |
| PS-SET-DSP-03 | Check for updates | checkforUpdates | 同上 |
| PS-SET-DSP-04 | Ellipsis in traffic log | ellipsisCheck | PS-TRF-14 |
| PS-SET-DSP-05 | Rolling 500 entry log | rolling500entryCheck — 100 vs 10000 | PS-TRF-03 |
| PS-SET-DSP-06 | Copy unformatted | copyUnformattedCheck | PS-TRF-05 |
| PS-SET-DSP-07 | Saved packets column order | displayOrderList 拖拽 | PS-SAV-10 |
| PS-SET-DSP-08 | Autolaunch starter panel | autolaunchStarterPanelButton | PS-PNL-* |
| PS-SET-DSP-09 | Language | languageCombo — 首次强制选择 | settings.cpp |

### 9.4 Smart Responses Tab（PS-SET-SMR-*）

总开关 + **5 条规则**（规则结构相同，序号 1–5）。

| 功能 ID | 字段 | 控件 key 模式 | 证据 |
| --- | --- | --- | --- |
| PS-SET-SMR-00 | Send a Smart Response | smartResponseEnableCheck | P-08 §8.4 |
| PS-SET-SMR-01～05 | 规则 N Enable | responseEnableCheck#N | 同上 |
| PS-SET-SMR-01～05 | Match method | Starts With / Contains / Ends With / Exact Match | packet.cpp L961–999 |
| PS-SET-SMR-01～05 | Encoding | Mixed ASCII / HEX | settings.cpp |
| PS-SET-SMR-01～05 | If（匹配模式） | 可含宏 | PS-MAC-* |
| PS-SET-SMR-01～05 | Reply（回复 payload） | macroSwap 后发送 | 同上 |

**运行时**（PS-SMR-RUN-*）：服务端收到包 → 按序测试规则 1→5 → 首命中发 reply；无命中可走 Respond-all（PS-SRV-10）。

---

## 10. Smart Response 五规则类型（PS-SMR-*）

| 功能 ID | Match 方法 | 源码判定 | Encoding 典型 |
| --- | --- | --- | --- |
| PS-SMR-M01 | **Starts With** | `data.startsWith(testData)` | Mixed ASCII |
| PS-SMR-M02 | **Contains** | `data.contains(testData)` | Mixed ASCII |
| PS-SMR-M03 | **Ends With** | `data.endsWith(testData)` | HEX |
| PS-SMR-M04 | **Exact Match** | `testData == data` | HEX |
| PS-SMR-E01 | Mixed ASCII 编码 | `encodingToByteArray` | — |
| PS-SMR-E02 | HEX 编码 | 同上 | — |

| 步 ID | 行为 | 日志 |
| --- | --- | --- |
| PS-SMR-B01 | 入站包触发匹配链 | Traffic 行 |
| PS-SMR-B02 | 命中 → 发 reply | Traffic + 方向 tx |
| PS-SMR-B03 | 宏在 If/Reply 中展开 | translateMacroSendCheck 时 |

**YoWire 映射**：WF-NET-12 · W-SMR-* · SL-SMR-*（`06-统一后端`）。

---

## 11. 宏变量（PS-MAC-*）

| 功能 ID | 宏 | 替换 | 触发点 |
| --- | --- | --- | --- |
| PS-MAC-01 | `{{DATE}}` | 当前日期（dateFormat，默认 yyyy-MM-dd） | 发送、Smart Reply、Respond-all |
| PS-MAC-02 | `{{TIME}}` | 当前时间（timeFormat，默认 hh:mm:ss ap） | 同上 |
| PS-MAC-03 | `{{UNIXTIME}}` | epoch 秒 | 同上 |
| PS-MAC-04 | `{{COUNTER}}` | 自启动递增，从 1 | 同上 |
| PS-MAC-05 | `{{RANDOM}}` | 随机整数 0–32767 或 2147483647 | 同上 |
| PS-MAC-06 | `{{UNIQUE}}` | UUID 字符串（无花括号） | 同上 |

**条件**：PS-SET-NET-07 `translateMacroSendCheck=true`。证据：`packet.cpp` L825–877。

---

## 12. Resend 与 Intense Traffic（PS-RSN-* / PS-INT-*）

### 12.1 Resend 队列（GUI）

| 功能 ID | 行为 | 证据 |
| --- | --- | --- |
| PS-RSN-01 | resendEdit > 0 → Send → 入队 `packetsRepeat` | P-10 |
| PS-RSN-02 | 状态栏 **Resending (N)** 绿色按钮 | 同上 |
| PS-RSN-03 | refreshTimer：距上次 ≥ repeat×1000−100 ms 重发 | 同上 |
| PS-RSN-04 | 达 cancelResendNum 上限停止 | PS-SET-NET-17 |
| PS-RSN-05 | 点 Resending → `cancelResends()` | 同上 |
| PS-RSN-06 | TCP+Persistent+Resend 多窗警告 | 同上 |
| PS-RSN-07 | Persistent 连接在 Resend 期间 carry | README |

### 12.2 Intense Traffic Generator（实验性）

GUI：**Tools → Intense Traffic Generator**；CLI 参数（man page / documentation）：

| 功能 ID | CLI 参数 | 含义 | 互斥关系 |
| --- | --- | --- | --- |
| PS-INT-01 | `--bps <bps>` | 按 **bits per second** 计算发送速率 | 指定 bps 时忽略 rate/usdelay |
| PS-INT-02 | `--num <number>` | 发送包数量；默认无限 | — |
| PS-INT-03 | `--rate <Hertz>` | 固定频率；**bps 模式下忽略** | — |
| PS-INT-04 | `--usdelay <microseconds>` | 包间微秒延迟；**rate=0 时用**；bps 模式下忽略 | — |
| PS-INT-05 | `--max` | 尽可能快发送 | — |
| PS-INT-06 | GUI 指标显示 | 文档注明 metrics **未充分测试** | E-PS-002 UDP Traffic Gen |

**YoWire**：高强度流量 **不纳入 v1**（WF-NET-18）；Resend 映射 RSN-* / WF-NET-01。

---

## 13. Panel Generator / Grid DSL（PS-PNL-*）

| 功能 ID | 名称 | 行为 | 证据 |
| --- | --- | --- | --- |
| PS-PNL-01 | Generate Panel | 多选 Saved → 创建 Grid 按钮面板 | panelgenerator.cpp |
| PS-PNL-02 | Load Starter Panel | Toolbar Panels；无 starter 则 Empty | E-PS-001 |
| PS-PNL-03 | Empty Panel Project | 空白 Grid | 同上 |
| PS-PNL-04 | View / Edit 模式切换 | 右下角 Viewing ↔ Editing | README Panel |
| PS-PNL-05 | 按钮脚本：包名 | 每行一条 → 发送已保存包 | L640–737 |
| PS-PNL-06 | `delay:N` / `sleep:N` | 等待 N 秒 | 同上 |
| PS-PNL-07 | `panel:ID` | 加载子 panel | 同上 |
| PS-PNL-08 | `#` / `//` / `;` | 注释行跳过 | 同上 |
| PS-PNL-09 | View 模式异步执行 | QtConcurrent | 同上 |
| PS-PNL-10 | File/URL 按钮 | http(s):// 或本地文件；View 打开浏览器/默认程序 | README |
| PS-PNL-11 | Panel Settings | Set Name / Set ID / Starter / Delete Panel | 同上 |
| PS-PNL-12 | `--starterpanel` CLI | Panel-only 启动模式 | 同上 |
| PS-PNL-13 | Export / Import panel 工程 | Panel 工具栏 File 菜单 | 同上 |

**YoWire 映射**：WF-NET-10 · PNL-*（`06-统一后端` §8）；终端页仅 Sheet，非 3 列 Grid。

---

## 14. HTTP GET/POST（PS-HTTP-*）

| 功能 ID | 能力 | 说明 | 证据 |
| --- | --- | --- | --- |
| PS-HTTP-01 | GET 请求 | QNetworkAccessManager / packetNetwork | P-04 |
| PS-HTTP-02 | POST 手动 Data | key=value&key=value | P-05 |
| PS-HTTP-03 | Generate Data 对话框 | Key + Value + `+` 添加 | 同上 |
| PS-HTTP-04 | Load File → POST body | 文件作为 body | 同上 |
| PS-HTTP-05 | Persistent TCP 剥离 headers | 便于读 body | README HTTP |
| PS-HTTP-06 | 整 URL 粘贴 Request | 自动解析 host/port/path | PS-CLI-07 |
| PS-HTTP-07 | Auth Header 生成 | Settings HTTP Tab | PS-SET-HTTP-* |
| PS-HTTP-08 | 按 host 凭证表 | 多 header 持久化 | 同上 |
| PS-HTTP-09 | Content-Type 自动调整 | httpAdjustContentTypeCheck | PS-SET-HTTP-01 |
| PS-HTTP-10 | 响应 headers+body 入 Traffic | — | PS-TRF-17 |

**YoWire PRD 扩展**：PUT/DELETE/PATCH、Bearer 认证 — 竞品无（WF-NET-04 PRD §10.2）。

---

## 15. SSL / DTLS 模式（PS-SSL-*）

| 功能 ID | 能力 | 桌面 | 移动 Xamarin | 证据 |
| --- | --- | --- | --- | --- |
| PS-SSL-01 | SSL Client | ✓ | ✗ | P-03 |
| PS-SSL-02 | SSL Server | ✓ | ✗ | PS-SRV-05/06 |
| PS-SSL-03 | 默认 ignore SSL errors | ✓ ignoreSSLCheck | — | settings.cpp |
| PS-SSL-04 | 加载 CA / Cert / Key | ✓ | — | PS-SET-NET-13~15 |
| PS-SSL-05 | Snake Oil 内置测试证书 | ✓ Windows 服务端 | — | README SSL |
| PS-SSL-06 | 握手进度 + 算法名 Log | ✓ AESGCM/RSA 等 | — | CLI 示例 |
| PS-SSL-07 | DTLS Client GUI | ✓（Win；他平台 Qt6 编译） | ✗ | DTLS 文档 |
| PS-SSL-08 | DTLS Server | ✓ | ✗ | 同上 |
| PS-SSL-09 | DTLS Cipher Suite 下拉 | ✓ | — | 同上 |
| PS-SSL-10 | DTLS Persistent Session | ✓ session key 复用 | — | 同上 |
| PS-SSL-11 | Smart Response over DTLS | ✓ | — | DTLS Smart 节 |
| PS-SSL-12 | CLI `-s` ignore / `-S` stop on error | ✓ | — | E-PS-005 |

**YoWire**：WF-NET-05/17 P1–P2 TLS 后续；v1 不阻塞 TCP/UDP/HTTP。

---

## 16. Wake-on-LAN / IPv4·IPv6 / 绑定（PS-NET-*）

| 功能 ID | 名称 | 行为 | 证据 |
| --- | --- | --- | --- |
| PS-NET-WOL-01 | WOL 生成器 | Tools 菜单；填 MAC → 主窗预填 Magic Packet | E-PS-002 WOL |
| PS-NET-WOL-02 | CLI `--wol <mac>` | 广播 Magic Packet；可选 port | E-PS-005 |
| PS-NET-IP-01 | 客户端 IPv4/IPv6 无缝切换 | 发送时自动；GUI 右下角 toggle | E-PS-002 |
| PS-NET-IP-02 | 服务端 IPv4 **或** IPv6（非同时） | Settings ipMode | 同上 |
| PS-NET-IP-03 | Bind specific IP | 多 NIC 强制出口/监听 | PS-SET-NET-09 |
| PS-NET-IP-04 | CLI `-4` / `-6` / `-B <ip>` | 强制模式与 bind | E-PS-005 |
| PS-NET-IP-05 | IPv6 scope ID | fe80::…%interface | CLI 示例 |
| PS-NET-SUB-01 | IPv4 Subnet Calculator | Tools 菜单 | E-PS-002 |
| PS-NET-MC-01 | Multicast join（实验） | 发送组播前 join；放弃 IPv6 直到重设 | 同上 |
| PS-NET-MC-02 | WiFi 组播延迟 ~20s | 已知问题 | 同上 |

**YoWire**：WOL/Subnet/CLI → WF-NET-18 P3 不做；IPv4/IPv6 bind → WF-NET-02 服务端 PS-SET-NET-09 映射。

---

## 17. Persistent TCP/SSL 独立窗（PS-PST-*）

| 功能 ID | 能力 | 证据 |
| --- | --- | --- |
| PS-PST-01 | 勾选 Persistent → 发送 TCP/SSL 开独立窗 | README L350–365 |
| PS-PST-02 | Raw / ASCII 双视图 | 同上 |
| PS-PST-03 | Return 键快速发送（可选 `\r`） | 同上 |
| PS-PST-04 | 已保存包下拉加载 | 同上 |
| PS-PST-05 | 文件上传到连接 | 同上；建议关 Log |
| PS-PST-06 | 连接计时器 | 首包收发启动；断开停止 | 同上 |
| PS-PST-07 | 入站 Server 连接也开窗 | 同上 |
| PS-PST-08 | 流量双写主 Traffic Log | PS-TRF-16 |
| PS-PST-09 | CLI **不支持** Persistent | README | 

**YoWire**：WF-NET-03。

---

## 18. 其他桌面能力（YoWire 不纳入 v1）

| 功能 ID | 能力 | YoWire Gap | 证据 |
| --- | --- | --- | --- |
| PS-EXT-01 | Packet Sender Cloud | P3 不做 | cloud.packetsender.com |
| PS-EXT-02 | Portable mode | — | portablemode.txt |
| PS-EXT-03 | CLI 全功能发送/监听 | P3 | E-PS-005 |
| PS-EXT-04 | `-n` 按名发包 | — | man page |
| PS-EXT-05 | `-f` 文件发送（UDP 10MiB/TCP 100MiB） | — | man page |
| PS-EXT-06 | `-w` wait for response ms | — | man page |
| PS-EXT-07 | 1×1 Android widget 快捷发包 | — | F-Droid 描述 |

---

## 19. 桌面 Qt vs Android 移动差异矩阵

| 能力维度 | 桌面 Qt（主证据） | Xamarin 移动（归档） | Compose 移动（新） | YoWire 取舍 |
| --- | --- | --- | --- | --- |
| 协议数 | **8**（含 HTTP/HTTPS/SSL/DTLS） | **2**（TCP/UDP） | 待确认（讨论区维护不稳） | 对齐桌面 8 + PRD WS/MQTT |
| Panel Generator | ✓ 完整 DSL | ✗ | ✗ | WF-NET-10 ⚙ |
| Smart Response ×5 | ✓ | ✗ | ✗ | WF-NET-12 专家 |
| Settings 四 Tab | ✓ Network/HTTP/Display/Smart | 简化 Settings | — | WiFi ⚙ 四分组 |
| Persistent TCP | ✓ 独立窗 | ✗ | ✗ | WF-NET-03 |
| SSL/DTLS/HTTPS | ✓ | ✗ | 部分？ | P2 |
| Resend 队列 | ✓ GUI 状态栏 | 基础 resend | — | RSN-* |
| Intense Traffic | ✓ GUI+CLI bps/num/usdelay | ✗ | ✗ | 不做 |
| WOL / Subnet | ✓ Tools | ✗ | ✗ | 不做 |
| Traffic Log Save/Copy | ✓ 完整 | ✓ 基础 log | — | WF-NET-11 |
| Saved Packets 搜索 | ✓ | ✓ 按名保存 | — | WF-NET-10 |
| Server 四协议 | ✓ | TCP+UDP only | — | WF-NET-02 |
| IPv4/IPv6 bind | ✓ | 有限 | — | 服务端项 |
| Cloud 同步 | ✓ | ✗ | ✗ | 不做 |

**结论**：YoWire 网络调试 **不以 Xamarin 移动版为能力上限**；以桌面 Qt + PRD 扩展（WS/MQTT）为设计基线。

---

## 20. YoWire 功能 ID 映射（PS-* → WF-NET-*）

| PacketSender PS 簇 | YoWire ID | 分级 | 落点 |
| --- | --- | --- | --- |
| PS-CLI + PS-PRO TCP/UDP | WF-NET-01 | P0 | C Terminal |
| PS-SRV + PS-SET-NET Server | WF-NET-02 | P0 | WiFi ⚙·网络调试 |
| PS-PST Persistent | WF-NET-03 | P0 | WF-NET-03 |
| PS-HTTP + PS-SET-HTTP | WF-NET-04 | P0 | C Request 区 |
| PS-SSL/DTLS | WF-NET-05/17 | P1–P2 | WiFi ⚙ |
| **PS-GAP WS** | **WF-NET-06/07** | **P0/P2 YoWire 独有** | C WS Segmented |
| **PS-GAP MQTT** | **WF-NET-08** | **P0 YoWire 独有** | C MQTT Tab |
| PS-MAC | WF-NET-09 | P1 | WiFi ⚙ |
| PS-PNL | WF-NET-10 · PNL-* | P1 | WiFi ⚙·命令与面板 |
| PS-TRF | WF-NET-11 | P0 | C Traffic |
| PS-SMR | WF-NET-12 | P2 专家 | WiFi ⚙·专家 |
| PS-RSN | RSN-* + WF-NET-01 | P0 | 状态栏 Stop |
| PS-EXT Cloud/WOL/CLI/INT | WF-NET-18 | P3 不做 | — |
| 840vp 三区 | WF-NET-19 | P1 | B 会话 + C Traffic |
| 会话导出 | WF-NET-20 | P1 | WiFi ⚙·会话 |

---

## 21. 统计摘要

| 维度 | 数量 |
| --- | --- |
| PS-PRO 协议 | 8（+2 GAP） |
| PS-CLI Client 字段/能力 | 22 + 9 快捷键 |
| PS-SRV 服务端项 | 17 |
| PS-TRF Traffic 项 | 17 |
| PS-SAV Saved 项 | 10 |
| PS-SET 四 Tab 控件 | 20+9+9+6×5 Smart |
| PS-SMR Match 类型 | 4 × 5 规则 |
| PS-MAC 宏 | 6 |
| PS-PNL Panel | 13 |
| PS-INT 高强度参数 | 6 |
| 逐步流程 PS-FLOW | 6（Client 主路径） |

---

## 22. 联网证据索引（E-PS-*）

| Evidence ID | URL | 本文章节 |
| --- | --- | --- |
| E-PS-001 | https://packetsender.com/ | §3–§18 |
| E-PS-002 | https://packetsender.com/documentation | §12 PS-INT、§14 HTTP、§16 WOL |
| E-PS-003 | https://github.com/dannagle/PacketSender | §4–§11 源码键 |
| E-PS-004 | https://en.wikipedia.org/wiki/Packet_Sender | §19 摘要 |
| E-PS-005 | https://manpages.debian.org/trixie/packetsender/packetsender.1.en.html | §6 CLI、§12 PS-INT |
| E-PS-GAP-01 | —（无 WS） | §4 PS-GAP-01/02 |
| E-PS-GAP-02 | —（无 MQTT） | §4 PS-GAP-03 |

---

## 23. 相关文档

| 文档 | 路径 |
| --- | --- |
| 深研清单 v2 | `.research/feature-inventory/06-PacketSender-全量功能清单-v2.md` |
| 源码逐步 P-01～P-16 | `.research/feature-inventory/15-PacketSender-源码级逐步流程-v2.md` |
| YoWire 产品化清单 | `03-WiFi模块/02-网络协议调试功能清单.md` |
| LAN/诊断（竞品无） | `03-WiFi模块/03-LAN与网络诊断功能清单.md` |
| 证据注册表 | `07-联网调研证据/01-竞品版本基线与公开证据索引.md` §5 |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` §10 |
| 差距矩阵 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v1 |
| 功能 ID 前缀 | PS-* |
| 行数目标 | 450+ |
| 最后更新 | 2026-07-03 |
