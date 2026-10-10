---
id: ui.workbench.command
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/workbench/home.md
  - .projectark/2-需求文档/无线调试工具/PRD/02-统一日志与命令面板PRD.md
---

# 命令面板

设计屏号 `screen.workbench.command`。从工作台进入，层级 `MODULE`。

PRD 02 要求命令可复用到 SPP、BLE Write、Socket 和星闪 dataTransfer。功能 Goal 没有给命令面板架构切片，也没有入库的执行函数名。本屏只规定操作如何呈现。执行意图交给页面状态。页面不调用 Kit，也不新命名 Repository。

## 布局

上：收藏列表，主行是命令名，次行是协议和目标摘要。
下：选中命令的只读参数。专家模式显示周期与超时。轻量模式隐藏周期，只留发送。
底：主按钮「执行一次」。周期发送是次按钮，默认不可用，直到设置里打开允许，并且页面状态给出上限。本屏不写死上限数字，避免和未入库的架构冲突。

窄屏上下堆叠。不小于 600vp 时 `YoSplitScaffold` 左列表右参数，4:6。

## ArkUI 组件树

```text
NavDestination
└── YoPageShell
    └── YoSplitScaffold
        ├── List
        │   └── ListItem
        │       └── Column
        │           ├── Text
        │           └── Text
        └── Column
            ├── Text
            ├── Text                         // 目标、协议，MONO_S
            ├── YoActionButton               // 执行一次，Button
            └── YoActionButton               // 周期，默认禁用
AlertDialog                                  // 停止周期前确认
```

没有 `YoTextField`。若以后要改参数，输入用 `TextInput`，本阶段参数只读，因为没有已入库的编辑接口。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 有收藏。选中第一条。主按钮可点。周期按钮禁用并说明原因 |
| 按下 | 行按下只选中。执行按钮松手后才把一次执行交给页面状态 |
| 禁用 | 没有选中、目标模块未连接、或上一次尚未终态时，执行禁用，原因可见。周期在设置未允许时保持禁用 |
| 空 | 没有收藏：`YoEmpty`「还没有命令」，没有主操作。不提供「新建命令」成功态，直到有架构编号描述创建 |
| 错误 | 执行终态失败：参数区 `YoError`，保留错误码。列表不删除该命令 |
| 加载 | 执行未终态：主按钮 `loading`，标签「执行中」。终态到达后离开加载 |
| 无权限 | 目标模块未授权时不执行。参数区换成该模块的权限墙文案，主操作「去该模块授权」。面板自己不弹系统授权框 |

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `screen.workbench.command` |
| 架构编号 | 无。不把 PRD 02 的章节号写成 WB 或 LOG 切片 |
| 工作台 | 从 `screen.workbench.home` 进入。槽 0 |
| 相关能力 | 执行结果若写入会话，呈现规则同各模块日志：BT-090、NL-107、WN-128。写到哪一个日志对象，见 [日志中心](../log/center.md) 的缺口 |
