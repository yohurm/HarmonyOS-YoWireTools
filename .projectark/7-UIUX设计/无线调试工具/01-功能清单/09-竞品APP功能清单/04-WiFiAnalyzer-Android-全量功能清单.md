# WiFiAnalyzer（Android）全量功能清单（竞品深研）

> **状态**：深研草稿，未定稿  
> **定位**：YoWire WiFi·环境分析子模块的 **上游竞品能力全集**；功能 ID 前缀 **WFA-***  
> **上游**：VREM WiFiAnalyzer（GPL-3.0，Kotlin）  
> **证据**：`.research/feature-inventory/05-WiFiAnalyzer-全量功能清单-v2.md` · `14-WiFiAnalyzer-源码级逐步流程-v2.md` · `12-WiFi与网络调试-逐步流程-v2.md`  
> **YoWire 产品化正文**：`03-WiFi模块/01-WiFiAnalyzer环境分析功能清单.md`（内部 W-ENV-* / W-SCR-*）  
> **显式 GAP**：无 Socket/MQTT/LAN · 无 SessionLog 持久化 · 无 840vp 三分栏 → YoWire PRD 扩展

---

## 0. 文档统计

| 维度 | 数量 | 说明 | Evidence URL |
| --- | ---: | --- | --- |
| 导航目的地 | 9 | Bottom 4 + Drawer 5 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/blob/master/README.md |
| 屏幕 WFA-SCR-* | 9 | 含 Export 动作屏 | `14-v2` §0.1 · NavigationMenu.kt |
| Settings WFA-SET-* | 13 | settings.xml Preference | `14-v2` §12 · settings.xml |
| Filter 维度 | 4 | SSID / Band / Strength / Security | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html |
| Filter 按钮 | 3 | Apply / Reset / Close | `14-v2` §6.3 · Filter.kt |
| Export 列 | 14 | 管道 `\|` 分隔 plain text | `14-v2` §11 · Export.kt |
| 逐步流程 F-* | 16 | 源码级控件走查 | `.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` |
| YoWire 映射 | WF-ENV-01～15 | PRD §5–§6 | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` |

---

## 1. 应用元信息（WFA-APP-*）

| 字段 ID | 字段 | 值 | Evidence URL |
| --- | --- | --- | --- |
| WFA-APP-01 | 应用名称 | WiFiAnalyzer (open-source) | https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer |
| WFA-APP-02 | 包名 | `com.vrem.wifianalyzer` | 同上 |
| WFA-APP-03 | 开源仓库 | VREMSoftwareDevelopment/WiFiAnalyzer | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer |
| WFA-APP-04 | 许可 | GPL-3.0 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/blob/master/LICENSE |
| WFA-APP-05 | Play 更新 | **2026-01-10**（Android 16 API 36、6G、OUI 更新） | https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer |
| WFA-APP-06 | 用户手册 | 在线 USER_MANUAL | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html |
| WFA-APP-07 | 官方能力页 | Features / FAQ | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/#features |
| WFA-APP-08 | 定位权限 Wiki | Android 9+ Location + Location Service | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/wiki/Location-Service-Permission-Requirements |
| WFA-APP-09 | 深研源码路径 | `.research/reference-apps/WiFiAnalyzer/`（若已 clone） | `14-v2` §0 |

### 1.1 Play Store 2025–2026 公开特性摘要

| Play / 发行说明要点 | WFA 映射 | YoWire WF-ENV | Evidence URL |
| --- | --- | --- | --- |
| **2.4 / 5 / 6 GHz** 三 band 扫描与图表 | WFA-SCR-01～04 · WFA-FLT-02 | WF-ENV-06 | https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer |
| **HT / VHT / HE** 信道宽度 20/40/80/160/320 MHz | WFA-AP-06 · WFA-CRT-01 | WF-ENV-06/08 | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html |
| **802.11mc 距离估算** | WFA-AP-11 · WFA-EXP-COL-10 | WF-ENV-01 | 同上 §Estimated Distance |
| **OUI 厂商** Vendor 屏 + 列表旁显示 | WFA-SCR-08 · WFA-VND-* | WF-ENV-12 | 同上 §Vendor/OUI Lookup |
| Filter：Band / Strength / Security / SSID | WFA-FLT-* | WF-ENV-04 | 同上 §Filtering |
| Export AP 详情 | WFA-SCR-06 · WFA-EXP-* | WF-ENV-11 | 同上 §Export |
| Android 16 (Baklava) 支持 | WFA-APP-05 | — | Play What's New 2026-01 |
| 无广告、无数据收集（Play 隐私标签） | — | — | Play 商店页 |

---

## 2. 信息架构（IA）与导航

### 2.1 全局壳层

```text
WiFiAnalyzer（Android）
├── Toolbar（optionmenu.xml）
│   ├── action_scanner      暂停/恢复 PeriodicScan
│   ├── action_filter       Filter AlertDialog（部分屏隐藏）
│   └── action_wifi_band    2.4 / 5 / 6 GHz 子菜单（AP 屏隐藏）
├── main_connection         Connection 条（仅 AP 屏显示）
├── Fragment 内容区
├── Bottom Navigation（4 主 Tab）
│   ├── Access Points
│   ├── Channel Rating
│   ├── Channel Graph
│   └── Time Graph
└── Navigation Drawer（9 项）
    ├── Access Points / Channel Rating / Channel Graph / Time Graph（重复 Bottom）
    ├── Export（无 Fragment，直接分享）
    ├── Channel Available
    ├── Vendors
    ├── Settings
    └── About
```

| IA ID | 区域 | 源码 enum / 资源 | Evidence URL |
| --- | --- | --- | --- |
| WFA-IA-01 | Bottom Nav 四 Tab | `NavigationMenu` ACCESS_POINTS / CHANNEL_RATING / CHANNEL_GRAPH / TIME_GRAPH | `14-v2` §0.1 |
| WFA-IA-02 | Drawer 九目的地 | `NavigationMenu.kt` L39–114 | 同上 |
| WFA-IA-03 | Toolbar 三动作 | `optionmenu.xml` · `OptionAction.kt` | `14-v2` §0.2 |
| WFA-IA-04 | Connection 条 | `ConnectionView` · `main_connection` | `14-v2` §15 |
| WFA-IA-05 | Settings Preference | `SettingsFragment` → `R.xml.settings` | `14-v2` §12 |

### 2.2 九屏元数据总表（WFA-SCR-*）

| 屏幕 ID | 屏幕名称 | Bottom Tab | Drawer | Connection 条 | Filter | Band 子菜单 | Scanner | 主 Fragment / 动作 | F-流程 | Evidence URL |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **WFA-SCR-01** | Access Points | ✓ | ✓ | **显示** | ON | 隐藏 | ON | `AccessPointsFragment` | F-01,07,15 | `NavigationOptions.kt` L20–26 |
| **WFA-SCR-02** | Channel Rating | ✓ | ✓ | 隐藏 | **隐藏** | ON | ON | `ChannelRatingFragment` | F-04,08 | `NavigationOptions.kt` L44–50 |
| **WFA-SCR-03** | Channel Graph | ✓ | ✓ | 隐藏 | ON | ON | ON | `ChannelGraphFragment` | F-04,05,09 | 同上 |
| **WFA-SCR-04** | Time Graph | ✓ | ✓ | 隐藏 | ON | ON | ON | `TimeGraphFragment` | F-04,05,10 | 同上 |
| **WFA-SCR-05** | Connection | — | — | **AP 屏内嵌** | — | — | — | `ConnectionView` | F-15 | `14-v2` §15 |
| **WFA-SCR-06** | Export | — | ✓ | — | — | — | — | `ExportItem.activate()` | F-11 | `ExportItem.kt` |
| **WFA-SCR-07** | Channel Available | — | ✓ | 隐藏 | 隐藏 | 隐藏 | OFF | `ChannelAvailableFragment` | F-13 | `NavigationMenu.kt` L90–95 |
| **WFA-SCR-08** | Vendors (OUI) | — | ✓ | 隐藏 | 隐藏 | 隐藏 | OFF | `VendorFragment` | F-14 | `NavigationMenu.kt` L96–101 |
| **WFA-SCR-09** | Settings | — | ✓ | 隐藏 | — | — | — | `SettingsFragment` | F-12 | settings.xml |
| **WFA-SCR-10** | About | — | ✓ | 隐藏 | — | — | — | About 屏 | — | Drawer About |

> **Note**：Connection 非独立 Bottom Tab，而是 **WFA-SCR-01** 顶区 + Settings·Connection view 控制；YoWire 840vp 将其提升为 C Sub-Tab（WF-ENV-14）。

### 2.3 Drawer 菜单项枚举（WFA-NAV-*）

| Drawer ID | 菜单文案（典型） | 导航目标 | Bottom 重复 | 持久化 selectedMenu | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| WFA-NAV-01 | Access Points | WFA-SCR-01 | ✓ | ✓ | `NavigationMenu.kt` |
| WFA-NAV-02 | Channel Rating | WFA-SCR-02 | ✓ | ✓ | 同上 |
| WFA-NAV-03 | Channel Graph | WFA-SCR-03 | ✓ | ✓ | 同上 |
| WFA-NAV-04 | Time Graph | WFA-SCR-04 | ✓ | ✓ | 同上 |
| WFA-NAV-05 | Export | WFA-SCR-06 动作 | — | — | `ExportItem.kt` |
| WFA-NAV-06 | Channel Available | WFA-SCR-07 | — | — | F-13 |
| WFA-NAV-07 | Vendors | WFA-SCR-08 | — | — | F-14 |
| WFA-NAV-08 | Settings | WFA-SCR-09 | — | — | F-12 |
| WFA-NAV-09 | About | WFA-SCR-10 | — | — | — |

**Drawer 交互逐步**（F-03）：

| 步 | 用户动作 | 系统行为 | Evidence URL |
| --- | --- | --- | --- |
| 1 | 左滑 / 汉堡图标 | `DrawerNavigation` 打开 | `MainActivity.kt` L138–142 |
| 2 | 点 Drawer 项 | `onNavigationItemSelected` → `NavigationMenu.find(id)` | 同上 |
| 3 | | `closeDrawer()` → `activateNavigationMenu()` 切换 Fragment | 同上 |
| 4 | | 四主 Tab → `saveSelectedMenu()` 持久化 | `Settings.kt` L106–113 |
| 5 | | `updateActionBar()` 刷新 Filter/Band/Scanner 可见性 | `NavigationOptions.kt` |

---

## 3. WFA-SCR-01 Access Points（AP 列表）

### 3.1 列表字段（WFA-AP-*）

| 字段 ID | 字段 | 列表 Compact | 详情 Complete | Export 列 | YoWire WF-ENV | Evidence URL |
| --- | --- | --- | --- | --- | --- | --- |
| WFA-AP-01 | SSID | ✓ 主标题 | ✓ | 列 2 | WF-ENV-01 | USER_MANUAL §Basic Operations |
| WFA-AP-02 | BSSID | ✓ | ✓ | 列 3 | WF-ENV-02 | Export.kt |
| WFA-AP-03 | RSSI (dBm) | ✓ 副标题 | ✓ | 列 4 Strength | WF-ENV-01 | USER_MANUAL §Signal Strength |
| WFA-AP-04 | Primary Channel | ✓ | ✓ | 列 5 | WF-ENV-01 | Export.kt |
| WFA-AP-05 | Primary Frequency | 详情 | ✓ | 列 6 | WF-ENV-01 | Export.kt |
| WFA-AP-06 | Center Channel / Frequency | 详情 | ✓ | 列 7–8 | WF-ENV-06 | USER_MANUAL §HT/VHT |
| WFA-AP-07 | Width (Range) | 详情 | ✓ | 列 9 | WF-ENV-06 | 20–320 MHz |
| WFA-AP-08 | Security | ✓ 图标 | ✓ | 列 12 | WF-ENV-04 | USER_MANUAL Security Icons |
| WFA-AP-09 | Standard (802.11) | 详情 Android 11+ | ✓ | 列 13 | WF-ENV-01 | USER_MANUAL Wi-Fi Standards |
| WFA-AP-10 | Fast Roaming (802.11r 等) | 详情 | ✓ | 列 14 FastRoaming | WF-ENV-01 | Export.kt |
| WFA-AP-11 | Distance 估算 | Complete view | ✓ | 列 10 | WF-ENV-01 | USER_MANUAL §Estimated Distance |
| WFA-AP-12 | 802.11mc (RTT) | 详情 | ✓ | 列 11 | WF-ENV-01 | Export.kt |
| WFA-AP-13 | Vendor / OUI | 列表旁（若已知） | ✓ | — | WF-ENV-12 | USER_MANUAL §Vendor/OUI |
| WFA-AP-14 | Time Stamp | — | — | 列 1 | WF-ENV-15 YoWire | Export.kt |
| WFA-AP-15 | WiFi 标准枚举 | n=4 ax, n=5 ac, n=6 ax, n=7 be | — | Standard 列 | WF-ENV-01 PRD 扩展 | USER_MANUAL Standards |

**Security 图标映射**（Filter 维 WFA-FLT-04 对齐）：

| 安全类型 | 图标语义 | Filter Checkbox | Evidence URL |
| --- | --- | --- | --- |
| WPA3 (SAE) | 最高 | `filterSecurityWPA3` | filter_security.xml |
| WPA2 / WPA | 常规 | `filterSecurityWPA2` / `WPA` | 同上 |
| WEP | 弱 | `filterSecurityWEP` | 同上 |
| WPS | — | `filterSecurityWPS` | 同上 |
| None / Open | 开放 | `filterSecurityNone` | 同上 |

### 3.2 列表交互（WFA-AP-I-*）

| 交互 ID | 用户动作 | UI 控件 | 行为 | Evidence URL |
| --- | --- | --- | --- | --- |
| WFA-AP-I01 | 点 SSID / ⓘ 区域 | `WiFiDetailPopup.attach` | AlertDialog 详情；Complete/Compact 由 WFA-SET-05 决定 | `AccessPointsAdapter.kt` L48–72 |
| WFA-AP-I02 | GroupBy 展开/折叠 | ExpandableListView | 分组：None / SSID / Channel / Virtual | WFA-SET-03 |
| WFA-AP-I03 | 周期刷新 | PeriodicScan | 间隔 = WFA-SET-01 scanSpeed（默认 5s） | `Settings.kt` L54–58 |
| WFA-AP-I04 | 长按（若启用） | 上下文 | 复制 BSSID 等（YoWire 规划） | `12-v2` W-1.3 |
| WFA-AP-I05 | 扫描 tick | `scannerService.update()` | 列表 RSSI/信道实时更新 | F-01 |

### 3.3 AP 列表逐步（F-01 / F-07）

| 步 | 用户动作 | 源码行为 | Evidence URL |
| --- | --- | --- | --- |
| 1 | 冷启动 App | 权限 → `MainActivity.onCreate` → 主题 | `MainActivity.kt` L58–87 |
| 2 | 权限未 granted | `finish()` 退出 | L100–108 |
| 3 | 默认屏 | `settings.selectedMenu()` → ACCESS_POINTS | `Settings.kt` L106–113 |
| 4 | `onResume` | `AccessPointsFragment` register adapter → `update()` | `AccessPointsFragment.kt` L62–66 |
| 5 | Connection 条 | `ConnectionView` 同 scan 注册 | F-15 |
| 6 | 点行详情 | `WiFiDetailPopup.show` | F-07 |

---

## 4. WFA-SCR-02 Channel Rating（信道评分）

| 功能 ID | 名称 | UI / 行为 | 规格 | Evidence URL |
| --- | --- | --- | --- | --- |
| WFA-CRT-01 | Best Channel 卡 | 顶部 Card | 五档带宽：**20 / 40 / 80 / 160 / 320 MHz** 推荐信道号 | `ChannelRatingAdapter.kt` L63–144 |
| WFA-CRT-02 | 星级 ListView | 每行信道 | 信道号 · AP 数 · 带宽 · **RatingBar 1–5 星**（色随 Strength） | 同上 |
| WFA-CRT-03 | Band 切换 | Toolbar `action_wifi_band` | 2.4/5/6G 重算 `bestChannels()` | F-05 |
| WFA-CRT-04 | 2.4G 无推荐 | alternate 文案 | country + 拥挤度 | F-08 |
| WFA-CRT-05 | **无 Filter** | Toolbar | `navigationOptionRating` 隐藏 filter | `NavigationOptions.kt` L44–50 |
| WFA-CRT-06 | 扫描驱动刷新 | 每 PeriodicScan tick | `ChannelRatingAdapter.update` | F-08 |

**YoWire 映射**：WFA-CRT-* → **WF-ENV-08**（P1 后续增强）；840vp C Sub-Tab「评分」。

| WFA ID | YoWire ID | 分级 | Evidence URL |
| --- | --- | --- | --- |
| WFA-CRT-01～06 | WF-ENV-08 | P1 | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html §Channel Rating |

---

## 5. WFA-SCR-03 Channel Graph（信道图）

| 功能 ID | 名称 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| WFA-CHG-01 | 三 band GraphFlipper | 每 band 一 `ChannelGraph` | `ChannelGraph.kt` |
| WFA-CHG-02 | 2.4 GHz **不可缩放** | `scalable=false` | L120–121 |
| WFA-CHG-03 | 5 / 6 GHz pinch + 横滑 | `zoomEnabled` + `ScrollHandler` | USER_MANUAL §Channel Graph |
| WFA-CHG-04 | X 轴信道 / Y 轴 dBm | 柱宽 = 信道占用宽度 | 同上 |
| WFA-CHG-05 | Marker 点击 | touch < **20dp** → AP 详情 | `MarkerMatching.kt` L44–61 |
| WFA-CHG-06 | 多 AP 同频点 | `WiFiDetailPopup.showSequence` 序列 Dialog | `WiFiDetailPopup.kt` L40–64 |
| WFA-CHG-07 | Y 轴上限 | WFA-SET-06 graphMaximumY | WFA-SET-06 |
| WFA-CHG-08 | Filter 生效 | 经 Filter 后 wiFiDetails 绘图 | F-09 |

**逐步（F-09）**：

| 步 | 动作 | 结果 | Evidence URL |
| --- | --- | --- | --- |
| 1 | Bottom/Drawer → Channel Graph | `GraphAdapter` 建三 band 图 | F-09 |
| 2 | Toolbar Band → 5 GHz | 显示 5G `ChannelGraph` | F-05 |
| 3 | pinch 缩放（5/6G） | X 轴滚动查看宽频 | USER_MANUAL |
| 4 | 点 Marker | 单 AP Dialog 或多 AP 序列 | F-09 §6–7 |

**YoWire 映射**：WFA-CHG-* → **WF-ENV-06** P0。

---

## 6. WFA-SCR-04 Time Graph（时间图）

| 功能 ID | 名称 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| WFA-TMG-01 | 自动 AP 曲线 | **无需手动选 AP**；Filter 后每个可见 AP 自动追加点 | `TimeGraph/DataManager.kt` L40–82 |
| WFA-TMG-02 | X 轴窗口 | 约 **200** 扫描点 `MAX_SCAN_COUNT` | `GraphConstants.kt` L21–22 |
| WFA-TMG-03 | AP 自动移除 | **连续 20 次**扫描未见 → 移出序列 | `TimeGraphCache.kt` L28–36 |
| WFA-TMG-04 | 曲线标签 | SSID+信道在曲线 **最右端** | `TimeGraph.kt` L89–95 |
| WFA-TMG-05 | Marker 详情 | 同 Channel Graph 序列逻辑 | F-10 |
| WFA-TMG-06 | Band + Filter | Toolbar Band 子菜单 + Filter ON | `NavigationOptions.kt` |

**USER_MANUAL 与源码差异**：手册写「Select an access point」；源码为 **全自动多 AP**（F-10）。以源码为准。

**YoWire 映射**：WFA-TMG-* → **WF-ENV-07** P0；840vp **B 选中 AP → C 时间图** 为 YoWire 增强。

---

## 7. WFA-SCR-05 Connection（当前连接）

| 功能 ID | 名称 | 显示规则 | Settings 控制 | Evidence URL |
| --- | --- | --- | --- | --- |
| WFA-CONN-01 | 可见性 | **仅 WFA-SCR-01** 显示 Connection 条 | — | `NavigationOptions.kt` L20–26 |
| WFA-CONN-02 | Complete 视图 | SSID / IP / Link speed / RSSI 等 | WFA-SET-04 Complete | settings.xml |
| WFA-CONN-03 | Compact 视图 | 精简字段 | WFA-SET-04 Compact | 同上 |
| WFA-CONN-04 | Hide | 完全隐藏 | WFA-SET-04 Hide → **recreate** | `MainReload.kt` |
| WFA-CONN-05 | 未连接空态 | 无 SSID 时提示 | — | USER_MANUAL |
| WFA-CONN-06 | 生命周期 | onPause unregister · onResume register | F-16 | `MainActivity.kt` L154–181 |

**YoWire 映射**：WFA-CONN-* → **WF-ENV-10** P0。

---

## 8. WFA-SCR-07 Channel Available（合法信道表）

| 功能 ID | 名称 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| WFA-AVL-01 | 按 country 列信道 | `countryCode()` + band 合法集 | F-13 |
| WFA-AVL-02 | Toolbar | 无 Filter / Band / Scanner 特殊项 | `navigationOptionOff` |
| WFA-AVL-03 | 与 Rating 联动 | 监管域影响 Best Channel | WFA-SET-10 |

**YoWire 映射**：WFA-AVL-* → **WF-ENV-12** P2（B「更多」或 WiFi ⚙）。

---

## 9. WFA-SCR-08 Vendors（OUI 厂商）

| 功能 ID | 名称 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| WFA-VND-01 | OUI 数据库列表 | `VendorFragment` | `NavigationMenu.kt` L96–101 |
| WFA-VND-02 | 点厂商行 | 过滤/查看使用该 OUI 的 AP | `vendor/VendorFragment.kt` |
| WFA-VND-03 | 列表内联 Vendor | AP 列表旁显示厂商名 | USER_MANUAL §Vendor/OUI |
| WFA-VND-04 | OUI DB 更新 | Play 2026-01 OUI DB update | Play What's New |

**YoWire 映射**：WFA-VND-* → **WF-ENV-12** P2。

---

## 10. Filter 四维 + 三按钮（WFA-FLT-*）

> 源码：`Filter.kt` L38–114 · `filter_popup.xml` · 仪器测试 `FilterInstrumentedTest.kt`

### 10.1 四维度

| 维度 ID | 维度 | 控件 ID | WFA-SCR-01 | WFA-SCR-02 | WFA-SCR-03/04 | 匹配规则 | Evidence URL |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **WFA-FLT-01** | SSID | `filterSSIDtext` EditText | ✓ | ✓ | ✓ | 空格分隔多 token，**部分匹配** | `SSIDFilter.kt` L55–57 |
| **WFA-FLT-02** | WiFi Band | `filterWifiBand2/5/6` Checkbox | ✓ | **GONE** | ✓（经 Toolbar Band） | 2.4 / 5 / 6 GHz | `Filter.kt` L52–56 |
| **WFA-FLT-03** | Strength | `filterStrength0`–`4` | ✓ | ✓ | ✓ | 0–4 档图标 · `StrengthFilter` | filter_strength.xml |
| **WFA-FLT-04** | Security | None/WPS/WEP/WPA/WPA2/WPA3 | ✓ | ✓ | ✓ | `SecurityFilter` | filter_security.xml |

> **Band 双轨**：AP 屏 Filter 内可选 Band；Rating/Graph/Time 屏 Filter **隐藏 Band 维**，改由 Toolbar **`action_wifi_band`** 子菜单切换当前 band（F-05）。

### 10.2 三按钮 Apply 行为

| 按钮 ID | Dialog 角色 | 行为 | 未 Apply 关闭 | Evidence URL |
| --- | --- | --- | --- | --- |
| **WFA-FLT-B01** | **Apply** (Positive) | `filtersAdapter.save()` → `mainActivity.update()` | — | `Filter.kt` L65–94 |
| **WFA-FLT-B02** | **Close** (Neutral) | `filtersAdapter.reload()` **丢弃**未保存编辑 | 等同 Cancel | 同上 |
| **WFA-FLT-B03** | **Reset** (Negative) | `filtersAdapter.reset()` 清空四维 → `update()` | — | `FiltersAdapter.kt` L42–48 |

### 10.3 Filter 激活指示

| 项 | 行为 | Evidence URL |
| --- | --- | --- |
| Toolbar filter 图标 tint | Filter 生效 → `R.color.selected` | `navigationOptionFilterOn` |
| 打开 Filter | `Filter.build().show()` AlertDialog（**非 BottomSheet**） | `Filter.kt` L38–46 |

**YoWire 映射**：WFA-FLT-* → **WF-ENV-04** P0；≥600vp **居中 Sheet** 480×560；第五维「收藏 AP」为 YoWire **WF-ENV-05**（竞品无）。

---

## 11. Toolbar 扫描与 Band（WFA-TB-*）

| 功能 ID | 控件 | 可见屏 | 行为 | Evidence URL |
| --- | --- | --- | --- | --- |
| WFA-TB-01 | `action_scanner` | Rating/Graph/Time/AP | `scannerService.toggle()` pause/play 图标 | `ScannerSwitch.kt` L29–40 |
| WFA-TB-02 | `action_filter` | AP/Graph/Time（Rating 隐藏） | 打开 WFA-FLT 对话框 | `OptionAction.kt` L27–48 |
| WFA-TB-03 | `action_wifi_band` | Rating/Graph/Time（AP 隐藏） | 子菜单 → `settings.wiFiBand(GHZ2/5/6)` → `update()` | `WiFiSwitch.kt` L32–44 |

**暂停/恢复逐步（F-02）**：

| 步 | 动作 | 结果 | Evidence URL |
| --- | --- | --- | --- |
| 1 | 点 pause 图标 | 停止 PeriodicScan | F-02 |
| 2 | 图标变 play | `ScannerSwitch` 更新 title/icon | `ScannerSwitch.kt` |
| 3 | 再点 play | `resume()` 恢复扫描 | F-02 |

**YoWire 映射**：WFA-TB-01 → **WF-ENV-03** P0。

---

## 12. Settings 十三项（WFA-SET-01～13）

> 入口：Drawer → Settings → `R.xml.settings` · `SettingsFragment.kt`

| WFA-SET-ID | settings.xml key | 用户可见名称 | 类型/选项 | 默认值域 | 影响范围 | recreate | Evidence URL |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **WFA-SET-01** | `scanSpeed` | Scan speed | ListPreference 秒 | 1–10s | PeriodicScan 间隔 | 否 | settings.xml · `Settings.kt` L54–58 |
| **WFA-SET-02** | `sortBy` | Sort by | Strength / SSID / Channel | Strength | 全 Tab 列表/图排序 | 否 | arrays.xml L28–99 |
| **WFA-SET-03** | `groupBy` | Group by | None / SSID / Channel / Virtual | None | AP ExpandableList 分组 | 否 | 同上 |
| **WFA-SET-04** | `connectionView` | Connection view | Complete / Compact / **Hide** | Complete | Connection 条样式/可见 | **是** | `MainReload.kt` L35–36 |
| **WFA-SET-05** | `apView` | AP view | Complete / Compact | Complete | 列表/详情字段密度 | 否 | USER_MANUAL §Access Point View |
| **WFA-SET-06** | `graphMaximumY` | Graph maximum Y | 0～-50 dBm（×-10 六档） | 0 | Channel/Time Graph Y 轴 | 否 | USER_MANUAL §Graph Settings |
| **WFA-SET-07** | `theme` | Theme | Dark / Light / System / **Black** | System | 全 App 主题 | **是** | USER_MANUAL §Themes |
| **WFA-SET-08** | `wifiOffOnExit` | WiFi off on exit | Switch（Android Q+ **隐藏**） | OFF | 退出关 WiFi | 否 | USER_MANUAL §Wi-Fi Control |
| **WFA-SET-09** | `keepScreenOn` | Keep screen on | Switch | OFF | Window 常亮 | 否 | 同上 |
| **WFA-SET-10** | `countryCode` | Country code | CountryPreference | 系统/用户 | 合法信道/Rating/Available | 否 | USER_MANUAL §Localization |
| **WFA-SET-11** | `language` | Language | LanguagePreference | 系统 | 界面语言 | **是** | 同上 |
| **WFA-SET-12** | `reset` | Reset | 按钮 | — | `SharedPreferences.clear()` | 否 | USER_MANUAL §Reset Settings |
| **WFA-SET-13** | `cacheOff` | Cache off (Experimental) | Switch | OFF | 扫描缓存策略 | 否 | settings.xml Experimental |

### 12.1 recreate 触发链

| 变更项 | 条件 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| WFA-SET-04 / 07 / 11 | `MainReload.shouldReload` | `MainActivity` recreate | `MainActivity.onSharedPreferenceChanged` L124–126 |
| 其他 SET | — | `mainActivity.update()` 即时刷新 | F-12 |

### 12.2 YoWire ⚙ 分组映射

| WFA-SET | YoWire WiFi ⚙ 分组 | WF-ENV | YoWire 差分 | Evidence URL |
| --- | --- | --- | --- | --- |
| 01 | 环境分析·扫描 | WF-ENV-03 | — | `03-WiFi/01` §12 |
| 02–03 | 环境分析·列表 | WF-ENV-01 | — | 同上 |
| 04–05 | 环境分析·显示 | WF-ENV-10/01 | — | 同上 |
| 06 | 环境分析·图表 | WF-ENV-06/07 | — | 同上 |
| 07 | **→ 更多 Tab·显示** | — | 迁全局 | 同上 |
| 08–09 | 环境分析·行为 | — | P2/P1 | 同上 |
| 10 | 环境分析·监管域 | WF-ENV-08/12 | — | 同上 |
| 11 | **→ 跟系统语言** | — | 不单独 Language | 同上 |
| 12 | 环境分析·危险 | — | 继承全局二次确认 | 同上 |
| 13 | 环境分析·专家 | WF-ENV-13 | Banner「最后更新时间」 | 同上 |

---

## 13. Export 十四列（WFA-EXP-*）

### 13.1 导出流水线

| 步 ID | 阶段 | 源码 | 行为 | Evidence URL |
| --- | --- | --- | --- | --- |
| WFA-EXP-01 | 触发 | Drawer → Export | `ExportItem.activate()` | `ExportItem.kt` L36–54 |
| WFA-EXP-02 | 空数据 | — | Toast `no_data` | 同上 |
| WFA-EXP-03 | 序列化 | `Export.export(wiFiDetails)` | 构建文本 | `Export.kt` L35–50 |
| WFA-EXP-04 | Header | 首行 14 列名 | `\|` 分隔 | L35–50 |
| WFA-EXP-05 | 数据行 | 每 AP 一行 | 14 字段对齐 | L92–107 |
| WFA-EXP-06 | 分享 | `ExportIntent` | `ACTION_SEND` + `text/plain` | `ExportIntent.kt` L26–44 |
| WFA-EXP-07 | Chooser | `createChooser` | 用户选目标 App | 同上 |
| WFA-EXP-08 | 建议文件名 | `{Access Points}-{yyyy/MM/dd-HH:mm:ss}` | **无固定 .csv 扩展名** | Export.kt |

### 13.2 十四列字段（管道 `\|` 分隔）

| 列 # | Header | 数据类型 | 空值/备注 | YoWire 约束 | Evidence URL |
| ---: | --- | --- | --- | --- | --- |
| 1 | Time Stamp | 扫描时间戳 | — | SessionLog 对齐 | `Export.kt` |
| 2 | SSID | string | `<unknown>` 隐藏网 | WF-ENV-01 | 同上 |
| 3 | BSSID | MAC | 权限受限可空 | WF-ENV-02 | 同上 |
| 4 | Strength (dBm) | int | — | 与列表 RSSI 一致 | 同上 |
| 5 | Primary Channel | int | — | — | 同上 |
| 6 | Primary Frequency | MHz | 含 6G | — | 同上 |
| 7 | Center Channel | int | HT/VHT 中心 | — | 同上 |
| 8 | Center Frequency | MHz | — | — | 同上 |
| 9 | Width (Range) | string | 20/40/80/160/**320** MHz | WF-ENV-06 | USER_MANUAL §Channel Width |
| 10 | Distance | estimate | 802.11mc / FSPL | WF-ENV-01 | USER_MANUAL §Estimated Distance |
| 11 | 802.11mc | flag | RTT 支持标记 | — | Export.kt |
| 12 | Security | enum | OPEN/WPA3/… | WF-ENV-04 | E-WFA-004 PR |
| 13 | Standard | 802.11 a/b/g/n/ac/ax/**be** | Android 11+ | WF-ENV-01 | USER_MANUAL Standards |
| 14 | FastRoaming | flag | 802.11r 等 | — | Export.kt |

**格式说明**（E-WFA-005）：竞品使用 **管道 `\|` 分隔 plain text**，非 RFC4180 CSV；YoWire 兼容导入 + **WiFi ⚙·会话** 提供 CSV/JSON 三格式（WF-ENV-11 / WF-ENV-15）。

| 格式议题 | WiFiAnalyzer | YoWire | Evidence URL |
| --- | --- | --- | --- |
| 分隔符 | `\|` 管道 | 管道 TXT + CSV `,` + JSON | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/issues/605 |
| SecurityTypes 列增强 | Android 13+ PR #601 | CSV 列对齐 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/pull/601 |

---

## 14. 权限与生命周期（WFA-PERM-* / WFA-LC-*）

| ID | 项 | 行为 | Evidence URL |
| --- | --- | --- | --- |
| WFA-PERM-01 | Location 运行时权限 | Android 9+ 扫描必需；拒绝 → `finish()` | Wiki Location-Service |
| WFA-PERM-02 | Location Service 开关 | 系统关闭则扫描不可用；FAQ 引导 | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/#faq |
| WFA-PERM-03 | WiFi 状态 | 读取扫描结果 | AndroidManifest |
| WFA-LC-01 | onPause | `scannerService.pause()`；unregister ConnectionView | F-16 |
| WFA-LC-02 | onResume | 权限 OK → `resume()`；register ConnectionView | F-16 |
| WFA-LC-03 | onStop | `scannerService.stop()` | F-16 |
| WFA-LC-04 | 退出关 WiFi | WFA-SET-08 启用时 | WFA-SET-08 |

**YoWire 映射**：WFA-PERM-* → **G-PERM** + **WF-ENV-02/13**；HarmonyOS 权限对照 `06-权限PRD`。

---

## 15. 逐步流程索引（F-01～F-16）

| 流程 ID | 名称 | 关联 WFA | 摘要 | Evidence URL |
| --- | --- | --- | --- | --- |
| **F-01** | 首次启动 → AP | WFA-SCR-01 | 权限 → PeriodicScan → 列表 | `14-v2` §1 |
| **F-02** | 暂停/恢复 | WFA-TB-01 | action_scanner toggle | §2 |
| **F-03** | Drawer 切换 | WFA-NAV-* | 九屏导航 | §3 |
| **F-04** | Bottom 四 Tab | WFA-SCR-01～04 | Rating 无 Filter | §4 |
| **F-05** | Toolbar Band | WFA-TB-03 | 非 Filter 内 Band | §5 |
| **F-06** | Filter | WFA-FLT-* | 四维 + Apply/Reset/Close | §6 |
| **F-07** | AP 详情 | WFA-AP-I01 | Complete/Compact | §7 |
| **F-08** | Channel Rating | WFA-CRT-* | Best Channel + 星 | §8 |
| **F-09** | Channel Graph | WFA-CHG-* | 缩放 + Marker | §9 |
| **F-10** | Time Graph | WFA-TMG-* | 200 点 + 20 次移除 | §10 |
| **F-11** | Export | WFA-EXP-* | 14 列 ACTION_SEND | §11 |
| **F-12** | Settings | WFA-SET-* | 13 项 + recreate | §12 |
| **F-13** | Channel Available | WFA-AVL-* | 合法信道表 | §13 |
| **F-14** | Vendors | WFA-VND-* | OUI 过滤 | §14 |
| **F-15** | Connection | WFA-CONN-* | AP Tab 条 | §15 |
| **F-16** | 生命周期 | WFA-LC-* | pause/resume/stop | §16 |

---

## 16. YoWire WF-ENV-* 完整映射

| WF-ENV ID | PRD 名称 | WiFiAnalyzer WFA 对照 | 分级 | YoWire 差分 | Evidence URL |
| --- | --- | --- | --- | --- | --- |
| **WF-ENV-01** | AP 列表全字段 | WFA-SCR-01 · WFA-AP-* | P0 | +WiFi 6/7 Category · 时间戳 | E-WFA-002 |
| **WF-ENV-02** | BSSID 降级 Chip | WFA-AP-02 部分 | P0 | HarmonyOS 随机 MAC 文案 | E-WFA-007 |
| **WF-ENV-03** | 周期扫描 + 暂停 | WFA-TB-01 · WFA-SET-01 | P0 | — | E-WFA-002 |
| **WF-ENV-04** | Filter 四维 + 三按钮 | WFA-FLT-* | P0 | ≥600vp Sheet · 第五维收藏 WF-ENV-05 | E-WFA-002 |
| **WF-ENV-05** | 收藏 AP Filter | **✗ 竞品无** | P1 | YoWire 增值 | PRD §5.2 |
| **WF-ENV-06** | 信道图 2.4/5/6G | WFA-CHG-* | P0 | — | E-WFA-002 |
| **WF-ENV-07** | RSSI 时间图 | WFA-TMG-* | P0 | B 选中 AP 绑定（宽屏） | E-WFA-002 |
| **WF-ENV-08** | 信道评分 | WFA-CRT-* | P1 | — | E-WFA-002 |
| **WF-ENV-09** | Settings 13 项 | WFA-SET-01～13 | P1 | Theme/Language 迁全局 | settings.xml |
| **WF-ENV-10** | Connection 条 | WFA-CONN-* | P0 | C Sub-Tab Connection | E-WFA-002 |
| **WF-ENV-11** | Export 14 列 | WFA-EXP-* | P1 | +CSV/JSON 会话归档 | E-WFA-004/005 |
| **WF-ENV-12** | Available / Vendors | WFA-AVL-* · WFA-VND-* | P2 | B「更多」或 WiFi ⚙ | E-WFA-001 |
| **WF-ENV-13** | 主动扫描 vs 缓存 | WFA-SET-13 部分 | P1 | Banner「最后更新时间」 | WFA-SET-13 |
| **WF-ENV-14** | 840vp B=AP + C 四 Tab | **✗ 手机 Bottom Nav** | P1 | doc 16 三分栏 | E-HMS-001 |
| **WF-ENV-15** | 环境 SessionLog | **✗ 仅 Export 分享** | P1 | WiFi ⚙·会话与日志 | E-HMS-002 |

---

## 17. 竞品有 · YoWire 无对标（环境分析边界）

| 能力 | WiFiAnalyzer | YoWire 落点 | Evidence URL |
| --- | --- | --- | --- |
| Socket / HTTP / MQTT | ✗ | `03-WiFi/02` PacketSender 系 | `22` §4 |
| LAN / Ping / DNS | ✗ | `03-WiFi/03` AndroidNetworkTools 系 | `12-v2` §2.3 |
| 命令 Panel | ✗ | WiFi ⚙·命令与面板 | E-HMS-002 |
| Black Theme 第四主题 | ✓ WFA-SET-07 | 全局 **更多·显示** | USER_MANUAL |

---

## 18. 联网证据索引（E-WFA-*）

| Evidence ID | URL | 本文章节 |
| --- | --- | --- |
| E-WFA-001 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/blob/master/README.md | §1–§2 |
| E-WFA-002 | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/USER_MANUAL.html | §3–§10 · §12 |
| E-WFA-003 | https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer | §1.1 · WFA-APP-05 |
| E-WFA-004 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/pull/601 | §13.2 Security 列 |
| E-WFA-005 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/issues/605 | §13 管道分隔 |
| E-WFA-006 | https://vremsoftwaredevelopment.github.io/WiFiAnalyzer/#features | §1 |
| E-WFA-007 | https://github.com/VREMSoftwareDevelopment/WiFiAnalyzer/wiki/Location-Service-Permission-Requirements | §14 WFA-PERM-* |
| E-WFA-SRC-01 | `.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` | §15 F-* |
| E-WFA-SRC-02 | `.research/feature-inventory/05-WiFiAnalyzer-全量功能清单-v2.md` | 全文 |

---

## 19. 相关文档

| 文档 | 路径 |
| --- | --- |
| YoWire 产品化清单 | `03-WiFi模块/01-WiFiAnalyzer环境分析功能清单.md` |
| 源码逐步 F-01～16 | `.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` |
| WiFi 逐步汇总 | `.research/feature-inventory/12-WiFi与网络调试-逐步流程-v2.md` |
| 840vp 线框 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |
| UI 页面设计 | `03-UI设计/03-WiFi模块/01-WiFi环境分析页面设计.md` |
| 证据注册表 | `07-联网调研证据/01-竞品版本基线与公开证据索引.md` §4 |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` §5 |
| 差距矩阵 | `.research/feature-inventory/22-YoWire-PRD与竞品能力差距矩阵-v2.md` §4 |

---

## 20. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 初版：WFA-SCR/SET/FLT/EXP 全量 · WF-ENV 映射 · Play 2026-01 证据 |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 版本 | 深研草稿 v1 |
| 功能 ID 前缀 | WFA-* |
| 行数目标 | 450+ |
| 最后更新 | 2026-07-03 |
