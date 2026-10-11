# GATT 详情

目标路由 `/bluetooth/gatt-detail`（架构第 7.2 节）。`main` 上还没有这个路由，实现等契约对齐。模式：list + detail。左为服务树，右或下一级为属性值。

## 布局

标题栏：设备名，返回。

窄屏：`List` 分组，一组一个服务，`SubHeader` 为服务 UUID。属性行 56vp：UUID 短标签 Body_L，次行 Body_S 写可读/可写/可通知里 ViewModel 给出的那些词。行点击 push 同一栈上的属性页（仍是本文件描述的下半部分，不新开模块）。

属性页：`Scroll`。标签/值依次为 UUID、属性、值。值是 Body_S、`tnum`，可多行。空值灰条「未读取」。底固定一颗主按钮，文案按能力只出现一个：「读取」或「写入」。既能读又能写时，写入放 sheet，页面主按钮是「读取」，文字按钮「写入」在值的下方。通知用 `Toggle` type Switch，标签「通知」。写 sheet：`TextArea`、主按钮「写入」、失败结果行。

宽屏 ≥600vp：`Row` 左树 280vp，右属性页。选中行 surface 用 brand 浅容器。无选中时右侧 Body_M「选择一项属性」。

数据卡最多一张：MTU。Title_S 数字，Caption_L「MTU」。没有数字时不画卡。

## 组件树

```text
NavDestination 设备名
  窄屏 List
    ListItemGroup
      SubHeader 服务 UUID
      ListItem 56 属性
  宽屏 Row
    List width 280
    Column layoutWeight 1
      数据卡 MTU  可选
      Scroll
        Text Caption_L 「UUID」
        Text Body_L
        Text Caption_L 「属性」
        Text Body_M
        Text Caption_L 「值」
        Text Body_S fontFeature tnum  或 灰条「未读取」
        Button TEXTUAL 「写入」  可选
        Row 「通知」 Toggle type Switch
      Button EMPHASIZED 「读取」
bindSheet 「写入」
  TextArea
  Button EMPHASIZED 「写入」
  Text Body_S 失败消息
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 服务组有行。右侧或属性页显示上次读到的值。通知开关反映 ViewModel |
| 按下 | 树行按压。读取按钮按下 |
| 禁用 | 未连接：树可以用缓存显示，读取、写入、通知 enabled false。标题下胶囊「未连接」 |
| 空 | 树区 Body_M「还没有服务」。没有伪造的 UUID 行 |
| 错 | 属性页值的位置改为 Body_M status.error，内容是消息。树保留 |
| 加载 | 读取中按钮文案「正在读取」且 enabled false，值的位置 16vp LoadingProgress。树不闪空 |
| 无权限 | 权限墙替换整页，包括宽屏右栏 |

## 对照

| 参考 | 取舍 |
| --- | --- |
| wifi 选择 | 写入 sheet 对应密码框+下一步，这里是 TextArea+写入 |
| 蓝牙扫描 | 不扫描 |
| WLAN 信息 | 标签在上、值在下；宽屏左树右值 |
| NetworkQuery | 不用四场景 |
| 智慧家居 | 不用模拟开关墙；只有通知一个 Toggle |
| 控制台 | 值不是日志流 |
| FastBle | 连接已在扫描页完成，这里不再滤扫描 |
| BLE 通信 | 仅 MTU 一张数据卡，不把每个属性画成体温卡 |
目标名 `/bluetooth/gatt-detail`。来源：列表加详情；H8 最多三张度量卡（RSSI、MTU，第三张仅当 ViewModel 有吞吐）；E3 进入下一级页而不是在扫描行里展开树。

窄屏：`List`。先最多三张度量卡横滑 `Row`（不够三张就少画）。其下按服务分组，`ListItemGroup`，组头是服务 UUID 的短标签 14 `font_secondary`。属性行 56vp：主行 UUID 短标签 16，次行 14 写 ViewModel 给出的「可读 / 可写 / 可通知」。行点击在同一栈再推属性页。

属性页：标题为短 UUID。值区 `Text` 14 `tnum`，可系统选择复制。按钮一行：有读则「读取」，有写则「写入」打开 `bindSheet`（一个 `TextArea` +「写入」），有通知则 `Toggle`「通知」。没有的动作不渲染。

宽屏 ≥600：`Row` 左树 280vp，右属性页。未选时右侧 14「选择一项属性」。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 树与值可见 |
| 按下 | 属性行按下 |
| 禁用 | 断线：动作 enabled false，顶行胶囊「未连接」 |
| 空 | 无服务：14「没有服务」，不画假 UUID |
| 错误 | 值区 `warning` 一行，树保留 |
| 加载 | 「读取」文案变为「正在读取」且 disabled，值位置 16vp `LoadingProgress` |
| 无权限 | 权限墙替换整页 |
