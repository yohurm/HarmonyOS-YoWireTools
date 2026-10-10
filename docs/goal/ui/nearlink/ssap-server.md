---
id: ui.nearlink.ssap-server
type: ui-design
status: draft
when: phase-c
related:
  - docs/goal/ui/nearlink/shell-navigation.md
  - docs/goal/checklist/nearlink.md
  - docs/goal/architecture/nearlink/NL-077.md
---

# SSAP 服务端

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
| 默认 | 服务端未打开时，添加与通知禁用，原因「服务端未打开」 |
| 按下 | 应答与通知松手后才发送。 |
| 禁用 | 无通知位时不能把「已通知」做成可点成功（NL-079）。服务端关闭后操作禁用（NL-119）。 |
| 空 | 无服务、无请求分别用 `YoEmpty`，文案不同 |
| 错误 | 码留在 `YoError`，待回复状态保持到成功发送 |
| 加载 | 按钮级。队列不在加载时被清空 |
| 无权限 | 未授权不添加服务、不应答读写。权限墙不用「还没有请求」的空态代替。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `nearlink/ssap-server` |
| 架构编号 | NL-077 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6 。文件不在 `main` |
| 工作台入口 | 工作台「星闪」卡片，或底栏星闪槽（下标 3） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


本端声明服务，应答对端的读和有响应写，并按地址发送通知。关闭服务端用 `close`，不出现名为断开连接的成功按钮。删除服务用 `removeService`。

架构：`docs/goal/architecture/nearlink/NL-077.md`、`NL-078.md`、`NL-079.md`、`NL-116.md` 至 `NL-120.md`。

## 导航

| 从 | 到 | 方式 | 返回 |
| --- | --- | --- | --- |
| 根页「SSAP 服务端」 | 服务列表 `MODULE` | 压栈 | 返回根页。服务端仍打开时入口卡保持「服务端已打开」 |
| 一条读或写请求 | 请求 `OBJECT` | 窄屏压栈；大于等于 600vp 左列表右请求，4:6 | 返回列表，未回复的请求仍标「待回复」 |
| 关闭服务端 | 系统对话框 | 确认后调用 `close` | 取消则保持打开 |
| 删除服务 | 系统对话框 | 确认后 `removeService` | 取消则 UUID 仍在 |

本页胶囊写「已添加」。对端真机能在服务树里看到该 UUID，才算 NL-077 通过。本页不提供「对端已发现」按钮。

## 信息密度

| 留在屏上 | 放进请求页 |
| --- | --- |
| 服务端已打开或已关闭 | 本次 `requestId`、地址、写类型 |
| 服务 UUID 列表 | 要回复的值 HEX |
| 待回复计数 | 无响应写的完整值 |
| 最近一次通知的地址与 `propertyUuid` 摘要 | 发送失败的错误码全文 |

待回复用警告胶囊，数字大于 0 时停在列表顶，避免有响应写被收进详情后忘掉。

## 布局

服务列表在上，请求队列在下。窄屏请求只显示地址、类型、待回复。宽屏选中请求后右栏展开回复表单。删除与关闭固定在标题栏菜单，用 `YoTitleBarMenuItem`，关闭为危险语义，点按后走系统对话框。

## 组件

| 区域 | 组件 |
| --- | --- |
| 页壳 | `YoPageShell` |
| 已打开、已关闭、待回复、已回复、无响应写 | `YoStatusPill` |
| 添加服务、发送响应、通知、删除、关闭 | `YoActionButton` |
| 无服务 | `YoEmpty` |
| 未声明通知仍点通知 | 按钮禁用 + 原因，不调用接口 |
| 添加或关闭失败 | `YoError` |

## 控件六态

| 控件 | 默认 | 按下 | 禁用 | 空 | 错误 | 加载 |
| --- | --- | --- | --- | --- | --- | --- |
| 添加服务 | 「添加服务」 | 按下 | 服务端已关闭；UUID 空 | 列表用 `YoEmpty`「尚未添加服务」 | 添加失败带码，列表不出现该 UUID | 按钮 `loading` |
| 回复读 | 请求页「发送响应」 | 按下 | 没有 `requestId` | 无待回复时按钮不在列表顶冒充 | 响应失败保持待回复 | `loading` |
| 回复有响应写 | 同上，文案「回复此次写入」 | 按下 | `WRITE_NO_RESPONSE` 时按钮不出现 | 无 | 失败保持待回复 | `loading` |
| 通知对端 | 已有客户端地址且属性含 `NOTIFY` | 按下 | 不含 `NOTIFY`，原因「属性未声明通知」（NL-079）；没有地址 | 无客户端时 `YoEmpty` 不占用通知按钮的成功位 | 失败带码 | `loading` |
| 删除服务 | 危险按钮 | 按下 | 该 UUID 未添加 | 无 | 失败则 UUID 仍在 | 确认后的请求 `loading` |
| 关闭 | 标题栏危险操作 | 按下 | 已经关闭 | 关闭后列表区改为已关闭说明，不是空服务成功 | 关闭失败保持已打开 | `loading` |

## 页面状态

| 状态 | 屏上 |
| --- | --- |
| 默认 | 服务端未打开时，添加与通知禁用，原因「服务端未打开」 |
| 已添加 | 列表含该 UUID。对端在真机上发现服务能看到它（NL-077）。本页胶囊是「已添加」 |
| 读请求 | 响应携带同一次 `requestId`。日志 ID 与请求一致（NL-078） |
| 有响应写 | `writeType` 为 `WRITE` 时必须 `sendResponse`，`requestId` 与 `address` 都与请求相同（NL-116）。回复后胶囊「已回复」 |
| 无响应写 | 留下值与写类型。不出现「已回复」。日志含 `WRITE_NO_RESPONSE`，且没有该 `requestId` 的 `sendResponse`（NL-117） |
| 通知 | 成功日志含地址和 `propertyUuid`（NL-118）。屏上摘要与之一致 |
| 未声明通知 | 不调用 `notifyPropertyChanged`，提示属性未声明通知（NL-079） |
| 已关闭 | 「服务端已关闭」（NL-119）。没有「已断开连接」按钮或成功胶囊 |
| 已删除 | 列表不再含该 UUID（NL-120） |
| 空 | 无服务、无请求分别用 `YoEmpty`，文案不同 |
| 加载 | 按钮级。队列不在加载时被清空 |
| 错误 | 码留在 `YoError`，待回复状态保持到成功发送 |

## 验收对照

| 条目 | 屏上证据 |
| --- | --- |
| NL-077 | 本端列表有该服务 UUID |
| NL-078 | 日志 `requestId` 与读请求一致 |
| NL-079 | 未声明通知的提示，无通知成功 |
| NL-116 | 回复日志的 `requestId` 与地址 |
| NL-117 | 有值与写类型，无该次 `sendResponse` |
| NL-118 | 成功日志中的地址与 UUID |
| NL-119 | 「服务端已关闭」 |
| NL-120 | 列表与日志都不再把该 UUID 当作现存服务 |
