# WLAN 扫描

目标页，对应模块设计里的扫描页。路由名等契约对齐，不在本文件新造路径常量。模式：扫描列表。选择某个 AP 后若要连接，用连接 sheet（wifi 扫描选择组件）。

## 布局

头：标题「正在扫描 / 扫描完成 / 尚未扫描 / 扫描失败」，辅文为 AP 数量或失败消息，文字按钮「扫描」或「停止」。

`List` 分组「已连接」「可用」，与 WLAN 参考一致。行 64vp：24vp 图标，SSID Body_L，次行「加密」或「开放」Body_S，右侧图标按钮「信息」40vp，点击 push 链路详情并带上该 AP 的标识（标识字段名等契约，界面只显示 ViewModel 的标题和次行）。

「连接」不放在每一行。点行打开 sheet：`Select` 已选中的 SSID（只有一项时 Select 仍显示该名，不可改成别的网）、密码 `TextInput`、可见性图标按钮、主按钮「下一步」、结果行「名称与结果」。这是参考截图里的控件，不是灯箱网页的收藏按钮。

开放网络不渲染密码框。主按钮仍是「下一步」。

## 组件树

```text
NavDestination 「扫描」
  Column
    结果头
    List
      ListItemGroup SubHeader 「已连接」
      ListItemGroup SubHeader 「可用」
        ListItem 64
          SymbolGlyph 24
          Column Text SSID / Text 「加密」|「开放」
          Button 图标 「信息」
bindSheet
  Select 当前 SSID
  TextInput Password  仅加密
  Button 图标 可见性
  Button EMPHASIZED 「下一步」
  Text Body_S 结果
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 「扫描完成」，辅文为数量。两组按有无数据渲染。空的「已连接」不占 SubHeader |
| 按下 | 行、信息按钮、下一步 |
| 禁用 | WLAN 关：缺口「WLAN 未打开」+「打开系统设置」。sheet 打不开 |
| 空 | 「尚未扫描」+ 图示 +「扫描」。无分组 |
| 错 | 「扫描失败」+ 消息。sheet 内下一步失败时结果行错误色，sheet 保持打开，密码保留 |
| 加载 | 「正在扫描」+ LoadingProgress +「停止」。已有行保留 |
| 无权限 | 权限墙「需要 WLAN 权限」 |

## 对照

采用 wifi 选择的 sheet 和蓝牙扫描的结果头、WLAN 的两组列表。不采用场景 Tab（那是诊断）、控制台、家居海报、体温卡、FastBle 的厂商字段。
