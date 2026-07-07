# 星闪模块 · SSAP Client 逐步交互流程

> **状态**：深研草稿，未定稿  
> **类型**：用户交互流程（逐步）  
> **依据**：`.research/feature-inventory/20-星闪模块-功能清单与逐步流程-v2.md` §4.1–§4.2 · `18-HarmonyOS-840vp-星闪模块三分栏线框-v2.md` §2 · `03-UI设计/04-星闪模块/02-SSAP-Client页面设计.md`  
> **对应功能 ID**：N-NL-02～N-NL-05、N-NL-07、N-NL-11  
> **前置**：`01-能力检测与权限引导流程.md` 终态 **Ready** 或 **Degraded（含 SSAP）**  
> **表头**：步 | 用户动作 | 系统响应 | 控件名

---

## 1. 流程索引

| 阶段 | 步骤 ID | 简述 |
| --- | --- | --- |
| 扫描 | NL-01～NL-06 | 首页 → 扫描 → 筛选 → 选设备 |
| SSAP 连接 | **NL-A1～NL-A5** | 创建 Client → 连接 → MTU → 发现服务 → Ready |
| SSAP 操作 | **NL-A6～NL-A8** | Read / Write / Subscribe |
| 结束 | **NL-A9** | 断开与重连 |

---

## 2. 扫描阶段（NL-01～NL-06）

### NL-01 · 进入星闪首页

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NL-01-1 | 能力 Ready 后进星闪 L0 | CapabilityBanner 可折叠；Segmented 默认 SSAP Client | `NearlinkScanPage` |
| NL-01-2 | 工作台 deep link | 预选设备或切 Tab | `DeepLinkHandler` |
| NL-01-3 | — | 顶栏 `[扫描/停止] [Filter] [⚙]` | `NearlinkTitleBar` |
| NL-01-4 | 宽屏 ≥840vp | B 列表 + C Empty「选择设备」 | `SplitLayout_nearlink` |
| NL-01-5 | Degraded 无 Scan | Banner 说明；列表不刷新 | `CapabilityBanner_degraded` |

### NL-02 · 开始扫描

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NL-02-1 | 点 **扫描** | 二次校验权限+开关+支持 | `btnScanToggle` |
| NL-02-2 | 校验通过 | `startScan`；按钮文案 **停止** | `btnScanToggle` |
| NL-02-3 | 校验失败 | 回退 `01-能力检测` Banner 路径 | `CapabilityBanner_*` |
| NL-02-4 | 已有连接 | Dialog「新连接将断开当前会话」 | `SingleConnectionDialog` |
| NL-02-5 | Dialog 确认 | 先 NL-A9 断开再扫描 | `btnDisconnectAndScan` |

### NL-03 · 扫描中

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NL-03-1 | 浏览列表 | 实时更新：名称、随机地址、RSSI、发现次数 | `NearlinkDeviceRow` |
| NL-03-2 | RSSI 127 | Caption「无信号」 | `rowRssiCaption` |
| NL-03-3 | 点 **停止** | `stopScan`；按钮恢复 **扫描** | `btnScanToggle` |
| NL-03-4 | 列表空 | Empty「未发现设备 · 继续扫描或调整 Filter」 | `EmptyState_scan` |
| NL-03-5 | — | 事件写 SessionLog `scan_*` | `SessionLogService` |

### NL-04 · 筛选（专家）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NL-04-1 | 点 **Filter** | 升起 FilterSheet | `btnFilter` |
| NL-04-2 | 轻量：设备名搜索 | 部分匹配 | `filterDeviceName` |
| NL-04-3 | 专家：地址 + OR/AND 组 | 复合条件 | `filterAddressAdvanced` |
| NL-04-4 | 点 **Apply** | 列表过滤；Chip 高亮 | `btnFilterApply` |
| NL-04-5 | 空条件 Apply | Toast「未生效任何过滤」 | `btnFilterApply` |
| NL-04-6 | **Reset** | 清除条件 | `btnFilterReset` |
| NL-04-7 | ≥600vp | 居中 480×560 Sheet | `FilterSheet` |

### NL-05 · 点选设备行

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NL-05-1 | 点设备行 | **stopScan**（若扫描中） | `NearlinkDeviceRow` |
| NL-05-2 | — | B 行高亮；进入 **NL-A1** | `NearlinkDeviceRow_selected` |
| NL-05-3 | 手机 | push L1 连接阶段条 | `NavPathStack` |
| NL-05-4 | 宽屏 | C 栏 NL-A1～A5 阶段条 | `ConnectionStageBar` |
| NL-05-5 | 已连接其他设备 | Dialog 单连接互斥 | `SingleConnectionDialog` |

### NL-06 · 广播详情（可选）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| NL-06-1 | 行长按 / ⋮ **广播详情** | Sheet：HEX、Local Name、Service Data | `btnAdvDetail` |
| NL-06-2 | Copy HEX | 剪贴板 | `btnCopyAdvHex` |
| NL-06-3 | 宽屏 | B 行展开或 C 顶 Sheet | `AdvDetailSheet` |

---

## 3. SSAP 连接阶段（NL-A1～NL-A5）

> 阶段条 4 步不可跳过；期间返回 → Dialog「断开并返回？」

### NL-A1 · 选择 SSAP 连接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A1-1 | 详情页点 **SSAP 连接** 或宽屏点行 | 阶段条第 1 步「连接中…」 | `btnSsapConnect` |
| A1-2 | — | `ssap.createClient(address)` | `SsapClientManager` |
| A1-3 | 重复 create | 连接管理器拦截；Toast | `SsapClientManager` |
| A1-4 | 失败 | Error 卡 + **重试**；Log `createClient_failed` | `ConnectErrorCard` |
| A1-5 | 点 **重试** | 从 A1-2 重试 | `btnRetryConnect` |
| A1-6 | Segmented 为 DT 时切 SSAP | 互斥 Dialog（若 DT 已连） | `SsapDtMutexDialog` |

### NL-A2 · 正在连接

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A2-1 | 等待 | 阶段条第 2 步「正在连接」 | `ConnectionStageBar` |
| A2-2 | — | `client.connect()` | `SsapClient` |
| A2-3 | 成功 | 进入 A3 | `ConnectionStageBar` |
| A2-4 | 超时 | Error 卡；**重试** / **返回列表** | `ConnectErrorCard` |
| A2-5 | 返回键 | Dialog「断开并返回？」 | `DisconnectOnBackDialog` |
| A2-6 | 宽屏 | C 全宽阶段条；B 选中保持 | `ConnectionStageBar` |

### NL-A3 · 请求 MTU

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A3-1 | 等待 | 阶段条第 3 步「请求 MTU…」 | `ConnectionStageBar` |
| A3-2 | — | `requestMtuSize` [22,512] 默认 256 | `SsapClient` |
| A3-3 | 成功 | MTU Chip 更新；Log 协商值 | `chipMtu` |
| A3-4 | 失败 | 保留默认 256 + Warning Log；**不阻断** A4 | `chipMtu` |
| A3-5 | 专家：C 工具栏再请求 MTU | 可选手动 `requestMtu` | `btnRequestMtu` |

### NL-A4 · 发现服务

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A4-1 | 等待 | 阶段条第 4 步「发现服务…」 | `ConnectionStageBar` |
| A4-2 | — | `getServices()` | `SsapClient` |
| A4-3 | 空服务 | Empty + **刷新服务** | `EmptyState_noServices` |
| A4-4 | 点 **刷新服务** | 重跑 A4 | `btnRefreshServices` |
| A4-5 | 成功 | 构建 SSAP 服务树 | `SsapServiceTree` |

### NL-A5 · Ready（服务树可操作）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A5-1 | — | 阶段条完成「就绪」→ 收起 | `ConnectionStageBar` |
| A5-2 | — | SSAP 树 + Log pane 显示 | `SsapServiceTree` / `SsapLogPane` |
| A5-3 | — | 连接状态条：设备名·MTU·加密态·时长 | `ConnectionStatusBar` |
| A5-4 | 840vp | 树 ~60% + Log ~40% | `SplitLayout_ssap` |
| A5-5 | 窄 C | Tab **树\|Log** | `Tab_ssapTreeLog` |
| A5-6 | C 工具栏 | Parse UUIDs、MTU、Reliable Write、Subscribe 全部、Disconnect（≤6） | `SsapToolbar` |
| A5-7 | 加密 Chip | 已加密/未加密/未知 | `chipEncryption` |

---

## 4. SSAP 属性操作（NL-A6～NL-A8）

### NL-A6 · Read Property

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A6-1 | 点 Property **Read** 图标 | 节点 Loading | `btnPropertyRead` |
| A6-2 | — | `readProperty` 执行 | `SsapClient` |
| A6-3 | 成功 | 节点展开/Sheet 展示 Text 或 HEX | `PropertyValueSheet` |
| A6-4 | — | Log：时间、Read、UUID、Payload HEX、成功 Chip | `SsapLogPane` |
| A6-5 | 点 Log 行 Payload | PayloadViewer 完整 HEX | `LogEntryRow` |
| A6-6 | 失败 | Log Error Chip；节点恢复 | `SsapLogPane` |
| A6-7 | Parse UUIDs ON | 显示 SIG 名 | `switchParseUuids` |

### NL-A7 · Write Property

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A7-1 | 点 Property **Write** 图标 | 打开 Write Sheet | `btnPropertyWrite` |
| A7-2 | 输入 Payload Text/HEX | 字节计数；超 MTU-开销 Warning | `writePayloadField` |
| A7-3 | **存入命令面板** | 预填 ⚙·SSAP Write 收藏 | `btnSaveToCommandPanel` |
| A7-4 | **从收藏选择** | FavoritePicker SSAP 类型 | `btnFavoritePicker` |
| A7-5 | 点 **写入** | 高风险 UUID/超长 → **Dialog 二次确认** | `btnWriteConfirm` |
| A7-6 | Dialog **确认写入** | `writeProperty` | `WriteConfirmDialog` |
| A7-7 | 成功 | Log Write 方向 + 结果 | `SsapLogPane` |
| A7-8 | 失败 | Error Chip；Sheet 保留 Payload | `SsapLogPane` |
| A7-9 | 取消 | 关闭 Sheet；草稿可保留（折叠接续） | `btnSheetCancel` |
| A7-10 | ≥600vp | Write Sheet 居中 480×560 | `WritePropertySheet` |

### NL-A8 · Subscribe（Notify）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A8-1 | Subscribe Toggle **开** | `setPropertyNotification(true)` | `toggleSubscribe` |
| A8-2 | — | Log「已订阅」 | `SsapLogPane` |
| A8-3 | 设备 Notify | `propertyChange` → Log 流追加 | `SsapLogPane` |
| A8-4 | Toggle **关** | `setPropertyNotification(false)` | `toggleSubscribe` |
| A8-5 | 专家 **Subscribe 全部** | 批量订阅；进度 Toast | `btnSubscribeAll` |
| A8-6 | 批量部分失败 | Toast 成功/失败计数 | `btnSubscribeAll` |
| A8-7 | 断开连接 | 自动取消全部订阅 | `SsapClient` |

---

## 5. 断开与结束（NL-A9）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| A9-1 | C 工具栏 **Disconnect** | 敏感操作进行中 → 确认 Dialog | `btnDisconnect` |
| A9-2 | — | `disconnect` / `close` | `SsapClient` |
| A9-3 | — | 树只读；**Log pane 保留**全部历史 | `SsapServiceTree` |
| A9-4 | Log 顶栏 **SAVE** | 跳转 ⚙·会话与日志·导出 SSAP 会话 | `btnLogSave` |
| A9-5 | 点同设备 **重连** | 从 **NL-A1** 重新开始 | `btnReconnect` |
| A9-6 | 选 B 列表其他设备 | Dialog「断开当前并连接新设备？」 | `SingleConnectionDialog` |
| A9-7 | Segmented 切 dataTransfer | 互斥 Dialog → A9-2 后进入 NL-B1 | `SegmentedControl_ssapDt` |
| A9-8 | Tab 切换离开 | 连接保持（后台策略） | `TabBar` |

---

## 6. 宽屏逐步（≥840vp · W-*）

| 步 | 用户动作 | B 栏 | C 栏 | 控件名 |
| --- | --- | --- | --- | --- |
| W-1 | A 栏选星闪 | Ready 摘要 | Empty | `SideNavItem_nearlink` |
| W-2 | Filter Apply | 列表过滤 | — | `btnFilterApply` |
| W-3 | 点设备行 | stopScan + 高亮 | NL-A1～A5 | `NearlinkDeviceRow` |
| W-4 | A5 Ready | 高亮保持 | 树 60% + Log 40% | `SplitLayout_ssap` |
| W-5 | A7 高风险 Write | — | Sheet + Dialog | `WritePropertySheet` |
| W-6 | ⚙ 模块设置 | — | navigate 设置 | `btnModuleSettings` |
| W-7 | 切 dataTransfer | 保留选中 | 互斥 Dialog | `SegmentedControl_ssapDt` |

---

## 7. 加密交叉（NL-C1～C5 摘要）

| 步 | 时机 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| C-1 | A5 Ready | 加密 Chip：已加密/未加密/未知 | `chipEncryption` |
| C-2 | 未加密 | 风险提示 Banner | `EncryptionWarningBanner` |
| C-3 | 需加密 | ⚙·连接策略 或 **配对引导** | `btnPairingGuide` |
| C-4 | `startPairing` | Log 记录配对过程 | `SsapLogPane` |
| C-5 | 状态变化 | Chip 更新 + Log | `chipEncryption` |

---

## 8. 异常与空态

| 步 | 场景 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| X-1 | 连接中断 | C 顶 Error 卡 + **重连** → NL-A1 | `ConnectErrorCard` |
| X-2 | MTU 失败 | 继续 A4；Chip 256 | `chipMtu` |
| X-3 | Write 失败 | Log Error；Sheet 保留 | `SsapLogPane` |
| X-4 | 扫描中点连接 | 自动 stopScan | `btnScanToggle` |
| X-5 | Degraded 无 SSAP | Segmented 置灰 | `SegmentedTab_ssap` |

---

## 9. 验收要点（P0）

- [ ] NL-05 stopScan 后再 NL-A1
- [ ] NL-A1～A5 阶段条完整；失败可重试
- [ ] NL-A7 高风险必须 Dialog
- [ ] NL-A9 断开后 Log 保留且可导出
- [ ] 840vp B 扫描 + C 树+Log，无第四栏
- [ ] 折叠接续：选中设备、树展开、Log scroll、Write 草稿

---

## 10. 相关文档

| 文档 | 路径 |
| --- | --- |
| 能力检测 | `01-能力检测与权限引导流程.md` |
| dataTransfer | `03-dataTransfer逐步交互流程.md` |
| 星闪设置 | `04-星闪模块设置流程.md` |
| UI 设计 | `../../03-UI设计/04-星闪模块/02-SSAP-Client页面设计.md` |
| 会话导出 | `../06-统一后端/01-会话日志导出逐步交互流程.md` |

---

## 11. Reliable Write 交叉（NL-A7 扩展 · 专家）

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| RW-1 | C 工具栏 **Reliable Write** ON | 下次 Write 走 RW 事务 | `switchReliableWrite` |
| RW-2 | Write Sheet 确认 | begin → write → execute | `WritePropertySheet` |
| RW-3 | 中途取消 | abort；Log 记录回滚 | `btnRwAbort` |
| RW-4 | 返回键 pop | ⚙ autoAbort ON 则 abort | `reliableWriteAutoAbortSwitch` |

---

## 12. Parse UUIDs 与专家工具栏

| 步 | 用户动作 | 系统响应 | 控件名 |
| --- | --- | --- | --- |
| PU-1 | Toggle **Parse UUIDs** ON | 树节点显示 SIG 名称 | `switchParseUuids` |
| PU-2 | 未知 UUID | 显示短 UUID + 复制 | `SsapTreeNode` |
| PU-3 | 专家 **放大** C | 树+Log 全屏 | `btnExpandC` |

---

## 13. 折叠屏接续（SSAP 专项）

| 步 | 接续项 | 控件名 |
| --- | --- | --- |
| FC-1 | Filter 条件草稿 | `FilterSheet` |
| FC-2 | 树展开 Service/Property | `SsapServiceTree` |
| FC-3 | Write Sheet Payload | `writePayloadField` |
| FC-4 | Subscribe Toggle 状态 | `toggleSubscribe` |
| FC-5 | Log scroll offset | `SsapLogPane` |

---

## 14. NL-A1～A9 一步一表索引（验收用）

| ID | 子步数 | 关键控件 | P0 验收 |
| --- | --- | --- | --- |
| NL-A1 | A1-1～A1-6 | `btnSsapConnect` | createClient 重试 |
| NL-A2 | A2-1～A2-6 | `ConnectionStageBar` | 超时 Error |
| NL-A3 | A3-1～A3-5 | `chipMtu` | 失败不阻断 A4 |
| NL-A4 | A4-1～A4-5 | `SsapServiceTree` | 空服务刷新 |
| NL-A5 | A5-1～A5-7 | `SsapToolbar` | 树+Log 可见 |
| NL-A6 | A6-1～A6-7 | `btnPropertyRead` | Log 方向 Read |
| NL-A7 | A7-1～A7-10 | `WritePropertySheet` | 高风险 Dialog |
| NL-A8 | A8-1～A8-7 | `toggleSubscribe` | Notify 流 |
| NL-A9 | A9-1～A9-8 | `btnDisconnect` | Log 保留 |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `02-用户交互流程/04-星闪模块/` |
| 版本 | 深研草稿 v1.1 |

