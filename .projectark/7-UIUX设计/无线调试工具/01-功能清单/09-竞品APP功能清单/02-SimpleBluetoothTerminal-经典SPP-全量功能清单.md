# 02-SimpleBluetoothTerminal — 经典 SPP 全量功能清单

> **状态**：深研草稿，未定稿  
> **竞品**：kai-morich / [SimpleBluetoothTerminal](https://github.com/kai-morich/SimpleBluetoothTerminal)（开源简化版）  
> **Play 完整版**：`de.kai_morich.serial_bluetooth_terminal`（含宏、HEX 增强、捐赠 IAP）  
> **YoWire 映射目标**：`01-功能清单/02-蓝牙模块/02-经典SPP功能清单.md`  
> **证据链**：`.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §1 · `07-联网调研证据/01-竞品版本基线与公开证据索引.md` E-SBT-*  
> **核验日期**：2026-07-03（GitHub `master` 源码 + Play Store 2026-06-09 更新说明）

---

## 1. 应用元数据（SBT-META-*）

| ID | 属性 | 值 | 证据 |
| --- | --- | --- | --- |
| **SBT-META-01** | 应用名（开源） | Simple Bluetooth Terminal | E-SBT-001 · https://github.com/kai-morich/SimpleBluetoothTerminal |
| **SBT-META-02** | 包名（开源） | `de.kai_morich.simple_bluetooth_terminal` | GitHub README · `AndroidManifest.xml` |
| **SBT-META-03** | 包名（Play 完整版） | `de.kai_morich.serial_bluetooth_terminal` | E-SBT-005 · https://play.google.com/store/apps/details?id=de.kai_morich.serial_bluetooth_terminal |
| **SBT-META-04** | 许可 | MIT（开源仓库） | E-SBT-001 |
| **SBT-META-05** | 最低 Android（Play 1.50+） | Android 5.0（API 21） | E-SBT-005 · Play 变更说明 2025-11-06 |
| **SBT-META-06** | Play 最近更新 | 2026-06-09（v1.52） | E-SBT-005 |
| **SBT-META-07** | 下载量级 | 1M+ | E-SBT-005 |
| **SBT-META-08** | 开发者 | Kai Morich（德国 Hockenheim） | Play Store 开发者信息 |
| **SBT-META-09** | 数据收集声明 | No data collected / No data shared | E-SBT-005 · Play Data safety |
| **SBT-META-10** | 开源 vs Play 关系 | Play 页链接两个简化 GitHub 仓库；完整版 **无** 公开源码 | E-SBT-005 · README 段落 |
| **SBT-META-11** | 支持协议（Play 描述） | Bluetooth Classic SPP；HC-05/06、Raspberry Pi 3 等 | E-SBT-005 |
| **SBT-META-12** | IAP | 仅「Donate」捐赠；核心功能免费 | E-SBT-005 |

### 1.1 Play 完整版相对开源版的增量能力（E-SBT-005）

| ID | 能力 | Play 证据 | 开源仓库 |
| --- | --- | --- | --- |
| **SBT-META-P01** | **Macros 宏命令** | v1.51+「macros w/o newline」「hex macros with delay」 | **无** |
| **SBT-META-P02** | HEX 宏延迟发送 | v1.51 2026-05-01 | **无** |
| **SBT-META-P03** | 双指 pinch 缩放字体 | v1.52 2026-06-09 | **无** |
| **SBT-META-P04** | 复制主文本区保留空格 | v1.50 FIX | 开源 receive 区无专用 Copy 菜单 |
| **SBT-META-P05** | 单 CR 与 CR+LF 换行修复 | v1.49 2025-03-17 | 开源已有 `pendingNewline` 逻辑（TerminalFragment） |
| **SBT-META-P06** | 后台通知 / HEX / 换行 | Play 描述 + 用户评论 | 开源 **有** HEX/换行/后台通知 |
| **SBT-META-P07** | 自动重连 / Inquiry 附近发现 | 用户评论提及断连需手动 Connect | **无**（源码确认） |

**YoWire 差分（Meta）**：周期发送、命令面板、SessionLog 导出对标 Play **Macros** 能力，但 UI 进 **蓝牙 ⚙·命令与面板**（非终端内宏编辑器）。

---

## 2. 信息架构（SBT-IA-*）— 两屏模型

| ID | 层级 | 屏幕 | Fragment / 布局 | 导航 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBT-IA-01** | L0 | 单 Activity 容器 | `MainActivity` → `R.id.fragment` | 默认加载 Devices | E-SBT-001 · `19` §0 |
| **SBT-IA-02** | L1 | **设备列表** | `DevicesFragment`（ListFragment） | 冷启动首页 | E-SBT-001 |
| **SBT-IA-03** | L2 | **终端** | `TerminalFragment` + `fragment_terminal.xml` | 列表行点击 `replace` + `addToBackStack` | E-SBT-003 · SPP-08 |
| **SBT-IA-04** | — | 无第三屏 | 无 Connect Sheet / 无设置页 / 无 GATT 树 | — | `19` §1.8 |
| **SBT-IA-05** | 返回栈 | 系统 Back | 终端 → 设备列表；**连接保持**（detach 通知） | `TerminalFragment.onStop` → `service.detach()` | E-SBT-003 |
| **SBT-IA-06** | 参数传递 | `Bundle` key `"device"` | 值为 Bluetooth MAC 字符串 | `onListItemClick` | SPP-09 |
| **SBT-IA-07** | 列表 Header | `device_list_header.xml` | 非可选设备行（position-1 偏移） | `addHeaderView` | DevicesFragment |
| **SBT-IA-08** | 列表 Item | `device_list_item.xml` | text1=名称，text2=MAC | `ArrayAdapter.getView` | DevicesFragment |

**YoWire 差分（IA）**

| 竞品 | YoWire | 映射 ID |
| --- | --- | --- |
| 2 屏直进终端 | L0 三路径 + Segmented 已配对/附近 + Connect Sheet | B-SPP-08~11, B-SPP-C-* |
| 无设置页 | 蓝牙 ⚙ 模块设置全屏 push | `02-经典SPP` §5 |
| 无 Inquiry | Segmented「附近」~12s | B-SPP-09~11 · E-SBT-002 Gap |
| 返回无 Dialog | 保持/断开 Dialog | B-SPP-N-03 |

---

## 3. 权限与平台分支（SBT-PERM-*）

| ID | 条件 | 权限 / 行为 | UI 反馈 | 源码 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBT-PERM-01** | 设备无 BT 硬件 | `FEATURE_BLUETOOTH` false → `bluetoothAdapter=null` | 空态 `bluetooth not available` | `DevicesFragment.onCreate` | SPP-04 |
| **SBT-PERM-02** | 蓝牙未开启 | `!bluetoothAdapter.isEnabled()` | 空态 `bluetooth disabled` | `refresh()` | SPP-04 |
| **SBT-PERM-03** | API 31+ 缺 CONNECT | `BLUETOOTH_CONNECT` 未授予 | 空态 `permission required`；⋮ **Refresh 仍可见** 作引导 | `refresh()` + `onCreateOptionsMenu` | SPP-07 |
| **SBT-PERM-04** | Refresh 触权 | `ActivityResultLauncher` 申请 CONNECT | 授予后自动 `refresh()` | `BluetoothUtil.onPermissionsResult` | SPP-05 |
| **SBT-PERM-05** | Android 13+ 通知 | `POST_NOTIFICATIONS` | Background notification 菜单 → 系统通知设置 | `TerminalFragment.onOptionsItemSelected` | SPP-24 |
| **SBT-PERM-06** | API 26+ 通知渠道 | `NotificationChannel` IMPORTANCE_LOW | 前台服务通知 | `SerialService.initNotification` | E-SBT-003 |
| **SBT-PERM-07** | 经典 SPP **无** 定位权限 | 不使用 LE scan | — | 仅 `getBondedDevices()` | E-SBT-002 Gap vs BLE |

**YoWire 差分（权限）**：HarmonyOS 蓝牙权限对照表 → `05-全局与权限` G-PERM；虚拟 MAC 文案 → B-SPP-N-04。

---

## 4. 设备列表页 — DevicesFragment（SBT-DEV-*）

### 4.1 生命周期钩子

| ID | 钩子 | 行为 | YoWire 差分 | 证据 URL |
| --- | --- | --- | --- | --- |
| **SBT-DEV-LC-01** | `onCreate` | `setHasOptionsMenu(true)`；检测 BT；初始化 `listAdapter`；注册 Refresh 权限 Launcher | — | https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/DevicesFragment.java |
| **SBT-DEV-LC-02** | `onActivityCreated` | 注入 header；`setEmptyText("initializing...")`；绑定 adapter | + 蓝牙 Banner | SPP-01 |
| **SBT-DEV-LC-03** | `onCreateOptionsMenu` | inflate `menu_devices.xml`；权限缺失时 Refresh visible；无 adapter 时 settings disabled | B 栏刷新按钮 | 同上 |
| **SBT-DEV-LC-04** | `onResume` | **自动** `refresh()` | 同左 | SPP-02 |
| **SBT-DEV-LC-05** | `onListItemClick` | `position-1` 取设备；传 MAC；push TerminalFragment | 可选 Connect Sheet | SPP-08 |

### 4.2 菜单项（menu_devices.xml）

| ID | 菜单 `@id` | 标题（典型） | 行为 | 可见性 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **SBT-DEV-M-01** | `bt_refresh` | Refresh | 权限检查 → `refresh()` | API31+ 缺权时常显 | B 标题栏图标刷新 | SPP-05 · https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/res/menu/menu_devices.xml |
| **SBT-DEV-M-02** | `bt_settings` | Bluetooth settings | `ACTION_BLUETOOTH_SETTINGS` | adapter==null 时 disabled | 配对引导链 | SPP-06 |

**竞品无菜单项（YoWire 增值）**：Scan/Inquiry、Filter、⚙ 设置、收藏 — 见 B-SPP-09~14。

### 4.3 refresh() 数据逻辑

| ID | 步骤 | 逻辑 | 空态文案 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBT-DEV-R-01** | 清空列表 | `listItems.clear()` | — | — | SPP-03 |
| **SBT-DEV-R-02** | 枚举已配对 | `bluetoothAdapter.getBondedDevices()` | — | — | E-SBT-003 |
| **SBT-DEV-R-03** | **过滤 LE** | `device.getType() != DEVICE_TYPE_LE` | — | HarmonyOS 设备类型对照 | SPP-03 |
| **SBT-DEV-R-04** | 排序 | `Collections.sort(..., BluetoothUtil::compareTo)` | — | 收藏优先/最近连接 P1 | SPP-03 |
| **SBT-DEV-R-05** | 无配对 | — | `no paired devices` | 具体原因 Chip | SPP-04 |
| **SBT-DEV-R-06** | notify | `listAdapter.notifyDataSetChanged()` | — | — | DevicesFragment |

### 4.4 列表行 UI

| ID | 字段 | 规则 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- |
| **SBT-DEV-U-01** | text1 | `device.getName()`（可 null） | 别名/收藏 | DevicesFragment.getView |
| **SBT-DEV-U-02** | text2 | `device.getAddress()` MAC | 虚拟 MAC 文案 | 同上 |
| **SBT-DEV-U-03** | 点击 | **无** stopDiscovery（经典无扫描） | Inquiry stop 后连接 | SPP-08 |

---

## 5. 终端页 — TerminalFragment（SBT-TERM-*）

### 5.1 生命周期与服务绑定

| ID | 钩子 | 行为 | 关联组件 | YoWire 差分 | 证据 URL |
| --- | --- | --- | --- | --- | --- |
| **SBT-TERM-LC-01** | `onCreate` | `setHasOptionsMenu(true)`；`setRetainInstance(true)`；读 `device` 参数 | — | 状态持久化对照 | https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/TerminalFragment.java |
| **SBT-TERM-LC-02** | `onAttach` | `bindService(SerialService, BIND_AUTO_CREATE)` | SerialService | — | SPP-11 |
| **SBT-TERM-LC-03** | `onStart` | 若 service 已存在则 `attach(this)`；否则 `startService` | 防旋转 unbind 销毁 | — | SPP-12 |
| **SBT-TERM-LC-04** | `onResume` | `initialStart && service!=null` → **auto-connect** | 仅首次 | ⚙ 可关闭 auto-connect | SPP-13 |
| **SBT-TERM-LC-05** | `onStop` | 非配置变更 → `service.detach()` | 触发后台通知 | 返回 Dialog | SPP-24 |
| **SBT-TERM-LC-06** | `onDestroy` | 若仍连接 `disconnect()`；`stopService` | — | YoWire 可选保持连接 | TerminalFragment |
| **SBT-TERM-LC-07** | `onServiceConnected` | 保存 service；`attach`；若 resumed 则 connect | queue 回放 | SessionLog 回放 | SPP-14 |
| **SBT-TERM-LC-08** | `onDetach` | `unbindService` | — | — | TerminalFragment |

### 5.2 终端布局（fragment_terminal.xml）

| ID | 控件 `@id` | 类型 | 行为 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBT-TERM-U-01** | `receive_text` | TextView（滚动） | 接收区 + status 行混排 | C 栏 70% 分区 | SPP-19 |
| **SBT-TERM-U-02** | `send_text` | EditText | 发送输入；HEX 时 hint `HEX mode` | 同左 | SPP-23 |
| **SBT-TERM-U-03** | `send_btn` | Button | 点击 → `send(text)` | + 周期发送工具栏 | SPP-25 |
| **SBT-TERM-U-04** | 着色 | `colorRecieveText` / `colorSendText` / `colorStatusText` | 发送/状态/接收分色 | SessionLog 原始字节 | TerminalFragment |

**YoWire 差分**：无 MTU 顶栏（SPP 不适用）；无阶段条（status 混排）；无「会话记录…」菜单 → B-SPP-T-13。

### 5.3 终端菜单（menu_terminal.xml）

| ID | 菜单 `@id` | 类型 | 行为 | 源码方法 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **SBT-TERM-M-01** | `clear` | action | 清空 `receiveText`（**不清** SerialService 队列） | `onOptionsItemSelected` | 不清 SessionLog | SPP-21 · https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/res/menu/menu_terminal.xml |
| **SBT-TERM-M-02** | `newline` | action | AlertDialog 单选 CR+LF / LF / none | `arrays.xml` | 同左 | SPP-22 · https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/res/values/arrays.xml |
| **SBT-TERM-M-03** | `hex` | checkable | toggle `hexEnabled`；清空 send；`HexWatcher` | `onPrepareOptionsMenu` 同步 checked | 同左 | SPP-23 |
| **SBT-TERM-M-04** | `background_notification` | checkable | API26+ 检查渠道；API33+ POST_NOTIFICATIONS；跳转 APP_NOTIFICATION_SETTINGS | `showNotificationSettings()` | 模块 ⚙ 后台覆盖 | SPP-24 |

**arrays.xml 换行值**

| 显示名 | 值常量 | 字节 |
| --- | --- | --- |
| CR+LF | `TextUtil.newline_crlf` | `\u000d\u000a` |
| LF | `TextUtil.newline_lf` | `\u000a` |
| \<none\> | `TextUtil.newline_none` | 空串 |

**竞品无终端菜单（YoWire / Play）**：周期发送、命令收藏、会话导出、复制选中 — B-SPP-T-11~14；Play Macros — SBT-META-P01。

### 5.4 连接状态机（终端 status 行，无独立进度条）

| ID | 阶段 | TextView 文案 | `Connected` 枚举 | 底层 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **SBT-TERM-C-01** | 开始 | `connecting...`（status 色） | Pending | `connect()` → `SerialSocket` | Connect Sheet 显 UUID | SPP-15 |
| **SBT-TERM-C-02** | RFCOMM | （无单独文案） | Pending | `createRfcommSocketToServiceRecord` | 阶段条 | SPP-16 · E-SBT-002 |
| **SBT-TERM-C-03** | 成功 | `connected` | True | `onSerialConnect()` | + 时长/统计 | SPP-17 |
| **SBT-TERM-C-04** | 失败 | `connection failed: <msg>` | False | `onSerialConnectError` → disconnect | 错误码卡 | SPP-18 |
| **SBT-TERM-C-05** | 读循环 | 数据 append receive | True | `onSerialRead` | SessionLog 落盘 | SPP-19 |
| **SBT-TERM-C-06** | IO 错误 | `connection lost: <msg>` | False | `onSerialIoError` | + 自动重连 | SPP-20 |

**RFCOMM UUID（硬编码）**

```text
BLUETOOTH_SPP = 00001101-0000-1000-8000-00805F9B34FB
```

证据：https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/SerialSocket.java

**YoWire 差分**：UUID 可配置 → B-SPP-C-02~03；Inquiry → B-SPP-09；自动重连 → B-SPP-C-05。

### 5.5 发送 / 接收逻辑

| ID | 模式 | 发送 | 接收显示 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **SBT-TERM-TX-01** | 文本 | `(str + newline).getBytes()` | 发送行着色 append | SessionLog direction=TX | SPP-25 |
| **SBT-TERM-TX-02** | HEX | `fromHexString` + newline 字节 | HEX 行 append | 同左 | SPP-26 |
| **SBT-TERM-TX-03** | 未连接 | Toast `not connected` | — | 同左 | SPP-27 |
| **SBT-TERM-RX-01** | HEX 接收 | — | `TextUtil.toHexString` 每 chunk 一行 | 同左 | TerminalFragment |
| **SBT-TERM-RX-02** | CRLF 合并 | — | `pendingNewline` 跨 chunk 处理 `\r\n` | 同左 | SPP-28 |
| **SBT-TERM-RX-03** | 控制符 | — | `TextUtil.toCaretString` 显示不可见字符 | 专家视图 P1 | TerminalFragment |
| **SBT-TERM-RX-04** | UI 节流 | — | `SerialService.onSerialRead` 合并 chunk | 同 E-SBLE-005 | SPP-29 · E-SBT-003 |

---

## 6. SerialService — 前台服务与双队列（SBT-SVC-*）

| ID | 能力 | 行为 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- |
| **SBT-SVC-01** | 架构 | `SerialSocket → SerialService → TerminalFragment` 监听链 | SessionLog 后端订阅 | E-SBT-003 |
| **SBT-SVC-02** | `connect(socket)` | 保存 socket；`connected=true` | — | SerialService |
| **SBT-SVC-03** | `write(data)` | 转发 `socket.write`；未连接抛 IOException | — | SerialService |
| **SBT-SVC-04** | `attach(listener)` | drain **queue1 + queue2** → listener；清空队列 | 会话事件回放 | SPP-14 · E-SBT-006 |
| **SBT-SVC-05** | `detach()` | `listener=null`；若仍连接 → **前台通知** | 全局/模块后台设置 | SPP-24 |
| **SBT-SVC-06** | queue1 | mainLooper 已 post 但未消费的事件 | — | SerialService |
| **SBT-SVC-07** | queue2 | 无 listener 时 Connect/Read/IoError 缓存 | → SessionLog 持久化 | E-SBT-006 |
| **SBT-SVC-08** | Read 合并 | `lastRead` + `mainLooper.post` 批量 UI 更新 | 同左 | SPP-29 |
| **SBT-SVC-09** | 通知标题 | `Connected to <deviceName>` | — | `createNotification` |
| **SBT-SVC-10** | 通知动作 | **Disconnect** → `INTENT_ACTION_DISCONNECT` | 同左 | E-SBT-003 |
| **SBT-SVC-11** | 点击通知 | 重启 MainActivity | — | `restartPendingIntent` |
| **SBT-SVC-12** | `onDestroy` | cancelNotification + disconnect | — | SerialService |

**YoWire 差分（SessionLog / 命令面板）**：竞品 **无** 落盘；YoWire SL-TYPE-01 + ⚙·会话与日志；命令面板 → ⚙·命令与面板（Play Macros 仅完整版有）。

证据：https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/SerialService.java

---

## 7. SerialSocket — RFCOMM SPP（SBT-SCK-*）

| ID | 能力 | 实现 | YoWire 差分 | 证据 |
| --- | --- | --- | --- | --- |
| **SBT-SCK-01** | 构造 | 需 **非 UI** Context（ApplicationContext） | 同约束 | SerialSocket 构造函数 |
| **SBT-SCK-02** | UUID | 固定 `00001101-…`（标准 SPP） | 可配置 UUID | E-SBT-002 · SPP-16 |
| **SBT-SCK-03** | 连接 | 单线程 Executor → `createRfcommSocketToServiceRecord` + `connect()` | HarmonyOS RFCOMM API | SerialSocket.run |
| **SBT-SCK-04** | 读缓冲 | `byte[1024]` 循环 read | 原始字节流不分包 | SPP-19 |
| **SBT-SCK-05** | 写 | `socket.getOutputStream().write(data)` | — | SerialSocket.write |
| **SBT-SCK-06** | 后台断开 | 注册 `INTENT_ACTION_DISCONNECT` BroadcastReceiver | 同左 | SerialSocket |
| **SBT-SCK-07** | disconnect | close socket；unregister receiver；`listener=null` | — | SerialSocket |
| **SBT-SCK-08** | getName | name 或 address  fallback | — | 通知文案 |

**YoWire 差分**：Inquiry 发现设备 — **无**（E-SBT-002 Gap）；Channel 直连 — **无**（B-SPP-C-04 P2）。

---

## 8. 逐步用户流程（源码级 SPP-01～SPP-29 全表）

| SPP-ID | SBT 别名 | 用户动作 / 系统事件 | UI | 源码锚点 | YoWire 映射 | Evidence URL |
| --- | --- | --- | --- | --- | --- | --- |
| SPP-01 | SBT-DEV-LC-02 | 冷启动 | `initializing...` | DevicesFragment.onActivityCreated | B-SPP-01 | E-SBT-001 |
| SPP-02 | SBT-DEV-LC-04 | — | onResume 刷新 | DevicesFragment.onResume | B-SPP-02 | 同上 |
| SPP-03 | SBT-DEV-R-02~04 | — | 已配对非 LE 列表 | DevicesFragment.refresh | B-SPP-03 | E-SBT-003 |
| SPP-04 | SBT-DEV-R-05 | — | 空态分支 | DevicesFragment.refresh | B-SPP-04 | 同上 |
| SPP-05 | SBT-DEV-M-01 | ⋮ Refresh | 重拉列表 | onOptionsItemSelected | B-SPP-05 | menu_devices.xml |
| SPP-06 | SBT-DEV-M-02 | ⋮ BT settings | 系统设置 | ACTION_BLUETOOTH_SETTINGS | B-SPP-06 | DevicesFragment |
| SPP-07 | SBT-PERM-03 | 缺 CONNECT 权限 | Refresh 引导 | permissionMissing | B-SPP-07 | DevicesFragment |
| SPP-08 | SBT-DEV-LC-05 | 点击行 | push 终端 | onListItemClick | B-SPP-08 | E-SBT-003 |
| SPP-09 | SBT-TERM-LC-01 | 进终端 | 读 MAC 参数 | TerminalFragment.onCreate | B-SPP-C-01 | E-SBT-004 |
| SPP-10 | SBT-TERM-LC-01 | 旋转 | retainInstance | setRetainInstance(true) | B-SPP-N-01 | TerminalFragment |
| SPP-11 | SBT-TERM-LC-02 | — | bind 服务 | onAttach | B-SPP-BG-01 | E-SBT-003 |
| SPP-12 | SBT-TERM-LC-03 | — | startService | onStart | B-SPP-BG-05 | TerminalFragment |
| SPP-13 | SBT-TERM-LC-04 | 首次 onResume | auto-connect | connect() | B-SPP-N-02 | TerminalFragment |
| SPP-14 | SBT-SVC-04 | 服务连接 | queue 回放 | SerialService.attach | B-SPP-BG-01 | E-SBT-006 |
| SPP-15 | SBT-TERM-C-01 | 连接中 | `connecting...` | status() | B-SPP-S-02 | TerminalFragment |
| SPP-16 | SBT-TERM-C-02 | RFCOMM | — | SerialSocket.run | B-SPP-S-03 | E-SBT-002 |
| SPP-17 | SBT-TERM-C-03 | 成功 | `connected` | onSerialConnect | B-SPP-S-04 | TerminalFragment |
| SPP-18 | SBT-TERM-C-04 | 失败 | `connection failed:` | onSerialConnectError | B-SPP-S-05 | TerminalFragment |
| SPP-19 | SBT-TERM-C-05 | 接收 | append receive | SerialSocket read 1024 | B-SPP-S-06 | E-SBT-002 |
| SPP-20 | SBT-TERM-C-06 | 断连 | `connection lost:` | onSerialIoError | B-SPP-S-07 | TerminalFragment |
| SPP-21 | SBT-TERM-M-01 | ⋮ Clear | 清 receive | receiveText.setText("") | B-SPP-T-02 | E-SBT-004 |
| SPP-22 | SBT-TERM-M-02 | ⋮ Newline | Dialog 三选一 | arrays.xml | B-SPP-T-03 | arrays.xml |
| SPP-23 | SBT-TERM-M-03 | ⋮ HEX | toggle | hexEnabled | B-SPP-T-04 | E-SBT-004 |
| SPP-24 | SBT-TERM-M-04 | ⋮ 后台通知 | detach 前台通知 | SerialService.detach | B-SPP-T-05 | E-SBT-003 |
| SPP-25 | SBT-TERM-TX-01 | 发送文本 | 着色 echo | send() | B-SPP-T-06 | E-SBT-004 |
| SPP-26 | SBT-TERM-TX-02 | 发送 HEX | fromHexString | send() hex | B-SPP-T-07 | 同上 |
| SPP-27 | SBT-TERM-TX-03 | 未连接发送 | Toast | send guard | B-SPP-T-08 | TerminalFragment |
| SPP-28 | SBT-TERM-RX-02 | 接收 CRLF | pendingNewline | receive() | B-SPP-T-09 | TerminalFragment |
| SPP-29 | SBT-TERM-RX-04 | 多 chunk | UI 节流 | SerialService.onSerialRead | B-SPP-T-10 | E-SBT-006 |

---

## 9. YoWire 核心差分列（竞品 SimpleBT vs YoWire PRD）

| 维度 | SimpleBT（本清单） | YoWire | YoWire 清单 ID | 证据 |
| --- | --- | --- | --- | --- |
| **Inquiry 附近发现** | ✗ 仅已配对 | Segmented「附近」~12s + RSSI | B-SPP-09~11 | E-SBT-002 · `19` §1.2 |
| **Filter** | ✗ | 收藏/名称 Filter | B-SPP-14 | PRD §10 |
| **MTU UI** | N/A（RFCOMM） | N/A | — | — |
| **连接阶段条** | ✗ status 混排 | Connect Sheet + 可选阶段 | B-SPP-S-02 | `19` §1.4 |
| **SessionLog** | ✗ 无持久化 | 模块 ⚙·会话与日志 TXT/CSV/JSON | B-SPP-T-13 | E-SBT-003 Gap |
| **命令面板 / 周期发送** | ✗ 开源无；Play 有 Macros | ⚙·命令与面板 + C 工具栏 | B-SPP-T-11~12 | E-SBT-005 |
| **UUID 自定义** | ✗ 硬编码 00001101 | Connect Sheet + ⚙ | B-SPP-C-03 | E-SBT-002 |
| **自动重连** | ✗ | SppReconnectCoordinator | B-SPP-C-05 | `19` §1.8 |
| **返回 Dialog** | ✗ detach 通知 | 保持/断开 | B-SPP-N-03 | PRD §6.2 |

---

## 10. E-SBT 证据注册表（本清单引用）

| Evidence ID | URL | 本清单 SBT  ID 簇 |
| --- | --- | --- |
| E-SBT-001 | https://github.com/kai-morich/SimpleBluetoothTerminal | SBT-META-01, SBT-IA-* |
| E-SBT-002 | https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/SerialSocket.java | SBT-SCK-*, SPP-16~19 |
| E-SBT-003 | https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/SerialService.java | SBT-SVC-*, SPP-14,24,29 |
| E-SBT-004 | https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/TerminalFragment.java | SBT-TERM-*, SPP-09~28 |
| E-SBT-005 | https://play.google.com/store/apps/details?id=de.kai_morich.serial_bluetooth_terminal | SBT-META-P*（Macros/hex/通知） |
| E-SBT-19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §1 | SPP-01~29 逐步 |

---

## 11. 映射至 YoWire `02-蓝牙模块/02-经典SPP功能清单.md`

| 竞品 SBT / SPP | YoWire B-SPP ID | 对齐度 |
| --- | --- | --- |
| SBT-DEV-R-02~04（已配对列表） | B-SPP-03~05 | **P0 对齐** |
| SBT-TERM-M-01~04（终端四菜单） | B-SPP-T-02~05 | **P0 对齐** |
| SBT-SVC-04~10（后台通知） | B-SPP-BG-* | **P0 对齐** |
| SBT-SCK-02（硬编码 UUID） | B-SPP-C-02 | 竞品默认 = YoWire 默认 |
| —（Inquiry） | B-SPP-09~11 | **YoWire 增值** |
| —（SessionLog） | B-SPP-T-13 | **YoWire 增值** |
| SBT-META-P01（Play Macros） | B-SPP-T-11~12 | **YoWire 设置页实现** |

---

## 12. 竞品明确不支持项（禁止伪造 URL）

| 能力 | 说明 | YoWire PRD |
| --- | --- | --- |
| LE 扫描 / BLE UART | 独立仓库 SimpleBluetoothLeTerminal | `03-BLE-UART` |
| GATT 浏览器 | 无 | `01-BLE-GATT` |
| WiFi / 网络 | 无 | `03-WiFi模块` |
| 全局日志中心 Tab | 无 | E-HMS-002 架构决策 |
| WebSocket / MQTT | 无 | WF-NET-GAP |

---

## 13. 辅助类与常量（SBT-AUX-*）

| ID | 文件 | 职责 | 关键符号 | 证据 URL |
| --- | --- | --- | --- | --- |
| **SBT-AUX-01** | `MainActivity.java` | 单 Activity；默认 `DevicesFragment` | `R.id.fragment` | https://github.com/kai-morich/SimpleBluetoothTerminal/blob/master/app/src/main/java/de/kai_morich/simple_bluetooth_terminal/MainActivity.java |
| **SBT-AUX-02** | `Constants.java` | 通知渠道、Foreground id、Disconnect Intent | `NOTIFICATION_CHANNEL`, `INTENT_ACTION_DISCONNECT` | 同上仓库 Constants |
| **SBT-AUX-03** | `BluetoothUtil.java` | 设备排序；权限封装 | `compareTo`, `hasPermissions`, `onPermissionsResult` | DevicesFragment / TerminalFragment 引用 |
| **SBT-AUX-04** | `TextUtil.java` | HEX 编解码；换行常量；HexWatcher | `newline_crlf`, `fromHexString`, `toCaretString` | E-SBT-004 |
| **SBT-AUX-05** | `SerialListener.java` | 连接/读/错回调接口 | `onSerialConnect/Read/IoError` | SerialService 实现 |
| **SBT-AUX-06** | `AndroidManifest.xml` | `SerialService` 声明；BT 权限 | `BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_CONNECT` | 仓库 manifest |

### 13.1 Play 完整版 Release Notes 时间线（E-SBT-005）

| 版本 | 日期 | 变更摘要 | YoWire 参照 |
| --- | --- | --- | --- |
| 1.52 | 2026-06-09 | 双指 pinch 缩放字体 | G-DSP 显示密度 |
| 1.51 | 2026-05-01 | 无换行宏；HEX 宏带 delay | B-SPP-T-11 周期发送 |
| 1.50 | 2025-11-06 | 复制保留空格；最低 Android 5.0 | B-SPP-T-14 |
| 1.49 | 2025-03-17 | CR+LF 下单 CR 修复 | B-SPP-T-09 |

---

## 14. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：SBT-* 全量 ID、SPP-01~29、E-SBT 证据、YoWire 差分列、Play vs 开源 |
| 2026-07-03 | 增补 §13 辅助类与 Play Release 时间线 |
