# YoWireTools 手机 UI 规范

本目录是整 App 的界面规范，从默认分支空白重写，并按工具库第二轮画面定稿。PR #19 已关闭未合并，旧稿作废，不是底稿。PR #22 同样已关闭未合并，不是底稿。门禁未过，不铺页面。

产品是一个手机 HAP（`product/phone`，包名 `com.yohurm.yowiretools`）。Wi‑Fi、蓝牙、星闪、日志、设置都在这一个壳里，不另起蓝牙或网络产品。界面不调用 Kit。数据只沿这条对齐槽往下走：UI → ViewModel/State → UseCase → RepositoryContract → DataSource/KitBridge → Kit。

## 不是底稿的东西

- [PR #19](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/19) 已关闭且未合并。旧 UI 稿作废，本目录不延续那条分支，也不粘贴旧组件树。
- 原型 PR #22 已关闭且未合并，不是本文的底稿。以后的图由界面原型目标交给 `docs/goal/ui/prototypes/`，作者目标 `bc-b0fee2c5-cd47-50ca-8063-a2e2089334a1`。本文不因旧图降低密度或改树。
- 更早的页面实现稿与薄市场稿同样作废。视觉以 [色彩 Token](app-shell/design-tokens.md) 为准。

## 先读

1. [QUALITY-GATE.md](QUALITY-GATE.md) — 结论仍是「不可进入大规模页面实现」。
2. [SOURCES.md](SOURCES.md) — 每个关键模式对应的仓库或官方文档。
3. [app-shell/](app-shell/README.md) — 壳、导航、色彩、密度、权限墙。
4. 各模块页：蓝牙、星闪、Wi‑Fi、工作台、日志、设置。

## 屏幕从哪来

已在 `main` 注册的路由（`product/phone` 的 `AppRoutes.ets`）可以当导航对齐槽：`/home/workbench`、`/bluetooth/overview`、`/bluetooth/spp`、`/bluetooth/spp/terminal`、`/bluetooth/ble`、`/wifi/overview`、`/nearlink/overview`、`/more/hub`。

`.projectark/5-架构设计/无线调试工具/00-总体架构与工程模块化设计.md` §7.2 另有扫描、详情、诊断、日志、设置等目标路由。那些名字可以当屏幕清单，不是已合并的整 App 契约。功能编号只追溯未合并的 [PR #20](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/20) `docs/goal/citation.md`。整 App 契约只追溯未合并的 [PR #21](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/21)。两者都不在 `main`，所以门禁保持拦住。本文不新造 BT/NL/WN/WB/LOG/SET 编号，不猜测契约文件名，不起草功能架构。

## 本规范不改什么

不改业务实现，不改 `youi_kit`，不实现页面，不画原型，不复制图片。壳的导航与状态模型只是对齐槽。
