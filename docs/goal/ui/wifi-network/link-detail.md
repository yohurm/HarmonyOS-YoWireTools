# 链路详情

目标：WLAN 信息查询右机那种详情。窄屏从扫描行或概览卡 push；宽屏 ≥600vp 时若从扫描进入，扫描列表留在左 280vp，详情在右。单独从概览 push 且窗口 ≥600vp 时，左列只有当前这一条，右列是详情，不把整份扫描结果偷偷加载出来。

## 布局

标题为 SSID 或「当前链路」。`Scroll` 里按顺序只渲染 ViewModel 有的项：MAC、IP、子网掩码、网关、DNS、RSSI、频段。每一项 Caption_L 标签 + Body_L 值，`tnum`。缺省「未读取」加 8vp 高的中性条，条旁仍有「未读取」三个字，不单靠颜色。

没有连接按钮。连接发生在扫描 sheet。

## 组件树

```text
NavDestination 标题 SSID
  Scroll
    Column padding 16 gap 16
      Column
        Text Caption_L 「MAC」
        Text Body_L fontFeature tnum
      Column  同样结构：IP、子网掩码、网关、DNS、RSSI、频段
```

没有值的项：`Text`「未读取」text.secondary，上面一条 8vp surface 条 radius 8。

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 各项有字 |
| 按下 | 本页无行按钮。返回键走系统标题栏按下 |
| 禁用 | 无禁用字段。链路掉了：标题下胶囊「未连接」，值保留上次读取并在胶囊旁 Body_S「上次结果」 |
| 空 | 全部「未读取」，仍列出标签，不改成一张空插画 |
| 错 | 第一项位置换成 Body_M status.error 消息，其余项不渲染，避免混着假值 |
| 加载 | 每项值的位置是 120×8 的浅条，标签仍在。不用整页 Loading |
| 无权限 | 权限墙，不列出空标签 |

## 对照

采用 WLAN 详情的标签/值。不采用扫描雷达、连接 sheet（已在扫描页）、四场景、控制台、家居、FastBle、体温卡。
来源：E1 `DetailInfoView` 顺序：MAC、IP、掩码、网关、DNS。ViewModel 若还有 RSSI、频段，接在 DNS 后面，不插到前面。H3 是同一组字段。

`NavDestination` 标题为 SSID 或「当前链路」。背景 `background_secondary`。一张圆角 16 的 `comp_background_primary` 卡片，内部分割线 `comp_divider`，分割线左右留白对齐 E1 的详情分割。每一项：标签 12 `font_secondary`，值 16 `font_primary` `tnum`，上下间隔 2vp，项与项之间用分割线而不是 8vp 色条。

缺值：值的位置写「未读取」，不用空色条代替文字。

宽屏：卡片最大宽 600 居中。左列表仅在从扫描页以分栏进入时出现。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 五项都有字 |
| 按下 | 值可选择，无单独按下皮 |
| 禁用 | 不适用 |
| 空 | 全部「未读取」仍渲染五行，不改成插画 |
| 错误 | 卡片上方 `warning` 一行 |
| 加载 | 值位置「正在读取」，不逐项闪空 |
| 无权限 | 权限墙 |
