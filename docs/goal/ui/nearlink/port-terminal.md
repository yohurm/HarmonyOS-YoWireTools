---
id: ui.nearlink.port-terminal
type: ui-design
status: draft
when: phase-c
related:
  - docs/goal/ui/nearlink/shell-navigation.md
  - docs/goal/ui/nearlink/pairing-encryption.md
  - docs/goal/checklist/nearlink.md
  - docs/goal/architecture/nearlink/NL-080.md
---

# 端口终端

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell                         // TERMINAL
        └── Column
            ├── Row
            │   ├── Text
            │   └── YoStatusPill
            ├── List                        // 收发记录，边到边
            │   └── ListItem
            │       └── Text                // MONO_S，文本或 HEX
            └── Row
                ├── TextInput               // 或 TextArea
                └── YoActionButton          // 发送 / 停止
YoSplitScaffold                             // ≥600vp 用 6:4
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 角色胶囊「两端对等，任一端可发起连接」。不出现「SSAP 客户端」（NL-058） |
| 按下 | 发送与断开松手后才提交。 |
| 禁用 | 未注册、UUID 不一致或拥塞时发送禁用，原因可见（NL-080、NL-090）。 |
| 空 | 无记录时列表区「尚未收发」，统计为 0，并仍标应用层 |
| 错误 | 码在行内或 `YoError`，连接胶囊保持未建立或已断开，不跳到已连接 |
| 加载 | 注册与连接用按钮加载。已有记录不被加载态替换 |
| 无权限 | 未授权不注册端口。端口没有客户端角色（NL-058）是能力说明，不是权限墙。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `nearlink/port-terminal` |
| 架构编号 | NL-080 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6 。文件不在 `main` |
| 工作台入口 | 工作台「星闪」卡片，或底栏星闪槽（下标 3） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


两端对等的数传会话。角色不是 SSAP 客户端。加密胶囊的文案由配对与加密页规定，本页只留出顶栏位置。

架构：`docs/goal/architecture/nearlink/NL-058.md`、`NL-080.md` 至 `NL-092.md`、`NL-102.md`。

## 导航

| 从 | 到 | 方式 | 返回 |
| --- | --- | --- | --- |
| 根页或扫描详情「端口」 | 端口列表 `MODULE` | 压栈 | 返回。若用户选择释放，先 `destroyPort` |
| 一条端口 | 终端 `TERMINAL` | 窄屏压栈；大于等于 600vp 时列表:终端为 6:4 | 返回列表 |
| 关闭会话 | 系统对话框：释放或保持 | 模态 | 取消则留在终端 |
| 超过 MTU | 系统对话框：取消或切片 | 未确认不调用 `writeData` | 取消留在输入框 |
| 加密说明 | 配对页 | 从顶栏胶囊进入 | 返回终端，草稿仍在 |

`YoNavDestinationKind.TERMINAL` 隐藏底栏。输入条贴在安全区之上。

## 信息密度

| 留在屏上 | 放进单条详情 |
| --- | --- |
| 角色句「两端对等」 | 单条 HEX 全文 |
| 连接胶囊、协商 MTU、模式（基础或可靠） | 拥塞时刻与下一次允许发送的时间 |
| 应用层：发送字节、接收字节、包数 | 接口名进会话日志 |
| 最近若干条收发，方向 + 字节数 + 一行 HEX | 更早的记录进会话日志，终端可滚动但不把统计区挤出首屏 |
| 加密胶囊（未知 / 未加密 / 已加密） | 禁止发送的原因全文 |

统计句里含「应用层」，并写明不是空口速率（NL-102）。不提供 bps 成功值。

## 布局

终端是 `List`，新记录贴底。统计条固定在列表上方，高度一行。输入区：分段「文本 / HEX」、输入框、发送。窄屏分段在输入框上；宽屏同一行。不使用已删除的 `DataTerminalView`。

拥塞时发送按钮禁用，列表顶插入一条错误记录，不弹遮罩挡住记录。

`YoImmersiveSurface` 只铺终端列表的背景材质，里面仍是普通列表，不把业务句写进 Kit。

## 组件

| 区域 | 组件 |
| --- | --- |
| 页壳 | `YoPageShell`，`TERMINAL` |
| 对等、已连接、未建立、拥塞、占用 | `YoStatusPill` |
| 注册、连接、发送、断开、销毁 | `YoActionButton` |
| 文本或 HEX、基础或可靠 | `YoSegmentButton` |
| 无端口 | `YoEmpty` |
| 注册失败、UUID 不一致、拥塞 | `YoError` 或行内错误 |
| 加密胶囊 | `YoStatusPill`，规则见配对页 |

## 控件六态

| 控件 | 默认 | 按下 | 禁用 | 空 | 错误 | 加载 |
| --- | --- | --- | --- | --- | --- | --- |
| 注册 | 「注册端口」 | 按下 | UUID 空；星闪关闭 | 无端口时 `YoEmpty`「尚未注册端口」 | `1009700020` 已注册，提供销毁后重试（NL-082）。`1009700021` 提示销毁其他端口，不写个数上限（NL-083） | `loading` |
| 连接 | UUID 已注册 | 按下 | 未注册 | 未建立不是空列表成功 | 对端 UUID 不同：保持未建立，提示两端 UUID 必须一致（NL-080） | 连接中 `loading`，不显示已连接 |
| 模式 | 默认基础 | 分段按下 | 已连接后禁用，原因「断开后再改模式」 | 无 | 无 | 无 |
| MTU 输入 | 空白表示默认 512 | 焦点 | 已连接后禁用 | 空白不是错误 | 超出 0 到 65535 不发起 | 无 |
| 发送 | 已连接 | 按下 | 未连接；拥塞间隔未到；未加密且用户禁止发送（见配对页 NL-096） | 输入空不发送 | HEX 奇数位或非法字符，校验句，不调用 `writeData` | 单次发送 `loading`；无响应式的「等待对端确认」不存在 |
| 断开 | 「断开」 | 按下 | 未连接 | 无 | 失败保持已连接并显示码 | `loading` |
| 销毁 | 危险 | 按下 | 选择保持时不销毁 | 无 | 从未注册的 UUID：`1009700022`（NL-084） | 确认后 `loading` |

## 页面状态

| 状态 | 屏上 |
| --- | --- |
| 默认 | 角色胶囊「两端对等，任一端可发起连接」。不出现「SSAP 客户端」（NL-058） |
| 未建立 | UUID 不一致或尚未 `connectionStateChanged`。胶囊「未建立」（NL-080） |
| 已连接 | 胶囊「已连接」，并显示 `ConnectionResult.mtu`（NL-081） |
| 模式 | 基础：无重传。可靠：有重传。默认基础（NL-089） |
| MTU | 不填则日志里的请求为 512。填写只接受 0 到 65535。旁边写明这不是 SSAP 的 22 到 512（NL-088） |
| 发送 | 文本与 HEX 两条出方向记录，标明类型和字节数（NL-085） |
| 接收 | 入方向，含地址、UUID、HEX（NL-086） |
| 超过端口 MTU | 提示中写出 `ConnectionResult.mtu`。未确认切片不发送（NL-087） |
| 拥塞 | `1009700023`，停止连发，后续间隔至少 10ms，每次写错误日志（NL-090） |
| 已断开 | 胶囊「已断开」。接收订阅在重连前取消（NL-091） |
| 释放 | 调用 `destroyPort`。保持：列表仍显示该 UUID 占用（NL-092） |
| 空 | 无记录时列表区「尚未收发」，统计为 0，并仍标应用层 |
| 加载 | 注册与连接用按钮加载。已有记录不被加载态替换 |
| 错误 | 码在行内或 `YoError`，连接胶囊保持未建立或已断开，不跳到已连接 |
| 重连 | 与 SSAP 相同：用户点击才再次连接，无「系统将自动重连」（NL-105） |

应用层计数始终可见：发送字节、接收字节、包数（NL-102）。

## 验收对照

| 条目 | 屏上证据 |
| --- | --- |
| NL-058 | 「两端对等」 |
| NL-080 | 未建立 + UUID 必须一致 |
| NL-081 | 已连接与协商 MTU |
| NL-082 | `1009700020` 与销毁后重试 |
| NL-083 | `1009700021`，无个数上限 |
| NL-084 | `1009700022` |
| NL-085 | 出方向的类型与字节数 |
| NL-086 | 入方向的地址、UUID、HEX |
| NL-087 | 提示中的端口 MTU |
| NL-088 | 默认 512，范围与 SSAP 分开 |
| NL-089 | 基础 / 可靠文案，默认基础 |
| NL-090 | 拥塞码与间隔后的发送时间 |
| NL-091 | 已断开 |
| NL-092 | 销毁日志或占用列表 |
| NL-102 | 统计含「应用层」 |
