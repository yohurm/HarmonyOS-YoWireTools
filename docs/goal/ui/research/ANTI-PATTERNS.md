---
id: yowire.ui.research.anti-patterns
type: topic-study
status: active
when: research
---

# 禁止项

后续模块 Goal 碰到下列结构，直接停，按 [MODULE-PAGE-MAP.md](MODULE-PAGE-MAP.md) 重做该页，不要在旧稿上改颜色或改文案。

## 1. 入口首页

工作台、模块根页出现下列任何一种，即是入口首页：

- 模块或功能的宫格、图标矩阵、全宽按钮列表
- 以最近会话、最近设备、收藏夹作为页面主体
- 把 PRD 01 第 3.2–3.4 节的入口表原样画成菜单

已对照的反例：

- 综合工具模板首页是分类宫格（[evidence/zonghe-tool-home.png](evidence/zonghe-tool-home.png)）
- 物联工厂首页是设备宫格（[evidence/iot-factory-phones.png](evidence/iot-factory-phones.png)）
- `network-query` 首页是四颗导航按钮（`Index.ets`）
- 星闪示例把「Start Scan」「Ssap Service」和结果列表放在同一启动页（`MainPage.ets`）
- PR #24 的工作台列表/宫格，PR #26 的最近会话，PR #29 的方案 A/B

看板上允许出现会话计数和告警里的对象名称。那是指标和下钻，不是菜单。

## 2. 换皮

下面的做法算换皮，即使颜色改成了宇宙蓝 `#0A59F7`、背景改成了雪域灰 `#F1F3F5`：

- 保留五个底栏，或保留「首页 / 调试 / 控制台 / 我的」
- 工作台仍是入口或最近会话，只换卡片圆角和字体
- 模块第一屏仍是同一列表，只换标题
- 宽屏只是把底栏旋转成侧栏
- 引用旧 PR #26 的组件尺寸表，不改页面职责

视觉 token 见 [VISUAL-LANG.md](VISUAL-LANG.md)。先满足 [IA-NAV.md](IA-NAV.md) 的职责划分，再谈颜色。

## 3. 模块页同一套列表壳

禁止用同一套「状态标题 + 白卡片列表 + 浅色胶囊主操作 + 底部一颗实心按钮」覆盖蓝牙、网络、星闪、日志和设置。

蓝牙通讯组件的白卡片和胶囊「连接」（[evidence/bt-comm-list.png](evidence/bt-comm-list.png)）只属于发现页的一行。官方 BLE 示例也是「列表 + 搜索按钮」，心率曲线在另一页用 `Canvas`（`HeartRateGraph.ets`，HEAD `0f169cc`）。曲线页、树页、终端页、诊断页、设置页各自使用 [COMPONENT-COMPOSITION.md](COMPONENT-COMPOSITION.md) 里不同的组合。

具体禁止：

- 用发现列表充当 `BT-BOARD`、`NW-BOARD`、`NL-BOARD`
- 用同一列表展示 AP、GATT 服务、MQTT 主题和设置项
- 用日志级别芯片去冒充分段导航
- 把 HTTP 请求/响应、套接字收发、星闪数传画成同一种设备卡片

## 附带禁止

这些会把上面三条又带回来：

- **半模态承载主流程。** `bindSheet` 适用于短任务；冗长流程用 `Navigation`（[bindSheet 指南](https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/ui/arkts-sheet-page.md)）。ui-design-brain 禁止模态套模态（SKILL.md，Anti-Patterns）。
- **一种空态走遍所有失败。** 通用状态组件是「插图 + 一句原因 + 一颗按钮」（[evidence/status-empty-phone.png](evidence/status-empty-phone.png)）。原因必须区分空、失败、关射频、无权限、能力不支持。加载用骨架，不用转圈占满页面（ui-design-brain：可预期布局用骨架，晚于 300ms）。
- **宽屏空栏填入口。** 宽屏空态仍在内容区（[evidence/status-empty-wide.png](evidence/status-empty-wide.png)）。多出来的栏位放检查器或「无读数」，不放功能卡片。
- **用环图或测速表盘当工作台。** 见 [DASHBOARD.md](DASHBOARD.md) 的图表选择。
- **把示例启动器当产品信息架构。** 官方 sample 的按钮首页可以保留为学习路由的方式，不能成稿。
- **宫格命令面板当首页。** 命令按钮只出现在会话托盘或命令库的分组里。
