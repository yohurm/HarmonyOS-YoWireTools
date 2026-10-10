---
id: ui.nearlink.pairing-encryption
type: ui-design
status: draft
when: phase-c
related:
  - docs/goal/ui/nearlink/port-terminal.md
  - docs/goal/ui/nearlink/shell-navigation.md
  - docs/goal/checklist/nearlink.md
  - docs/goal/architecture/nearlink/NL-093.md
  - docs/goal/architecture/nearlink/NL-101.md
---

# 配对与加密

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Scroll
            └── Column
                ├── Row
                │   ├── Text
                │   └── YoStatusPill
                ├── TextInput
                ├── YoSegmentButton
                ├── List
                │   └── ListItem
                └── YoActionButton
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 未读取 ACB。顶栏与本页都是「加密状态未知」或「未验证」。不显示已加密（NL-093） |
| 按下 | 发起配对松手后才调用系统确认（NL-097）。没有应用内 PIN。 |
| 禁用 | 低版本没有配对发起接口时，按钮禁用并说明（NL-100）。解除配对不是可点成功按钮（NL-101）。 |
| 空 | 没有地址时不展示假的已配对 |
| 错误 | 配对失败原因可见（NL-099）。已连接但未加密用警告胶囊，不用成功胶囊（NL-095）。 |
| 加载 | 仅配对按钮与 ACB 读取。不明文案期间不显示已加密 |
| 无权限 | 未授权不发起配对。不能解除配对（NL-101）是缺口墙，不是权限墙。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `nearlink/pairing-encryption` |
| 架构编号 | NL-093, NL-101 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6 。文件不在 `main` |
| 工作台入口 | 工作台「星闪」卡片，或底栏星闪槽（下标 3） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


配对走系统确认。加密只相信 `getAcbState()` 的 `ENCRYPTED`。解除配对没有成功路径。

架构：`docs/goal/architecture/nearlink/NL-093.md` 至 `NL-101.md`。

## 导航

| 从 | 到 | 方式 | 返回 |
| --- | --- | --- | --- |
| 根页「配对」 | 本页 `MODULE` | 压栈 | 返回根页 |
| 端口终端顶栏胶囊 | 本页，带上当前端口地址 | 压栈 | 返回终端 |
| 点击配对 | 系统配对界面 | 离开本模块的绘制，系统负责免输入、数字比较或通行码 | 系统结束后回到本页，显示结果 |
| 低版本或已配对 | 留在本页 | 不调用或不再次冒充流程 | 无 |
| 解除配对说明 | 页内缺口块 | 不压栈到成功页 | 无 |

模块内没有配对码输入框（NL-097）。

## 信息密度

| 留在屏上 | 放进日志详情 |
| --- | --- |
| 配对胶囊：未配对 / 配对中 / 已配对 / 失败原因 | `startPairing` 的日志行 |
| 加密胶囊：未知或未验证 / 未加密 / 已加密 | ACB 原始值 |
| 「未加密时禁止发送」开关 | 被拦住的发送不产生出方向字节 |
| 缺口句：不能解除配对 | 无「已解除」记录 |

端口终端顶栏只重复加密胶囊的短文案，不重复配对原因全文。

## 布局

上半是当前地址的配对与加密，下半是「未加密时禁止发送」。窄屏单列。宽屏两列：左状态，右开关和缺口说明，避免开关离状态太远。开关使用系统 `Toggle`，标签用 `YoTypeStyle`，不恢复 `YoSwitchRow`。

## 组件

| 区域 | 组件 |
| --- | --- |
| 页壳 | `YoPageShell`，`MODULE` |
| 配对与加密 | `YoStatusPill` |
| 发起配对 | `YoActionButton` |
| 失败原因、低版本 | `YoError` 或状态条下的 `causeHint` |
| 尚未选择设备 | `YoEmpty` |
| 禁止发送 | 系统开关；终端发送按钮读取同一页面状态 |

## 控件六态

| 控件 | 默认 | 按下 | 禁用 | 空 | 错误 | 加载 |
| --- | --- | --- | --- | --- | --- | --- |
| 配对 | 「配对」 | 按下 | 无目标地址；系统低于 5.1.0(18)，原因含起始版本（NL-100） | 无设备：`YoEmpty`「先从扫描结果选择设备」 | 已配对再次点击：显示已经配对；`1009700099` 也按已配对解释（NL-098） | 等待系统界面时按钮 `loading`，胶囊「配对中」 |
| 加密胶囊 | 尚未读取 ACB：`neutral`「加密状态未知」（NL-093） | 不可点，点按进入本页而不是改变状态 | 无「禁用的已加密」 | 未知不是空字符串 | 读取失败显示码，胶囊保持未知，不升为已加密 | 读取 ACB 时胶囊旁加载，不把未知改成已加密 |
| 禁止发送开关 | 关闭 | 系统按下 | 无会话时禁用，原因「没有端口会话」 | 无 | 无 | 无 |
| 终端发送（受本开关影响） | 见端口终端 | 按下 | ACB 不是 `ENCRYPTED` 且开关打开时禁用，原因「当前未加密」（NL-096） | 无 | 不产生出方向字节 | 不进入发送加载 |

## 页面状态

| 状态 | 屏上 |
| --- | --- |
| 默认 | 未读取 ACB。顶栏与本页都是「加密状态未知」或「未验证」。不显示已加密（NL-093） |
| 已加密 | `ENCRYPTED` 时胶囊 `success`「已加密」（NL-094） |
| 未加密 | ACB 为 `CONNECTED` 时胶囊 `warning`「未加密」，并写「不要发送敏感数据」（NL-095） |
| 禁止发送打开且未加密 | 端口发送不调用 `writeData`（NL-096） |
| 系统配对 | 不低于 5.1.0(18)、目标未配对：出现系统确认。日志含 `startPairing`（NL-097） |
| 已配对 | 「已经配对」（NL-098） |
| 配对失败 | 取消、对端不支持服务、连接数达上限，各用对应 `PairingReason` 文案（NL-099）。胶囊 `error`，不是未知故障 |
| 低版本 | 「当前系统版本不提供该能力」，起始版本 5.1.0(18)。不调用 `startPairing`（NL-100） |
| 加载 | 仅配对按钮与 ACB 读取。不明文案期间不显示已加密 |
| 空 | 没有地址时不展示假的已配对 |

## 缺口：不能解除配对（NL-101）

已配对时，本页没有「解除配对」按钮，没有滑动删除，没有「已解除配对」胶囊。固定说明：「本模块没有解除配对接口，请在系统设置中处理。」

说明是中性正文加 `warning` 胶囊「Kit 未提供」。不提供可完成的主操作。用户从系统设置返回后，只有新的 `getPairingState()` 结果可以改变配对胶囊。

依据：`docs/goal/architecture/nearlink/NL-101.md`。

## 验收对照

| 条目 | 屏上证据 |
| --- | --- |
| NL-093 | 顶栏未知或未验证，无已加密 |
| NL-094 | 已加密，日志有 ACB |
| NL-095 | 未加密与敏感数据提示 |
| NL-096 | 无出方向字节 |
| NL-097 | 系统配对界面；模块内无自绘配对码 |
| NL-098 | 已经配对；`1009700099` 不显示成未知故障 |
| NL-099 | `PairingReason` 文案 |
| NL-100 | 起始版本 5.1.0(18) |
| NL-101 | 缺口说明，无解除成功态 |
