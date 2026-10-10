# 对照来源

定稿前读过下列独立来源。关键模式在各页用「来源」标出仓库或文档，不把未读的 GitCode 示例树写成依据。GitCode / AtomGit 在调研时返回 WAF，OpenHarmony `ComponentCollection` 的 Gitee raw 路径本次返回 404，因此组件选型改以已克隆的 Gitee 官方样例和 ArkUI 文档为准。

工具库截图仍在扩大。市场条目用已有目录，不把未看到的画面写成布局。

## 组件库与高星 ArkUI

| 编号 | 来源 | 链接 | 本文取用 |
| --- | --- | --- | --- |
| G2 | ibest-ui-v2 | https://github.com/ibestservices/ibest-ui-v2 | 浅色/深色成对资源；单元格标题/说明/值；弹出层、对话框、动作面板、搜索、输入、页签的分层。不采用其 `ibest_primary_color` `#1989fa` |
| G3 | CoolMallArkTS | https://github.com/Joker-x-dev/CoolMallArkTS | 单 Navigation 宿主、页面级 Loading、空态重试。不采用 `primary` `#465CFF` 与紫渐变 |
| G4 | HarmonyKit | https://github.com/Joker-x-dev/HarmonyKit | `AppNavDestination` 把标题、菜单、安全区、背景收进一个 NavDestination；空态是说明 + 可选重试 |
| G6 | Wechat_HarmonyOS | https://github.com/ausboyue/Wechat_HarmonyOS | 「我的」分组：组间粗分隔、组内细分隔、行内图标+标题+尾值。不复制微信品牌与 19fp 标题 |
| G8 | JhHarmonyDemo | https://github.com/iotjin/JhHarmonyDemo | `JhSetCell`：左图标、标题、右值、箭头、底部分割。行高改用官方效率列表，不用其 50vp 与自有色板 |
| G12 | hadice | https://github.com/HuolalaTech/hadice | `SystemLogsPage`：级别 D/I/W/E/F、暂停/继续、清空、关键字、无设备空态。不搬桌面 xterm 壳 |

## Gitee 官方样例

| 编号 | 来源 | 链接 | 本文取用 |
| --- | --- | --- | --- |
| E1 | wlan-info-query | https://gitee.com/harmonyos_samples/wlan-info-query | 已连接一组 + 扫描列表；详情 NavDestination 顺序展示 MAC、IP、掩码、网关、DNS |
| E2 | network-query | https://gitee.com/harmonyos_samples/network-query | 四个网络场景：指定网络、网络感知、WLAN 定位、故障诊断。样例是栈底四颗全宽按钮；手机壳已有底栏，本文改成顶栏 `Tabs` |
| E3 | BluetoothLowEnergy | https://gitee.com/harmonyos_samples/BluetoothLowEnergy | 设备卡 76vp、圆角 16、主行 16 / 次行 14；连接中 `LoadingProgress`；空态；长按 `AlertDialog`。硬编码白底改为容器 Token |
| E4 | multi-nav-bar | https://gitee.com/harmonyos_samples/multi-nav-bar | 断点：&lt;600 `sm` 底栏，600–840 `md`，840–1440 `lg` 竖向页签宽 96，≥1440 `xl` 用 `SideBarContainer` 宽 240。选中字色 `#0A59F7` |
| E6 | NavigationSettings | https://gitee.com/harmonyos_samples/NavigationSettings | `Navigation` 在 `sm` 用 `Stack`、更宽用 `Split`；设置 `List` 组间距 12、组内分割线、搜索在列表首项 |

## 色彩与设计技能

| 编号 | 来源 | 链接 | 本文取用 |
| --- | --- | --- | --- |
| D2 | HarmonyOS NEXT 色彩 | https://developer.huawei.com/consumer/cn/doc/doccenter-ux-design/color-0000001776857164 | 宇宙蓝 `brand` 浅色 `#0A59F7`、深色 `#317AF7`；雪域灰 `background_secondary` 浅色 `#F1F3F5`；`font_primary` 到 `font_fourth`；`comp_*` 与 `interactive_*`。同名 Token 跨浅色/深色，不另造 Material 色板 |
| S1 | ui-ux-pro-max design-system | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill | 三层 Token：基础值 → 语义 → 控件。示例里的 `#2563EB` 不进入本应用 |
| S3 | interface-design | https://github.com/Dammyjay93/interface-design | 工具界面：一屏一个焦点；导航即产品；数字要说明含义。模式是 Operate，不是营销页 |
| S2 | impeccable | https://github.com/pbakaus/impeccable | 工具界面优先可扫读和系统习惯；旧视觉只作反例，不折中抛光 |

## 官方度量与市场目录

| 编号 | 来源 | 链接 | 本文取用 |
| --- | --- | --- | --- |
| D-interval | 间隔参数 | https://developer.huawei.com/consumer/cn/doc/design-guides/interval-parameter-0000002562577161 | 4/8vp 网格；手机左右边距 16vp；卡片间距 12vp；有边界控件 16vp；无边界 8vp；主次文字上下 2vp、左右 8vp |
| D-list | 列表 | https://developer.huawei.com/consumer/cn/doc/design-guides/list-0000001929853910 | 效率型行高 48/56/64/72/96vp；右侧元素与正文间隔 12vp；一级/二级/三级文字；分组用子标题 |
| D-tab | 底部页签 | https://developer.huawei.com/consumer/cn/doc/design-guides/bottomtab-0000001956787789 | 3–5 项；平铺 48vp、悬浮 56vp；图标 24vp；避让系统导航条 |
| D-btn | 按钮 | https://developer.huawei.com/consumer/cn/doc/design-guides/button-0000001929683228 | `ButtonStyleMode` / `ButtonRole`；单按钮最宽 448vp；半模态最宽 480vp，左右各 16vp |
| D-touch | 触摸热区 | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-universal-attributes-touch-target | API 26 起 Button 等默认最小热区高度 32vp。工程内 UX 要求主要控件热区不小于 40×40vp（`.projectark/4-专家模型/HarmonyOS UIUX设计师.md`） |
| H1–H8 | 华为工具库目录 | https://developer.huawei.com/consumer/cn/market/prod-list?fromNav=toolLibrary | Wi‑Fi 选择与密码、蓝牙扫描状态、WLAN 详情、四场景网络、家居底栏壳、控制台页签、FastBle 过滤、BLE 通信卡。只取布局，不取品牌 |

市场条目：

- H1 wifi 扫描选择 https://developer.huawei.com/consumer/cn/market/prod-detail/b7e8c084fc214b80820ae31ba5ae9358/2adce9bbd4cb42d58a87e6add45594b3
- H2 蓝牙扫描 https://developer.huawei.com/consumer/cn/market/prod-detail/f6bf602fb1224791ae5874a45e292728/2adce9bbd4cb42d58a87e6add45594b3
- H3 WLAN 信息 https://developer.huawei.com/consumer/cn/market/prod-detail/f722288166ec49cab512d9fef9efafe6/PLATFORM
- H4 NetworkQuery https://developer.huawei.com/consumer/cn/market/prod-detail/15e711a071a9441b9a9b52b185792124/PLATFORM
- H5 智慧家居模板 https://developer.huawei.com/consumer/cn/market/prod-detail/0d7dd2239ce14a8e9fe8cfcde426d5ff/2adce9bbd4cb42d58a87e6add45594b3
- H6 IKConsoleKit https://developer.huawei.com/consumer/cn/market/prod-detail/11090518ae8147e9b12f9ab8fb5cf815/c5ef800e4cc6476ab179493aa30dff52
- H7 FastBle https://developer.huawei.com/consumer/cn/market/prod-detail/dca785c6dc1d458c8fd12568ecd78f05/PLATFORM
- H8 BLE 通信 https://developer.huawei.com/consumer/cn/market/prod-detail/c0b2e7a68718427eb7fa8ba0fd8afd00/PLATFORM
