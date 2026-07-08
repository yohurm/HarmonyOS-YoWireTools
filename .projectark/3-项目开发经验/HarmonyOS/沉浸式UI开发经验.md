# 鸿蒙沉浸式UI开发：自底而上全链路实战

## 概述

本文档记录 HarmonyOS APP 从窗口层到标题栏完整沉浸式效果的实现方案，涵盖 `setWindowLayoutFullScreen`、`ignoreLayoutSafeArea`、`expandSafeArea`、`clipContent` 的职责边界，HdsTabs 悬浮样式与沉浸光感材质，以及 HdsNavigation 标题栏的动态模糊与系统材质效果。

核心原则：**每一层只做自己该做的事，避让完全交系统框架处理，杜绝手动像素传递。**

---

## 一、两种沉浸式方案对比

HarmonyOS 提供了两种实现沉浸式效果的路径，场景不同，选择不同：

| 方案 | 机制 | 适用场景 | 本项目的选择 |
|------|------|----------|-------------|
| **窗口全屏布局** | `setWindowLayoutFullScreen(true)` → 界面元素延伸到状态栏/导航条区域 → 手动通过 `avoidAreaChange` 获取避让区高度做 padding | 需要在状态栏/导航条区域布局独立 UI 元素（如游戏控件、视频进度条） | 本项目的窗口层 |
| **组件安全区** | 不调 `setWindowLayoutFullScreen` → 使用 `expandSafeArea` / `ignoreLayoutSafeArea` / `clipContent` 让组件绘制延伸 → 布局保持在安全区内 | 只需要背景/颜色延伸到系统栏，不需要在系统栏区域放置交互元素 | 本项目头部/底部 |

**本项目的混合方案**：窗口层用方案一（`setWindowLayoutFullScreen(true)` 打开全屏布局能力），组件层用方案二的 API（`ignoreLayoutSafeArea` / `clipContent` / `enableComponentSafeArea`）处理各层的具体避让。

> 窗口开了 `setWindowLayoutFullScreen(true)` 只是**许可**内容延伸到系统栏，具体哪些组件延伸到哪里，由 `ignoreLayoutSafeArea` / `expandSafeArea` 逐组件控制。

---

## 二、自底而上的五层架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────┐
│ L1  EntryAbility          窗口级                     │
│     setWindowLayoutFullScreen(true)                 │
│     setWindowSystemBarProperties(transparent)       │
├─────────────────────────────────────────────────────┤
│ L2  RootPage              根导航                    │
│     Navigation.ignoreLayoutSafeArea([TOP, BOTTOM])  │
├─────────────────────────────────────────────────────┤
│ L3  MainTabContainer      Tab 容器                  │
│     HdsTabs.barFloatingStyle + systemMaterialEffect │
├─────────────────────────────────────────────────────┤
│ L4  TopNavigationPageContainer  页面壳层             │
│     HdsNavigation.ignoreLayoutSafeArea([TOP])       │
│     titleBar: avoidLayoutSafeArea +                 │
│               enableComponentSafeArea +             │
│               systemMaterialEffect                  │
│     Scroll.clipContent(ContentClipMode.SAFE_AREA)   │
├─────────────────────────────────────────────────────┤
│ L5  DownloadPage / SettingsPage / ProfilePage       │
│     统一 bottomPadding 常量                         │
└─────────────────────────────────────────────────────┘
```

### 2.2 L1 — 窗口级：开全屏 + 透明系统栏

```typescript
// EntryAbility.ets
import { window } from '@kit.ArkUI'

private configureMainWindow(windowStage: window.WindowStage): void {
  const mainWindow = windowStage.getMainWindowSync()

  // 打开全屏布局许可：内容可延伸到状态栏和导航条区域
  void mainWindow.setWindowLayoutFullScreen(true)

  // 系统栏属性：透明背景 + 自适应深浅色文字
  const props: window.SystemBarProperties = {
    statusBarColor: '#00000000',              // 状态栏透明
    statusBarContentColor: contentColor,       // 状态栏文字颜色（深色/浅色自适应）
    navigationBarColor: '#00000000',           // 导航条透明
    navigationBarContentColor: contentColor    // 导航条文字颜色
  }
  void mainWindow.setWindowSystemBarProperties(props)
}
```

**关键点**：
- `statusBarColor` 和 `navigationBarColor` 都设为透明 —— 沉浸式效果的核心前提
- `contentColor` 从 `base/dark` 资源目录读取，随系统深浅模式自动切换
- **不需要** `avoidAreaChange` 监听、不需要 `getWindowAvoidArea` 查询 — 后续层的 `ignoreLayoutSafeArea` / `enableComponentSafeArea` 会处理

### 2.3 L2 — 根导航：绘制延伸授权

```typescript
// RootPage.ets
Navigation(this.navStack) {
  MainTabContainer({ ... })
}
.ignoreLayoutSafeArea(
  [LayoutSafeAreaType.SYSTEM],
  [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM]
)
```

**职责**：让 Navigation 容器的绘制区域覆盖整个屏幕（包括状态栏和导航条区域）。

**关键点**：
- `ignoreLayoutSafeArea` 只作用于**绘制**，不改变布局
- 子组件的布局仍然被安全区域约束，不会自动跑进状态栏
- 这步设置后，Navigation 的背景色可以铺满全屏

### 2.4 L3 — Tab 容器：底部悬浮导航 + 沉浸光感

```typescript
// MainTabContainer.ets
import { HdsTabs, HdsTabsController, hdsMaterial } from '@kit.UIDesignKit'
import { SymbolGlyphModifier } from '@kit.ArkUI'

@Local materialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE

aboutToAppear(): void {
  // 查询设备是否支持 IMMERSIVE 材质，不支持则降级到 SMOOTH
  const types = hdsMaterial.getSystemMaterialTypes()
  if (types.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
    this.materialLevel = hdsMaterial.MaterialLevel.SMOOTH
  }
}

build() {
  HdsTabs({ controller: this.controller }) {
    TabContent() { DownloadPage(...) }
      .tabBar(new BottomTabBarStyle({
        normal: new SymbolGlyphModifier($r('sys.symbol.arrow_down'))
          .fontColor([$r('sys.color.ohos_id_color_bottom_tab_icon_off')]),
        selected: new SymbolGlyphModifier($r('sys.symbol.arrow_down'))
          .fontColor([$r('sys.color.ohos_id_color_activated')])
      }, $r('app.string.tab_download')))
    // ...
  }
  .barOverlap(true)        // TabBar 悬浮在 TabContent 之上
  .barPosition(BarPosition.End)
  .vertical(false)
  .barFloatingStyle({
    barBottomMargin: 28,    // 底部间距（单位 vp）
    systemMaterialEffect: {
      materialType: hdsMaterial.MaterialType.ADAPTIVE,  // 自适应系统材质
      materialLevel: this.materialLevel                  // 运行态材质等级
    }
  })
}
```

**关键点**：
- `barOverlap(true)` + `barFloatingStyle` 是 HdsTabs 悬浮效果的必要条件
- `systemMaterialEffect` 实现沉浸光感：毛玻璃 + 投影 + 边缘光效，由系统根据设备算力自动调节
- `MaterialType.ADAPTIVE` 表示跟随系统策略自适应（推荐）
- 不支持 IMMERSIVE 材质的设备降级到 `SMOOTH`，避免卡顿和发热
- 不再需要手写 `backdropBlur`、`shadow`、`borderRadius` 等属性

**图标颜色使用系统语义色**：
- 未选中：`sys.color.ohos_id_color_bottom_tab_icon_off`（系统自动适配深浅模式）
- 选中：`sys.color.ohos_id_color_activated`（系统主题色）

### 2.5 L4 — 页面壳层：标题栏沉浸 + 内容安全区

```typescript
// TopNavigationPageContainer.ets
import { HdsNavigation, HdsNavigationTitleMode, ScrollEffectType, hdsMaterial } from '@kit.UIDesignKit'

@Local materialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE

build() {
  HdsNavigation() {
    Scroll(this.scroller) {
      Column() { this.content() }
    }
    .clipContent(ContentClipMode.SAFE_AREA)  // 裁剪到安全区边缘
  }
  .titleBar({
    avoidLayoutSafeArea: true,       // 标题栏在状态栏下方排版
    enableComponentSafeArea: true,   // 标题栏成为组件安全区 → Scroll 自然避让
    style: {
      scrollEffectOpts: {            // 滚动动态模糊
        enableScrollEffect: true,
        scrollEffectType: ScrollEffectType.COMMON_BLUR,
        blurEffectiveStartOffset: LengthMetrics.vp(0),
        blurEffectiveEndOffset: LengthMetrics.vp(20)
      },
      systemMaterialEffect: {       // 标题栏按钮沉浸光感
        materialType: hdsMaterial.MaterialType.ADAPTIVE,
        materialLevel: this.materialLevel
      }
    },
    content: { title: { mainTitle: this.title } }
  })
  .bindToScrollable([this.scroller])
  .titleMode(HdsNavigationTitleMode.MINI)
  .hideBackButton(true)
  .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
}
```

**关键点**：
- `ignoreLayoutSafeArea([TOP])`：HdsNavigation 背景绘制延伸到状态栏 — 实现顶部沉浸
- `avoidLayoutSafeArea: true`：标题栏自身排版避让状态栏 — 标题文字不会和状态栏图标重叠
- `enableComponentSafeArea: true`：标题栏声明为组件安全区 — Scroll 内容自动在标题栏下方排版
- `clipContent(ContentClipMode.SAFE_AREA)`：Scroll 内容裁剪到安全区边缘 — 滚动到底部时内容不会被导航条遮挡
- 删除了旧的 `Blank().height(computeTitleSpacerVp())` 手动占位 hack — 由系统框架的 `enableComponentSafeArea` 替代

### 2.6 L5 — 页面：统一底部间距

```typescript
// DownloadPage.ets / SettingsPage.ets / ProfilePage.ets
const BOTTOM_FLOATING_NAV_SPACING: number = 88

TopNavigationPageContainer({
  bottomPadding: LengthMetrics.vp(BOTTOM_FLOATING_NAV_SPACING),
  // ...
})
```

**关键点**：
- 三个页面使用统一的 `BOTTOM_FLOATING_NAV_SPACING = 88` 常量
- 这个值 = HdsTabs 底部悬浮导航栏高度（56vp）+ 底部安全间距（约 28vp 包括导航条避让）
- 作为 Scroll 的 `bottomPadding`，确保滚动到最底部时最后一项内容不被悬浮导航栏遮挡

---

## 三、常见错误模式

### 3.1 ❌ 手动像素传递：`avoidAreaChange` → AppStorage → Page padding

```typescript
// ❌ 错误的做法：监听窗口避让区变化 → 写入 AppStorageV2 → 各页面读取计算 padding
mainWindow.on('avoidAreaChange', (data) => {
  const insets = connectWindowInsets()
  insets.topInsetPx = data.area.topRect.height
  insets.bottomInsetPx = data.area.bottomRect.height
})

// ❌ 页面中手动计算
@Local insets: WindowInsetsAppState = connectWindowInsets()
private computeBottomPaddingVp(): number {
  return this.getUIContext().px2vp(this.insets.bottomInsetPx) + FLOATING_NAV_SPACING
}
```

**问题**：引入了 AppStorageV2 的跨层数据流 + px2vp 转换 + 多处重复计算。系统框架已经提供了 `ignoreLayoutSafeArea` / `clipContent` / `enableComponentSafeArea` 等声明式 API，无需手动计算。

### 3.2 ❌ 手写悬浮导航栏：Row + backdropBlur + shadow

```typescript
// ❌ 手写的悬浮胶囊导航条
Row() { ForEach(...) }
  .backgroundColor('#E6FFFFFF')
  .borderRadius(28)
  .backdropBlur(20)
  .shadow({ radius: 16, color: ..., offsetY: 4 })
```

**问题**：无法享受系统的沉浸光感材质效果（毛玻璃层级、边缘流光、按压阴影），无法按设备算力自适应材质等级，深浅色模式需额外维护两组颜色。

### 3.3 ❌ 标题栏手动 spacer hack

```typescript
// ❌ 手动创建一个 Blank 做标题栏避让
Column() {
  Blank()
    .height(this.getUIContext().px2vp(this.insets.topInsetPx) + TITLE_BAR_HEIGHT)
    .width('100%')
  this.content()
}
```

**问题**：手动计算 px→vp 转换 + 硬编码 TITLE_BAR_HEIGHT + 依赖 AppStorageV2 传递的像素值。应使用 `enableComponentSafeArea: true`。

### 3.4 ❌ 在浅色列表页误用 `IMMERSIVE_GRADIENT_BLUR` / `GRADIENT_BLUR(enableScrollEffect:false)`

WSL API 对标题默认色的规定（`HdsNavigationTitleStyle.mainTitleColor`）：

| scrollEffectType | enableScrollEffect | 默认主标题色 |
|------------------|-------------------|-------------|
| `COMMON_BLUR` | 任意 | `font_primary`（浅色模式深色字）✅ |
| `GRADIENT_BLUR` | `false` | `font_on_primary`（白字）❌ 浅色列表页 |
| `GRADIENT_BLUR` | `true` | 滚动前 `font_primary`，滚动后 `font_on_primary` |
| `IMMERSIVE_GRADIENT_BLUR` | `false` | 沉浸式图文初始态，白字 ❌ 浅色列表页 |

**根因链路（自底而上）**：

1. **L1** `EntryAbility` + `SystemBarThemeCoordinator`：窗口级透明系统栏 + 深浅色 contentColor —— 正确基线。
2. **L4** `HdsNavigation.systemBarStyle`：WSL 明确「不建议与 `setWindowSystemBarProperties` 混用」；主页面状态栏以 HdsNavigation 为准，默认跟随标题栏字体色。
3. **误配**：浅色列表/工作台（`scrollable:false`）使用 `IMMERSIVE_GRADIENT_BLUR` 或 `GRADIENT_BLUR + enableScrollEffect:false` → 标题固定 `font_on_primary` → 状态栏图标同步变白。

**正确场景映射（`HdsTitleBarPolicy`）**：

- 列表/工作台浅色内容：`COMMON_BLUR` + `originalStyle/scrollEffectStyle` 显式 `font_primary`
- 可滚动列表沉浸光感：同上（参考 WSL《设置动态模糊样式》官方示例）
- 沉浸式图文 hero：`IMMERSIVE_GRADIENT_BLUR` + `font_on_primary` → `font_primary` 过渡

### 3.5 ❌ 重复设置 `ignoreLayoutSafeArea`

在 RootPage 的 Navigation 和 TopNavigationPageContainer 的 HdsNavigation 上分别设置了 `ignoreLayoutSafeArea([TOP])`，但实际只需要后者。RootPage 的 Navigation 只需 `ignoreLayoutSafeArea([TOP, BOTTOM])` 保证根容器绘制延伸到系统栏即可；各页面的 HdsNavigation 各自用 `ignoreLayoutSafeArea([TOP])` 控制标题栏背景延伸。

---

## 四、沉浸光感材质适配策略

```typescript
aboutToAppear(): void {
  const materialTypes = hdsMaterial.getSystemMaterialTypes()
  if (materialTypes.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
    // 当前设备不支持 IMMERSIVE 材质 → 降级到 SMOOTH
    // 避免在低算力设备上产生卡顿和发热
    this.materialLevel = hdsMaterial.MaterialLevel.SMOOTH
  }
  // 支持 IMMERSIVE → 保持 EXQUISITE（精致效果）
}
```

| MaterialLevel | 说明 | 适用设备 |
|---------------|------|----------|
| `EXQUISITE` | 沉浸光感最高品质 | 高端设备 |
| `IMMERSIVE` | 标准沉浸光感 | 中高端设备 |
| `SMOOTH` | 基础平滑效果 | 低端设备 / 不支持 IMMERSIVE 的设备 |
| `ADAPTIVE` | 系统自适应（仅 MaterialType 使用） | 推荐 |

**查询结果示例**：
- 支持 IMMERSIVE 的设备 → 返回数组包含 `MaterialType.IMMERSIVE` → 使用 `EXQUISITE`
- 不支持 IMMERSIVE 的设备（如部分低端机型）→ 降级为 `SMOOTH`

---

## 五、参考文档

- [开发应用沉浸式效果](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-develop-apply-immersive-effects)
- [UI Design Kit — 沉浸光感材质](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-design-hds-component-material)
- [设置页签栏的悬浮样式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-design-hds-tabs-bar-floating)
- [设置动态模糊样式](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ui-design-navigation-dynamic-blur)
- [导航条设计指南](https://developer.huawei.com/consumer/cn/doc/design-guides/navigation-0000001957075737)
- [状态栏设计指南](https://developer.huawei.com/consumer/cn/doc/design-guides/status-bar-0000001776775568)
- [管理应用窗口（Stage模型）](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/application-window-stage)
- [SymbolGlyphModifier API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/universal-attributes-attribute-symbolglyphmodifier)
- [BottomTabBarStyle API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-container-tabcontent#bottomtabbarstyle9)
