# 01-BLE-GATT 全量功能清单

> **状态：深研草稿，未定稿。**  
> **竞品基准**：Nordic nRF Connect for Android 4.29.x（documentation 级穷尽 + Release/Issue 交叉验证）。  
> **YoWire 映射**：PRD `03-蓝牙模块PRD.md` §7–§8 · Gap 矩阵 `22-…` §1 · IA `00-UI架构修正`  
> **证据链**：`.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` · `08-Scanner到Connection逐步流程-v2.md` · `09-Settings与ReleaseNotes-v2.md` · `13-DFU与Connection菜单-v2.md` · `21-UNKNOWN项交叉验证-v2.md`

---

## 1. 统计与范围

| 维度 | nRF Connect | YoWire 首期承诺 |
| --- | --- | --- |
| 一级 Tab/入口 | Scanner / Bonded / Advertiser / Drawer GATT Server / Connection | BLE GATT 为蓝牙三入口之一 |
| Scanner 独立功能点 | 14 项（S-01~S-14）+ Filter 九维 | P0 核心 + P1 深度 |
| Connection ⋮ 菜单项 | 14+ 项（CM-01~CM-14） | P0/P1 分层 |
| Settings 项 | Connectivity 4 + Scanner 9 + Filter 9 | 蓝牙 ⚙ 分组映射 |
| Macros 操作 tag | **28** 种 | P3 完整引擎；P1 单命令收藏 |
| Automated Tests tag | **27** 种 | P3 架构预留（无 ADB UI） |

**不在本文**：Advertiser / GATT Server / DFU 详见 `04-BLE实验室与高级功能清单.md`。

---

## 2. 应用级能力（APP-*）

| ID | 功能 | nRF 行为 | YoWire 优先级 | YoWire 落点 | 证据 |
| --- | --- | --- | --- | --- | --- |
| APP-01 | Location 权限（扫描） | Marshmallow+ 必需 | **P0** | BLE 扫描页 Banner + 引导 | `08` §0.2 · `09` §5 |
| APP-02 | Location Service 开关 | 关闭则扫描不可用 | **P0** | 同左 + 跳转系统设置 | `08` §0.3 |
| APP-03 | Storage 权限 | Log/Macro/GATT XML 导出 | **P1** | 导出时按需申请 | `01-v2` §1 |
| APP-04 | 多连接并行 | 扫描+广播+多 Connection | **P2** | 连接管理器；HarmonyOS 平台验证 | `01-v2` §1 |
| APP-05 | nRF Logger 集成 | 独立 App 持久化 | **—** | 不依赖；自有 SessionLog | `21` §1.2 否定 Logger Settings |
| APP-06 | Device Information 抽屉 | 主机 BLE 能力 flags | **P2** | 蓝牙 ⚙·关于/能力 或 Drawer 等价 | `21` DR-01 PARTIAL |
| APP-07 | Nearby 权限（Android 12+） | 扫描/connect 权限模型 | **P0** | HarmonyOS 蓝牙权限对照清单 | `09` §4 REL-4.25.0 |

---

## 3. Scanner Tab（S-*）

### 3.1 扫描列表核心

| ID | 功能 | nRF UI/行为 | YoWire 优先级 | YoWire UI 落点 | PRD 对照 | 证据 |
| --- | --- | --- | --- | --- | --- | --- |
| **S-01** | 实时 BLE 列表 + RSSI | 默认持续扫描；行：名/MAC/RSSI/CONNECT | **P0** | B 栏列表；C 栏选中详情（非 B 内嵌） | BT-GATT-01 | `01-v2` §2 · `08` §1.1 |
| **S-02** | **Filter** 多维 | 名称、MAC、广播 HEX、RSSI、**排除设备类型** | **P0**（Mask 为 PRD 必须） | ≥600vp Filter Sheet；预设存 **蓝牙 ⚙·扫描** | BT-GATT-02 | `01-v2` §2 · `08` §1.2 |
| **S-03** | **Only Favorites** | Filter 内 Switch | **P1** | Filter 维 + B Segmented「收藏」 | BT-GATT-13 | `01-v2` §2 · `09` SET-FIL-09 |
| **S-04** | **CONNECT** | O+ 仅 connectable 显示；旧版 30s 超时 | **P0** | B 行 CONNECT；**连接前 stopScan** | BT-GATT-03 | `08` §1.4 |
| **S-05** | CONNECT **⋮** 子菜单 | autoConnect、preferred PHY、bond/remove bond | **P1** | ≥600vp Popup/Connect Sheet | BT-GATT-08 | `01-v2` §2 · `08` §1.4 |
| **S-06** | 行展开 + **蓝色标题**解析器 | Int/Float/Temperature/Pressure… | **P1** | C 栏广播详情 / B 展开二级 | BT-GATT-01 扩展 | `08` §1.3 |
| **S-07** | **RAW** AD 结构 | Dialog 或内嵌 HEX 按 AD 记录拆分 | **P0** | 广播详情「原始 HEX」 | BT-GATT-01 · §7.3 | `08` §1.3 |
| **S-08** | **MORE** 包历史 + 数值曲线 | 包变化、广播间隔；数值 Tab 时间曲线 | **P2** | 独立图表页或 C Sub-Tab | BT-GATT-12 | `01-v2` §2 · `08` §1.3 |
| **S-09** | **CLONE** → Advertiser | Lollipop+ 克隆到本机广播 | **P3** | 专家·BLE 实验室 | BT-GATT-16 | `01-v2` §2 · `04` |
| **S-10** | **OPEN** Physical Web URL | 广播含 URL 时打开浏览器 | **P3** | 不纳入 v1 | — | `01-v2` §2 |
| **S-11** | **RSSI graph** | 右滑或菜单；平均 RSSI 曲线 | **P1** | C Sub-Tab 或全屏图 | — | `08` §1.5 |
| **S-12** | RSSI 图 **CSV/EXCEL 导出** | root README | **P1** | 导出 → **蓝牙 ⚙·会话** | BT-GATT-19 | `01-v2` §2 |
| **S-13** | 长按多选批量 | 命名、导出平均广播、**TIMELINE**（≥2 设备） | **P3** | 实验室 / 后续 | BT-GATT-16 | `08` §1.6 |
| **S-14** | Settings→Scanner 五项 | 见 §6 SET-SCAN-* | **P1** | **蓝牙 ⚙·扫描** | — | `01-v2` §2 · `09` |

### 3.2 Filter 子项（SET-FIL-*，Filter Sheet 内）

| ID | 过滤项 | nRF 行为 | YoWire 优先级 | PRD 增量 | 证据 |
| --- | --- | --- | --- | --- | --- |
| SET-FIL-01 | 名称/地址部分匹配 | TextField 部分匹配 | **P0** | 含/精确匹配 | `09` §3 |
| SET-FIL-02 | 广播数据 HEX 过滤 | AD payload 子串 | **P0** | — | `09` §3 |
| SET-FIL-03 | RSSI 下限 | Slider/数值 | **P0** | 最小 RSSI | `09` §3 |
| SET-FIL-04 | 排除 Apple | Checkbox | **P1** | 专家 Filter 预设 | `09` REL-4.25.3 |
| SET-FIL-05 | 排除 Microsoft | Checkbox | **P1** | 同左 | `09` |
| SET-FIL-06 | 排除 Google | Checkbox | **P1** | 同左 | `09` |
| SET-FIL-07 | 排除 Samsung | Checkbox | **P1** | 同左 | `09` |
| SET-FIL-08 | 排除 Mesh/Beacon/ENS | Checkbox 组 | **P1** | 同左 | `09` |
| SET-FIL-09 | Only Favorites | Switch | **P1** | 是否收藏 | `09` |
| **SET-FIL-10** | **Manufacturer Data Mask** | nRF 无等价 Mask UI | **P0** | **PRD 必须**，YoWire 增值 | `22` BT-GATT-02 |
| SET-FIL-11 | Service UUID 过滤 | 文档/社区 | **P0** | PRD §7.2 | `03-蓝牙PRD` §7.2 |
| SET-FIL-12 | Manufacturer ID | — | **P0** | PRD §7.2 | `03-蓝牙PRD` §7.2 |

### 3.3 Scanner 逐步流程摘要（YoWire 对照）

| 步 | nRF 动作 | YoWire 必须行为 | 证据 |
| --- | --- | --- | --- |
| 1.1 | 点 Scanner Tab，默认扫描 | B 栏进入即扫或显式 SCAN | `08` §1.1 |
| 1.2 | Filter 配置 → Back | Filter Sheet Apply/Reset/Close | `08` §1.2 |
| 1.3 | 点行展开 AD | C 栏或 Sheet 广播详情 | `08` §1.3 |
| 1.4 | CONNECT / CONNECT⋮ | **stopScan 后连接** | `08` §1.4 · PRD |
| 1.5 | RSSI 图/导出 | P1 纳入 | `08` §1.5 |

---

## 4. Bonded Tab（B-*）

| ID | 功能 | nRF 行为 | YoWire 优先级 | YoWire 落点 | 证据 |
| --- | --- | --- | --- | --- | --- |
| B-01 | 系统 bond 列表 | 无 Location 要求；无实时广播 | **P1** | B Segmented「已绑定」 | `08` §2 |
| B-02 | 列表项名/MAC | 系统缓存 | **P1** | 同 Scanner 行样式 | `08` §2.2 |
| B-03 | CONNECT / ⋮ | 同 Scanner | **P1** | 共用 Connection 页 | `08` §2.3 |
| B-04 | 连接成功 → Connection | 同路径 | **P0** | 同 GATT 连接流 | `08` §2.4 |

**YoWire 差分**：HarmonyOS 虚拟 MAC 文案；bond 与「收藏」分轨（PRD §10）。

---

## 5. Connection — CLIENT（C-* / CM-* / GATT-*）

### 5.1 进入与会话壳

| ID | 功能 | nRF 行为 | YoWire 优先级 | YoWire 落点 | 证据 |
| --- | --- | --- | --- | --- | --- |
| C-01 | 连接成功顶栏 | 设备名、Disconnect、⋮ | **P0** | C 顶栏 | `08` §3.1 |
| C-02 | Auto discover（默认 ON） | 自动 GATT discover | **P0** | 阶段条步骤 2；可 ⚙ 关闭 | SET-CONN-01 |
| C-03 | Tab：CLIENT / SERVER | 4.29+ 第二 CLIENT Tab 同设备 | **P2** | 宽屏双 pane 优先于双 Tab | `08` §3.1 · `21` §1.3 |
| C-04 | 右滑 / Show log → Log pane | 时间戳事件流 | **P0** | C Log Tab/pane 40% | BT-GATT-10 |
| C-05 | 红 FAB → Macros | Sheet | **P3** | ⚙·命令与面板；C 工具栏 Macros 入口 P2 | `08` §3.1 |

### 5.2 GATT 树操作（GATT-*）

| ID | 操作 | nRF UI | YoWire 优先级 | PRD | 证据 |
| --- | --- | --- | --- | --- | --- |
| GATT-01 | Service 展开 | UUID + Known 名 | **P0** | §8.2 | `08` §3.2 |
| GATT-02 | Characteristic 属性图标 | Read/Write/Notify/Indicate | **P0** | §8.3 | `08` §3.2 |
| GATT-03 | **Read** | 行内更新 + Log | **P0** | §8.3 | `08` §3.2.3 |
| GATT-04 | **Write**（WWR/WWOR） | Write Dialog；Big Endian 4.25.4+ | **P0** | §8.3 | `08` §3.2.4 · WR-01 |
| GATT-05 | **Notify** | CCCD 写入 + 持续 Log | **P0** | §8.3 | `08` §3.2.5 |
| GATT-06 | **Indicate** | 同 Notify | **P0** | §8.3 | `08` §3.2.5 |
| GATT-07 | Descriptor Read/Write | 同 char 图标集 | **P0** | §8.3 CCCD | `08` §3.2.6 |
| GATT-08 | **Reliable Write** Begin/Execute/Abort | ⋮ 子菜单 + Prepare 队列 | **P1** | C ⋮ 或 **蓝牙 ⚙·BLE 高级** | BT-GATT-05 · CM-03~05 |
| GATT-09 | 命令收藏（Characteristic） | Macros read/write 子集 | **P1** | **蓝牙 ⚙·命令与面板** | BT-GATT-14 |
| GATT-10 | Known UUID 字典 | Parse known UUIDs ON | **P1** | C 工具栏 Toggle | BT-GATT-09 · CM-02 |
| GATT-11 | 纯 HEX Dialog | Parse OFF | **P1** | 同 Toggle OFF | CM-02 |
| GATT-12 | UUID 长按复制 | nRF 无 GATT 树 Copy | **P1** | Log 解析 + 长按复制 | `21` §5 |

### 5.3 Connection 顶栏 ⋮ 菜单（CM-*）

| ID | 菜单项 | 类型 | YoWire 优先级 | YoWire 落点 | 证据 |
| --- | --- | --- | --- | --- | --- |
| **CM-01** | Show log | Action | **P0** | 同 C-04 | `13` §1.2 |
| **CM-02** | Parse known UUIDs | Toggle | **P1** | C 工具栏 | `13` · `21` |
| **CM-03** | Reliable Write → Begin | Action | **P1** | C ⋮ | `13` |
| **CM-04** | Reliable Write → Execute | Action | **P1** | C ⋮ | `13` |
| **CM-05** | Reliable Write → Abort | Action | **P1** | C ⋮；新连接自动 Abort 可 ⚙ | `13` · SET-CONN-02 |
| **CM-06** | Refresh services | Action | **P2** | C ⋮ 专家 | BT-GATT-11 · `13` |
| **CM-07** | Request MTU | Dialog 23–517 | **P0** | C 顶栏 MTU Chip + 请求 | BT-GATT-06 · `13` |
| **CM-08** | Request connection priority | LOW/BALANCED/HIGH | **P1** | 专家；平台降级说明 | BT-GATT-07 · `13` |
| **CM-09** | Read PHY | Action | **P1** | 专家 | BT-GATT-07 |
| **CM-10** | Set preferred PHY | tx/rx 1M/2M/CODED | **P1** | 专家 | BT-GATT-07 |
| **CM-11** | Bond | Action | **P1** | Connect Sheet / ⋮ | `13` INFER |
| **CM-12** | Remove bond | Action | **P1** | **仅 CONNECT ⋮**，非 Connection ⋮ | `21` §2.1 否定 |
| **CM-13** | Clone device's services | → GATT Server DB | **P3** | 实验室 | `13` · `04` |
| **CM-14** | Open second tab | 同设备双 Tab | **P2** | 840vp 双 pane | `21` PARTIAL |
| **CM-15** | Copy/Share（⋮ 级） | **不在 ⋮** | **P1** | Log pane 底栏 | `21` §2.1 |

### 5.4 Log pane（LOG-*）

| ID | 控件 | nRF 行为 | YoWire 优先级 | YoWire 落点 | 证据 |
| --- | --- | --- | --- | --- | --- |
| LOG-01 | **SAVE** | 导出文件；Storage | **P0** | 底栏 + **蓝牙 ⚙·会话** | `13` §1.3 |
| LOG-02 | **Clear (Trash)** | 清空当前 log | **P0** | 底栏 | `21` ISSUE#93 |
| LOG-03 | nRF Logger | 可选独立 App | **—** | SessionLog 后端 | `21` 否定 |
| LOG-04 | **Copy / Share / Save / Clear** 四图标 | 4.24.3 修复窄屏裁切 | **P1** | Log pane 底栏四动作 | `21` §2.2 |
| LOG-05 | Log level 过滤 | UI 过滤；导出仍全量 | **P2** | 专家 | `21` ISSUE#181 |

### 5.5 Write Dialog（WR-*）

| ID | 项 | YoWire 优先级 | 证据 |
| --- | --- | --- | --- |
| WR-01 | Big Endian 写 | **P1** | REL-4.25.4 · `13` §1.4 |

### 5.6 断开与多连接

| ID | 行为 | YoWire 优先级 | 证据 |
| --- | --- | --- | --- |
| C-06 | Disconnect 回扫描 | **P0** | `08` §3.5 |
| C-07 | 多设备独立 Connection 栈 | **P2** | `08` §3.5.2 |
| C-08 | RW 进行中断开自动 Abort | **P1** | ISSUE#145 · SET-CONN-02 |

---

## 6. Settings 映射（SET-*）

### 6.1 Connectivity（SET-CONN-*）

| ID | 设置项 | 默认 | YoWire 优先级 | 蓝牙 ⚙ 分组 | 证据 |
| --- | --- | --- | --- | --- | --- |
| SET-CONN-01 | Auto service discovery | ON | **P0** | **连接** | `09` §2 |
| SET-CONN-02 | Abort reliable write on new connection | OFF @4.25.2+ | **P1** | **BLE 高级** | `09` · `21` |
| SET-CONN-03 | Parse known UUIDs | 会话 Toggle（非 Settings） | **P1** | C 工具栏 | `09` Δ-5 |
| SET-CONN-06 | **Auto request maximum MTU** | Switch | **P1** | **连接** | `21` DZ-108836 |
| SET-CONN-07 | Prompt before saving log | PARTIAL/证据不足 | **—** | 暂不实现 | `21` |
| SET-CONN-08 | **Show incoming connections** | ON | **P2** | **BLE 高级** 实验室 | `21` ISSUE#21/89 |

### 6.2 Scanner（SET-SCAN-*）

| ID | 设置项 | YoWire 优先级 | 证据 |
| --- | --- | --- | --- |
| SET-SCAN-01 | Physical Layer (PHY) | **P1** | `09` · DZ-86964 灰显规则 |
| SET-SCAN-02 | Offloaded scan batching | **P1** | `09` 故障常见根因 |
| SET-SCAN-03 | Only connectable devices | **P1** | REL-4.25.0 |
| SET-SCAN-04 | Only Advertising Extension | **P2** 专家 | REL-4.25.0 |
| SET-SCAN-05 | Scan PHY Coded only | **P2** 专家 | REL-4.25.0 |
| SET-SCAN-06 | **Scanning mode** LOW/BALANCED/LOW_POWER | **P1** | `21` DZ-97953 |
| SET-SCAN-07 | **Continuous scanning** + 周期 | **P1–P2** | `21` DZ-77165 |
| SET-SCAN-09 | **Compatibility mode (PHY)** | **P2** | `21` DZ-60496 |
| SET-SCAN-10 | CSV export delimiter | **P2** | `21` DZ-77165 |

---

## 7. Macros — 28 操作 tag 摘要

> 完整逐步语义见 `11-nRF-Connect-Macros-28操作逐步流程-v2.md` · 实验室清单见 `04`。

| 分类 | Tag 列表 | 数量 | YoWire 优先级 |
| --- | --- | ---: | --- |
| **Client** | read, read-descriptor, write, write-descriptor, begin/execute/abort-reliable-write, wait-for-notification, wait-for-indication, sleep-if, sleep-until, unlock-eddystone | 12 | P3 全引擎；P1 单步收藏 |
| **Server** | wait-for-read, wait-for-read-descriptor, wait-for-write, wait-for-write-descriptor, wait-for-execute-reliable-write, set-value, set-descriptor-value, send-notification, send-indication | 9 | P3 |
| **Other** | sleep, read-rssi, request-mtu, request-connection-priority, read-phy, set-preferred-phy, wait-for-phy-update | 7 | P1 部分（MTU/PHY） |
| **Assert 树** | assert-server-service, assert-service, assert-value… | — | P2 步骤 UI 橙三角 |

**执行 UI**：Step Over / Skip / Run / Loop；灰→蓝/红；assert 失败橙三角。  
**YoWire**：编辑在 **蓝牙 ⚙·命令与面板 → Macro 步骤**；运行时 C 工具栏 Sheet（P2）。

---

## 8. Automated Tests — 27 操作（P3 架构预留）

| 仅 Tests（11） | scan, scan-for, connect, discover-services, refresh, disconnect, bond, unbond, assert-notification, **dfu**, **mcu** |
| --- | --- |
| 执行壳 | PC test.bat/sh + ADB；**无应用内 UI** |
| YoWire | 不做 ADB UI；架构层可预留 Test XML 导入 |

**证据**：`01-v2` §6 · `13` §3

---

## 9. YoWire PRD 需求 ID 全表映射

| PRD ID | 摘要 | 本清单 ID | Gap |
| --- | --- | --- | --- |
| BT-GATT-01 | 扫描列表字段+RAW | S-01, S-07, SET-FIL-* | P0 |
| BT-GATT-02 | Mask 过滤 | SET-FIL-10 | P0 |
| BT-GATT-03 | stopScan 后连接 | S-04 | P0 |
| BT-GATT-04 | GATT R/W/N/I/CCCD | GATT-01~07 | P0 |
| BT-GATT-05 | Reliable Write | GATT-08, CM-03~05 | P1 |
| BT-GATT-06 | MTU | CM-07, SET-CONN-06 | P0 |
| BT-GATT-07 | PHY/连接优先级 | CM-08~10 | P1 |
| BT-GATT-08 | CONNECT ⋮ | S-05 | P1 |
| BT-GATT-09 | Parse UUIDs | CM-02, GATT-10/11 | P1 |
| BT-GATT-10 | Log pane + 导出 | C-04, LOG-* | P0 |
| BT-GATT-11 | Refresh cache | CM-06 | P2 |
| BT-GATT-12 | Notify 曲线 | S-08 | P2 |
| BT-GATT-13 | 收藏/别名/持久化 | S-03, B-* | P1 |
| BT-GATT-14 | 命令收藏 | GATT-09 | P1 |
| BT-GATT-15 | Macros 步骤 | §7 | P3 |
| BT-GATT-16 | 实验室 | S-09, S-13 → `04` | P3 |
| BT-GATT-17 | DFU | → `04` | P3 |
| BT-GATT-18 | 840vp 三分栏 | UI 规范 | P1 布局 |
| BT-GATT-19 | 统一会话导出 | LOG-01 + ⚙·会话 | P0 |

---

## 10. 840vp 宽屏栏位（摘要）

| 栏 | 内容 | 硬约束 |
| --- | --- | --- |
| **A** | 模块 Nav：GATT / SPP / UART / 实验室 | 子 Nav 切换 |
| **B** | 扫描列表 + Segmented + ≤3 按钮 | `10-HarmonyOS-840vp-蓝牙三分栏` |
| **C** | GATT 树 60% + Log 40%；工具栏 ≤6 | 禁止第四 Inspector |

**证据**：`.research/feature-inventory/10-HarmonyOS-840vp-蓝牙模块三分栏线框-v2.md`

---

## 11. 逐步流程索引（完整步骤）

| 流程 | 文档 |
| --- | --- |
| Scanner → Filter → CONNECT → Connection | `08-nRF-Connect-Scanner到Connection逐步流程-v2.md` §1–§3 |
| GATT R/W/N + Reliable Write + Log | 同上 §3.2–§3.3 |
| Settings 交叉 | `09-nRF-Connect-Settings与ReleaseNotes-v2.md` |
| Connection ⋮ + DFU 边界 | `13-nRF-Connect-DFU与Connection菜单-v2.md` |
| UNKNOWN 判定 | `21-nRF-Connect-UNKNOWN项交叉验证-v2.md` |

---

## 12. 证据索引

| 键 | 路径 |
| --- | --- |
| nRF-01 | `.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` |
| nRF-08 | `.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` |
| nRF-09 | `.research/feature-inventory/09-nRF-Connect-Settings与ReleaseNotes-v2.md` |
| nRF-11 | `.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md` |
| nRF-13 | `.research/feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md` |
| nRF-21 | `.research/feature-inventory/21-nRF-Connect-UNKNOWN项交叉验证-v2.md` |
| GAP-22 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` §1 |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/03-蓝牙模块PRD.md` |
| Nordic DOC | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation |

---

## 13. Connection CLIENT — GATT 全量操作矩阵（GATT-OP-*）

> **证据**：Nordic `documentation/README.md` Connection 章 · `08` §3.2 · Bluetooth Core Spec Vol 3 Part G · Play Store 4.29.x 录屏交叉（Reliable Write / PHY / McuMgr 边界见 §14）。

### 13.1 Characteristic 级操作总表

| OP-ID | 操作 | nRF UI 入口 | ATT/GATT 语义 | Log 事件关键字 | YoWire 优先级 | YoWire UI 落点 | 失败/边界 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **GATT-OP-01** | **Read** | Char 行 Read 图标 | Read Request → Read Response | `Read` + UUID + value | **P0** | C 树行内值 + Log | GATT error → 红点 Toast |
| **GATT-OP-02** | **Write (WWR)** | Write 图标 → Dialog → Send | Write Request（需 Response） | `Write` type=WRITE_REQUEST | **P0** | Write Sheet；默认 WWR | 超 MTU-3 需分包或拒绝 |
| **GATT-OP-03** | **Write (WWOR)** | 同 Dialog；属性含 Write Without Response | Write Command（无 Response） | `Write` type=WRITE_COMMAND | **P0** | Write Sheet 类型切换 | 队列满 / 连接断开 |
| **GATT-OP-04** | **Notify 订阅** | Notify 图标（铃铛） | 写 CCCD `0x0001` + 使能 Notify | `Notification enabled` + 持续 `Notification received` | **P0** | C 树 Toggle + Log 流 | CCCD 只读 / 未 bonded 权限 |
| **GATT-OP-05** | **Indicate 订阅** | Indicate 图标 | 写 CCCD `0x0002` + 使能 Indicate | `Indication received`（含 ACK） | **P0** | 同 Notify；Indicate 需确认 | 与 Notify 互斥 CCCD 位 |
| **GATT-OP-06** | **Notify/Indicate 取消** | 再次点图标 | 写 CCCD `0x0000` | `Notification disabled` | **P0** | Toggle OFF | — |
| **GATT-OP-07** | **Reliable Write Prepare** | ⋮ RW→Begin 后 Write | Prepare Write Request/Response 队列 | `Prepare write` / verify | **P1** | C ⋮ + 状态条 | 新连接 Abort（SET-CONN-02） |
| **GATT-OP-08** | **Reliable Write Execute** | ⋮ RW→Execute | Execute Write Request | `Execute` | **P1** | C ⋮ | 无 Prepare 则失败 |
| **GATT-OP-09** | **Reliable Write Abort** | ⋮ RW→Abort | 回滚至 Begin 前 | `Abort` | **P1** | C ⋮ | 断开自动 Abort [ISSUE#145] |
| **GATT-OP-10** | **Long Write** | 大 payload Write | 自动分段 Prepare（非 RW 模式时平台行为） | 多段 Log | **P2** | 专家说明 | HarmonyOS 平台验证 |

### 13.2 Descriptor / CCCD 操作总表

| OP-ID | 目标 | nRF UI | 典型 UUID | YoWire 优先级 | 备注 |
| --- | --- | --- | --- | --- | --- |
| **GATT-OP-11** | **Read Descriptor** | Desc 行 Read | 任意（含 CCCD `2902`） | **P0** | Parse ON 时友好名 |
| **GATT-OP-12** | **Write Descriptor** | Desc 行 Write | CCCD / User Desc / Report Ref | **P0** | CCCD 写 `0100`/`0200`/`0000` |
| **GATT-OP-13** | **CCCD Read** | 同 GATT-OP-11 | `00002902-0000-1000-8000-00805f9b34fb` | **P0** | Bond 后可能缓存旧值 [Tests README] |
| **GATT-OP-14** | **CCCD Write Notify** | Notify 图标间接 | CCCD = `01 00` LE | **P0** | 与 GATT-OP-04 等价 UI |
| **GATT-OP-15** | **CCCD Write Indicate** | Indicate 图标间接 | CCCD = `02 00` LE | **P0** | 与 GATT-OP-05 等价 |
| **GATT-OP-16** | **Client Characteristic Configuration** | Macros `write-descriptor` | Tests `assert-cccd` | **P1** | 自动化断言 CCCD 默认 0 |

### 13.3 Write Dialog 字段与编码（WR-* 扩展）

| WR-ID | 字段 | nRF 行为 | YoWire 优先级 | 证据 |
| --- | --- | --- | --- | --- |
| WR-01 | **Big Endian** | 多字节整型大端写入 | **P1** | REL-4.25.4 |
| WR-02 | **value 字节** | HEX 或解析表单 | **P0** | CM-02 Parse 开关 |
| WR-03 | **type 选择** | WWR vs WWOR（属性允许时） | **P0** | Tests `<write type=` |
| WR-04 | **instance-id** | 同 UUID 多实例 | **P2** | Tests XML |
| WR-05 | **Write 后 Read 验证** | 手动再点 Read | **P1** | 命令收藏可 bundling |

### 13.4 树浏览与 UUID 交互（GATT-UI-*）

| ID | 交互 | nRF | YoWire |
| --- | --- | --- | --- |
| GATT-UI-01 | Service 折叠/展开 | UUID + Known 名 | C 树 Accordion |
| GATT-UI-02 | Char 属性图标条 | R/W/N/I/RW 图标 | 同左；色盲安全 |
| GATT-UI-03 | 长按 UUID 复制 | **无**（Log 可复制） | **P1** 长按复制 [21] |
| GATT-UI-04 | Known UUID Toggle | CM-02 | C 工具栏 Chip |
| GATT-UI-05 | 连接阶段条 | discover 进度 | P0 步骤 1–3 显式 |

---

## 14. Connection ⋮ 菜单 CM-01～CM-14 完整规格

> **证据**：`13-nRF-Connect-DFU与Connection菜单-v2.md` §1 · `21` 交叉验证 · `08` §3.2.7–3.2.10

| ID | 菜单项 | 类型 | 逐步 UI 行为 | Log/副作用 | YoWire 优先级 | YoWire 落点 | 平台/边界 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **CM-01** | Show log | Action | 右滑等价；打开 Log pane | — | **P0** | C Log Tab 40% | 窄屏四图标 [21] |
| **CM-02** | Parse known UUIDs | Toggle | OFF→纯 HEX Dialog；ON→SIG/厂商解析 | 影响后续 R/W 显示 | **P1** | C 工具栏 Toggle | 非 Settings 持久 |
| **CM-03** | Reliable Write → Begin | Action | 状态条「RW active」 | 后续 Write→Prepare | **P1** | C ⋮ 子菜单 | Android 4.3+ |
| **CM-04** | Reliable Write → Execute | Action | 提交队列 | Execute 成功/失败 Log | **P1** | C ⋮ | ≥1 Prepare |
| **CM-05** | Reliable Write → Abort | Action | 回滚 | Abort Log | **P1** | C ⋮ | 新连接可自动 Abort |
| **CM-06** | Refresh services | Action | 隐藏 `gatt.refresh()` + rediscover | 缓存清空 Log | **P2** | C ⋮ 专家 | DFU 后必用 |
| **CM-07** | Request MTU | Dialog+Action | 输入 23–517 → OK | `MTU changed` | **P0** | MTU Chip + Sheet | 每连接次数有限 |
| **CM-08** | Request connection priority | Submenu | LOW / BALANCED / HIGH | priority Log | **P1** | 专家 Sheet | ≤Android 8 假成功 |
| **CM-09** | Read PHY | Action | Log tx/rx PHY | `PHY read` | **P1** | 专家 | Android 8+ |
| **CM-10** | Set preferred PHY | Dialog | tx/rx 1M/2M/CODED + S2/S8 | `PHY updated` | **P1** | 专家 | 与 Scanner preferred PHY 不同语境 |
| **CM-11** | Bond | Action | 系统配对 UI | bond 事件 | **P1** | Connect Sheet / ⋮ | 已 bond 无 op |
| **CM-12** | Remove bond | Action | **CONNECT ⋮ 为主**；Connection ⋮ 重复 **[UNKNOWN]** | 可能断连 | **P1** | Connect Sheet 仅 | [21] 否定 Connection ⋮ |
| **CM-13** | Clone device's services | Action | 远端 GATT→本地 GATT Server DB | — | **P3** | 实验室 | 需 GSRV 配置 |
| **CM-14** | Open second tab | Action | 同设备第二 CLIENT Tab | 双 pane 独立 Log | **P2** | 840vp 双 pane 优先 | REL-4.29.1 |

**CM 菜单 YoWire 宽屏映射**：≥840vp 将 CM-07/08/09/10 收敛为 C 顶栏 Chip 组（≤6）；其余进 ⋮ Overflow。

---

## 15. Log pane — SAVE 导出路径与格式（LOG-* 扩展）

### 15.1 导出触发路径

| 路径 ID | 用户路径 | nRF UI | YoWire 等价 |
| --- | --- | --- | --- |
| LOG-P-01 | Connection → 右滑 Log → **SAVE** | 文件选择器 | C Log 底栏 Save |
| LOG-P-02 | Log 底栏 **Share** | Android Share Sheet | Share → 系统分享 |
| LOG-P-03 | Log 底栏 **Copy** | 剪贴板 | Copy 选中/全量 |
| LOG-P-04 | Log 底栏 **Clear** | Trash 清空 | Clear（不删 SessionLog 归档） |
| LOG-P-05 | 模块 ⚙ → **会话与日志** | nRF Logger 独立 App | YoWire SessionLog 列表导出 |

### 15.2 SAVE 文件语义

| 项 | nRF 行为 | YoWire 映射 | 证据 |
| --- | --- | --- | --- |
| 格式 | 纯文本时间戳行 | TXT 默认；CSV/JSON 在 ⚙·会话 | [DOC] README |
| 权限 | Storage（旧版） | 导出时按需申请 | APP-03 |
| 内容 | connect/discover/read/write/notify/mtu/phy… | 全量事件；UI 过滤不影响导出 [ISSUE#181] | [21] |
| 命名 | 用户选择路径 | `{设备名}-{yyyyMMdd-HHmmss}.txt` 建议 | — |
| 失败 | 过大文件 SAVE 失败 | 分卷或 ⚙ 提示 | [DOC] |
| 持久化 | 可选 nRF Logger DB | SessionLog 后端统一 | APP-05 否定 Logger Settings |

### 15.3 Log 事件类型枚举（LOG-EVT-*）

| EVT-ID | 事件 | 典型行前缀 | P0 |
| --- | --- | --- | --- |
| LOG-EVT-01 | Connected | `[I] Connected` | ✓ |
| LOG-EVT-02 | Discovered | `[I] Services discovered` | ✓ |
| LOG-EVT-03 | Read/Write | `[I] Read/Write` + handle | ✓ |
| LOG-EVT-04 | Notification | `[N] Notification` | ✓ |
| LOG-EVT-05 | Indication | `[I] Indication` | ✓ |
| LOG-EVT-06 | MTU | `[I] MTU changed` | ✓ |
| LOG-EVT-07 | PHY | `[I] PHY` | P1 |
| LOG-EVT-08 | Error | `[E] GATT error` | ✓ |
| LOG-EVT-09 | Reliable Write | `[I] Prepare/Execute/Abort` | P1 |

---

## 16. Automated Tests — 27 操作 tag 全表（P3 架构预留）

> **证据**：`.research/reference-apps/nRF-Connect-docs/Automated-tests-README.md` · `01-v2` §6 · `13` §3  
> **YoWire**：不做 ADB/in-app Tests UI；架构层可导入 `<test-suite>` XML（P3）。

### 16.1 27 tag 主表

| # | Tag | 需连接 | 默认 timeout | 仅 Tests | XML 关键属性 | YoWire 预留 |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | `scan` | 否 | 5000ms | **是** | rssi, name, data, target | P3 实验室 |
| 2 | `scan-for` | 否 | 5000ms | **是** | bind-target | P3 |
| 3 | `connect` | — | 5000ms | **是** | target | P3 |
| 4 | `discover-services` | 是 | 5000ms | **是** | — | P2 等同 auto discover |
| 5 | `refresh` | 是 | 5000ms | **是** | 隐藏 gatt.refresh | P2 CM-06 |
| 6 | `disconnect` | 是 | 5000ms | **是** | — | P0 |
| 7 | `bond` | 否* | 5000ms | **是** | expected | P1 |
| 8 | `unbond` | 否* | 5000ms | **是** | — | P1 |
| 9 | `assert-service` | 加载期 | — | 部分** | uuid, assert 树 | P2 |
| 10 | `read` | 是 | 5000ms | 共有 | service/char UUID, assert-value | P0 GATT |
| 11 | `read-descriptor` | 是 | 5000ms | 共有 | uuid | P0 |
| 12 | `write` | 是 | 5000ms | 共有 | type=WWR/WWOR | P0 |
| 13 | `write-descriptor` | 是 | 5000ms | 共有 | CCCD | P0 |
| 14 | `begin-reliable-write` | 是 | — | 共有 | — | P1 |
| 15 | `execute-reliable-write` | 是 | 5000ms | 共有 | — | P1 |
| 16 | `abort-reliable-write` | 是 | 5000ms | 共有 | — | P1 |
| 17 | `assert-notification` | 是 | 5000ms | **是** | 可嵌 write/read | P2 |
| 18 | `read-rssi` | 是 | 5000ms | 共有 | assert-value -50+ | P1 Scanner 图 |
| 19 | `request-mtu` | 是 | 5000ms | 共有 | value 23–517 | P0 |
| 20 | `request-connection-priority` | 是 | 5000ms | 共有 | LOW/BALANCED/HIGH | P1 |
| 21 | `read-phy` | 是 | 5000ms | 共有 | assert tx/rx | P1 |
| 22 | `set-preferred-phy` | 是 | 5000ms | 共有 | LE_1M/2M/CODED | P1 |
| 23 | `sleep` | — | ms | 共有 | — | P3 |
| 24 | `sleep-if` | 是 | 5000ms | 共有 | 条件 | P3 |
| 25 | `sleep-until` | 是 | 5000ms | 共有 | 值相等 | P3 |
| 26 | **`dfu`** | 否** | **无默认** | **是** | file, type, init | P3 → `04` DFU |
| 27 | **`mcu`** | 是 | 5000ms | **是** | mode, swap-time, buffers | P3 Device Manager 边界 |

\* bond/unbond 可不连接调用。** dfu 可不先 connect（bootloader 广播）。

### 16.2 Tests 执行壳（非 UI）

| 项 | 行为 | YoWire |
| --- | --- | --- |
| 入口 | PC `test.bat` / `test.sh` + ADB | 不做 |
| 通知 | 「Test in progress…」 | — |
| 结果 | `*_result.txt` | 可解析格式预留 |
| expected | SUCCESS / FAIL / WARNING 变体 | assert 橙三角语义对齐 Macros |
| target | `<target address=` / scan-for bind | — |

### 16.3 Tests vs Macros 差集速查

| 维度 | Macros 28 | Tests 27 |
| --- | --- | --- |
| 入口 | 红 FAB Sheet | ADB only |
| 独有 | Server 9 tag + unlock-eddystone + assert 树 | scan/scan-for/connect/discover/refresh/disconnect/bond/unbond/assert-notification/**dfu**/**mcu** |
| XML 根 | `<macro>` | `<test-suite>` |

---

## 17. Web / Play Store 竞品证据（nRF Connect）

| 主题 | 公开证据 | YoWire 映射 ID | 备注 |
| --- | --- | --- | --- |
| **Reliable Write** | Nordic documentation README Connection；Core Spec 4.9.5；REL-4.21.0 Macros/Tests RW | GATT-08, CM-03~05, GATT-OP-07~09 | P1 必对齐 |
| **RSSI CSV/EXCEL 导出** | root README；REL-4.26.0 Detail RSSI 图导出 | S-12, SET-SCAN-10 delimiter | P1 → ⚙·会话 |
| **PHY Read/Set** | Play「Read and update PHY」；Android 8+ API；Macros read-phy/set-preferred-phy | CM-09~10, SET-SCAN-01 | P1 专家 |
| **McuManager DFU** | root README McuMgr；NCS nrf_desktop；`<mcu>` Tests 4.28.0+ | DFU-03, Tests tag `mcu` | P3；完整 FOTA→Device Manager |
| **Parse known UUIDs** | Play 描述 GATT 调试；ISSUE#12 | CM-02, GATT-10/11 | P1 |
| **Auto MTU** | DevZone DZ-108836；Infineon 文档链 | SET-CONN-06, CM-07 | P1 |
| **Play 商店** | [nRF Connect](https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp) 4.29.x：Scanner/DFU/Macros/PHY | 全文 ID 基准 | 版本漂移需 Release 交叉 |

**McuMgr 边界（Web/NCS）**：

- nRF Connect 主 App：**轻量 `.bin` 上传** + Log McuMgr 字样 [ISSUE#204]
- **nRF Connect Device Manager** 独立 App：Image tab、Shell、Stats、完整 FOTA mode
- YoWire：**不复制 Device Manager**；P3 实验室仅文档引用 Nordic NCS DFU 文档：https://docs.nordicsemi.com/

---

## 18. 架构重设计缺口回写（2026-07-23）

> 总册见 [`00-蓝牙功能总清单与优先级矩阵.md`](00-蓝牙功能总清单与优先级矩阵.md)。以下为相对当前 `features/bluetooth` 的实现缺口。

| 缺口 | 定稿优先级 | 架构落点 |
| --- | --- | --- |
| `BleScanViewModel` 与 `GattBrowserViewModel` 拆分（现 BleMain 过载） | P0 | `viewmodel/ble` · `viewmodel/gatt` |
| Filter Sheet UX（含 Manufacturer Mask SET-FIL-10） | P0 | `ui/view` + BleScanFilter |
| GATT 树页 + Log pane + SessionLog 导出 | P0 | `GattBrowserPage` + debug_core |
| 多 GATT Session UI（应用层上限 4） | **P1**（总册上调，原 APP-04 P2） | Repository sessionId 索引 |
| 连接前强制 stopBleScan | P0 | ConnectGatt UseCase 硬约束 |
| CONNECT⋮ / Reliable Write / Parse UUID | P1 | Gatt UseCase 扩展 |

---

## 19. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：S-01~S-14、CM/LOG/SET 全 ID、28 Macro tag、PRD/Gap 映射 |
| 2026-07-03 | 深扩：§13 GATT-OP 全矩阵、§14 CM-01~14、§15 LOG SAVE、§16 Tests 27 tag、§17 Web 证据 |
| 2026-07-23 | §18 架构重设计缺口回写；多会话上调 P1 |
