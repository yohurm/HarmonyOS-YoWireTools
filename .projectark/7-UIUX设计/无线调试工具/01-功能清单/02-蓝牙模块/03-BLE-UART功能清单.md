# 03-BLE-UART 功能清单

> **状态：深研草稿，未定稿。**  
> **竞品基准**：SimpleBluetoothLeTerminal（E-SBLE 源码级）。  
> **YoWire 差分**：独立 L1 入口、显式连接阶段条、MTU UI、扫描 Filter、失败转 GATT、SessionLog/命令面板。  
> **证据链**：`.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §2 · `22-…` §3 · `17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md` §3

---

## 1. 范围与三路径边界

| 项 | BLE UART | BLE GATT | 经典 SPP |
| --- | --- | --- | --- |
| 用户目标 | 快速 Nordic 等串口 Profile 终端 | 通用 GATT 浏览器 | RFCOMM 字节流 |
| 连接后 UI | 终端（同 SPP 布局） | GATT 树 + Log pane | 终端 |
| Profile | 自动匹配 4 种预设 | 全服务树 | N/A |
| 失败兜底 | **改用 GATT 调试** | — | — |
| 清单文档 | 本文 | `01-BLE-GATT全量功能清单.md` | `02-经典SPP功能清单.md` |

**IA 铁律**：UART 连接失败 **不得** 在 UART 页复刻完整 GATT 能力；应 Segmented/按钮跳转 GATT 入口（PRD §9 · `02-蓝牙模块` README）。

---

## 2. Profile 预设与 UUID 对照（B-UART-P-*）

| ID | Profile | Service UUID | TX (Write) | RX (Notify/Read) | SimpleBT | YoWire 首期 | 证据 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **B-UART-P-01** | **Nordic UART** | `6e400001-b5a3-f393-e0a9-e50e24dcca9e` | `6e400002-…` (write) | `6e400003-…` (notify) | ✓ 自动 | **P0 首期优先** | `19` UART-12 |
| **B-UART-P-02** | TI CC254x | `0000ffe0-0000-1000-8000-00805f9b34fb` | `0000ffe1` 读写同特征 | 同左 | ✓ | **P1** 后续扩展 | `19` · PRD §9.1 |
| **B-UART-P-03** | Microchip RN4870/1 | `49535343-FE7D-4ED5-8A77-040FB917814E` | W `…8841…` / RW `…1E4D…` | 双特征 | ✓ | **P1** | `19` |
| **B-UART-P-04** | Telit Bluemod | `0000FEFB-0000-1000-8000-00805F9B34FB` | Credits 流控 | 异步多步 CCCD | ✓ | **P1** | `19` |
| **B-UART-P-05** | **自定义 Profile** | 用户指定 S/TX/RX | 用户映射 | 用户映射 | ✗ | **P2** 完整规划 | PRD §9.2 |
| **B-UART-P-06** | 手动选择 Profile | 无 UI | 连接前/后可选 | **P1** | Connect Sheet / ⚙ | PRD §9.2 |
| **B-UART-P-07** | 按设备/全局保存映射 | 无 | **P2** | **蓝牙 ⚙·BLE 连接** | PRD §9.2 |

**CCCD 标准**：`00002902-0000-1000-8000-00805f9b34fb`（所有 Notify Profile 共用）。

---

## 3. 扫描页功能（B-UART-S-*）

| ID | 功能 | E-SBLE 行为 | YoWire 优先级 | YoWire UI | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-UART-S-01** | 进入页空态 | `use LE scan` / disabled 等 | **P0** | 状态 Banner | — | UART-01 |
| **B-UART-S-02** | ⋮ **Scan** | 10s 自动 stop；`<scanning...>` | **P0** | B SCAN/STOP toggle | — | UART-02~03 |
| **B-UART-S-03** | LE 扫描周期 | `LE_SCAN_PERIOD=10000` ms | **P0** | 可 ⚙ 配置 duty | — | UART-03 |
| **B-UART-S-04** | 扫描结果列表 | 名空则 `<unnamed>`；地址行 | **P0** | B 栏列表 | §7.1 | UART-04 |
| **B-UART-S-05** | ⋮ **Stop** | stopScan / cancelDiscovery | **P0** | 同 SCAN toggle | — | UART-05 |
| **B-UART-S-06** | **点击 → stopScan → 终端** | 第一行 stopScan | **P0** | **连接前必须 stopScan** | BT-GATT-03 | UART-06 · E-SBLE-001 |
| **B-UART-S-07** | 定位权限 (API 23–30) | AlertDialog → FINE_LOCATION | **P0** | HarmonyOS 蓝牙权限 | — | UART-07 |
| **B-UART-S-08** | 定位关 → Discovery fallback | `startDiscovery()` | **P1** | 平台降级说明 | — | UART-08 |
| **B-UART-S-09** | **Filter**（名/RSSI/收藏） | **无** | **P1** YoWire 增值 | Filter Sheet → ⚙ 预设 | §7.2 | `19` §2.5 |
| **B-UART-S-10** | 独立 L1 入口 | 与 GATT 同页 DevicesFragment | **P0** IA | 蓝牙首页「BLE 串口预设」 | §9 | BT-UART-01 |
| **B-UART-S-11** | 发现次数/最后发现时间 | 无 | **P1** | B 行副信息 | §7.1 | PRD |

---

## 4. 连接阶段链（B-UART-C-*）— 四步阶段条

> 竞品仅在终端 status 混排 `connecting…`；YoWire **必须**显式阶段条（PRD · `17` §3.3）。

| 步 | ID | 阶段 | SimpleBT 日志/状态 | YoWire 阶段条 | 源码方法 | 证据 |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | **B-UART-C-01** | GATT 连接 | `connectGatt,LE` | 1/4 连接中 | `connectGatt(TRANSPORT_LE)` | UART-09 |
| 2 | **B-UART-C-02** | 配对请求 | `pairing request` 资源串 | ≥600vp 配对 Sheet | `ACTION_PAIRING_REQUEST` | UART-10 · E-SBLE-004 |
| 3 | **B-UART-C-03** | 服务发现 | `discoverServices` | 2/4 发现服务 | `onConnectionStateChange(CONNECTED)` | UART-11 |
| 4 | **B-UART-C-04** | **Profile 匹配** | 命中 delegate | 3/4 显示 Profile 名 | `connectCharacteristics1()` 遍历 | UART-12 |
| 5 | **B-UART-C-05** | **无 Profile 失败** | `no serial profile found` | Error 卡 + **改用 GATT** | 失败分支 E-SBLE-003 | UART-13 |
| 6 | **B-UART-C-06** | **MTU 请求** | `request max MTU` max 512 | 4/4 子步；顶栏 MTU | `requestMtu(MAX_MTU)` | UART-14 |
| 7 | **B-UART-C-07** | MTU 结果 | `payload size = mtu-3` | 顶栏展示 MTU + payload | `onMtuChanged()` | UART-15 |
| 8 | **B-UART-C-08** | Notify/Indicate CCCD | 写 `00002902-…` | 阶段条完成 | `connectCharacteristics3()` | UART-16 |
| 9 | **B-UART-C-09** | **就绪 connected** | `connected` | 进入终端收发 | `onDescriptorWrite` 成功 | UART-17 |

### 4.1 MTU 与分包（B-UART-M-*）

| ID | 功能 | SimpleBT | YoWire 优先级 | YoWire 行为 | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-UART-M-01** | MTU 协商 | 内部 max 512 | **P0** | HarmonyOS [23,517] | §8.4 | UART-14 |
| **B-UART-M-02** | payloadSize = mtu-3 | 内部计算 | **P0** | 顶栏副标题展示 | §8.4 | UART-15 |
| **B-UART-M-03** | 发送分包队列 | writeBuffer 按 payload 切 | **P0** | 长发送提示分包 | §8.4 | UART-21 |
| **B-UART-M-04** | MTU 变化订阅 | 无 UI | **P0** | 订阅 MTU 变更事件 | §8.4 | PRD §8.4 |
| **B-UART-M-05** | 用户请求 MTU | 自动 max | **P1** | C 工具栏 / ⚙ 默认 | §8.4 | SET-CONN-06 对照 |
| **B-UART-M-06** | 日志记录 MTU 协商 | 无 | **P0** | SessionLog 事件 | §8.4 | PRD |

**YoWire 顶栏示例**：`NUS · MTU 247 · payload 244`（B-UART-08 / BT-UART-06）。

---

## 5. 终端页（B-UART-T-*）

| ID | 功能 | SimpleBT / E-SBLE | YoWire 优先级 | YoWire UI | PRD | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **B-UART-T-01** | 布局同 SPP | `fragment_terminal.xml` 同构 | **P0** | C 栏 70% 收发 + 30% 折叠 Log | BT-UART-09 | UART-18 |
| **B-UART-T-02** | Clear / Newline / HEX / 后台通知 | 菜单四件套 | **P0** | C 工具栏 ⋮（≤6） | BT-SPP-05 | UART-19 · SPP-21~24 |
| **B-UART-T-03** | onResume auto-connect | new SerialSocket → connect | **P0** | 进入页自动连；可 ⚙ 关 | — | UART-20 |
| **B-UART-T-04** | **MTU 顶栏展示** | 竞品无 UI | **P0** | `Profile · MTU n · payload n-3` | BT-UART-06 | UART-22 |
| **B-UART-T-05** | 文本发送 | str + newline | **P0** | 发送按钮 + 输入框 | BT-UART-09 | SPP-25 |
| **B-UART-T-06** | HEX 发送 | fromHexString | **P0** | HEX toggle 后发送 | BT-UART-09 | SPP-26 |
| **B-UART-T-07** | 未连接发送 Toast | `not connected` | **P0** | 同左 | — | SPP-27 |
| **B-UART-T-08** | CRLF 跨 chunk 合并 | pendingNewline | **P0** | 接收区逻辑 | — | SPP-28 |
| **B-UART-T-09** | 接收 UI 节流 | queue + post | **P0** | 同 E-SBLE-005 | — | SPP-29 |
| **B-UART-T-10** | **周期发送** | 无 | **P1** | C Resend + 间隔 Sheet | BT-UART-09 · CMD-03 | YoWire PRD |
| **B-UART-T-11** | **命令收藏 Sheet** | 无 | **P1** | 「从收藏选择」 | BT-UART-09 · CMD-01 | E-PS-001 |
| **B-UART-T-12** | **会话记录…** | 无 | **P0** | → **蓝牙 ⚙·会话与日志** | SL-TYPE-03 | `00` §6 |
| **B-UART-T-13** | 复制选中 / 混合视图 | 仅文本/HEX | **P1** | 接收区长按/专家视图 | — | PRD |
| **B-UART-T-14** | Notify 数值曲线 | 无 | **P2** | 独立 Sub-Tab 或 Sheet | BT-UART-12 | BT-GATT-12 复用 |
| **B-UART-T-15** | UTF-8/ASCII 编码 | 隐含 UTF-8 | **P1** | ⋮ 或 ⚙ 默认 | — | PRD |

**C 工具栏（≤6，840vp）**：发送 · Resend · 收藏 · Clear · HEX · 更多（Newline/通知/会话记录）。

**终端菜单与 SPP 对齐**：`02-经典SPP功能清单.md` §2.4 B-SPP-T-02~05 同构；差分仅顶栏 MTU（T-04）。

---

## 5.1 导航与生命周期（B-UART-N-*）

| ID | 行为 | SimpleBT | YoWire | 证据 |
| --- | --- | --- | --- | --- |
| **B-UART-N-01** | retainInstance / 状态持久 | true | HarmonyOS 状态持久化 | SPP-10 |
| **B-UART-N-02** | 扫描页点击 → stopScan → 终端 | 第一行 stopScan | **P0 强制** | UART-06 |
| **B-UART-N-03** | 返回上一页 | detach 通知 | **保持/断开 Dialog**（继承 SPP） | BT-SPP-11 |
| **B-UART-N-04** | Profile 失败 | error 字符串 | Error 卡 + **改用 GATT** CTA | B-UART-C-05 |
| **B-UART-N-05** | 840vp 不断 Session | N/A 手机 push | A/B/C 切换保留 C 终端 | BT-UART-13 · `07/04` |

---

## 5.2 Profile 自动匹配算法（B-UART-MATCH-*）

| 步 | 行为 | 失败 |
| ---: | --- | --- |
| 1 | `discoverServices()` 完成 | 超时 → 阶段条 Error |
| 2 | 按 ⚙ 默认 Profile 序：Nordic → TI → Microchip → Telit | 四者均 miss |
| 3 | 命中则 `connectCharacteristics1/2/3` + CCCD | → **B-UART-C-05** + GATT 跳转 |
| 4 | `requestMtu(MAX)` → 展示 payload | MTU 失败仍可收发默认 20 |
| 5 | Notify 就绪 → `connected` | — |

**证据**：`.research/feature-inventory/19-…` UART-12~17 · SimpleBLE `SerialSocket.java`

---

## 6. SerialService / SerialSocket 架构（B-UART-ARCH-*）

| ID | 组件 | 职责 | 与 SPP 差异 | 证据 |
| --- | --- | --- | --- | --- |
| ARCH-01 | `DevicesFragment` | SCAN/STOP、LE 列表 | LE 扫描 vs bonded | `19` §2.1 |
| ARCH-02 | `SerialSocket` (BLE) | GATT 链、Profile、MTU、CCCD、写队列 | vs RFCOMM SPP | `19` §2.1 |
| ARCH-03 | `TerminalFragment` | UI 同 SPP | 仅 Socket 构造不同 | `19` §2.4 |
| ARCH-04 | `SerialService` | 双队列、detach 通知 | **与 SPP 同构** | E-SBLE-005 · E-SBT-006 |
| ARCH-05 | 接收节流 | lastRead + mainLooper | 同源 SPP-29 | `19` UART-21 |

---

## 7. YoWire PRD 需求 ID 映射

| PRD ID | 摘要 | 本清单 ID | Gap |
| --- | --- | --- | --- |
| BT-UART-01 | 独立入口 | B-UART-S-10 | P0 |
| BT-UART-02 | LE 扫描+stop 后连接 | B-UART-S-02~06 | P0 |
| BT-UART-03 | 四 Profile 自动匹配 | B-UART-P-01~04, C-04 | P0 |
| BT-UART-04 | 首期仅 Nordic | B-UART-P-01 vs P-02~04 | P1 |
| BT-UART-05 | 自定义 UUID 映射 | B-UART-P-05~07 | P2 |
| BT-UART-06 | MTU+UI+分包 | B-UART-M-*, T-04 | P0 |
| BT-UART-07 | 扫描 Filter | B-UART-S-09 | P1 |
| BT-UART-08 | 失败→GATT | B-UART-C-05 | P1 |
| BT-UART-09 | 终端同 SPP 增强 | B-UART-T-05~06 | P1 |
| BT-UART-10 | 显式阶段条 | B-UART-C-01~09 | P1 |
| BT-UART-11 | 配对 Sheet | B-UART-C-02 | P0 |
| BT-UART-12 | Notify 曲线 | B-UART-T-08 | P2 |
| BT-UART-13 | 840vp B+C | §8 | P1 |

---

## 8. 逐步流程（完整）

### 8.1  happy path：Nordic UART

```text
1. 蓝牙首页 → BLE 串口预设
2. B 栏 SCAN（10s 或手动 STOP）
3. 点击设备 → stopScan
4. [可选] Connect Sheet：Profile 默认 NUS
5. push 终端 → 阶段条：
   连接 → 发现服务 → 匹配 NUS → MTU/CCCD → connected
6. 顶栏：NUS · MTU xxx · payload xxx
7. 收发（HEX/换行/周期/命令收藏）
8. SessionLog → 蓝牙 ⚙·会话与日志
```

### 8.2 失败 path：无 Profile

```text
1. 步骤 3/4 Profile 匹配失败
2. C 区 Error 卡：no serial profile found（友好中文）
3. 主 CTA：「改用 GATT 调试」→ 携带 deviceId 跳转 BLE GATT
4. 次 CTA：换 Profile 手动重试（P1）
```

**证据**：`19` UART-13 · `17` §3.3 · BT-UART-08

---

## 9. 蓝牙 ⚙ 设置映射

| ⚙ 分组 | UART 相关项 | 功能 ID |
| --- | --- | --- |
| **BLE 连接** | 默认 Profile；MTU 默认；自定义 UUID 对 | B-UART-P-06~07, M-05 |
| **BLE 扫描** | 扫描 duty；Filter 预设 | B-UART-S-02~03, S-09 |
| **会话与日志** | UART 会话列表；导出 | B-UART-T-07 |
| **命令与面板** | BLE 串口命令；周期发送默认 | B-UART-T-05~06 |
| **连接** | 自动重连（同 SPP） | 继承 B-SPP-C-05 |

---

## 10. 840vp 宽屏（B-UART-840-*）

| ID | 手机 <840vp | ≥840vp A/B/C | 证据 |
| --- | --- | --- | --- |
| **B-UART-840-01** | push 扫描 → push 终端 | **A** Tab · **B** LE 列表+Filter · **C** 终端/阶段条 | `17` §3 |
| **B-UART-840-02** | Connect Sheet 全屏 | ≥600vp 居中 Sheet；Profile/MTU 在 Sheet 或 C 顶栏 | doc 17 |
| **B-UART-840-03** | 阶段条全屏 | 连接中 C 栏顶 4 步条；完成后收起到 MTU 顶栏 | BT-UART-10 |
| **B-UART-840-04** | Write/Filter Sheet | **禁止第四 Inspector**；Filter/Write 用 Sheet | IA-04 |
| **B-UART-840-05** | 成功后 C 布局 | 同 SPP 70/30 Traffic+Log 折叠 | `17` §2.1 |

**专篇流程**：`02-用户交互流程/07-多设备/04-蓝牙840vp三分栏逐步交互流程.md` · PRD BT-UART-13

| 栏 | 内容 | 标题按钮 |
| --- | --- | --- |
| A | 蓝牙 L1：GATT / SPP / **UART** / 实验室 | — |
| B | SCAN/STOP · Filter · LE 列表 | ≤3 |
| C | 阶段条 / 终端 / Resend 工具栏 | ≤6 |

---

## 11. 竞品 vs YoWire 对照表

| 项 | E-SBLE | YoWire |
| --- | --- | --- |
| 入口 | UART 页内 Scan | 蓝牙首页独立 L1 |
| Filter | ✗ | ✓ P1 |
| Profile 手动 | 仅自动 | ⚙ 默认 + 专家自定义 P2 |
| MTU UI | ✗ | ✓ P0 顶栏 |
| 阶段条 | status 混排 | ✓ 4 步 P1 |
| 失败引导 GATT | error 字符串 | ✓ Error 卡 P1 |
| SessionLog/命令 | ✗ | ✓ P0/P1 |

---

## 12. 证据索引

| 键 | 路径 |
| --- | --- |
| E-SBLE-19 | `.research/feature-inventory/19-经典SPP与BLE-UART-源码级逐步流程-v2.md` §2 |
| GAP-22 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` §3 |
| 840-17 | `.research/feature-inventory/17-HarmonyOS-840vp-经典SPP与UART三分栏线框-v2.md` §3 |
| 源码 | `.research/reference-apps/SimpleBluetoothLeTerminal/` |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/03-蓝牙模块PRD.md` §9 |
| SPP 终端 | `02-经典SPP功能清单.md` §2.4 |

---

## 13. 架构重设计缺口回写（2026-07-23）

> 总册见 [`00-蓝牙功能总清单与优先级矩阵.md`](00-蓝牙功能总清单与优先级矩阵.md)。

| 缺口 | 定稿优先级 | 架构落点 |
| --- | --- | --- |
| **独立 L1 入口** `UartMainPage`（首页三路径并列） | P0 | `ui/page` · BluetoothFeaturePage |
| `SerialProfileMatcher` 服务（Nordic P0；其余 P1） | P0 | `domain/service/uart` |
| 四步+阶段条 UI（B-UART-C-*） | P0 | `UartMainViewModel` |
| 失败 → **改用 GATT** 跳转契约（禁止页内复刻 GATT 树） | P0 | navigation + Event |
| 终端同构 SPP + 复用 CommandWriteQueue / GattTransport | P0 | queue + transport |
| MTU / payloadSize=mtu-3 顶栏展示 | P0 | VM Trace |
| 四 Profile（TI/Microchip/Telit） | P1 | matcher 扩展 |
| 自定义 Profile | P2 | ⚙·BLE 连接 |

---

## 14. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：Profile/MTU/阶段 B-UART-* 全 ID、双流程、PRD 映射 |
| 2026-07-03 | **v2**：§5 终端 15 项 · N/MATCH/840 专节 · C 工具栏 · `07/04` 链 |
| 2026-07-23 | §13 架构缺口：独立页、ProfileMatcher、失败跳转 GATT |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v2 |
| 功能 ID 前缀 | B-UART-* · B-UART-P/S/C/M/T/N-* |
| 行数 | ~290 |
| 02-流程 | `02-蓝牙/03` · `07-多设备/04` |
