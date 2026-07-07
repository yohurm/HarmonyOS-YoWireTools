# 02-蓝牙模块 — 用户交互流程索引

> **状态**：深研草稿（未定稿）  
> **版本**：v0.2 · 2026-07-03  
> **主索引**：[`../09-交互流程全量索引与PRD映射.md`](../09-交互流程全量索引与PRD映射.md)  
> **功能清单**：[`01-功能清单/02-蓝牙模块/`](../../01-功能清单/02-蓝牙模块/README.md)

---

## 1. 文档列表

| 文件 | 范围 | 行数 | 840vp § |
| --- | --- | ---: | --- |
| [01-BLE-GATT逐步交互流程.md](./01-BLE-GATT逐步交互流程.md) | Filter → CONNECT → GATT → Log → Macros | 343 | §16 |
| [02-经典SPP逐步交互流程.md](./02-经典SPP逐步交互流程.md) | 已配对/附近/收藏 → Inquiry → 终端 → 导出 | 330 | §14 |
| [03-BLE-UART逐步交互流程.md](./03-BLE-UART逐步交互流程.md) | SCAN → 四步 Profile → 终端 / 失败 → GATT | 338 | §10 |
| [04-模块设置与会话命令流程.md](./04-模块设置与会话命令流程.md) | 蓝牙 ⚙ 五 Tab；命令；会话导出；Panel Grid | 330 | §8 |
| [05-BLE实验室Macros与DFU逐步交互流程.md](./05-BLE实验室Macros与DFU逐步交互流程.md) | ADV-* · GSRV-* · MAC 28 tag · DFU-* | 363 | §7 |

**840vp 横切**：[`../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md`](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md) §3.2（BLE GATT / SPP / UART）。

---

## 2. 竞品逐步对照（08）

| YoWire 流程 | 08-竞品对照 | 09-竞品功能清单 |
| --- | --- | --- |
| 01 BLE-GATT | [08/01-nRF Connect](../08-竞品逐步流程对照/README.md#01-nrf-connect) 📋 | [01-nRF Connect](../../01-功能清单/09-竞品APP功能清单/01-nRF-Connect-Android-全量功能清单.md) |
| 02 经典 SPP | [08/02-SimpleBT](../08-竞品逐步流程对照/README.md#02-simplebluetoothterminal) 📋 | [02-SimpleBT SPP](../../01-功能清单/09-竞品APP功能清单/02-SimpleBluetoothTerminal-经典SPP-全量功能清单.md) |
| 03 BLE-UART | [08/03-SimpleBLE](../08-竞品逐步流程对照/README.md#03-simplebluetoothleterminal) 📋 | [03-SimpleBLE UART](../../01-功能清单/09-竞品APP功能清单/03-SimpleBluetoothLeTerminal-BLE-UART-全量功能清单.md) |
| 04 设置 / 05 实验室 | [08/01-nRF §Settings/Lab](../08-竞品逐步流程对照/README.md#01-nrf-connect) 📋 | 09/01 |

---

## 3. 上游依据

| 类型 | 路径 |
| --- | --- |
| 深研清单 | `.research/feature-inventory/08` `11` `13` `19` |
| UI 设计 | [`03-UI设计/02-蓝牙模块/`](../../03-UI设计/02-蓝牙模块/) |
| 840 线框 | doc `10`（GATT）· doc `17`（SPP/UART） |
| 会话模型 | [`03-UI设计/00-全局框架/03-模块自治与会话命令模型.md`](../../03-UI设计/00-全局框架/03-模块自治与会话命令模型.md) |
| 统一后端 | [`06-统一后端/README.md`](../06-统一后端/README.md) |

---

## 4. 流程格式约定

每步表格四列：| 步 | 用户动作 | 系统响应 | 控件名 |

- **步**：`步1` 或域前缀 `INQ-1`、`FILTER-*`、`NL-A*`（星闪无）  
- **分支**：手机 `<600vp` / 宽屏 `≥840vp` 单独小节  

---

## 5. 模块共性

1. 顶栏 `[扫描/Filter/⚙]` ≤3 上下文按钮  
2. ⚙ → `BluetoothSettingsPage`（NavDestination，非 Sheet）  
3. 无全局日志/命令 Tab  
4. 连接中返回 → `KeepConnectionDialog`  
5. Panel Grid 编辑 **仅** ⚙·命令与面板  

---

## 6. 阅读顺序

1. [01-BLE-GATT](./01-BLE-GATT逐步交互流程.md)（P0）  
2. [02-经典SPP](./02-经典SPP逐步交互流程.md) · [03-BLE-UART](./03-BLE-UART逐步交互流程.md)  
3. [04-模块设置](./04-模块设置与会话命令流程.md)  
4. [05-BLE实验室](./05-BLE实验室Macros与DFU逐步交互流程.md)（P3 专家）  
5. 840vp：[07/03](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md)

---

## 7. 下游

- Navigation 路由表实现  
- [`03-UI设计/08-验收与状态/02-模块验收清单.md`](../../03-UI设计/08-验收与状态/02-模块验收清单.md)  
- P0 清单：[`09-索引`](../09-交互流程全量索引与PRD映射.md) §4.2

---

*蓝牙模块用户交互流程子目录索引 · v0.2*
