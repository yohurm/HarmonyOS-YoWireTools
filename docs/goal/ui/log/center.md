---
id: ui.log.center
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/log/detail.md
  - docs/goal/ui/bluetooth/throughput-packets-log.md
  - docs/goal/ui/nearlink/session-log.md
  - docs/goal/ui/wifi-network/session-log.md
  - .projectark/2-需求文档/无线调试工具/PRD/02-统一日志与命令面板PRD.md
---

# 日志中心

设计屏号 `screen.log.center`。从工作台进入，层级 `MODULE`。各模块标题菜单里的「会话日志」仍进入该模块自己的日志屏，不强制改道到这里。

## 读模型缺口

三份未合并架构稿没有一条共同的读接口：

| 模块 | 架构稿里的日志名字 | 出处 |
| --- | --- | --- |
| 蓝牙 | 进程日志走 `YoLog`。会话导出见 BT-090 | PR #8，BT-001 与 BT-090 |
| 星闪 | `DebugLogRecord` | PR #6，NL-001；展示见 NL-107 |
| Wi-Fi | `LogCaptureService`，落库 `LogRepository` | PR #7，WN-001；行字段见 WN-128 |

本屏不新命名跨模块查询函数，也不把 `YoLog` 说成 `LogRepository`。页面只渲染页面状态给出的行。单一读路径等待功能侧 shell function docs PR，不在这里猜路径，也不自编 `LOG-` 编号。

## 布局

顶：`Search` 做关键字。旁边 `YoSegmentButton` 切模块：全部、蓝牙、网络、星闪。宽度写在外层 `Scroll`，不写在 `SegmentButton` 上。
列表：主行时间加模块胶囊，次行方向、目标摘要、错误码。文本或 HEX 不在主行铺开。
底：导出、清空。清空先 `AlertDialog`。

窄屏单列。不小于 600vp 时左列表右详情，详情即 [detail.md](detail.md)，4:6。

行字段对齐 PRD 02 里用户要看见的那些：时间、模块、方向、协议、目标、错误码、文本或 HEX。缺字段留空。

## ArkUI 组件树

```text
NavDestination
└── YoPageShell
    └── Column
        ├── Search
        ├── Scroll
        │   └── YoSegmentButton
        ├── List
        │   └── ListItem
        │       └── Column
        │           ├── Row
        │           │   ├── Text
        │           │   └── YoStatusPill
        │           └── Text
        └── Row
            ├── YoActionButton
            └── YoActionButton
YoSplitScaffold                         // ≥600vp
```

`Search` 的专页在 `开发/API参考/…/ArkTS组件/文本与输入/Search.md`。样例搜索框在 HarmonyOSComponentUXExamples 的 `components/input`。模块内过滤仍用 Phase-C 的 `TextInput`，因为那些屏是表单而不是搜索页。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 有行。最新在上。选中行在宽屏右栏重复时间、方向、错误码 |
| 按下 | 行按下后松手打开详情或更新右栏。导出与清空走按钮按下态 |
| 禁用 | 当前过滤结果为空时导出和清空禁用，原因「没有日志」 |
| 空 | 没有任何行，或过滤后为零：`YoEmpty`「没有会话日志」。这与写入失败不同 |
| 错误 | 导出失败 `YoError`，列表保留。读模型尚未就绪时，整页 `YoError`「日志来源未收口」，不显示编造的行 |
| 加载 | 打开时 `YoLoading`「正在读取会话日志」。新行到达不整页加载 |
| 无权限 | 本屏不申请射频或网络权限。某一行记录的是权限失败时，胶囊 `warning`，点进详情看错误码。不用权限墙挡住其他模块的行 |

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `screen.log.center` |
| 架构编号 | 无 LOG 切片。行内容可追溯到 BT-086–BT-090、NL-103、NL-107–NL-109、NL-113、WN-128–WN-132 |
| 工作台 | `screen.workbench.home` 的日志卡片。槽 0 |
