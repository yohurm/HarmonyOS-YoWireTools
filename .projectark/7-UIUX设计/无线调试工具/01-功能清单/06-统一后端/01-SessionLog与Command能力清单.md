# SessionLog 与 Command 统一后端能力清单

> **状态**：深研草稿，未定稿  
> **权威 PRD**：`.projectark/2-需求文档/无线调试工具/PRD/02-统一日志与命令面板PRD.md`  
> **IA 约束**：`.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` · `22-YoWire-PRD与竞品能力差距矩阵-v2.md` §7、§9  
> **竞品对照**：nRF Connect Log pane / Macros · PacketSender Panel / Resend / Smart Response · SimpleBluetooth* 终端 · WiFiAnalyzer Export  
> **功能 ID 前缀**：`SL-*`（SessionLog）· `CMD-*`（Command 收藏）· `PNL-*`（Panel Grid）· `RSN-*`（Resend/周期发送）· `MAC-*`（宏变量）

---

## 1. 文档定位

本文将 **PRD 02 全量需求** 映射为可实现的功能 ID，并明确 **UI 落点（模块 ⚙）** 与 **禁止项（无全局日志中心 Tab）**。后端统一、前端模块自治是 YoWire 与 PRD 01 原稿的最大修订点。

| 原则 | 说明 | 证据 |
| --- | --- | --- |
| 后端统一 | 八种 SessionLog、Command 模型、导出格式、脱敏策略一套实现 | PRD 02 §3–§10 · `22` LOG-01 |
| UI 分散 | 完整记录/Panel 编辑仅在 **蓝牙/WiFi/星闪 ⚙** | `00-UI架构修正` §3–§7 |
| 无全局日志中心 | 取消 PRD 01 顶层「日志中心」「命令面板」Tab | `22` §9.1 IA-01 |
| 工作台 deep link | 首页仅卡片跳转模块内会话，非全局编辑 | IA-02 · `01-首页工作台功能清单` W-HOME-07/08 |

---

## 2. PRD 02 章节 → 功能域对照

| PRD 02 章节 | 能力域 | 功能 ID 前缀 | 主文档 |
| --- | --- | --- | --- |
| §3 会话日志 | SessionLog 模型、显示、操作、导出 | `SL-*` | 本文 §3–§5 |
| §4 命令模型 | 命令类型、字段、绑定规则 | `CMD-*` | 本文 §6–§7 |
| §5 命令收藏 | 单条命令 CRUD、快速发送 | `CMD-*` | 本文 §7 |
| §6 命令面板 | Panel 结构、Grid、执行策略 | `PNL-*` | 本文 §8 |
| §7 周期发送 | Resend、间隔、停止条件 | `RSN-*` | 本文 §9 |
| §8 宏变量 | {{DATE}} 等 payload 展开 | `MAC-*` | 本文 §10 |
| §9 本地数据 | 落盘、清理、存储上限 | `SL-LOC-*` | 本文 §11 |
| §10 跨模块复用 | 蓝牙/WiFi/星闪矩阵 | 本文 §12 | 各模块功能清单 |
| §11 风险与限制 | 高频发送、误触、敏感数据 | `RSN-RISK-*` · `CMD-RISK-*` | 本文 §13 |

---

## 3. SessionLog 会话类型（SL-TYPE-*）

PRD 02 §3.1 定义八种会话；YoWire 用 `sessionType` 枚举 + 模块归属。

| 功能 ID | sessionType | 模块 | 典型事件 | 主 UI | 完整导出 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| SL-TYPE-01 | `spp_terminal` | 蓝牙 | connect/send/receive/error | C 终端流 + 折叠 Log | **蓝牙 ⚙·会话与日志** | PRD 02 §3.1 · `19` SPP 无持久化 |
| SL-TYPE-02 | `ble_gatt` | 蓝牙 | scan/connect/read/write/notify/mtu | C Log pane 40% | **蓝牙 ⚙·会话与日志** | nRF Log pane SAVE · [nRF README](https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/README.md) |
| SL-TYPE-03 | `ble_uart` | 蓝牙 | profile/mtu/send/receive | C 终端（同 SPP） | **蓝牙 ⚙·会话与日志** | `19` UART-14~15 |
| SL-TYPE-04 | `wifi_scan` | WiFi | AP 列表/RSSI/刷新/限制 | C 图表区 | **WiFi ⚙·会话与日志** | WiFiAnalyzer Export · [User Manual](https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html) |
| SL-TYPE-05 | `network_diagnostic` | WiFi | Ping/DNS/TraceRoute/Whois/端口 | C 诊断输出 | **WiFi ⚙·会话与日志** | PRD 04 §8 · YoWire 扩展 |
| SL-TYPE-06 | `network_traffic` | WiFi | TCP/UDP/HTTP/WS/MQTT 收发 | C Traffic 表 | **WiFi ⚙·会话与日志** | PacketSender Traffic · [packetsender.com](https://packetsender.com/) |
| SL-TYPE-07 | `nearlink_ssap` | 星闪 | scan/connect/read/write/notify/mtu | C Log pane | **星闪 ⚙·会话与日志** | [NearLink sample](https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code) |
| SL-TYPE-08 | `nearlink_datatransfer` | 星闪 | port/connect/send/encrypt | C 终端 + 加密条 | **星闪 ⚙·会话与日志** | PRD 05 §8–§9 |
| SL-TYPE-09 | `command_panel_run` | 跨模块 | 面板按钮执行结果/耗时 | 模块 C 工具栏反馈 | 归属触发模块 ⚙·会话 | PRD 02 §6.2 日志关联 |

**禁止**：`SL-TYPE-GLOBAL` 或独立「日志中心」会话列表 Tab（IA-01）。

---

## 4. SessionLog 事件字段（SL-FLD-*）

PRD 02 §3.2 字段 → 存储 schema 功能 ID。

| 功能 ID | 字段 | 类型/约束 | UI 显示 | 导出 | 证据 |
| --- | --- | --- | --- | --- | --- |
| SL-FLD-01 | `timestampMs` | int64 毫秒 | 所有视图 | TXT/CSV/JSON | PRD 02 §3.2 |
| SL-FLD-02 | `module` | enum 蓝牙/WiFi/星闪 | 专家 Filter | CSV 列 | PRD 02 §3.2 |
| SL-FLD-03 | `sessionId` | UUID | 会话头 | JSON 嵌套 | PRD 02 §3.2 |
| SL-FLD-04 | `eventType` | scan/connect/send/receive/… | Filter | CSV 列 | PRD 02 §3.2 |
| SL-FLD-05 | `direction` | tx/rx/system/user | 方向图标 | TXT 前缀 | PRD 02 §3.2 |
| SL-FLD-06 | `protocol` | SPP/BLE/TCP/…/SSAP/dataTransfer | Chip | CSV 列 | PRD 02 §3.2 |
| SL-FLD-07 | `target` | 地址/IP/UUID/Property | 行摘要 | CSV 列 | PRD 02 §3.2 |
| SL-FLD-08 | `rawPayload` | ArrayBuffer Base64 | HEX/混合 | JSON 完整 | PRD 02 §3.3 原始优先 |
| SL-FLD-09 | `textView` | string 可空 | 文本模式 | TXT 正文 | PRD 02 §3.3 |
| SL-FLD-10 | `hexView` | string | HEX 模式 | TXT/CSV | PRD 02 §3.3 |
| SL-FLD-11 | `statusCode` | int/string | 专家列 | CSV 列 | PRD 02 §3.2 |
| SL-FLD-12 | `errorMessage` | string 可空 | Error 卡 | TXT | PRD 02 §3.2 |
| SL-FLD-13 | `metadata` | JSON（RSSI/MTU/PHY/加密…） | 专家展开 | JSON | PRD 02 §3.2 |

**字节流铁律（SL-RULE-01）**：SPP、TCP、UDP、dataTransfer 保存原始字节流，UI 回调 ≠ 业务包边界（PRD 02 §3.3 · BT-SPP-06）。

---

## 5. 日志显示与操作（SL-UI-*）

### 5.1 显示模式

| 功能 ID | 模式 | 行为 | 适用协议 | 证据 |
| --- | --- | --- | --- | --- |
| SL-UI-01 | 文本模式 | 按编码显示，不可打印字节占位 | 终端类 | PRD 02 §3.3 |
| SL-UI-02 | HEX 模式 | payload 全 HEX | 全部 | SimpleBT hex · [TerminalFragment](https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/TerminalFragment.java) |
| SL-UI-03 | 混合模式 | 可读文本 + HEX 摘要 | 终端类 | PRD 02 §3.3 |
| SL-UI-04 | 原始事件模式 | 完整字段 JSON 视图 | 专家 | PRD 02 §3.3 · nRF 专家 Log |

### 5.2 运行时操作

| 功能 ID | 操作 | 行为 | 删除底层？ | 证据 |
| --- | --- | --- | --- | --- |
| SL-UI-10 | 清屏 | 仅清空当前显示缓冲区 | 否（除非用户删会话） | PRD 02 §3.4 |
| SL-UI-11 | 暂停显示 | UI 不滚动，后台继续写 SL | — | PRD 02 §3.4 |
| SL-UI-12 | 搜索 | 关键字/HEX/UUID/IP/错误码 | — | PRD 02 §3.4 |
| SL-UI-13 | 过滤 | 事件类型/方向/协议/时间 | — | PRD 02 §3.4 |
| SL-UI-14 | 复制 | 选中行或筛选结果 | — | nRF Log Copy · `21` LOG-04 |
| SL-UI-15 | 标记 | 用户标记关键行 | 导出含 flag | PRD 02 §3.4 |
| SL-UI-16 | 导出 | 见 §6 | — | PRD 02 §3.4 |
| SL-UI-17 | 删除会话 | 单会话或批量历史 | 是 | PRD 02 §3.4 |

---

## 6. 导出格式（SL-EXP-*）— 模块作用域

**铁律 SL-EXP-RULE-01**：导出入口在 **各模块 ⚙·会话与日志**，无全局导出 Tab。

| 功能 ID | 格式 | 适用 | 字段要求 | 脱敏 | 证据 |
| --- | --- | --- | --- | --- | --- |
| SL-EXP-01 | **TXT** | 人工查看、问题单 | 方向·时间·目标·内容清晰 | 可选 G-SEC-02 | PRD 02 §3.5 |
| SL-EXP-02 | **CSV** | 表格分析 | 每事件一行、列稳定 | 可选 | PRD 02 §3.5 · WiFiA `\|` 导出 [Export PR#601](https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/pull/601) |
| SL-EXP-03 | **JSON** | 自动化复现 | 完整结构 + raw Base64 | 可选 | PRD 02 §3.5 |
| SL-EXP-04 | 脱敏对象 | 蓝牙地址/WiFi BSSID/IP/SN | 导出前勾选 | 默认直出、可脱敏 | PRD 02 §3.5 · G-SEC-02 |
| SL-EXP-05 | 模块筛选导出 | 仅导出当前模块会话 | 蓝牙/WiFi/星闪独立 | — | IA-01 模块自治 |
| SL-EXP-06 | 按 sessionType 筛选 | 如仅 network_traffic | WiFi ⚙ 子筛 | — | WF-NET-20 |

### 6.1 模块导出映射表

| 模块 | ⚙ 路径 | 可导出 sessionType | 竞品对照 | 证据 URL |
| --- | --- | --- | --- | --- |
| 蓝牙 | **蓝牙 ⚙·会话与日志** | spp_terminal, ble_gatt, ble_uart, command_panel_run | nRF SAVE 单文件 | [Automated tests README](https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Automated%20tests/README.md) |
| WiFi | **WiFi ⚙·会话与日志** | wifi_scan, network_diagnostic, network_traffic | PS Save Log；WiFiA ACTION_SEND | [PacketSender GitHub](https://github.com/dannagle/PacketSender) |
| 星闪 | **星闪 ⚙·会话与日志** | nearlink_ssap, nearlink_datatransfer | 无 OSS | [nearlink-kit sample](https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code) |

---

## 7. Command 命令模型（CMD-*）

### 7.1 命令类型（PRD 02 §4.1）

| 功能 ID | 命令类型 | 模块 | 执行器 | Panel 可绑 | 证据 |
| --- | --- | --- | --- | --- | --- |
| CMD-TYPE-01 | 字节发送 | 蓝牙 SPP / WiFi TCP/UDP / 星闪 DT | TerminalWriter | ✓ | SimpleBT send · PS TCP |
| CMD-TYPE-02 | BLE Write | 蓝牙 GATT | GattWriteExecutor | ✓ | nRF Connection Write |
| CMD-TYPE-03 | BLE Read | 蓝牙 GATT | GattReadExecutor | ✓ | nRF Read |
| CMD-TYPE-04 | BLE Subscribe | 蓝牙 GATT | GattNotifyExecutor | ✓ | nRF Notify |
| CMD-TYPE-05 | SSAP Write | 星闪 | SsapWriteExecutor | ✓ | ssap Client.writeProperty |
| CMD-TYPE-06 | SSAP Read | 星闪 | SsapReadExecutor | ✓ | ssap Client.readProperty |
| CMD-TYPE-07 | Socket Connect | WiFi | SocketConnectExecutor | ✓ | PS Persistent TCP |
| CMD-TYPE-08 | HTTP Request | WiFi | HttpRequestExecutor | ✓ | [PS documentation](https://packetsender.com/documentation) |
| CMD-TYPE-09 | 诊断命令 | WiFi | DiagnosticExecutor | ✓ | YoWire PRD 04 §8 |
| CMD-TYPE-10 | MQTT Publish | WiFi | MqttPublishExecutor | ✓ | **YoWire PRD 扩展**（PS 无 MQTT） |
| CMD-TYPE-11 | WS Frame | WiFi | WebSocketExecutor | ✓ | **YoWire PRD 扩展**（PS 无 WS） |
| CMD-TYPE-12 | 控制命令 | 全局 | delay/wait/stop/panel | ✓ | nRF Macro wait · PS `delay:N` |

### 7.2 命令字段（PRD 02 §4.2）

| 功能 ID | 字段 | 必填 | UI 编辑位置 | 证据 |
| --- | --- | --- | --- | --- |
| CMD-FLD-01 | name | ✓ | ⚙·命令与面板 | PRD 02 §4.2 |
| CMD-FLD-02 | commandType | ✓ | 类型选择器 | PRD 02 §4.2 |
| CMD-FLD-03 | module | ✓ | 自动 | PRD 02 §4.2 |
| CMD-FLD-04 | targetBinding | 条件 | 设备/UUID/IP/Property | PRD 02 §4.2 |
| CMD-FLD-05 | payload | 条件 | 文本/HEX/JSON | PRD 02 §4.2 |
| CMD-FLD-06 | encoding | 可选 | UTF-8/ASCII/HEX | PRD 02 §4.2 |
| CMD-FLD-07 | newline | 终端类 | None/CR/LF/CRLF | [SimpleBT newline](https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/TerminalFragment.java) |
| CMD-FLD-08 | timeoutMs | 可选 | 专家 | PRD 02 §4.2 |
| CMD-FLD-09 | retryPolicy | 可选 | 专家 | PRD 02 §4.2 |
| CMD-FLD-10 | expectedResponse | 可选 | Smart Response 联动 | PS Smart Tab |
| CMD-FLD-11 | tags | 可选 | 分类搜索 | PRD 02 §4.2 |
| CMD-FLD-12 | riskLevel | ✓ | 普通/扰动/高风险 | PRD 02 §4.2 · G-SEC-03 |

### 7.3 目标绑定规则（CMD-BIND-*）

| 功能 ID | 绑定级别 | 显示规则 | 证据 |
| --- | --- | --- | --- |
| CMD-BIND-01 | 具体设备 | 仅该设备会话默认显示 | PRD 02 §5 |
| CMD-BIND-02 | 协议类型 | 同类协议可复用 | PRD 02 §5 |
| CMD-BIND-03 | 全局 | 命令面板选目标后执行 | PRD 02 §5 |
| CMD-BIND-04 | 收藏 AP/LAN | WiFi 环境/网络目标 | WF-NET-10 |

### 7.4 命令收藏 CRUD（CMD-CRUD-*）

| 功能 ID | 操作 | UI | 证据 |
| --- | --- | --- | --- |
| CMD-CRUD-01 | 保存当前输入为命令 | C 页「收藏」 | PRD 02 §5 |
| CMD-CRUD-02 | 编辑 | ⚙·命令与面板 | PRD 02 §5 |
| CMD-CRUD-03 | 复制 | ⚙·命令与面板 | PRD 02 §5 |
| CMD-CRUD-04 | 删除（确认） | ⚙·命令与面板 | PRD 02 §5 |
| CMD-CRUD-05 | 分类标签 | ⚙·命令与面板 | PRD 02 §5 |
| CMD-CRUD-06 | 快速发送 Sheet | C「从收藏选择」 | `22` CMD-01 · 非全局 Grid |

---

## 8. 命令面板 Panel Grid（PNL-*）

PRD 02 §6 + PacketSender Panel Generator 映射。

| 功能 ID | 能力 | 编辑 UI | 运行时 UI | 证据 |
| --- | --- | --- | --- | --- |
| PNL-01 | 新建面板（模块+模板） | **模块 ⚙·命令与面板** | — | PRD 02 §6.3 |
| PNL-02 | 3 列 Grid 布局 | ⚙ 子页 | 禁止终端页 Grid | `00` §7 · WF-NET-10 |
| PNL-03 | 按钮绑定单命令/命令组 | ⚙ | C Sheet 快捷（非 Grid） | PRD 02 §6.2 |
| PNL-04 | 执行策略：单步/顺序/循环 | ⚙ 专家 | 按钮状态反馈 | PRD 02 §6.2 |
| PNL-05 | 按钮状态：执行中/成功/失败/耗时 | — | C + SL-TYPE-09 | PRD 02 §6.2 |
| PNL-06 | DSL：`包名` 发送 | ⚙ 脚本编辑 | PS 同源 | [PS Panel](https://github.com/dannagle/PacketSender) · W-PNL-03 |
| PNL-07 | DSL：`delay:N` / `sleep:N` | ⚙ | PS 同源 | W-PNL-04 |
| PNL-08 | DSL：`panel:ID` 子面板 | ⚙ | PS 同源 | W-PNL-05 |
| PNL-09 | DSL：注释 `#` `//` `;` | ⚙ | PS 同源 | W-PNL-06 |
| PNL-10 | 轻量模式隐藏高风险按钮 | ⚙ 标记 | IA-03 | PRD 02 §6.4 |
| PNL-11 | 停止执行（周期/长任务） | C Stop | PRD 02 §6.3 |

### 8.1 模块 Panel 映射

| 模块 | ⚙ Tab/分组 | 命令来源 | 竞品 | 证据 |
| --- | --- | --- | --- | --- |
| 蓝牙 | **命令与面板** · SPP / BLE / Macro | CMD-TYPE-01~04 | nRF Macros 28-tag · PS Panel | [DevZone Macros](https://devzone.nordicsemi.com/nordic/nordic-blog/b/blog/posts/nrf-connect-macros-currently-android-only) |
| WiFi | **命令与面板** · Socket/HTTP/MQTT | CMD-TYPE-07~10 | PS Generate Panel | [packetsender.com](https://packetsender.com/) |
| 星闪 | **命令与面板** · SSAP / dataTransfer | CMD-TYPE-05~01 | 无 OSS | PRD 05 §7.4/§8.3 |

---

## 9. Resend / 周期发送（RSN-*）

PRD 02 §7 + PacketSender Resend 队列。

| 功能 ID | 要求 | 默认 | UI | 证据 |
| --- | --- | --- | --- | --- |
| RSN-01 | 间隔可配 + **最小间隔** | 模块 ⚙ | C 工具栏 + W-HOME-11 RiskStrip | PRD 02 §7 · CMD-03 |
| RSN-02 | 次数：固定 N / 持续 | 持续需显式确认 | C 状态「Resending (N)」 | PS W-RSN-02 |
| RSN-03 | 停止：手动/失败/达次数/期望响应 | — | Stop 按钮 | PRD 02 §7 |
| RSN-04 | 每次发送写 SL（序号/时间/结果） | — | SL-TYPE 各模块 | PRD 02 §7 |
| RSN-05 | 高频前风险提示 Dialog | — | 首次 + 专家可关 | PRD 02 §7 · G-SEC-03 |
| RSN-06 | 后台周期发送 | **默认关** G-BG-06 | 更多 Tab | PRD 06 §5.1 |
| RSN-07 | cancelResendNum 上限 | 0=无限需警告 | WiFi ⚙·网络调试 W-NET-S15 | PS settings |

### 9.1 模块 Resend 支持矩阵

| 协议/模块 | RSN 支持 | 功能 ID | 证据 |
| --- | --- | --- | --- |
| SPP | ✓ | RSN-BT-SPP-01 | BT-SPP-09 |
| BLE Write | ✓ | RSN-BT-BLE-01 | PRD 02 §7 |
| TCP/UDP | ✓ | RSN-WF-SOCK-01 | WF-NET-01 · PS P-10 |
| MQTT Publish | ✓ | RSN-WF-MQT-01 | WF-NET-08 YoWire 扩展 |
| dataTransfer | ✓ | RSN-NL-DT-01 | PRD 05 §8.3 |
| HTTP 单次 | 可选 Resend | RSN-WF-HTTP-01 | PS resendEdit |

---

## 10. 宏变量（MAC-*）

PRD 02 §8 · PacketSender 六宏。

| 功能 ID | 宏 | 含义 | 展开写入 SL | 证据 |
| --- | --- | --- | --- | --- |
| MAC-01 | `{{DATE}}` | 当前日期 | ✓ | PS W-NET-S17 dateFormat |
| MAC-02 | `{{TIME}}` | 当前时间 | ✓ | PS timeFormat |
| MAC-03 | `{{UNIXTIME}}` | epoch 秒/毫秒 | ✓ | PS {{UNIXTIME}} |
| MAC-04 | `{{COUNTER}}` | 递增计数 | ✓ | PS {{COUNTER}} |
| MAC-05 | `{{RANDOM}}` | 随机整数 | ✓ | PS {{RANDOM}} |
| MAC-06 | `{{RANDOM_HEX}}` | 随机字节 | ✓ | PRD 02 §8 YoWire 扩展 |
| MAC-07 | `{{NEWLINE}}` | CR/LF/CRLF | ✓ | PRD 02 §8 |
| MAC-08 | 会话只读变量 | 设备别名/IP/端口 | ✓ | PRD 02 §8 |
| MAC-09 | translateMacro 总开关 | WiFi ⚙ W-NET-S07 | — | PS translateMacroSendCheck |

---

## 11. Smart Response 五规则（SL-SMR-* / CMD-SMR-*）

PacketSender Smart Responses Tab → WiFi ⚙·网络调试·专家（WF-NET-12 P2）。

| 功能 ID | 规则 | Match 方法 | Encoding | 行为 | 证据 |
| --- | --- | --- | --- | --- | --- |
| SL-SMR-00 | 总开关 | — | — | 服务端入站触发 | PS W-SMR-S00 |
| SL-SMR-01 | 规则 1 | Starts With / Contains / Ends With / Exact | Mixed ASCII / HEX | 命中发 reply + macroSwap | PS W-SMR-S01~05 |
| SL-SMR-02 | 规则 2 | 同上 | 同上 | 按序测试 1→5 | PS W-SMR-B01 |
| SL-SMR-03 | 规则 3 | 同上 | 同上 | 写入 Traffic + SL | WF-NET-11 |
| SL-SMR-04 | 规则 4 | 同上 | 同上 | 轻量模式隐藏 | IA-03 |
| SL-SMR-05 | 规则 5 | 同上 | 同上 | 专家 ⚙ 编辑 | WF-NET-12 |

**YoWire 扩展说明**：Smart Response 为 **WiFi 网络调试 Server 入站** 能力；蓝牙/星闪无等价竞品，不强制移植。

---

## 12. 本地数据与清理（SL-LOC-*）

PRD 02 §9 + 更多 Tab G-STOR-*。

| 功能 ID | 对象 | 默认保存 | 清理入口 | 证据 |
| --- | --- | --- | --- | --- |
| SL-LOC-01 | 会话日志 | ✓ | 模块 ⚙·会话 + G-STOR-03 | PRD 02 §9.1 |
| SL-LOC-02 | 收藏设备 | ✓ | 各模块 ⚙·收藏 | PRD 02 §9.1 |
| SL-LOC-03 | 命令收藏 | ✓ | 模块 ⚙·命令与面板 | PRD 02 §9.1 |
| SL-LOC-04 | 命令面板 | ✓ | 模块 ⚙·命令与面板 | PRD 02 §9.1 |
| SL-LOC-05 | 导出记录（路径元数据） | ✓ 路径 only | G-STOR | PRD 02 §9.1 |
| SL-LOC-06 | 存储上限 | 可配 G-STOR-01 | 达上限提示/自动清理 | PRD 02 §9.2 |
| SL-LOC-07 | 一键清除敏感 | G-SEC-04 | 更多 Tab | PRD 02 §9.2 |

---

## 13. 跨模块复用矩阵（PRD 02 §10）

| 能力 | 蓝牙 | WiFi | 星闪 | 功能 ID | 证据 |
| --- | --- | --- | --- | --- | --- |
| 文本/HEX 输入 | SPP/BLE Write | TCP/UDP/WS/MQTT | DT/SSAP Write | CMD-TYPE-01~05 | PRD 02 §10 |
| 换行配置 | SPP/BLE UART | TCP/WS/MQTT | dataTransfer | CMD-FLD-07 | PRD 02 §10 |
| 周期发送 | SPP/BLE Write | TCP/UDP/MQTT | dataTransfer | RSN-* | PRD 02 §10 |
| 日志导出 | 全蓝牙会话 | 全 WiFi 会话 | 全星闪会话 | SL-EXP-* | PRD 02 §10 |
| 命令面板 | SPP/BLE | Socket/HTTP/MQTT | SSAP/DT | PNL-* | PRD 02 §10 |
| 设备收藏 | 蓝牙设备 | AP/LAN/网络目标 | 星闪多维 | CMD-BIND-* | PRD 02 §10 |

---

## 14. 风险与限制（SL-RISK-* / CMD-RISK-*）

| 功能 ID | 风险 | 产品处理 | 证据 |
| --- | --- | --- | --- |
| SL-RISK-01 | 周期发送设备压力 | 最小间隔 + 次数 + Stop | PRD 02 §11 |
| SL-RISK-02 | 日志含敏感数据 | 本地 + 脱敏导出 + 清理 | PRD 02 §11 · G-SEC-* |
| CMD-RISK-01 | 面板误触 | 高风险二次确认 | PRD 02 §11 · G-SEC-03 |
| RSN-RISK-01 | 后台持续发送 | G-BG-06 默认关 | PRD 02 §11 |
| SL-RISK-03 | 原始字节不可读 | 文本+HEX+混合 | PRD 02 §11 |

---

## 15. 与 PRD 01 IA 冲突修订摘要

| PRD 01 原项 | YoWire 修订 | SessionLog/Command 落点 | 证据 |
| --- | --- | --- | --- |
| 顶层日志中心 E | **取消** | 模块 ⚙·会话 | `22` §9.1 |
| 顶层命令面板 F | **取消** | 模块 ⚙·命令与面板 | `22` §9.1 |
| 首页快捷命令面板 | deep link 卡片 | W-HOME-07/08 | IA-02 |
| 设置·命令全局组 | 拆入模块 ⚙ + 更多·周期默认 | RSN-06 | `00` §5.4 |

---

## 16. 验收清单（节选）

- [ ] 八种 sessionType 均可创建、落盘、按模块导出 TXT/CSV/JSON（SL-TYPE-01~09）
- [ ] 无一级 Tab `/log/*` 路由（IA-01 · W-HOME-15）
- [ ] Panel Grid 仅存在于模块 ⚙，终端页仅「从收藏选择」Sheet（PNL-02）
- [ ] 周期发送有最小间隔、RiskStrip、后台默认关（RSN-01/05/06）
- [ ] 宏展开结果写入 SL（MAC-*）
- [ ] WiFi Smart Response 5 规则在专家 ⚙ 可配（SL-SMR-*）
- [ ] SPP/TCP/dataTransfer 原始字节流不因 UI 清屏丢失（SL-RULE-01）

---

## 17. 相关文档

| 文档 | 路径 |
| --- | --- |
| PRD 02 | `.projectark/2-需求文档/无线调试工具/PRD/02-统一日志与命令面板PRD.md` |
| 全局边界 | `01-功能清单/00-全局能力边界与PRD对照.md` |
| 联网证据 | `01-功能清单/07-联网调研证据/01-竞品版本基线与公开证据索引.md` |
| PRD 主索引 | `01-功能清单/08-PRD全量需求ID主索引.md` |
| 差距矩阵 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v1 |
| 行数目标 | ~350 |
| 最后更新 | 2026-07-03 |
