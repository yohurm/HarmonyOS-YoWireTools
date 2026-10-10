# 导航

## 现在代码里有的

`product/phone/src/main/ets/pages/Index.ets`：一个 `Navigation`，一个 `NavPathStack`，`NavigationMode.Stack`，`hideTitleBar(true)`。根上是五个槽位。`navDestination` 只注册了蓝牙 SPP、SPP 终端、BLE。工作台、网络、星闪、更多是槽位内容，不是栈页面。

这是现状，不是整机契约。契约文件在 PR #21，未进 `main`。下面视觉规则可以先写死；路由名是否改成第 7.2 节那一套，等 `docs/goal/architecture/app/` 进 `main` 再对齐。对齐前不新开第二棵 Navigation，也不把三个射频模块各做一个 product。

## 五个目的地

与 `string.json` 一致：

| 槽位 | 文案 | 现路由或页面 |
| --- | --- | --- |
| 0 | 工作台 | `HomeFeaturePage` |
| 1 | 蓝牙 | `/bluetooth/overview` |
| 2 | 网络 | `/wifi/overview` |
| 3 | 星闪 | `/nearlink/overview` |
| 4 | 更多 | `/more/hub`，标题资源是「更多」 |

窄屏：`Tabs`，`barPosition` End，悬浮式，高 bar.56，图标 24vp，文字 Caption_L。当前项品牌色，其余二级色。须 `expandSafeArea` 避开系统导航条，页签热区与导航条热区分开（`底部页签.md`）。

≥840vp：底栏不渲染。左侧栏宽 96vp 只显示图标，或 200vp 图标+文字（窗口够 12 列时用 200vp）。当前项表面用 brand 的浅容器，不是一条 4vp 色条。

切换槽位只改当前索引，不 `pushPath`，不清栈。从蓝牙概览 push 出去的终端还在栈上；切到工作台再切回蓝牙，栈仍在。这一句是现有 `Index.ets` 的行为，契约对齐前不改成「一切槽清空栈」。

## 从属页

push 用同一个 `NavPathStack`。`NavDestination` `hideTitleBar(false)` 时用系统标题栏：返回、标题 Title 由系统样式承担，内容区不再重复大标题。菜单用 `bindMenu`，不多于四项。

官方 `Navigation基础架构介绍.md`：容器宽度 &lt;600vp 建议单栏，≥600vp 建议分栏（Stack / Split / Auto）。本仓库现为 Stack。list+detail 的左右分栏做在目的地内部的 `Row` 里，避免在契约未定时把 `mode` 改成 Auto。是否改为 Split，写在对齐位，不在本文件决定。

## 对齐位

| 待对齐 | 只指向 |
| --- | --- |
| 目的地是否仍是这五个、命令面板和日志中心算不算一级 | PR #21 `docs/goal/checklist/app.md`；屏行为索引 PR #20 `docs/goal/citation.md` |
| 跨模块会话列表的读模型 | 同两处。读路径终点若契约写的是表 `debug_log_index`，界面只消费 ViewModel 给出的行，不读 hilog |
| 状态装饰器 | 新界面用状态管理 V2（`@ComponentV2`）。不在规范里指定仓库还没有的状态类名 |

页面文件不 `import` Kit。壳的 `product/phone` 可以引用 feature 导出的页面组件，这是现有装配方式；导出面收口属于 APP-003，未进 `main` 前不在这里改 `Index.ets`。
