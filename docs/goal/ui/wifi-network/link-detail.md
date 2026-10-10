# 链路详情

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
