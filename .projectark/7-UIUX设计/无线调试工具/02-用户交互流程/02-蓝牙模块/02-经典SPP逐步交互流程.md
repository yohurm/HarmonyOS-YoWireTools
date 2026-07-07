# 02 — 经典 SPP 逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §1、`03-UI设计/02-蓝牙模块/02-经典SPP终端页面设计.md`、`feature-inventory/17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md`  
> **范围**：已配对 / 附近 Inquiry / 收藏 → Connect Sheet → 终端 → 设置导出

---

## 1. 流程总览

```text
蓝牙 Tab → 经典 SPP (L1)
  ├── Segmented [已配对|附近|收藏]
  ├── Inquiry ~12s（附近）
  ├── PairingGuideSheet → ConnectSheet
  ├── SPP 终端：HEX/换行/发送/周期/收藏
  └── ⚙ 会话与日志 / 命令与面板
```

**竞品基线**：SimpleBluetoothTerminal（E-SBT）；YoWire 增 Inquiry、Connect Sheet、模块 ⚙。

---

## 2. 进入经典 SPP 页

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 **蓝牙** Tab | 蓝牙工作台 L0 | `TabItem_bluetooth` |
| 步2 | 点 **经典 SPP** 入口或 A 栏子 Nav | navigate `bluetooth/classic-spp` | `NavItem_classicSpp` |
| 步3 | — | 顶栏 **经典 SPP** | `TitleBar` |
| 步4 | Segmented 默认 **已配对** | 刷新配对列表 | `SegmentedControl_sppTabs` |
| 步5 | 蓝牙关/无权限 | CapabilityBanner + 空态 | `CapabilityBanner_bt` |

### 2.1 顶栏

```text
[← 返回]  经典 SPP                  [扫描/停止] [Filter] [⚙ 设置]
```

| Segmented | 扫描按钮文案 | Filter |
| --- | --- | --- |
| 已配对 | **刷新** | 名称/MAC + RSSI |
| 附近 | **扫描/停止** Inquiry | 同左 |
| 收藏 | **刷新收藏** | 仅名称搜索 |

---

## 3. Segmented：已配对 / 附近 / 收藏

### 3.1 已配对 Tab

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 进入 **已配对** | `getPairedDevices()` 非 LE；排序 | `SegmentedTab_paired` |
| 步2 | — | 列表填充 SppDeviceRow | `SppDeviceList` |
| 步3 | 列表空 | `no paired devices` / 蓝牙关 / 无权限 | `EmptyState_paired` |
| 步4 | 点 **刷新** | 重新拉取配对列表 | `btnScanToggle` |
| 步5 | 点 **已配对且非 LE** 行 | 已连→终端；未连→ConnectSheet | `SppDeviceRow` |
| 步6 | 点 **CONNECT** | 打开 ConnectSheet | `btnConnect` |

### 3.2 附近 Tab — Inquiry 流程

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| INQ-1 | 切 **附近** Segmented | 检查蓝牙/权限 | `SegmentedTab_nearby` |
| INQ-2 | 点 **扫描/停止** ON | 启动 Inquiry ~12s（默认） | `btnScanToggle` |
| INQ-3 | — | 空态 `<inquiring…>`；列表清空 | `EmptyState_inquiring` |
| INQ-4 | 发现设备 | SppDeviceRow：名/MAC/RSSI；去重插入 | `SppDeviceRow` |
| INQ-5 | 计时结束 | 自动 stop；按钮恢复 **扫描** | `InquiryTimer` |
| INQ-6 | 点 **停止** | 立即停止 Inquiry | `btnScanToggle` |
| INQ-7 | 点 **未配对** 行 | 弹出 PairingGuideSheet | `SppDeviceRow` |
| INQ-8 | 配对成功 | Toast → 自动 ConnectSheet | `PairingGuideSheet` |
| INQ-9 | 配对失败 | Error Banner + 重试 / 系统蓝牙设置 | `PairingErrorBanner` |

**Inquiry 时长**：蓝牙 ⚙ → 连接 → 经典蓝牙 → **Inquiry 时长** Slider 5–30s。

### 3.3 收藏 Tab

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 切 **收藏** | 收藏设备优先排序 | `SegmentedTab_favorites` |
| 步2 | 空 | 「暂无收藏 · 在设备详情中收藏」 | `EmptyState_favorites` |
| 步3 | 点收藏行 | 同已配对/附近连接逻辑 | `SppDeviceRow_favorite` |
| 步4 | 点行尾 **星标** | 取消/添加收藏 | `btnFavoriteStar` |

---

## 4. Filter Sheet（SPP）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 **Filter** | SppFilterSheet 升起 | `btnFilter` |
| 步2 | 输入名称/MAC | 部分匹配 | `filterNameMac` |
| 步3 | 调整 RSSI（附近 Tab） | Slider | `filterRssiMin` |
| 步4 | 点 **应用** | 列表过滤 | `btnFilterApply` |
| 步5 | 点 **清除** | 恢复全量 | `btnFilterClear` |

---

## 5. PairingGuideSheet

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 未配对设备点行 | PairingGuideSheet 升起 | `PairingGuideSheet` |
| 步2 | 阅读配对说明 | 显示 PIN/确认步骤 | `pairingInstructions` |
| 步3 | 点 **开始配对** | 调起系统配对 UI | `btnStartPairing` |
| 步4 | 用户完成系统配对 | Toast 成功 → ConnectSheet | 系统 Dialog |
| 步5 | 点 **取消** | Sheet dismiss | `btnPairingCancel` |
| 步6 | 点 **打开系统蓝牙设置** | ACTION_BLUETOOTH_SETTINGS | `btnSystemBtSettings` |

---

## 6. Connect Sheet — UUID 与连接

### 6.1 Sheet 布局控件

```text
ConnectSheet — 连接 SPP
TargetSummary · UuidPickerField · ConnectionOptions
[取消]  [连接]
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| CS-1 | Sheet 打开 | TargetSummary：设备名·MAC·配对状态 | `ConnectSheet` |
| CS-2 | 选 **标准 SPP** | UUID `00001101-0000-1000-8000-00805F9B34FB` | `radioUuidStandard` |
| CS-3 | 选 **收藏 UUID** | 下拉收藏列表 | `pickerFavoriteUuid` |
| CS-4 | 专家：选 **手动输入** | TextField 格式校验 | `fieldManualUuid` |
| CS-5 | 调整 **超时** Slider | 5–60s 显示 | `sliderConnectTimeout` |
| CS-6 | 勾选 **自动重连** | 次数/间隔见设置 | `switchAutoReconnect` |
| CS-7 | 勾选 **安全连接** | 平台支持时 | `switchSecureConnection` |
| CS-8 | 点 **连接** Primary | Sheet 关闭；进入终端连接态 | `btnConnectConfirm` |
| CS-9 | 点 **取消** | Sheet dismiss | `btnConnectCancel` |

**宽屏 ≥600vp**：ConnectSheet → 居中 **480×560vp**。

### 6.2 RFCOMM 连接阶段（终端 status 行）

| 步 | 阶段 | 终端显示 | 控件名 |
| --- | --- | --- | --- |
| CS-10 | 开始 | `connecting…`（status 色） | `DataTerminal_status` |
| CS-11 | 成功 | `connected` | `ConnectionChip_connected` |
| CS-12 | 失败 | `connection failed: {msg}` | `DataTerminal_status` |
| CS-13 | 断连 | `connection lost: {msg}` | `DataTerminal_status` |

---

## 7. SPP 终端页 — 布局

### 7.1 手机全屏终端

```text
[← 返回]  {设备名}  {连接 Chip}              [⋮]
ContextStrip：HEX | 换行 CR+LF | 收发计数
DataTerminal (~70%)
CommandDock (~30%)：sendInput · [HEX][发送][从收藏选择]
FoldLogBar
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | Connect 成功 | push `classic-spp/terminal/{deviceId}` 或 C 栏终端 | `SppTerminalPage` |
| 步2 | onResume 首次 | **auto-connect**（若从 deep link 恢复） | `SppAutoConnect` |
| 步3 | 服务 bind 成功 | `service.attach` 回放队列 | `SerialService` |
| 步4 | — | ContextStrip 显示 HEX/换行/计数 | `ContextStrip` |

### 7.2 顶栏 ⋮ 菜单

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 **⋮** | 弹出 TerminalMenu | `btnTerminalMenu` |
| 步2 | **Clear** | 仅清空 UI receiveText | `menuClear` |
| 步3 | **Newline** | AlertDialog：CR+LF / LF / none | `menuNewline` |
| 步4 | **HEX** | checkable toggle | `menuHex` |
| 步5 | **Background notification** | detach 时前台通知 | `menuBgNotification` |
| 步6 | **周期发送** | IntervalSheet | `menuPeriodicSend` |
| 步7 | **会话记录…** | deep link 蓝牙 ⚙·会话与日志 | `menuSessionLog` |
| 步8 | **断开** | disconnect RFCOMM | `menuDisconnect` |

---

## 8. 终端操作 — HEX / 换行 / 发送

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| T-1 | ⋮ → **HEX** ON | sendInput hint `HEX mode`；收发 HEX | `menuHex` |
| T-2 | ⋮ → **Newline** 选 CR+LF | 发送追加 `\r\n` | `NewlineDialog` |
| T-3 | ⋮ → **Clear** | 清 UI；**不**清 SessionLog 文件 | `menuClear` |
| T-4 | ContextStrip 点 **HEX** Chip | 与 ⋮ 同步 | `chipHexMode` |
| T-5 | 输入文本点 **发送** | `(str+newline).getBytes()`；tx 着色 append | `sendInput` / `btnSend` |
| T-6 | HEX 模式非法字符 | Toast 校验错误 | `sendInput` |
| T-7 | 未连接点发送 | Toast `not connected` | `btnSend` |
| T-8 | 接收 CRLF | 跨 chunk 合并 `\r\n` | `DataTerminal` |
| T-9 | 多 chunk 接收 | 合并后一次刷新 UI | `SerialService` |

---

## 9. 周期发送

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| T-10 | ⋮ → **周期发送** | IntervalSheet 打开 | `menuPeriodicSend` |
| T-11 | 设间隔 ms、次数上限 | Stepper | `periodicIntervalStepper` |
| T-12 | 点 **开启** | C 工具栏 Chip 动画；全局 **停止周期发送** 可见 | `btnPeriodicStart` |
| T-13 | 点 **停止周期发送** | 立即停止 | `chipPeriodicStop` |
| T-14 | 首次启用超最小间隔 | RiskConfirmDialog | `PeriodicRiskDialog` |

默认间隔：**蓝牙 ⚙ → 命令与面板 → 周期发送默认**。

---

## 10. 从收藏选择

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| T-15 | 点 **从收藏选择** | FavoritePickerSheet（SPP 协议） | `btnFavoritePicker` |
| T-16 | 搜索 | 过滤 AT 命令等 | `favoriteSearchField` |
| T-17 | 点一条 | 载入 sendInput 或直接发送 | `FavoriteListItem` |
| T-18 | **管理收藏…** | push 蓝牙 ⚙ → 命令与面板 → SPP Tab | `btnManageFavorites` |

---

## 11. 后台与 SerialService

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| BG-1 | 终端页 pop（选保持连接） | UI detach；SerialService 前台 | `KeepConnectionDialog` |
| BG-2 | detach | 通知「Connected to {name}」+ Disconnect 动作 | `ForegroundNotification` |
| BG-3 | 通知点 **Disconnect** | INTENT → SerialSocket disconnect | `notifActionDisconnect` |
| BG-4 | 再次进入终端 | attach + drain 队列回放 | `SerialService.attach` |
| BG-5 | Android 13+ 无 POST_NOTIFICATIONS | 引导授权 | `CapabilityBanner_notification` |

**设置**：蓝牙 ⚙ → 高级 → 后台；继承 **更多 → 权限与后台**。

---

## 12. 会话导出 — 设置路径

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| EX-1 | 终端 ⋮ → **会话记录…** | push 蓝牙 ⚙；定位 SPP 当前 session | `menuSessionLog` |
| EX-2 | 会话与日志 Tab | SessionList 过滤 spp | `SessionLogTab` |
| EX-3 | 点 SessionRow | SessionDetailPage | `SessionRow` |
| EX-4 | Tab **文本/HEX** | LogViewer 方向分色 | `LogViewer` |
| EX-5 | **导出** | ExportDialog：TXT/CSV/JSON + 脱敏 | `btnExportSession` |
| EX-6 | **开始导出** | 进度条 → 分享/保存 | `btnExportStart` |
| EX-7 | 批量多选 **导出** | 合并或 ZIP（设置） | `btnBatchExport` |

---

## 13. Deep Link 恢复 SPP 会话

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 工作台点 SPP 最近会话卡片 | URI `yowire://bluetooth/spp/session/{id}` | `RecentSessionCard_spp` |
| 步2 | — | 切换蓝牙 Tab → SPP → 终端 | `DeepLinkHandler` |
| 步3 | — | 加载 SessionLog 历史（只读） | `SessionRestoreService` |
| 步4 | Banner **重新连接** | 打开 ConnectSheet 同 MAC | `btnReconnectBanner` |

---

## 14. 840vp 三分栏分支

| 场景 | A 栏 | B 栏 | C 栏 |
| --- | --- | --- | --- |
| 设备列表 | 蓝牙● + SPP 子 Nav | Segmented + SppDeviceRow | 空态或 Inspector 摘要 |
| ConnectSheet | — | 选中行高亮 | 居中 Sheet 或 C 内嵌 |
| 已连接终端 | — | 活跃 Session 列表 | DataTerminal + CommandDock |
| ⚙ 设置 | — | B 保持 | C navigate 蓝牙设置 |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| W-1 | 点 B 栏已连接 Session | C 栏切换终端上下文 | `SessionSidebarItem` |
| W-2 | C 栏终端 | 无全屏 push；B 列表常驻 | `SplitLayout_spp` |
| W-3 | Connect 进行中 | C 显示 ConnectionProgress + status | `ConnectionProgressBar` |

---

## 15. 返回栈与 Dialog

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 终端连接中按 **←** | KeepConnectionDialog | `KeepConnectionDialog` |
| 步2 | 设备列表 L1 按返回 | pop 至蓝牙工作台 L0 | `btnNavBack` |
| 步3 | ConnectSheet 打开时按返回 | 先 dismiss Sheet | `ConnectSheet` |

---

## 16. 验收检查清单

- [ ] Segmented 已配对/附近/收藏三路径  
- [ ] Inquiry ~12s + PairingGuideSheet  
- [ ] ConnectSheet UUID 标准/收藏/手动（专家）  
- [ ] 终端 HEX/Newline/Clear/发送/周期/收藏  
- [ ] 会话记录 deep link ⚙ 导出三格式  
- [ ] 后台通知 + KeepConnectionDialog  
- [ ] 840vp B 列表 + C 终端  

---

## 17. 错误态与恢复流程

| 步 | 触发条件 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- | --- |
| ERR-1 | 蓝牙适配器 null | — | 空态 + 「蓝牙不可用」 | `EmptyState_noAdapter` |
| ERR-2 | 蓝牙未开启 | 点 Banner **去开启** | ACTION_BLUETOOTH_SETTINGS | `CapabilityBanner_btOff` |
| ERR-3 | 无 BLUETOOTH_CONNECT | 点刷新 | 引导权限 Dialog | `PermissionDialog_connect` |
| ERR-4 | RFCOMM 连接被拒 | — | status `connection failed: Connection refused` | `DataTerminal_status` |
| ERR-5 | 连接被拒后 | 点 **重试** | 重新 ConnectSheet | `btnRetryConnect` |
| ERR-6 | UUID 不匹配 | — | `connection failed: Service not found` | `ConnectErrorBanner` |
| ERR-7 | UUID 错误 | 专家选手动 UUID | ConnectSheet 重新连接 | `fieldManualUuid` |
| ERR-8 | 自动重连中 | — | status `reconnecting… (n/3)` | `chipAutoReconnect` |
| ERR-9 | 自动重连失败 | Toast | 「已停止自动重连 · 查看设置」 | `Toast_reconnectFailed` |

---

## 18. 收藏设备管理（设置联动）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| FAV-1 | 设备行长按 → **收藏** | 写入收藏表 | `ApContextMenu_favorite` |
| FAV-2 | 收藏 Tab 显示 | 星标 + 优先排序 | `SegmentedTab_favorites` |
| FAV-3 | ⚙ → 连接 → **收藏设备管理** | 列表别名/MAC | `NavRow_favoriteDevices` |
| FAV-4 | 编辑别名 | 列表与 ConnectSheet 同步显示 | `FavoriteDeviceEditor` |
| FAV-5 | 取消收藏 | 从收藏 Tab 移除 | `btnRemoveFavorite` |

---

*经典 SPP 逐步交互流程；BLE UART 见 `03-BLE-UART逐步交互流程.md`。*
