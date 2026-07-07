# 星闪模块 · dataTransfer 逐步交互流程

> **状态**：深研草稿，未定稿  
> **类型**：用户交互流程（逐步）  
> **依据**：`.research/feature-inventory/20-星闪模块-功能清单与逐步流程-v2.md` §4.3 · `18-HarmonyOS-840vp-星闪模块三分栏线框-v2.md` §3 · `03-UI设计/04-星闪模块/03-dataTransfer终端页面设计.md`  
> **对应功能 ID**：N-NL-06、N-NL-07、N-NL-09、N-NL-10、N-NL-12  
> **前置**：能力 **Ready** 或 **Degraded（含 dataTransfer）**；与 SSAP **单连接互斥**  
> **表头**：步 | 用户动作 | 系统响应 | 控件名

---

## 1. 流程索引

| 步骤 ID | 阶段 | 简述 |
| --- | --- | --- |
| **NL-B1** | Port 准备 | 输入/选择 Port UUID |
| **NL-B2** | 创建端口 | createPort → portReady |
| **NL-B3** | 连接 | connect + 加密状态检查 |
| **NL-B4** | 已连接 | 终端态 + **加密条固定顶** |
| **NL-B5** | 发送 | 文本/HEX + 行尾 |
| **NL-B6** | 接收 | RX 流展示 |
| **NL-B7** | 拥塞 | 错误码 1009700023 退避 |
| **NL-B8** | 结束 | disconnect / destroyPort |

**扫描前置**：与 SSAP 共享 NL-01～NL-05（Segmented 选 **dataTransfer**）。

---

## 2. 进入 dataTransfer 模式（DT-0）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DT-0-1 | Segmented 切 **dataTransfer** | B 列表保持；C 切换 DT 占位 | `SegmentedControl_ssapDt` |
| DT-0-2 | 已连接 SSAP | Dialog「切换将断开 SSAP 连接」 | `SsapDtMutexDialog` |
| DT-0-3 | Dialog 确认 | NL-A9 断开后进入 B1 | `btnConfirmSwitchDt` |
| DT-0-4 | Degraded 无 DT | Segmented 置灰 + Tooltip | `SegmentedTab_dataTransfer` |
| DT-0-5 | 宽屏 | C Empty「选择设备与端口」 | `DtPlaceholderPane` |

---

## 3. NL-B1 · 输入/选择 Port UUID

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B1-1 | 选 B 栏设备行（NL-05） | stopScan → 高亮 | `NearlinkDeviceRow` |
| B1-2 | 点 **Port UUID** 栏 / Sheet | 升起 PortUuidSheet | `btnPortUuid` |
| B1-3 | 输入 UUID | 格式校验 | `portUuidField` |
| B1-4 | 非法 UUID | 输入框错误态；**创建端口** 禁用 | `portUuidField` |
| B1-5 | 点 **最近端口** 列表项（≤10） | 预填 UUID | `recentPortList` |
| B1-6 | 点 **收藏**（⚙·收藏与设备） | 预填 | `favoritePortList` |
| B1-7 | 未选设备 | 创建端口禁用 + Tooltip | `btnCreatePort` |
| B1-8 | ≥600vp | 居中 480×560 Sheet | `PortUuidSheet` |
| B1-9 | 宽屏 B 栏 | 「最近 UUID 端口」快捷行 | `recentPortQuickRow` |
| B1-10 | — | 读取默认 Port UUID Preference | `defaultPortUuidPreference` |

---

## 4. NL-B2 · createPort

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B2-1 | 点 **创建端口** | 按钮 idle → Loading | `btnCreatePort` |
| B2-2 | — | `createPort` API | `DataTransferPortManager` |
| B2-3 | 成功 | 状态 **portReady**；Port 栏显示 UUID | `portStatusChip` |
| B2-4 | — | MTU 占位「协商后显示」 | `chipPortMtu` |
| B2-5 | 失败 | Error Toast + Log；按钮 idle | `DtErrorToast` |
| B2-6 | 重复 create 同 UUID | 管理器复用或提示 | `DataTransferPortManager` |
| B2-7 | Log | `createPort_ok/fail` | `SessionLogService` |

---

## 5. NL-B3 · connect

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B3-1 | 点 **连接** | 连接阶段条 4 步 | `btnDtConnect` |
| B3-2 | 阶段 1「创建端口…」 | B2 已完成则快速通过 | `ConnectionStageBar_dt` |
| B3-3 | 阶段 2「正在连接…」 | `connect` | `DataTransferPort` |
| B3-4 | 阶段 3「检查加密状态…」 | `getAcbState` 等 | `EncryptionCheckService` |
| B3-5 | 阶段 4「就绪」 | 进入 **NL-B4** | `ConnectionStageBar_dt` |
| B3-6 | 失败 | Error 卡 + **重试** + 可选「改用 SSAP」 | `ConnectErrorCard` |
| B3-7 | 返回键 | Dialog「断开并返回？」 | `DisconnectOnBackDialog` |
| B3-8 | 重试 | 从 B3-2 或 B3-3 | `btnRetryConnect` |

---

## 6. NL-B4 · 已连接（终端态 + 加密条）

### 6.1 布局与加密提醒条（P0 不可折叠）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B4-1 | — | **加密提醒条固定顶** + RX/TX 终端 + CommandDock + 折叠 Log | `DtTerminalPage` |
| B4-2 | ENCRYPTED | Chip「已加密」；条「当前链路已加密」 | `EncryptionStrip_encrypted` |
| B4-3 | PLAIN | Chip「未加密」；警告 + 加密说明 + 配对引导 | `EncryptionStrip_plain` |
| B4-4 | UNKNOWN | 同 PLAIN 警告；**禁止**标为已加密 | `EncryptionStrip_unknown` |
| B4-5 | 点 **加密说明** | Sheet：PRD §9、ACB 状态、用户策略 | `btnEncryptionExplain` |
| B4-6 | 点 **配对引导** | `startPairing`（P1） | `btnPairingGuide` |
| B4-7 | 尝试折叠加密条 | **不允许**；无折叠控件 | IA 约束 |
| B4-8 | MTU 协商完成 | Port MTU Chip 更新 | `chipPortMtu` |
| B4-9 | 连接时长 | 状态条计时 | `chipConnectionDuration` |

### 6.2 终端区控件

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B4-10 | — | 终端 List：RX/TX、时间、长度、Text/HEX | `DataTerminal` |
| B4-11 | Toggle **HEX/ASCII** | 全局显示模式切换 | `toggleHexAscii` |
| B4-12 | **清屏** | 仅 UI 清空；SessionLog 保留 | `btnClearTerminal` |
| B4-13 | 折叠 Log | 「会话 Log (N 条)」展开 Sheet 或 C 内 40% | `btnExpandSessionLog` |
| B4-14 | C 工具栏 | 断开、从收藏、周期发送、放大（≤6） | `DtToolbar` |

---

## 7. NL-B5 · 发送

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B5-1 | CommandDock 输入 | Text/HEX；字节计数 | `commandInputField` |
| B5-2 | 选 **行尾** | None / CR / LF / CRLF | `newlinePicker` |
| B5-3 | 点 **发送** | 校验：已连接、非拥塞、加密策略 | `btnSend` |
| B5-4 | 通过 | 终端 TX 行；全量写 SessionLog | `DataTerminal` |
| B5-5 | 超 Port MTU | Warning；Dialog 或阻断 | `MtuWarningDialog` |
| B5-6 | PLAIN + 策略「禁止发送」 | 发送禁用 + Tooltip | `btnSend` |
| B5-7 | UNKNOWN + 默认策略 | 建议禁止；可 ⚙ 放宽 | `btnSend` |
| B5-8 | **从收藏选择** | Sheet ⚙·DT 命令 | `btnFavoritePicker` |
| B5-9 | **周期发送** | 间隔/次数 → **停止周期发送** | `btnPeriodicSend` |
| B5-10 | 周期 tick | 重复 B5-4 | `PeriodicSendScheduler` |
| B5-11 | 未连接 | 发送禁用 | `btnSend` |

---

## 8. NL-B6 · 接收

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B6-1 | 等待设备数据 | 自动 RX 行追加 | `DataTerminal` |
| B6-2 | UTF-8 失败 | 替换符 + 可展开 HEX | `RxRow_invalidUtf8` |
| B6-3 | 用户不在底部 | UnreadBar 提示 | `UnreadBar` |
| B6-4 | — | 底层全记录；节流同 BLE UART | `SessionLogService` |
| B6-5 | 加密状态变化 | 顶栏 Chip 更新 + Log `encryption_state_change` | `EncryptionStrip_*` |
| B6-6 | 长按 RX 行 | Copy HEX / 存命令 | `RxRow_contextMenu` |
| B6-7 | 虚拟化 | 大流量 List 虚拟滚动 | `DataTerminal` |

---

## 9. NL-B7 · 拥塞退避

| 步 | 触发 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B7-1 | 发送 API `1009700023` | Log 行 `congestion` | `SessionLogService` |
| B7-2 | — | C 栏 **拥塞 Banner**：「发送队列已满，已暂停发送」 | `CongestionBanner` |
| B7-3 | — | 发送钮禁用/Loading；**RX 继续** | `btnSend` |
| B7-4 | — | 指数退避 1s→2s→4s… 上限 ⚙·拥塞退避上限 | `CongestionBackoffScheduler` |
| B7-5 | 退避结束 | 恢复发送；Banner 消失 | `CongestionBanner` |
| B7-6 | **立即停止周期发送** | 周期任务取消 | `btnStopPeriodicSend` |
| B7-7 | 连续拥塞 N 次 | Toast 建议减小 payload 或间隔 | `CongestionBanner` |
| B7-8 | 专家 Log | 每次退避间隔写入 SessionLog | `SessionLogService` |

---

## 10. NL-B8 · disconnect / destroyPort

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| B8-1 | **断开** | 周期发送中 → 确认 Dialog | `btnDisconnect` |
| B8-2 | — | `disconnect` | `DataTransferPort` |
| B8-3 | 可选 **destroyPort** | 释放端口资源 | `btnDestroyPort` |
| B8-4 | — | 终端只读历史；加密条灰态保留最后状态 | `EncryptionStrip_disconnected` |
| B8-5 | — | 会话 Log 保留；⚙·会话与日志导出 TXT/CSV/JSON | `btnLogSave` |
| B8-6 | **重连** 同 UUID | 从 B2 或 B3 | `btnReconnect` |
| B8-7 | Segmented 切 SSAP | 互斥 Dialog → B8-2 后进 SSAP | `SegmentedControl_ssapDt` |
| B8-8 | Tab 切换 | 连接保持（后台策略） | `TabBar` |
| B8-9 | SAVE 导出 | 见 `06-统一后端/01-会话日志导出` | `btnLogSave` |

---

## 11. 宽屏 dataTransfer（≥840vp · W-*）

| 步 | 用户动作 | B 栏 (4) | C 栏 (6) | 控件名 |
| --- | --- | --- | --- | --- |
| W-1 | Segmented DT | 扫描/Filter | Empty 占位 | `SegmentedControl_ssapDt` |
| W-2 | 点设备 + 最近 UUID | 高亮 | Port 栏或 Sheet | `recentPortQuickRow` |
| W-3 | B2～B3 | 高亮 | 阶段条 | `ConnectionStageBar_dt` |
| W-4 | B4 | — | 终端 + **加密条顶** + Dock | `DtTerminalPage` |
| W-5 | ⚙ | — | navigate 设置·DT 命令 | `btnModuleSettings` |
| W-6 | 放大 C | — | 终端全屏；加密条仍固定顶 | `btnExpandTerminal` |

---

## 12. 手机端栈深度

```text
L0 扫描（Segmented=dataTransfer）
  → Port UUID Sheet（NL-B1）
  → L1 连接阶段条（NL-B3）
  → L2 终端全屏（NL-B4～B7）
  → NL-B8 断开回 L0 或 L2 只读
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| ST-1 | L2 终端全屏 | 隐藏 Bottom Tab | `NavPathStack` |
| ST-2 | B8 断开回 L0 | 显示 Tab；保留 B 选中可选 | `TabBar` |
| ST-3 | 系统返回 L2→L1 | 阶段条或 Dialog | `btnNavBack` |

---

## 13. 交互状态矩阵

| 状态 | 加密条 | 终端 | 发送 | 控件名 |
| --- | --- | --- | --- | --- |
| 未选设备 | 隐藏 | 占位 | 禁用 | `DtPlaceholderPane` |
| Port 未创建 | 隐藏 | 占位 | 禁用 | `btnCreatePort` |
| 连接中 | 「检查中…」 | 空 | 禁用 | `EncryptionStrip_checking` |
| 已连接·PLAIN | 警告 | 活跃 | 策略控制 | `EncryptionStrip_plain` |
| 已连接·UNKNOWN | 警告 | 活跃 | 建议禁止 | `EncryptionStrip_unknown` |
| 已连接·ENCRYPTED | 成功弱化 | 活跃 | 可用 | `EncryptionStrip_encrypted` |
| 拥塞 B7 | 保持 | RX 继续 | 暂停 | `CongestionBanner` |
| 断开 B8 | 灰态 | 只读 | 禁用 | `EncryptionStrip_disconnected` |

---

## 14. 折叠屏接续

| 步 | 接续项 | 控件名 |
| --- | --- | --- |
| FC-1 | B 栏选中设备 | `NearlinkDeviceRow_selected` |
| FC-2 | Port UUID 输入草稿 | `portUuidField` |
| FC-3 | 终端 scroll 位置 | `DataTerminal` |
| FC-4 | CommandDock 输入 | `commandInputField` |
| FC-5 | 加密条状态（不重置 UNKNOWN） | `EncryptionStrip_*` |
| FC-6 | 周期发送运行态 | `btnStopPeriodicSend` |

---

## 15. 验收要点（P0/P1）

- [ ] NL-B4 加密提醒条 **始终可见**不可折叠
- [ ] UNKNOWN **禁止**显示为已加密
- [ ] NL-B5 未加密 +「禁止发送」策略生效
- [ ] NL-B7 拥塞 1009700023 暂停 + 退避
- [ ] NL-B8 断开后 Log 可 ⚙ 导出
- [ ] NL-B5 HEX/换行/清屏对齐 SPP 终端
- [ ] stopScan 后再选设备
- [ ] SSAP/DT 单连接互斥 Dialog

---

## 16. 相关文档

| 文档 | 路径 |
| --- | --- |
| 能力检测 | `01-能力检测与权限引导流程.md` |
| SSAP | `02-SSAP-Client逐步交互流程.md` |
| 星闪设置 | `04-星闪模块设置流程.md` |
| UI 设计 | `../../03-UI设计/04-星闪模块/03-dataTransfer终端页面设计.md` |
| 周期发送 | `../06-统一后端/02-命令面板与周期发送逐步交互流程.md` |

---

## 17. 与 SPP 终端 UX 对齐检查（NL-08）

| 步 | 对齐项 | dataTransfer | SPP 参照 | 控件名 |
| --- | --- | --- | --- | --- |
| AL-1 | HEX/ASCII Toggle | ✓ B4-11 | SPP C 工具栏 | `toggleHexAscii` |
| AL-2 | 行尾 CR/LF/CRLF | ✓ B5-2 | CommandDock | `newlinePicker` |
| AL-3 | 清屏保留 Log | ✓ B4-12 | btnClearTerminal | `btnClearTerminal` |
| AL-4 | 从收藏选择 | ✓ B5-8 | FavoritePicker | `btnFavoritePicker` |
| AL-5 | 周期发送启停 | ✓ B5-9 | PeriodicSend | `btnPeriodicSend` |
| AL-6 | UnreadBar | ✓ B6-3 | DataTerminal | `UnreadBar` |

---

## 18. NL-C 加密配对完整子流程（P1）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| C-P1 | PLAIN 条点 **配对引导** | Sheet 步骤说明 | `btnPairingGuide` |
| C-P2 | 点 **开始配对** | `startPairing` Loading | `btnStartPairing` |
| C-P3 | 配对成功 | Chip→ENCRYPTED；Log | `EncryptionStrip_encrypted` |
| C-P4 | 配对失败 | Toast + 保持 PLAIN | `PairingErrorToast` |
| C-P5 | ⚙·连接 **禁止未加密发送** ON | B5-6 生效 | `switchBlockPlainSend` |

---

## 19. QA 走查 NL-B1～B8

| # | 步骤 | 必验 | 步 ID |
| --- | --- | --- | --- |
| 1 | Port UUID 非法 | 创建禁用 | B1-4 |
| 2 | 连接成功 | 加密条可见不可折叠 | B4-7 |
| 3 | PLAIN 发送 | 策略生效 | B5-6 |
| 4 | 注入拥塞码 | Banner+退避 | B7-* |
| 5 | 断开 | Log 可导出 | B8-5 |

---

## 20. NL-B1～B8 一步一表索引

| ID | 子步数 | 关键控件 | P0 验收 |
| --- | --- | --- | --- |
| NL-B1 | B1-1～B1-10 | `portUuidField` | UUID 校验 |
| NL-B2 | B2-1～B2-7 | `btnCreatePort` | portReady |
| NL-B3 | B3-1～B3-8 | `ConnectionStageBar_dt` | 加密检查阶段 |
| NL-B4 | B4-1～B4-14 | `EncryptionStrip_*` | **不可折叠** |
| NL-B5 | B5-1～B5-11 | `btnSend` | 加密策略 |
| NL-B6 | B6-1～B6-7 | `DataTerminal` | RX 节流 |
| NL-B7 | B7-1～B7-8 | `CongestionBanner` | 1009700023 |
| NL-B8 | B8-1～B8-9 | `btnDisconnect` | destroyPort 可选 |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `02-用户交互流程/04-星闪模块/` |
| 版本 | 深研草稿 v1.1 |

