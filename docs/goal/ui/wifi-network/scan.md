# WLAN 扫描

来源：E1 `Index.ets` 的「已连接」标题 + `WlanItemView` + 其余扫描项；H1 的连接半模态。

`List` 组「已连接」「可用」。行 64vp（E1 是通栏列表项，本文用效率 64 而不是 E3 的 76 卡，因为 WLAN 行是信息入口不是设备操作卡）。主行 SSID 16，次行「加密」或「开放」14。右侧图标按钮热区 40，「信息」，`push` 链路详情。

点可用行且 ViewModel 标记需要口令：`bindSheet`。内容为只读 SSID、密码 `TextInput`、明文图标按钮、主按钮「下一步」。开放网络不打开 sheet，行点击就是提交连接动作，行尾出现 16vp `LoadingProgress`。

E1 用定时器直接 `wifiManager.getScanInfoList`。本页只观察 ViewModel 列表。

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 两组列表，当前 SSID 在「已连接」 |
| 按下 | 行按下；sheet 内按钮按下 |
| 禁用 | WLAN 关：无 List，标题「WLAN 已关闭」 |
| 空 | 扫描结束无 AP：「没有网络」 |
| 错误 | sheet 内密码下 `warning` 一行，sheet 不自动关 |
| 加载 | 标题旁进度，已有 AP 保留 |
| 无权限 | 权限墙 |
