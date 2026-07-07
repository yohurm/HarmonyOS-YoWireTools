# 02-经典 SPP 功能清单

> **状态：深研草稿，未定稿。**  
> **竞品基准**：SimpleBluetoothTerminal（E-SBT 源码级）。  
> **YoWire 增值**：Inquiry 附近发现、UUID 自定义、Connect Sheet、自动重连、SessionLog、命令面板（PRD `03-蓝牙模块PRD.md` §5–§6）。  
> **证据链**：`.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §1 · `22-…` §2 · `17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md`

---

## 1. 范围与 IA

| 项 | 说明 |
| --- | --- |
| 入口 | 蓝牙首页 **经典 SPP**（与 BLE GATT / BLE UART 并列） |
| 竞品 IA | 单 Activity：设备列表 → 终端（2 屏） |
| YoWire IA | L0 工作台 → L1 设备列表（Segmented 已配对/附近）→ Connect Sheet → C 终端 |
| 日志/命令 | **无全局日志中心**；**蓝牙 ⚙·会话与日志** / **命令与面板** |
| 宽屏 | B=设备列表，C=终端 70/30；Inspector 禁止第四栏 |

**设计铁律**：SPP 为字节流，**不做业务分包**；一次 read 回调 = 传输层一段字节（PRD §6.3）。

---

## 2. 功能 ID 总表

### 2.1 设备列表页（B-SPP-*）

| ID | 功能 | SimpleBT（E-SBT） | YoWire 优先级 | YoWire UI/行为 | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-SPP-01** | 冷启动列表 | `initializing...` 空态 | **P0** | 蓝牙状态 Banner + 列表 | §4 | `19` SPP-01 |
| **B-SPP-02** | onResume 自动刷新 | `refresh()` | **P0** | 进入页刷新已配对 | §5.1 | SPP-02 |
| **B-SPP-03** | **已配对非 LE 列表** | `getBondedDevices()` 过滤 LE | **P0** | Segmented「已配对」 | §5.1 | SPP-03 · E-SBT-003 |
| **B-SPP-04** | 空态分支 | 无蓝牙/未开/无权限/无配对 | **P0** | 具体原因文案 | §4 | SPP-04 |
| **B-SPP-05** | ⋮ **Refresh** | 重新拉配对 | **P0** | B 标题栏刷新 | §5.1 | SPP-05 |
| **B-SPP-06** | ⋮ **Bluetooth settings** | 跳转系统蓝牙 | **P0** | 权限/配对引导 | §5.1 | SPP-06 |
| **B-SPP-07** | Android 12+ 权限引导 | Refresh 可见引导 CONNECT | **P0** | HarmonyOS 蓝牙权限对照 | — | SPP-07 |
| **B-SPP-08** | **点击行 → 终端** | 无 Connect Sheet，直进 | **P0** | 路径 A：一点进终端 | §5.1 快捷 | SPP-08 |
| **B-SPP-09** | **附近 Inquiry 发现** | **无** | **P0** YoWire 增值 | Segmented「附近」+ 扫描 ~12s + RSSI | §5.2 | `19` §1.2 · E-SBT-002 |
| **B-SPP-10** | Inquiry 停止/倒计时 | — | **P0** | SCAN/STOP + 倒计时 | §5.2 | PRD §5.2 |
| **B-SPP-11** | 连接前停止发现 | — | **P0** | 自动 stop Inquiry | §5.2 | PRD §5.2 |
| **B-SPP-12** | 排序 | 源码仅名称 sort | **P1** | 收藏优先、最近连接、名称 | §5.1 | PRD |
| **B-SPP-13** | 设备详情 | 无 | **P1** | Sheet：别名、最近连接 | §5.1 | PRD |
| **B-SPP-14** | 收藏过滤 | 无 | **P1** | Filter 或 Segmented | §10 | PRD |

### 2.2 Connect Sheet / 连接配置（B-SPP-C-*）

| ID | 配置项 | SimpleBT | YoWire 优先级 | 默认/行为 | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-SPP-C-01** | 目标设备 | 列表行 address | **P0** | 已配对或 Inquiry 结果 | §6.1 | SPP-09 |
| **B-SPP-C-02** | **SPP UUID** | 硬编码 `00001101-…` | **P0** | 默认标准 Serial Port UUID | §6.1 | SPP-16 · E-SBT-004 |
| **B-SPP-C-03** | **自定义 UUID** | 无 | **P0** YoWire 增值 | 输入/收藏/最近 | §6.1 | `19` §1.8 |
| **B-SPP-C-04** | **Channel 直连** | 无 | **P2** 平台待验证 | 不支持则隐藏 + ⚙ 记录 | §6.1 · §3 | `22` BT-SPP-04 |
| **B-SPP-C-05** | 自动重连 | 无 | **P1** | 遵循全局/单设备 ⚙ | §11 | `19` §1.8 |
| **B-SPP-C-06** | 后台保持 | 仅 detach 通知 | **P0** | 继承 **更多·权限与后台** + 模块覆盖 | §6.1 | SPP-24 · E-SBT-006 |
| **B-SPP-C-07** | 日志保存默认 ON | 无持久化 | **P0** | SessionLog 落盘 | §6.1 | BT-SPP-06 |
| **B-SPP-C-08** | 未配对 → 系统配对 | settings 菜单间接 | **P0** | Connect Sheet 引导配对 | — | BT-SPP-13 |

**Connect Sheet 规格**：≥600vp 居中 Sheet（宽屏 Inspector 常驻）。

### 2.3 连接状态机（B-SPP-S-*）

| ID | 状态 | SimpleBT 显示 | YoWire 优先级 | YoWire 增强 | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-SPP-S-01** | 未连接 | — | **P0** | 可连接 CTA | §6.2 | — |
| **B-SPP-S-02** | 连接中 | `connecting...` status 色 | **P0** | 显示 UUID、耗时 | §6.2 | SPP-15 |
| **B-SPP-S-03** | RFCOMM 建链 | `createRfcommSocketToServiceRecord` | **P0** | 底层 HarmonyOS socket | — | SPP-16 |
| **B-SPP-S-04** | 已连接 | `connected` | **P0** | 时长、收发统计 | §6.2 | SPP-17 |
| **B-SPP-S-05** | 连接失败 | `connection failed: <msg>` | **P0** | 错误码 + 建议 | §6.2 | SPP-18 |
| **B-SPP-S-06** | 读循环 1024B | `onSerialRead` | **P0** | chunk 合并节流 | §6.3 | SPP-19 |
| **B-SPP-S-07** | 连接丢失 | `connection lost` | **P0** | 保留日志 + 重连 | §6.2 | SPP-20 |
| **B-SPP-S-08** | **自动重连中** | 无 | **P1** | 第 N 次、下次时间 | §11 | PRD §11 |
| **B-SPP-S-09** | 已断开 | disconnect 后 | **P0** | 日志保留 | §6.2 | — |

### 2.4 终端页 UI（B-SPP-T-*）

| ID | 功能 | SimpleBT | YoWire 优先级 | YoWire 落点 | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-SPP-T-01** | receive + send 布局 | `fragment_terminal.xml` | **P0** | C 70/30 分区 | §6.3 | UART-18 同构 |
| **B-SPP-T-02** | **Clear** | 仅清 receiveText | **P0** | 不清 SessionLog | §6.3 | SPP-21 |
| **B-SPP-T-03** | **Newline** CR+LF/LF/none | Dialog 单选 | **P0** | 终端 ⋮ | §6.3 | SPP-22 |
| **B-SPP-T-04** | **HEX** 模式 | toggle + HexWatcher | **P0** | 终端 ⋮ | §6.3 | SPP-23 |
| **B-SPP-T-05** | **Background notification** | detach → 前台通知 | **P0** | 终端 ⋮ + 系统通知权限 | — | SPP-24 |
| **B-SPP-T-06** | 文本发送 | str + newline bytes | **P0** | 发送按钮 | §6.3 | SPP-25 |
| **B-SPP-T-07** | HEX 发送 | fromHexString | **P0** | 同左 | §6.3 | SPP-26 |
| **B-SPP-T-08** | 未连接发送 Toast | `not connected` | **P0** | 同左 | — | SPP-27 |
| **B-SPP-T-09** | CRLF 跨 chunk 合并 | pendingNewline | **P0** | 接收区逻辑 | §6.3 | SPP-28 |
| **B-SPP-T-10** | 接收 UI 节流 | queue + mainLooper.post | **P0** | 同 E-SBLE-005 | — | SPP-29 |
| **B-SPP-T-11** | **周期发送** | 无 | **P1** | C 工具栏 + ⚙ 默认 | §6.3 | BT-SPP-09 |
| **B-SPP-T-12** | **命令收藏 Sheet** | 无 | **P1** | 「从收藏选择」 | §6.3 | BT-SPP-10 |
| **B-SPP-T-13** | **会话记录…** | 无 | **P0** | → **蓝牙 ⚙·会话与日志** | §6.3 | `00` §6 |
| **B-SPP-T-14** | 复制选中 | 无 | **P1** | 接收区长按/菜单 | §6.3 | PRD |
| **B-SPP-T-15** | 混合/文本/HEX 接收视图 | 仅文本/HEX toggle | **P1** | 专家视图切换 | §6.3 | PRD |
| **B-SPP-T-16** | UTF-8/ASCII 编码 | 隐含 UTF-8 | **P1** | 终端 ⋮ 或 ⚙ | §6.3 | PRD |

### 2.5 SerialService 后台模型（B-SPP-BG-*）

| ID | 行为 | 源码 | YoWire 优先级 | 映射 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **B-SPP-BG-01** | UI attach drain 双队列 | queue1+queue2 | **P0** | 会话事件回放 | E-SBT-006 |
| **B-SPP-BG-02** | detach → 前台通知 | Connected to + Disconnect 动作 | **P0** | **更多·后台** + 模块覆盖 | SPP-24 |
| **B-SPP-BG-03** | 无 listener 事件入 queue2 | Connect/Read/IoError 缓存 | **P0** | SessionLog 后端 | E-SBT-006 |
| **B-SPP-BG-04** | 通知 Disconnect → socket disconnect | INTENT | **P0** | 同左 | E-SBT-006 |
| **B-SPP-BG-05** | bind + startService 防销毁 | onStart | **P0** | HarmonyOS 后台任务对照 | SPP-11/12 |

### 2.6 导航与生命周期（B-SPP-N-*）

| ID | 行为 | SimpleBT | YoWire 优先级 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **B-SPP-N-01** | retainInstance 防旋转丢态 | true | **P0** | 状态持久化 | SPP-10 |
| **B-SPP-N-02** | onResume auto-connect | 首次 connect() | **P0** | 可 ⚙ 关闭 | SPP-13 |
| **B-SPP-N-03** | 返回上一页 | detach 通知，无 Dialog | **P1** | **保持/断开 Dialog**（PRD 强制） | BT-SPP-11 |
| **B-SPP-N-04** | 虚拟 MAC 文案 | N/A Android | **P0** | 不称物理 MAC | PRD §5.1 |

---

## 3. YoWire PRD 需求 ID 映射

| PRD ID | 摘要 | 本清单 ID | Gap |
| --- | --- | --- | --- |
| BT-SPP-01 | 已配对列表+刷新 | B-SPP-03~05 | P0 |
| BT-SPP-02 | 附近 Inquiry | B-SPP-09~11 | P0 |
| BT-SPP-03 | UUID 自定义 | B-SPP-C-02~03 | P0 |
| BT-SPP-04 | Channel 直连 | B-SPP-C-04 | P2 |
| BT-SPP-05 | 终端 HEX/换行/清屏 | B-SPP-T-02~04 | P0 |
| BT-SPP-06 | SessionLog 原始字节 | B-SPP-T-13, C-07 | P0 |
| BT-SPP-07 | 自动重连 | B-SPP-C-05, S-08 | P1 |
| BT-SPP-08 | 后台+通知 | B-SPP-T-05, BG-* | P0 |
| BT-SPP-09 | 周期发送 | B-SPP-T-11 | P1 |
| BT-SPP-10 | 命令面板 | B-SPP-T-12 | P1 |
| BT-SPP-11 | 返回 Dialog | B-SPP-N-03 | P1 |
| BT-SPP-12 | SPP Server | — | P3 架构预留 |
| BT-SPP-13 | 配对引导 | B-SPP-C-08 | P0 |
| BT-SPP-14 | 840vp B+C | 宽屏 §4 | P1 布局 |

---

## 4. 逐步 UI 流程（源码级）

### 4.1 路径 A：已配对快捷连接

```text
1. 蓝牙 → 经典 SPP → Segmented「已配对」
2. 列表 refresh（onResume / 手动 Refresh）
3. 点击设备行
   ├─ [YoWire] 可选 Connect Sheet（UUID/重连/后台）
   └─ push 终端页
4. Terminal onResume → auto-connect → status: connecting… → connected
5. 收发 / ⋮ Clear·HEX·Newline·通知
6. 返回 → [YoWire] Dialog 保持/断开
```

### 4.2 路径 B：附近 Inquiry（YoWire 独有）

```text
1. Segmented「附近」→ 开始发现（~12s HarmonyOS 文档）
2. 列表 RSSI 更新；显示倒计时
3. STOP 或超时 → 用户选设备
4. stop Inquiry → Connect Sheet → 连接
5. 同路径 A 步骤 4–6
```

**证据**：`19` §1.2 · PRD §5.2

---

## 5. 蓝牙 ⚙ 设置映射

| ⚙ 分组 | SPP 相关项 | 功能 ID |
| --- | --- | --- |
| **经典蓝牙** | 默认 SPP UUID；Inquiry 时长；配对引导 | B-SPP-C-02, B-SPP-09 |
| **连接** | 自动重连次数/间隔；后台保持 | B-SPP-C-05~06, S-08 |
| **会话与日志** | SPP 会话列表；导出 TXT/CSV/JSON | B-SPP-T-13 |
| **命令与面板** | SPP 命令收藏；Panel Grid；周期发送默认 | B-SPP-T-11~12 |
| **收藏与设备** | 别名；默认 UUID | B-SPP-12~14 |

**入口**：`[⚙ 设置]` push BluetoothSettingsPage（禁止更多 Tab 日志中心）。

---

## 6. 840vp 宽屏（摘要）

| 手机 | ≥840vp |
| --- | --- |
| push 终端全屏 | B 设备列表 + C 终端 Detail |
| Connect Sheet | Inspector 常驻 UUID/状态 |
| ⚙ 全屏 push | C 栏 navigate 蓝牙设置 |

**证据**：`.research/feature-inventory/17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md` §2

---

## 7. 竞品缺失 → YoWire 必做清单

| 能力 | SimpleBT | YoWire 必达级别 |
| --- | --- | --- |
| Inquiry 附近发现 | ✗ | P0 |
| UUID 自定义 | ✗ | P0 |
| 自动重连 | ✗ | P1 |
| SessionLog 持久化 | ✗ | P0 |
| 周期发送/命令面板 | ✗ | P1 |
| 返回保持/断开 Dialog | ✗ | P1 |
| SPP Server | ✗ | P3 预留 |

---

## 8. 证据索引

| 键 | 路径 |
| --- | --- |
| E-SBT-19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §1 |
| GAP-22 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` §2 |
| 840-17 | `.research/feature-inventory/17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md` |
| UI-00 | `.research/feature-inventory/00-UI架构修正-模块自治与后端统一.md` |
| 源码 | `.research/reference-apps/SimpleBluetoothTerminal/` |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/03-蓝牙模块PRD.md` §5–§6 |

---

## 10. SPP-01～SPP-29 源码逐步对照（inventory 19 全量）

> **证据**：`.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §1 · 源码路径 `.research/reference-apps/SimpleBluetoothTerminal/`（E-SBT）  
> **列说明**：「源码:行」为 inventory 19 引用的逻辑位置；本地 clone 缺失时以 GitHub [SimpleBluetoothTerminal](https://github.com/kai-morich/SimpleBluetoothTerminal) `master` 为准。

### 10.1 设备列表页（SPP-01～SPP-08）

| SPP-ID | 用户可见 | 源码文件 | 源码:行 / 方法 | YoWire 功能 ID | YoWire 差分 |
| --- | --- | --- | --- | --- | --- |
| **SPP-01** | 冷启动 `initializing...` | `DevicesFragment.java` | `onActivityCreated()` → `setEmptyText` | B-SPP-01 | 同左 + 蓝牙 Banner |
| **SPP-02** | onResume 自动 refresh | `DevicesFragment.java` | `onResume()` → `refresh()` | B-SPP-02 | 同左 |
| **SPP-03** | 已配对非 LE 列表 | `DevicesFragment.java` | `refresh()`：`getBondedDevices()` + `DEVICE_TYPE_LE` 过滤 + sort | B-SPP-03 | HarmonyOS 虚拟 MAC 文案 |
| **SPP-04** | 空态分支文案 | `DevicesFragment.java` | `refresh()` 分支：adapter null / disabled / permission / no paired | B-SPP-04 | 具体原因 Chip |
| **SPP-05** | ⋮ Refresh | `DevicesFragment.java` | `onOptionsItemSelected(R.id.bt_refresh)` | B-SPP-05 | B 标题栏刷新按钮 |
| **SPP-06** | ⋮ Bluetooth settings | `DevicesFragment.java` | `ACTION_BLUETOOTH_SETTINGS` | B-SPP-06 | 配对引导链 |
| **SPP-07** | Android 12+ 权限引导 | `DevicesFragment.java` | `permissionMissing` → Refresh 菜单 visible | B-SPP-07 | HarmonyOS 权限对照 |
| **SPP-08** | 点击行 → 终端 | `DevicesFragment.java` | `onListItemClick()` → `TerminalFragment` + address arg | B-SPP-08 | 可选 Connect Sheet |

### 10.2 终端生命周期（SPP-09～SPP-14）

| SPP-ID | 行为 | 源码文件 | 源码:行 / 方法 | YoWire ID |
| --- | --- | --- | --- | --- |
| **SPP-09** | 读取 device 参数 | `TerminalFragment.java` | `onCreate()` → `getArguments().getString("device")` | B-SPP-C-01 |
| **SPP-10** | retainInstance | `TerminalFragment.java` | `onCreate()` → `setRetainInstance(true)` | B-SPP-N-01 |
| **SPP-11** | bind SerialService | `TerminalFragment.java` | `onAttach()` → `bindService` | B-SPP-BG-01 |
| **SPP-12** | startService 防销毁 | `TerminalFragment.java` | `onStart()` | B-SPP-BG-05 |
| **SPP-13** | onResume auto-connect | `TerminalFragment.java` | `initialStart && service != null` → `connect()` | B-SPP-N-02 |
| **SPP-14** | attach 回放队列 | `SerialService.java` | `attach()` drain queue1+queue2 | B-SPP-BG-01 |

### 10.3 连接状态机（SPP-15～SPP-20）

| SPP-ID | 阶段 | 显示 | 源码文件 | 源码:行 / 方法 | YoWire ID |
| --- | --- | --- | --- | --- | --- |
| **SPP-15** | 连接中 | `connecting...` | `TerminalFragment.java` | `connect()` → `status("connecting...")` | B-SPP-S-02 |
| **SPP-16** | RFCOMM 建链 | — | `SerialSocket.java` | `createRfcommSocketToServiceRecord(BLUETOOTH_SPP)` | B-SPP-S-03 |
| **SPP-17** | 已连接 | `connected` | `TerminalFragment.java` | `onSerialConnect()` | B-SPP-S-04 |
| **SPP-18** | 连接失败 | `connection failed:` | `TerminalFragment.java` | `onSerialConnectError()` | B-SPP-S-05 |
| **SPP-19** | 读循环 | receive 追加 | `SerialSocket.java` | `read(buffer[1024])` → `onSerialRead` | B-SPP-S-06 |
| **SPP-20** | 连接丢失 | `connection lost:` | `TerminalFragment.java` | `onSerialIoError()` | B-SPP-S-07 |

**RFCOMM UUID 常量（SPP-16）**：`SerialSocket.java` — `BLUETOOTH_SPP = "00001101-0000-1000-8000-00805F9B34FB"`（标准 Serial Port Profile UUID，Bluetooth SIG Base UUID）。

### 10.4 终端菜单（SPP-21～SPP-24）

| SPP-ID | 菜单项 | 效果 | 源码文件 | 源码:行 / 方法 | YoWire ID |
| --- | --- | --- | --- | --- | --- |
| **SPP-21** | Clear | 仅清 receiveText | `TerminalFragment.java` | `receiveText.setText("")` | B-SPP-T-02 |
| **SPP-22** | Newline | CR+LF / LF / none Dialog | `TerminalFragment.java` + `arrays.xml` | `AlertDialog.setSingleChoiceItems` | B-SPP-T-03 |
| **SPP-23** | HEX | toggle + HexWatcher | `TerminalFragment.java` | `hexEnabled` + `TextUtil.HexWatcher` | B-SPP-T-04 |
| **SPP-24** | Background notification | detach 前台通知 | `SerialService.java` | `detach()` → `createNotification()` | B-SPP-T-05, BG-02 |

**菜单资源**：`res/menu/menu_terminal.xml` — 项 id：`clear`, `newline`, `hex`, `background_notification`（checkable）。

### 10.5 收发逻辑（SPP-25～SPP-29）

| SPP-ID | 模式 | 行为 | 源码文件 | 源码:行 / 方法 | YoWire ID |
| --- | --- | --- | --- | --- | --- |
| **SPP-25** | 文本发送 | str + newline bytes | `TerminalFragment.java` | `send()` text branch | B-SPP-T-06 |
| **SPP-26** | HEX 发送 | `TextUtil.fromHexString` | `TerminalFragment.java` | `send()` hex branch | B-SPP-T-07 |
| **SPP-27** | 未连接 Toast | `not connected` | `TerminalFragment.java` | `send()` guard | B-SPP-T-08 |
| **SPP-28** | CRLF 跨 chunk | `pendingNewline` | `TerminalFragment.java` | receive append 逻辑 | B-SPP-T-09 |
| **SPP-29** | UI 节流 | queue + mainLooper.post | `SerialService.java` | `onSerialRead()` | B-SPP-T-10 |

---

## 11. YoWire 增值功能详表（竞品无 → PRD 必达）

| YoWire ID | 能力 | SimpleBT | PRD | UI 落点 | 优先级 |
| --- | --- | --- | --- | --- | --- |
| **B-SPP-09** | **Inquiry 附近发现** | ✗ | §5.2 | Segmented「附近」+ SCAN ~12s + RSSI | **P0** |
| **B-SPP-10** | Inquiry 倒计时/STOP | ✗ | §5.2 | B 标题栏 SCAN/STOP + 倒计时 Chip | **P0** |
| **B-SPP-11** | 连接前 stop Inquiry | ✗ | §5.2 | Connect 前自动 stop | **P0** |
| **B-SPP-C-03** | **自定义 SPP UUID** | 硬编码 00001101 | §6.1 | Connect Sheet + ⚙·经典蓝牙 | **P0** |
| **B-SPP-C-05** | **自动重连** | ✗ | §11 | ⚙·连接 + 状态 `S-08` | **P1** |
| **B-SPP-T-11** | **周期发送** | ✗ | §6.3 | C 工具栏 Interval + ⚙ 默认 | **P1** |
| **B-SPP-T-12** | **命令收藏 Sheet** | ✗ | §6.3 | 「从收藏选择」→ ⚙·命令与面板 | **P1** |
| **B-SPP-T-13** | **会话记录…** | ✗ | §6.3 | → ⚙·会话与日志 TXT/CSV/JSON | **P0** |
| **B-SPP-N-03** | **返回保持/断开 Dialog** | detach 无 Dialog | §6.2 | 系统返回 / 导航返回 | **P1** |
| **B-SPP-C-04** | Channel 直连 | ✗ | §6.1 | P2 平台验证后隐藏 | **P2** |

### 11.1 Inquiry 逐步流程（YoWire 独有）

| 步 | 用户动作 | UI | 系统行为 |
| --- | --- | --- | --- |
| Y-SPP-01 | Segmented「附近」 | B 栏切换 | 清空 Inquiry 列表 |
| Y-SPP-02 | 点 SCAN | 倒计时 ~12s | `startDiscovery()` / HarmonyOS 经典发现 API |
| Y-SPP-03 | 设备出现 | 行：名/MAC/RSSI | 列表增量更新 |
| Y-SPP-04 | STOP 或超时 | 扫描停止 | 保留已发现列表 |
| Y-SPP-05 | 选设备 | Connect Sheet | stop Inquiry → UUID/重连/后台 |
| Y-SPP-06 | 连接 | 终端 status 行 | 同 SPP-15~17 |

### 11.2 周期发送与命令面板（YoWire）

| 控件 ID | 行为 | 落点 |
| --- | --- | --- |
| Y-SPP-PER-01 | Interval ms 输入 | C 工具栏 Sheet |
| Y-SPP-PER-02 | Start/Stop 周期 | 同左；Stop 不清 SessionLog |
| Y-SPP-CMD-01 | 命令收藏列表 | ⚙·命令与面板 → SPP 分组 |
| Y-SPP-CMD-02 | Panel Grid 3 列 | 仅设置页编辑；终端 Sheet 选用 |
| Y-SPP-CMD-03 | 一键发送收藏 | 终端「从收藏选择」 |

---

## 12. Web / 开源证据 — SimpleBluetoothTerminal

| 主题 | 证据来源 | 与 SPP-ID 映射 |
| --- | --- | --- |
| **RFCOMM 00001101** | [SimpleBluetoothTerminal SerialSocket.java](https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/serial_bluetooth_terminal/SerialSocket.java) — `BLUETOOTH_SPP` UUID | SPP-16 · B-SPP-C-02 |
| **HEX / Newline / Clear 菜单** | [menu_terminal.xml](https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/res/menu/menu_terminal.xml) + `TerminalFragment.java` | SPP-21~23 · B-SPP-T-02~04 |
| **SerialService 前台** | [SerialService.java](https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/serial_bluetooth_terminal/SerialService.java) — `attach/detach`, notification, queue2 | SPP-24, SPP-29 · B-SPP-BG-* |
| **Play 商店** | [Simple Bluetooth Terminal](https://play.google.com/store/apps/details?id=de.kai_morich.serial_bluetooth_terminal) — 2 屏 IA、RFCOMM 串口 | 竞品基准 |
| **布局** | `fragment_terminal.xml` — receive + send + button | SPP-25~27 · B-SPP-T-01 |
| **换行 arrays** | `res/values/arrays.xml` — `newline_values` CR+LF/LF/none | SPP-22 |

**SerialService 前台通知语义（Web/源码）**：

```text
onAttach(UI)     → drain queue1 + queue2 → TerminalFragment listener
onDetach(UI)     → createNotification("Connected to <name>", Disconnect action)
Disconnect action → INTENT → SerialSocket.disconnect()
无 listener 事件  → queue2 缓存 Connect/Read/IoError → attach 时回放
```

YoWire 映射：**更多·权限与后台** 全局默认 + **蓝牙 ⚙·连接** 模块覆盖（B-SPP-C-06, B-SPP-T-05）。

---

## 13. SPP 功能 ID ↔ SPP 逐步 ID 追溯矩阵

| B-SPP 功能 ID | SPP 逐步 ID | 源码锚点 |
| --- | --- | --- |
| B-SPP-01 | SPP-01 | DevicesFragment.onActivityCreated |
| B-SPP-02 | SPP-02 | DevicesFragment.onResume |
| B-SPP-03 | SPP-03 | DevicesFragment.refresh bonded |
| B-SPP-04 | SPP-04 | DevicesFragment.refresh empty |
| B-SPP-05 | SPP-05 | menu bt_refresh |
| B-SPP-06 | SPP-06 | ACTION_BLUETOOTH_SETTINGS |
| B-SPP-07 | SPP-07 | permissionMissing menu |
| B-SPP-08 | SPP-08 | onListItemClick |
| B-SPP-C-01 | SPP-09 | TerminalFragment device arg |
| B-SPP-S-02~07 | SPP-15~20 | connect/connectError/read/ioError |
| B-SPP-T-02~10 | SPP-21~29 | menu + send + SerialService |
| B-SPP-BG-01~05 | SPP-11~14, 24, 29 | SerialService attach/detach/queue |
| B-SPP-N-01~02 | SPP-10, 13 | retainInstance, auto-connect |
| B-SPP-09~11 | —（YoWire） | PRD §5.2 Inquiry |
| B-SPP-T-11~13 | —（YoWire） | PRD §6.3 命令/会话 |

---

## 14. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：B-SPP-01~N-04 全 ID、双路径流程、PRD/Gap 映射 |
| 2026-07-03 | 深扩：§10 SPP-01~29 源码对照、§11 YoWire 增值、§12 Web 证据、§13 追溯矩阵 |
