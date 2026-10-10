# YoWire 高保真原型

界面以 PR #26（分支 `cursor/ui-spec-market2-5ad2`，`docs/goal/ui/`）为准。本目录是从 `main` 另起的静态稿，只含说明和图片，不改业务代码，也不改 `youi_kit`。

不把已关闭的 PR #19、PR #22，或 #23 薄稿当作版式来源。`main` 上没有这套 UI 规范，所以这里只引用 #26 的页面说明和它点名的来源编号，不把旧规范抄回来。

画布：手机 360×800，宽屏样张 900×640。PNG 为 2 倍。规范字体是 HarmonyOS Sans；这台环境没有该字体，图中用文泉驿微米黑代替，字号和字色仍按规范。

壳是一个 `Navigation`、一条底栏，五个目的地与现有 `MainTabContainer` 一致：工作台、蓝牙、网络、星闪、更多。日志从工作台进入，设置从「更多」进入，都不是底栏项。窄屏用底栏；宽屏样张用 96vp 竖向图标栏，列表和详情在同一页里左右分栏。

颜色：宇宙蓝 `#0A59F7`，页面雪域灰 `#F1F3F5`，卡片白，主文字 `#1A1A1A`，次文字 `#666666`。连接胶囊是浅灰底 `#F1F3F5`、品牌色字，不是实心主按钮。

## 路径、页面、状态、参照

参照列里的文件路径都属于 PR #26 的 `docs/goal/ui/`。来源编号沿用该规范里的写法。

| 路径 | 页面 | 状态 | 参照 |
| --- | --- | --- | --- |
| `phone/workbench-default.svg` | 工作台 | 默认 | `workbench/home.md`。底栏五个目的地来自 `app-shell/information-architecture.md` 与 E4。右上「日志」「命令」。组「最近」，行 64，左图标只用蓝牙、网络、星闪三个符号。不画 M2 三列宫格，不重复三个模块大卡 |
| `phone/workbench-empty.svg` | 工作台 | 空 | 同上。中部 14「还没有会话」，两个文字按钮仍在 |
| `phone/workbench-error.svg` | 工作台 | 错误 | 同上。警告一行，不出现空文案 |
| `phone/bt-overview-default.svg` | 蓝牙总览 | 默认 | `bluetooth/overview.md`。状态胶囊「已开启」，其下经典蓝牙、低功耗两行 |
| `phone/bt-overview-off.svg` | 蓝牙总览 | 适配器关 | 同上。胶囊「已关闭」，入口箭头变弱 |
| `phone/bt-overview-permission.svg` | 蓝牙总览 | 无权限 | `app-shell/permission-gap-wall.md`、M5、G4。中部标题和辅文，底部一颗主按钮，无插画 |
| `phone/bt-scan-default.svg` | 经典蓝牙扫描 | 搜索成功 | `bluetooth/classic-scan.md`、`app-shell/layout-patterns.md` 扫描列表。M12 白卡片和浅胶囊「连接」，E3 行高 76、圆角 16，E1「已连接 / 可用」，H2 状态标题。已连接行不放「断开」。底部「重新搜索」 |
| `phone/bt-scan-empty.svg` | 经典蓝牙扫描 | 空 | 同上，外加 M5。标题「搜索成功」，辅文「没有设备」，中部「附近的设备会出现在这里」，底部按钮仍在 |
| `phone/bt-scan-loading.svg` | 经典蓝牙扫描 | 正在搜索 | 同上。标题旁进度，已出现的行保留，底部「停止」 |
| `phone/bt-scan-fail.svg` | 经典蓝牙扫描 | 搜索失败 | 同上。标题「搜索失败」，底部「重新搜索」 |
| `phone/bt-scan-off.svg` | 经典蓝牙扫描 | 适配器关 | 同上。标题「蓝牙已关闭」，底部按钮不可用 |
| `phone/bt-scan-permission.svg` | 经典蓝牙扫描 | 无权限 | 权限墙替换扫描内容 |
| `phone/spp-off.svg` | SPP 终端 | 未连接 | `bluetooth/spp-terminal.md`。居中「未连接」「选择设备后连接」，按钮「连接」 |
| `phone/spp-default.svg` | SPP 终端 | 已连接 | 同上。胶囊「已连接」，行 48（圆点、时间、摘要），底部输入和「发送」。右上菜单对应断开、清空、暂停、滑动到底部；断开需错误确认，本张不展开对话框 |
| `phone/spp-empty.svg` | SPP 终端 | 已连接无数据 | 同上。中部「还没有数据」，输入条仍在 |
| `phone/ble-default.svg` | 低功耗扫描 | 搜索成功 | `bluetooth/ble-scan.md`、M12、E3。名称在上，地址和 RSSI 在下。可连接行浅胶囊「连接」；不可连接行胶囊禁用。底部「搜索设备」 |
| `phone/ble-empty.svg` | 低功耗扫描 | 空 | 同上、M5。中部「没有设备」，底部「搜索设备」 |
| `phone/gatt-detail.svg` | GATT | 默认 | `bluetooth/gatt-detail.md`。RSSI、MTU 两张量卡，其下服务组。属性行 56，右侧「可读 / 可通知」 |
| `phone/wifi-overview.svg` | 网络总览 | 已连接 | `wifi-network/overview.md`、E2、E6。WLAN 行右侧胶囊为当前 SSID。下列扫描、诊断、局域网、Socket，行 56。四个场景不放成底部四颗按钮 |
| `phone/wifi-scan.svg` | WLAN 扫描 | 默认 | `wifi-network/scan.md`、E1。行 64。主行 SSID，次行「加密」或「开放」，右侧信息热区进入链路详情 |
| `phone/wifi-connect.svg` | 连接网络 | 半模态 | `wifi-network/scan.md` 与布局模式「连接半模态」。M17 标题、关闭、底部一颗按钮；H1 只读 SSID、密码、显示图标、「下一步」。开放网络不打开这张表 |
| `phone/wifi-detail.svg` | 链路详情 | 默认 | `wifi-network/link-detail.md`、E1。标签 12 在上，值 16 在下。顺序 MAC、IP、掩码、网关、DNS、RSSI |
| `phone/wifi-diag.svg` | 网络诊断 | 故障页有速率 | `wifi-network/diagnostics.md`、E2、H4、M4。顶栏页签「连接 / 状态 / 定位 / 故障」。速率用页标题字号 20，单位和说明 12。其下三列时延、下载、上传，再是 48 行和「通过 / 失败」胶囊。不画 0–500 刻度弧，也不铺黑底 |
| `phone/nl-overview.svg` | 星闪总览 | 已开启 | `nearlink/overview.md`。状态胶囊，扫描入口，已连接设备行 |
| `phone/nl-scan-default.svg` | 星闪扫描 | 搜索成功 | `nearlink/scan.md`、M12、E3、H2。卡片与蓝牙扫描相同，行内不放「连接」。随机地址在次行末尾放中性胶囊「随机」。底部「重新搜索」 |
| `phone/nl-scan-empty.svg` | 星闪扫描 | 空 | 同上。辅文「没有设备」，底部「开始搜索」 |
| `phone/nl-transfer.svg` | 星闪数据传输 | 已连接无数据 | `nearlink/data-transfer.md`。胶囊「已连接」，文本 / HEX，底部输入和「发送」 |
| `phone/nl-connect.svg` | 星闪连接 | 需要端口 | 同上，半模态。标题「连接」、关闭、一个「端口」输入、底部「连接」 |
| `phone/log-default.svg` | 日志中心 | 默认 | `log/center.md`、G12、H6、M6。从工作台进入。顶栏「全部 / 蓝牙 / 网络 / 星闪」，搜索「关键字」，芯片 Debug / Info / Warn / Error / Fatal。选中芯片黑底白字，未选中只有次文字。行 48，圆点按级别用警告色、提示色、品牌色、三级文字色。不画彩色描边，也不做半模态切换。右上菜单为暂停、清空、滑动到底部 |
| `phone/log-empty.svg` | 日志中心 | 空 | 同上。中部「没有日志」，页签、搜索、芯片仍在 |
| `phone/log-detail.svg` | 日志详情 | Error | `log/detail.md`。级别胶囊、模块、摘要 |
| `phone/command-default.svg` | 命令 | 有一项选中 | `workbench/command-panel.md`。行 56，选中底 `interactive_select`。行上的名称只用来看排版，不是已合并契约里的命令编号 |
| `phone/command-empty.svg` | 命令 | 空 | 同上。「没有命令」 |
| `phone/more-hub.svg` | 更多 | 默认 | `settings/hub.md`。两行 56：「设置」「关于」 |
| `phone/settings.svg` | 设置 | 默认 | `settings/hub.md`、E6、G6、G8。只有显示、记录、关于三组。主题和日志级别带右值和箭头；版本无箭头。不放搜索，不画专家/轻量开关 |
| `phone/settings-theme.svg` | 设置 | 主题半模态 | 同上。标题、关闭、三行单选，选中行 `interactive_select`：跟随系统、浅色、深色 |
| `wide/wifi-split.svg` | WLAN 扫描 | 宽屏列表加详情 | `app-shell/navigation.md`、`app-shell/layout-patterns.md`、E4、E1。左侧 96vp 只放五个目的地图标，中列宽 280 的热点列表，右侧链路详情。返回不单独占一条应用轨 |

同名 `.png` 与 `.svg` 是同一张画面。
