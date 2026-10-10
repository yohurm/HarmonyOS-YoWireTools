# 工作台

槽位 0，标题「工作台」。`main` 上 `HomeFeaturePage` 是空 `Column`。目标布局是最近会话的扫描列表头，而不是三张模块海报。底栏已经能进蓝牙、网络、星闪，工作台不再放三张入口卡。

读哪些会话等 PR #21 的读模型对齐。对齐前这一屏的绑定标成未接线：界面规格仍按下面画，实现时若 ViewModel 没有行，只能出空态，不能填示例 SSID 或示例 MAC。

## 布局

标题下不放 Title_M 大字（标题栏已经是「工作台」）。第一行是文字按钮「日志」和「命令」，右对齐，高度 40。它们 push 日志中心和命令面板，不是底栏项。

其下 `SubHeader`「最近」。`List` 行 64vp：左 24vp 图标按模块（蓝牙、网络、星闪，资源名核对后再用），主行会话标题 Body_L，次行时间 Body_S。行点击 push 到该会话已有的终端；没有目标路由时行仍显示，点击不跳，次行追加「不能打开」。

无行：不显示 SubHeader。Body_M「还没有会话」，没有雷达，没有「搜索成功」。

不显示三枚射频总开关。开关在各模块概览。

宽屏：列表最大宽 600vp。两个文字按钮留在右上。

## 组件树

```text
NavDestination 「工作台」  根槽，无返回
  Column
    Row padding 16
      Blank
      Button TEXTUAL 「日志」
      Button TEXTUAL 「命令」
    SubHeader 「最近」  仅有行
    List
      ListItem 64
        SymbolGlyph 24
        Column Text 标题 / Text 时间
    空时 Column
      Text Body_M 「还没有会话」
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 有会话行。日志、命令可点 |
| 按下 | 行按压。文字按钮按下 |
| 禁用 | 某一行 ViewModel 标成不能打开：文字 text.disabled，无按压，次行「不能打开」 |
| 空 | 「还没有会话」。日志和命令仍在 |
| 错 | 列表区换成 Body_M status.error 消息。两个按钮仍在 |
| 加载 | SubHeader 位置 LoadingProgress「正在读取」。不展示假行 |
| 无权限 | 工作台不申请射频权限，无权限墙 |

## 对照

采用扫描列表的「没有行就不要成功态」，采用 WLAN 的双行列表，采用家居模板仅限于底栏不在本页重复。不采用连接 sheet、四场景、控制台（命令和日志是下一屏）、FastBle、体温卡、wifi 密码框。
