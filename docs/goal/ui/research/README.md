---
id: yowire.ui.research.readme
type: hub
status: active
when: research
scope: com.yohurm.yowiretools
related:
  - DASHBOARD.md
  - IA-NAV.md
  - MODULE-PAGE-MAP.md
  - VISUAL-LANG.md
  - ANTI-PATTERNS.md
  - COMPONENT-COMPOSITION.md
---

# YoWireTools UI 深研总纲

本目录是 `com.yohurm.yowiretools` 的界面信息架构与页面地图。它只定职责、布局逻辑和页面级组合，不画最终原型，不改业务代码。

后续每个模块 Goal **按 [MODULE-PAGE-MAP.md](MODULE-PAGE-MAP.md) 里的页面编号单独设计**。一次 Goal 只覆盖一个模块（或该模块里明确列出的一组页面）。禁止把蓝牙、网络、星闪、日志、命令、设置合成一个「换皮 Goal」，禁止用同一套列表壳铺完全部页面。

## 作废

下列产物作废，禁止在其上打补丁：

| 产物 | 原因 |
| --- | --- |
| PR #26 UI 规范 | 工作台仍是最近会话；模块页共用列表壳；色彩换了，布局逻辑与功能设计没换 |
| PR #24 信息架构草图 | 工作台的列表/宫格被标成待选，两者都是入口首页 |
| PR #29 以及同方向的 #27 / #28 高保真 | 按 #26 或工具宫格重画，属于换皮 |
| `.projectark/2-需求文档/无线调试工具/PRD/01-产品信息架构与模式PRD.md` 第 3.1–3.4 节的首页入口表 | 模块能力仍有效；「首页 = 模块入口 + 最近会话 + 快捷命令」这一布局不再有效 |

功能范围仍以蓝牙、Wi-Fi、星闪、日志、命令、权限 PRD 为准。页面怎么摆，以本目录为准。

## 先读什么

| 文件 | 内容 |
| --- | --- |
| [DASHBOARD.md](DASHBOARD.md) | 工作台是数据看板：指标、状态、趋势、告警、下钻 |
| [IA-NAV.md](IA-NAV.md) | 整 App 导航、页面职责、相对旧稿改了什么 |
| [MODULE-PAGE-MAP.md](MODULE-PAGE-MAP.md) | 每一页清单与主状态 |
| [COMPONENT-COMPOSITION.md](COMPONENT-COMPOSITION.md) | 页面级多组件组合，供各模块 Goal 复用 |
| [VISUAL-LANG.md](VISUAL-LANG.md) | 为新信息架构服务的视觉语言 |
| [ANTI-PATTERNS.md](ANTI-PATTERNS.md) | 禁止项 |
| [sources/](sources/CANDIDATES.md) | 候选、单项目阅读记录、规范摘录、截图索引 |

## 证据

结论旁标注来源链接，或 `evidence/` 下的截图。截图是华为开发者联盟工具库商品图，用来说明别人的页面结构，不是 YoWireTools 的界面稿。

源码级阅读在本机 `/tmp/YoAgentResearch/<owner>--<repo>`（浅克隆）。源码不进入本仓库。GitCode 的处理见 [sources/CANDIDATES.md](sources/CANDIDATES.md)。

本总纲按用户指定落在产品仓库。不写入 YoAgentDocs，也不把结论升格为 AgentRules。
