# 导航

来源：E4 multi-nav-bar 的 `Home.ets` 与 `WindowUtil.ets`；E6 NavigationSettings 的 `Index.ets`；D-tab 底部页签；现有 `product/phone` 的 `Index.ets`（`NavigationMode.Stack`）与 `MainTabContainer.ets` 的五个符号。

## 断点

窗口宽度（vp）沿 E4：

| 宽度 | 名称 | 壳 |
| --- | --- | --- |
| &lt;320 | xs | 与 sm 相同，边距仍 16vp |
| 320–599 | sm | 底栏 `Tabs`，`barPosition` End，`vertical` false |
| 600–839 | md | 仍用底栏。列表与详情在页面内 `Row` 分栏，不改 Navigation 模式 |
| 840–1439 | lg | 页签改到起始侧，`vertical` true，`barWidth` 96，只显示 24vp 图标 |
| ≥1440 | xl | `SideBarContainer` Embed，`sideBarWidth` 240，显示图标和文字 |

手机竖屏落在 sm。同一 HAP 在宽窗口上按上表变，不增加第二个产品。

E4 的 `lg` 底栏高度写成 76，那是连系统导航条一起算的样例值。本应用悬浮底栏内容高用官方 56vp，并用 `expandSafeArea` 避开导航条，热区与导航条分开。选中项文字 `brand`，未选中 `font_secondary`，栏底 `background_secondary` 加 `BlurStyle.COMPONENT_THICK`。E4 把选中色写成字面量 `#0A59F7`，本文改引用 `brand`，这样深色会落到 `#317AF7`。

五个目的地与现有符号（已在 `MainTabContainer.ets` 使用，不再新猜）：

| 序 | 文案 | 符号 | 根路由 |
| --- | --- | --- | --- |
| 0 | 工作台 | `sys.symbol.house` | `/home/workbench` |
| 1 | 蓝牙 | `sys.symbol.trunk` | `/bluetooth/overview` |
| 2 | 网络 | `sys.symbol.ohos_wifi` | `/wifi/overview` |
| 3 | 星闪 | `sys.symbol.card_writer` | `/nearlink/overview` |
| 4 | 更多 | `sys.symbol.more` | `/more/hub` |

日志和设置不是第六、第七个页签。日志从工作台进入，设置从「更多」进入。

## 栈

根上只有一个 `Navigation` + 一个 `NavPathStack`，与现在的 `Index.ets` 一致。子页注册在 `navDestination`。E6 在非 sm 把 `NavigationMode` 改成 `Split` 且 `navBarWidth` 为窗口的 0.4。那是设置样例的双栏，本壳在 md 以上用页面内 `Row` 做列表+详情，是否把根 `NavigationMode` 从 `Stack` 改为 `Split` 留给 PR #21 的导航契约，本文不改 `Index.ets`。

HarmonyKit 的 `AppNavDestination` 说明子页应包一层 `NavDestination`：标题、菜单、安全区、`background_secondary`。页面内容不直接 `router.pushUrl`（Wechat_HarmonyOS 的 `Mine.ets` 用了 router，本文不沿用）。

返回：非根页系统返回弹出栈。半模态先关 sheet，再返回页面。一级页签不拦截返回去「确认退出」。
