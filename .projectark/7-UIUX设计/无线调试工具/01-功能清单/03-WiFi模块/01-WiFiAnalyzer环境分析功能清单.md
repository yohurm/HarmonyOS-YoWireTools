# WiFiAnalyzer 环境分析功能清单

> **状态**：深研草稿  
> **上游竞品**：VREM WiFiAnalyzer（GPLv3）  
> **证据**：`.research/feature-inventory/05-WiFiAnalyzer-全量功能清单-v2.md`、`14-WiFiAnalyzer-源码级逐步流程-v2.md`、`12-WiFi与网络调试-逐步流程-v2.md`  
> **PRD 映射**：`04-WiFi模块PRD.md` §5–§6 · 差距矩阵 `22` §4（WF-ENV-01～15）  
> **YoWire 备注**：环境分析日志/导出在 **WiFi ⚙·会话与日志**；Theme 项迁入 **更多 Tab·显示**（非模块专有）

---

## 1. 文档目的

将 WiFiAnalyzer 竞品能力枚举为 YoWire **WiFi 环境分析**子模块的功能 ID 表，供 UI 设计、验收与 PRD 追溯。逐步流程引用 **F-01～F-16**（源码级，见 doc 14）。

---

## 2. 九屏导航目的地

| # | 屏幕 ID | 屏幕名称 | Bottom Tab | Drawer | Connection 条 | Toolbar 组合 | 对应流程 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `W-SCR-01` | Access Points | ✓ | ✓ | **显示** | 暂停/恢复 · Filter ON · Band 隐藏 | F-01, F-07, F-15 |
| 2 | `W-SCR-02` | Channel Rating | ✓ | ✓ | 隐藏 | 暂停/恢复 · **Filter 隐藏** · Band 子菜单 | F-04, F-08 |
| 3 | `W-SCR-03` | Channel Graph | ✓ | ✓ | 隐藏 | 暂停/恢复 · Filter ON · Band 子菜单 | F-04, F-05, F-09 |
| 4 | `W-SCR-04` | Time Graph | ✓ | ✓ | 隐藏 | 暂停/恢复 · Filter ON · Band 子菜单 | F-04, F-05, F-10 |
| 5 | `W-SCR-05` | Export | — | ✓ | — | 无 Fragment，直接分享动作 | F-11 |
| 6 | `W-SCR-06` | Channel Available | — | ✓ | 隐藏 | 无 Filter/Band/Scanner 特殊项 | F-13 |
| 7 | `W-SCR-07` | Vendors (OUI) | — | ✓ | 隐藏 | 无 | F-14 |
| 8 | `W-SCR-08` | Settings | — | ✓ | 隐藏 | Preference 屏 | F-12 |
| 9 | `W-SCR-09` | About | — | ✓ | 隐藏 | 关于屏 | — |

**YoWire IA**：840vp 下 B 栏常驻 **AP 列表**（W-SCR-01）；C 栏 Sub-Tab 映射 Rating / Graph / Time / Connection（WF-ENV-14）。Drawer 五项（Export / Available / Vendors / Settings / About）→ B「更多」或 **WiFi ⚙** 跳转（WF-ENV-12 P2）。

**证据**：`NavigationMenu.kt` L39–114；`NavigationOptions.kt` L20–50。

---

## 3. 功能 ID 总表（环境分析）

| 功能 ID | 名称 | 分级 | 竞品 | PRD | Gap | 主 UI 落点 |
| --- | --- | --- | --- | --- | --- | --- |
| W-ENV-01 | AP 列表全字段展示 | 必须 | ✓ | WF-ENV-01 | P0 | B 栏列表 |
| W-ENV-02 | BSSID 真实/随机降级 Chip | 必须 | 部分 | WF-ENV-02 | P0 | B 行 + **WiFi ⚙** 权限说明 |
| W-ENV-03 | 周期扫描 + 暂停/恢复 | 必须 | ✓ `action_scanner` | WF-ENV-03 | P0 | B 标题栏 toggle |
| W-ENV-04 | Filter 四维 + 三按钮 | 必须 | ✓ | WF-ENV-04 | P0 | ≥600vp 居中 Sheet |
| W-ENV-05 | 收藏 AP 过滤（第五维） | 后续 | ✗ | WF-ENV-05 | P1 | Filter + **WiFi ⚙·环境分析** |
| W-ENV-06 | 信道图（2.4/5/6G、Marker、缩放） | 首期优先 | ✓ | WF-ENV-06 | P0 | C Sub-Tab「信道图」 |
| W-ENV-07 | RSSI 时间图（~200 点、AP 自动移除） | 首期优先 | ✓ | WF-ENV-07 | P0 | B 选中 AP → C 时间图 |
| W-ENV-08 | 信道评分 Best Channel 卡 + 星级 | 后续增强 | ✓ | WF-ENV-08 | P1 | C Sub-Tab「评分」 |
| W-ENV-09 | Settings 13 项对齐 | 首期 | ✓ settings.xml | WF-ENV-09 | P1 | **WiFi ⚙·环境分析** |
| W-ENV-10 | Connection 条（SSID/IP/RSSI） | 必须 | ✓ | WF-ENV-10 | P0 | C 顶 Connection 条 |
| W-ENV-11 | Export 扫描快照（14 列） | 完整规划 | ✓ ACTION_SEND | WF-ENV-11 | P1 | C Export + **WiFi ⚙·会话** |
| W-ENV-12 | Channel Available / Vendors | 架构预留 | ✓ Drawer | WF-ENV-12 | P2 | B「更多」或 **WiFi ⚙** |
| W-ENV-13 | 主动扫描 vs 缓存降级 UX | 必须 | 部分 | WF-ENV-13 | P1 | Banner「最后更新时间」 |
| W-ENV-14 | 840vp B=AP + C=四 Sub-Tab | 首期 | ✗ 宽屏 | WF-ENV-14 | P1 | 三分栏 |
| W-ENV-15 | 环境扫描 SessionLog 导出 | 必须 | ✗ | WF-ENV-15 | P1 | **WiFi ⚙·会话与日志** |

---

## 4. AP 列表字段（W-ENV-01）

| 字段 ID | 字段 | WiFiAnalyzer | YoWire PRD 扩展 | 展示规则 |
| --- | --- | --- | --- | --- |
| W-AP-01 | SSID | ✓ | 隐藏网络标识 | 主标题 |
| W-AP-02 | BSSID | ✓ | 权限降级 | W-ENV-02 Chip |
| W-AP-03 | RSSI (dBm) | ✓ | 强度等级 0–4 | 副标题 + 色条 |
| W-AP-04 | Primary Channel | ✓ | — | 列表列 |
| W-AP-05 | Primary / Center Frequency | ✓ | 6G/60G | 详情 |
| W-AP-06 | Width (Range) | ✓ | 20/40/80/160/320 MHz | 详情 |
| W-AP-07 | Security | ✓ | OPEN/WEP/PSK/SAE/EAP/OWE/WAPI | Filter 维 |
| W-AP-08 | Standard (802.11) | ✓ Export 列 | a/b/g/n/ac/ax/ad | 详情 |
| W-AP-09 | Fast Roaming | ✓ Export 列 | — | 详情 |
| W-AP-10 | 802.11mc | ✓ Export 列 | — | 详情 |
| W-AP-11 | Distance | ✓ Export 列 | — | 详情（Complete view） |
| W-AP-12 | WiFi Category | — | WiFi 6/7 等 | PRD §5.1 |
| W-AP-13 | 时间戳 | — | 扫描结果时间 | PRD §5.1 |
| W-AP-14 | 厂商/OUI | Vendors 屏 | BSSID 可用时 | W-ENV-12 |

**列表交互**（F-07）：

| 步 ID | 动作 | 行为 |
| --- | --- | --- |
| W-AP-I01 | 点行 / ⓘ | AP 详情 Sheet（Complete/Compact 由 Settings·AP view 决定） |
| W-AP-I02 | 长按 | 复制 BSSID 等上下文菜单 |
| W-AP-I03 | GroupBy 展开/折叠 | ExpandableListView 分组 |
| W-AP-I04 | 宽屏 B 选中 | C 绑定 Time Graph / 详情 |

---

## 5. Filter 四维度 + 三按钮（W-ENV-04）

> 源码：`Filter.kt` L38–114；仪器测试验证三按钮 id。

| 维度 ID | 维度 | 控件 | AP Tab | 其他 Tab | 匹配规则 |
| --- | --- | --- | --- | --- | --- |
| W-FLT-01 | SSID | EditText | ✓ | ✓ | 空格分隔多 token，部分匹配 |
| W-FLT-02 | WiFi Band | Checkbox 2.4/5/6 GHz | ✓ | **GONE** | 仅 Access Points Tab |
| W-FLT-03 | Strength | 0–4 档图标 | ✓ | ✓ | `StrengthFilter` 枚举 |
| W-FLT-04 | Security | None/WPS/WEP/WPA/WPA2/WPA3 | ✓ | ✓ | `SecurityFilter` |
| W-FLT-05 | 收藏（YoWire） | Switch | ✓ | ✓ | PRD §5.2，竞品无 |

| 按钮 ID | 角色 | 行为 | 流程 |
| --- | --- | --- | --- |
| W-FLT-B01 | **Apply** (Positive) | `save()` → 刷新列表/图表 | F-06 §6.3 |
| W-FLT-B02 | **Close** (Neutral) | `reload()` 丢弃未保存编辑 | F-06 |
| W-FLT-B03 | **Reset** (Negative) | 清空四维 → 刷新 | F-06 |

**Toolbar 指示**：Filter 生效时 filter 图标 tint 为 selected（`navigationOptionFilterOn`）。

**Band 子菜单**（非 Filter 内，F-05）：Rating / Graph / Time 屏 Toolbar **`action_wifi_band`** → 2.4 / 5 / 6 GHz；AP Tab 无此项。

---

## 6. 十三项 Settings（W-ENV-09）

> 入口：Drawer → Settings → `settings.xml`；YoWire 映射 **WiFi ⚙·环境分析** 分组。

| # | Settings key | 用户可见名称 | 类型/选项 | 即时效果 | recreate |
| --- | --- | --- | --- | --- | --- |
| 1 | scanSpeed | Scan speed | ListPreference 间隔秒数 | PeriodicScan 间隔变 | 否 |
| 2 | sortBy | Sort by | Strength / SSID / Channel | 各 Tab 排序变 | 否 |
| 3 | groupBy | Group by | None / SSID / Channel / Virtual | AP 分组变 | 否 |
| 4 | connectionView | Connection view | Complete / Compact / Hide | Connection 条样式 | **是** |
| 5 | apView | AP view | Complete / Compact | 列表/详情密度 | 否 |
| 6 | graphMaximumY | Graph maximum Y | 0～-50 dBm 六档 × -10 | 图表 Y 轴上限 | 否 |
| 7 | theme | Theme | Dark / Light / System / **Black** | 全 App 主题 | **是** → **YoWire 迁全局** |
| 8 | wifiOffOnExit | WiFi off on exit | Switch（Q+ 隐藏） | 退出时关 WiFi | 否 |
| 9 | keepScreenOn | Keep screen on | Switch | 常亮 | 否 |
| 10 | countryCode | Country code | CountryPreference | 合法信道集 / Rating | 否 |
| 11 | language | Language | LanguagePreference | 界面语言 | **是** → **YoWire 跟系统** |
| 12 | reset | Reset | 按钮 | 清空 SharedPreferences | 否 |
| 13 | cacheOff | Cache off (Experimental) | Switch | 扫描缓存策略 | 否 |

**recreate 条件**（F-12）：theme / connectionView / language 变更 → `MainActivity` recreate。

---

## 7. 图表交互规格

### 7.1 Channel Graph（W-ENV-06 · F-09）

| 项 ID | 规格 |
| --- | --- |
| W-CHG-01 | 三 band 各一 `ChannelGraph`；当前 band 可见 |
| W-CHG-02 | **2.4 GHz**：`scalable=false`，不可 pinch 缩放 |
| W-CHG-03 | **5 / 6 GHz**：pinch 缩放 + 横滑 |
| W-CHG-04 | 点击 Marker：距 touch < 20dp → AP 详情 |
| W-CHG-05 | 多 AP 同频点：`WiFiDetailPopup.showSequence` 序列 Dialog |
| W-CHG-06 | Y 轴上限 = Settings `graphMaximumY` |

### 7.2 Time Graph（W-ENV-07 · F-10）

| 项 ID | 规格 |
| --- | --- |
| W-TMG-01 | 自动为每个可见 AP 追加数据点（无需手动选） |
| W-TMG-02 | X 轴窗口约 **200** 扫描点（`MAX_SCAN_COUNT`） |
| W-TMG-03 | AP **连续 20 次**扫描未见 → 从序列移除 |
| W-TMG-04 | SSID+信道标签在曲线最右端 |
| W-TMG-05 | Marker 点击同 Channel Graph 详情序列 |

### 7.3 Channel Rating（W-ENV-08 · F-08）

| 项 ID | 规格 |
| --- | --- |
| W-CRT-01 | 顶部 Best Channel 卡：20/40/80/160/320 MHz 推荐信道 |
| W-CRT-02 | ListView：信道号 · AP 数 · 带宽 · RatingBar 1–5 星 |
| W-CRT-03 | 2.4G 无推荐时 alternate 文案 |
| W-CRT-04 | **无 Filter**（`navigationOptionRating`） |

---

## 8. Export 十四列（W-ENV-11 · F-11）

| 步 | 行为 |
| --- | --- |
| 1 | Drawer / C 工具栏 → Export |
| 2 | 无数据 → Toast |
| 3 | 有数据 → `scannerService.wiFiData().wiFiDetails` → Export |
| 4 | `ACTION_SEND` + chooser；`type=text/plain` |
| 5 | 文件名 `{Access Points}-{yyyy/MM/dd-HH:mm:ss}` |

### 8.1 十四列管道分隔 CSV（`|`）

| 列 # | Header | 说明 |
| --- | --- | --- |
| 1 | Time Stamp | 扫描时间戳 |
| 2 | SSID | |
| 3 | BSSID | 受 W-ENV-02 约束 |
| 4 | Strength (dBm) | |
| 5 | Primary Channel | |
| 6 | Primary Frequency | |
| 7 | Center Channel | |
| 8 | Center Frequency | |
| 9 | Width (Range) | |
| 10 | Distance | |
| 11 | 802.11mc | |
| 12 | Security | |
| 13 | Standard | |
| 14 | FastRoaming | |

**YoWire 扩展**：**WiFi ⚙·会话** 支持 TXT / CSV / JSON 三格式持久归档（WF-ENV-11 P1）；运行时 Export 保持快速分享。

---

## 9. 逐步流程索引 F-01～F-16

| 流程 ID | 名称 | 摘要 | 本文功能 ID |
| --- | --- | --- | --- |
| **F-01** | 首次启动 → AP 列表 | 权限 → 默认 ACCESS_POINTS → PeriodicScan | W-ENV-01, W-ENV-03, W-ENV-10 |
| **F-02** | 暂停/恢复扫描 | `action_scanner` toggle | W-ENV-03 |
| **F-03** | Drawer 切换目的地 | 九屏导航 | §2 九屏表 |
| **F-04** | Bottom Nav 四主 Tab | Rating 无 Filter | W-ENV-04, W-ENV-08 |
| **F-05** | Toolbar Band 子菜单 | 非 Filter 内 Band | W-FLT-02 对照 |
| **F-06** | Filter 对话框 | 四维 + Apply/Reset/Close | W-ENV-04 |
| **F-07** | AP 列表 → 详情 | Complete/Compact | W-AP-I01 |
| **F-08** | Channel Rating | Best Channel + 星级 | W-ENV-08 |
| **F-09** | Channel Graph | 缩放 + Marker 序列 | W-ENV-06 |
| **F-10** | Time Graph | 200 点 + 20 次移除 | W-ENV-07 |
| **F-11** | Export | 14 列管道 CSV | W-ENV-11 |
| **F-12** | Settings 13 项 | 逐项操作 + recreate | W-ENV-09 |
| **F-13** | Channel Available | 合法信道表 | W-ENV-12 |
| **F-14** | Vendors OUI | 厂商 → 过滤 AP | W-ENV-12 |
| **F-15** | Connection 视图 | AP Tab 显示 / Hide 设置 | W-ENV-10 |
| **F-16** | 生命周期扫描注册 | onPause/onResume/onStop | W-ENV-03 |

**详细逐步表**：`.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md`

---

## 10. YoWire 相对竞品增量

| 竞品无 / 弱 | YoWire 要求 | 功能 ID |
| --- | --- | --- |
| 独立会话日志 | SessionLog 持久化 + 三格式导出 | W-ENV-15 |
| 收藏 AP Filter | 第五维 Filter | W-ENV-05 |
| Socket/MQTT/LAN | 见 `02-网络协议调试`、`03-LAN与网络诊断` | WF-NET-* |
| 全局 Theme Black | 迁 **更多 Tab·显示** | — |
| 840vp 三分栏 | B=AP 常驻 | W-ENV-14 |

---

## 11. 相关文档

| 文档 | 路径 |
| --- | --- |
| 竞品全量清单 | `.research/feature-inventory/05-WiFiAnalyzer-全量功能清单-v2.md` |
| 源码逐步 F-01～16 | `.research/feature-inventory/14-WiFiAnalyzer-源码级逐步流程-v2.md` |
| 840vp 线框 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |
| 页面设计 | `03-UI设计/03-WiFi模块/01-WiFi环境分析页面设计.md` |
| PRD | `.projectark/2-需求文档/无线调试工具/PRD/04-WiFi模块PRD.md` §5 |
| LAN/诊断交叉 | [`03-LAN与网络诊断功能清单.md`](03-LAN与网络诊断功能清单.md) |
| 网络协议交叉 | [`02-网络协议调试功能清单.md`](02-网络协议调试功能清单.md) |

---

## 12. Settings 十三项 — W-SET-01～W-SET-13 完整映射

> **证据**：`settings.xml` · `Settings.kt` · `SettingsFragment.kt` · `14` §12 · `05-v2`

| W-SET-ID | settings.xml key | 用户可见名称 | 类型/选项 | 默认值域 | 影响范围 | recreate | YoWire ⚙ 分组 | PRD |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **W-SET-01** | `scanSpeed` | Scan speed | ListPreference 秒 | 1–10s 档 | PeriodicScan 间隔 | 否 | **环境分析·扫描** | WF-ENV-03 |
| **W-SET-02** | `sortBy` | Sort by | Strength / SSID / Channel | Strength | 全 Tab 列表/图排序 | 否 | **环境分析·列表** | WF-ENV-01 |
| **W-SET-03** | `groupBy` | Group by | None / SSID / Channel / Virtual | None | AP ExpandableList | 否 | **环境分析·列表** | WF-ENV-01 |
| **W-SET-04** | `connectionView` | Connection view | Complete / Compact / **Hide** | Complete | Connection 条样式/可见 | **是** | **环境分析·显示** | WF-ENV-10 |
| **W-SET-05** | `apView` | AP view | Complete / Compact | Complete | 列表/详情密度 | 否 | **环境分析·显示** | WF-ENV-01 |
| **W-SET-06** | `graphMaximumY` | Graph maximum Y | 0～-50 dBm（×-10 六档） | 0 | Channel/Time Graph Y 轴 | 否 | **环境分析·图表** | WF-ENV-06/07 |
| **W-SET-07** | `theme` | Theme | Dark / Light / System / **Black** | System | 全 App 主题 | **是** | **→ 更多 Tab·显示**（非模块） | — |
| **W-SET-08** | `wifiOffOnExit` | WiFi off on exit | Switch（Android Q+ 隐藏） | OFF | 退出关 WiFi | 否 | **环境分析·行为** P2 | — |
| **W-SET-09** | `keepScreenOn` | Keep screen on | Switch | OFF | Window 常亮 | 否 | **环境分析·行为** | — |
| **W-SET-10** | `countryCode` | Country code | CountryPreference | 系统/用户 | 合法信道/Rating/Available | 否 | **环境分析·监管域** | WF-ENV-08/12 |
| **W-SET-11** | `language` | Language | LanguagePreference | 系统 | 界面语言 | **是** | **→ 跟系统**（YoWire） | — |
| **W-SET-12** | `reset` | Reset | 按钮 | — | `SharedPreferences.clear()` | 否 | **环境分析·危险** 二次确认 | — |
| **W-SET-13** | `cacheOff` | Cache off (Experimental) | Switch | OFF | 扫描缓存策略 | 否 | **环境分析·专家** | WF-ENV-13 |

**recreate 触发**（`MainReload.shouldReload`）：W-SET-04 / W-SET-07 / W-SET-11 → `MainActivity` recreate。

**YoWire 差分摘要**：

| 竞品项 | YoWire 处理 |
| --- | --- |
| Theme Black | 迁入全局 **更多·显示** |
| Language | 跟随 HarmonyOS 系统语言 |
| Reset | 继承全局「危险操作确认」 |
| cacheOff | Banner「最后更新时间」+ WF-ENV-13 主动扫描降级 |

---

## 13. 九屏 W-SCR-01～W-SCR-09 逐步走查

### 13.1 屏幕元数据总表

| W-SCR-ID | 屏幕 | 入口 | Bottom Tab | Drawer | Connection 条 | Filter | Band 子菜单 | Scanner | 主 Fragment | F-流程 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **W-SCR-01** | Access Points | 默认启动 | ✓ | ✓ | **显示** | ON | 隐藏 | ON | `AccessPointsFragment` | F-01,07,15 |
| **W-SCR-02** | Channel Rating | Bottom/Drawer | ✓ | ✓ | 隐藏 | **隐藏** | ON | ON | `ChannelRatingFragment` | F-04,08 |
| **W-SCR-03** | Channel Graph | Bottom/Drawer | ✓ | ✓ | 隐藏 | ON | ON | ON | `ChannelGraphFragment` | F-04,05,09 |
| **W-SCR-04** | Time Graph | Bottom/Drawer | ✓ | ✓ | 隐藏 | ON | ON | ON | `TimeGraphFragment` | F-04,05,10 |
| **W-SCR-05** | Export | Drawer only | — | ✓ | — | — | — | — | `ExportItem` 动作 | F-11 |
| **W-SCR-06** | Channel Available | Drawer | — | ✓ | 隐藏 | 隐藏 | 隐藏 | OFF | `ChannelAvailableFragment` | F-13 |
| **W-SCR-07** | Vendors (OUI) | Drawer | — | ✓ | 隐藏 | 隐藏 | 隐藏 | OFF | `VendorFragment` | F-14 |
| **W-SCR-08** | Settings | Drawer | — | ✓ | 隐藏 | — | — | — | `SettingsFragment` | F-12 |
| **W-SCR-09** | About | Drawer | — | ✓ | 隐藏 | — | — | — | About 屏 | — |

**证据**：`NavigationMenu.kt` L39–114 · `NavigationOptions.kt` L20–50 · `14` §0.1

### 13.2 各屏逐步摘要（控件级）

| W-SCR-ID | 步 | 用户动作 | UI 控件 | 结果 |
| --- | --- | --- | --- | --- |
| W-SCR-01 | 1 | 进入 | Bottom「Access Points」 | PeriodicScan 运行 |
| W-SCR-01 | 2 | 点行 / ⓘ | `WiFiDetailPopup` | Complete/Compact 详情 |
| W-SCR-01 | 3 | 长按 | 上下文菜单 | 复制 BSSID |
| W-SCR-02 | 1 | 进入 | Rating Tab | Best Channel 卡 + 星级 ListView |
| W-SCR-02 | 2 | Band 切换 | Toolbar `action_wifi_band` | 2.4/5/6G 推荐信道重算 |
| W-SCR-03 | 1 | 进入 | Graph Tab | 三 band ChannelGraph |
| W-SCR-03 | 2 | pinch（5/6G） | `ScrollHandler` | 缩放+横滑 |
| W-SCR-03 | 3 | 点 Marker | touch <20dp | 多 AP `showSequence` |
| W-SCR-04 | 1 | 进入 | Time Tab | 自动全 AP 曲线 |
| W-SCR-04 | 2 | 等待 | 扫描 tick | 200 点窗口；20 次未见移除 |
| W-SCR-05 | 1 | Drawer Export | `ExportItem.activate` | ACTION_SEND 或 Toast no_data |
| W-SCR-06 | 1 | Drawer Available | 合法信道表 | countryCode + band |
| W-SCR-07 | 1 | Drawer Vendors | OUI 列表 | 点厂商过滤 AP |
| W-SCR-08 | 1 | Drawer Settings | Preference 13 项 | 见 W-SET-* |
| W-SCR-09 | 1 | Drawer About | 版本/GPL | — |

### 13.3 YoWire 840vp 九屏映射

| 竞品屏 | YoWire B 栏 | YoWire C 栏 Sub-Tab |
| --- | --- | --- |
| W-SCR-01 | **常驻 AP 列表** | 选中 AP → 详情/时间图 |
| W-SCR-02~04 | B 保持 AP 列表 | C：Rating / 信道图 / 时间图 / Connection |
| W-SCR-05~09 | B「更多」或 **WiFi ⚙** | navigate 全屏或 Sheet |

---

## 14. Export 十四列 — 完整管道与 YoWire 扩展

### 14.1 导出流水线（逐步）

| 步 ID | 阶段 | 源码类/方法 | 行为 |
| --- | --- | --- | --- |
| W-EXP-01 | 触发 | `ExportItem.activate()` | Drawer → Export |
| W-EXP-02 | 数据检查 | `scannerService.wiFiData()` | 空 → Toast `no_data` |
| W-EXP-03 | 序列化 | `Export.export(wiFiDetails)` | 构建管道分隔文本 |
| W-EXP-04 | Header 行 | `Export.kt` L35–50 | 14 列名 `\|` 分隔 |
| W-EXP-05 | 数据行 | 每 AP 一行 | 14 字段对齐 |
| W-EXP-06 | Intent | `ExportIntent` | `ACTION_SEND` + `text/plain` |
| W-EXP-07 | Chooser | `createChooser` | 用户选目标 App |
| W-EXP-08 | 建议文件名 | `{Access Points}-{yyyy/MM/dd-HH:mm:ss}` | 无固定 .csv 扩展名 |

**证据**：`Export.kt` L35–50, L92–107 · `ExportIntent.kt` L26–44 · `ExportItem.kt` L36–54

### 14.2 十四列字段规格（W-EXP-COL-*）

| 列 # | Header | 数据类型 | 空值 | YoWire 约束 |
| ---: | --- | --- | --- | --- |
| 1 | Time Stamp | 扫描时间戳 | — | SessionLog 对齐 |
| 2 | SSID | string | `<unknown>` | 隐藏网络标识 |
| 3 | BSSID | MAC | 权限降级空 | W-ENV-02 Chip |
| 4 | Strength (dBm) | int | — | 与列表 RSSI 一致 |
| 5 | Primary Channel | int | — | — |
| 6 | Primary Frequency | MHz | — | 含 6G |
| 7 | Center Channel | int | — | HT/VHT 中心 |
| 8 | Center Frequency | MHz | — | — |
| 9 | Width (Range) | string | — | 20/40/80/160/320 MHz |
| 10 | Distance | estimate | 空 | 802.11mc RTT 估算 |
| 11 | 802.11mc | bool/flag | — | 支持标记 |
| 12 | Security | enum | OPEN/… | Filter 维对齐 |
| 13 | Standard | 802.11 a/b/g/n/ac/ax/ad | — | **含 WiFi 6/7 展示** |
| 14 | FastRoaming | flag | — | 802.11r 等 |

### 14.3 YoWire 会话导出扩展（WF-ENV-11 / W-ENV-15）

| 格式 | 场景 | 列/字段 | 落点 |
| --- | --- | --- | --- |
| 管道 TXT | 快速分享（竞品对齐） | 14 列 | Drawer Export / C Export |
| CSV | 归档 | 14 列 + 表头；`,` 或 `\t` 可 ⚙ | **WiFi ⚙·会话** |
| JSON | 归档 | AP 对象数组 + scanMeta | **WiFi ⚙·会话** |
| SessionLog | 周期扫描历史 | 多快照 + 时间序列 | W-ENV-15 P1 |

---

## 15. Web / Play Store — WiFiAnalyzer（2025–2026 特性）

| 主题 | 公开描述 / 版本 | YoWire 映射 | 备注 |
| --- | --- | --- | --- |
| **2.4 / 5 / 6 GHz** | Play 与 GitHub：三 band 扫描与图表 | W-FLT-02, W-SCR-02~04 Band 子菜单 | HarmonyOS WiFi 6/6E 能力验证 |
| **HT / VHT / HE 宽度** | Export Width 列；Channel Graph 多宽信道 | W-EXP-COL-09, W-AP-06 | 20–320 MHz |
| **802.11mc 距离估算** | Export Distance 列；Complete AP view | W-EXP-COL-10, W-AP-11 | RTT 硬件依赖 |
| **Channel Rating 320MHz** | Best Channel 卡五档含 320 | W-CRT-01 | WiFi 7 信道 |
| **6 GHz 扫描** | Android 12+ / 厂商差异 | W-SET-10 country + band | 降级 Banner |
| **Play 更新** | [WiFiAnalyzer Play](https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer) — 2025–2026 维护：6G、ax 标准、OUI | 全文 W-ENV-* 基准 | GPLv3 源码 [VREM/WiFiAnalyzer](https://github.com/VREMSoftware/WiFiAnalyzer) |
| **Black Theme** | settings Theme=Black | W-SET-07 → 全局显示 | 竞品独有 |

**竞品无 → YoWire 必补**：SessionLog 持久化（W-ENV-15）、收藏 AP Filter 第五维（W-ENV-05）、840vp B=AP 常驻（W-ENV-14）。

---

## 16. 相关文档（补充）

| 文档 | 路径 |
| --- | --- |
| 竞品 Play | https://play.google.com/store/apps/details?id=com.vrem.wifianalyzer |
| 源码 Export | `.research/reference-apps/WiFiAnalyzer/.../export/Export.kt` |
| 840vp 线框 | `.research/feature-inventory/16-HarmonyOS-840vp-WiFi模块三分栏线框-v2.md` |

---

## 17. 变更记录

| 日期 | 变更 |
| --- | --- |
| 2026-07-03 | 深扩：W-SET-01~13、W-SCR-01~09 走查、Export 14 列流水线、Play/Web 证据 |
