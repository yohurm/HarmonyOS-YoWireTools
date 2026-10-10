# 对照来源

定稿前读过下列独立来源。关键模式在各页用「来源」标出仓库或文档，不把未读的 GitCode 示例树写成依据。GitCode / AtomGit 在调研时返回 WAF，OpenHarmony `ComponentCollection` 的 Gitee raw 路径本次返回 404，因此组件选型改以已克隆的 Gitee 官方样例和 ArkUI 文档为准。

市场合计 28 条：先有 8 条，第二轮目录再加 20 条。定稿同时对照 Top 12 开源样例，以及本轮看过的工具壳、日志控制台、空态、蓝牙列表、测速和半模态。目录里没有附画面的条目只登记，不写成布局。

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

## 工具库第二轮（看过画面的）

目录：`huawei-expand/CATALOG.md`。下面这些按画面改了布局。色相仍只用 D2，不采用计算器橙、记账绿、日志彩虹边框。

| 编号 | 来源 | 链接 | 画面里取用 / 不取用 |
| --- | --- | --- | --- |
| M1 | 计算器应用模板 | https://developer.huawei.com/consumer/cn/market/prod-detail/545386ee7127455ea20d802258f46839/2adce9bbd4cb42d58a87e6add45594b3 | 标题下分段（选中实心、未选灰底）说明页内模式切换。不把键盘和橙色运算符搬进调试页 |
| M2 | 综合工具应用模板 | https://developer.huawei.com/consumer/cn/market/prod-detail/65362ceb3ff6417fa93636eba9fae427/2adce9bbd4cb42d58a87e6add45594b3 | 底栏 + 首页宫格是工具箱壳。本应用底栏已是五个无线目的地，工作台不改成三列小工具宫格 |
| M3 | 健康管理应用模板 | https://developer.huawei.com/consumer/cn/market/prod-detail/a535af340eb545f9bee62f47dce631db/2adce9bbd4cb42d58a87e6add45594b3 | 设备页是白卡片：名称、状态短句、次要动作。不放设备照片主视觉 |
| M4 | 网络测速组件 | https://developer.huawei.com/consumer/cn/market/prod-detail/0dc4756853e8437db56dbc737bdcb0f8/2adce9bbd4cb42d58a87e6add45594b3 | 一个大数字加三个说明（时延、下载、上传）。不把整页改成深色仪表盘 |
| M5 | 通用状态服务组件 | https://developer.huawei.com/consumer/cn/market/prod-detail/992591e621d3416da45cf37026e9d5d5/2adce9bbd4cb42d58a87e6add45594b3 | 空态/错误：中部标题和辅文，底部一颗胶囊主按钮。不要求行星插画 |
| M6 | 应用内可视化日志查看工具 | https://developer.huawei.com/consumer/cn/market/prod-detail/a085f91630a04dbb85daf9aab948e78a/b6a17875746941e0b5606c9b1eb174f8 | 关键字搜索、Debug/Info/Warn/Error/Fatal 芯片、清空、滑动到底部。不加速浮「log」球，不提供彩虹背景色板 |
| M12 | 蓝牙通讯组件 | https://developer.huawei.com/consumer/cn/market/prod-detail/bda40096ca854265937fee47e95a5a36/PLATFORM | 灰底白卡片、地址主行、浅底胶囊「连接」、底部一颗实心「搜索设备」。主行与次行不重复同一串地址 |
| M17 | 账单管理半模态 | https://developer.huawei.com/consumer/cn/market/prod-detail/fb4020d8e0e1494390e845dc559e0a31/2adce9bbd4cb42d58a87e6add45594b3 | 半模态自带标题和关闭，模式分段在字段之上，一颗完成按钮在底部。不搬分类宫格和绿色 |
| M19 | 消息管理 | https://developer.huawei.com/consumer/cn/market/prod-detail/b111d8b49c56423aa5cfb9e7afb6fb95/2adce9bbd4cb42d58a87e6add45594b3 | 顶部分段筛选、行内标题+时间+辅文。滑动露出的「标为已读 / 删除」是消息动作，日志流不照搬 |

第二轮其余条目（UtilLog、hilog、debug db、NFCTag、beacon、图文识别、折叠屏扫码、账单图表、莓创图表、文件管理、物联工厂）在目录中，本轮没有用来改组件树。
