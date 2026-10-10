# 更多

槽位 4。标题资源现为「更多」，底栏也是「更多」。不把底栏改成「设置」；页内 `SubHeader` 可以用「显示」「记录」这类分组名，分组是否与 PR #20 的设置清单一致，等 `docs/goal/checklist/settings.md` 进 `main` 再对名称。本页先固定能从界面上核对的四组，不把未进主干的八组写成已经存在。

`main` 上 `MoreFeaturePage` 是空壳。

## 布局

`List` 分组，行 56vp：名称 Body_L，次行当前值 Body_S 或「未读取」，行尾箭头。点行打开 `bindSheet` 编辑，不 push 大量子页。

组：

1. 显示。一行「主题」。sheet 里 `SegmentButton`「跟随系统」「浅色」「深色」。主按钮「完成」。值未读到时次行「未读取」，SegmentButton 无选中项，完成按钮禁用。
2. 记录。一行「日志」文字按钮行，点击 push 日志中心。没有第二套日志开关。
3. 关于。一行，次行版本号或「未读取」。sheet 只读，无主按钮。

没有「清除数据」。没有专家/轻量开关。这两项在未合并清单里是缺口，本视觉不先画一个不能接线的开关。

本页不申请蓝牙、星闪、WLAN 权限。

宽屏：列表最大宽 600vp，sheet 居中。

## 组件树

```text
NavDestination 「更多」
  List
    ListItemGroup
      SubHeader 「显示」
      ListItem 56 「主题」 次行 当前值|「未读取」
    ListItemGroup
      SubHeader 「记录」
      ListItem 56 「日志」
    ListItemGroup
      SubHeader 「关于」
      ListItem 56 「版本」
bindSheet 主题
  SegmentButton 三项
  Button EMPHASIZED 「完成」  未读到值时禁用
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 主题次行是三选一的当前词。版本有字 |
| 按下 | 行按压后开 sheet。完成按下 |
| 禁用 | 值未知：完成禁用，SegmentButton 不显示假选中 |
| 空 | 不把整页收成空插画。三组始终在，值用「未读取」 |
| 错 | 出错的那一行次行改为 status.error 的短消息，其他行保持 |
| 加载 | 次行位置 LoadingProgress，行不可开 sheet |
| 无权限 | 无权限墙 |

## 对照

采用家居模板「我的」的分组列表（登录、权限、关于那一列的行结构），不用它的插画和头像。主题 sheet 用一颗主按钮。不采用扫描、WLAN 双机、四格诊断、控制台、FastBle、体温卡。
