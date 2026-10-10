# 候选与落选

阅读日：2026-10-10。克隆根目录：`/tmp/YoAgentResearch/<owner>--<repo>`。浅克隆 `--depth 1`。Star 只作参考，数字来自当日 `gh api` 能查到的 GitHub 仓库；Gitee 官方样例不按 star 筛选。

## GitCode

| 观察 | 结果 |
| --- | --- |
| 调研包记录 | 浏览器调查曾返回 418，见上传包 `EXPANDED-UI-RESEARCH.md` 第 H 节 |
| 本次 HTTP | `curl -I https://gitcode.com/openharmony/docs` 为 200，同时 `Set-Cookie: HWWAFSESID`，`x-render-mode: csr-shell`。正文是标题壳，不能当源码读 |
| 本次 git | `git ls-remote https://gitcode.com/HarmonyOS_Samples/nearlink-kit_-sample-code.git` 成功，`master` 为 `f70be9ba9f85904a5ef2bbfa7aaf5e7ba4327de9` |
| 实际阅读 | 星闪样例改从 Gitee 克隆。ArkUI 文档改从 GitHub `openharmony/docs` 的 `OpenHarmony-5.0.2-Release` raw 阅读 |

Gitee 镜像：<https://gitee.com/harmonyos_samples/nearlink-kit_-sample-code>，本地 HEAD `d211493`。

华为设计指南里 `design-guides/list-0000001929853910` 与 `component_navigation-0000001929763488` 的页面抓取只返回「文档中心」空壳，这两条不作为规范依据。色彩页与 UI Design Kit、OpenHarmony 镜像文档有正文，才写入总纲。

## 入选

| 仓库或文档 | HEAD 或版本 | 一句话 | 利用 |
| --- | --- | --- | --- |
| harmonyos_samples/network-query | `42c7516` | 四个网络场景是不同目的地；首页按钮列表是反例 | adapt / anti-pattern |
| harmonyos_samples/wlan-info-query | `a114aba` | 扫描列表推进键值详情 | adapt |
| harmonyos_samples/BluetoothLowEnergy | `0f169cc` | 设备列表与心率 Canvas 分属不同视图 | adapt |
| harmonyos_samples/multi-nav-bar | `a9a49a9` | `xl` 侧栏 240vp，更窄用 Tabs | reuse-pattern |
| harmonyos_samples/NavigationSettings | `4349e44` | 搜索、分组、非 sm 时 Split | reuse-pattern |
| harmonyos_samples/navigation-router | `6f81cde` | HAR 登记 builder，壳持有 NavPathStack | reuse-pattern |
| harmonyos_samples/nearlink-kit_-sample-code | `d211493` | 扫描、SSAP 客户端、服务端分页；MainPage 是演示启动器 | adapt / anti-pattern |
| harmonyos_samples/list-exchange | `bad3f1e` | 列表侧滑与拖拽 | lesson-only |
| harmonyos_samples/PureTabs | `49e12dd` | 外层页签套内层页签，属于内容分类 | anti-pattern（嵌套目的地） |
| harmonyos_samples/custom-dialog-selection-and-development | `d448e79` | 对话框、列表、隐私分成不同文件 | adapt |
| HuolalaTech/hadice | `ff3b9a9`，64 star | 设备总览是读数，性能曲线和 Shell 是别的页 | adapt |
| ibestservices/ibest-ui-v2 | `286a3e0`，52 star | empty、skeleton、segmented、tree、cellGroup 等职责拆分 | lesson-only |
| qingkouwei/qcharts | `27c3278`，1 star | ArkUI 折线、柱、仪表的交互能力；仪表不用于工作台 | adapt |
| carmahhawwari/ui-design-brain | `38f04c5`，893 star | 一个强调色、骨架、禁止彩虹徽章和模态套模态 | adapt |
| DammyJay93/interface-design | `2f9be32`，5785 star | 工具界面的单焦点、密度、60/30/10 | adapt |
| nextlevelbuilder/ui-ux-pro-max-skill | `50d8a7d`，134287 star | `charts.csv` 规定时间用折线、类别用柱、占比才用环图 | adapt |
| JimLiu/baoyu-design | `6530033`，4277 star | 线框阶段先展开多种结构 | lesson-only |
| pbakaus/impeccable | `d631a88`，79088 star | 批评要指出具体失败，而不是换一套装饰 | lesson-only |
| OpenHarmony docs 5.0.2 | 分支 `OpenHarmony-5.0.2-Release` | Navigation、Tabs、bindSheet、DataPanel、SideBarContainer、SegmentButton | reuse-pattern |
| 色彩文档 | 见 VISUAL-LANG | 宇宙蓝与雪域灰 token | reuse-pattern |
| 工具库截图 | `evidence/` | 宫格、测速、日志、空态、蓝牙行、图表 | adapt / anti-pattern |

## 落选

| 对象 | 原因 |
| --- | --- |
| harmonyos_codelabs/nearlink-kit_-codelab，HEAD `d873f91` | 与官方 sample 同页：`MainPage`、`ScanConfigPage`、`SsapPage`、`SsapClientPage`、`SsapServerPage`。留 sample |
| 综合工具、健康模板、工厂模板的信息架构 | 宫格或设备入口。截图只作反例 |
| 账单环图 | 占比图，不是射频趋势 |
| ibest 色值与 CoolMall 壳 | 本次未把商城导航当调试工具的信息架构。ibest 只取组件职责目录 |
| PureTabs 的具体视觉 | 未把每个 view 逐行当产品稿。结论限于「页签嵌套是内容分类」 |
