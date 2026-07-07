# 01 — BLE GATT 逐步交互流程

> **状态：深研草稿（未定稿）**  
> **版本**：v0.1 · 2026-07-03  
> **依据**：`feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md`、`feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md`、`03-UI设计/02-蓝牙模块/01-BLE-GATT调试页面设计.md`、`03-UI设计/02-蓝牙模块/04-BLE实验室与高级能力.md`  
> **范围**：Scanner Filter → CONNECT → GATT 树 → Log → Macros 执行；含手机与宽屏分支

---

## 1. 流程总览

```text
蓝牙 Tab → BLE GATT (L1)
  ├── Segmented [附近|已绑定]
  ├── FilterSheet（五维 + 专家第六维）
  ├── BleDeviceRow → CONNECT / ⋮ / 广播详情
  ├── ConnectionPage：CLIENT | SERVER | Log
  ├── WriteCharacteristicSheet / Reliable Write
  └── MacrosRuntimeSheet（28 操作子集）
```

**P0 约束**：连接前 **必须 stopScan**；无全局日志中心；840vp 仅 A/B/C 三分栏。

---

## 2. 进入 BLE GATT 页

### 2.1 路由与入口

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 **蓝牙** Tab | 显示蓝牙工作台 L0 | `TabItem_bluetooth` |
| 步2 | 点入口卡 **BLE GATT 调试** 或 A 栏子 Nav | push / 切换至 `bluetooth/ble-gatt` | `NavItem_bleGatt` |
| 步3 | — | 顶栏显示标题 **BLE GATT** | `TitleBar` |
| 步4 | — | Segmented 默认 **附近**；按设置可自动扫描 | `SegmentedControl_scannerBonded` |
| 步5 | 权限/蓝牙未开 | 显示 **CapabilityBanner** | `CapabilityBanner_ble` |

### 2.2 顶栏控件

```text
[← 返回]  BLE GATT                    [扫描/停止] [Filter] [⚙ 设置]
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步6 | 点 **扫描/停止** Toggle ON | 启动 BLE 扫描；按钮文案 **停止** | `btnScanToggle` |
| 步7 | 点 **扫描/停止** Toggle OFF | stopScan；按钮文案 **扫描** | `btnScanToggle` |
| 步8 | 点 **Filter** | 升起 FilterSheet | `btnFilter` |
| 步9 | 点 **⚙ 设置** | push `BluetoothSettingsPage` | `btnModuleSettings` |

---

## 3. Segmented：附近 / 已绑定

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 Segmented **附近** | 检查权限 → 启动扫描（若允许） | `SegmentedTab_nearby` |
| 步2 | 点 Segmented **已绑定** | 停止扫描（若在扫）→ 刷新 bond 列表 | `SegmentedTab_bonded` |
| 步3 | 已绑定列表空 | 空态：「无已绑定设备 · 在附近 Tab 连接并 Bond」 | `EmptyState_bonded` |
| 步4 | 附近无结果 + Filter 激活 | 「无匹配设备 · 检查 Filter」+ **清除 Filter** | `EmptyState_filtered` |
| 步5 | 连接成功后返回 | 对应 Segmented 保持；选中设备高亮 | `BleDeviceRow_selected` |

**宽屏 ≥840vp**：Segmented 在 **B 栏标题下**；切换行为同手机。

---

## 4. Filter 五维 — 逐步流程

### 4.1 打开与应用

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点顶栏 **Filter** | FilterSheet 升起（手机 Bottom Medium） | `FilterSheet` |
| 步2 | 输入 **名称或地址** | 部分匹配实时预览条数 | `filterNameOrAddress` |
| 步3 | 输入 **广播数据** HEX | 匹配 AD payload 子串 | `filterAdvHex` |
| 步4 | 调整 **RSSI 阈值** | Slider + 数值；仅显示 RSSI ≥ 值 | `filterRssiMin` |
| 步5 | 勾选 **排除设备类型** | Apple/Microsoft/Google/Samsung/Mesh/Beacon/ENS | `filterExcludeTypes` |
| 步6 | 切换 **仅收藏** | 列表仅收藏 MAC | `filterOnlyFavorites` |
| 步7 | 专家模式：展开 **Manufacturer Data Mask** | 第六维 Mask 字段 | `filterMfgDataMask` |
| 步8 | 点 **应用** Primary | Sheet 关闭；列表过滤；顶栏 Filter Chip 高亮 | `btnFilterApply` |
| 步9 | 点 **清除** X | 五维恢复默认；Chip 消失 | `btnFilterClear` |
| 步10 | 专家：点 **存为预设** | 命名 Dialog → 蓝牙设置·扫描·Filter 预设 | `btnSaveFilterPreset` |

### 4.2 Filter 与扫描关系

| 步 | 系统行为 | 控件名 |
| --- | --- | --- |
| 步11 | Filter **不**重启底层扫描；客户端过滤 | `BleScanFilterEngine` |
| 步12 | 被排除类型可选删除线样式或完全隐藏（设置内） | `BleDeviceRow_excluded` |

**宽屏 ≥600vp**：FilterSheet → **居中 480×560vp** 面板。

---

## 5. 设备列表行（BleDeviceRow）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | — | 行显示：名称、MAC、RSSI 条、CONNECT、⋮ | `BleDeviceRow` |
| 步2 | 设备名空 | 主标题 `<未命名>` | `rowTitle` |
| 步3 | Oreo+ 非 connectable | **CONNECT** 隐藏或置灰 | `btnConnect` |
| 步4 | 点行（非 CONNECT） | 展开 AD / push 广播详情页 | `BleDeviceRow_body` |
| 步5 | 长按行 | 进入多选模式 | `SelectionModeBar` |
| 步6 | 多选 ≥2 | 顶栏 **Assign name** / **Export avg advertising** / **TIMELINE** | `btnBulkAssignName` |

---

## 6. CONNECT 与 CONNECT ⋮

### 6.1 直接连接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 **CONNECT** | **stopScan** → 行内 Button loading | `btnConnect` |
| 步2 | — | 显示 ConnectionProgressBar | `ConnectionProgressBar` |
| 步3 | 连接成功 | push ConnectionPage；Auto discover（默认 ON） | `ConnectionPage` |
| 步4 | 失败 30s 超时 | Error Banner：「连接超时 · 重试 / 查看 Log」 | `ConnectErrorBanner` |
| 步5 | 点 **重试** | 再次 stopScan + connect | `btnRetryConnect` |

### 6.2 CONNECT ⋮ 子菜单

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点 CONNECT 旁 **⋮** | 升起 ConnectOptionsSheet | `btnConnectOverflow` |
| 步2 | 勾选 **autoConnect** | 后台重连模式连接 | `switchAutoConnect` |
| 步3 | 选 **preferred PHY** | LE 1M / 2M / Coded（O+） | `radioPreferredPhy` |
| 步4 | 点 **Bond** | 系统配对 UI | `listItemBond` |
| 步5 | 点 **Remove bond** | ConfirmDialog → 清除 bond | `listItemRemoveBond` |
| 步6 | 点 **连接**（Sheet 内） | 应用选项后执行 C-1 流程 | `btnConnectConfirm` |

**宽屏**：ConnectOptionsSheet → 居中 **400×480vp**。

---

## 7. 广播详情（未连接）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点设备行 | push DeviceAdvDetailPage 或 BottomSheet | `DeviceAdvDetailPage` |
| 步2 | 点 **蓝色标题** 解析字段 | ParserPicker：Int/Float/Temperature 等 | `ParserPicker` |
| 步3 | 点 **RAW** | RawAdvDialog：HEX 按 AD 记录拆分 | `btnRawAdv` |
| 步4 | 点 **MORE** | NavDestination 包历史：RSSI、间隔 | `btnAdvMore` |
| 步5 | 解析器已选 | MORE 内 **数值曲线 Tab** | `Tab_advChart` |
| 步6 | 点 **CLONE**（P2） | ConfirmDialog → 跳转 BLE 实验室 Advertiser | `btnCloneAdv` |
| 步7 | 广播含 URL | **OPEN** → 系统浏览器 | `btnOpenPhysicalWeb` |

**宽屏 ≥840vp**：点 B 栏行 → **C 栏** 加载详情；B 行高亮。

---

## 8. Connection 页 — 进入与 Tab

### 8.1 顶栏与 Tab 结构

```text
[← 断开]  {设备名}  {连接 Chip}  {MTU Chip}     [⋮]
Tab:  CLIENT  |  SERVER  |  Log
```

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 连接成功进入 | 顶栏显示设备名、MTU Chip | `ConnectionTitleBar` |
| 步2 | Auto discover ON | 自动 GATT discover；进度指示 | `DiscoverProgressIndicator` |
| 步3 | 点 Tab **CLIENT** | 显示 GATT 树 | `Tab_client` |
| 步4 | 点 Tab **SERVER** | 本机 GATT Server 镜像 | `Tab_server` |
| 步5 | 点 Tab **Log** 或右滑 | Log pane 滑入 | `Tab_log` / `LogPane` |
| 步6 | 手机点右下 **红 FAB** | 打开 MacrosRuntimeSheet | `fabMacros` |
| 步7 | 点 **MTU Chip** | Request MTU Dialog 23–517 | `chipMtu` |
| 步8 | 点 **← 断开** | 断开 GATT；RW 进行中可 Auto Abort | `btnDisconnect` |

### 8.2 宽屏 Connection 布局

| 步 | 布局 | 控件名 |
| --- | --- | --- |
| 步9 | B 栏：设备摘要 + 快捷操作 | `ConnectionSidebar` |
| 步10 | C 栏：CLIENT 树 + Log pane 分 pane | `GattTreePane` / `LogPane` |
| 步11 | Macros 入口在 C 工具栏 **Macros** 按钮（非 FAB） | `btnMacrosToolbar` |

---

## 9. CLIENT Tab — GATT 树操作

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 展开 **Service** 节点 | 显示 UUID；Known UUID 友好名 | `TreeNode_service` |
| 步2 | 展开 **Characteristic** | 属性图标：Read/Write/Notify/Indicate/Reliable | `TreeNode_characteristic` |
| 步3 | 点 **Read** 图标 | 值更新行内 + Log 事件 | `btnCharRead` |
| 步4 | 点 **Write** 图标 | 打开 WriteCharacteristicSheet | `btnCharWrite` |
| 步5 | 点 **Notify/Indicate** | Toggle；CCCD 写入；Log 持续 | `btnCharNotify` |
| 步6 | 展开 **Descriptor** | Read/Write descriptor | `TreeNode_descriptor` |
| 步7 | 长按 Characteristic | ContextMenu：复制 UUID / 复制值 / 加入命令收藏 | `CharContextMenu` |
| 步8 | ⋮ → **Parse known UUIDs OFF** | Write/Read 变纯 HEX Dialog | `menuParseUuidOff` |

### 9.1 WriteCharacteristicSheet

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | Sheet 打开 | 显示解析字段或 HEX | `WriteCharacteristicSheet` |
| 步2 | 编辑 `writeValueHex` | HEX 校验 | `writeValueHex` |
| 步3 | 选 `writeType` | Write Request / Write Command | `radioWriteType` |
| 步4 | 专家：切换 **Big Endian** | Switch | `switchBigEndian` |
| 步5 | 点 **发送** | 写入 + Log | `btnWriteSend` |
| 步6 | 点 **取消** | Sheet dismiss | `btnWriteCancel` |

---

## 10. Reliable Write — 逐步流程

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | ⋮ → **Reliable Write → Begin** | C 顶栏 **RW 进行中** 状态条 | `menuRwBegin` |
| 步2 | 对多个 Char 点 **Write** | 每步 Prepare + verify | `btnCharWrite` |
| 步3 | ⋮ → **Execute** | 提交 Reliable Write | `menuRwExecute` |
| 步4 | ⋮ → **Abort** | 回滚 | `menuRwAbort` |
| 步5 | 新连接且设置 Abort ON | 自动 Abort 未完成 RW | `reliableWriteAutoAbortSwitch` |

---

## 11. Log Pane — 逐步流程

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 右滑 CLIENT 或点 Tab **Log** | 时间戳事件流 | `LogPane` |
| 步2 | — | 事件：connect/discover/read/write/notify… | `LogEntryRow` |
| 步3 | 点 **SAVE** | 单文件导出；可选跳转会话与日志 | `btnLogSave` |
| 步4 | 完整多会话 | 蓝牙 ⚙ → 会话与日志 → ble_gatt | `NavRow_gattSessions` |
| 步5 | 点 Log 行 | 展开 payload HEX/文本 | `LogEntryRow_expand` |

---

## 12. Connection ⋮ 菜单（14 项摘要）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 点顶栏 **⋮** | 弹出 ConnectionMenu | `btnConnectionMenu` |
| 步2 | **Refresh services** | 重新 discover | `menuRefreshServices` |
| 步3 | **Request MTU** | MTU Dialog | `menuRequestMtu` |
| 步4 | **Read PHY** / **Set preferred PHY** | 专家 | `menuReadPhy` |
| 步5 | **Parse known UUIDs** | Toggle | `menuParseUuids` |
| 步6 | **Reliable Write** 子菜单 | Begin/Execute/Abort | `submenuReliableWrite` |
| 步7 | **Export log** | ExportFlow | `menuExportLog` |
| 步8 | **Disconnect** | 断开并返回列表 | `menuDisconnect` |

---

## 13. Macros 运行时 — 逐步流程

> 依据 `feature-inventory/11`；YoWire 映射 GATT C 栏 **Macros** + Sheet。

### 13.1 打开与加载

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| M-1 | 已连接 · 点 **Macros** FAB/工具栏 | MacrosRuntimeSheet 升起 | `fabMacros` / `btnMacros` |
| M-2 | 展开 **Tutorial** 文件夹 | 3 个示例宏 | `MacroFolder_tutorial` |
| M-3 | 点宏行 | 行展开 operation 列表（灰点） | `MacroListItem` |
| M-4 | 服务不匹配 | 宏行上方 Banner 错误文案 | `MacroCompatBanner` |
| M-5 | 加载成功 | 每 operation **灰点** 待执行 | `MacroOpIndicator_pending` |

### 13.2 执行控制条

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| M-6 | 点 **Step Over** | 执行下一 op；成功→**蓝点**；失败→**红点**；assert 不符→**橙三角** | `btnMacroStepOver` |
| M-7 | 点 **Skip operation** | 跳过下一 op | `btnMacroSkip` |
| M-8 | 点 **Run macro** | 顺序执行全部 | `btnMacroRun` |
| M-9 | 点 **Loop** | 循环执行；图标变蓝 | `btnMacroLoop` |
| M-10 | — | Log pane 每步详情、assert 差异 | `LogPane` |

### 13.3 Client 操作语义（12 种 — 执行一步时 UI）

| Tag | 一步执行 UI/Log | 失败指示 |
| --- | --- | --- |
| read | Log Read + 值；树更新 | 红点 |
| write | 自动提交 Write | 红点 |
| begin-reliable-write | RW 状态条 | 红点 |
| execute-reliable-write | Execute Log | 红点 |
| wait-for-notification | 阻塞至 notify | 超时红点；值不符橙三角 |
| sleep | 纯等待 | — |
| request-mtu | Log MTU | 红点 |
| set-preferred-phy | PHY 变更 Log | 红点 |

（Server 9 种 + Other 7 种见 `11-nRF-Connect-Macros`；编辑在 ⚙→命令与面板→Macro 步骤。）

### 13.4 导入/导出 XML（专家）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| M-11 | Sheet 菜单 **导入 XML** | Storage 选择；名称唯一校验 | `menuMacroImport` |
| M-12 | **导出 XML** | 分享文件 | `menuMacroExport` |

**运行时 Sheet 只读执行**；XML 编辑仅在蓝牙 ⚙。

---

## 14. RSSI 图与 TIMELINE（P1/P2）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | 列表菜单 **Show RSSI graph** | 全屏/半屏 RSSI 曲线 | `menuRssiGraph` |
| 步2 | 长按多选设备 | 图上区分曲线 | `BleDeviceRow_multiSelect` |
| 步3 | 菜单 **Export** | CSV / EXCEL | `menuRssiExport` |
| 步4 | ≥2 设备 → **TIMELINE** | 多设备广播历史对比 | `btnTimeline` |

---

## 15. 返回与 KeepConnectionDialog

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| 步1 | Connection 页按 **←** 或系统返回 | 弹出 KeepConnectionDialog | `KeepConnectionDialog` |
| 步2 | **保持连接** | pop 至扫描列表；连接后台继续 | `btnKeepConnection` |
| 步3 | **断开并返回** | disconnect → pop | `btnDisconnectAndBack` |
| 步4 | Reliable Write 中返回 | 可选 Auto Abort | `reliableWriteAutoAbortSwitch` |

---

## 16. 840vp 三分栏分支汇总

| 场景 | B 栏 | C 栏 | 差异控件 |
| --- | --- | --- | --- |
| 扫描列表 | BleDeviceRow 列表 | 广播详情 / 空态引导 | 点行 C 加载详情 |
| 已连接 | 设备摘要 | GATT 树 + Log pane | 无 FAB，用工具栏 |
| Filter | B 标题栏 Filter | — | 居中 Sheet 480×560 |
| Macros | — | Macros Sheet 居中 | 同手机语义 |
| ⚙ 设置 | B 保持 | C navigate 设置 | A/B 不隐藏 |

---

## 17. 验收检查清单

- [ ] 连接前 stopScan  
- [ ] Filter 五维 + 专家 Mfg Mask  
- [ ] CONNECT ⋮：autoConnect / PHY / Bond  
- [ ] CLIENT Read/Write/Notify + Reliable Write  
- [ ] Log pane SAVE + ⚙ 会话导出  
- [ ] Macros Step Over / Run / Loop + 灰蓝红橙指示  
- [ ] 宽屏 B 列表 + C 树；无第四 Inspector  
- [ ] KeepConnectionDialog  

---

*BLE GATT 逐步交互流程；设置与命令编辑见 `04-模块设置与会话命令流程.md`。*
