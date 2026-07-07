# 03 — WiFiAnalyzer 逐步对照 YoWire

> **状态**：深研草稿，未定稿  
> **版本**：v0.1 · 2026-07-03  
> **竞品**：[04-WiFiAnalyzer-Android-全量功能清单.md](../../01-功能清单/09-竞品APP功能清单/04-WiFiAnalyzer-Android-全量功能清单.md)  
> **YoWire 流程**：[01-环境分析逐步交互流程.md](../03-WiFi模块/01-环境分析逐步交互流程.md)  
> **深研**：`.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` · `12-WiFi与网络调试-逐步流程-v2.md`

---

## 0. 映射总览

| 竞品流程 | 竞品步号 | WiFiAnalyzer 屏幕 | YoWire 文档章节 | YoWire 步号域 |
| --- | --- | --- | --- | --- |
| 冷启动 AP 列表 | F-01 | WFA-SCR-01 Access Points | 01 §3 F01-* | `ApListView` |
| 暂停/恢复扫描 | F-02 | Toolbar action_scanner | 01 §4 F02-* | `btnScanToggle` |
| Drawer 导航 | F-03 | 9 Drawer 项 | 01 §5（合并 Sub-Tab） | `SubTab_*` |
| Bottom 四 Tab | F-04 | Bottom Nav 4 | 01 §5 | `SegmentedControl_envAnalysis` 内 Sub-Tab |
| Toolbar Band | F-05 | action_wifi_band | 01 §6 · Rating/Graph | `bandSubmenu` |
| **Filter Apply/Reset/Close** | **F-06** | Filter AlertDialog 三按钮 | 01 §6 FL-* | `btnFilterApply/Reset/Close` |
| AP 详情 | F-07 | WiFiDetailPopup | 01 §7 | `ApDetailSheet` |
| Channel Rating | F-08 | WFA-SCR-02 | 01 §8 | `SubTab_channelRating` |
| Channel Graph | F-09 | WFA-SCR-03 | 01 §9 | `SubTab_channelGraph` |
| Time Graph | F-10 | WFA-SCR-04 | 01 §10 | `SubTab_timeGraph` |
| Export | F-11 | ExportItem Share | 01 §11 | `btnExportAp` |
| Settings | F-12 | settings.xml 13 项 | [04-WiFi设置](../03-WiFi模块/04-WiFi模块设置与会话命令流程.md) | SET-* |
| Channel Available | F-13 | WFA-SCR-07 | 01 §12 | `SubTab_channelAvailable` |
| Vendors OUI | F-14 | WFA-SCR-08 | 01 §13 | `VendorLookupPage` |
| Connection 条 | F-15 | ConnectionView | 01 §5 ST-5 · §14 | `ConnectionView` |
| 权限/Location | F-16 | MainActivity 权限 | 01 §2 步4～5 | `CapabilityBanner_wifi` |

**YoWire 显式 GAP**：

| GAP | WiFiAnalyzer | YoWire |
| --- | --- | --- |
| IA | 9 屏 Drawer + Bottom 4 | Segmented 环境分析 + 4 Sub-Tab + B 常驻 AP |
| SessionLog | Export Share 一次 | ⚙·会话 多格式持久化 |
| 840vp | 单列 | B AP 列表 + C Sub-Tab（doc 16） |

---

## 1. F-01 冷启动 → AP 列表

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-01-1 | 启动 App | MainActivity.onCreate 主题 | 步1～2 | `TabItem_wifi` · `SegmentedControl_envAnalysis` | [01 §2](../03-WiFi模块/01-环境分析逐步交互流程.md) | **IA 差**：YoWire WiFi Tab 内 Segmented |
| F-01-2 | 权限 Dialog | 未 granted → finish() | 步4～5 | 系统权限 · `CapabilityBanner_wifi` | 01 §2 | HarmonyOS 文案；可不 finish |
| F-01-3 | onStart resume 扫描 | scannerService.resume() | F01-2 | `ScannerService` | 01 §3 | 对齐 |
| F-01-4 | 默认 ACCESS_POINTS | settings.selectedMenu | F01-1 | `ApListView` | 01 §3 | 对齐 |
| F-01-5 | 列表周期刷新 | PeriodicScan 默认 5s | F01-3～5 | `ApListAdapter` · `scanSpeedPreference` | 01 §3 | 对齐 WF-ENV-01 |
| F-01-6 | Connection 条 | main_connection | F01-4 · ST-5 | `ConnectionView` | 01 §2 · §5 | 对齐；840vp 提升 C Sub-Tab |
| F-01-7 | GroupBy 展开 | ExpandableListView | AP 步 | `ApListGroupHeader` | 01 §7 | 对齐 WFA-SET-03 |

---

## 2. F-02 暂停/恢复扫描

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-02-1 | 点 action_scanner pause | ScannerService.toggle OFF | F02-1 · 步7 | `btnScanToggle` | 01 §4 | 对齐 |
| F-02-2 | 图标变 play | ScannerSwitch 更新 | F02-2 | `btnScanToggle` | 01 §4 | 对齐 |
| F-02-3 | 再点恢复 | resume + pause 图标 | F02-3 | `btnScanToggle` | 01 §4 | 对齐 |
| F-02-4 | 暂停冻结列表 | 无新 tick | F02-4 | `ApListView` | 01 §4 | 对齐 |

---

## 3. F-03 / F-04 导航 → Sub-Tab

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-03-1 | 打开 Drawer | DrawerNavigation | — | 手机 Sub-Tab 替代 | 01 §5 | **IA 差** |
| F-03-2 | 点 Drawer 项 | activateNavigationMenu | ST-1～5 | `SubTab_apList` 等 | 01 §5.1 | 四主 Tab 映射 Sub-Tab |
| F-03-3 | saveSelectedMenu | Settings 持久化 | ST-6 | `NavigationController` | 01 §5 | 对齐 |
| F-03-4 | updateActionBar | Filter/Band/Scanner 可见性 | ST-6 | `NetDebugTitleBar` 组合 | 01 §5 | 对齐 NavigationOptions |
| F-04-1 | Bottom Channel Rating | ChannelRatingFragment | ST-2 | `SubTab_channelRating` | 01 §5.1 | 对齐 |
| F-04-2 | Rating 屏 Filter 隐藏 | navigationOptionRating | ST-2 | Filter 按钮 **隐藏** | 01 §5.1 · §6 注 | **关键对齐** |
| F-04-3 | Graph/Time 屏 | Filter + Band 可见 | ST-3～4 | `SubTab_channelGraph` · `SubTab_timeGraph` | 01 §5.1 | 对齐 |

---

## 4. F-05 Toolbar Band 子菜单

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-05-1 | Rating/Graph/Time 屏 Band 可见 | action_wifi_band | Band-1 | `bandSubmenu` | 01 §6 · §8～10 | 对齐 |
| F-05-2 | 点 Band 标题 | 子菜单展开 | Band-2 | `bandSubmenu` | 01 §6 | 对齐 |
| F-05-3 | 选 2.4 GHz | wiFiBandAction2 GHZ2 | Band-3 | `bandAction2_4` | 01 §6 | 对齐 |
| F-05-4 | 选 5 / 6 GHz | wiFiBandAction5/6 | Band-4 | `bandAction5` · `bandAction6` | 01 §6 | 对齐 6GHz Play 2026 |
| F-05-5 | mainActivity.update() | GraphFlipper 切换 | Band-5 | `GraphBandController` | 01 §9～10 | 对齐 |
| — | AP Tab Band 隐藏 | navigationOptionAp | ST-1 | Filter **内** Band Checkbox | 01 §6.2 | **IA 差**：AP 用 Filter 维非 Toolbar |

---

## 5. F-06 Filter — Apply / Reset / Close 专节

### 5.1 打开 Filter

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-06-1 | 点 action_filter | Filter.build().show() | FL-1 · 步8 | `btnFilter` · `FilterSheet` | 01 §6.1 | AlertDialog → Bottom Sheet |
| F-06-2 | Dialog title + icon | filter_title · ic_filter_list | FL-2 | `filterTitle` | 01 §6.1 | 对齐语义 |
| F-06-3 | inflate filter_popup.xml | 四维控件 | FL-2 | `FilterSheet` 内容 | 01 §6.2 | 对齐 |
| F-06-4 | Filter 激活 tint | navigationOptionFilterOn selected 色 | FL-3 | `btnFilter_active` | 01 §6.1 | 对齐 |

### 5.2 四维度编辑

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-06-SSID | 输入 SSID token | filterSSIDtext 空格多 token | FL-SSID | `filterSSIDtext` | 01 §6.2 | 对齐 WFA-FLT-01 |
| F-06-Band | Band 2/5/6 Checkbox | filterWifiBand2/5/6 | FL-Band | `filterWifiBand2/5/6` | 01 §6.2 | AP Tab ✓；Graph 屏 **GONE** 同竞品 |
| F-06-Strength | 0～4 档图标 | filterStrength0～4 | FL-Strength | `filterStrength0_4` | 01 §6.2 | 对齐 WFA-FLT-03 |
| F-06-Security | None/WPS/WEP/WPA/WPA2/WPA3 | filter_security.xml | FL-Security | `filterSecurityWPA3` 等 | 01 §6.2 | 对齐 WFA-FLT-04 |

### 5.3 三按钮映射（核心）

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-06-**Apply** | 点 **Apply** Positive | filtersAdapter.save() → update() | FL-Apply | `btnFilterApply` | 01 §6.3 | **1:1 对齐** 持久化并刷新 |
| F-06-**Reset** | 点 **Reset** Negative | filtersAdapter.reset() 清空四维 → update() | FL-Reset | `btnFilterReset` | 01 §6.3 | **1:1 对齐** 等同竞品 reset |
| F-06-**Close** | 点 **Close** Neutral | filtersAdapter.reload() 丢弃未保存 | FL-Close | `btnFilterClose` | 01 §6.3 | **1:1 对齐** 不 save |
| — | YoWire 清除 X | — | FL-Clear | `btnFilterClear` | 01 §6.3 | 同 Reset 快捷 |
| — | 仅收藏 | 竞品无 | FL-Fav | `filterOnlyFavorites` | 01 §6.2 | **YoWire 增值** PRD |

**实现注意**：YoWire `btnFilterClose` 必须 **reload 不 save**；`btnFilterApply` 必须 **save + update** — 与 Filter.kt L65–94 语义一致。

---

## 6. F-07 AP 详情

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-07-1 | 点 SSID / ⓘ | WiFiDetailPopup.attach | AP-D1 | `ApDetailSheet` | 01 §7 | 对齐 |
| F-07-2 | Complete/Compact | Settings ap_view | AP-D2 | `apViewDensityPreference` | 01 §7 · 04 设置 | 对齐 WFA-SET-05 |
| F-07-3 | 字段 RSSI/信道/Width/Security/距离 | Export 14 列子集 | AP-D3 | `ApDetailField_*` | 01 §7 | 对齐 WFA-AP-* |
| F-07-4 | 宽屏点 B 行 | — | W-3 | `ApListRow` → C 详情卡 | 01 §5.2 | **GAP-840** doc 16 |

---

## 7. F-08 Channel Rating

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-08-1 | 进入 Channel Rating | ChannelRatingFragment | CR-1 | `SubTab_channelRating` | 01 §8 | 对齐 |
| F-08-2 | Best Channel 卡 | 20/40/80/160/320 MHz 行 | CR-2 | `BestChannelCard` | 01 §8 | 对齐 WF-ENV-08 |
| F-08-3 | ListView 星级 | RatingBar 1～5 | CR-3 | `ChannelRatingRow` | 01 §8 | 对齐 |
| F-08-4 | 切换 Band F-05 | bestChannels 重算 | CR-4 | `bandSubmenu` | 01 §8 | 对齐 |
| F-08-5 | 扫描 tick 更新 | adapter.update | CR-5 | `PeriodicScanService` | 01 §8 | 对齐 |

---

## 8. F-09 Channel Graph

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-09-1 | 进入 Channel Graph | ChannelGraphFragment | CG-1 | `SubTab_channelGraph` | 01 §9 | 对齐 |
| F-09-2 | 三 band GraphAdapter | GraphFlipper | CG-2 | `ChannelGraphPane` | 01 §9 | 对齐 |
| F-09-3 | 2.4G 不可 pinch | scalable=false | CG-3 | `graph24FixedScale` | 01 §9 | **1:1 对齐** 源码 |
| F-09-4 | 5/6G pinch+横滑 | zoomEnabled ScrollHandler | CG-4 | `graph56ZoomScroll` | 01 §9 | 对齐 |
| F-09-5 | 点击 Marker | matchDetails <20dp | CG-5 | `graphMarkerHitTest` | 01 §9 | 对齐 |
| F-09-6 | 多 AP 同频序列弹窗 | showSequence Dialog 链 | CG-6 | `ApDetailSequence` | 01 §9 | 对齐 F-10 同源 |
| F-09-7 | Y 轴上限 | graphMaximumY 设置 | CG-7 | `graphMaxYPreference` | 01 §9 · 04 | 对齐 |

---

## 9. F-10 Time Graph

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-10-1 | 进入 Time Graph | TimeGraphFragment | TG-1 | `SubTab_timeGraph` | 01 §10 | 对齐 |
| F-10-2 | 自动追加 AP 曲线 | 无需手动选 AP | TG-2 | `TimeGraphAutoSeries` | 01 §10 | 对齐 |
| F-10-3 | X 轴 ~200 点窗口 | MAX_SCAN_COUNT | TG-3 | `timeGraphWindow` | 01 §10 | 对齐 |
| F-10-4 | 20 次未见移除 | MAX_NOT_SEEN_COUNT | TG-4 | `timeGraphCacheEvict` | 01 §10 | 对齐 |
| F-10-5 | 手机需选 AP | 竞品自动；YoWire 手机可选 | TG-5 | `ApListRow` 绑定 | 01 §10 | **宽屏差**：B 点行绑定 C |

---

## 10. F-11 Export · F-12 Settings · F-13～16

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-11-1 | Drawer Export | ExportItem Share plain text 14 列 | EX-1～5 | `btnExportAp` | 01 §11 | **增值** CSV + ⚙ SessionLog |
| F-12-1 | Settings 13 项 Preference | settings.xml | SET-* | WifiSettingsPage | [04](../03-WiFi模块/04-WiFi模块设置与会话命令流程.md) | scanSpeed/groupBy/ap_view 等 |
| F-13-1 | Channel Available | ChannelAvailableFragment | CA-1 | `SubTab_channelAvailable` | 01 §12 | 对齐；Scanner OFF |
| F-14-1 | Vendors OUI | VendorFragment | VN-1 | `VendorLookupPage` | 01 §13 | 对齐 WF-ENV-12 |
| F-15-1 | Connection 条详情 | ConnectionView 点击 | CN-1 | `ConnectionView` · `SubTab_connection` | 01 §14 | 840vp C Sub-Tab |
| F-16-1 | Location 权限 Wiki | Android 9+ 双重要求 | 步4～5 | `CapabilityBanner_wifi` | 01 §2 | HarmonyOS 对照 |

---

## 11. 840vp 与 SessionLog GAP

| 竞品 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| 单列 Fragment 切换 | Bottom+Drawer | W-1～4 | B `ApListPane_B` · C `AnalysisPane_C` | 01 §5.2 · [07-840vp](../07-多设备与断点流程/03-840vp三分栏与折叠屏接续流程.md) | doc 16 |
| Export Share 一次 | ExportItem | EX → ⚙ | `NavRow_wifiEnvSessions` | 04 · [06](../06-统一后端/01-会话日志导出逐步交互流程.md) | TXT/CSV/JSON |
| Filter Dialog 居中 | AlertDialog | FL 宽屏 | 480×560 Sheet | 01 §6 | 对齐 |

---

## 12. WFA-SCR → YoWire Sub-Tab 对照表

| WFA-SCR | 竞品屏名 | YoWire Sub-Tab | Filter | Band Toolbar | 竞品 F-流程 |
| --- | --- | --- | --- | --- | --- |
| WFA-SCR-01 | Access Points | AP 列表 / B 栏 | ✓ | Filter 内 | F-01,07,15 |
| WFA-SCR-02 | Channel Rating | 信道评分 | **✗** | ✓ | F-04,08 |
| WFA-SCR-03 | Channel Graph | 信道图表 | ✓ | ✓ | F-04,05,09 |
| WFA-SCR-04 | Time Graph | 时间图表 | ✓ | ✓ | F-04,05,10 |
| WFA-SCR-05 | Connection | 连接 Sub-Tab | — | — | F-15 |
| WFA-SCR-06 | Export | 顶栏/Drawer 导出 | — | — | F-11 |
| WFA-SCR-07 | Channel Available | 可用信道 | ✗ | ✗ | F-13 |
| WFA-SCR-08 | Vendors | OUI 查询 | ✗ | ✗ | F-14 |
| WFA-SCR-09 | Settings | WiFi ⚙ push | — | — | F-12 |

---

## 13. 验收勾选

- [ ] F-01 冷启动 AP 列表 + Connection 条  
- [ ] F-02 暂停/恢复  
- [ ] F-06 **Apply / Reset / Close** 语义与 Filter.kt 一致  
- [ ] Rating 屏 **Filter 隐藏**  
- [ ] Graph 2.4G 不可缩放 · 5/6G 可 pinch  
- [ ] Export 14 列 + ⚙ SessionLog  
- [ ] ≥840vp B 常驻 AP + C Sub-Tab  

---

## 14. 证据索引

| 键 | 路径 |
| --- | --- |
| 竞品清单 | `09/04-WiFiAnalyzer-Android-全量功能清单.md` |
| inventory 14 | `.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` |
| Filter 源码 | Filter.kt L65–94 · FiltersAdapter.kt L42–48 |
| doc 16 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |

---

## 14. WFA-SET 十三项 → WiFi ⚙ 映射

| WFA-SET ID | 竞品设置项 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- |
| WFA-SET-01 | scanSpeed 周期 | F01-5 | `scanSpeedPreference` | 01 §3 · 04 | 默认 5s 对齐 |
| WFA-SET-02 | sortBy | — | `sortByPreference` | 04 | YoWire 扩展 |
| WFA-SET-03 | groupBy | F-07-1 | `groupByPreference` | 01 §7 · 04 | ExpandableList |
| WFA-SET-04 | channelGraphType | CG-2 | `channelGraphTypePreference` | 01 §9 · 04 | 对齐 |
| WFA-SET-05 | ap_view Complete/Compact | F-07-2 | `apViewDensityPreference` | 01 §7 · 04 | 对齐 |
| WFA-SET-06 | wiFiBand 持久 | F-05 | `wifiBandPreference` | 01 §6 · 04 | Toolbar Band |
| WFA-SET-07 | graphMaximumY | CG-7 | `graphMaxYPreference` | 01 §9 · 04 | 对齐 |
| WFA-SET-08 | theme | — | 跟随系统 | 05 全局 | HarmonyOS 主题 |
| WFA-SET-09 | language | — | 应用语言 | 05 全局 | — |
| WFA-SET-10 | keepScreenOn | — | `keepScreenOnSwitch` | 04 | YoWire 扩展 |
| WFA-SET-11 | showTimeGraphXAxis | TG-3 | `timeGraphAxisPreference` | 01 §10 · 04 | 对齐 |
| WFA-SET-12 | vendorDisplay | VN-1 | `showVendorInListSwitch` | 01 §13 · 04 | WF-ENV-12 |
| WFA-SET-13 | selectedMenu 持久 | F-03-3 | `lastSubTabPreference` | 01 §5 · 04 | 对齐 |

---

## 15. Export 十四列 → YoWire 导出

| Export 列 # | 列名（WFA-EXP） | 竞品 F-11 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| ---: | --- | --- | --- | --- | --- | --- |
| 1 | Time Stamp | Share plain | EX-1 | `exportColumnTimestamp` | 01 §11 | 对齐 |
| 2 | SSID | ✓ | EX-1 | `exportColumnSsid` | 01 §11 | 对齐 |
| 3 | BSSID | ✓ | EX-1 | `exportColumnBssid` | 01 §11 | 对齐 |
| 4 | Strength | ✓ | EX-1 | `exportColumnRssi` | 01 §11 | 对齐 |
| 5–8 | Channel/Freq/Center/Width | ✓ | EX-1 | `exportColumnChannel*` | 01 §11 | WF-ENV-06 |
| 9 | Range | ✓ | EX-1 | `exportColumnRange` | 01 §11 | 对齐 |
| 10 | Distance | ✓ | EX-1 | `exportColumnDistance` | 01 §11 | 802.11mc |
| 11 | 802.11mc | ✓ | EX-1 | `exportColumnRtt` | 01 §11 | 对齐 |
| 12 | Security | ✓ | EX-1 | `exportColumnSecurity` | 01 §11 | 对齐 |
| 13 | Standard | ✓ | EX-1 | `exportColumnStandard` | 01 §11 | ax/be |
| 14 | FastRoaming | ✓ | EX-1 | `exportColumnFastRoaming` | 01 §11 | 802.11r |
| — | CSV 多会话 | 单次 Share | EX-2 | ⚙ SessionLog | 04 · 06 | **YoWire 增值** |

---

## 16. F-16 权限与 Location Service 专节

| 竞品步号 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-16-1 | 冷启动权限 | onRequestPermissionsResult | 步4 | 系统 Dialog | 01 §2 | 对齐 |
| F-16-2 | 拒绝 → finish() | 退出 App | 步5 | `CapabilityBanner_wifi` | 01 §2 | YoWire 可 Banner 非 finish |
| F-16-3 | Location Service 关 | Wiki 要求双开 | 步5 | 引导系统定位 | 01 §2 | HarmonyOS 对照 |
| F-16-4 | onStart check/resume | permissionService | F01-2 | `ScannerService.resume` | 01 §3 | 对齐 |

---

## 17. Channel Graph Marker 序列（F-09 子步扩展）

| 竞品子步 | 竞品用户动作 | 竞品控件/屏幕 | YoWire步号 | YoWire控件名 | YoWire流程文档 | 差异/增值 |
| --- | --- | --- | --- | --- | --- | --- |
| F-09-5a | 点击 Marker 近点 | touch <20dp | CG-5 | `graphMarkerHitTest` | 01 §9 | 对齐 MarkerMatching |
| F-09-5b | 单 AP 详情 Dialog | AlertDialog OK | CG-5 | `ApDetailSheet` | 01 §9 | 对齐 |
| F-09-5c | 多 AP showSequence | Dialog1 OK → Dialog2 | CG-6 | `ApDetailSequence` | 01 §9 | 对齐 WiFiDetailPopup |
| F-09-5d | 末条仅 Close | 序列结束 | CG-6 | `btnSequenceClose` | 01 §9 | 对齐 |

---

**文档元信息**

| 项 | 内容 |
| --- | --- |
| 目录 | `08-竞品逐步流程对照/` |
| 版本 | 深研草稿 v0.1 |
