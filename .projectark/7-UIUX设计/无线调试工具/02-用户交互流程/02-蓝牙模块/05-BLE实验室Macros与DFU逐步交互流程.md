# 05 — BLE 实验室 · Macros 与 DFU 逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` §4 · `feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md` · `feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md` · `01-功能清单/02-蓝牙模块/04-BLE实验室与高级功能清单.md` · `03-UI设计/02-蓝牙模块/04-BLE实验室与高级能力.md`  
> **范围**：Advertiser 启停 · GATT Server 配置 · Macros 28 操作子集录制/播放/导入 · DFU 选文件→协议→进度→错误  
> **门控**：专家模式；轻量模式隐藏 A 栏「实验室」Nav

---

## 1. 流程总览

```text
蓝牙 Tab → A 栏「实验室」（专家）
├── Advertiser（ADV-*）        广播包 CRUD · Start/Stop
├── GATT Server（GSRV-*）      预设/Custom · Import XML · SERVER Tab
├── Macros 运行时（MAC-*）     GATT 连接后 C 栏 · 28 tag 子集
└── DFU 向导（DFU-*）P3       选文件 → 协议 → 进度 → 错误恢复
```

**P0 约束**：实验室操作写入 SessionLog；DFU 整体 P3 可灰显占位；Macros **编辑**在 ⚙·命令与面板，**运行**在 GATT Connection C 栏。

---

## 2. 进入实验室 Hub

### 2.1 专家门控与入口

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 更多 Tab → 模式 → **专家** → 确认 | `expertModePreference=true` | `ExpertModeConfirmDialog` |
| 步2 | 蓝牙 Tab → A 栏 **实验室** | push `BluetoothLabHubPage` | `NavItem_bleLab` |
| 步3 | 轻量模式点实验室（若可见锁） | 说明 Sheet：需开启专家模式 | `ExpertGateSheet` |
| 步4 | — | Hub 三卡片：Advertiser / GATT Server / 固件升级 | `LabModeCard_*` |
| 步5 | — | 底栏 RiskFooter：误广播/误升级风险 | `LabRiskFooter` |
| 步6 | 宽屏 ≥840vp | A 栏二级 Nav；B 列表；C 编辑器 | `SideNavItem_lab` |

### 2.2 Hub 页控件

```text
PageHeader：BLE 实验室
ExpertBanner：专家模式已开启
ModeCards：[Advertiser] [GATT Server] [固件升级 P3]
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步7 | 点 **Advertiser** 卡片 | navigate `bluetooth/lab/advertiser` | `LabModeCard_advertiser` |
| 步8 | 点 **GATT Server** 卡片 | navigate `bluetooth/lab/gatt-server` | `LabModeCard_gattServer` |
| 步9 | 点 **固件升级** 卡片 | P3：占位 Banner 或进入 DFU 向导 | `LabModeCard_dfu` |
| 步10 | 点 **← 返回** | pop 至蓝牙 L0 | `btnNavBack` |

---

## 3. Advertiser — 广播模拟（ADV-*）

### 3.1 列表页

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| AD-1 | 进入 Advertiser 列表 | 显示历史广播包列表（模拟他机所见） | `AdvertiserListPage` |
| AD-2 | — | 空态：「暂无广播包 · 点 + 新建」 | `EmptyState_advList` |
| AD-3 | 点 **FAB +** | push AdvertiserEditorPage 新建 | `fabNewAdvPacket` |
| AD-4 | 点列表行 | 进入编辑已有包 | `AdvPacketRow` |
| AD-5 | 左滑 / ⋮ **Delete** | Destructive Dialog 确认删除 | `btnAdvDelete` |
| AD-6 | 顶栏菜单 **笔** | Complete Local Name Dialog（系统级名称） | `btnSetCompleteLocalName` |
| AD-7 | 行 **Start/Stop** Toggle ON | 本机开始 BLE 广播；Chip **广播中** | `toggleAdvStartStop` |
| AD-8 | Toggle OFF | stopAdvertise；Chip 消失 | `toggleAdvStartStop` |
| AD-9 | 4.29+ **Discoverable** Switch | 控制 Generic Access Discoverable flag | `switchDiscoverable` |
| AD-10 | **Service Solicitation UUID** | 写入广播 Service Solicitation 字段 | `fieldServiceSolicitation` |
| AD-11 | 与 GATT/UART 连接冲突 | Banner：「广播可能与连接互斥」 | `AdvConflictBanner` |
| AD-12 | Scanner **CLONE** deep link | 预填 AD 记录自扫描详情 | `DeepLinkHandler_cloneAdv` |

### 3.2 编辑器逐步

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| AE-1 | 新建或编辑包 | 显示包名 + AdvRecordList | `AdvertiserEditorPage` |
| AE-2 | 填 **包名** | 本地别名保存 | `advPacketName` |
| AE-3 | 点 **ADD RECORD** | ActionSheet 选 AD 类型 | `btnAddAdvRecord` |
| AE-4 | 选 Flags / Complete Name / Service UUID / Mfg Data / URI | 表单/HexEditor 切换 | `advRecordTypePicker` |
| AE-5 | 填 payload | AdvPreviewPane 实时解析 + RAW HEX | `advPayloadEditor` |
| AE-6 | 点 **Save** | 回列表；Toast「已保存」 | `btnAdvSave` |
| AE-7 | 点 **Start**（编辑器内） | 等同列表 Start；状态 Chip | `btnAdvStartFromEditor` |
| AE-8 | 预览区 Copy HEX | 剪贴板 | `btnCopyAdvHex` |

### 3.3 840vp Advertiser

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| AE-W1 | B 栏选包 | C 栏加载编辑器 | `AdvPacketRow` |
| AE-W2 | B 栏 Start/Stop | C 预览同步状态 | `toggleAdvStartStop` |
| AE-W3 | C 编辑 Save | B 列表刷新 | `btnAdvSave` |

---

## 4. Configure GATT Server（GSRV-*）

### 4.1 配置壳页

```text
顶栏 Dropdown：选择配置 / New / Import XML / Disable
Toolbar：ADD SERVICE · Share · Export XML
Tree：Service → Characteristic → Descriptor
Bottom：Sample configuration（Macros 教程 #3）
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| GS-1 | 打开 GATT Server 配置 | Dropdown 列出本地配置 DB | `GattServerConfigPage` |
| GS-2 | Dropdown 选 **New** | 空配置树 | `dropdownGattConfig` |
| GS-3 | Dropdown 选已有配置 | 加载 Service 树 | `dropdownGattConfig` |
| GS-4 | 点 **Import XML** | DocumentPicker；请求 Storage 权限 | `btnImportGattXml` |
| GS-5 | 选 Nordic GATT XML 文件 | 解析；成功则树刷新；失败 Error Banner | `DocumentPicker` |
| GS-6 | 解析失败 | Banner：行号/标签错误；树不变 | `GattXmlParseErrorBanner` |
| GS-7 | 点 **Disable** | ConfirmDialog → 禁用本机 GATT Server | `btnDisableGattServer` |
| GS-8 | 点 **ADD SERVICE** | ActionSheet：Custom / Link Loss / Immediate Alert / Current Time / Heart Rate | `btnAddService` |
| GS-9 | 选 SIG 预设 | 表单预填 UUID 与属性 | `GattServicePresetSheet` |
| GS-10 | 服务节点 ⋮ **ADD CHARACTERISTIC** | Dialog：UUID + Properties (R/W/N/I…) | `btnAddCharacteristic` |
| GS-11 | 特征节点 ⋮ **ADD DESCRIPTOR** | Dialog：UUID + 初值 | `btnAddDescriptor` |
| GS-12 | 点 **Share** | 系统 Share Sheet 导出 XML 摘要 | `btnShareGattConfig` |
| GS-13 | 点 **Export XML** | FilePicker 写入 Storage | `btnExportGattXml` |
| GS-14 | 点 **Sample configuration** | 加载教程 #3 样例（Macros 依赖） | `btnSampleGattConfig` |
| GS-15 | 树节点编辑值 | set-value 本地 DB 更新 | `GattServerTreeNode` |

### 4.2 连接后会话 — SERVER Tab

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| GS-16 | 远端连接本机 GATT Server | ConnectionPage Tab **SERVER** 可见 | `Tab_server` |
| GS-17 | 远端 Read 本机 char | Log pane 追加 incoming Read | `ServerLogPane` |
| GS-18 | 远端 Write | Log + 树节点值更新 | `ServerLogPane` |
| GS-19 | ⚙·连接 **Show incoming connections** ON | 入站连接 Toast + Log | `switchShowIncomingConn` |
| GS-20 | 设置 OFF | 静默拒绝或忽略入站（平台策略） | `switchShowIncomingConn` |

---

## 5. Macros — 28 操作子集

> **完整 tag 语义**：`feature-inventory/11` · 编辑入口：**蓝牙 ⚙·命令与面板·Macro 步骤** · 运行入口：**GATT Connection C 栏·Macros**

### 5.1 导入 / 录制 / 管理（设置侧）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MAC-E1 | ⚙ → 命令与面板 → **Macro 步骤** | 宏文件夹树 + Tutorial 文件夹 | `InnerTab_macro` |
| MAC-E2 | 点 **导入 XML** | Storage Picker；校验 `<macro>` 根 | `btnMacroImport` |
| MAC-E3 | XML 名冲突 | Dialog：覆盖 / 重命名 | `MacroNameConflictDialog` |
| MAC-E4 | 加载期 assert 失败 | Banner：「宏不可用 · 缺 service/char」；步骤灰显 | `MacroCompatBanner` |
| MAC-E5 | 点 **新建宏** FAB | MacroEditorPage | `fabNewMacro` |
| MAC-E6 | 点 **录制**（P2） | 连接 GATT 后记录 R/W/Notify 为步骤 | `btnMacroRecord` |
| MAC-E7 | 录制中点 **停止** | 生成 XML 草稿；可编辑 | `btnStopRecord` |
| MAC-E8 | 添加 operation | Picker 28 tag 子集（见 §5.3） | `MacroOpPicker` |
| MAC-E9 | 编辑 assert 节点 | assert-service / assert-characteristic / assert-value | `MacroAssertEditor` |
| MAC-E10 | **导出 XML** | Share Sheet | `btnMacroExport` |
| MAC-E11 | Link **Tutorial #3** | 跳转 Sample GATT Server 配置 | `linkTutorial3` |

### 5.2 运行时 Shell（GATT 已连接）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MAC-R1 | Connection C 栏点 **Macros** | 升起 MacrosRuntimeSheet | `btnMacrosRuntime` |
| MAC-R2 | — | 列表：文件夹 / 宏名 / 兼容 Chip | `MacrosRuntimeSheet` |
| MAC-R3 | 选 Tutorial #1/#2/#3 | 预置示例（若已导入） | `MacroListItem_tutorial` |
| MAC-R4 | 选自定义宏 | 步骤列表；未验证行 **灰色** | `MacroStepList` |
| MAC-R5 | 点 **Run** | 从首步或当前步执行 | `btnMacroRun` |
| MAC-R6 | 点 **Step Over** | 执行单步；成功行 **蓝色** 高亮 | `btnMacroStepOver` |
| MAC-R7 | 点 **Skip** | 跳过当前步 | `btnMacroSkip` |
| MAC-R8 | 点 **Loop** | 循环当前宏（专家） | `btnMacroLoop` |
| MAC-R9 | assert-value 失败 | 行 **橙色三角**（非红失败） | `MacroStepRow_assertFail` |
| MAC-R10 | 步骤 API 失败 | 行 **红色** + Log Error | `MacroStepRow_fail` |
| MAC-R11 | 执行中 disconnect | Sheet 关闭；Banner「宏已中断」 | `MacroInterruptBanner` |
| MAC-R12 | Sheet 关闭 | 步骤进度不持久（除非设置保存） | `btnSheetClose` |

### 5.3 28 操作逐步语义（子集逐步表）

#### Client 操作（12 tag）

| 步 | Tag | 用户动作（编辑） | 系统响应（运行 Step Over） | 控件名 |
| --- | --- | --- | --- | --- |
| M-C1 | `read` | 填 service/char UUID | Read → Log + GATT 树更新 | `MacroOp_read` |
| M-C2 | `read-descriptor` | 填 desc UUID | Read desc → Log | `MacroOp_readDesc` |
| M-C3 | `write` | 填 UUID + payload HEX | 等同 Write Sheet 自动提交 | `MacroOp_write` |
| M-C4 | `write-descriptor` | 填 CCCD 等 | Write desc | `MacroOp_writeDesc` |
| M-C5 | `begin-reliable-write` | — | RW 事务开始 | `MacroOp_beginRw` |
| M-C6 | `execute-reliable-write` | — | RW 提交 | `MacroOp_executeRw` |
| M-C7 | `abort-reliable-write` | — | RW 回滚 | `MacroOp_abortRw` |
| M-C8 | `wait-for-notification` | 填 char UUID + 可选 timeout | 阻塞至 Notify 或超时 | `MacroOp_waitNotify` |
| M-C9 | `wait-for-indication` | 同上 | 阻塞至 Indicate | `MacroOp_waitIndicate` |
| M-C10 | `sleep-if` | 条件表达式 | 条件满足即结束等待 | `MacroOp_sleepIf` |
| M-C11 | `sleep-until` | 期望值 | 值相等即结束 | `MacroOp_sleepUntil` |
| M-C12 | `unlock-eddystone` | Eddystone 密钥 | P3 灰显不可用 | `MacroOp_unlockEddystone` |

#### Server 操作（9 tag — 依赖 GATT Server 配置）

| 步 | Tag | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- | --- |
| M-S1 | `wait-for-read` | 填 char UUID | 阻塞远端 Read | `MacroOp_waitRead` |
| M-S2 | `wait-for-read-descriptor` | 填 desc | 阻塞远端 Read desc | `MacroOp_waitReadDesc` |
| M-S3 | `wait-for-write` | 填 char + assert-value | 阻塞 + 断言 | `MacroOp_waitWrite` |
| M-S4 | `wait-for-write-descriptor` | 填 desc | 同上 | `MacroOp_waitWriteDesc` |
| M-S5 | `wait-for-execute-reliable-write` | — | 等 Execute/Abort | `MacroOp_waitExecRw` |
| M-S6 | `set-value` | char + value | 本地 char 更新 + 树刷新 | `MacroOp_setValue` |
| M-S7 | `set-descriptor-value` | desc + value | 本地 desc 更新 | `MacroOp_setDescValue` |
| M-S8 | `send-notification` | char + value | 推 Notify 至远端 | `MacroOp_sendNotify` |
| M-S9 | `send-indication` | char + value | 推 Indicate | `MacroOp_sendIndicate` |

#### Other 操作（7 tag）

| 步 | Tag | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- | --- |
| M-O1 | `sleep` | 毫秒数 | 纯等待 | `MacroOp_sleep` |
| M-O2 | `read-rssi` | — | Log RSSI 值 | `MacroOp_readRssi` |
| M-O3 | `request-mtu` | 目标 MTU | MTU 协商 | `MacroOp_requestMtu` |
| M-O4 | `request-connection-priority` | balanced/high/low | Android 优先级 | `MacroOp_requestPriority` |
| M-O5 | `read-phy` | — | Log PHY | `MacroOp_readPhy` |
| M-O6 | `set-preferred-phy` | 1M/2M/CODED | PHY 切换 | `MacroOp_setPhy` |
| M-O7 | `wait-for-phy-update` | 期望 PHY | 阻塞 PHY 变更 | `MacroOp_waitPhy` |

### 5.4 验证灰行与 assert 树

| 步 | 触发 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| V-1 | 宏加载 `assert-server-service` 失败 | 整宏不可用；Banner | `MacroCompatBanner` |
| V-2 | `assert-service` 远端缺 service | 相关步骤 **灰色**；Run 跳过或阻断（设置） | `MacroStepRow_disabled` |
| V-3 | `assert-characteristic` MANDATORY 失败 | 步骤灰 + Tooltip 原因 | `MacroStepRow_disabled` |
| V-4 | OPTIONAL 失败 | 步骤黄警告；可 Skip | `MacroStepRow_optionalWarn` |
| V-5 | Step Over 后 `assert-value` 不匹配 | **橙色三角** | `MacroStepRow_assertFail` |
| V-6 | 用户点灰行 **Step Over** | Toast「步骤未通过加载验证」 | — |

---

## 6. DFU 固件升级向导（DFU-* · P3）

> **边界**：Legacy/Secure/McuManager/SUIT 四协议；完整 SUIT Confirm → nRF Device Manager；YoWire 实验室 DFU 为 P3 专家功能。

### 6.1 入口与前置

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DFU-1 | 实验室 Hub → **固件升级** | push DfuWizardPage；或 P3 占位 Banner | `LabModeCard_dfu` |
| DFU-2 | 自 GATT 已连接页点顶栏 **DFU 图标** | 携带 `deviceAddress` 进入向导 | `btnDfuEntry` |
| DFU-3 | 未连接设备 | Step1 提示「请先连接目标设备或 DfuTarg」 | `DfuPrereqBanner` |
| DFU-4 | 非专家模式 | 入口隐藏或锁 Sheet | `ExpertGateSheet` |

### 6.2 选文件 → 协议

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DFU-5 | Step **选择固件** | 显示 Distribution ZIP / 分文件 / McuMgr bin 选项 | `DfuStepPickFile` |
| DFU-6 | 点 **Distribution ZIP** | DocumentPicker 选 `.zip` | `btnPickZip` |
| DFU-7 | 或选 **SoftDevice/Bootloader/Application** 分文件 | 多 Picker：bin/hex + init .dat | `btnPickSplitFiles` |
| DFU-8 | 或选 **McuManager .bin** | 单 bin Picker | `btnPickMcuBin` |
| DFU-9 | 文件校验失败 | Error：签名/格式/大小；禁止下一步 | `DfuFileErrorBanner` |
| DFU-10 | Step **选择协议** | Radio：Legacy DFU / Secure DFU / McuManager / SUIT | `radioDfuProtocol` |
| DFU-11 | SUIT 设备 API 不足 | SUIT 项灰显 + Tooltip | `radioDfuSuit` |
| DFU-12 | 显示 **Keep bond** Switch | 默认 ON（Toolbox ISSUE#44） | `switchDfuKeepBond` |
| DFU-13 | Secure DFU：**Disable resume** | 可选 Switch | `switchDfuDisableResume` |
| DFU-14 | Legacy：**Force scan bootloader** | 可选 Switch | `switchDfuForceScan` |
| DFU-15 | 点 **开始升级** | 进入传输阶段；可能触发 Buttonless → Bootloader 广播 | `btnDfuStart` |

### 6.3 进度与完成

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DFU-16 | 传输中 | ProgressBar + 百分比 + 速率 | `DfuProgressBar` |
| DFU-17 | — | Log pane 追加 DFU 行（阶段/part/image） | `DfuLogPane` |
| DFU-18 | Buttonless 切换 Bootloader | Banner「等待 Bootloader 广播…」；可选自动 reconnect | `DfuBootloaderBanner` |
| DFU-19 | 传输 100% | Success Dialog「升级完成 · 设备可能重启」 | `DfuSuccessDialog` |
| DFU-20 | 点 **刷新 GATT** | Connection ⋮ Refresh services（CM-06） | `btnRefreshGattAfterDfu` |
| DFU-21 | 用户点 **取消** | ConfirmDialog → abort 传输 | `btnDfuCancel` |

### 6.4 错误恢复

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| DFU-E1 | 传输中断 / 超时 | Error 卡：错误码 + 摘要 | `DfuErrorCard` |
| DFU-E2 | 签名验证失败（Secure） | 禁止 resume；建议重选 ZIP | `DfuErrorCard` |
| DFU-E3 | McuMgr 模式不匹配 | Banner 指向 Device Manager 完整 FOTA | `DfuMcuMgrHintBanner` |
| DFU-E4 | 点 **重试** | 从选文件或协议步恢复（保留路径） | `btnDfuRetry` |
| DFU-E5 | 点 **查看 Log** | 跳转蓝牙 ⚙·会话与日志·DFU 事件 | `linkDfuSessionLog` |
| DFU-E6 | 设备变砖风险说明 | 静态 RiskFooter 始终可见 | `DfuRiskFooter` |

---

## 7. 宽屏实验室流程（≥840vp 摘要）

| 步 | 用户动作 | B 栏 | C 栏 |
| --- | --- | --- | --- |
| W-L1 | A 栏选实验室 | Hub 或子 Nav 高亮 | — |
| W-L2 | Advertiser | 包列表 + Start/Stop | HEX 编辑器 + 预览 |
| W-L3 | GATT Server | 配置 Dropdown 列表 | Service 树编辑 |
| W-L4 | DFU | 步骤条摘要 | Log + Progress |
| W-L5 | GATT 连接 + Macros | B 设备列表 | C Connection + Macros Sheet |

---

## 8. 与主路径衔接

| 来源 | 目标 | 行为 |
| --- | --- | --- |
| GATT Scanner CLONE | Advertiser 编辑器 | deep link 带 AD HEX |
| GATT Connection DFU 图标 | DFU 向导 Step2 | 跳过连接步 |
| ⚙·Macro 编辑 | GATT Macros Runtime | 只读执行 |
| Tutorial #3 Sample GATT | Macro #3 运行 | 依赖 GSRV-07 |

---

## 9. 验收要点（流程级）

- [ ] 轻量模式不可达实验室 Advertiser/GATT Server/DFU
- [ ] Advertiser Start/Stop 状态 Chip 与 Log 一致
- [ ] GATT Server Import XML 失败不 corrupt 本地 DB
- [ ] Macros 加载 assert 失败步骤 **灰色**；assert-value 失败 **橙色三角**
- [ ] Macros 28 tag 子集逐步可 Step Over（P3 灰显项除外）
- [ ] DFU：选文件 → 协议 → 进度 → 错误 → 重试 可走通（P3 占位可 Mock）
- [ ] 840vp 实验室无第四 Inspector 栏
- [ ] 实验室事件可经蓝牙 ⚙·会话与日志导出

---

## 10. 相关文档

| 文档 | 路径 |
| --- | --- |
| BLE GATT 主流程 | `01-BLE-GATT逐步交互流程.md` |
| 蓝牙设置·Macro 编辑 | `04-模块设置与会话命令流程.md` |
| UI 设计 | `../../03-UI设计/02-蓝牙模块/04-BLE实验室与高级能力.md` |
| 功能清单 | `../../01-功能清单/02-蓝牙模块/04-BLE实验室与高级功能清单.md` |
| nRF Macros 证据 | `.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md` |
| nRF DFU 证据 | `.research/feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md` |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `02-用户交互流程/02-蓝牙模块/` |
| 版本 | 深研草稿 v1 |
| 步骤域 | ADV-* · GSRV-* · MAC-* · DFU-* |

---

## 11. Automated Tests 边界（P3 · 无 in-app UI）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| AT-1 | 专家搜索 Automated Tests | 无入口；About 页文档链接 nRF test.bat | `NavRow_about` |
| AT-2 | 导入 `<test-suite>` XML | P3 预留：Toast「请使用 Macros 或 ADB Tests」 | `btnMacroImport` |
| AT-3 | Tests 专属 tag scan/connect/dfu | 不在 Macro 28 子集 UI 列出 | `MacroOpPicker` |

---

## 12. 折叠屏 / 旋转接续（实验室）

| 步 | 接续项 | 控件名 |
| --- | --- | --- |
| FC-1 | Advertiser 编辑器 AD 记录列表 | `AdvRecordList` |
| FC-2 | GATT Server 树展开节点 | `GattServerTreeNode` |
| FC-3 | Macros Runtime 当前步骤索引 | `MacroStepList` |
| FC-4 | DFU 向导当前 Step + 已选文件路径 | `DfuWizardPage` |

