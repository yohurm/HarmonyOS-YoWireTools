---
id: ui.wifi-network.lan
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 局域网发现

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Column
            ├── Row                         // 状态条，高 56vp
            │   ├── Text
            │   └── YoStatusPill
            ├── Scroll                      // 只包分段，宽度不写在 SegmentButton 上
            │   └── YoSegmentButton         // SegmentButton，@kit.ArkUI
            ├── TextInput                   // 过滤字段，YoTextModifier
            ├── List
            │   └── ListItem
            │       └── Column
            │           ├── Row
            │           │   ├── Text        // 主行，accessibilityGroup
            │           │   └── YoStatusPill
            │           └── Text            // 次行，最多四个短事实
            └── Row
                ├── YoActionButton          // Button，PRIMARY
                └── YoActionButton          // SECONDARY
    bindSheet                               // 过滤或确认，不承载整条调试流程
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 见下方行为细则中的同名描述。 |
| 按下 | 见下方行为细则中的同名描述。 |
| 禁用 | 见下方行为细则中的同名描述。 |
| 空 | 见下方行为细则中的同名描述。 |
| 错误 | 见下方行为细则中的同名描述。 |
| 加载 | 见下方行为细则中的同名描述。 |
| 无权限 | WLAN 未连接是错误「需要 Wi-Fi」（WN-115），不是权限墙。声明缺失仍回 201，不开始发现。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/lan-discovery` |
| 架构编号 | WN-112, WN-113, WN-116, WN-117, WN-114, WN-115 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 。文件不在 `main` |
| 工作台入口 | 工作台「网络」卡片，或底栏网络槽（下标 2） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


本页做 mDNS 发现和本机发布。SSDP 不混进同一行。WLAN 未连接时不把旧局域网的服务显示为在线。

## 布局

`YoPageShell` 标题「局域网」，`MODULE`。

顶区两枚胶囊：WLAN「已连接」或「未连接」；发现「进行中」或「已停止」。

`YoSegmentButton`：「发现」「发布」。

发现表单：服务类型 `TextInput`，占位 `_http._tcp`。按钮「开始发现」「停止」。列表主行服务名，次行类型与端口（WN-112）。离开的服务从在线列表消失，或留在列表里但胶囊为「离开」（WN-113）。两种呈现选一种并保持：本设计用胶囊「离开」，行仍在，便于对照日志。新的发现周期开始时，上一周期标成离开的行可以随「清空离开项」收起。清空是 `TEXT` 按钮，不调用停止以外的扫描。

发布表单：服务名、类型、端口。「发布」「移除」。说明文字写明对端能看到所填名称和端口；本机移除后对端应收到离开（WN-116）。本机列表只表示本机发布状态。

`≥600vp` 左在线列表、右表单与最近事件（`serviceFound` / `serviceLost`）。事件行有时间。

类型为空时，开始按钮禁用，原因「类型为空」，并且不发开始搜索（WN-117）。

## 状态

### 默认

WLAN 已连接，类型已填，列表为当前在线服务。停止后的列表不再增长（WN-114）。

### 按下

开始、停止、发布、移除、行按下走按下透明度。行按下展开主机名等附加字段；没有附加字段时展开区写「系统未返回」。

### 禁用

类型为空、WLAN 未连接、或发现进行中时，「开始发现」禁用。未在发现时「停止」禁用。发布缺服务名或端口时「发布」禁用。

### 空

已连接、发现已成功返回且没有服务：`YoEmpty`「没有发现服务」，说明里带服务类型。WLAN 未连接不用这个空态。

### 错误

WLAN 未连接就点开始：`ERROR`「需要 Wi-Fi」。旧服务全部改为不可用，不保留「在线」胶囊（WN-115）。开始失败带系统码。失败后发现胶囊为「已停止」。

### 加载

从开始到第一次 `serviceFound`、明确的空结果、或失败之前，列表区 `LOADING`「正在发现」。停止后离开加载。WLAN 未连接的失败立即结束加载。

## 依据

- `docs/goal/architecture/wifi-network/WN-112.md` 至 `WN-117.md`
- `设计/设计指南/通用设计基础/布局/响应式应用架构.md`
- `common/youi_kit/src/main/ets/components/feedback/YoEmpty.ets`
# 局域网发现

目标路由 `/wifi/lan-discovery`。模式：扫描列表。行是主机而不是 AP。

## 布局

结果头：「尚未发现」「正在发现」「发现完成」「发现失败」。按钮「开始」或「停止」。

行 64vp：主机名或 IP 为 Body_L，次行另一项 Body_S `tnum`。没有主机名时主行就是 IP，次行「无名称」。右侧无「连接」。行点击 push HTTP 页并把主机填进 URL 输入框的初值；HTTP 页仍按自己的状态显示，不自动发送。

没有密码 sheet。

宽屏不分为详情，除非 ViewModel 另有字段；有则右列用链路详情那种标签/值，左列保持列表。没有额外字段时宽屏只是列表最大宽 600vp。

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 「发现完成」，辅文为主机数量 |
| 按下 | 行按压后 push |
| 禁用 | 无网络：按钮禁用，标题「没有可用网络」 |
| 空 | 「尚未发现」+ 图示 +「开始」。图示用 48vp SymbolGlyph，不用雷达成功文案 |
| 错 | 「发现失败」+ 消息 |
| 加载 | 「正在发现」+ LoadingProgress +「停止」，已发现的行保留 |
| 无权限 | 权限墙 |

## 对照

采用蓝牙扫描的头和 WLAN 的双行列表。不采用连接 sheet、四场景、控制台、家居、FastBle 过滤、体温卡。
# 局域网发现

目标名 `/wifi/lan-discovery`。来源：扫描列表，但不用 H2 的「搜索成功」雷达文案。行是主机而不是周边设备。

行 64vp：主行主机名，没有主机名时主行是 IP；次行另一项，`tnum`。无「连接」按钮。行点击 `push` HTTP，并把主机写入 URL 初值。HTTP 页仍停在「尚未发送」，不自动发请求。

空：14「尚未发现」+ 主按钮「开始」。不用雷达。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 有主机行 |
| 按下 | 行按下 |
| 禁用 | 「开始」在扫描中变成「停止」 |
| 空 | 「尚未发现」 |
| 错误 | 列表上 `warning` 一行 |
| 加载 | 「正在发现」，已发现的行保留 |
| 无权限 | 权限墙 |
