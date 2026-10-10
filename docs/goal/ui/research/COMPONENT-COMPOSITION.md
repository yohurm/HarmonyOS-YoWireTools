---
id: yowire.ui.research.composition
type: topic-study
status: active
when: research
---

# 页面级组合

这里的「组合」是一整页的组件栈，不是单个控件的用法。模块 Goal 按页面编号选用下面的一种。同一页只选一种主组合。半模态 C13 可以叠在主组合上，但不能代替主组合。

组件名优先用 ArkUI / UI Design Kit 已有控件：`HdsNavigation`、`Tabs`、`SegmentButton`、`List`、`bindSheet`、`SideBarContainer`、`NavigationMode.Split`。ibest-ui-v2 的 `empty`、`skeleton`、`cellGroup`、`tree`、`noticeBar`、`swipeCell` 只作为同类职责的参照，落代码时仍走 YoUI Kit 或系统组件，不把 ibest 的色值带进来。

## C1 指标板

**用于** `DB-BOARD`、`BT-BOARD`、`NW-BOARD`、`NL-BOARD`。

自上而下：

1. `HdsNavigation` 标题。看板标题为「看板」。模块板标题为模块名。菜单只有「日志」「设置」。
2. 射频或能力状态带：若干 `Text` 事实，横排，可换行。不是图标宫格。
3. 焦点数字一块：标签、数字、单位或错误码。
4. 次级数字一行三块，字号低于焦点。
5. 告警 `List`，最多 5 行；「全部」进入 `DB-ALERTS` 或模块自己的失败记录。
6. 趋势区：满足 [DASHBOARD.md](DASHBOARD.md) 的点数条件才放折线，否则一句「样本不足」。

模块板的第 6 项可以不出现。星闪板在「不支持」时，第 3 项换成阻断说明，第 5、6 项不渲染。

**状态切换：** 加载时 3–5 换成与最终位置一致的骨架。失败时在 1 与 2 之间插入 `noticeBar`。关射频和无权限改写第 2、3 项的文案与主按钮，不把整页换成另一套列表。

**来源：** 莓创图表的指标加趋势（[evidence/mccharts-dashboard.png](evidence/mccharts-dashboard.png)）；hadice `DeviceOverviewPage.tsx` 用多块读数而不是应用启动器（HEAD `ff3b9a9`，指标栅格 `grid-cols-2 md:grid-cols-4`）；interface-design 的单焦点与指标排版。

**不要用于** 发现、终端、设置、命令库。

## C2 告警轨

**用于** `DB-ALERTS`，以及 C1 里的告警段。

一行包含：级别色条、模块名、对象、错误码、时间。点击带参数进入拥有该信号的页。空态说明「这个时间窗没有告警」，主按钮「回到看板」。不要在空态上放模块入口。

**来源：** 应用内日志的级别过滤（[evidence/app-log-phones.png](evidence/app-log-phones.png)）提供级别语义；行本身是证据，不是设备卡片。

## C3 发现工作区

**用于** `BT-CLASSIC-DISCOVERY`、`BT-BLE-SCAN`、`NL-SCAN`。

自上而下：

1. 标题栏 `bottomBuilder`：搜索。`SegmentButton` 单选只切换排序或「已配对 / 附近」这类同一结果集的子集。
2. 状态条：进行中、已停止、数量、最近刷新、是否来自缓存。
3. `List`。经典蓝牙分两组头。BLE 行含地址类型与 RSSI。星闪行含地址与广播名。行内主操作是胶囊按钮，样式参考蓝牙通讯列表（[evidence/bt-comm-list.png](evidence/bt-comm-list.png)）。
4. 底部一颗主按钮：开始或停止。

空态只替换第 3 项。状态条保留，这样用户知道扫描已经结束。关射频和无权限替换 2–4，主按钮分别是「打开射频」和「去授权」。

**来源：** BLE 示例 `BluetoothClientView.ets` 是列表加搜索按钮，连接前有确认；`wlan-info-query` 的 `Index.ets`（HEAD `a114aba`）是扫描列表推进详情。官方示例没有把这张列表同时当作模块首页。

**不要用于** 模块板、GATT/SSAP 树、AP 频谱、日志、设置。

## C4 频谱分栏

**用于** `NW-SPECTRUM`、`NW-RSSI-TREND`、`NW-AP-DETAIL`（详情是窄屏上的子页，宽屏上并进右栏）。

窄屏：上为信道柱图，下为 AP 列表；点柱或点行进入 `NW-AP-DETAIL`。`NW-RSSI-TREND` 整页是选中 AP 的折线，暂停与时间窗在标题栏。

宽屏：左图或左列表，右详情。`NavigationMode.Split`。

AP 详情是键值：SSID、BSSID（不可见时写原因）、RSSI、信道、安全类型、来源。字段来自已有 `WifiAccessPointSnapshot`。

**来源：** 类别对比用柱（`charts.csv` 第 2 行）；时间趋势用折线（第 1 行）。`wlan-info-query` 的 `DetailInfoView.ets` 是键值详情，不是第二张扫描首页。

**不要用于** 蓝牙发现或星闪扫描。那些没有信道轴。

## C5 诊断运行

**用于** `NW-DIAG-RUN`、`NW-PORT`、`NW-LAN`。

未开始：一句目标（网关或用户在半模态里确认的主机）加一颗「开始」。目标来自当前关联，不先展示 Ping / DNS / 路由的入口菜单。

进行中：步骤列表，当前步标为进行。结果区是一个主数字（时延或开放端口数）加辅助列。测速组件的「一个大数 + 时延/下载/上传」（[evidence/net-speed-phone.png](evidence/net-speed-phone.png)）只借用这个层级，不借用仪表盘皮肤。

`NW-LAN` 的主体是主机表：地址、存活、时延、开放端口。它是表，不是设置分组。

**来源：** `NetworkDiagnostics.ets` 以重新查询为动作（HEAD `42c7516`）。步骤模型已有 `DiagnosticStepKind` / `DiagnosticStepState`。

**不要用于** 看板上的长期趋势。

## C6 会话终端

**用于** `BT-SPP-TERMINAL`、`BT-NUS-TERMINAL`、`NL-DT`、`NW-SOCKET`、`NW-WS`、`NW-MQTT`。

自上而下：

1. 连接条：协议、目标、状态、最近错误。MQTT 另加已订阅主题数。
2. 记录区：时间序，等宽。`SegmentButton` 切换「文本 / HEX」，切换的是同一记录的编码，不是另一页。
3. 输入条：输入、编码、发送。周期发送的参数在 C13，不占第三屏。
4. 标题栏动作打开 C10 命令托盘。

已连接但无字节：记录区写「已连接，等待数据」，输入条仍在。这和「没有设备」不是同一种空。

**来源：** 应用内日志的等宽行与滚到底（[evidence/app-log-phones.png](evidence/app-log-phones.png)）。hadice 把性能曲线放在独立页 `PerformanceMonitorPage.tsx`，终端类页面（`HdcShellPage.tsx`）与总览页分开。YoWire 的通知曲线是 `BT-NOTIFY-CURVE`，不塞进终端记录区的头部。

**差异：** MQTT 在连接条下增加主题列表，点主题过滤记录。WebSocket 与 TCP 没有主题列表。星闪数传在连接条显示端口与加密状态。这些差异写在连接条和附加段，不另做一套列表壳。

## C7 树与检查器

**用于** `BT-GATT-TREE`、`NL-SSAP`、`BT-ADV-DETAIL`、`NL-ADV`。

窄屏：服务列表推进特征页。特征的读、写、订阅放在页底按钮；写入表单用 C13。

宽屏：左树右检查器。树用分组缩进。ibest 的 `tree` 说明这种数据适合树组件，而不是扁平设备卡片。

广播详情是只读键值加原始 HEX 折叠区。解析失败时仍显示原始字节，这是失败态，不是空态。

**来源：** BLE 示例把心率视图从设备列表再推进去（`HeartRateView` / `HeartRateGraph.ets`）。星闪示例把 SSAP 放在 `SsapClientPage.ets`，与 `MainPage` 的扫描分开。

## C8 报文分栏

**用于** `NW-HTTP`。

上或左：方法、URL、头、体。下或右：状态码、耗时、响应头、响应体。发送是主按钮。模板列表是标题栏进入的半模态，不是页面主体。

**来源：** 已有 `HttpRequestTemplate` 与响应模型（`responseCode`、`latencyMs`、`bodySize`）。报文页和套接字终端不是同一种记录流。

## C9 证据流

**用于** `LOG-STREAM`、`LOG-SESSION`。

1. 搜索。
2. 来源 `SegmentButton`：全部 / 蓝牙 / 网络 / 星闪。这是同一日志的子集，参考消息列表顶部分段（[evidence/msg-list.png](evidence/msg-list.png)）。
3. 级别芯片：Debug、Info、Warn、Error、Fatal。多选过滤，不是底栏。参考应用内日志（[evidence/app-log-phones.png](evidence/app-log-phones.png)）。
4. 虚拟列表。滑动操作只保留「复制」，不把侧滑删除当作主路径。`list-exchange` 演示了 `swipeAction`（HEAD `bad3f1e`），日志以保留证据为先。
5. 窄屏点一行进入 `LOG-SESSION`。宽屏右栏即详情。

**来源：** hadice 的设备总览和性能页是分开的路由（`frontend/src/pages`）。日志同样不回嵌到看板里当第二首页。

## C10 命令托盘

**用于** 终端页上的执行面，宽屏时落在右栏。编辑页是 `CMD-LIBRARY`，用 C11 的分组，不用托盘。

托盘内：当前会话可用的命令，按组。每颗按钮显示空闲、执行中、成功、失败和最近耗时。轻量模式只显示标记为轻量的命令。高风险命令先确认。

托盘是 `bindSheet`（窄屏）或分栏（宽屏）。新建和排序在 `CMD-LIBRARY`，不在托盘里完成。

**来源：** `bindSheet` 适合添加内容、短任务（[指南](https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/ui/arkts-sheet-page.md)）。自定义对话框示例把隐私、列表、导航弹层分成不同页面文件（HEAD `d448e79`），说明不同模态不要叠成一个万能弹层。

## C11 分组偏好

**用于** `SET-ROOT` 及其子页。

`Search` 加多个 `ItemGroup`：显示、日志、后台、蓝牙默认、网络默认、星闪默认、安全、关于。行是标题、当前值、开关或箭头。`NavigationSettings` 的 `SettingList.ets` 就是搜索加数组组；非 `sm` 用 `NavigationMode.Split`（HEAD `4349e44`）。

设置子页只改偏好。它不扫描、不连接。

## C12 阻断

**用于** 任一页的关射频、无权限、能力不支持。也用于整页失败。

内容区：原因标题、一句下一步、一颗主按钮。结构来自通用状态（[evidence/status-empty-phone.png](evidence/status-empty-phone.png)、[evidence/status-empty-wide.png](evidence/status-empty-wide.png)）。

文案按原因分开，按钮按原因分开：

| 原因 | 主按钮 |
| --- | --- |
| 空结果 | 放宽过滤，或保持停止 |
| 加载 | 不使用本组合，使用骨架 |
| 失败 | 重试 |
| 关射频 | 打开系统开关或系统设置 |
| 无权限 | 申请或去系统授权 |
| 能力不支持 | 无主按钮。说明停在本页 |

星闪不支持属于最后一行。不要提供「仍然扫描」。

## C13 短任务半模态

**用于** 连接参数、扫描过滤、导出、特征写入、诊断目标确认、周期发送参数。

标题、关闭、字段、一颗主按钮。字段多到需要步骤时，改成子页。父页面在半模态下面保持可见。二次关闭用 `onWillDismiss`，避免误关正在编辑的连接参数（同一份 bindSheet 指南）。

`custom-dialog` 示例还包含 Toast 与自定义对话框。YoWire 的确认用对话框，表单用半模态，成功提示用 Toast。三者不混成一个组件。

## C14 宽屏壳

**用于** 宽度达到 `xl` 的侧栏，以及达到 `Navigation` 分栏阈值的内容区。页面编号仍是窄屏那些，不另起一套路由。

1. `SideBarContainer` 嵌入，宽 240vp，四项与底栏相同。
2. 内容 `Navigation`：`Split` 时左主右检。
3. 右检的内容由主区决定：AP 详情、树节点、日志行、命令托盘。
4. 空的右检写「未选择」，不填入口卡片。

`multi-nav-bar` 的 `BreakpointType` 提供 `sm` / `md` / `lg` / `xl`（`BreakpointType.ets`）。`lg` 使用起始侧页签即可，不必提前变侧栏；`xl` 再用侧栏。这是示例里的分界，YoWire 沿用，避免平板宽度上出现两套导航。

PureTabs 的外层页签包着内层页签（`OutTabsComponent.ets`、`InTabsComponent.ets`，HEAD `49e12dd`）。那种嵌套用来切换内容分类。YoWire 的底栏已经是目的地，页内不再套第二层 `Tabs`。
