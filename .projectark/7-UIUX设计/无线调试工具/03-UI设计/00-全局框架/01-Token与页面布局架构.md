# Token 与页面布局架构

> **状态**：实现对照稿  
> **代码权威**：`common/ui/src/main/ets/token/` · `YoPageShell`  
> **依据**：HarmonyOS《圆角参数》、沉浸式布局指南、`SegmentButtonV2` / `Menu` API  
> **更新日期**：2026-07-23

---

## 1. 分层模型

```text
foundation/ → semantic/ → component Token → YoPageShell / feature pages
```

硬规则：禁止魔法数圆角/间距；同层同圆角。

---

## 2. 全量沉浸式（列表模块页）

窗口已 `setWindowLayoutFullScreen(true)`。`contentEdgeToEdge + !scrollable` 时：

| 层 | 行为 |
| --- | --- |
| `YoPageShell` | `ignoreLayoutSafeArea` TOP+BOTTOM；壳层 **bottomPadding=0**（避免与手势条双重留白） |
| 背景 | `expandSafeArea(SYSTEM, BOTTOM)` 延伸到导航指示条 |
| List | footer 占位 `height=navigationBottomInsetVp`，末行可点区域避让 |

根因：原先 MODULE 再加 `navInset + FORM_GAP`，在全屏布局下叠出底部空白带。

---

## 3. 分段按钮

| Do | Don't |
| --- | --- |
| `CapsuleSegmentButtonV2` + `selectedIndex!!` 写在 `build()` 内 | 把 Segment 包进 `@LocalBuilder`（会打断 !! 双向绑定/指示条滑动） |
| 面板用 if/else 切换 | 用 Swiper 做页间滑动（需求禁止） |
| `enableStateAnimation`（API24+）可选 | 工程 compatibleSdk=23 暂不依赖 |

---

## 4. 圆角 / 列表 Token

设备行 `CardToken.RADIUS_DEVICE_ROW`；间距 `ListToken.ITEM_GAP`。
