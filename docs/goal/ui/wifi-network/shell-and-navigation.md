---
id: ui.wifi-network.shell
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/navigation.md
  - docs/goal/ui/wifi-network/README.md
  - product/phone/src/main/ets/shell/MainTabContainer.ets
---

# 网络目的地

Phase-C 把网络写成独立 `NavPathStack`，并在不小于 600vp 时使用 `NavigationMode.Auto`。这与 `main` 上 `Index.ets` 的单栈、`NavigationMode.Stack` 冲突，也与蓝牙壳冲突。该两句作废。断点与分栏以 [导航](../app-shell/navigation.md) 为准：一条根栈，页内 `YoSplitScaffold`。

网络仍是下标 2，路由 `/wifi/overview`。不把目的地注册到蓝牙或星闪。

## 布局

概览是 `ROOT_TAB`。顶部一条状态带，下面是入口卡。小于 600vp 一列；600–839vp 两列；不小于 840vp 仍两列，单卡不超过内容区的一半。不放密钥框、测速进度或 AP 全表。

## ArkUI 组件树

```text
YoPageShell
└── Column
    ├── Row
    │   └── YoStatusPill              // WLAN、默认网络、缓存是否过期
    └── GridRow
        └── GridCol
            └── YoModeEntryCard
NavDestination
└── 子屏组件树见各文件
```

会话日志放在 `YoTitleBarMenuItem`，键沿用 Phase-C 的 `sessionLog`。确认连接用 `bindSheet` 或 `AlertDialog`，不用第二套对话框组件。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 网络 Tab 选中。每张入口卡显示该组最后一次终态。尚未读取显示「未读取」，胶囊 `neutral` |
| 按下 | 入口卡按下透明度 `YoOpacity.PRESSED`。松手后 push。底栏切换先 pop |
| 禁用 | 五项都可切换。入口卡在该组加载时 disabled，原因「读取中」。拒绝类卡片保持可点，以便阅读说明。不提供洪泛、阻断或其他应用破解入口（WN-132） |
| 空 | 四项系统授权已声明且还没有任何读取：`YoEmpty`「尚未读取」，主动作「打开 WLAN 状态」。声明缺失不用这个空态 |
| 错误 | `GET_WIFI_INFO`、`SET_WIFI_INFO`、`GET_NETWORK_INFO` 或 `INTERNET` 未声明时概览 `ERROR`，`nativeCode` 201，不弹运行时授权（WN-001） |
| 加载 | 首次 `YoLoading`「正在核对权限声明」。801 到达后加载结束，胶囊「本机不支持 801」（WN-006） |
| 无权限 | 声明缺失是错误 201，不是运行时权限墙。对端 MAC、本机 MAC 的受限显示在权限与能力页（WN-008、WN-009） |

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/shell-and-navigation` |
| 架构编号 | WN-001、WN-006、WN-131、WN-132，以及下表 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 |
| 工作台入口 | 槽 0 的网络卡片。无 WB 编号 |

| 目的地 | 层级 | 文档 | 编号 |
| --- | --- | --- | --- |
| 权限与能力 | `MODULE` | [permissions-and-capability.md](permissions-and-capability.md) | WN-001–WN-010 |
| WLAN 状态 | `MODULE` | [wlan-state.md](wlan-state.md) | WN-011–WN-018 |
| 扫描 | `MODULE` | [scan-filter-channel.md](scan-filter-channel.md) | WN-019–WN-039 |
| 链路 | `MODULE` | [link.md](link.md) | WN-040–WN-050 |
| 连接与认证 | `MODULE` | [connect-and-auth.md](connect-and-auth.md) | WN-051–WN-064 |
| 重连与默认网络 | `MODULE` | [reconnect-and-default-network.md](reconnect-and-default-network.md) | WN-065–WN-073 |
| 地址与诊断 | `MODULE` | [address-dns-route-ports.md](address-dns-route-ports.md) | WN-074–WN-090 |
| 吞吐 | `MODULE` | [throughput.md](throughput.md) | WN-091–WN-096 |
| 本应用连接检查 | `TERMINAL` | [in-app-connection-inspect.md](in-app-connection-inspect.md) | WN-097–WN-111 |
| 局域网发现 | `MODULE` | [lan-discovery.md](lan-discovery.md) | WN-112–WN-117 |
| 抓包与权限墙 | `MODULE` | [capture-boost-permission-walls.md](capture-boost-permission-walls.md) | WN-118–WN-127 |
| 会话日志 | `MODULE` | [session-log.md](session-log.md) | WN-128–WN-132 |

离开子页时页面状态成对取消订阅。同一次系统回调只产生一行日志（WN-131）。页面不调用 `@kit.ConnectivityKit` 或 `@kit.NetworkKit`。
