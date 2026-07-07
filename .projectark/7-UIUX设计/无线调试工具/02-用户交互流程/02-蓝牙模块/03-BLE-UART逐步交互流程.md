# 03 — BLE UART 逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §2、`03-UI设计/02-蓝牙模块/03-BLE-UART串口页面设计.md`  
> **范围**：SCAN → Profile 四阶段 → 终端 / 失败 → GATT 重定向

---

## 1. 流程总览

```text
蓝牙 Tab → BLE UART (L1)
  ├── SCAN/STOP ~10s
  ├── FilterSheet
  ├── 点行 → stopScan → UartConnectionStagePage（四步）
  ├── 成功 → 终端（同 SPP 同构 + MTU/Profile Chip）
  └── 失败 → UartErrorCard → 「改用 GATT 调试」
```

**边界**：UART **不**提供 Reliable Write / SERVER Tab；无 Profile 时必须引导 GATT。

---

## 2. 进入 BLE UART 页

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 蓝牙 Tab → **BLE 串口** 入口 | navigate `bluetooth/ble-uart` | `NavItem_bleUart` |
| 步2 | — | 顶栏 **BLE 串口** | `TitleBar` |
| 步3 | onResume | 按设置可选自动 SCAN | `BleUartScanPage` |
| 步4 | 定位权限缺失 (API 23–30) | CapabilityBanner + 申请 | `CapabilityBanner_location` |
| 步5 | 定位服务关闭 | fallback Discovery 提示或引导 | `Banner_locationService` |

### 2.1 顶栏

```text
[← 返回]  BLE 串口                    [SCAN/STOP] [Filter] [⚙ 设置]
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步6 | 点 **SCAN** | 启动 ~10s LE 扫描 | `btnScanToggle` |
| 步7 | 点 **STOP** | 立即停止 | `btnScanToggle` |
| 步8 | 点 **Filter** | BleUartFilterSheet | `btnFilter` |
| 步9 | 点 **⚙** | push 蓝牙设置（UART Profile 分组） | `btnModuleSettings` |

---

## 3. SCAN 流程 — 逐步

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| U-1 | 点 **SCAN** | SCAN 隐藏 STOP 显示 | `btnScanToggle` |
| U-2 | — | 空态 `<scanning…>`；列表清空 | `EmptyState_scanning` |
| U-3 | — | `startScan(leScanCallback)` | `BleScanner` |
| U-4 | 10s 到 | 可选 Toast；自动 stopScan | `ScanTimer_10s` |
| U-5 | 扫描结果 | BleUartDeviceRow 去重插入 | `BleUartDeviceRow` |
| U-6 | 点 **STOP** | `scanner.stopScan` | `btnScanToggle` |
| U-7 | **点击设备行** | **第一动作 stopScan**（P0） | `BleUartDeviceRow` |
| U-8 | stop 后 | push UartConnectionStagePage 或 C 栏阶段 UI | `UartConnectionStagePage` |

### 3.1 列表行字段

| 字段 | 控件 | 说明 |
| --- | --- | --- |
| 名称 | `rowTitle` | 空则 `<unnamed>` |
| MAC | `rowSubtitle` | 脱敏 |
| RSSI | `rssiBar` | 实时 |
| Profile 指示 | `chipProfileHint` | P2 广播启发式 |
| 收藏 | `btnFavoriteStar` | — |

### 3.2 Filter Sheet

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| F-1 | 点 Filter | Sheet 升起 | `BleUartFilterSheet` |
| F-2 | 名称/MAC | 部分匹配 | `filterNameMac` |
| F-3 | RSSI Slider | ≥ 阈值 | `filterRssiMin` |
| F-4 | 仅收藏 Switch | 列表过滤 | `filterOnlyFavorites` |
| F-5 | **应用** | 关闭 Sheet | `btnFilterApply` |

---

## 4. 连接阶段条 — 四步 Profile

### 4.1 阶段 UI 模板

```text
UartStageBar — 连接 {设备名}
● 步骤 1/4  连接 GATT …
○ 步骤 2/4  发现服务 …
○ 步骤 3/4  匹配 Profile …
○ 步骤 4/4  MTU 协商 + 开启 Notify …
[取消]
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| ST-0 | 进入阶段页 | 四步 Stepper 初始化 | `UartStageBar` |
| ST-1 | — | 步骤1 **连接 GATT…** 进行中 | `stepIndicator_1` |
| ST-2 | GATT 连接成功 | 步骤1 完成；步骤2 进行中 | `stepIndicator_2` |
| ST-3 | discoverServices 完成 | 步骤2 完成；步骤3 进行中 | `stepIndicator_3` |
| ST-4 | Profile 匹配成功 | 显示 Profile 名 Chip | `chipMatchedProfile` |
| ST-5 | MTU + CCCD 完成 | 步骤4 完成 → `connected` | `stepIndicator_4` |
| ST-6 | 点 **取消** | abort 连接；返回列表 | `btnStageCancel` |

### 4.2 各阶段底层与失败文案

| 阶段 | 文案 | 失败 | 控件名 |
| --- | --- | --- | --- |
| 1 | 连接 GATT … | `connection failed` | `UartStage_step1` |
| 2 | 发现服务 … | 超时 | `UartStage_step2` |
| 3 | 匹配 Profile … | `no serial profile found` | `UartStage_step3` |
| 4 | MTU + Notify … | CCCD 失败 | `UartStage_step4` |

### 4.3 Profile UUID 对照（步骤 3 UI 展示）

| Profile 名 | Service UUID | 步骤 3 显示 |
| --- | --- | --- |
| Nordic UART | `6e400001-…` | `Nordic UART` |
| TI CC254x | `0000ffe0-…` | `CC254x` |
| Microchip | `49535343-FE7D-…` | `Microchip` |
| Telit Bluemod | `0000FEFB-…` | `Telit` |

**默认顺序**：蓝牙 ⚙ → 连接 → **BLE UART 默认 Profile**（首期 Nordic 优先）。

---

## 5. 配对请求子流程

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PR-1 | 步骤1 收到配对请求 | 阶段区/status：`pairing request` | `PairingStatusText` |
| PR-2 | — | 升起 **PairingSheet** | `PairingSheet` |
| PR-3 | 用户完成系统配对 | 继续步骤2 | 系统 UI |
| PR-4 | 用户拒绝 | Error 卡；可取消或重试 | `PairingErrorCard` |

**宽屏 ≥600vp**：PairingSheet → 居中面板。

---

## 6. MTU 展示与协商

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| MTU-1 | 步骤4 开始 | `request max MTU`（max 512） | `MtuNegotiator` |
| MTU-2 | 协商完成 | C 顶栏 **MTU Chip** 显示 ATT MTU | `chipMtu` |
| MTU-3 | — | ContextStrip：`payload = mtu - 3`（内部） | `ContextStrip` |
| MTU-4 | 发送大包 | write 队列按 payloadSize 分包 | `WriteQueue` |
| MTU-5 | 专家：点 MTU Chip | Request MTU Dialog 23–517 | `MtuRequestDialog` |
| MTU-6 | 设置 **Auto request maximum MTU** ON | 步骤4 自动 max | `autoMaxMtuSwitch` |

---

## 7. 失败 → GATT 重定向

| 步 | 条件 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- | --- |
| F-1 | 步骤3 无 Profile | — | **UartErrorCard** 标题：`未找到串口 Profile` | `UartErrorCard` |
| F-2 | — | 阅读正文 | 列出已发现 Service UUID 摘要 | `errorServiceList` |
| F-3 | — | 点 **改用 GATT 调试** Primary | navigate `ble-gatt` + 预选 MAC | `btnSwitchToGatt` |
| F-4 | — | 点 **重新扫描** Secondary | 回 B 列表；SCAN | `btnRescan` |
| F-5 | 超时/配对拒 | 同 F-3 按钮组 | — | `UartErrorCard` |
| F-6 | 宽屏 | B 栏保持选中 | C 栏 Error | `SplitLayout_error` |

### 7.1 GATT 预选行为

| 步 | 系统响应 | 控件名 |
| --- | --- | --- |
| 步1 | 切换 A/B 子 Nav 至 **BLE GATT**（840vp Segmented） | `NavItem_bleGatt` |
| 步2 | 扫描列表预选 MAC 高亮 | `BleDeviceRow_selected` |
| 步3 | 可选 Banner「来自 UART 失败 · 可手动 CONNECT」 | `Banner_fromUartFail` |

---

## 8. 终端态 — 与 SPP 同构

连接成功（ST-4 → `connected`）后进入终端布局。

### 8.1 布局控件

```text
[← 返回]  {设备名}  {连接 Chip}  {MTU Chip}     [⋮]
ContextStrip：Profile Chip | MTU | HEX | 换行 | 收发计数
DataTerminal + CommandDock + FoldLogBar
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 阶段4 完成 | C 栏切换终端布局 | `UartTerminalPage` |
| 步2 | — | **Profile Chip** 只读（如 Nordic UART） | `chipProfile` |
| 步3 | — | **MTU Chip** 可点按详情 | `chipMtu` |
| 步4 | auto-connect 同 SPP | SerialService attach | `SerialService` |

### 8.2 C 工具栏（≤6）

| # | 控件 | 行为 |
| --- | --- | --- |
| 1 | HEX/ASCII | toggle |
| 2 | 换行模式 | Dialog |
| 3 | 清屏 | UI only |
| 4 | 从收藏选择 | UART 命令 Tab |
| 5 | 周期发送 | IntervalSheet |
| 6 | 断开 | disconnect GATT UART |

### 8.3 ⋮ 菜单（同 SPP）

| 步 | 菜单项 | 控件名 |
| --- | --- | --- |
| 步1 | Clear / Newline / HEX / Background notification | 同 `02-经典SPP` |
| 步2 | 周期发送 / 会话记录… / 断开 | `menuPeriodicSend` 等 |

**改 Profile**：必须 B 栏重新 SCAN；终端内 **不提供** Profile 切换。

---

## 9. 发送 / 接收（UART 特有）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| TX-1 | 文本发送 | `(str+newline).getBytes()` 按 MTU 分包 | `btnSend` |
| TX-2 | HEX 发送 | fromHexString + 队列 | `sendInput` |
| TX-3 | write 队列 | 按 `payloadSize=mtu-3` 顺序写 | `WriteBuffer` |
| RX-1 | Notify 数据 | 追加 DataTerminal；节流合并 | `DataTerminal` |
| RX-2 | Telit Credits 流控 | 内部流控；UI 可选 Credits 指示（P2） | `CreditsIndicator` |

---

## 10. 840vp 三分栏分支

| 场景 | B 栏 | C 栏 |
| --- | --- | --- |
| 扫描 | BleUartDeviceRow | 空态说明 |
| 连接阶段 | 选中行高亮 | UartStageBar 全高 |
| 终端 | 活跃 UART Session | DataTerminal + CommandDock |
| 失败 Error | 选中设备 | UartErrorCard + GATT 按钮 |
| A 栏 Segmented | BLE GATT \| BLE UART | 失败一键切 GATT |

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| W-1 | A 栏 **BLE UART** | B 扫描列表 | `SideNavItem_bleUart` |
| W-2 | 点 B 行 | C 阶段条或终端 | `BleUartDeviceRow` |
| W-3 | 失败点 **改用 GATT** | A 栏切 GATT；B 同 MAC | `btnSwitchToGatt` |

---

## 11. 返回与 KeepConnectionDialog

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 阶段条进行中按返回 | ConfirmDialog：取消连接？ | `StageCancelDialog` |
| 步2 | 终端已连接按返回 | KeepConnectionDialog | `KeepConnectionDialog` |
| 步3 | 保持连接 | pop 列表；GATT UART 后台 | `btnKeepConnection` |

---

## 12. Deep Link 与工作台

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 工作台 UART 最近会话 | `yowire://bluetooth/uart/session/{id}` | `RecentSessionCard_uart` |
| 步2 | — | 切换 BLE UART → 终端 + 历史 | `DeepLinkHandler` |
| 步3 | 设备未连接 | Banner 重新 SCAN | `btnReconnectBanner` |

---

## 13. 与 GATT 页差异对照

| 项 | BLE UART | BLE GATT |
| --- | --- | --- |
| 扫描周期 | ~10s 单次 | 持续直到停止 |
| 连接 UI | 四步阶段条 | 直接 ConnectionPage |
| 成功后 | 终端 only | GATT 树 + Log |
| 失败 | → GATT 按钮 | Error Banner |
| stopScan | 点行第一动作 | CONNECT 前 |

---

## 14. 验收检查清单

- [ ] SCAN/STOP ~10s；点行先 stopScan  
- [ ] 四步阶段条 + Profile 名展示  
- [ ] MTU Chip + Auto max MTU  
- [ ] 无 Profile → UartErrorCard → 改用 GATT  
- [ ] 终端同 SPP：HEX/换行/周期/收藏  
- [ ] 840vp B 列表 + C 阶段/终端  
- [ ] KeepConnectionDialog  

---

## 15. 权限与 Capability 分支

| 步 | 条件 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- | --- |
| CAP-1 | API 23–30 无定位 | 点 SCAN | AlertDialog 解释 → 申请 ACCESS_FINE_LOCATION | `LocationPermissionDialog` |
| CAP-2 | 用户拒绝定位 | — | Banner「需要定位权限才能 LE 扫描」 | `CapabilityBanner_location` |
| CAP-3 | 定位服务关闭 | — | fallback Discovery 提示或引导开启 | `Banner_locationServiceOff` |
| CAP-4 | 蓝牙未开 | 点 Banner | 系统蓝牙设置 | `CapabilityBanner_btOff` |
| CAP-5 | 权限通过 | 点 SCAN | 正常 U-2 流程 | `btnScanToggle` |

---

## 16. Telit Credits 流控（P2 专家）

| 步 | 系统行为 | UI | 控件名 |
| --- | --- | --- | --- |
| TEL-1 | Profile 匹配 Telit | 步骤3 显示 `Telit` | `chipMatchedProfile` |
| TEL-2 | Credits 异步 CCCD 多步 | 阶段条子步骤文案更新 | `UartStage_step4` |
| TEL-3 | Credits 不足 | Error 卡「流控 credits 不足」 | `UartErrorCard` |
| TEL-4 | 专家 ContextStrip | 可选 Credits 计数 | `CreditsIndicator` |

---

## 17. 与经典 SPP 终端差异对照表

| 控件/行为 | 经典 SPP | BLE UART |
| --- | --- | --- |
| 连接前 | ConnectSheet UUID | stopScan + 四步阶段条 |
| 顶栏 Chip | 连接状态 | 连接 + **MTU** |
| ContextStrip | HEX/换行/计数 | + **Profile Chip** |
| 失败路径 | 重试 Connect | **改用 GATT 调试** |
| 分包 | RFCOMM 1024B read | MTU-3 write 队列 |
| 设置 Tab | 经典蓝牙 UUID | UART Profile + MTU |

---

## 18. 扫描自动启动设置联动

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| AS-1 | ⚙ → 扫描 → **UART 页自动 SCAN** ON | 进入页 onResume 自动 SCAN | `switchUartAutoScan` |
| AS-2 | 自动 SCAN + 权限缺失 | 不启动；Banner 引导 | `CapabilityBanner_location` |
| AS-3 | 自动 SCAN + 10s 结束 | 列表保留；可手动 STOP 再 SCAN | `ScanTimer_10s` |

---

*BLE UART 逐步交互流程；模块设置见 `04-模块设置与会话命令流程.md`。*
