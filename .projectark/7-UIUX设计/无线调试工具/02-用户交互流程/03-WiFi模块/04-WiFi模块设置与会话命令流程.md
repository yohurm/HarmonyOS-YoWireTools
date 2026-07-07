# 04 — WiFi 模块设置与会话命令流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`03-UI设计/03-WiFi模块/04-WiFi模块设置页设计.md`、`feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` F-12、`feature-inventory/15-PacketSender-源码级逐步流程-v2.md` §8、`03-UI设计/00-全局框架/03-模块自治与会话命令模型.md`  
> **范围**：WiFi ⚙ 五分组；命令收藏；Panel Grid；会话导出；环境/LAN/网络调试设置

---

## 1. 进入 WiFi 设置页

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 环境分析/网络调试顶栏 **⚙** | push `/wifi/settings` | `btnModuleSettings` |
| 步2 | 手机 <600vp | 全屏 WifiSettingsPage | `WifiSettingsPage` |
| 步3 | 宽屏 ≥600vp | C 栏 navigate 480×560 或全宽 | `SettingsPanel` |
| 步4 | Traffic **Save Log** 后 | 可选跳转会话与日志 | `btnSaveLog` |
| 步5 | 环境 **Export** 持久化 | 会话列表新增扫描快照 | `ExportService` |
| 步6 | 点 **← 返回** 或 **完成** | pop；保存草稿 Preference | `btnSettingsBack` / `btnSettingsDone` |
| 步7 | — | **禁止** 从更多 Tab 直接进入 WiFi 专有 scanSpeed 等 | IA 约束 |

### 1.1 顶栏

```text
[← 返回]  WiFi 设置                    [完成]
```

### 1.2 五分组 Scroll 列表

```text
1. 会话与日志
2. 命令与面板
3. 环境分析
4. LAN
5. 网络调试
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步8 | 点分组 NavRow | push 子页或展开 | `NavRow_sessionLog` 等 |
| 步9 | 破坏性 Reset | 独立 Dialog；不依赖「完成」 | `btnResetDefaults` |

---

## 2. 分组一：会话与日志

### 2.1 会话类型列表

| 会话类型 | 列表字段 | 操作 |
| --- | --- | --- |
| 环境扫描 | 时间、AP 数、Filter 摘要 | 查看/导出/删除 |
| Traffic | 时间、协议、条数、大小 | 导出三格式 |
| LAN 子网 | CIDR、发现数、耗时 | 导出 |
| 端口扫描 | 目标 IP、范围、open 数 | 导出 |
| 诊断 | 类型、目标、成功/失败 | 导出 Timeline |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SL-1 | 进入 **会话与日志** | 顶栏：批量导出、按类型清理、暂停落盘 | `SessionLogGroup` |
| SL-2 | 切换 **暂停落盘** | Switch；内存缓冲上限 Banner | `switchPausePersist` |
| SL-3 | **存储占用** Progress | 按 WiFi 模块统计 | `storageUsageBar` |
| SL-4 | 点 **环境扫描** 会话行 | 详情：14 列摘要 + 导出 | `SessionRow_wifiScan` |
| SL-5 | 点 **Traffic** 会话行 | Traffic 表回放只读 | `SessionRow_traffic` |
| SL-6 | 点 **LAN** 会话行 | 主机列表摘要 | `SessionRow_lan` |
| SL-7 | 点 **诊断** 会话行 | Timeline 回放 | `SessionRow_diag` |
| SL-8 | 多选 **批量导出** | ExportFlow 合并/ZIP | `btnBatchExport` |
| SL-9 | **按类型清理** | Destructive Dialog | `btnClearByType` |

### 2.2 导出规格 ExportFlow

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| EX-1 | 点 **导出** | ExportSheet：范围、条数、预计大小 | `ExportSheet` |
| EX-2 | 选 **TXT/CSV/JSON** | CSV 预览列头 | `formatRadio` |
| EX-3 | **脱敏** Switch | 继承更多 Tab·安全；BSSID/IP 掩码 | `redactSwitch` |
| EX-4 | **开始导出** | 进度条 | `btnExportStart` |
| EX-5 | 成功 | 分享 / 保存 | `btnShareExport` |
| EX-6 | 失败 | 空间/权限/过大 | `ExportErrorBanner` |

### 2.3 与环境分析运行时 Export 关系

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| EX-7 | C 工具栏 **Export** | 快速 ACTION_SEND 14 列 CSV | `btnExport` |
| EX-8 | 本分组 | 持久归档 + 三格式批量 | `SessionLogGroup` |

---

## 3. 分组二：命令与面板

### 3.1 命令收藏列表

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| CMD-1 | 进入 **命令与面板** | 命令收藏列表 | `CommandPanelGroup` |
| CMD-2 | 点 **新增** FAB | CommandEditorSheet | `fabAddCommand` |
| CMD-3 | 选协议 | TCP/UDP/SSL/HTTP/HTTPS/WS/MQTT/诊断 | `pickerProtocol` |
| CMD-4 | 填名称、目标、Payload | 校验 | `cmdNameField` 等 |
| CMD-5 | **保存** | 列表追加 | `btnCmdSave` |
| CMD-6 | 点行 **编辑** | Sheet 预填 | `SavedCommandRow` |
| CMD-7 | **复制/删除** | Dialog | `btnCmdDuplicate` |
| CMD-8 | 专家 **导入/导出 JSON** | 文件 | `btnCmdImportExport` |

### 3.2 Panel Grid 子页

```text
Panel Grid 编辑 [View|Edit]
Grid 按钮 · 绑定命令 / DSL 编辑器
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-1 | NavRow **网络调试 Panel Grid** | push GridEditorPage | `NavRow_panelGrid` |
| PG-2 | **Edit** 模式 | 点空格 Picker 绑定包 | `togglePanelEdit` |
| PG-3 | 编辑 **Panel 脚本 DSL** | `包名` / `delay:N` / `panel:ID` | `panelScriptEditor` |
| PG-4 | **Generate Panel** | 多选收藏 → 自动生成 Grid | `btnGeneratePanel` |
| PG-5 | **View** 模式 | 点按钮执行；log 写 Traffic Session | `togglePanelView` |
| PG-6 | **保存** | Terminal Sheet 只读引用 | `btnPanelSave` |

**禁止**：Socket Terminal 运行时页 3 列 Grid。

### 3.3 运行时衔接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| RT-1 | C **从收藏选择** | Sheet 列表 | `btnFavoritePicker` |
| RT-2 | 点收藏 | 载入 Terminal 编辑区 | `FavoriteListItem` |
| RT-3 | Resend 默认值 | 收藏项内嵌；Terminal 可覆盖 | `resendEdit` |

---

## 4. 分组三：环境分析（13+ 项）

| # | 设置项 | 用户操作 | 系统响应 | 控件名 |
| --- | --- | --- | --- | --- |
| 1 | 扫描间隔 | List 选秒数 | 下轮 PeriodicScan 间隔变 | `listScanSpeed` |
| 2 | Sort by | Strength/SSID/Channel | 各 Tab 排序变 | `listSortBy` |
| 3 | Group by | None/SSID/Channel/Virtual | AP 分组变 | `listGroupBy` |
| 4 | Connection 条样式 | Complete/Compact/Hide | **recreate** Main | `listConnectionView` |
| 5 | AP view | Complete/Compact | 详情密度变 | `listApView` |
| 6 | Graph maximum Y | 0~-50 dBm 六档 | 图表 Y 轴变 | `listGraphMaxY` |
| 7 | 退出时关闭 WiFi | Switch | 即时 | `switchWifiOffOnExit` |
| 8 | 扫描时常亮 | Switch | 即时 | `switchKeepScreenOn` |
| 9 | 国家码 | CountryPicker | 监管域变 | `pickerCountryCode` |
| 10 | 扫描缓存策略 | Switch Experimental | 即时 | `switchCacheOff` |
| 11 | 收藏 AP 管理 | 子列表 CRUD | — | `NavRow_favoriteAp` |
| 12 | Channel Available | 跳转只读页 | — | `NavRow_channelAvailable` |
| 13 | 厂商 OUI Vendors | 跳转只读页 | — | `NavRow_vendors` |
| 14 | 恢复环境分析默认 | Button + Dialog | reset 全部 | `btnResetEnvDefaults` |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| ENV-1 | 改 scanSpeed 为 10s | 下次扫描间隔 10s | `listScanSpeed` |
| ENV-2 | Connection View → Hide | recreate；Connection 条隐藏 | `listConnectionView` |
| ENV-3 | 点 **收藏 AP** | 列表 SSID/BSSID；删除/备注 | `FavoriteApList` |

---

## 5. 分组四：LAN

| 设置项 | 类型 | 轻量 | 专家 | 控件名 |
| --- | --- | --- | --- | --- |
| 子网扫描超时 | 数字 ms | 默认 | 可调 | `fieldSubnetTimeout` |
| 扫描线程数 | 数字 | 锁定 | 可调 | `stepperScanThreads` |
| 端口扫描默认范围 | 文本 | 1-1024 | 可改 | `fieldDefaultPortRange` |
| 端口扫描并发上限 | 数字 | 锁定 | 可调 | `stepperPortConcurrency` |
| 单端口超时 | 数字 ms | 默认 | 可调 | `fieldPortTimeout` |
| 仅允许私有网段 | Switch | 开 | 可关+风险 | `switchPrivateNetOnly` |
| 禁 Ping 说明 | 只读 | 显示 | 显示 | `textIcmpDisclaimer` |
| TraceRoute 最大跳 | 数字 | 20 | 30+ | `stepperMaxHops` |
| mDNS/SSDP | 灰显 | 预留说明 | 同 | `NavRow_mdnsReserved` |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| LAN-1 | 专家调 **线程数** 超默认 | 下次 LAN 扫描生效 | `stepperScanThreads` |
| LAN-2 | 关 **仅私有网段** | RiskConfirmDialog | `switchPrivateNetOnly` |
| LAN-3 | 读 **禁 Ping 说明** | 诊断 UI 引用同文案 | `textIcmpDisclaimer` |

---

## 6. 分组五：网络调试（PacketSender Settings 四 Tab 映射）

### 6.1 Network 子组

| 控件 | 作用 | 控件名 |
| --- | --- | --- |
| UDP Server Enable + Port | 多端口逗号分隔 | `switchUdpServer` |
| TCP Server Enable + Port | 冲突校验 | `switchTcpServer` |
| SSL Server Enable + Port | 与 TCP 互斥 | `switchSslServer` |
| DTLS Server | 平台支持时 | `switchDtlsServer` |
| Respond to all | 统一回复 payload | `switchRespondAll` |
| Response ASCII/HEX | 或从包加载 | `fieldResponsePayload` |
| Translate macros when sending | macroSwap | `translateMacroSendPreference` |
| Persistent TCP | 默认勾选 | `switchPersistentTcp` |
| IPv4/IPv6/Bind IP | ipMode | `radioIpMode` |
| Ignore SSL errors | 默认 true | `ignoreSSLCheckPreference` |
| Cancel resend after N | 0=无限 | `stepperCancelResendNum` |
| Date/Time format | 宏格式 | `dateFormatPreference` |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NET-1 | 开 UDP Server 8080 | C 底 Chip 显示监听 | `switchUdpServer` |
| NET-2 | 改 cancelResendNum=10 | 第 10 次后自动停 Resend | `stepperCancelResendNum` |
| NET-3 | 关 ignoreSSLCheck | HTTPS 证书错误阻断 | `ignoreSSLCheckPreference` |

### 6.2 HTTP 子组

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| HTTP-1 | **Adjust Content-Type** ON | POST 自动补 | `httpAdjustContentTypePreference` |
| HTTP-2 | **Generate Auth Header** | 显示 Host/UN/PW | `switchHttpAuthGen` |
| HTTP-3 | 点 **HTTP Auth Header** | Basic Auth 写入凭证表 | `btnGenBasicAuth` |
| HTTP-4 | 凭证表增删改 | 按 host 存 header | `HttpCredentialTable` |

### 6.3 Display 子组

| 控件 | 控件名 |
| --- | --- |
| Restore session on launch | `restoreSessionPreference` |
| Ellipsis in traffic log | `ellipsisCheckPreference` |
| Rolling 500 entry log | `rolling500entryPreference` |
| Copy unformatted | `copyUnformattedCheckPreference` |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DSP-1 | 开 **Restore session** | 下次启动恢复 IP/hex/port | `restoreSessionPreference` |
| DSP-2 | Rolling 500 ON | Traffic max 100 条 | `rolling500entryPreference` |

### 6.4 Smart Responses 子组（专家）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-1 | **Send a Smart Response** ON | 规则 1–5 可见 | `switchSmartResponse` |
| SR-2 | 规则 Enable + Match method | Starts With/Contains/Ends With/Exact | `smartRuleRow1` |
| SR-3 | 填 If / Reply | Mixed ASCII/HEX | `fieldSmartIf1` |
| SR-4 | 保存 | 服务端命中自动回复 | `btnSaveSmartRules` |

---

## 7. 专家 / 轻量联动

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 轻量模式 | LAN 线程数/端口并发锁定；Smart Response 隐藏 | `expertModePreference` |
| 步2 | 专家模式 | 环境分析 13 项全显；Server 四协议 Chip 可见 | 各设置行 |
| 步3 | 设置页底 | 只读模式小字 | `SettingsModeHint` |

---

## 8. 840vp 设置呈现

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 宽屏 ⚙ | C 栏 SettingsPanel；A/B 保持 | `SettingsPanel` |
| 步2 | Panel Grid 编辑 | C navigate 子页全宽 | `GridEditorPage` |
| 步3 | 会话详情 | overlay 或 C 全屏 | `SessionDetailPage` |

---

## 9. 跨流程入口汇总

| 来源 | 目标分组 | 控件 |
| --- | --- | --- |
| 环境 Export | 会话与日志·环境扫描 | `btnExport` |
| Traffic Save Log | 会话与日志·Traffic | `btnSaveLog` |
| LAN 导出 | 会话与日志·LAN | `btnExportLan` |
| 诊断导出 | 会话与日志·诊断 | `btnExportDiag` |
| Terminal 从收藏选择→管理 | 命令与面板 | `btnManageFavorites` |
| C 专家参数 | LAN 分组 | `btnExpertLanSettings` |

---

## 10. 验收检查清单

- [ ] 五分组均可从 ⚙ 进入  
- [ ] 会话：环境/Traffic/LAN/诊断 导出 TXT/CSV/JSON  
- [ ] 命令收藏 CRUD + Panel Grid DSL  
- [ ] 环境 13 项 + recreate 项  
- [ ] LAN 专家项 + 禁 Ping 说明  
- [ ] 网络调试 Network/HTTP/Display/Smart Response  
- [ ] 无全局命令 Tab；Terminal 无 Grid  
- [ ] 脱敏继承更多 Tab·安全  

---

## 11. PacketSender Settings 四 Tab 逐步对照

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PS-1 | 网络调试 → UDP Server 8080,9090 | 双端口监听 | `fieldUdpPorts` |
| PS-2 | Respond all ON + 选 Response 包 | 入站统一回复 | `switchRespondAll` |
| PS-3 | HTTP → Generate Auth Header | Basic 写入凭证表 | `btnGenBasicAuth` |
| PS-4 | Display → Restore session ON | 重启恢复 Terminal 字段 | `restoreSessionPreference` |
| PS-5 | Smart Response 规则3 Contains 命中 | 服务端自动 reply | `smartRuleRow3` |
| PS-6 | 点 **完成** | 写 Preference + pop | `btnSettingsDone` |

---

## 12. 命令 Editor Sheet 字段逐步

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| CE-1 | 新增 HTTP POST 命令 | Sheet 打开 | `CommandEditorSheet` |
| CE-2 | 填 `cmdName` `requestPath` `host` | — | 各 Field |
| CE-3 | Body Tab 填 JSON | — | `httpBodyField` |
| CE-4 | 嵌 `{{DATE}}` 宏 | 预览替换结果 | `macroPreview` |
| CE-5 | Resend 默认 0.5s | 载入 Terminal 时带入 | `fieldDefaultResend` |
| CE-6 | **保存** | 列表 + Panel Grid 可绑定 | `btnCmdSave` |

---

## 13. 收藏 AP 与环境 Filter 第五维

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| APF-1 | 环境分析 AP 长按 **收藏** | 写入收藏 AP 表 | `ApContextMenu_favorite` |
| APF-2 | Filter Sheet **仅收藏** ON | B/C 仅显示收藏 AP | `filterFavoritesOnly` |
| APF-3 | ⚙ → 环境分析 → **收藏 AP 管理** | 列表 CRUD | `NavRow_favoriteAp` |
| APF-4 | 删除收藏 | Filter 第五维同步更新 | `btnRemoveFavoriteAp` |

---

*WiFi 模块设置与会话命令流程；全局导航见 `../00-全局导航与会话流程.md`。*
