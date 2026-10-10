---
id: ui.nearlink.shell
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/navigation.md
  - docs/goal/ui/nearlink/README.md
  - product/phone/src/main/ets/navigation/AppRoutes.ets
---

# 星闪目的地

断点、8vp 网格、底栏与侧栏、状态词和 Kit 边界已合并到 [应用壳](../app-shell/README.md)。Phase-C 在本文件写过的断点表和六态词表不再单独生效。星闪仍是下标 3 的 Tab，路由 `/nearlink/overview`。页内跳转走同一条根 `NavPathStack`，不用 `@ohos.router`，也不另做一根星闪栈。

## 布局

根页 `ROOT_TAB`：支持条在上，入口卡在下。窄屏一列，宽屏入口卡按栅格折行，不放成插画。子页 `MODULE` 或 `OBJECT`。端口终端是 `TERMINAL`，宽屏 6:4。半模态只用于过滤、确认和销毁端口，不承载整条调试流程。

## ArkUI 组件树

```text
YoAppShell
└── 星闪根 Nav 内容
    └── YoPageShell
        └── Column
            ├── 支持条 Row + YoStatusPill
            └── GridRow
                └── GridCol
                    └── YoModeEntryCard
NavDestination
└── 各子屏，见对应文档的组件树
```

## 状态矩阵

| 态 | 本模块导航 |
| --- | --- |
| 默认 | 选中星闪时内容是支持与开关 |
| 按下 | 入口卡松手后 push。底栏切换先 pop 到根 |
| 禁用 | 不支持或开关关闭时入口卡 disabled，原因在卡上。Tab 本身仍可进入来阅读说明 |
| 空 | 壳不出现「没有星闪模块」。没有设备的空态在扫描页 |
| 错误 | 未知路由停在当前页，`YoToast` |
| 加载 | 支持查询的加载在根页内容区，不挡住其他 Tab |
| 无权限 | 进入模块不弹授权（NL-013）。拒绝后的权限墙在扫描页（NL-015、NL-016） |

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `nearlink/shell-navigation` |
| 架构编号 | 目的地分表，不单占一条 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6 |
| 工作台入口 | 槽 0 的星闪卡片。无 WB 编号 |

| 目的地 | 文档 | 编号 |
| --- | --- | --- |
| 支持与开关 | [support-radio.md](support-radio.md) | NL-001–NL-018、NL-111、NL-112、NL-115 |
| 扫描与过滤 | [scan-filters.md](scan-filters.md) | NL-019–NL-052、NL-104、NL-110 |
| 广播 | [advertising.md](advertising.md) | NL-053–NL-057 |
| SSAP 客户端 | [ssap-client.md](ssap-client.md) | NL-059–NL-076、NL-105、NL-106、NL-114 |
| SSAP 服务端 | [ssap-server.md](ssap-server.md) | NL-077–NL-079、NL-116–NL-120 |
| 端口终端 | [port-terminal.md](port-terminal.md) | NL-058、NL-080–NL-092、NL-102 |
| 配对与加密 | [pairing-encryption.md](pairing-encryption.md) | NL-093–NL-101 |
| 会话日志 | [session-log.md](session-log.md) | NL-103、NL-107–NL-109、NL-113 |

离开星闪 Tab 时取消开关订阅（NL-009）。若扫描仍在进行，先停止扫描（NL-027、NL-110）。页面不调用 `@kit.NearLinkKit`。
