# 01 — nRF Connect 逐步对照 YoWire

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **竞品**：[01-nRF-Connect-Android-全量功能清单.md](../../01-功能清单/09-竞品APP功能清单/01-nRF-Connect-Android-全量功能清单.md) · Nordic 4.29.1  
> **YoWire 流程**：[01-BLE-GATT逐步交互流程.md](../02-蓝牙模块/01-BLE-GATT逐步交互流程.md) · [05-BLE实验室Macros与DFU…](../02-蓝牙模块/05-BLE实验室Macros与DFU逐步交互流程.md) · [04-模块设置与会话命令流程.md](../02-蓝牙模块/04-模块设置与会话命令流程.md)  
> **深研**：`.research/feature-inventory/08` · `11` · `13` · `21` · `22`

---

## 0. 映射总览

| 竞品域 | 竞品步号域 | YoWire 主文档 | YoWire 步号域 |
| --- | --- | --- | --- |
| Scanner 列表 + Filter | S-01～S-14 · SET-FIL-* | 01-BLE-GATT §3～§7 | 步1～步7 · Filter 步1～12 |
| Bonded Tab | NRF-B-01～04 | 01-BLE-GATT §3 Segmented | `SegmentedTab_bonded` |
| CONNECT / ⋮ | S-04～S-05 | 01-BLE-GATT §6 | CS-1～CS-6 |
| Connection CLIENT | NRF-GATT-* · NRF-CM-* | 01-BLE-GATT §8～§12 | 步1～步8 · RW · Log |
| Macros 28 tag | M-0.* · Client/Server/Other | 01 §13 + 05 §5 | M-1～M-12 · MAC-* |
| DFU | NRF-DFU-* | 05 §6 | DFU-1～DFU-E6 |
| Advertiser / GATT Server | NRF-ADV-* · NRF-GS-* | 05 §3～§4 | ADV-* · GSRV-* |
| Settings | NRF-SET-CONN/SCAN-* | 04 模块设置 | SET-* |

**显式 GAP（本对照重点）**：

| GAP | 竞品 | YoWire |
| --- | --- | --- |
| **GAP-MASK** | 仅 HEX 子串；Tests XML `data=` | Filter 第六维 `filterMfgDataMask` P0 |
| **GAP-840** | 单列手机 + 4.29 第二 CLIENT Tab | ≥840vp A/B/C；B 列表 C 树+Log |
| **GAP-STOP** | CONNECT 不强制 stopScan | P0 连接前 `btnScanToggle` OFF |
| **GAP-LOGFMT** | Log SAVE 单文件 + nRF Logger | 蓝牙 ⚙·会话与日志 多格式 SessionLog |

---

## 1. 应用壳与权限（前置 0.*）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| 0.1 | 冷启动 App | 底部 Tab：Scanner / Bonded / Advertiser | 步1～2 | `TabItem_bluetooth` · `NavItem_bleGatt` | [01-BLE-GATT §2](../02-蓝牙模块/01-BLE-GATT逐步交互流程.md) | **IA 差**：YoWire 蓝牙 L0 三路径，非 nRF 三 Tab |
| 0.2 | 首次扫描 | 系统 Location 权限 Dialog | 步5 | `CapabilityBanner_ble` | 01 §2.1 | 对齐 P0；HarmonyOS 权限文案不同 |
| 0.3 | Location Service 关 | 应用内提示 → 系统设置 | 步5 | `CapabilityBanner_ble` | 01 §2.1 | 对齐 |
| 0.4 | 打开 ☰ Drawer | Configure GATT Server · Settings | 步9 | `btnModuleSettings` | 01 §2.1 · [04 设置](../02-蓝牙模块/04-模块设置与会话命令流程.md) | **增值**：Drawer 项进 **蓝牙 ⚙** 分组 |
| 0.5 | Settings→Connectivity | Auto discover · Abort RW Switch | SET-CONN | `autoDiscoverSwitch` · `reliableWriteAutoAbortSwitch` | 04 设置 | 对齐 P0/P1 |
| 0.6 | Settings→Scanner | PHY · batching · connectable 等 9 项 | SET-SCAN | `scanPhyPreference` 等 | 04 · 01 §4 | 对齐 P1；进 ⚙·扫描 |

---

## 2. Scanner S-01～S-14 → BLE-GATT 扫描列表

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| S-01 | 进入 Scanner Tab | 实时 BLE 列表 + RSSI | 步6 ON | `btnScanToggle` · `BleDeviceRow` | 01 §2.1 · §5 | 对齐；YoWire 顶栏 Toggle 非独立 Tab |
| S-02 | 点顶栏 Filter | Filter Sheet | 步8 · Filter步1 | `btnFilter` · `FilterSheet` | 01 §4.1 | 对齐 P0 |
| S-03 | Only Favorites Switch | Filter 内 | Filter步6 | `filterOnlyFavorites` | 01 §4.1 | 对齐 P1 |
| S-04 | 点 **CONNECT** | 行右侧 CONNECT | 步1 CS-1 | `btnConnect` | 01 §6.1 | **GAP-STOP**：YoWire 先 stopScan |
| S-05 | CONNECT ⋮ 子菜单 | autoConnect / PHY / Bond / Remove bond | CS-2～6 | `ConnectOptionsSheet` | 01 §6.2 | 对齐 P1 |
| S-06 | 点行展开 AD | 蓝色标题解析字段 | 步4 · 广播步2 | `BleDeviceRow_body` · `ParserPicker` | 01 §7 | 对齐 P1 |
| S-07 | 点 **RAW** | HEX 按 AD 记录拆分 | 广播步3 | `btnRawAdv` | 01 §7 | 对齐 P0 |
| S-08 | 点 **MORE** | 包历史 RSSI/间隔/曲线 | 广播步4～5 | `btnAdvMore` · `Tab_advChart` | 01 §7 · §14 | 对齐 P2 |
| S-09 | 点 **CLONE** | → Advertiser Tab | 广播步6 | `btnCloneAdv` | 01 §7 · [05 ADV](../02-蓝牙模块/05-BLE实验室Macros与DFU逐步交互流程.md) | P2 实验室 deep link |
| S-10 | 广播含 URL → OPEN | 系统浏览器 Physical Web | — | — | — | **跳过 v1** |
| S-11 | Show RSSI graph | 右滑或菜单全屏曲线 | §14 步1～2 | `menuRssiGraph` | 01 §14 | 对齐 P1 |
| S-12 | RSSI Export CSV/EXCEL | 图表菜单 Export | §14 步3 | `menuRssiExport` | 01 §14 · 04 导出 | **增值**：SessionLog 多格式 |
| S-13 | 长按多选 | Assign name / Export avg | 步5 · §14 | `SelectionModeBar` · `btnBulkAssignName` | 01 §5 · §14 | P3 实验室级 |
| S-14 | Scanner Settings 联动 | ☰ Settings→Scanner 9 项 | 步9 | 蓝牙 ⚙·扫描 | 04 设置 | 对齐 P1 |

---

## 3. Filter SET-FIL-* → Filter 五维 + Mask（GAP-MASK）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| SET-FIL-01 | 名称或地址部分匹配 | Filter TextField | Filter步2 | `filterNameOrAddress` | 01 §4.1 | 对齐 P0 |
| SET-FIL-02 | 广播数据 HEX 子串 | Filter TextField | Filter步3 | `filterAdvHex` | 01 §4.1 | 对齐 P0 |
| SET-FIL-03 | RSSI 阈值下限 | Slider/数值 | Filter步4 | `filterRssiMin` | 01 §4.1 | 对齐 P0 |
| SET-FIL-04～08 | 排除 Apple/Microsoft/Google/Samsung/Mesh… | Checkbox 组 | Filter步5 | `filterExcludeTypes` | 01 §4.1 | 对齐 P1 |
| SET-FIL-09 | Only Favorites | Filter Switch | Filter步6 | `filterOnlyFavorites` | 01 §4.1 | 对齐 P1 |
| SET-FIL-X1 | Filter 右侧 **X** 清除 | 恢复全量 | Filter步9 | `btnFilterClear` | 01 §4.1 | 对齐 P0 Reset |
| — Apply | Back/Done 应用 | 列表即时过滤 | Filter步8 | `btnFilterApply` | 01 §4.1 | 对齐 |
| **— Mfg Mask** | **nRF 无 UI**（Tests `data=`） | — | Filter步7 | `filterMfgDataMask` | 01 §4.1 | **YoWire P0 增值 GAP-MASK** |
| — Service UUID | UI 弱；Tests scan-for | — | 专家 Filter | `filterServiceUuid` | 04 · PRD §7.2 | **YoWire P0 增值** |
| — | — | — | Filter步10 | `btnSaveFilterPreset` | 01 §4.1 | **YoWire-only** 预设存 ⚙ |

---

## 4. Bonded Tab → Segmented「已绑定」

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NRF-B-01 | 点 Bonded Tab | 系统 bond 列表 | 步2 | `SegmentedTab_bonded` | 01 §3 | **IA 差**：YoWire Segmented 非独立 Tab |
| NRF-B-02 | 列表项名/MAC | 无广播解析 | 步2 | `BleDeviceRow` | 01 §3 | 对齐 |
| NRF-B-03 | CONNECT / ⋮ | 同 Scanner | CS-1～6 | 同左 | 01 §6 | Bonded 无 stopScan 问题；YoWire 仍 stopScan 统一 |
| NRF-B-04 | 连接成功 | → Connection | CS-3 | `ConnectionPage` | 01 §8 | 对齐 P0 |

---

## 5. Connection CM / CLIENT → GATT 树

### 5.1 进入 Connection 与 Tab

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| 3.1.1 | 连接成功 | 顶栏设备名 · Disconnect · ⋮ | 步1 | `ConnectionTitleBar` | 01 §8.1 | 对齐 |
| 3.1.2 | Auto discover ON | GATT discover 进度 | 步2 | `DiscoverProgressIndicator` | 01 §8.1 | 对齐 P0 |
| 3.1.3 | Tab CLIENT / SERVER | 4.29+ 第二 CLIENT Tab | 步3～5 | `Tab_client` · `Tab_server` · `Tab_log` | 01 §8.1 | **GAP-840**：宽屏双 pane 替代第二 Tab |
| 3.1.4 | 右滑 / Show log | Log pane | 步5 · Log步1 | `LogPane` · `Tab_log` | 01 §11 | 对齐 P0 |
| 3.1.5 | 红 FAB | Macros Sheet | M-1 | `fabMacros` / `btnMacrosToolbar` | 01 §13 · 05 §5.2 | 宽屏 FAB→工具栏 |

### 5.2 CLIENT GATT 树操作

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NRF-GATT-02 | 展开 Service 树 | Known UUID 友好名 | CLIENT步1 | `TreeNode_service` | 01 §9 | 对齐 P0 |
| NRF-GATT-03 | Read characteristic | 行内更新 + Log | CLIENT步3 | `btnCharRead` | 01 §9 | 对齐 P0 |
| NRF-GATT-04 | Write → Dialog | HEX/解析 · Big Endian | CLIENT步4～6 | `WriteCharacteristicSheet` | 01 §9.1 | 对齐 P0/P1 |
| NRF-GATT-05/06 | Notify / Indicate | CCCD + 持续 Log | CLIENT步5 | `btnCharNotify` | 01 §9 | 对齐 P0 |
| NRF-GATT-07 | Descriptor R/W | Descriptor 行图标 | CLIENT步6 | `TreeNode_descriptor` | 01 §9 | 对齐 P0 |
| NRF-GATT-08 | Reliable Write B/E/A | ⋮ 子菜单 | RW步1～4 | `menuRwBegin` 等 | 01 §10 | 对齐 P1 |
| NRF-GATT-09 | Parse known UUIDs OFF | ⋮ Toggle | CLIENT步8 | `menuParseUuidOff` | 01 §9 | 对齐 P1 |
| NRF-GATT-13 | 无一键 Copy UUID | 从 Log 复制 | CLIENT步7 | `CharContextMenu` 长按复制 | 01 §9 | **YoWire P1 增值** |
| NRF-CM-06 | Refresh services | ⋮ | ⋮步2 | `menuRefreshServices` | 01 §12 | 对齐 P2 |
| NRF-CM-07 | Request MTU | ⋮ Dialog 23–517 | 步7 · ⋮步3 | `chipMtu` · `menuRequestMtu` | 01 §8 · §12 | 对齐 P0 |
| NRF-CM-08～10 | Priority / Read PHY / Set PHY | ⋮ 专家 | ⋮步4 | `menuReadPhy` | 01 §12 | 对齐 P1 |
| NRF-CM-14 | Remove bond | **CONNECT ⋮ 仅** | CS-5 | `listItemRemoveBond` | 01 §6.2 | 对齐 P1 |

### 5.3 Log pane

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NRF-LOG-01 | 事件流 Log | connect/discover/read… | Log步1～2 | `LogPane` · `LogEntryRow` | 01 §11 | 对齐 P0 |
| NRF-LOG-02 | SAVE 导出 | Storage 单文件 | Log步3 · 步4 | `btnLogSave` · `NavRow_gattSessions` | 01 §11 · 04 | **GAP-LOGFMT** 多格式 ⚙ |
| NRF-LOG-03～04 | Copy / Share | Log 底栏四图标 | 04 导出 | `btnLogCopy` 等 | 04 | 对齐 P1 |
| NRF-LOG-05 | Clear Trash | 清空会话 log | 04 | `btnLogClear` | 04 | 对齐 P0 |
| NRF-LOG-07 | nRF Logger 持久化 | 独立 Logger App | — | SessionLog 模块内 | 04 · [06 统一后端](../06-统一后端/01-会话日志导出逐步交互流程.md) | **跳过 Logger 依赖** |

---

## 6. Macros 28 子集 → 05 BLE 实验室 / 01 §13

### 6.1 Macros UI 壳

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| M-0.1 | 已连接 CLIENT | GATT 树可见 | MAC-R1 前置 | `Tab_client` | 05 §5.2 | 对齐 |
| M-0.2 | 点红 FAB | Macros Sheet | M-1 · MAC-R1 | `fabMacros` · `MacrosRuntimeSheet` | 01 §13 · 05 §5.2 | 对齐 |
| M-0.3 | Tutorial 文件夹 | 3 示例宏 | MAC-R3 | `MacroListItem_tutorial` | 05 §5.2 | 对齐 P3 |
| M-0.4 | 点宏行展开 | operation 灰点列表 | M-3～5 | `MacroListItem` · `MacroOpIndicator_pending` | 01 §13.1 | 对齐 |
| M-0.5 | 导入 XML | Storage | MAC-E2 | `btnMacroImport` | 05 §5.1 | **编辑在 ⚙**；运行时只读 |
| M-0.6 | 兼容性 Banner | 服务不匹配 | M-4 · V-1 | `MacroCompatBanner` | 05 §5.4 | 对齐 |
| M-0.7 | Step Over / Run / Loop | 控制条 | M-6～9 · MAC-R5～8 | `btnMacroStepOver` 等 | 01 §13.2 · 05 §5.2 | 灰蓝红橙对齐 inventory 11 |

### 6.2 Client 12 tag（节选逐步）

| 竞品 Tag | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| read | Step Over 读 char | Log + 树更新 | M-C1 | `MacroOp_read` | 05 §5.3 | 对齐 P1 |
| write | 自动 Write Dialog | Log | M-C3 | `MacroOp_write` | 05 §5.3 | 对齐 |
| begin/execute/abort-rw | Reliable Write 三步 | RW 状态条 | M-C5～7 | `MacroOp_beginRw` 等 | 05 §5.3 | 对齐 P1 |
| wait-for-notification | 阻塞至 notify | 超时红点/橙三角 | M-C8 | `MacroOp_waitNotify` | 05 §5.3 | 对齐 P3 |
| unlock-eddystone | Eddystone key | 专用服务 | M-C12 | `MacroOp_unlockEddystone` | 05 §5.3 | **P3 灰显跳过** |
| request-mtu | Log MTU | — | M-O3 | `MacroOp_requestMtu` | 05 §5.3 | 对齐 P0 |

### 6.3 Server 9 tag + Other 7 tag

| 竞品域 | 竞品前置 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| wait-for-read/write 等 | GATT Server 配置 + SERVER Tab | M-S1～9 | `MacroOp_waitRead` 等 | 05 §5.3 | P3；依赖 GSRV Sample |
| sleep / read-rssi / PHY 7 项 | 已连接 | M-O1～7 | `MacroOp_sleep` 等 | 05 §5.3 | 对齐子集 |
| assert 树 | 加载期 + Step 后橙三角 | V-1～5 | `MacroStepRow_assertFail` | 05 §5.4 | 对齐 inventory 11 |

**v1 分期**：PRD P1 单命令收藏；完整 28-tag 引擎 P3 — 见 09 清单 §19。

---

## 7. DFU → 05 §6

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NRF-DFU-01 | Connection 顶栏 **DFU 图标** | 非 ⋮ 菜单 | DFU-2 | `btnDfuEntry` | 05 §6.1 | 对齐 P3 |
| NRF-DFU-02 | 文件类型子菜单 | ZIP / SoftDevice / Bootloader / App | DFU-5～7 | `DfuStepPickFile` | 05 §6.2 | 对齐 P3 |
| NRF-DFU-03 | Document Picker | 选包 | DFU-6 | `DocumentPicker` | 05 §6.2 | 对齐 |
| NRF-DFU-04 | Buttonless → Bootloader | Scanner 见 DfuTarg | DFU-18 | `DfuBootloaderBanner` | 05 §6.3 | 对齐 P3 |
| NRF-DFU-05 | DFU 进度 Log | Log pane [DFU] | DFU-17 | `DfuLogPane` | 05 §6.3 | 对齐 |
| NRF-DFU-07 | McuMgr .bin | 主 App 轻量 | DFU-8 | `btnPickMcuBin` | 05 §6.2 | SUIT 完整 → Device Manager **跳过** |
| NRF-DFU-12 | DFU 后 Refresh | Connection ⋮ | DFU-20 | `btnRefreshGattAfterDfu` | 05 §6.3 | 对齐 P2 |
| — | 实验室 Hub 入口 | — | DFU-1 | `LabModeCard_dfu` | 05 §6.1 | **YoWire** 专家门控 |

---

## 8. Advertiser / GATT Server → 05 §3～§4

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NRF-ADV-01～04 | Advertiser Tab 列表 Start/Stop | FAB + 编辑器 | AD-1～8 | `AdvertiserListPage` · `toggleAdvStartStop` | 05 §3 | P2/P3 专家实验室 |
| NRF-ADV-05～06 | Discoverable · Service Solicitation | 4.29+ 编辑器 | AD-9～10 | `switchDiscoverable` · `fieldServiceSolicitation` | 05 §3.1 | 对齐 P2 |
| NRF-GS-01～07 | ☰ Configure GATT Server | Dropdown · Import XML | GS-1～14 | `GattServerConfigPage` | 05 §4 | P3；Tutorial #3 链 Macros |
| 3.4.1～2 | SERVER Tab 镜像 | 远端 R/W Log | GS-16～18 | `Tab_server` · `ServerLogPane` | 05 §4.2 | 对齐 P3 |

---

## 9. 840vp 三分栏 GAP 对照

| 竞品路径 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Scanner 单列列表 | Scanner Tab 全屏 | §16 步9～11 | B `BleDeviceRow` · C `GattTreePane` | 01 §16 · [07-840vp](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md) | **GAP-840** YoWire 三分栏 |
| 第二 CLIENT Tab | 4.29 同设备双 Tab | §16 | C 双 pane 树+Log | 01 §16 | YoWire 用布局替代 |
| Filter Sheet | 全宽 Bottom | Filter 宽屏 | 居中 480×560 | 01 §4 · §16 | 对齐 doc 10 |
| Macros FAB | 右下 FAB | §16 | C `btnMacrosToolbar` | 01 §16 | 宽屏无 FAB |
| Log SAVE | 单文件 | Log步4 | ⚙ `NavRow_gattSessions` | 01 §11 · 04 | **GAP-LOGFMT** 模块 SessionLog |
| Settings | Drawer Settings | 步9 | `btnModuleSettings` push 全屏 | 04 · 01 §2 | **SessionLog 在 ⚙** 非 Connection 内 |

---

## 10. SessionLog 在模块 ⚙（GAP 专节）

| 竞品能力 | 竞品步号/控件 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| Log pane 会话内 SAVE | NRF-LOG-02 | Log步3～4 | `btnLogSave` → ⚙ | 01 §11 · 04 · [06-统一后端](../06-统一后端/01-会话日志导出逐步交互流程.md) | TXT/CSV/JSON 统一 |
| nRF Logger 跨 App | NRF-LOG-07 | — | `SessionLogService` 模块内 | 04 · 06 | 无第三方 Logger |
| Macros 执行 Log | M-0.7 Log pane | MAC-R10 | `LogPane` + ⚙ 导出 | 05 · 04 | 实验室事件可导出 |
| DFU 事件 Log | NRF-DFU-05 | DFU-E5 | `linkDfuSessionLog` | 05 §6.4 | YoWire-only 链路 |
| RSSI 导出 | S-12 | §14 步3 | ⚙·会话·扫描 | 01 §14 · 04 | 多格式 |

---

## 11. 验收勾选（对照 derived）

- [ ] S-01～07 + Filter 五维 + **Mfg Mask** 可走通  
- [ ] CONNECT 前 **stopScan**（GAP-STOP）  
- [ ] CLIENT R/W/N/I + Reliable Write + MTU  
- [ ] Log → ⚙ SessionLog 导出（GAP-LOGFMT）  
- [ ] Macros Step Over 灰蓝红橙（28 子集 P3 灰显项除外）  
- [ ] ≥840vp B 列表 + C 树+Log（GAP-840）  
- [ ] DFU P3 占位或 Mock 可走通  

---

## 12. 证据索引

| 键 | 路径 |
| --- | --- |
| 竞品清单 | `09/01-nRF-Connect-Android-全量功能清单.md` |
| inventory 08 | `.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` |
| inventory 11 | `.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md` |
| inventory 13 | `.research/feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md` |
| inventory 22 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` §1 |

---

## 13. Connection ⋮ CM-01～CM-14 全量对照

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| NRF-CM-01 | Show log | Connection ⋮ | Log步1 | `menuShowLog` · `Tab_log` | 01 §11 | 对齐 |
| NRF-CM-02 | Parse known UUIDs | ⋮ Toggle | ⋮步5 | `menuParseUuids` | 01 §12 | P1 |
| NRF-CM-03～05 | RW Begin/Execute/Abort | ⋮ 子菜单 | RW步1～4 | `submenuReliableWrite` | 01 §10 | P1 |
| NRF-CM-06 | Refresh services | ⋮ | ⋮步2 | `menuRefreshServices` | 01 §12 | P2 |
| NRF-CM-07 | Request MTU | ⋮ Dialog | 步7 | `menuRequestMtu` | 01 §8 | P0 |
| NRF-CM-08～10 | Priority / Read PHY / Set PHY | ⋮ | ⋮步4 | `menuReadPhy` | 01 §12 | P1 |
| NRF-CM-11 | Bond | ⋮ [INFER] | CS-4 | `listItemBond` | 01 §6.2 | 在 CONNECT ⋮ |
| NRF-CM-12 | Clone services | ⋮ | GSRV P3 | 05 §4 | P3 |
| NRF-CM-13 | Open second tab | ⋮ 4.29+ | §16 | 840vp 双 pane | 01 §16 | GAP-840 |
| NRF-CM-15 | Copy UUID | Log 底栏非 ⋮ | CLIENT步7 | `CharContextMenu` | 01 §9 | YoWire 增值 |

---

## 14. NRF-SET-SCAN 九项 → 蓝牙 ⚙

| 竞品 ID | 设置项 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- |
| NRF-SET-SCAN-01 | PHY | `scanPhyPreference` | 04 | P1 |
| NRF-SET-SCAN-02 | Offloaded batching | `offloadedBatchingSwitch` | 04 | P1 |
| NRF-SET-SCAN-03 | Only connectable | `onlyConnectableSwitch` | 04 | P1 |
| NRF-SET-SCAN-04 | Only Adv Extension | `advExtensionOnlySwitch` | 04 | P2 |
| NRF-SET-SCAN-05 | Coded PHY only | `codedPhyOnlySwitch` | 04 | P2 |
| NRF-SET-SCAN-06 | Scanning mode | `scanningModePicker` | 04 | P1 |
| NRF-SET-SCAN-07 | Continuous scan | `continuousScanSwitch` | 04 | P1–P2 |
| NRF-SET-SCAN-08 | Compatibility PHY | `phyCompatSwitch` | 04 | P1–P2 |
| NRF-SET-SCAN-09 | CSV delimiter | `csvDelimiterPreference` | 04 · 01 §14 | P1 |

---

## 15. Automated Tests 边界（P3）

| Tests Tag | 竞品入口 | YoWire | 差异/增值 |
| --- | --- | --- | --- |
| scan/connect/discover | ADB only | 无 in-app | P3 架构 |
| dfu/mcu | Tests XML | 05 DFU P3 | 主 App 轻量 |
| bond/unbond | Tests only | CS-4/5 | UI 在 CONNECT ⋮ |

---

## 16. 版本对齐备忘

| 版本 | 功能 | 对照节 | YoWire |
| --- | --- | --- | --- |
| 4.29.1 | SUIT DFU | §7 | P3 |
| 4.29.1 | 第二 CLIENT Tab | §9 | 840vp 替代 |
| 4.25.3 | Filter 排除 OEM | §3 | P1 |
| 4.25.4 | Big Endian Write | §5 | P1 |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `02-用户交互流程/08-竞品逐步流程对照/` |
| 版本 | 深研草稿 v0.1 |
| 行数域 | Scanner · Connection · Macros · DFU · GAP |
