# 04-BLE 实验室与高级功能清单

> **状态：深研草稿，未定稿。**  
> **范围**：nRF Connect **Advertiser**、**Configure GATT Server**、**DFU 四协议**、**Macros 28 操作全量**、**Automated Tests**、**Eddystone/iBeacon** 等实验室/生态级能力。  
> **YoWire 定位**：**P2 架构预留 + P3 明确不纳入 v1 承诺**；入口在 A 栏「BLE 实验室」，专家模式门控。  
> **证据链**：`.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` §3 · `08-…` §4 · `11-Macros-28操作-v2.md` · `13-DFU与Connection菜单-v2.md` · `21-UNKNOWN交叉验证-v2.md`

---

## 1. 分级总览

| 能力域 | nRF 完整度 | YoWire 优先级 | v1 承诺 |
| --- | --- | --- | --- |
| Advertiser / 广播克隆 | 文档完整 | **P2** 实验室 | 架构预留 |
| GATT Server + XML Import | 5 预设 + Custom | **P2–P3** | 架构预留 |
| DFU Legacy/Secure | 较完整 UI | **P3** | 不纳入 v1 |
| McuManager / SUIT | 轻量 bin + Device Manager 完整 | **P3** | 不纳入 v1 |
| Macros 28-tag 引擎 | 完整 FAB+Sheet | **P3** | P1 仅单命令收藏 |
| Automated Tests 27-tag | 仅 ADB | **P3** | 无 in-app UI |
| Eddystone / iBeacon / Physical Web | 产品页+Macros | **P3** | 不纳入 v1 |
| TIMELINE / RSSI 多设备对比 | Scanner 长按 | **P3** | 不纳入 v1 |

**PRD 对照**：`03-蓝牙模块PRD.md` §12（Advertiser/GATT Server 架构预留）· `22-…` §1 BT-GATT-15~17 · §8.4 P3

---

## 2. Advertiser Tab（ADV-*）

| ID | 功能 | nRF UI/行为 | YoWire 优先级 | YoWire 落点 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **ADV-01** | Advertiser Tab 入口 | 底部 Tab 第三项 | **P2** | A 栏「实验室」→ 广播 | `08` §4.1 |
| **ADV-02** | 历史广播包列表 | 模拟他机所见 | **P2** | 实验室列表 | `08` §4.1.1 |
| **ADV-03** | FAB **+** 新建包 | 广播包编辑器 | **P2** | 编辑器页 | `08` §4.1.2 |
| **ADV-04** | 菜单 **笔** 设 Complete Local Name | 系统级名称 | **P2** | 设置项 | `08` §4.1.3 |
| **ADV-05** | Start/Stop 本机广播 | BLE 广播开关 | **P2** | 主 CTA | `08` §4.1.4 |
| **ADV-06** | **Discoverable flag** | 4.29+ 控制可发现性 | **P2** | 编辑器 Switch | `09` REL-4.29.1 |
| **ADV-07** | **Service Solicitation UUID** | 4.29+ 广播字段 | **P2** | 编辑器 | `09` REL-4.29.1 |
| **ADV-08** | **CLONE**（来自 Scanner S-09） | 克隆他机 AD → Advertiser | **P3** | Scanner 行操作 → 实验室 | `01-v2` S-09 |
| **ADV-09** | Physical Web URL / OPEN (S-10) | 浏览器打开 URL | **P3** | 不纳入 v1 | `01-v2` |
| **ADV-10** | Eddystone / iBeacon 预设 | 产品页+解析器 | **P3** | 后续 | `01-v2` §1 |

---

## 3. Configure GATT Server（GSRV-*）

| ID | 功能 | nRF UI/行为 | YoWire 优先级 | 证据 |
| --- | --- | --- | --- | --- |
| **GSRV-01** | ☰ Drawer → Configure GATT Server | 配置页入口 | **P2** | `08` §4.2 |
| **GSRV-02** | 顶栏 Dropdown | 选配置 / New / Import XML / Disable | **P2–P3** | `08` §4.2.2 |
| **GSRV-03** | **Import XML** | Storage 权限 | **P3** | `01-v2` §3 |
| **GSRV-04** | **Share / Export XML** | Android Share | **P3** | `21` DR-02 · DZ-68849 |
| **GSRV-05** | ADD SERVICE 预设 | Custom + Link Loss + Immediate Alert + Current Time + Heart Rate | **P2** | `01-v2` 统计 |
| **GSRV-06** | ADD CHARACTERISTIC / DESCRIPTOR | 自定义 UUID 与属性 | **P2** | `08` §4.2.4 |
| **GSRV-07** | **Sample configuration** | Macros 教程 #3 依赖 | **P3** | `11` §3 |
| **GSRV-08** | 连接后 **SERVER Tab** | 本机 GATT 镜像；远端读写 Log | **P2** | `08` §3.4 |
| **GSRV-09** | **Show incoming connections** | Settings Switch；默认 ON | **P2** | SET-CONN-08 · `21` |
| **GSRV-10** | **Clone device's services** (CM-13) | 克隆远端 GATT → 本地 DB | **P3** | `13` ISSUE#13 |

---

## 4. DFU 四协议（DFU-*）

### 4.1 协议对照

| ID | 协议 | SDK/平台 | nRF 支持 | YoWire | 证据 |
| --- | --- | --- | --- | --- | --- |
| **DFU-01** | Legacy DFU | nRF5 SDK | ✓ ZIP/bin+dat | **P3** | `13` §2.0 |
| **DFU-02** | Secure DFU | nRF5 SDK 12+ | ✓ 签名 ZIP | **P3** | `13` §2.2 |
| **DFU-03** | McuManager (SMP) | NCS/Zephyr | ✓ 轻量 `.bin` | **P3** | `13` §2.3 |
| **DFU-04** | SUIT over SMP | NCS 3.x+ / nRF54H | ✓ 4.29.1+ | **P3** 首期不做 SUIT | `13` §2.4 · `21` PARTIAL |

**边界**：完整 FOTA mode / SUIT Confirm / Read manifest → **nRF Connect Device Manager** 独立 App；YoWire 不复制 Device Manager 全量。

### 4.2 DFU UI 流程（证据化步骤）

| 步 | ID | 用户动作 | UI | YoWire | 证据 |
| ---: | --- | --- | --- | --- | --- |
| 1 | **DFU-E-01** | Scanner/Bonded CONNECT | 连目标或 DfuTarg | P3 | `13` §2.1 |
| 2 | **DFU-E-02** | 顶栏 **DFU 图标**（非 ⋮） | 固件升级入口 | P3 | ISSUE#184 |
| 3 | **DFU-E-03** | 选 **Distribution ZIP** | Document Picker | P3 | `13` §2.2.1 A-3a |
| 4 | **DFU-E-04** | 或 SoftDevice/Bootloader/Application 分文件 | bin/hex + init .dat | P3 | A-3b |
| 5 | **DFU-E-05** | Buttonless → Bootloader 广播 | Secure DFU Service 图标 | P3 | `13` §2.2.2 Thingy52 |
| 6 | **DFU-E-06** | 传输进度 | Log + 可能新 DFU Tab | P3 | ISSUE#204 |
| 7 | **DFU-E-07** | McuMgr 选 `.bin` | Log McuMgr 字样 | P3 | `13` §2.3 |
| 8 | **DFU-E-08** | 换固件后 GATT 仍旧 | Connection ⋮ Refresh | P2 若做 GATT | CM-06 |

### 4.3 DFU 流程内选项（非 Settings）

| ID | 选项 | 默认 | 证据 |
| --- | --- | --- | --- |
| DFU-OPT-01 | **Keep bond** | ON | Toolbox ISSUE#44 |
| DFU-OPT-02 | Disable resume (Secure) | — | REL-4.24.2 |
| DFU-OPT-03 | Force scan for bootloader (Legacy) | — | REL-4.24.2 |

### 4.4 DFU 仍未知（Play 录屏待补）

| 项 | 交叉结论 | 证据 |
| --- | --- | --- |
| SUIT 逐步 confirm 对话框 | PARTIAL | `21` §2.3 |
| McuManager mode 主 App UI | **无**（Tests XML / Device Manager） | `21` RESOLVED 否定 |
| 独立 Start 按钮 vs 选文件即开始 | PARTIAL | `21` |
| DFU 默认路径 Settings | STILL_UNKNOWN | `21` |

---

## 5. Macros — 28 操作全量摘要

> **完整逐步语义**：`.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md`

### 5.1 执行壳（MAC-UI-*）

| ID | 控件/行为 | YoWire 映射 | 优先级 |
| --- | --- | --- | --- |
| MAC-UI-01 | 红 FAB → Macros Sheet | C 工具栏「Macros」 | P3 |
| MAC-UI-02 | Tutorial 文件夹 3 示例 | 实验室 Sample | P3 |
| MAC-UI-03 | XML 导入/录制 | ⚙·命令与面板 导入 | P3 |
| MAC-UI-04 | 兼容性 Banner | 服务不匹配提示 | P2 |
| MAC-UI-05 | **Step Over / Skip / Run / Loop** | 步骤执行 UI | P3 |
| MAC-UI-06 | 灰→**蓝**/失败**红**/assert **橙三角** | 同语义 | P1 assert UI |
| MAC-UI-07 | 宏图标 `icon=` 共 **42** 个 | Panel 图标 token 子集 | P2 |

### 5.2 Client 操作（12 tag）

| # | Tag | 一步语义摘要 | YoWire |
| ---: | --- | --- | --- |
| 1 | `read` | Read char → Log + 树更新 | P3 / P1 单命令 |
| 2 | `read-descriptor` | Read desc | P3 |
| 3 | `write` | 自动 Write Dialog 等效 | P1 收藏 |
| 4 | `write-descriptor` | CCCD 等 | P3 |
| 5 | `begin-reliable-write` | RW 开始 | P3 |
| 6 | `execute-reliable-write` | RW 提交 | P3 |
| 7 | `abort-reliable-write` | RW 回滚 | P3 |
| 8 | `wait-for-notification` | 阻塞至 notify | P2 |
| 9 | `wait-for-indication` | 阻塞至 indicate | P2 |
| 10 | `sleep-if` | 条件满足即结束 | P3 |
| 11 | `sleep-until` | 值相等即结束 | P3 |
| 12 | `unlock-eddystone` | Eddystone 解锁写 | P3 |

### 5.3 Server 操作（9 tag）

| # | Tag | 一步语义摘要 | 依赖 |
| ---: | --- | --- | --- |
| 1 | `wait-for-read` | 阻塞远端 Read | GATT Server 配置 |
| 2 | `wait-for-read-descriptor` | 阻塞远端 Read desc | 同上 |
| 3 | `wait-for-write` | 阻塞 + assert-value | 同上 |
| 4 | `wait-for-write-descriptor` | 同上 | 同上 |
| 5 | `wait-for-execute-reliable-write` | 等 Execute/Abort | 同上 |
| 6 | `set-value` | 本地 char 值更新 | 同上 |
| 7 | `set-descriptor-value` | 本地 desc 值更新 | 同上 |
| 8 | `send-notification` | 推 Notify 至远端 | 同上 |
| 9 | `send-indication` | 推 Indicate | 同上 |

**Tutorial #3 路径**：Configure GATT Server → Sample configuration → Macro #3（`11` §3）。

### 5.4 Other 操作（7 tag）

| # | Tag | 平台约束 | YoWire 优先级 |
| ---: | --- | --- | --- |
| 1 | `sleep` | 纯等待 ms | P3 |
| 2 | `read-rssi` | 需已连接 | P2 |
| 3 | `request-mtu` | MTU 23–517 | P1（连接菜单已有） |
| 4 | `request-connection-priority` | Android 5+ | P1 |
| 5 | `read-phy` | Android 8+ | P1 |
| 6 | `set-preferred-phy` | LE 1M/2M/CODED S2/S8 | P1 |
| 7 | `wait-for-phy-update` | 阻塞 PHY 变更 | P2 |

### 5.5 Assert 树（加载期 / Step 后）

| 节点 | 检查时机 | UI 反馈 |
| --- | --- | --- |
| `assert-server-service` | 宏加载 | Banner 宏不可用 |
| `assert-service` | 宏加载 | 远端缺 service |
| `assert-characteristic` + property | 加载 | MANDATORY/OPTIONAL/EXCLUDED |
| `assert-descriptor` / `assert-cccd` | 加载 | — |
| `assert-value` | Step Over 后 | **橙三角**（非红失败） |

---

## 6. Automated Tests — 27 操作（TEST-*）

| 维度 | Macros | Automated Tests |
| --- | --- | --- |
| 入口 | 连接后 FAB Sheet | **无 in-app UI**；PC test.bat/sh + ADB |
| XML 根 | `<macro>` | `<test-suite>` + `<test>` |
| 需已连接 | **是** | **否**（可 scan/connect/dfu） |
| 操作数 | 28 tag | 27 tag |

**仅 Tests（11 tag）**：`scan`, `scan-for`, `connect`, `discover-services`, `refresh`, `disconnect`, `bond`, `unbond`, `assert-notification`, **`dfu`**, **`mcu`**

**YoWire**：不做 ADB Tests UI；架构层可预留 Test XML 导入（P3）。  
**证据**：`13` §3 · `01-v2` §6

---

## 7. Scanner 实验室功能（LAB-SCAN-*）

| ID | 功能 | 来源 ID | YoWire | 证据 |
| --- | --- | --- | --- | --- |
| LAB-SCAN-01 | TIMELINE 多设备广播对比 | S-13 | P3 | `08` §1.6 |
| LAB-SCAN-02 | 长按多选 + Assign name | S-13 | P3 | `08` |
| LAB-SCAN-03 | Export avg advertising | S-13 | P3 | `08` |
| LAB-SCAN-04 | RSSI 多选曲线 + CSV | S-11~12 | P1–P2 | `08` §1.5 |
| LAB-SCAN-05 | 第二 Connection Tab 同设备 | CM-14 | P2 宽屏双 pane | `21` PARTIAL |

---

## 8. YoWire 实验室 IA 草案

```text
蓝牙 → A 栏「实验室」（专家模式门控）
├── 广播模拟（Advertiser ADV-*）
├── GATT Server 配置（GSRV-*）
├── 固件升级向导（DFU-*）— P3 隐藏或「即将推出」
└── Macro 教程 / XML 管理（MAC-*）— 与 ⚙·命令与面板 联动
```

| 原则 | 说明 |
| --- | --- |
| 门控 | 轻量模式隐藏实验室 Nav |
| 日志 | 实验室操作仍写入 SessionLog |
| 不复制 Device Manager | SUIT/McuMgr 完整 FOTA 仅文档引用 |

---

## 9. 与主路径清单交叉引用

| 实验室 ID | 主清单引用 |
| --- | --- |
| S-09 CLONE | `01-BLE-GATT` §3.1 S-09 |
| CM-13 Clone services | `01-BLE-GATT` §5.3 |
| SET-CONN-08 | `01-BLE-GATT` §6.1 |
| Macro write/read | `01-BLE-GATT` §7 · BT-GATT-14/15 |

---

## 10. 证据索引

| 键 | 路径 |
| --- | --- |
| nRF-01 | `.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` |
| nRF-08 | `.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` §4 |
| nRF-11 | `.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md` |
| nRF-13 | `.research/feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md` |
| nRF-21 | `.research/feature-inventory/21-nRF-Connect-UNKNOWN项交叉验证-v2.md` |
| GAP-22 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` §1 · §8.4 |
| Nordic root README | `.research/reference-apps/nRF-Connect-docs/README.md` |
| Thingy52 DFU | Nordic Thingy52 dfu_connect.html（`13` 引用） |

---

## 12. DFU 四协议 — Nordic 官方文档 URL 与参数

> **证据**：`13` §2 · Nordic GitHub · NCS 文档 · Android-DFU-Library

### 12.1 协议 × 文档 URL 对照

| DFU-ID | 协议 | 官方文档 / 仓库 URL | 包/文件类型 | nRF Connect UI 入口 | YoWire |
| --- | --- | --- | --- | --- | --- |
| **DFU-01** | **Legacy DFU** | [Android-DFU-Library README](https://github.com/NordicSemiconductor/Android-DFU-Library) · [nRF5 SDK DFU](https://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/examples_bootloader_dfu.html) | ZIP（manifest+bin+dat）或分文件 bin+init .dat | 顶栏 DFU 图标 → Distribution ZIP | **P3** |
| **DFU-02** | **Secure DFU** | [Secure DFU Bootloader](https://infocenter.nordicsemi.com/topic/sdk_nrf5_v17.1.0/lib_bootloader.html) · [Init packet README](https://github.com/NordicSemiconductor/Android-DFU-Library/blob/main/init%20packet%20README.md) | 签名 ZIP；Buttonless UUID `8e400001-…` | 同 DFU-01 + GATT Buttonless 图标 | **P3** |
| **DFU-03** | **McuManager (SMP)** | [McuManager Android](https://github.com/nrfconnect/sdk-nrf/blob/main/doc/nrf/app_dev/device_guides/nrf_desktop/dfu_mcumgr.rst) · [SMP spec](https://docs.zephyrproject.org/latest/services/device_mgmt/smp_protocol.html) | 裸 `.bin`（非 Distribution ZIP） | DFU 图标 → 选 bin；Log「McuMgr」 | **P3** 轻量 |
| **DFU-04** | **SUIT over SMP** | [NCS SUIT](https://docs.nordicsemi.com/bundle/ncs-latest/page/nrf/app_dev/device_guides/working_with_nrf/nrf54h/developing/ug_nrf54h_suit.html) · REL-4.29.1 | envelope / 多镜像 **[UNKNOWN 扩展名]** | 仍用 DFU 图标 **[PARTIAL]** | **P3** 首期不做 |

### 12.2 DFU 流程选项与 Nordic 交叉引用

| OPT-ID | 选项 | 默认 | Nordic 证据 URL / Issue |
| --- | --- | --- | --- |
| DFU-OPT-01 | Keep bond | ON | [Toolbox ISSUE#44](https://github.com/NordicSemiconductor/Android-nRF-Toolbox/issues/44) |
| DFU-OPT-02 | Disable resume (Secure) | — | REL-4.24.2 release notes |
| DFU-OPT-03 | Force scan bootloader (Legacy) | — | REL-4.24.2 |
| DFU-OPT-04 | Experimental Buttonless UUID | flag | [ISSUE#212](https://github.com/NordicSemiconductor/Android-nRF-Connect/issues/212) |
| DFU-OPT-05 | Multi-image (nRF5340) | ZIP 内多镜像 | REL-4.25.0 |

### 12.3 McuManager Tests XML 参数（`<mcu>` tag）

| 属性 | 取值 | 说明 | 证据 |
| --- | --- | --- | --- |
| `file` | `.bin` 路径 | 固件文件 | Automated-tests README |
| `mode` | TEST_AND_CONFIRM / TEST_ONLY / CONFIRM_ONLY / NONE | FOTA 模式 | 4.28.0+ |
| `swap-time` | ms | 交换时间 | PR#209 |
| `number-of-buffers` | int | 传输缓冲 | 同上 |
| `memory-alignment` | int | 对齐 | 同上 |
| `erase-app-storage` | bool | 擦除应用存储 | 同上 |

**Device Manager 边界 URL**：[nRF Connect Device Manager Play](https://play.google.com/store/apps/details?id=no.nordicsemi.android.nrfconnectdevicemanager) — Shell/Stats/完整 Image 管理；YoWire 不复制。

---

## 13. Macros — 28 操作 FULL 表（XML tag + 参数）

> **证据**：`.research/reference-apps/nRF-Connect-docs/Macros-README.md` 489 行 · `11-nRF-Connect-Macros-28操作逐步流程-v2.md`

### 13.1 Client 操作（12 tag）

| # | XML tag | 必需属性 | 可选属性 | 一步语义 | 阻塞 | YoWire |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | `read` | service-uuid, char-uuid | instance-id, timeout, target | Read char → Log+树 | 否 | P3 / P1 收藏 |
| 2 | `read-descriptor` | desc-uuid, service, char | instance-id | Read desc | 否 | P3 |
| 3 | `write` | service, char, value/value-string | type=WWR/WWOR | 自动 Write | 否 | P1 |
| 4 | `write-descriptor` | desc-uuid, value | service, char | 写 CCCD 等 | 否 | P3 |
| 5 | `begin-reliable-write` | — | — | RW Begin | 否 | P3 |
| 6 | `execute-reliable-write` | — | timeout | RW Execute | 否 | P3 |
| 7 | `abort-reliable-write` | — | — | RW Abort | 否 | P3 |
| 8 | `wait-for-notification` | service, char | assert-value 子节点 | 阻塞至 notify | **是** | P2 |
| 9 | `wait-for-indication` | service, char | 同左 | 阻塞至 indicate | **是** | P2 |
| 10 | `sleep-if` | 条件 | server=true | 条件满足即结束 | 条件 | P3 |
| 11 | `sleep-until` | 期望值 | — | 值相等即结束 | 条件 | P3 |
| 12 | `unlock-eddystone` | Eddystone 上下文 | — | 解锁写 | 否 | P3 |

### 13.2 Server 操作（9 tag）

| # | XML tag | 前置 | 一步语义 | YoWire |
| ---: | --- | --- | --- | --- |
| 1 | `wait-for-read` | GATT Server 配置 + SERVER Tab | 阻塞远端 Read | P3 |
| 2 | `wait-for-read-descriptor` | 同上 | 阻塞远端 Read desc | P3 |
| 3 | `wait-for-write` | 同上 | 阻塞 + assert-value | P3 |
| 4 | `wait-for-write-descriptor` | 同上 | 阻塞 + assert-value | P3 |
| 5 | `wait-for-execute-reliable-write` | 同上 | 等 Execute/Abort | P3 |
| 6 | `set-value` | Server char | 本地值更新 | P3 |
| 7 | `set-descriptor-value` | Server desc | 本地 desc 更新 | P3 |
| 8 | `send-notification` | Notify 属性 | 推 Notify 至远端 | P3 |
| 9 | `send-indication` | Indicate 属性 | 推 Indicate | P3 |

### 13.3 Other 操作（7 tag）

| # | XML tag | 参数 | 平台 | YoWire 优先级 |
| ---: | --- | --- | --- | --- |
| 1 | `sleep` | timeout ms | — | P3 |
| 2 | `read-rssi` | assert-value -50+ | 已连接 | P2 |
| 3 | `request-mtu` | value 23–517 | Android 5+ | P1 |
| 4 | `request-connection-priority` | LOW/BALANCED/HIGH | Android 5+ | P1 |
| 5 | `read-phy` | assert tx/rx | Android 8+ | P1 |
| 6 | `set-preferred-phy` | LE_1M/2M/CODED, option S2/S8 | Android 8+ | P1 |
| 7 | `wait-for-phy-update` | assert PHY | Android 8+ | P2 |

### 13.4 Assert 树节点（加载期 / Step 后）

| XML 节点 | 检查时机 | requirement 枚举 | UI |
| --- | --- | --- | --- |
| `assert-server-service` | 宏加载 | — | Banner 宏不可用 |
| `assert-service` | 宏加载 | — | 缺 service |
| `assert-characteristic` | 加载 | MANDATORY/OPTIONAL/EXCLUDED | — |
| `property` | 加载 | NOTIFY/READ/WRITE/… | — |
| `assert-descriptor` / `assert-cccd` | 加载 | — | — |
| `assert-value` | Step Over 后 | expected 变体 | **橙三角** |

**宏根节点**：`<macro name= icon=>` — `icon=` 共 **42** 枚举（LEFT, PLAY, NORDIC, EDDYSTONE, NUMBER_1…9 等）。

---

## 14. Advertiser 全量功能 ID 扩展（ADV-*）

| ID | 功能 | nRF UI 逐步 | 4.29+ 增量 | YoWire 优先级 | 证据 |
| --- | --- | --- | --- | --- | --- |
| ADV-01 | Tab 入口 | 底部 Tab 第三项 | — | P2 | `08` §4.1 |
| ADV-02 | 历史包列表 | 模拟他机 AD | — | P2 | `08` §4.1.1 |
| ADV-03 | FAB + 新建 | 广播包编辑器 | — | P2 | `08` §4.1.2 |
| ADV-04 | 笔 → Complete Local Name | 系统级名称 | — | P2 | `08` §4.1.3 |
| ADV-05 | Start/Stop | 本机广播开关 | — | P2 | `08` §4.1.4 |
| ADV-06 | Discoverable flag | 编辑器 Switch | ✓ | P2 | REL-4.29.1 |
| ADV-07 | Service Solicitation UUID | 编辑器字段 | ✓ | P2 | REL-4.29.1 |
| ADV-08 | CLONE from Scanner | S-09 链 | — | P3 | `01-v2` |
| ADV-09 | Physical Web OPEN | S-10 | — | P3 不做 | `01-v2` |
| ADV-10 | Eddystone/iBeacon 预设 | 产品页解析 | — | P3 | root README |
| **ADV-11** | AD 结构编辑 | 按 AD type 增删 | — | P2 | documentation README |
| **ADV-12** | TX Power / Interval | 广播参数 | — | P2 | 专家 |
| **ADV-13** | 多包轮换 | 历史列表切换 | — | P3 | — |
| **ADV-14** | Manufacturer Data 编辑 | HEX 字段 | — | P2 | YoWire Mask 联动 |

---

## 15. GATT Server 全量功能 ID 扩展（GSRV-*）

| ID | 功能 | nRF UI | 预设/约束 | YoWire | 证据 |
| --- | --- | --- | --- | --- | --- |
| GSRV-01 | Drawer 入口 | ☰ Configure GATT Server | — | P2 | `08` §4.2 |
| GSRV-02 | Dropdown | 选配置/New/Import/Disable | — | P2–P3 | `08` §4.2.2 |
| GSRV-03 | Import XML | Storage 权限 | — | P3 | `01-v2` |
| GSRV-04 | Share/Export XML | Android Share | — | P3 | `21` DZ-68849 |
| GSRV-05 | ADD SERVICE 预设 | Custom + Link Loss + Immediate Alert + Current Time + Heart Rate | **5 预设** | P2 | `01-v2` 统计 |
| GSRV-06 | ADD CHARACTERISTIC | UUID + 属性 R/W/N/I | — | P2 | `08` §4.2.4 |
| GSRV-07 | ADD DESCRIPTOR | CCCD/User Desc | — | P2 | 同上 |
| GSRV-08 | Sample configuration | Macros Tutorial #3 | — | P3 | `11` §3 |
| GSRV-09 | SERVER Tab 镜像 | 连接后远端读写 Log | 每连接独立副本 | P2 | `08` §3.4 |
| GSRV-10 | Show incoming connections | Settings Switch 默认 ON | SET-CONN-08 | P2 | ISSUE#21/89 |
| GSRV-11 | Clone services CM-13 | 远端→本地 DB | — | P3 | ISSUE#13 |
| **GSRV-12** | Char 初始值 | 编辑器 default value | — | P2 | — |
| **GSRV-13** | Permissions | Read/Write 权限 | — | P2 | — |
| **GSRV-14** | 多配置切换 | Dropdown 切换 active | — | P2 | — |
| **GSRV-15** | Disable all | 关闭 Server 广播 GATT | — | P2 | Dropdown Disable |

**GSRV 预设服务 UUID（SIG）**：

| 预设名 | Service UUID（摘要） |
| --- | --- |
| Link Loss | `0x1803` |
| Immediate Alert | `0x1802` |
| Current Time | `0x1805` |
| Heart Rate | `0x180D` |
| Custom | 用户 UUID |

---

## 16. 架构缝约定（2026-07-23）

> 总册见 [`00-蓝牙功能总清单与优先级矩阵.md`](00-蓝牙功能总清单与优先级矩阵.md)。  
> **v1 不实现**本分册能力；仅在架构中预留：

| 缝 | 目录/类型预留 | 说明 |
| --- | --- | --- |
| Advertiser | `ui/lab/` + `BluetoothSessionKind.ADVERTISER` | Kit `ble` 广播 API 可用，入口专家门控 |
| GATT Server | `ui/lab/` + SessionKind | `createGattServer` 预留 |
| DFU | 文档引用 Nordic；无 in-app 引擎 | P3 |
| Macros 28-tag | 可挂 GattOperationQueue 步骤编排 | P3；P1 仅单命令收藏 |
| Automated Tests | 无 in-app UI | P3 |

`features/bluetooth/Index.ets` **不导出**实验室实现符号，避免误用。

---

## 17. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：Advertiser/GATT Server/DFU/Macros 28/Tests 27 全 ID 与 P2/P3 分级 |
| 2026-07-03 | 深扩：§12 DFU Nordic URL、§13 Macros 28 FULL、§14 ADV、§15 GSRV 扩展 |
| 2026-07-23 | §16 架构缝约定：v1 不实现、目录预留 |
