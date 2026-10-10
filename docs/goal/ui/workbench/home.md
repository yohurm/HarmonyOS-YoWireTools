---
id: ui.workbench.home
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/information-architecture.md
  - docs/goal/ui/workbench/command-panel.md
  - docs/goal/ui/log/center.md
  - product/phone/src/main/ets/navigation/AppRoutes.ets
  - features/home/src/main/ets/ui/page/HomeFeaturePage.ets
  - .projectark/2-需求文档/无线调试工具/PRD/01-产品信息架构与模式PRD.md
---

# 工作台

设计屏号 `screen.workbench.home`。路由 `/home/workbench`，槽位 `AppRoutes.TAB_INDEX_WORKBENCH` = 0。`main` 上的 `HomeFeaturePage` 是空壳。本屏只规定看见什么。

没有 WB 架构编号。功能 Goal 的已打开 PR 未给工作台切片。最近会话从哪个对象读出，本屏不新命名查询函数。页面只读页面状态。

## 布局

`ROOT_TAB`。自上而下四块，间距 `YoSpace.XL`：

1. 状态条：蓝牙、WLAN、星闪各一枚胶囊。事实来自各模块已经定义的状态句，工作台不重算。
2. 三张模块入口卡：蓝牙、网络、星闪。
3. 最近会话列表，最多五行。点一行进入该模块里已经存在的对象页或终端。
4. 两张次入口：日志中心、命令面板。

窄屏一列。不小于 600vp 时入口卡用 `GridRow` 三列，列表仍在下方，不把工作台做成 `NavigationMode.Split`。不小于 840vp 时应用壳已经是侧栏，本页结构不变。

轻量模式只留入口卡、最近会话和三枚状态胶囊。专家模式在状态条下多一行：后台记录是否开启、日志占用。模式开关在设置页，不在本页发明第二套模式存储。

## ArkUI 组件树

```text
YoPageShell                              // ROOT_TAB，HdsNavigation 标题「工作台」
└── Column
    ├── Row
    │   ├── YoStatusPill                  // 蓝牙
    │   ├── YoStatusPill                  // WLAN
    │   └── YoStatusPill                  // 星闪
    ├── GridRow
    │   └── GridCol
    │       └── YoModeEntryCard
    ├── List
    │   └── ListItem                      // accessibilityGroup，朗读名称与状态
    │       └── Row
    │           ├── Text
    │           └── YoStatusPill
    └── Row
        ├── YoModeEntryCard               // 日志中心
        └── YoModeEntryCard               // 命令面板
```

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 三枚胶囊显示各模块最后一次已知状态。未读取为「未读取」，`neutral`。入口卡可点 |
| 按下 | 卡片和会话行用 `YoColor.INTERACTIVE_PRESSED`。松手才切换 Tab 或 push。按下不开始扫描 |
| 禁用 | 模块在模拟器或能力不支持时，卡片仍可点，用来阅读该模块的不可用说明。不把卡片 disabled 成无法查看缺口 |
| 空 | 没有任何最近会话：列表区 `YoEmpty`「还没有会话」，主操作留空。模块入口仍在。这不是权限失败 |
| 错误 | 某一模块的最近一次终态是错误时，只在该胶囊上用 `error`，不把整页换成 `YoError` |
| 加载 | 三个状态都还没有快照时，状态条 `YoLoading`「正在读取状态」。入口卡仍可点进模块，由模块页自己加载 |
| 无权限 | 工作台不弹授权。胶囊写「未授权」时点卡片进入该模块，权限墙在模块里按 [权限墙](../app-shell/permission-gap-wall.md) 显示 |

## 编号追溯

| 区域 | 去向 | 架构编号 |
| --- | --- | --- |
| 蓝牙卡片 | `/bluetooth/overview` | BT-001 起，见适配器页 |
| 网络卡片 | `/wifi/overview` | WN-001 起 |
| 星闪卡片 | `/nearlink/overview` | NL-001 起 |
| 最近会话行 | 该会话所属模块的对象页或终端 | 行上的模块编号。没有统一会话架构号 |
| 日志 | [日志中心](../log/center.md) | 无 LOG 编号。行内容对应 BT-086–BT-090、NL-107–NL-109、WN-128–WN-132 |
| 命令面板 | [命令面板](command-panel.md) | 无架构编号。PRD 02 |

PR #1（`cursor/workbench-feature-hub-434e`）有未合并的工作台草稿。本设计不把它的用例签名当成已入库接口。
