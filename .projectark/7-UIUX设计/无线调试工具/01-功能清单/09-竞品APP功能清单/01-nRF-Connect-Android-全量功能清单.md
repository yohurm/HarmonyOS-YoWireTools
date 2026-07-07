# nRF Connect for Mobile（Android）全量功能清单

> **状态**：深研草稿（竞品穷尽级，非 Play 录屏级）  
> **平台**：Android（Google Play `no.nordicsemi.android.mcp`）  
> **源码**：**闭源** — 本仓库仅含 [documentation + Issue tracker](https://github.com/NordicSemiconductor/Android-nRF-Connect)  
> **版本基线**：**2024-12+**（GitHub Release **4.29.1** `version_4.29.1` tag；Play What's new 4.29.1 交叉）  
> **证据层级**：`[DOC]` Nordic documentation/README · `[REL]` GitHub Releases · `[DZ]` DevZone · `[ISSUE]` GitHub Issues · `[PLAY]` Play Store · `[INFER]` 多源推断  
> **本地深研输入**：`.research/feature-inventory/01-v2` · `08` · `09` · `11` · `13` · `21`  
> **YoWire 对照**：PRD `03-蓝牙模块PRD.md` · Gap 矩阵 `22-…` §1 · 内部 ID `BT-GATT-*`

---

## 0. 文档统计

| 维度 | 数量 | 说明 |
| --- | ---: | --- |
| 一级 Tab / Drawer 入口 | 5 | Scanner / Bonded / Advertiser / ☰ GATT Server / Connection |
| Scanner 功能点 S-* | 14 | 含 RSSI 图、TIMELINE、CLONE 等 |
| Filter 维 SET-FIL-* | 9 | UI 内 Filter Sheet（非 Settings 页） |
| Connection ⋮ CM-* | 14 | 不含 Remove bond（仅 CONNECT ⋮） |
| Log pane LOG-* | 5 | Copy/Save/Share/Clear + level 过滤 |
| Settings Connectivity | 4 | 含 4.25+ 新增 MTU / incoming connections |
| Settings Scanner | 9 | 含 Scanning mode / Continuous / Compatibility |
| Macros XML operation tag | **28** | Client 12 + Server 9 + Other 7 |
| Automated Tests XML tag | **27** | 无 in-app UI；ADB `test.bat`/`test.sh` |
| GATT Server 预设服务 | 5 | Custom + Link Loss + Immediate Alert + Current Time + Heart Rate |
| DFU 协议 | 4 | Legacy / Secure / McuManager / SUIT over SMP |

---

## 1. 应用元信息（APP Meta）

| 字段 | 值 | Evidence URL |
| --- | --- | --- |
| 应用名称 | nRF Connect for Mobile | https://github.com/NordicSemiconductor/Android-nRF-Connect |
| 包名 | `no.nordicsemi.android.mcp` | https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp |
| 最低 Android | 4.3（API 18） | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md |
| 源码可用性 | **否** — repo 仅文档与 Issue | https://github.com/NordicSemiconductor/Android-nRF-Connect |
| 分发 | Google Play（推荐自动更新）或 GitHub Releases | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases |
| 版本基线 | **4.29.1**（2024-12 段） | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.29.1 |
| 关联 App | nRF Logger `no.nordicsemi.android.log`；Device Manager `no.nordicsemi.android.nrfconnectdevicemanager` | https://play.google.com/store/apps/details?id=no.nordicsemi.android.log |
| 产品定位 | BLE 开发者工具：扫描、GATT Client/Server、广播、DFU、宏自动化、ADB 测试 | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md |

### 1.1 Play Store 公开能力摘要（无 Settings 逐项）

| Play 描述要点 | YoWire 映射 | Evidence URL |
| --- | --- | --- |
| BLE 扫描与 RSSI 图导出 CSV/EXCEL | BT-GATT-01 / BT-GATT-19 | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md |
| 多设备同时连接 | APP-04 P2 | 同上 |
| GATT Read/Write/Notify + GATT Server 配置 | BT-GATT-04 / BT-GATT-16 P3 | 同上 |
| DFU（Legacy/Secure/McuManager）+ 4.29.1 SUIT | BT-GATT-17 P3 | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.29.1 |
| Macros 录制/导入 XML | BT-GATT-14/15 | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Macros |
| Automated Tests（ADB XML） | BT-GATT-15 P3 架构预留 | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Automated%20tests |
| Eddystone 解析/解密 EID/Config Service | P3 生态；YoWire 不纳入 v1 | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md |
| PHY 读/设（Bluetooth 5） | BT-GATT-07 P1 | https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp |

---

## 2. 信息架构（IA）与导航结构

### 2.1 全局壳层

```text
nRF Connect（Android）
├── 底部 Tab 栏
│   ├── Scanner          ← 默认 Tab；实时 BLE 扫描列表
│   ├── Bonded           ← 系统 bond 缓存列表（无需 Location 扫描）
│   └── Advertiser       ← 本机 BLE 广播（Lollipop+）
├── ☰ 导航抽屉（Drawer）
│   ├── Configure GATT Server   ← 本地 GATT Server 配置（非 Tab）
│   ├── Device Information      ← 主机 BLE 能力 [PARTIAL 证据]
│   └── Settings
│       ├── Connectivity        ← 4 项 Switch/行为
│       └── Scanner             ← 9 项扫描专家设置
└── Connection 栈（连接后全屏/Tab）
    ├── 顶栏：设备名 · Disconnect(×) · DFU 图标 · ⋮
    ├── Tab：CLIENT | SERVER |（4.29+ 第二 CLIENT Tab 同设备）
    ├── 右滑 / Show log → Log pane
    └── 红 FAB → Macros Sheet
```

### 2.2 IA 对照表

| IA 节点 | UI 位置 | 核心行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- |
| NRF-IA-01 | 底部 Tab **Scanner** | 持续扫描、Filter、CONNECT | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/documentation/README.md | 蓝牙→BLE GATT→B 栏扫描列表 |
| NRF-IA-02 | 底部 Tab **Bonded** | 系统 bond 列表；无广播解析 | 同上 | B Segmented「已绑定」BT-GATT-13 |
| NRF-IA-03 | 底部 Tab **Advertiser** | 本机广播包编辑/Start/Stop | 同上 | 专家·BLE 实验室 BT-GATT-16 P3 |
| NRF-IA-04 | Drawer **Configure GATT Server** | 本地服务/特征/描述符；Import XML | 同上 | 实验室 P3 |
| NRF-IA-05 | Drawer **Settings** | Connectivity + Scanner 分组 | `.research/feature-inventory/09-v2` · DZ 交叉 | **蓝牙 ⚙** 模块设置 |
| NRF-IA-06 | **Connection** 会话 | CLIENT/SERVER GATT 树 + Log + Macros | 同上 | C 栏 GATT 树 + Log pane 40% |
| NRF-IA-07 | Connection 顶栏 **DFU 图标** | 固件升级（独立于 ⋮） | `.research/feature-inventory/13-v2` §2 | BT-GATT-17 P3 |
| NRF-IA-08 | Connection **红 FAB** | Macros Sheet | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Macros | BT-GATT-15 P3 |

---

## 3. 应用权限与连通性（NRF-APP-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-APP-01 | **Location 权限**（Marshmallow+） | 首次扫描系统 Dialog | 拒绝则扫描不可用；Bonded/已连接仍可用 | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/documentation/README.md | P0 扫描页 Banner |
| NRF-APP-02 | **Location Service** 开关 | 应用内提示→系统设置 | 关闭则扫描不可用（Samsung Pie+ 等 OEM 强制） | 同上 · DZ-86964 | P0 同左 |
| NRF-APP-03 | **Storage 权限** | 导出时按需 | Log/Macro/GATT XML 保存可选 | 同上 | P1 导出时申请 |
| NRF-APP-04 | **Nearby / BLUETOOTH_SCAN**（Android 12+） | 权限流程 | 4.25.0+ 适配新权限模型 | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.25.0 | P0 HarmonyOS 对照 |
| NRF-APP-05 | **多连接并行** | Scanner 仍可 CONNECT 其他设备 | 扫描+广播+多 Connection 栈独立 | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md | P2 连接管理器 |
| NRF-APP-06 | **nRF Logger 集成** | Log pane 自动写入 Logger DB | 需安装独立 Logger App；退出 nRF 不丢 log | https://play.google.com/store/apps/details?id=no.nordicsemi.android.log | **跳过** — 自有 SessionLog |
| NRF-APP-07 | **Device Information** 抽屉项 | ☰ Drawer | 主机 BLE 能力 flags [PARTIAL] | `.research/feature-inventory/21-v2` DR-01 | P2 蓝牙 ⚙·能力 |
| NRF-APP-08 | **Foreground Service**（4.29.1） | 连接服务常开 | Play/APKMirror What's new | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.29.1 | P0 后台策略对照 |
| NRF-APP-09 | **Edge-to-edge** 视觉（4.29.1） | 系统栏 inset | Release 4.29.1 | 同上 | 适配参考 |
| NRF-APP-10 | **ADB Automated Tests** | 无 in-app UI | PC `test.bat`/`test.sh` + XML | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Automated%20tests | P3 架构预留 |

---

## 4. Scanner Tab（NRF-S-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-S-01 | 实时 BLE 设备列表 + RSSI | Scanner Tab 列表区 | 默认持续扫描；行显示名/MAC/RSSI | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/documentation/README.md | **BT-GATT-01** P0 |
| NRF-S-02 | **Filter** 入口 | 顶栏 Filter 图标/按钮 | 打开 Filter Sheet 多维过滤 | 同上 · `.research/feature-inventory/08-v2` §1.2 | **BT-GATT-02** P0 |
| NRF-S-03 | **Only Favorites** | Filter 内 Switch | 仅显示收藏设备 | DZ/社区 · `09-v2` SET-FIL-09 | **BT-GATT-13** P1 |
| NRF-S-04 | **CONNECT** | 列表行右侧 | Oreo+ 仅 connectable 显示；旧版全显示 30s 超时 | documentation/README.md Scanner 节 | **BT-GATT-03** P0（YoWire 需 stopScan） |
| NRF-S-05 | CONNECT **⋮** 子菜单 | CONNECT 旁三点 | autoConnect / preferred PHY / Bond / Remove bond | 同上 | **BT-GATT-08** P1 |
| NRF-S-06 | 行展开 + **蓝色标题**解析器 | 点行展开 AD | Int/Float/Temperature/Pressure 等切换 | 同上 · REL-4.29.1 更多解析器 | BT-GATT-01 扩展 P1 |
| NRF-S-07 | **RAW** 广播数据 | 展开区 RAW 按钮 | HEX 按 AD 记录拆分 | documentation/README.md | **BT-GATT-01** P0 |
| NRF-S-08 | **MORE** 包历史 | 展开区 MORE | RSSI/包变化/广播间隔；数值解析器→时间曲线 Tab | 同上 | **BT-GATT-12** P2 |
| NRF-S-09 | **CLONE** → Advertiser | 展开区 CLONE（Lollipop+） | 近似克隆广播到本机 Advertiser | 同上 | **BT-GATT-16** P3 |
| NRF-S-10 | **OPEN** Physical Web URL | 广播含 URL 时 | 系统浏览器打开 Physical Web | 同上 | **跳过** v1 |
| NRF-S-11 | **RSSI graph** | 右滑列表或菜单 Show RSSI graph | 平均 RSSI 曲线；4.25+ 长按多选灰显 | README.md · REL-4.25.0 | P1 |
| NRF-S-12 | RSSI 图 **CSV/EXCEL 导出** | RSSI 图菜单 Export | 导出格式选择 | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md | **BT-GATT-19** P1 |
| NRF-S-13 | **长按多选**批量操作 | 长按进入选择模式 | Assign name / Export avg advertising / **TIMELINE**（≥2 设备） | documentation/README.md | **BT-GATT-16** P3 |
| NRF-S-14 | Scanner **Settings** 联动 | ☰ Settings→Scanner | PHY/batching/connectable/AdvExt/Coded 等九项 | `09-v2` · `21-v2` §3.1 | 蓝牙 ⚙·扫描 P1 |

---

## 5. Filter 配置（NRF-SET-FIL-*）

> 位于 Scanner 顶栏 **Filter** Sheet，**非** Settings 持久页。

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-SET-FIL-01 | 名称或地址部分匹配 | Filter TextField | 例 "OA56B2" 匹配全名 | documentation/README.md · `08-v2` §1.2.2 | **BT-GATT-02** P0 |
| NRF-SET-FIL-02 | 广播数据 HEX 过滤 | Filter TextField | AD payload 子串匹配 | 同上 §1.2.3 | **BT-GATT-02** P0 |
| NRF-SET-FIL-03 | RSSI 阈值下限 | Filter Slider/数值 | 仅显示 RSSI ≥ 设定 | 同上 §1.2.4 | **BT-GATT-02** P0 |
| NRF-SET-FIL-04 | 排除 **Apple** 设备 | Filter Checkbox | 4.25.3+；被排除项可显示删除线 | REL-4.25.3 · DZ-86964 | P1 Filter 预设 |
| NRF-SET-FIL-05 | 排除 **Microsoft** | Checkbox | 同上 | `09-v2` | P1 |
| NRF-SET-FIL-06 | 排除 **Google** | Checkbox | REL-4.25.3 | `09-v2` | P1 |
| NRF-SET-FIL-07 | 排除 **Samsung** | Checkbox | REL-4.25.3 | `09-v2` | P1 |
| NRF-SET-FIL-08 | 排除 **Mesh / Beacon / ENS** | Checkbox 组 | release notes 扩展 | `09-v2` · `01-v2` | P1 |
| NRF-SET-FIL-09 | **Only Favorites** | Filter Switch | 社区/DevZone 文档化 | `09-v2` SET-FIL-09 | **BT-GATT-13** P1 |
| NRF-SET-FIL-X1 | Filter 清除 | Filter 右侧 **X** | 恢复全量列表 | `08-v2` §1.2.7 | P0 Reset |
| — | **Manufacturer Data Mask** | **nRF 无等价 UI** | 仅 HEX 子串 `data=`（Tests XML） | Automated tests README · `22-v2` §1 | **YoWire P0 增值** SET-FIL-10 |
| — | **Service UUID 过滤** | UI 弱；Tests `scan-for` 支持 | PRD 要求独立 Filter 维 | `03-蓝牙PRD` §7.2 | **YoWire P0** |

---

## 6. Bonded Tab（NRF-B-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-B-01 | 系统 bond 设备列表 | Bonded Tab | **无需** Location 权限 | documentation/README.md Bonded 节 | BT-GATT-13 P1 |
| NRF-B-02 | 列表项名/MAC | 列表行 | 系统缓存；**无**实时广播解析 | 同上 | B Segmented「已绑定」 |
| NRF-B-03 | CONNECT / CONNECT⋮ | 同 Scanner | autoConnect/PHY/bond/remove bond | `08-v2` §2 | BT-GATT-08 P1 |
| NRF-B-04 | 连接成功 → Connection | 同 Scanner 路径 | 进入 CLIENT discover 流程 | `08-v2` §2.4 | BT-GATT-03/04 P0 |

---

## 7. Advertiser Tab（NRF-ADV-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-ADV-01 | 历史广播包列表 | Advertiser Tab | 模拟他机扫描所见 | documentation/README.md Advertiser 节 | BT-GATT-16 P3 |
| NRF-ADV-02 | **+ FAB** 新建包 | 左下 FAB | 创建 AD 记录组合 | 同上 | 实验室 P3 |
| NRF-ADV-03 | **笔** 图标设 Complete Local Name | 顶栏菜单 | 系统级设备名；影响含 Local Name 的包 | 同上 | P3 |
| NRF-ADV-04 | Start/Stop 广播 | 包编辑器 | Lollipop+ 本机 peripheral 模式 | README.md Features #9 | P3 |
| NRF-ADV-05 | **Discoverable flag**（4.29+） | Advertiser 编辑器 | 控制可发现性 | REL-4.29.1 | P2 实验室 |
| NRF-ADV-06 | **Service Solicitation UUID**（4.29+） | Advertiser 编辑器 | BLE 5 广播字段 | REL-4.29.1 | P2 实验室 |
| NRF-ADV-07 | **CLONE** 来源 | Scanner S-09 | 从扫描包导入 | documentation/README.md | P3 |

---

## 8. Configure GATT Server（NRF-GS-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-GS-01 | 配置入口 | ☰ **Configure GATT Server** | 非 Tab；Drawer 进入 | documentation/README.md | BT-GATT-16 P3 |
| NRF-GS-02 | 顶栏 Dropdown | 配置选择器 | 选配置 / New / **Import XML** / Disable | 同上 | P3 |
| NRF-GS-03 | **ADD SERVICE** 预设 | 配置页 | Custom / Link Loss / Immediate Alert / Current Time / Heart Rate | 同上 | P3 |
| NRF-GS-04 | **ADD CHARACTERISTIC** | Custom 服务下 | UUID + 属性 | 同上 | P3 |
| NRF-GS-05 | **ADD DESCRIPTOR** | 特征下 | CCCD/CEPD 自动添加规则 | 同上 | P3 |
| NRF-GS-06 | **Sample configuration** | Dropdown | Macros Tutorial #3 依赖 | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Macros | P3 |
| NRF-GS-07 | **Share / Export XML** | 配置页顶栏 ⋮ | Android Share + XML 导出 | DZ-68849 · ISSUE#13 | P3 |
| NRF-GS-08 | 连接后 **SERVER Tab** | Connection Tab | 每连接独立服务副本 | documentation/README.md Connection | P3 |
| NRF-GS-09 | 与系统/其他 App 服务合并 | 运行时 | 远端可能发现多于配置项 | 同上 | — |

---

## 9. Connection — CLIENT GATT 操作（NRF-GATT-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-GATT-01 | Auto service discovery | 连接后自动 | Settings→Connectivity 可关 | documentation/README.md Connection | SET-CONN-01 **P0** |
| NRF-GATT-02 | Service 树展开 | CLIENT Tab | Known UUID 友好名 | 同上 | **BT-GATT-04** P0 |
| NRF-GATT-03 | **Read** characteristic | 属性图标行 | 行内更新 + Log | 同上 · icons.png | **BT-GATT-04** P0 |
| NRF-GATT-04 | **Write**（WWR/WWOR） | Write 图标→Dialog | 解析表单或 HEX；type 可选 | Macros README `<write type=` | **BT-GATT-04** P0 |
| NRF-GATT-05 | **Notify** 订阅 | Notify 图标 | 写 CCCD；持续 Log | documentation/README.md | **BT-GATT-04** P0 |
| NRF-GATT-06 | **Indicate** 订阅 | Indicate 图标 | 同 Notify | 同上 | **BT-GATT-04** P0 |
| NRF-GATT-07 | **Descriptor Read/Write** | Descriptor 行图标 | 含 CCCD 操作 | 同上 | **BT-GATT-04** P0 |
| NRF-GATT-08 | **Reliable Write** Begin/Execute/Abort | Connection ⋮ 子菜单 | Prepare 队列；4.21.0+ | documentation/README.md · Macros README | **BT-GATT-05** P1 |
| NRF-GATT-09 | **Parse known UUIDs** Toggle | Connection ⋮ | OFF→纯 HEX Dialog | 同上 · ISSUE#12 | **BT-GATT-09** P1 |
| NRF-GATT-10 | **Big Endian** 写 | Write Dialog 选项 | 4.25.4+ | REL-4.25.4 | P1 WR-01 |
| NRF-GATT-11 | Known SIG + 厂商特征解析 | 默认 ON | 4.29.1 扩展 Find My/Continuity/micro:bit 等 | REL-4.29.1 | P1 |
| NRF-GATT-12 | 第二 **CLIENT Tab** 同设备 | Connection Tab 栏 | 4.29+ 双 Tab 并行视图 | REL-4.29.1 · ISSUE#85 PARTIAL | P2 840vp 双 pane |
| NRF-GATT-13 | GATT 树 **无一键 Copy UUID** | — | DevZone 建议从 Log 解析复制 | DZ-66939 | YoWire P1 长按复制 |
| NRF-GATT-14 | 特征/描述符 **icons 图例** | CLIENT 树 | Read/Write/Notify/Indicate/Reliable 等 | documentation/../images/icons.png | P0 图标对齐 |

---

## 10. Connection 顶栏 ⋮ 菜单（NRF-CM-*）

> **Remove bond** 仅在 **CONNECT ⋮**，不在已连接 Tab ⋮（`21-v2` RESOLVED 否定）。

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-CM-01 | **Show log** | Connection ⋮ | 打开 Log pane；亦可右滑 CLIENT | documentation/README.md | **BT-GATT-10** P0 |
| NRF-CM-02 | **Parse known UUIDs** | Connection ⋮ Toggle | 会话级；非 Settings 持久 | 同上 · DZ-22523 | **BT-GATT-09** P1 |
| NRF-CM-03 | **Reliable Write → Begin** | ⋮ 子菜单 | 后续 Write 走 Prepare | documentation/README.md | **BT-GATT-05** P1 |
| NRF-CM-04 | **Reliable Write → Execute** | ⋮ 子菜单 | 提交 RW 子过程 | 同上 | **BT-GATT-05** P1 |
| NRF-CM-05 | **Reliable Write → Abort** | ⋮ 子菜单 | 回滚；断开时可能自动 Abort | ISSUE#145 | **BT-GATT-05** P1 |
| NRF-CM-06 | **Refresh services** | ⋮ Action | 调用隐藏 `BluetoothGatt.refresh()` | ISSUE#212 · SO-50739085 | **BT-GATT-11** P2 |
| NRF-CM-07 | **Request MTU** | ⋮→Dialog | 输入 23–517；交换次数有限 | DZ-108836 · DZ-95220 | **BT-GATT-06** P0 |
| NRF-CM-08 | **Request connection priority** | ⋮ Submenu | LOW_POWER / BALANCED / HIGH | Macros/Tests XML INFER | **BT-GATT-07** P1 |
| NRF-CM-09 | **Read PHY** | ⋮ Action | Log tx/rx PHY | Play 描述 INFER | **BT-GATT-07** P1 |
| NRF-CM-10 | **Set preferred PHY** | ⋮ Dialog | LE_1M/2M/CODED + S2/S8 option | Macros README | **BT-GATT-07** P1 |
| NRF-CM-11 | **Bond** | ⋮ Action [INFER] | 系统配对 UI | Tests `<bond>` + CONNECT ⋮ DOC | P1 |
| NRF-CM-12 | **Clone device's services** | ⋮ Action | 克隆远端 GATT→本地 Server DB | ISSUE#13 | BT-GATT-16 P3 |
| NRF-CM-13 | **Open second tab** / Open tab | ⋮ 或 Tab 栏 [PARTIAL] | 同设备双 Connection Tab | REL-4.29.1 · ISSUE#85 | P2 |
| NRF-CM-14 | **Remove bond** | **CONNECT ⋮ 仅** | 清除系统 bond | documentation/README.md Scanner | BT-GATT-08 P1 |
| NRF-CM-15 | Copy/Share UUID/value | **不在 ⋮** | Log pane 底栏 Copy/Share | ISSUE#93 | P1 Log 底栏 |

**菜单固定顺序**：STILL_UNKNOWN（无 4.29.1 官方顺序表）— `21-v2` §2.1。

---

## 11. Log pane（NRF-LOG-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-LOG-01 | 事件流 Log | 右滑 CLIENT 或 Show log | connect/discover/read/write/notify… 时间戳 | documentation/README.md | **BT-GATT-10** P0 |
| NRF-LOG-02 | **SAVE** 导出 | Log pane 底栏 | Storage；过大可能失败 | 同上 | **BT-GATT-10/19** P0 |
| NRF-LOG-03 | **Copy** | Log pane 底栏 | 4.24.2+ 窄屏裁切修复 | ISSUE#93 · REL-4.24.2 | P1 |
| NRF-LOG-04 | **Share** | Log pane 底栏 | 系统 Share Sheet | ISSUE#93 | P1 |
| NRF-LOG-05 | **Clear (Trash)** | Log pane 底栏 | 清空当前会话 log | ISSUE#123 · ISSUE#93 | P0 |
| NRF-LOG-06 | **Log level 过滤** | Log pane UI | 过滤仅 UI；导出仍全量 | ISSUE#181 | P2 |
| NRF-LOG-07 | **nRF Logger** 持久化 | 安装 Logger 时 | 写入 Logger DB；退出不丢 | documentation/README.md · PLAY Logger | **跳过** |
| NRF-LOG-08 | Prompt before save | Settings? [PARTIAL] | Issue #123 用户自述；维护者未确认 | ISSUE#123 | **暂不实现** |

---

## 12. Settings — Connectivity（NRF-SET-CONN-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-SET-CONN-01 | **Auto service discovery** | Settings→Connectivity Switch | 默认 ON | documentation/README.md | **P0** 蓝牙 ⚙·连接 |
| NRF-SET-CONN-02 | **Abort reliable write on new connection** | 同上 Switch | 4.25.2+ 默认 **OFF** | ISSUE#145 | **P1** BLE 高级 |
| NRF-SET-CONN-03 | **Auto request maximum MTU** | 同上 Switch | 连接后自动协商 max MTU（例 517） | DZ-108836 | **P1** 蓝牙 ⚙·连接 |
| NRF-SET-CONN-04 | **Show incoming connections** | 同上 Switch | GATT Server 入站连接调试；默认 ON | ISSUE#21 · ISSUE#89 | **P2** 实验室 |
| — | Theme / Dark mode | **不存在** | 随 Android DayNight | PLAY · DOC 否定 `21-v2` | — |
| — | Logger 子设置 | **不存在** | 独立 App | PLAY Logger | **跳过** |
| — | DFU 默认路径 | **不存在** | 每次 Document Picker | ISSUE#184 | — |

---

## 13. Settings — Scanner（NRF-SET-SCAN-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-SET-SCAN-01 | **Physical Layer (PHY)** | Settings→Scanner | All supported / 限制 PHY；不支持 Coded 时 All **灰显** | documentation/README.md · DZ-86964 | P1 |
| NRF-SET-SCAN-02 | **Offloaded scan batching** | 同上 Switch | ON 可能导致部分机型扫不到 | DZ-86964 | P1 |
| NRF-SET-SCAN-03 | **Only connectable devices** | 同上 Switch | Android 8+ | REL-4.25.0 | P1 |
| NRF-SET-SCAN-04 | **Only Advertising Extension** | 同上 Switch | 仅 BLE 5 Adv Extension | REL-4.25.0 | P2 专家 |
| NRF-SET-SCAN-05 | **Scan PHY Coded only** | 同上 Switch | 仅 Coded PHY 扫描 | REL-4.25.0 | P2 专家 |
| NRF-SET-SCAN-06 | **Scanning mode** | 同上枚举 | LOW_LATENCY（默认）/ BALANCED / LOW_POWER | DZ-97953 | P1 |
| NRF-SET-SCAN-07 | **Continuous scanning** | Switch + 周期 | Manual / 最长 5min 等 | DZ-77165 | P1–P2 |
| NRF-SET-SCAN-08 | **Compatibility mode (PHY)** | 同上 Switch | ON=legacy only；OFF=含 Coded | DZ-60496 | P1–P2 |
| NRF-SET-SCAN-09 | **CSV termination character** | 同上枚举 | Comma / Tab / Semicolon | DZ-77165 | P1 导出 |

---

## 14. Macros — 28 种 operation tag 全表

> **入口**：Connection 页右下 **红 FAB** → Macros Sheet。  
> **证据**：`documentation/Macros/README.md`（489 行）。  
> **执行 UI**：Step Over / Skip operation / Run macro / Loop；灰点→蓝（成功）/红（失败）/橙三角（assert 值不符）。

### 14.1 Client 操作（12）

| # | XML Tag | 功能摘要 | UI/Log 行为 | Evidence URL | YoWire 映射 |
| ---: | --- | --- | --- | --- | --- |
| 1 | `<read>` | 读 characteristic | 树更新 + Log；可嵌 `<assert-value>` | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Macros/README.md | BT-GATT-14 P1 |
| 2 | `<read-descriptor>` | 读 descriptor | 同 read | 同上 | BT-GATT-14 P1 |
| 3 | `<write>` | 写 characteristic | type=WRITE_REQUEST\|WRITE_COMMAND | 同上 | BT-GATT-14 P1 |
| 4 | `<write-descriptor>` | 写 descriptor | 含 CCCD | 同上 | BT-GATT-14 P1 |
| 5 | `<begin-reliable-write>` | 开始 Reliable Write | 4.21.0+；后续 write 走 Prepare | 同上 | BT-GATT-05 P1 |
| 6 | `<execute-reliable-write>` | 提交 RW | 需至少一次 Prepare write | 同上 | BT-GATT-05 P1 |
| 7 | `<abort-reliable-write>` | 中止 RW | 回滚至 Begin 前状态 | 同上 | BT-GATT-05 P1 |
| 8 | `<wait-for-notification>` | 等待 Notify | 阻塞至 notification；assert 不符→橙三角 | 同上 | BT-GATT-15 P3 |
| 9 | `<wait-for-indication>` | 等待 Indicate | 同 notification | 同上 | BT-GATT-15 P3 |
| 10 | `<sleep-if>` | 值等于则立即结束否则等 | 需 Notify on；Server 侧 server=true | 同上 | P3 |
| 11 | `<sleep-until>` | 值等于目标则结束 | 同 sleep-if 语义反转 | 同上 | P3 |
| 12 | `<unlock-eddystone>` | Eddystone 解锁 | 需先 read challenge；16-byte key | 同上 | **跳过** P3 生态 |

### 14.2 Server 操作（9）

| # | XML Tag | 功能摘要 | 前置 | Evidence URL | YoWire 映射 |
| ---: | --- | --- | --- | --- | --- |
| 13 | `<wait-for-read>` | 等远端 Read char | GATT Server 配置 + SERVER Tab | Macros README | BT-GATT-16 P3 |
| 14 | `<wait-for-read-descriptor>` | 等远端 Read desc | 同上 | 同上 | P3 |
| 15 | `<wait-for-write>` | 等远端 Write char | 可 assert-value | 同上 | P3 |
| 16 | `<wait-for-write-descriptor>` | 等远端 Write desc | 可 assert-value | 同上 | P3 |
| 17 | `<wait-for-execute-reliable-write>` | 等 Execute/Abort RW | execute=true\|false | 同上 | P3 |
| 18 | `<set-value>` | 设 Server char 值 | 可被远端 Read | 同上 | P3 |
| 19 | `<set-descriptor-value>` | 设 Server desc 值 | 同上 | 同上 | P3 |
| 20 | `<send-notification>` | 发 Notify | Notify 属性 + CCCD | 同上 | P3 |
| 21 | `<send-indication>` | 发 Indicate | Indicate 属性 | 同上 | P3 |

### 14.3 Other 操作（7）

| # | XML Tag | 功能摘要 | 平台约束 | Evidence URL | YoWire 映射 |
| ---: | --- | --- | --- | --- | --- |
| 22 | `<sleep>` | 纯延时 ms | timeout 属性 | Macros README | P3 |
| 23 | `<read-rssi>` | 读连接 RSSI | 需已连接 | 同上 | P1 |
| 24 | `<request-mtu>` | 请求 MTU | 23–517；Android 5+ | 同上 | **BT-GATT-06** P0 |
| 25 | `<request-connection-priority>` | 连接优先级 | LOW_POWER/BALANCED/HIGH | 同上 | **BT-GATT-07** P1 |
| 26 | `<read-phy>` | 读 tx/rx PHY | Android 8+；可 assert tx/rx | 同上 | **BT-GATT-07** P1 |
| 27 | `<set-preferred-phy>` | 设推荐 PHY | tx/rx LE_1M/2M/CODED；option S2/S8 | 同上 | **BT-GATT-07** P1 |
| 28 | `<wait-for-phy-update>` | 等 PHY 更新 | 可 assert | 同上 | **BT-GATT-07** P1 |

### 14.4 Assert 树（宏加载期）

| XML 节点 | 检查时机 | UI 反馈 | Evidence URL |
| --- | --- | --- | --- |
| `<assert-server-service>` | 宏加载 | 不符→Banner 宏不可用 | Macros README |
| `<assert-service>` | 宏加载 | 远端缺 service→Banner | 同上 |
| `<assert-characteristic>` + `<property requirement=MANDATORY\|OPTIONAL\|EXCLUDED>` | 加载 | 属性约束 | 同上 |
| `<assert-descriptor>` / `<assert-cccd>` | 加载 | 描述符约束 | 同上 |
| `<assert-value>`（子节点） | Step Over 后 | 不符→**橙三角** | 同上 |

### 14.5 宏 icon 属性（42 值，节选）

LEFT, UP, HOME, DOWN, RIGHT, REWIND, PLAY, PAUSE, STOP, FORWARD, MAGIC, PHYSICAL_WEB, EDDYSTONE, NORDIC, LOCK, ALARM, SETTINGS, STAR, PLUS, MINUS, BRIGHTNESS_HIGH, BRIGHTNESS_LOW, DOWNLOAD, UPLOAD, PRINT, FLASH, FLASH_OFF, LED_ON, LED_OFF, BATTERY, INFO, MESSAGE, ROCKET, PARACHUTE, PIKACHU, NUMBER_1…NUMBER_9, CLOSE — 完整列表见 Macros README §Name and icon。

---

## 15. Automated Tests — 27 种 operation tag 摘要

> **入口**：**无应用内 UI** — PC 执行 `test.bat`/`test.sh` + ADB。  
> **根节点**：`<test-suite>` → `<test>` + `<run-test>`。  
> **默认 timeout**：5000ms（**`<dfu>` 除外**）。  
> **证据**：`documentation/Automated tests/README.md`（495 行）。

| # | XML Tag | 功能摘要 | Macros 是否有 | Evidence URL | YoWire 映射 |
| ---: | --- | --- | ---: | --- | --- |
| 1 | `<scan>` | 定时扫描并 log 包 | ✗ | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Automated%20tests/README.md | P3 架构 |
| 2 | `<scan-for>` | 扫描直至匹配；可 bind-target | ✗ | 同上 | P3 |
| 3 | `<connect>` | 连接 target | ✗ | 同上 | — |
| 4 | `<discover-services>` | GATT discover | ✗ | 同上 | — |
| 5 | `<refresh>` | 清 GATT cache（hidden API） | ✗ | 同上 | BT-GATT-11 P2 |
| 6 | `<disconnect>` | 断开 | ✗ | 同上 | — |
| 7 | `<bond>` | 配对（可不连接） | ✗ | 同上 | P1 |
| 8 | `<unbond>` | 移除 bond | ✗ | 同上 | P1 |
| 9 | `<assert-service>` | 断言服务/特征/描述符树 | 部分（Macros assert 树） | 同上 | P3 |
| 10 | `<read>` | 读 char + assert | ✓ | 同上 | BT-GATT-14 |
| 11 | `<read-descriptor>` | 读 desc | ✓ | 同上 | BT-GATT-14 |
| 12 | `<write>` | 写 char | ✓ | 同上 | BT-GATT-14 |
| 13 | `<write-descriptor>` | 写 desc | ✓ | 同上 | BT-GATT-14 |
| 14 | `<begin-reliable-write>` | RW Begin | ✓ | 同上 | BT-GATT-05 |
| 15 | `<execute-reliable-write>` | RW Execute | ✓ | 同上 | BT-GATT-05 |
| 16 | `<abort-reliable-write>` | RW Abort | ✓ | 同上 | BT-GATT-05 |
| 17 | `<assert-notification>` | 等 Notify（可嵌 write 触发） | ✗（Macros 用 wait-for-notification） | 同上 | P3 |
| 18 | `<read-rssi>` | RSSI + 范围 assert | ✓ | 同上 | P1 |
| 19 | `<request-mtu>` | MTU 23–517 | ✓ | 同上 | BT-GATT-06 |
| 20 | `<request-connection-priority>` | 连接优先级 | ✓ | 同上 | BT-GATT-07 |
| 21 | `<read-phy>` | 读 PHY | ✓ | 同上 | BT-GATT-07 |
| 22 | `<set-preferred-phy>` | 设 PHY | ✓ | 同上 | BT-GATT-07 |
| 23 | `<sleep>` | 延时 | ✓ | 同上 | P3 |
| 24 | `<sleep-if>` | 条件 sleep | ✓ | 同上 | P3 |
| 25 | `<sleep-until>` | 等到值相等 | ✓ | 同上 | P3 |
| 26 | `<dfu>` | Legacy/Secure DFU ZIP/bin | ✗ | 同上 · init packet README | BT-GATT-17 P3 |
| 27 | `<mcu>` | McuManager SMP 上传（4.28.0+） | ✗ | 同上 L481-490 · PR#209 | BT-GATT-17 P3 |

**Tests 独有属性**：`expected` / `expectedErrorCode` / `timeout` / `target` — Macros **不支持**（Macros 支持 `icon=` 42 值）。

**样例 XML**：`sample_test_hrm.xml`（HRS_DFU）· `sample_test_scanning.xml`（v4.3+ 扫描）— https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Automated%20tests

---

## 16. DFU — Device Firmware Update（NRF-DFU-*）

### 16.1 协议对照

| 协议 | SDK/平台 | nRF Connect 支持 | 完整 UI 边界 | Evidence URL | YoWire |
| --- | --- | ---: | --- | --- | --- |
| **Legacy DFU** | nRF5 SDK | ✓ | 主 App DFU 图标 | README.md DFU 表 | P3 |
| **Secure DFU** | nRF5 SDK 12+ | ✓ | Distribution ZIP + init packet | 同上 · init packet handling | P3 |
| **McuManager (SMP)** | NCS/Zephyr/Mynewt | ✓ | 主 App 轻量 `.bin`；mode 仅 Tests XML | README · ISSUE#204 | P3 |
| **SUIT over SMP** | NCS 3.x+ / nRF54H | ✓ 4.29.1+ | 主 App 轻量路径；完整 SUIT→**Device Manager** | REL-4.29.1 · NCS smp_transfer | P3 |

### 16.2 DFU UI 流程要点

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-DFU-01 | **DFU 入口** | Connection 顶栏 **DFU 图标**（非 ⋮） | 独立于 Connection 菜单 | ISSUE#184 · Thingy52 教程 | BT-GATT-17 P3 |
| NRF-DFU-02 | 文件类型子菜单 | DFU 图标点击 | Distribution ZIP / SoftDevice / Bootloader / Application | ISSUE#184 · DZ-14568 | P3 |
| NRF-DFU-03 | Document Picker 选包 | 系统文件选择 | Android 13/14 可能需 Show local files | DZ-109476 | P3 |
| NRF-DFU-04 | **Buttonless** 进 Bootloader | CLIENT Secure DFU Service 图标 | Confirm Send→断开→Scanner 见 DfuTarg | Thingy52 dfu_connect.html | P3 |
| NRF-DFU-05 | DFU 进度 Log | Log pane / 可能新 Tab | `[DFU] Firmware file opened`… | ISSUE#204 | P3 |
| NRF-DFU-06 | **Multi-image DFU** (nRF5340) | DFU 流程内 | 4.25.0+ | REL-4.25.0 | P3 |
| NRF-DFU-07 | McuMgr **选 .bin** | 同 DFU 图标 | Log 出现 McuMgr；4.29.0 进度图回归 4.29.1 修复 | ISSUE#204 · ISSUE#225 · DZ-116934 | P3 |
| NRF-DFU-08 | `<mcu mode=` Tests only | 无 in-app UI | TEST_AND_CONFIRM / TEST_ONLY / CONFIRM_ONLY / NONE | Automated tests README | P3 |
| NRF-DFU-09 | **Keep bond** | DFU 流程选项（非 Settings） | 默认 ON | Toolbox ISSUE#44 | — |
| NRF-DFU-10 | **Disable resume** Secure DFU | DFU 选项 | 4.24.2+ | REL-4.24.2 | — |
| NRF-DFU-11 | **Force scan for bootloader** Legacy | DFU 选项 | 4.24.2+ | REL-4.24.2 | — |
| NRF-DFU-12 | DFU 后 **Refresh services** | Connection ⋮ | 换固件后 GATT 仍旧时 | ISSUE#212 | BT-GATT-11 P2 |
| NRF-DFU-13 | DFU 权限 | Scanner 先扫触发 Location/SCAN | Fresh install 可能不弹 Location | ISSUE#184 · DFU-Library README | P0 对照 |
| NRF-DFU-14 | **SUIT** 逐步 UI | DFU 图标→Picker | PARTIAL；完整在 Device Manager | REL-4.29.1 · PLAY Device Manager | P3 |

**`<dfu>` XML type 属性**：1=SoftDevice，2=Bootloader，4=Application，0=auto（ZIP 默认）— Automated tests README。

---

## 17. Eddystone / iBeacon / Physical Web（NRF-EDDY-*）

| ID | 功能 | UI 位置 | 行为 | Evidence URL | YoWire 映射 |
| --- | --- | --- | --- | --- | --- |
| NRF-EDDY-01 | Eddystone 广播解析 | Scanner 展开 | README Features | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md | **跳过** |
| NRF-EDDY-02 | Eddystone EID 解密 | Scanner/GATT | 同上 | 同上 | **跳过** |
| NRF-EDDY-03 | Eddystone Config Service | GATT CLIENT | unlock-eddystone 宏 | Macros README | **跳过** |
| NRF-EDDY-04 | Physical Web **OPEN** | Scanner S-10 | 打开 URL | documentation/README.md | **跳过** |
| NRF-EDDY-05 | iBeacon 解析 | Scanner 解析器 | release/社区 | REL-4.25.0 解析器扩展 | P2 可选 |

---

## 18. Release Notes 4.25.0 – 4.29.1 功能→UI 映射（节选）

| 版本 | 功能 | UI 落点 | Evidence URL | YoWire 优先级 |
| --- | --- | --- | --- | --- |
| 4.29.1 | SUIT over SMP DFU | DFU 图标流程 | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.29.1 | P3 |
| 4.29.1 | 第二 Connection Tab | Connection Tab / ⋮ Open tab | 同上 · ISSUE#85 | P2 |
| 4.29.1 | Discoverable flag | Advertiser 编辑器 | 同上 | P2 |
| 4.29.1 | Service Solicitation UUID | Advertiser | 同上 | P2 |
| 4.29.1 | 更多 AD/GATT 解析器 | Scanner 蓝标题 / GATT | 同上 | P1 |
| 4.28.0 | Automated Tests `<mcu>` | ADB only | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/v4.28.0 | P3 |
| 4.27.1 | 更多 SMP Characteristic 写入 | GATT Write | REL-4.27.1 | P3 |
| 4.26.0 | Detail RSSI 导出 | RSSI 图 | REL-4.26.0 | P1 |
| 4.25.4 | Big Endian Write | Write Dialog | REL-4.25.4 | P1 |
| 4.25.3 | 排除 Samsung/Google | Filter | REL-4.25.3 | P1 |
| 4.25.2 | RW abort on connect 可选 | Settings→Connectivity | ISSUE#145 | P1 |
| 4.25.0 | Only connectable / Adv Extension / Coded scan | Settings→Scanner | REL-4.25.0 | P1–P2 |
| 4.24.3 | Log menu options fixed | Log 底栏四图标 | REL-4.24.3 · ISSUE#93 | P1 |

---

## 19. YoWire 采纳矩阵（Adopt vs Skip）

| 类别 | **采纳（Adopt）** | **跳过 / 不依赖（Skip）** | 理由 |
| --- | --- | --- | --- |
| **GATT 核心** | Read/Write/Notify/Indicate/Desc/MTU/Log pane/stopScan connect | — | P0 调试闭环 · `22-v2` §1 |
| **扫描深度** | Filter 九维 + **Mfg Mask（YoWire 增值）** + RAW + RSSI 导出 | Physical Web OPEN | PRD §7.2 Mask 为 P0；Physical Web 已过时 |
| **连接专家** | Reliable Write、Parse UUIDs、PHY/优先级、Refresh、CONNECT⋮ | 第二 Connection Tab（宽屏用双 pane 替代） | P1 专家模式 · `21-v2` §5 |
| **设置** | Connectivity 4 + Scanner 9 → **蓝牙 ⚙** 分组 | Theme/Logger/DFU 默认路径 | nRF 无后者 · `09-v2` Δ-2 |
| **日志** | Copy/Save/Share/Clear + SessionLog TXT/CSV/JSON | **nRF Logger 依赖** | 模块自治 SessionLog · `00-UI架构` |
| **命令自动化** | v1 单命令收藏（read/write/subscribe） | 完整 28-tag Macro 引擎 + ADB Tests UI | P1 单命令 / P3 全引擎 |
| **实验室** | 架构预留 Advertiser/GATT Server/CLONE | Eddystone unlock 全套 | P3 门控 · Nordic 生态专用 |
| **DFU** | 架构预留 / 专家向导（Legacy+Secure 子集） | SUIT 完整 UI、McuMgr mode 主 App UI | Device Manager 边界 · `13-v2` §2.3 |
| **IA** | 840vp A/B/C 三分栏（B 列表 C GATT+Log） | nRF 单列手机 IA 照搬 | `10` 840vp 线框 · BT-GATT-18 |

### 19.1 优先级汇总（相对 nRF 全量）

| 优先级 | 采纳范围 |
| --- | --- |
| **P0** | S-01/04/07、Filter 核心、GATT R/W/N/I、MTU、Log+导出、stopScan connect、Mask 过滤（YoWire 独有） |
| **P1** | S-05/06/11/12、SET-SCAN/CONN 大部分、CM Reliable Write/Parse/PHY、单命令收藏、Log 四图标 |
| **P2** | S-08 MORE 曲线、Refresh、Continuous scan、Show incoming、840vp 布局 |
| **P3** | Advertiser/GATT Server/Macros 全引擎/ADB Tests/DFU 四协议/Eddystone/TIMELINE/CLONE |

---

## 20. 已知缺口：nRF Connect vs YoWire PRD

| 缺口 ID | nRF 现状 | YoWire PRD 要求 | Gap | Evidence URL | 设计应对 |
| --- | --- | --- | --- | --- | --- |
| **GAP-MASK** | 仅广播 HEX 子串 + 排除类型；**无 Mfg Data Mask UI** | BT-GATT-02 Mask 级过滤 | **P0 YoWire 增值** | `22-v2` §1 · `03-蓝牙PRD` §7.2 | Filter Sheet + 蓝牙 ⚙ 预设 |
| **GAP-840** | 官方无 HarmonyOS/840vp 三分栏 IA | BT-GATT-18 A/B/C | **P1 布局差** | `10-HarmonyOS-840vp-蓝牙` · `07-宽屏规范` | B≤3 按钮 C≤6 工具栏 |
| **GAP-STOP** | CONNECT 不强制 stopScan | 连接前必须 stopScan | **P0 行为差** | `08-v2` · PRD UART-06 | B 栏 SCAN/STOP toggle |
| **GAP-LOGFMT** | 单文件 SAVE + Logger DB | TXT/CSV/JSON 统一 SessionLog | **P0 格式差** | `02-统一日志PRD` · BT-GATT-19 | 蓝牙 ⚙·会话与日志 |
| **GAP-UUIDCPY** | GATT 树无一键 Copy | 调试效率 | **P1** | DZ-66939 · `21-v2` §5 | 长按复制 + Log 解析 |
| **GAP-SUIT** | 主 App SUIT 轻量；完整在 Device Manager | PRD 未承诺 DFU | **P3** | REL-4.29.1 · PLAY Device Manager | v1 不纳入 |
| **GAP-MACROUI** | 完整 FAB+Sheet+28 op | v1 单命令；P3 全引擎 | **P1/P3 分期** | Macros README | 蓝牙 ⚙·命令与面板 |
| **GAP-ADB** | Automated Tests 仅 PC ADB | 无 ADB UI 要求 | **P3 架构预留** | Automated tests README | 不做 in-app Tests |
| **GAP-SPP** | nRF 无经典蓝牙 SPP | BT-SPP-* 全模块 | **N/A** | `19-经典SPP` | YoWire 独立模块 |
| **GAP-ORDER** | Connection ⋮ 菜单顺序未知 | — | 文档级缺口 | `21-v2` STILL_UNKNOWN | Play 4.29.1 录屏下一阶 |

---

## 21. 证据索引（Evidence URL 主清单）

| 键 | URL |
| --- | --- |
| DOC-README | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/documentation/README.md |
| DOC-ROOT | https://raw.githubusercontent.com/NordicSemiconductor/Android-nRF-Connect/main/README.md |
| DOC-MACROS | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Macros/README.md |
| DOC-TESTS | https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/main/documentation/Automated%20tests/README.md |
| DOC-TESTS-TREE | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation/Automated%20tests |
| DOC-TREE | https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/main/documentation |
| REL-4.29.1 | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.29.1 |
| REL-4.25.0 | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/version_4.25.0 |
| REL-4.24.3 | https://github.com/NordicSemiconductor/Android-nRF-Connect/releases/tag/v4.24.3 |
| PLAY-MCP | https://play.google.com/store/apps/details?id=no.nordicsemi.android.mcp |
| PLAY-LOGGER | https://play.google.com/store/apps/details?id=no.nordicsemi.android.log |
| PLAY-DM | https://play.google.com/store/apps/details?id=no.nordicsemi.android.nrfconnectdevicemanager |
| ISSUE#93 | https://github.com/NordicSemiconductor/Android-nRF-Connect/issues/93 |
| ISSUE#145 | https://github.com/NordicSemiconductor/Android-nRF-Connect/issues/145 |
| ISSUE#184 | https://github.com/NordicSemiconductor/Android-nRF-Connect/issues/184 |
| DZ-108836 | https://devzone.nordicsemi.com/f/nordic-q-a/108836/ |
| DZ-86964 | https://devzone.nordicsemi.com/f/nordic-q-a/86964/ |
| LOCAL-01 | `.research/feature-inventory/01-nRF-Connect-BLE-全量功能清单-v2.md` |
| LOCAL-08 | `.research/feature-inventory/08-nRF-Connect-Scanner到Connection逐步流程-v2.md` |
| LOCAL-09 | `.research/feature-inventory/09-nRF-Connect-Settings与ReleaseNotes-v2.md` |
| LOCAL-11 | `.research/feature-inventory/11-nRF-Connect-Macros-28操作逐步流程-v2.md` |
| LOCAL-13 | `.research/feature-inventory/13-nRF-Connect-DFU与Connection菜单-v2.md` |
| LOCAL-21 | `.research/feature-inventory/21-nRF-Connect-UNKNOWN项交叉验证-v2.md` |
| LOCAL-22 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` |

---

## 22. 变更日志

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初稿：自 `.research/feature-inventory/01/08/09/11/13/21` + Nordic GitHub documentation 穷尽编目；NRF-* ID 体系；Macros 28 + Tests 27 全表；YoWire 采纳矩阵与 PRD 缺口 |

---

**下一阶（非本文阻塞）**：Play Store 4.29.1 Settings 全页录屏；Connection ⋮ 固定顺序；SUIT 主 App 逐步 confirm 对话框；Prompt before save 是否存在。
