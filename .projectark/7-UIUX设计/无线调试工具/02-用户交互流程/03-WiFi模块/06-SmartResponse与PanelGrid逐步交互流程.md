# 06 — Smart Response 与 Panel Grid 逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/15-PacketSender-源码级逐步流程-v2.md` §6.4 Smart Tab · `01-功能清单/03-WiFi模块/02-网络协议调试功能清单.md` §6.4/§10 · `03-UI设计/03-WiFi模块/04-WiFi模块设置页设计.md` · `03-UI设计/00-全局框架/03-模块自治与会话命令模型.md`  
> **范围**：Smart Response 5 规则 CRUD + 匹配测试 · Panel Grid DSL 编辑 · 绑定收藏包 · Stop Resending  
> **入口约束**：**仅** WiFi 模块 ⚙ → **命令与面板** / ⚙ → **网络调试·专家**；终端页无 3 列 Grid 编辑

---

## 1. 流程总览

```text
WiFi ⚙ 设置
├── 网络调试 · 专家 → Smart Response（5 规则 CRUD + 测试）
└── 命令与面板 → Panel Grid（DSL · 绑定包 · View/Edit · Stop Resending）
         ↕
网络调试 C 栏运行时：Resending Chip · 从收藏选择（非 Grid 编辑）
```

**专家门控**：轻量模式隐藏 Smart Response；Panel Grid 编辑仍可在命令与面板（P1），Smart Response 仅专家。

---

## 2. 进入 Smart Response 设置

### 2.1 导航路径

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-0 | 轻量模式 | ⚙·网络调试 无 Smart Response NavRow | `NavRow_smartResponse` 隐藏 |
| SR-1 | 专家模式 · WiFi 顶栏 **⚙** | push WifiSettingsPage | `btnModuleSettings` |
| SR-2 | 点分组 **网络调试** | 展开四 Tab：服务端/HTTP/Display/专家 | `NavRow_netDebugSettings` |
| SR-3 | 点 **Smart Response** | push SmartResponsePage | `NavRow_smartResponse` |
| SR-4 | 宽屏 ≥600vp | C 栏 navigate 480×560 | `SettingsPanel` |
| SR-5 | 点 **← 返回** | pop；规则草稿自动保存 | `btnSettingsBack` |

### 2.2 页面布局

```text
SmartResponsePage
├── 总开关 smartResponseEnableCheck
├── 规则 1～5 折叠卡片
├── 匹配测试区（专家）
└── 底部：Respond to all 联动说明
```

---

## 3. Smart Response 总开关

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-10 | 切换 **启用 Smart Response** ON | 服务端入站包启用规则引擎 | `smartResponseEnableCheck` |
| SR-11 | OFF | 入站仅走 Respond to all（若启用） | `smartResponseEnableCheck` |
| SR-12 | ON 但 TCP/UDP Server 均未启用 | Banner「需启用至少一个 Server 端口」 | `SmartServerRequiredBanner` |
| SR-13 | 切换即时生效 | 写 Preference；Traffic 标注 `[SMART]` | `SmartResponseEngine` |

---

## 4. 五条规则 CRUD（W-SMR-S01～S05）

### 4.1 规则卡片结构（每条相同）

| 字段 | 控件 | 说明 |
| --- | --- | --- |
| Enable | Switch `ruleNEnable` | 单条启用 |
| Match method | Dropdown | Starts With / Contains / Ends With / Exact |
| Encoding | Radio | Mixed ASCII / HEX |
| If | TextField `ruleNIf` | 匹配条件 |
| Reply | TextField `ruleNReply` | 回复 payload；支持宏变量 |

### 4.2 创建 / 编辑规则逐步

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-20 | 展开 **规则 1** 卡片 | 显示 Enable/Match/If/Reply | `SmartRuleCard_1` |
| SR-21 | Enable Switch ON | 规则 1 参与匹配序列 | `rule1Enable` |
| SR-22 | Match 选 **Starts With** | 引擎用 `data.startsWith` | `rule1MatchMethod` |
| SR-23 | Encoding 选 **Mixed ASCII** | 入站按 ASCII 解释 | `rule1Encoding` |
| SR-24 | 填 **If** `GET /api` | 保存至 Preference | `rule1If` |
| SR-25 | 填 **Reply** `HTTP/1.1 200 OK\r\n…` | 支持 {{DATE}}/{{COUNTER}} | `rule1Reply` |
| SR-26 | 重复 SR-20～25 规则 2～5 | 最多 5 条；优先级 1→5 | `SmartRuleCard_2`…`_5` |
| SR-27 | 规则 3 Match **Contains** | `data.contains` | `rule3MatchMethod` |
| SR-28 | 规则 4 Match **Ends With** | `data.endsWith` | `rule4MatchMethod` |
| SR-29 | 规则 5 Match **Exact Match** | 全等 | `rule5MatchMethod` |
| SR-30 | 规则 2 Encoding **HEX** | 入站 HEX 解码后匹配 | `rule2Encoding` |
| SR-31 | 清空 If 且 Enable ON | 保存时 Warning「空条件永不命中」 | `ruleValidationBanner` |
| SR-32 | 点 **恢复 Smart 默认** | Dialog → 清空 5 规则 | `btnResetSmartDefaults` |

### 4.3 删除 / 禁用

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-33 | 单条 Enable OFF | 跳过该条；不删字段 | `ruleNEnable` |
| SR-34 | Reset 全部 | 5 条恢复空模板 | `btnResetSmartDefaults` |

---

## 5. 匹配测试（专家 · 不入站真实 Server）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-40 | 滚动至 **匹配测试** 区 | 显示模拟入站输入框 | `SmartMatchTestSection` |
| SR-41 | 输入模拟入站 **Payload** | ASCII/HEX 切换 | `smartTestInputField` |
| SR-42 | 点 **运行匹配** | 按规则 1→5 顺序测试 | `btnRunSmartMatchTest` |
| SR-43 | 规则 1 命中 | 结果区：「命中规则 1」+ Reply 预览（macro 已替换） | `smartTestResultPane` |
| SR-44 | 无命中 | 「无规则匹配 · 将走 Respond to all 或无回复」 | `smartTestResultPane` |
| SR-45 | 多条 Enable 仅第一条命中 | 显示首条命中；Log 说明短路 | `smartTestResultPane` |
| SR-46 | translateMacro ON | Reply 预览含 {{DATE}} 替换示例 | `translateMacroSendCheck` |
| SR-47 | Copy 测试结果 | 剪贴板 | `btnCopySmartTestResult` |

---

## 6. 运行时 Smart Response（Server 入站）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| SR-50 | 外部 Client 向 YoWire TCP Server 发数据 | Server 收到入站 | `TcpServerService` |
| SR-51 | Smart ON + 规则匹配 | 自动 Reply；Traffic IN+OUT 行 | `trafficLogTable` |
| SR-52 | Traffic 行 Method 列 | 标注 `[SMART-R1]` 等 | `trafficLogTable` |
| SR-53 | 无匹配 + Respond to all ON | 发默认 Response 包（⚙ 服务端） | `sendReponsePreference` |
| SR-54 | 无匹配 + Respond off | 仅 IN 行无 OUT | `trafficLogTable` |
| SR-55 | 写 SessionLog | smart_match / smart_reply 事件 | `SessionLogService` |

---

## 7. 进入 Panel Grid 编辑

### 7.1 导航（仅 WiFi ⚙·命令与面板）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-0 | 网络调试 C 栏 | **无** 3 列 Grid 编辑入口（IA 约束） | — |
| PG-1 | WiFi ⚙ → **命令与面板** | 显示命令收藏 + NavRow Panel Grid | `CommandPanelGroup` |
| PG-2 | 点 **网络调试 Panel Grid** | push GridEditorPage | `NavRow_panelGrid` |
| PG-3 | — | 顶栏 Segmented **View \| Edit** | `togglePanelViewEdit` |
| PG-4 | 宽屏 | C 栏全宽 Grid；A/B 保持 | `GridEditorPage` |

### 7.2 Panel Grid 页面布局

```text
GridEditorPage [View|Edit]
├── 3 列 × N 行 Grid（默认可滚动）
├── DSL 脚本编辑器（Edit 模式）
├── 绑定：收藏包 Picker
└── 底栏：Generate Panel · Save · Stop Resending（View 运行时）
```

---

## 8. Panel Grid DSL 编辑（W-PNL-01～08）

### 8.1 Edit 模式 — 绑定收藏包

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-10 | 切换 **Edit** | Grid 格显示 + 占位 | `togglePanelEdit` |
| PG-11 | 点空格 | 升起 **绑定包 Picker** | `panelGridCell` |
| PG-12 | Picker 选已保存包 | 格显示包名 + 协议 Chip | `SavedPacketPicker` |
| PG-13 | 长按格 | 清除绑定 / 编辑标签 | `panelGridCell` |
| PG-14 | 点 **Generate Panel** | 多选收藏 → 自动生成 Grid 布局 | `btnGeneratePanel` |
| PG-15 | Generate 确认 | 覆盖或追加 Dialog | `PanelGenerateConfirmDialog` |

### 8.2 DSL 脚本编辑

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-20 | 点 **编辑 Panel 脚本** | 打开 DSL 编辑器 | `btnEditPanelScript` |
| PG-21 | 行：`包名` | 发送已保存包（同 PacketSender） | `panelScriptEditor` |
| PG-22 | 行：`delay:2` / `sleep:2` | 等待 2 秒 | `panelScriptEditor` |
| PG-23 | 行：`panel:子PanelId` | 加载嵌套 panel | `panelScriptEditor` |
| PG-24 | 行：`# 注释` / `//` / `;` | 忽略 | `panelScriptEditor` |
| PG-25 | 语法错误行 | 行号红波浪；Save 阻断 | `panelScriptLintBanner` |
| PG-26 | 点 **Save** | 持久化 Grid + DSL；Toast | `btnPanelSave` |
| PG-27 | 点 **Starter Panel** | 加载默认模板（⚙ Display autolaunch） | `btnStarterPanel` |
| PG-28 | **Empty Panel** | 清空 Grid | `btnEmptyPanel` |

### 8.3 View 模式 — 执行

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-30 | 切换 **View** | Grid 只读按钮 | `togglePanelView` |
| PG-31 | 点 Grid **按钮** | 异步发送绑定包（QtConcurrent 等价） | `panelGridButton` |
| PG-32 | — | Traffic 写入；若未在网络调试页则后台 SessionLog | `trafficLogTable` |
| PG-33 | 脚本含 delay | 顺序执行；按钮 Loading | `PanelScriptRunner` |
| PG-34 | 脚本含 panel: 嵌套 | 临时切换子 Panel 执行 | `PanelScriptRunner` |
| PG-35 | 执行错误（包不存在） | Toast + Log Error | `PanelRunErrorToast` |

---

## 9. Stop Resending 与 Resend 队列联动

### 9.1 从 Panel / Terminal 触发 Resend

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-40 | Panel 按钮发送带 resend>0 的包 | 入队 packetsRepeat | `ResendScheduler` |
| PG-41 | 网络调试 C 栏 | Chip **Resending (N)** 绿色 | `chipResending` |
| PG-42 | GridEditor View 底栏 | **Stop Resending** 按钮同步可见 | `btnStopResending` |
| PG-43 | 点 **Stop Resending** | cancelResends()；Chip 隐藏 | `btnStopResending` |
| PG-44 | 点 Chip（C 栏） | 等同 Stop Resending | `chipResending` |
| PG-45 | 达 cancelResendNum | 自动 stop；Toast | `cancelResendNumPreference` |
| PG-46 | TCP Persistent + Resend | RiskDialog（多连接） | `PersistentResendRiskDialog` |

### 9.2 Panel 运行时与模块隔离

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-50 | 蓝牙 Tab 活跃 | WiFi Panel Resend **不影响** 蓝牙 Session | `SessionManager` |
| PG-51 | 切 Tab 后 Resend 继续 | 依 ⚙·权限与后台·后台连接 | `backgroundConnectionSwitch` |
| PG-52 | WiFi ⚙ 暂停落盘 | Resend 仍写内存 Traffic；导出受限 Banner | `switchPausePersist` |

---

## 10. 命令收藏与 Panel 交叉

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PG-60 | ⚙·命令与面板 **新增** MQTT/HTTP 包 | 出现在 Picker | `fabAddCommand` |
| PG-61 | 终端 **从收藏选择** | Sheet 列表；**非** Grid | `btnFavoritePicker` |
| PG-62 | 编辑收藏包 | Grid 绑定名同步更新（同 ID） | `SavedCommandRow` |
| PG-63 | 删除收藏包 | Grid 格显示「包已删除」红框 | `panelGridCell_orphan` |

---

## 11. 宽屏 Panel Grid（≥840vp）

| 步 | 用户动作 | B 栏 | C 栏 |
| --- | --- | --- | --- |
| PG-W1 | ⚙·命令与面板 | — | GridEditor 全宽 |
| PG-W2 | View 模式点按钮 | 网络调试 B 收藏可选中 | Traffic 同步刷新 |
| PG-W3 | Stop Resending | — | C 栏 Chip + Grid 底栏双入口 |

---

## 12. 验收要点

- [ ] Smart Response 5 规则 CRUD + Enable/Match/Encoding/If/Reply 全字段
- [ ] 匹配测试区可模拟命中规则 N 并预览 Reply（含宏替换）
- [ ] 运行时 Server 入站按 1→5 短路匹配；Traffic 标注 `[SMART-Rn]`
- [ ] Panel Grid **仅** WiFi ⚙·命令与面板 可 Edit；终端页无 Grid 编辑
- [ ] DSL：`包名` / `delay:N` / `panel:ID` / 注释 语法校验
- [ ] View 模式点按钮写 Traffic + SessionLog
- [ ] Stop Resending 在 Grid View 与 C 栏 Chip 双入口等效
- [ ] 轻量模式隐藏 Smart Response；专家可见
- [ ] 跨模块 Resend 不污染蓝牙/星闪 Session

---

## 13. 相关文档

| 文档 | 路径 |
| --- | --- |
| HTTP/WS/MQTT 发送 | `05-HTTP-WebSocket-MQTT逐步交互流程.md` |
| WiFi 设置全分组 | `04-WiFi模块设置与会话命令流程.md` |
| 命令面板跨模块 | `../06-统一后端/02-命令面板与周期发送逐步交互流程.md` |
| 功能清单 §6.4/§10 | `../../01-功能清单/03-WiFi模块/02-网络协议调试功能清单.md` |
| PacketSender Smart/Panel | `.research/feature-inventory/15-PacketSender-源码级逐步流程-v2.md` |

---

## 14. Respond to all 与 Smart 优先级

| 步 | 条件 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| RA-1 | Smart ON + 规则命中 | **仅** Smart Reply；不走 Respond to all | `SmartResponseEngine` |
| RA-2 | Smart ON + 无命中 + Respond to all ON | 发默认 Response 包 | `sendReponsePreference` |
| RA-3 | Smart OFF | 仅 Respond to all 或静默 | `smartResponseEnableCheck` |
| RA-4 | ⚙ 服务端 **Response 包** 未配置 | Toast「请配置默认 Response」 | `W-NET-S06` |

---

## 15. Panel 与 Resend 并发场景

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PR-1 | Panel 脚本含 3 个 delay + 2 个包 | 顺序执行；Traffic 5+ 行 | `PanelScriptRunner` |
| PR-2 | 脚本运行中手动 Send | 并行或排队（设置） | `btnSend` |
| PR-3 | Resend 与 Panel 同时 | Stop Resending 取消 **全部** WiFi 队列 | `btnStopResending` |
| PR-4 | Smart 命中 + Panel 发送 | 独立；Smart 仅 Server 入站 | `SmartResponseEngine` |

---

## 16. 折叠屏接续

| 步 | 接续项 | 控件名 |
| --- | --- | --- |
| FC-1 | Smart 规则 1～5 展开状态 | `SmartRuleCard_*` |
| FC-2 | Panel Grid Edit 选中格 | `panelGridCell` |
| FC-3 | DSL 编辑器 scroll | `panelScriptEditor` |
| FC-4 | 匹配测试输入/结果 | `smartTestInputField` |

---

## 17. PacketSender Settings 四 Tab 映射（Smart/Panel 专用）

| PacketSender Tab | YoWire ⚙ 落点 | 本文档步骤 |
| --- | --- | --- |
| Smart Responses | 网络调试·专家·Smart | SR-10～SR-55 |
| Panel Generator | 命令与面板·Panel Grid | PG-1～PG-63 |
| Network·Respond to all | 网络调试·服务端 | RA-1～RA-4 |
| Display·Autolaunch panel | 网络调试 Display + Panel Starter | PG-27 |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MAP-1 | 竞品用户找 Smart Tab | YoWire 仅 WiFi ⚙ 专家分组 | `NavRow_smartResponse` |
| MAP-2 | 竞品 Panel Toolbar | YoWire ⚙·命令与面板 NavRow | `NavRow_panelGrid` |
| MAP-3 | 终端页找 Panel | Toast「请在 WiFi 设置编辑 Panel」 | — |

---

## 18. 规则 Encoding 与 Match 组合矩阵

| Match \ Encoding | Mixed ASCII | HEX |
| --- | --- | --- |
| Starts With | SR-22 默认 | SR-30 规则2 |
| Contains | SR-27 | 入站 decode 后 contains |
| Ends With | SR-28 | endsWith hex |
| Exact | SR-29 | 全等 hex 串 |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| ENC-1 | HEX 规则 If=`48656C6C6F` | 匹配入站 HEX 解码 | `ruleNEncoding` |
| ENC-2 | Reply 含 `{{COUNTER}}` | macroSwap 后发出 | `ruleNReply` |
| ENC-3 | 测试区 Encoding 与规则不一致 | 测试说明 Banner | `smartTestResultPane` |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `02-用户交互流程/03-WiFi模块/` |
| 版本 | 深研草稿 v1 |
| 步骤域 | W-SMR-* · W-PNL-* · WF-NET-10/12 |

