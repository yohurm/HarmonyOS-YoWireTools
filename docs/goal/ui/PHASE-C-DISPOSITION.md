---
id: ui.phase-c-disposition
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/navigation.md
  - docs/goal/ui/QUALITY-GATE.md
---

# Phase-C 处置

Phase-C 的 UI 文档在三条未合并分支上，不在 `main`：

| 模块 | PR | 分支 | 提交 |
| --- | --- | --- | --- |
| 蓝牙 | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/11 | `cursor/bluetooth-phase-c-ui-e5a0` | `dd2a4256dbe42486aaf1bb60fb044fed9e6552e7` |
| 星闪 | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/9 | `cursor/nearlink-phase-c-ui-099b` | `ef3554690dbcc906d9195f32002921ef58a352d2` |
| Wi-Fi | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/10 | `cursor/wifi-network-phase-c-ui-f6c1` | `73a0a8d709f41af01b996ad3769f76c7a0ab0d90` |

本目录是它们的后继。若 #9、#10、#11 先合并，再合本分支，同一路径会冲突。合并顺序应先收口这一份，或关闭那三份里已被取代的壳规范，避免两套断点同时生效。

没有一份旧 UI 规范被原样留下又继续单独生效。行为细则还在各屏后半，壳层数字只认 `app-shell`。

## 冲突怎么收

| Phase-C 写法 | 处置 |
| --- | --- |
| 蓝牙、星闪、Wi-Fi 各写一套断点、底栏和六态 | 合并到 [app-shell](app-shell/README.md)。模块壳文件只留目的地 |
| Wi-Fi 壳使用独立 `NavPathStack`，且不小于 600vp 时 `NavigationMode.Auto` | 作废。`main` 的 `product/phone/src/main/ets/pages/Index.ets` 是一条栈、`NavigationMode.Stack`。列表详情用 `YoSplitScaffold` |
| 蓝牙壳使用同一条根 `Navigation`，页内分栏 | 保留，并升为全 App 规则 |
| 各屏的领域句子（错误码、缺口、按钮文案） | 保留在该文件的「行为细则」 |
| 各屏缺少单独的无权限行，或把未授权写在错误行 | 重做。无权限单独成行，文案仍用原文 |

## 文件

| 旧路径 | 处置 | 现在看哪里 |
| --- | --- | --- |
| `docs/goal/ui/bluetooth/index.md` | 重做 | 导语指向应用壳。屏幕表保留 |
| `docs/goal/ui/bluetooth/shell-navigation.md` | 合并 | [导航](app-shell/navigation.md)。本文件只留蓝牙目的地 |
| `docs/goal/ui/bluetooth/adapter-permissions.md` | 重做 | 同路径。行为细则保留 |
| `docs/goal/ui/bluetooth/classic-discovery.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/pairing.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/address-identity.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/spp-terminal.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/l2cap.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/ble-scan.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/advertising-gatt-server.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/gatt-client.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/mtu-phy-connection.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/throughput-packets-log.md` | 重做 | 同路径 |
| `docs/goal/ui/bluetooth/reconnect-background-diagnostics.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/README.md` | 重做 | 导语指向应用壳。屏幕表保留 |
| `docs/goal/ui/nearlink/shell-navigation.md` | 合并 | [导航](app-shell/navigation.md)。本文件只留星闪目的地 |
| `docs/goal/ui/nearlink/support-radio.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/scan-filters.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/advertising.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/ssap-client.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/ssap-server.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/port-terminal.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/pairing-encryption.md` | 重做 | 同路径 |
| `docs/goal/ui/nearlink/session-log.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/README.md` | 重做 | 导语指向应用壳。屏幕表保留 |
| `docs/goal/ui/wifi-network/shell-and-navigation.md` | 合并 | [导航](app-shell/navigation.md)。独立栈与 `Auto` 作废。本文件只留网络目的地 |
| `docs/goal/ui/wifi-network/permissions-and-capability.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/wlan-state.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/scan-filter-channel.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/link.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/connect-and-auth.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/reconnect-and-default-network.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/address-dns-route-ports.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/throughput.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/in-app-connection-inspect.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/lan-discovery.md` | 重做 | 同路径 |
| `docs/goal/ui/wifi-network/capture-boost-permission-walls.md` | 重做 | 同路径。统一墙的视觉以 [permission-gap-wall.md](app-shell/permission-gap-wall.md) 为准 |
| `docs/goal/ui/wifi-network/session-log.md` | 重做 | 同路径。跨模块列表另见 [log/center.md](log/center.md)，不替换本屏 |

Phase-C 没有工作台、命令面板、日志中心、设置的屏幕稿。这些是本轮新写的，不是把某一份旧稿标成保留。
