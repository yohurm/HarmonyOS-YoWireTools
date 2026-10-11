# 可视化原型

这是整 App 的静态原型，不是 ArkUI 组件树，也不是页面实现。图按 `docs/goal/ui/` 已定文案、信息架构和单根 `Navigation` 绘制。蓝牙、星闪、Wi-Fi 是同一壳下的三个目的地，不是三个 App。

质量门禁第 10–12、14 项仍然阻塞。有图也不表示可以铺业务页面。

## 怎么在 PR 里看

打开本目录下的 PNG。GitHub 会直接预览 PNG；同名 SVG 是可缩放的源图。屏文档里的图片用相对路径指向这里。

窄屏逻辑宽 360vp，套同一只手机框。底栏五项是：工作台、蓝牙、网络、星闪、更多。宽屏换成 240vp 侧栏，项与底栏相同。内容高出一屏时，图按滚动展开，底栏画在末尾。

胶囊用浅色目标色（成功 `#44923D`、警告 `#D45C11`），不是当前 Kit 里待替换的浅色值。未上真机。

## 窄屏

| 文件 | 屏 | 状态 |
| --- | --- | --- |
| [phone-workbench.png](phone-workbench.png) | 工作台 `screen.workbench.home` | 默认（轻量） |
| [phone-workbench-empty.png](phone-workbench-empty.png) | 工作台 | 空：还没有会话 |
| [phone-command-panel.png](phone-command-panel.png) | 命令面板 `screen.workbench.command` | 默认：执行一次可点，周期发送禁用 |
| [phone-command-panel-empty.png](phone-command-panel-empty.png) | 命令面板 | 空：还没有命令 |
| [phone-command-panel-permission.png](phone-command-panel-permission.png) | 命令面板 | 无权限：去该模块授权 |
| [phone-log-center.png](phone-log-center.png) | 日志中心 `screen.log.center` | 默认；其中一行是权限失败 |
| [phone-log-center-empty.png](phone-log-center-empty.png) | 日志中心 | 空：没有会话日志 |
| [phone-log-center-error.png](phone-log-center-error.png) | 日志中心 | 错误：日志来源未收口 |
| [phone-settings.png](phone-settings.png) | 设置 `screen.settings.hub` | 默认：八组，未读取，开关禁用 |
| [phone-settings-error.png](phone-settings-error.png) | 设置 | 错误：一行读取失败 |
| [phone-bluetooth-overview.png](phone-bluetooth-overview.png) | 蓝牙概览 | 默认：已打开 |
| [phone-bluetooth-overview-permission.png](phone-bluetooth-overview-permission.png) | 蓝牙概览 | 无权限：授权 |
| [phone-bluetooth-overview-gap.png](phone-bluetooth-overview-gap.png) | 蓝牙概览 | 禁用：BT-008 蓝牙不可用 |
| [phone-nearlink-overview.png](phone-nearlink-overview.png) | 星闪概览 | 默认：支持且已打开；进入不弹授权 |
| [phone-nearlink-overview-error.png](phone-nearlink-overview-error.png) | 星闪概览 | 错误：801 |
| [phone-nearlink-overview-closed.png](phone-nearlink-overview-closed.png) | 星闪概览 | 禁用：星闪已关闭 |
| [phone-wifi-overview.png](phone-wifi-overview.png) | Wi-Fi 概览 | 默认：状态带与入口卡 |
| [phone-wifi-overview-empty.png](phone-wifi-overview-empty.png) | Wi-Fi 概览 | 空：尚未读取 |
| [phone-wifi-overview-error.png](phone-wifi-overview-error.png) | Wi-Fi 概览 | 错误：声明缺失 201，不是运行时权限墙 |

## 宽屏

| 文件 | 屏 | 状态 |
| --- | --- | --- |
| [wide-shell-workbench.png](wide-shell-workbench.png) | 应用壳 + 工作台 | 侧栏展开，同一组五项 |
| [wide-log-center.png](wide-log-center.png) | 应用壳 + 日志中心 | 侧栏仍高亮工作台；列表与详情分栏 |

## 图注里的待对齐

只标架构还没定的地方，不改屏上的规范文案。

| 图 | 图注 |
| --- | --- |
| 工作台默认 / 空 | 最近会话读模型未命名，无 WB 编号 |
| 命令面板默认 / 空 / 无权限 | 没有入库的执行函数；周期上限不写死；跨模块跳转契约未到 |
| 日志中心默认 / 错误，宽屏日志 | LOG-003 仍是缺口，行是示意 |
| 设置默认 / 错误 | 没有 SET 存储。蓝牙 / Wi-Fi / 星闪只链到模块 |
| 蓝牙概览默认 | 回连与诊断未画成第三张卡，根页行为细则只有经典和低功耗 |
| 星闪概览默认 | 页面状态类型未到 |
| Wi-Fi 概览默认 | 入口按壳的目的地表逐卡，没有收成 PRD 的三类工作台 |
| 两张宽屏 | 整 App 导航契约未到，沿用一个 `Navigation` |

## 假设

规范没有写死、图画的时候采用的做法：

- 设置页标题用「设置」，底栏用现有资源「更多」。
- 设置每组只画关键行，未画出的行名以设置屏文档为准。
- 命令名、会话行、日志行是示意，不是已入库数据。
- 按下只改按下色，没有单独出图。
- 星闪根页的无权限态就是不弹框，权限墙在扫描页，所以概览没有第二张权限墙。
- Wi-Fi 声明缺失按错误 201 画，不画运行时「授权」按钮。

## 屏文档

| 屏 | 文档 |
| --- | --- |
| 工作台 | [home.md](../workbench/home.md) |
| 命令面板 | [command-panel.md](../workbench/command-panel.md) |
| 日志中心 | [center.md](../log/center.md) |
| 设置 | [hub.md](../settings/hub.md) |
| 蓝牙概览 | [adapter-permissions.md](../bluetooth/adapter-permissions.md) |
| 星闪概览 | [support-radio.md](../nearlink/support-radio.md) |
| Wi-Fi 概览 | [shell-and-navigation.md](../wifi-network/shell-and-navigation.md) |
| 宽屏壳 | [navigation.md](../app-shell/navigation.md) |
# 原型目录

高保真还没画。这里只有信息架构草图，用来看页面怎么挂在同一个导航上。颜色、密度、标题栏和组件外观都还没定，要等华为工具库截图、更多官方页面样例和高星开源对照之后再出。

## 怎么看

PR 里直接打开同名 PNG。SVG 是源文件，用浏览器打开即可。每张图角上标了「信息架构草图 · 非高保真」。

`references/harmonyos-component-ux-phone.png` 是组件示例仓库自带的手机截图，只说明看过那一个橱窗，不是本 App 的稿。

主分支上没有单独的界面屏文档。页面范围写在 `REWORK.md`，不从已作废的 PR #19 抄规范。
# 原型

高保真静态图。SVG 是源文件，PNG 是 2 倍导出，PR 里直接看 PNG。手机画布 360×800，宽屏 900×640。说明见 `REWORK.md`。

主分支没有单独的界面屏文档。页面范围以这次工具库调研和产品任务为准。

## 路径 → 屏 → 状态

| 路径 | 屏 | 状态 |
| --- | --- | --- |
| `ia/nav.svg` | 单根导航总图 | 结构草图。窄屏栈、宽屏同一批目的地。 |
| `ia/workbench.svg` | 工作台 | 草图。列表入口和宫格入口并列，未选定。 |
| `ia/list.svg` | 列表页（扫描、日志、发现共用） | 草图。默认布局，并标出空、错、无权限都留在内容区。 |
| `ia/command.svg` | 命令面板 | 草图。整页和半模态并列，未选定。 |
| `ia/logs-settings.svg` | 日志、设置 | 草图。日志含列表和详情；设置按组，不按三种无线拆首页。 |
| `ia/radios.svg` | 蓝牙、星闪、Wi-Fi | 草图。三条链路的关键页，仍进同一栈。 |
| `ia/sheet-terminal.svg` | 配对/连接半模态、终端 | 草图。半模态不叠两层；终端分摘要、接收、发送。 |
| `ia/wide.svg` | 宽屏分栏 | 草图。左侧是同一导航，返回键隐藏。栏宽未选定。 |

每张 SVG 旁有同名 PNG。
| `phone/home-default.svg` | 首页 | 默认 |
| `phone/home-empty.svg` | 首页 | 空 |
| `phone/home-error.svg` | 首页 | 探测失败 |
| `phone/home-permission.svg` | 首页 | 无权限 |
| `phone/debug-default.svg` | 调试 | 默认。蓝牙、Wi-Fi、星闪同一列表 |
| `phone/wifi-list-default.svg` | Wi-Fi 列表 | 默认 |
| `phone/wifi-list-empty.svg` | Wi-Fi 列表 | 空 |
| `phone/wifi-list-error.svg` | Wi-Fi 列表 | 未开启 |
| `phone/wifi-list-permission.svg` | Wi-Fi 列表 | 无权限 |
| `phone/wifi-detail.svg` | Wi-Fi 详情 | 默认 |
| `phone/wifi-connect.svg` | Wi-Fi 连接 | 半模态，下一步 |
| `phone/wifi-diag-default.svg` | 网络诊断 | 默认 |
| `phone/wifi-diag-error.svg` | 网络诊断 | 失败 |
| `phone/bt-scan-default.svg` | 蓝牙扫描 | 已搜到 |
| `phone/bt-scan-empty.svg` | 蓝牙扫描 | 空 |
| `phone/bt-scan-error.svg` | 蓝牙扫描 | 未开启 |
| `phone/bt-scan-permission.svg` | 蓝牙扫描 | 无权限 |
| `phone/bt-connect.svg` | 蓝牙串口连接 | 半模态 |
| `phone/bt-terminal.svg` | 串口终端 | 默认 |
| `phone/bt-terminal-empty.svg` | 串口终端 | 空 |
| `phone/bt-terminal-error.svg` | 串口终端 | 发送失败 |
| `phone/ble-scan.svg` | BLE 扫描 | 默认 |
| `phone/ble-gatt.svg` | BLE GATT | 默认 |
| `phone/nl-scan-default.svg` | 星闪扫描 | 已搜到 |
| `phone/nl-scan-empty.svg` | 星闪扫描 | 空 |
| `phone/nl-scan-error.svg` | 星闪扫描 | 本机不支持 |
| `phone/nl-scan-permission.svg` | 星闪扫描 | 无权限 |
| `phone/nl-ssap.svg` | 星闪 SSAP | 默认 |
| `phone/nl-transfer.svg` | 星闪数传 | 默认 |
| `phone/console-log.svg` | 控制台 · 日志 | 默认 |
| `phone/console-log-empty.svg` | 控制台 · 日志 | 空 |
| `phone/console-log-error.svg` | 控制台 · 日志 | 读失败 |
| `phone/console-network.svg` | 控制台 · 网络 | 默认 |
| `phone/console-command.svg` | 控制台 · 命令 | 默认 |
| `phone/settings-default.svg` | 我的 / 设置 | 默认 |
| `phone/settings-error.svg` | 我的 / 设置 | 导出路径不可写 |
| `wide/wifi-split.svg` | Wi-Fi 列表 + 详情 | 宽屏，同一条任务 |

每个 SVG 旁边有同名 PNG。
# 原型索引

手机画布 360×800，宽屏 900×640。每屏同时有 SVG 和 PNG。中文界面。`main` 没有逐屏 UI 规格，下表是这套原型自己的路径、屏幕、状态和参照，不回填 PR #19。

壳层只有一条导航。底栏是首页、调试、控制台、设置。Wi-Fi、蓝牙、星闪从「调试」推进去。

| 路径 | 屏幕 | 状态 | 参照 |
| --- | --- | --- | --- |
| `phone/home-default.svg` | 首页 | 默认 | 健康管理模板的设备卡和「开始调试」；综合工具模板的三列宫格，图标收成宇宙蓝；multi-nav-bar 底栏 |
| `phone/home-empty.svg` | 首页 | 空 | 通用状态服务：状态胶囊、环形空态、查看帮助、浅底蓝字按钮 |
| `phone/home-error.svg` | 首页 | 错误 | 通用状态服务；PRD 失败要给出下一步 |
| `phone/home-permission.svg` | 首页 | 无权限 | 通用状态服务；BluetoothLowEnergy 权限检查 |
| `phone/debug-default.svg` | 调试 | 默认 | 综合工具 / 计算器模板的宫格壳和「默认打开」；同一导航栈，不另做底栏 |
| `phone/wifi-home.svg` | Wi-Fi 首页 | 默认 | network-query 四场景改成分组列表；PRD 当前网络 + 环境 / 诊断 / 协议 / 局域网；wlan-info 连接行 |
| `phone/wifi-list-default.svg` | 环境分析 | 默认 | wlan-info-query 已连接 / 可用；H3 列表；PRD 信道占用 |
| `phone/wifi-list-empty.svg` | 环境分析 | 空 | 通用状态服务的「加载中 / 网络未设置 / 获取不到内容」 |
| `phone/wifi-list-error.svg` | 环境分析 | 错误 | 同上，WLAN 未开启 |
| `phone/wifi-list-permission.svg` | 环境分析 | 无权限 | 同上，缺少位置权限 |
| `phone/wifi-detail.svg` | 热点详情 | 默认 | wlan-info `InfoItemView` 左标签右值；H3 详情；一个主按钮「网络诊断」 |
| `phone/wifi-connect.svg` | 连接网络 | 半模态 | H1 灰选择框、密码与眼睛、居中「下一步」；手机用底部半模态，不套第二层 |
| `phone/wifi-diag-default.svg` | 网络诊断 | 默认 | 网络测速组件的表盘、时延 / 下载 / 上传；network-query 的网关和 DNS |
| `phone/wifi-diag-error.svg` | 网络诊断 | 错误 | 通用状态服务，「设置网络」 |
| `phone/wifi-protocol.svg` | 协议调试 | 默认 | PRD TCP / UDP / HTTP / WebSocket / MQTT；NavigationSettings 行 |
| `phone/bt-home.svg` | 蓝牙首页 | 默认 | PRD 经典蓝牙与 BLE 分开；NavigationSettings 行 |
| `phone/bt-scan-default.svg` | 经典蓝牙扫描 | 默认 | 蓝牙通讯组件：地址行、浅底「连接」、底部「搜索设备」；「搜索成功」来自蓝牙扫描组件 |
| `phone/bt-scan-empty.svg` | 经典蓝牙扫描 | 空 | 通用状态服务 |
| `phone/bt-scan-error.svg` | 经典蓝牙扫描 | 错误 | 通用状态服务，蓝牙未开启 |
| `phone/bt-scan-permission.svg` | 经典蓝牙扫描 | 无权限 | 通用状态服务；BLE 权限列表 |
| `phone/bt-connect.svg` | SPP 连接 | 半模态 | PRD 连接配置；复选框表示安全连接；主按钮只有「连接」 |
| `phone/bt-terminal.svg` | SPP 终端 | 默认 | PRD 终端结构；hadice 日志行；等宽只用于报文 |
| `phone/bt-terminal-empty.svg` | SPP 终端 | 空 | 已连接但还没有收发；空态图形来自通用状态服务 |
| `phone/bt-terminal-error.svg` | SPP 终端 | 错误 | 发送失败并给出重新连接 |
| `phone/ble-scan.svg` | BLE 扫描 | 默认 | 蓝牙通讯组件的列表和「连接」。不采用心率标题和心率卡片 |
| `phone/ble-gatt.svg` | GATT | 默认 | PRD 服务树；读 / 写 / 通知用文字；JhSetCell 右值 |
| `phone/nl-home.svg` | 星闪首页 | 默认 | PRD 先展示能力、开关和权限 |
| `phone/nl-scan-default.svg` | 星闪扫描 | 默认 | 蓝牙通讯组件的列表结构；PRD 星闪地址 |
| `phone/nl-scan-empty.svg` | 星闪扫描 | 空 | 通用状态服务 |
| `phone/nl-scan-unsupported.svg` | 星闪扫描 | 能力不支持 | PRD：不支持时不要进入空白扫描；通用状态服务 |
| `phone/nl-scan-permission.svg` | 星闪扫描 | 无权限 | ACCESS_NEARLINK；通用状态服务 |
| `phone/nl-ssap.svg` | SSAP | 默认 | PRD Property 读、写、通知；MTU |
| `phone/nl-transfer.svg` | dataTransfer | 默认 | PRD 终端；alert 色提示默认不保证加密 |
| `phone/console-log.svg` | 控制台日志 | 默认 | 应用内可视化日志：搜索、Debug/Info/Warn/Error/Fatal、深色分级卡片 |
| `phone/console-log-empty.svg` | 控制台日志 | 空 | 通用状态服务 |
| `phone/console-log-error.svg` | 控制台日志 | 错误 | 通用状态服务，写入失败 |
| `phone/console-sheet.svg` | 控制台日志 | 半模态设置 | 应用内日志的背景、滑到底部、半模态 / 全模态 |
| `phone/console-swipe.svg` | 控制台日志 | 侧滑 | 消息管理的分段胶囊和侧滑「导出 / 删除」 |
| `phone/action-sheet.svg` | 导出文件 | 操作列表 | 文件管理底部操作列表：导出、删除、取消 |
| `phone/console-network.svg` | 控制台网络 | 默认 | hadice 网络记录；H6 网络数据 |
| `phone/console-command.svg` | 命令 | 默认 | 消息管理的选中胶囊和左标题右操作；PRD 命令面板 |
| `phone/settings-default.svg` | 设置 | 默认 | NavigationSettings 搜索和分组；PRD 显示 / 日志 / 后台 / 蓝牙 / 关于；JhSetCell；开关只给立刻生效项 |
| `phone/settings-error.svg` | 设置 | 错误 | 通用状态服务 |
| `wide/wifi-split.svg` | Wi-Fi 分栏 | 默认 | multi-nav-bar lg 竖栏 96，目的地与手机相同；wlan-info 与 H3 的列表\|详情；分栏不画返回 |

每张 PNG 与同名 SVG 放在一起。
# YoWire 高保真原型

界面以 PR #26（分支 `cursor/ui-spec-market2-5ad2`，`docs/goal/ui/`）为准。本目录是从 `main` 另起的静态稿，只含说明和图片，不改业务代码，也不改 `youi_kit`。

不把已关闭的 PR #19、PR #22，或 #23 薄稿当作版式来源。`main` 上没有这套 UI 规范，所以这里只引用 #26 的页面说明和它点名的来源编号，不把旧规范抄回来。

画布：手机 360×800，宽屏样张 900×640。PNG 为 2 倍。规范字体是 HarmonyOS Sans。SVG 的 `font-family` 先写文泉驿微米黑，再回退到 `Noto Sans CJK SC` 和 `HarmonyOS Sans SC`。这台环境只用得到文泉驿，字号和字色仍按规范。

壳是一个 `Navigation`、一条底栏，五个目的地与现有 `MainTabContainer` 一致：工作台、蓝牙、网络、星闪、更多。日志从工作台进入，设置从「更多」进入，都不是底栏项。窄屏用底栏；宽屏样张用 96vp 竖向图标栏，列表和详情在同一页里左右分栏。

颜色：宇宙蓝 `#0A59F7`，页面雪域灰 `#F1F3F5`，卡片白，主文字 `#1A1A1A`，次文字 `#666666`。连接胶囊是浅灰底 `#F1F3F5`、品牌色字，不是实心主按钮。

## 路径、页面、状态、参照

参照列里的文件路径都属于 PR #26 的 `docs/goal/ui/`。来源编号沿用该规范里的写法。

| 路径 | 页面 | 状态 | 参照 |
| --- | --- | --- | --- |
| `phone/workbench-default.svg` | 工作台 | 默认 | `workbench/home.md`。底栏五个目的地来自 `app-shell/information-architecture.md` 与 E4。右上「日志」「命令」。组「最近」，行 64，左图标只用蓝牙、网络、星闪三个符号。不画 M2 三列宫格，不重复三个模块大卡 |
| `phone/workbench-empty.svg` | 工作台 | 空 | 同上。中部 14「还没有会话」，两个文字按钮仍在 |
| `phone/workbench-error.svg` | 工作台 | 错误 | 同上。警告一行，不出现空文案 |
| `phone/workbench-a.svg` | 工作台 | 方案 A · 分组列表 | 结构来自 PR #24 `ia/workbench.svg` 的方案 A。状态条、最近会话、模块三行（蓝牙 / 网络 / 星闪）都是列表。颜色、白卡片、标题右侧「日志」「命令」按 PR #26。文案用现有字符串：已开启、已连接、经典蓝牙串口 |
| `phone/workbench-b.svg` | 工作台 | 方案 B · 模块宫格 | 结构来自同一张线框的方案 B。三个模块是宫格，最近会话仍是列表。PR #26 `workbench/home.md` 写明不采用 M2 这种宫格；这张画出来供和方案 A 对照选择 |
| `phone/workbench-ab.svg` | 工作台 | A/B 对照 | 上面两张手机稿并排，方便直接选。左侧方案 A，右侧方案 B |
| `phone/bt-overview-default.svg` | 蓝牙总览 | 默认 | `bluetooth/overview.md`。状态胶囊「已开启」。经典蓝牙次行「不能打开」，因为 `/bluetooth/classic-scan` 在 `main` 尚未注册。低功耗次行用现有文案「GATT 浏览器」 |
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
