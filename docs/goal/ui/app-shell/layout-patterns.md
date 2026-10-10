# 布局模式

每一种模式对应已读来源。页面选用其中一种，不混成第二套视觉。

## 扫描列表

来源：H2 蓝牙扫描（状态标题、重新搜索、设备列表）；E3 `BluetoothClientView`（有设备才渲染 `List`，否则空态；底栏一颗「搜索设备」）；E1 把「已连接」和扫描结果分成两组。

窄屏：`Column`。上为标题 20 Bold + 辅文 14 `font_secondary` + 文字按钮「开始搜索 / 停止 / 重新搜索」。中为 `List`，`layoutWeight` 1，左右边距 16vp，项间距 12vp。项是 76vp 卡片，圆角 16，背景 `comp_background_primary`。无项时中部改为空态，不留空白列表。

## 连接半模态

来源：H1 的选择、密码、一颗「下一步」；D-btn 半模态最宽 480vp、左右 16vp。E2 的 `WifiConnector` 直接调 Kit 并 `showToast`，本文不学那条调用，只保留「先确认当前链路，再让用户提交口令」的顺序。

`bindSheet` 贴底。内容：标题、`Select` 或只读当前 SSID、`TextInput` 密码、尾部图标按钮切换明文、一颗 `ButtonStyleMode.EMPHASIZED`「下一步」。同一区域不再放第二颗主按钮。

## 列表加详情

来源：E1 `DetailInfoView` 的标签/值顺序；H3 同一信息；md 及以上页面内 `Row`，左列表右详情。左列宽 280vp（会话）或 40%（设置双栏，对齐 E6 的 0.4 窗口宽，且只在设置页考虑）。窄屏详情是栈上的下一页。

## 场景页签

来源：E2 的四个目的地；H4 的等宽文字页签。用顶栏 `Tabs`，`barPosition` Start，`BarMode.Fixed`。不用 E2 那种贴在页面底部的四颗全宽按钮，避免和壳底栏叠在一起。

## 日志控制台

来源：G12 hadice `SystemLogsPage`（级别多选、暂停、清空、关键字、无设备）；H6 用顶栏分类而不是再做一个窗口。手机上级别用 `Select` 或一排 `Toggle` 式筛选，不用桌面下拉浮层。行高 48vp。

## 设置分组

来源：E6 `SettingList`（`List` space 12，组内 `Divider`，左右 padding 12）；G6 的组间节奏；G8 的「标题 + 右值 + 箭头」。搜索框只在组很多时出现，本应用三组不放 `Search`。

## 度量卡

来源：H8 的通信页用少量实时量，不用来代替设备列表。卡高至少 72vp，圆角 16，内边距 12。数字用页标题字号，说明用 12 Regular。一屏最多三张，多了改列表。
