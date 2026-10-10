# 命令面板

从工作台 push。目标名对应架构 `/command/list`。`main` 上没有这页。模式：list + 一次执行。不是周期发送的控制台；周期若契约没有，界面不画间隔输入框。

## 布局

标题「命令」。`List` 56vp：命令名 Body_L，次行 Body_S 为参数摘要或「无参数」。点行选中，选中行 brand 浅底。

底部固定栏：主按钮「执行一次」。未选中时 enabled false。执行中按钮「正在执行」+ LoadingProgress，列表仍可滚动但不可改选中。

结果不占新页：按钮上方一行 Body_S，成功用 text.secondary，失败用 status.error。无结果时这行不占位。

空：Body_M「还没有命令」，底栏按钮禁用。

宽屏：左列表 320vp，右栏是选中项的只读参数，标签/值同链路详情。窄屏参数只在次行，不 push。

执行需要哪一路会话，界面不猜。ViewModel 没有焦点会话时，结果行写「没有可执行的会话」，按钮禁用。文案可以显示，不表示功能编号已经在 `main` 验收。

## 组件树

```text
NavDestination 「命令」
  Column
    List layoutWeight 1
      ListItem 56
        Text Body_L 名称
        Text Body_S 参数摘要
    Text Body_S 结果  可选
    Row padding 16
      Button EMPHASIZED 「执行一次」
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 有行，选中一行，按钮可点 |
| 按下 | 行按压后成为选中。按钮按下 |
| 禁用 | 无选中或无会话：按钮禁用 |
| 空 | 「还没有命令」，无选中底 |
| 错 | 结果行 status.error，选中保留，按钮恢复「执行一次」 |
| 加载 | 「正在执行」，按钮禁用，行不可改选中 |
| 无权限 | 若执行被权限挡住：不换整页墙。结果行写 ViewModel 的权限句，并给文字按钮「去授权」 |

## 对照

采用 WLAN 的只读详情（宽屏）和一颗主按钮。不采用扫描雷达、wifi 密码、四场景、IKConsole 的多页签、家居海报、FastBle、数据卡。
