# 端口数传

目标路由 `/nearlink/data-transfer`。模式：控制台日志，发送栏同 SPP 终端。连接参数用一张 sheet，而不是把端口号放进日志行。

## 布局

未连接：内容区不是空日志。Title_M「未连接」，辅文 Body_M「填写端口后连接」。主按钮「连接」打开 sheet。sheet：`TextInput`「端口」，主按钮「连接」，失败结果行。没有第二字段就不要画占位输入框。

已连接：胶囊「已连接」，日志 `List` 48vp，底栏文本/HEX + 输入 +「发送」。标题栏菜单「断开」，经 AlertDialog 确认。

宽屏：未连接时表单居中，最大宽 480vp，不是拉满十二列。已连接时左列不需要，单列日志最大宽 720vp 居中，避免一行十六进制拉得过长。

## 组件树

```text
NavDestination 「数传」
  未连接 Column padding 16 gap 16  水平居中最大 480
    Text Title_M 「未连接」
    Text Body_M
    Button EMPHASIZED 「连接」
  已连接 Column
    胶囊 + 日志 List + 发送 Row
bindSheet
  TextInput 「端口」
  Button EMPHASIZED 「连接」
  Text Body_S 失败时
AlertDialog 断开确认
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 已连接的日志流，或未连接的说明+「连接」 |
| 按下 | 主按钮与日志行 |
| 禁用 | 端口为空时 sheet 里「连接」enabled false。已断开时发送栏禁用 |
| 空 | 已连接但无字节：日志区「还没有数据」，发送栏仍在 |
| 错 | sheet 结果行或日志末行，status.error，文案来自 ViewModel |
| 加载 | 按钮「正在连接」+ LoadingProgress，sheet 不关闭 |
| 无权限 | 权限墙替换未连接说明，不打开 sheet |

## 对照

采用控制台的单行日志、wifi 选择的一颗主按钮 sheet、蓝牙扫描里「没有行就不要假装成功」。不采用家居四页签、WLAN 的 IP 字段（除非 ViewModel 提供，否则不画）、体温卡、FastBle 过滤、NetworkQuery 四场景。
