# bindSheet 半模态弹窗开发经验

## 概述

本文档系统整理 HarmonyOS `bindSheet` 半模态弹窗的开发要点，包括 API 用法、V2 组件双向绑定、多实例绑定规则、确认交互模式，以及常见问题的成因与解决方案。

---

## 一、API 核心用法

### 1.1 基本调用

```typescript
@ComponentV2
struct MyComponent {
  @Local showSheet: boolean = false

  build() {
    Row() {
      Text('点击打开')
    }
    .onClick(() => { this.showSheet = true })
    .bindSheet(!!this.showSheet, this.SheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      dragBar: true,
      title: { title: '标题' },
      onDisappear: () => { /* 弹窗关闭后处理 */ }
    })
  }

  @Builder
  SheetBuilder() {
    Column() { /* 弹窗内容 */ }
  }
}
```

### 1.2 isShow 双向绑定

`isShow` 参数**必须使用双向绑定**，否则框架无法将弹窗关闭状态同步回组件变量。

| 绑定语法 | 适用组件 | 适用装饰器 | 最低 API |
|----------|----------|-----------|----------|
| `$$this.xxx` | `@Component` | `@State` | API 9+ |
| `!!this.xxx` | `@ComponentV2` | `@Local` | API 18+ |

使用双向绑定后，框架在弹窗关闭时自动将变量置为 `false`，无需在 `onDisappear` 中手动重置。

### 1.3 宿主节点绑定规则

**半模态严格和宿主节点绑定**——宿主节点销毁则弹窗销毁。

由此衍生出一条关键规则：**一个宿主节点只绑定一个 `bindSheet`**。

同一节点链式绑定多个 `bindSheet` 时，后绑定的实例状态会覆盖先绑定的，导致先绑定的弹窗闪退（打开即关闭）。这是社区已知问题，根本解决方案是将每个 `bindSheet` 绑定到各自独立的宿主组件上。

```typescript
// ❌ 同一节点绑定多个 bindSheet → 闪退
Column() {
  Row() { /* 选项 A */ }
  Row() { /* 选项 B */ }
}
.bindSheet(!!this.showSheetA, ...)
.bindSheet(!!this.showSheetB, ...)

// ✅ 每个 bindSheet 绑定独立宿主
Row() { /* 选项 A */ }
  .onClick(() => { this.showSheetA = true })
  .bindSheet(!!this.showSheetA, ...)

Row() { /* 选项 B */ }
  .onClick(() => { this.showSheetB = true })
  .bindSheet(!!this.showSheetB, ...)
```

---

## 二、生命周期回调

| 回调 | 时机 | 是否可修改状态 |
|------|------|--------------|
| `onWillAppear` | 弹窗即将显示 | ✅ |
| `onAppear` | 弹窗已显示 | ✅ |
| `onWillDisappear` | 弹窗即将消失 | ❌ 禁止 |
| `onDisappear` | 弹窗已消失 | ✅ |

**`onWillDisappear` 中禁止修改状态变量**，这是官方文档明确约束。需要做状态处理的逻辑统一放在 `onDisappear` 中。

---

## 三、确认交互模式

### 3.1 模式说明

半模态弹窗中的选择操作采用**暂存 + 确认**模式：弹窗内选择仅修改临时变量，用户点击确认后才应用到外部状态；用户取消（下拉关闭/点击遮罩）则丢弃选择。

### 3.2 状态变量设计

每个半模态选择需要三个 `@Local` 变量：

```typescript
@Local showXxxSheet: boolean = false       // 弹窗显隐
@Local tempXxx: Type = defaultValue         // 暂存选择值
@Local xxxConfirmed: boolean = false        // 确认标记
```

### 3.3 完整交互流程

```
用户点击触发 Row
  ├─ 将当前值拷贝到 temp 变量
  └─ showXxxSheet = true → 弹窗打开

弹窗内选择（Radio / 列表）
  └─ 仅修改 temp 变量，不影响外部状态

确认路径：
  用户点击确认按钮
    ├─ xxxConfirmed = true
    └─ showXxxSheet = false → 弹窗关闭
  onDisappear 触发
    ├─ xxxConfirmed 为 true → 读取 temp 值，调用回调应用变更
    └─ 重置 xxxConfirmed = false

取消路径：
  用户下拉关闭 / 点击遮罩
    └─ 弹窗关闭（!! 自动将 showXxxSheet 置 false）
  onDisappear 触发
    ├─ xxxConfirmed 为 false → 不应用变更
    └─ 重置 xxxConfirmed = false
```

### 3.4 代码模板

```typescript
// 触发组件
Row() {
  Text('选项名称')
  Text(this.currentValue)
}
.onClick(() => {
  this.tempValue = this.currentValue  // 拷贝当前值到临时变量
  this.showSheet = true
})
.bindSheet(!!this.showSheet, this.SheetBuilder(), {
  height: SheetSize.FIT_CONTENT,
  dragBar: true,
  title: { title: '选择标题' },
  onDisappear: () => {
    if (this.confirmed) {
      this.onValueChange(this.tempValue)  // 应用变更
    }
    this.confirmed = false  // 重置确认标记
  }
})

// 弹窗内容
@Builder
SheetBuilder() {
  Column({ space: 12 }) {
    // 选择列表，修改 tempValue
    ForEach(this.options, (option: Option) => {
      Row() {
        Radio({ value: option.id, group: 'selectGroup' })
          .checked(this.tempValue === option.id)
          .onChange((isChecked: boolean) => {
            if (isChecked) { this.tempValue = option.id }
          })
        Text(option.label)
      }
      .width('100%')
      .height(48)
    })

    Button($r('app.string.dialog_confirm'))
      .width('100%')
      .type(ButtonType.Capsule)
      .onClick(() => {
        this.confirmed = true           // 标记确认
        this.showSheet = false          // 关闭弹窗
      })
  }
  .padding($r('app.float.spacing_lg'))
}
```

**要点**：确认按钮必须先设 `confirmed = true` 再关闭弹窗。若只关闭弹窗不设标记，`onDisappear` 中会跳过应用逻辑，导致确认无效。

---

## 四、设置页面分区组件架构

### 4.1 结构

```
SettingsPage（页面）
  └── SettingsViewModel（@ObservedV2 + @Trace）
        └── SettingsUiState（UI 状态模型）
  └── Section 组件（@ComponentV2 + @Param）
        ├── DownloadSettingsSection    — 含 3 个 bindSheet
        ├── NotificationSettingsSection
        ├── AppearanceSettingsSection
        ├── StorageCacheSection
        └── AboutSection
```

### 4.2 数据流

```
ViewModel (@Trace 属性)
  → SettingsPage 读取并传入 Section 组件 (@Param)
    → Section 组件内部 @Local 管理弹窗状态
    → 用户操作通过回调函数上报 ViewModel
      → ViewModel 更新 @Trace 属性
        → @Param 自动同步到 Section 组件
```

**关键**：`@Local` 变量不会因 `@Param` 变化而重置。弹窗显隐状态用 `@Local` 管理，不会受父组件重渲染影响。

---

## 五、常见问题速查

| 现象 | 原因 | 解决 |
|------|------|------|
| 弹窗打开即关闭（闪退） | 同一宿主节点绑定多个 `bindSheet` | 每个 `bindSheet` 绑定到独立宿主组件 |
| 弹窗关闭后无法再次打开 | `isShow` 使用单向绑定，关闭状态未同步 | V2 组件使用 `!!this.xxx` 双向绑定 |
| 确认按钮点击无效 | 未设 `confirmed = true` 就关闭弹窗 | 先设标记再关闭 |
| 弹窗行为异常/偶发闪退 | 在 `onWillDisappear` 中修改状态 | 状态处理移至 `onDisappear` |

---

## 参考链接

- bindSheet 半模态 API：
  https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-universal-attributes-sheet-V5
- V2 状态管理：
  https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-mvvm-v2
