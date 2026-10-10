---
id: research.harmony-arkui-shell
type: topic-study
status: active
when: research
stack:
  capability: ui-kit
  languages: []
  frameworks: [ArkUI, HarmonyOS]
utilization: [reuse-pattern]
source:
  platform: other
  url: https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/ui/arkts-navigation-navigation.md
  repos:
    - openharmony/docs
studied_at: 2026-10-10
---

# ArkUI 规范摘录

本地没有 `HarmonyOS-Developer-docs` 树。华为开发者站点上的部分设计指南返回空壳，因此规范正文以 OpenHarmony 文档 GitHub 镜像和能够抽出正文的华为页面为准。

## 导航与布局

- `Navigation` 是根容器，模式为 `Stack`、`Split`、`Auto`。API 10 起自适应分栏阈值 600vp。导航页不在栈内，子页通过 `NavPathStack` 进入。  
  <https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/ui/arkts-navigation-navigation.md>
- `Tabs` 的子节点只能是 `TabContent`。页签切走后默认不销毁。默认 `barPosition` 为 `Start`。  
  <https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-container-tabs.md>
- `SideBarContainer` 必须且只能有两个子组件：侧栏、内容。  
  <https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-container-sidebarcontainer.md>
- `SegmentButton` 分页签、单选、多选，API 11，从 `@kit.ArkUI` 导入。  
  <https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ohos-arkui-advanced-SegmentButton.md>
- 标题栏可在 `stackBuilder` 放分段按钮，在 `bottomBuilder` 放搜索。自定义区不要挡住返回和标题。  
  <https://developer.huawei.com/consumer/cn/doc/HarmonyOS-Guides/ui-design-navigation-customized-area>

YoWire 把四个一级目的地放在 `Tabs`（窄）或侧栏（`xl`），把同一数据集的切换放在 `SegmentButton`。

## 半模态

`bindSheet` 是非全屏模态，适合个人信息、分享、创建日程、添加内容。复杂流程改用全模态或 `Navigation`。生命周期为 `onWillAppear` → `onAppear` → `onWillDisappear` → `onDisappear`。声明 `onWillDismiss` 后，关闭必须自己调用 `dismiss`。

<https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/ui/arkts-sheet-page.md>

华为指南同题页面在抓取时只剩文档壳，上面的镜像有正文，以镜像为准。站点入口仍记录在：<https://developer.huawei.com/consumer/cn/doc/HarmonyOS-Guides/arkts-sheet-page>

## 图表

`DataPanel` 展示占比，`values` 最多 9 个，小于 0 的值当 0，类型分环形与线形，类型不能动态改。

<https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-basic-components-datapanel.md>

时间序列和信道对比不使用该组件。见 [DASHBOARD.md](../DASHBOARD.md)。

## 色彩

宇宙蓝 `brand` 浅色 `#ff0a59f7`，深色 `#ff317af7`。雪域灰对应 `background_secondary` 浅色 `#fff1f3f5`。警告 `#ffe84026`，注意 `#ffed6f21`，确认 `#ff64bb5c`。文本四级与组件容器色见色彩页表格。

<https://developer.huawei.com/consumer/cn/doc/doccenter-ux-design/color-0000001776857164>

## 未读到正文的章节

列表与底部导航的 design-guides 链接没有返回正文。列表行为改由官方 sample（`wlan-info-query`、`BluetoothLowEnergy`、`NavigationSettings`）和空态截图约束，不假装已经对上那两篇设计指南。
