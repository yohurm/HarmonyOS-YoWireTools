# 鸿蒙跨APP跳转：openLink与startAbility实战经验

## 概述

本文档记录从APP直接跳转到B站APP登录页面的全链路排查与解决过程，覆盖 `openLink` AppLinking匹配机制、`bm dump` 命令行排障方法、以及 `startAbility` 显式Want绕过路径限制的方案。

---

## 一、问题背景

需求：二维码登录时增加"在B站APP中登录"按钮，点击后直接跳转B站APP，不经过系统浏览器。

原始方案使用 `context.openLink(url)`，但无论怎么调参，始终先跳浏览器再跳B站APP。经过命令行逐层排查，最终定位到 AppLinking 的 pathRegex 限制，改用 `startAbility` 显式 Want 解决。

---

## 二、openLink 的 AppLinking 匹配机制

### 2.1 API 定义

```typescript
import { common, OpenLinkOptions } from '@kit.AbilityKit'

// appLinkingOnly: true  → 仅走 AppLinking，匹配不到直接失败
// appLinkingOnly: false → AppLinking 失败后回退 DeepLinking（浏览器）
await context.openLink(url, { appLinkingOnly: true })
```

### 2.2 匹配条件（三个缺一不可）

`openLink` 要成功拉起目标APP，目标APP必须在 `module.json5` 的 `skills` 中同时满足：

| 条件 | 字段 | 值 |
|------|------|-----|
| 1. action | `actions` | 包含 `"ohos.want.action.viewData"` |
| 2. entity | `entities` | 包含 `"entity.system.browsable"` |
| 3. URI | `uris` | `scheme` 匹配 + `host` 匹配 + `pathRegex` 匹配 + `domainVerify: true` |

**关键坑点：pathRegex 不是通配的。** 很多APP对每个功能路径单独注册一条 URI，`/h5-app/passport/login` 这种非标准路径大概率不在注册列表中。

---

## 三、bm dump 排障方法

### 3.1 命令路径

```bash
# hdc.exe 在 SDK 的 toolchains 目录下
SDK_PATH/sdk/default/openharmony/toolchains/hdc.exe
```

### 3.2 列出所有已安装APP

```bash
hdc shell bm dump -a | grep -i "bili"
# 输出: yylx.danmaku.bili
```

### 3.3 查看指定APP的完整注册信息

```bash
hdc shell bm dump -n "yylx.danmaku.bili" > bili_dump.txt
```

### 3.4 分析结果

提取 domainVerify 和 host 的组合：

```bash
grep -B 50 '"host": "目标域名"' bili_dump.txt \
  | grep -E '"domainVerify"|"host"|"scheme"|"pathRegex"'
```

### 3.5 本章排查时 B站APP 的实际注册

**passport.bilibili.com（登录域名）：完全未注册。** 这是第一次 `appLinkingOnly: true` 失败的根因——host 都不匹配。

**www.bilibili.com（主域名）：注册了7条，domainVerify=true，但每条都有特定 pathRegex：**

| pathRegex | 用途 |
|-----------|------|
| `blackboard/.*` | 黑板报 |
| `BPU.*` | BPU |
| `read/cv.*` | 专栏 |
| `video/.*` | 视频 |
| `bangumi/i/.*` | 番剧 |
| `mobile/bangumi/i/.*` | 移动端番剧 |
| `cheese/play/ep.*` | 付费课堂 |

**`/h5-app/passport/login` 不在任何一条 pathRegex 中。** 即使将 URL 重写为 `www.bilibili.com`，AppLinking 依然失败——这是第二次失败的根因。

---

## 四、解决方案：startAbility 显式 Want

### 4.1 原理

`openLink` 走隐式 Want 匹配，依赖 `skills` 中的 pathRegex 完全匹配。`startAbility` 显式 Want 直接通过 `bundleName + moduleName + abilityName` 指定目标 Ability，**绕过 skill 匹配**。

### 4.2 从 bm dump 获取显式 Want 参数

B站APP shortcut 中暴露了显式 Want 参数：

```json
{
  "targetBundle": "yylx.danmaku.bili",
  "targetClass": "EntryAbility",
  "targetModule": "phone"
}
```

### 4.3 实现代码

```typescript
import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'

const BILI_BUNDLE = 'yylx.danmaku.bili'
const BILI_MODULE = 'entry'
const BILI_ABILITY = 'EntryAbility'

async function openBiliApp(context: common.UIAbilityContext, url: string) {
  try {
    // 策略1: 显式 Want 拉起 B站APP，绕过 AppLinking 的 pathRegex 限制
    const want: Want = {
      bundleName: BILI_BUNDLE,
      moduleName: BILI_MODULE,
      abilityName: BILI_ABILITY,
      uri: url
    }
    await context.startAbility(want)
  } catch (_explicitError) {
    // 策略2: 显式 Want 失败（APP未安装）→ 回退 DeepLinking
    await context.openLink(url, { appLinkingOnly: false })
  }
}
```

### 4.4 关键约束

| 约束 | 说明 |
|------|------|
| `bundleName` 硬编码 | B站包名 `yylx.danmaku.bili` 来自 `bm dump`，不会频繁变化但不保证永不变 |
| 目标 Ability 必须 exported | `EntryAbility` 是主入口，一般默认 exported |
| 安全管控 | 鸿蒙 API 12+ 后第三方APP显式拉起可能受管控，需实测 |
| 兜底策略 | 显式 Want 失败时自动回退 `openLink(appLinkingOnly: false)`（浏览器→snackBar→B站） |

---

## 五、错误处理策略

采用二级兜底：

```
显式 startAbility(bundleName+abilityName+uri)
    ├─ 成功 → B站APP直接打开 ✓
    └─ 失败 → openLink(url, {appLinkingOnly: false})
               ├─ 成功 → 浏览器 → snackbar → B站APP（兜底路径）
               └─ 失败 → 提示用户错误信息
```

**不要尝试 `appLinkingOnly: true` 中间路径**——如果 `bm dump` 确认 pathRegex 不匹配，此路径必然失败，无需增加不必要的重试。

---

## 六、验证方法

### 6.1 日志关键字

```bash
hdc hilog | grep -E "C01324|C01336|C01331|C01332|startAbility|start.ability"
```

| 日志 | 含义 |
|------|------|
| `[napi_common_open_link_options.cpp29]called` | openLink 被调用 |
| `[AMC1703]call` | AMS 匹配流程 |
| `[js_ability_context.cpp1117]start ability by default succeeded` | DeepLinking 成功（走浏览器） |
| `[ui_ability_thread.cpp321]name:EntryAbility,targeState:6` | 当前APP进入后台（成功拉起其他APP） |

### 6.2 日志特征对比

**成功（显式Want）：**
```
[C01324] [napi_common_open_link_options.cpp*]  ← 只有 startAbility，无 openLink
[C01332] targetState:6                          ← 当前APP进后台，B站APP在前台
```

**失败回退（DeepLinking）：**
```
[C01324] called →
[C01336] [AMC1703]call →  ← AppLinking 尝试
[C01324] called →           ← fallback openLink
[C01331] start ability by default succeeded  ← DeepLinking 成功（浏览器路径）
```

---

## 七、启动方 module.json5 配置

使用 `startAbility` 显式拉起其他APP前，需要在**调用方**（我们的APP）的 `module.json5` 中声明 `querySchemes`：

```json5
{
  "module": {
    "querySchemes": [
      "bilibili"  // B站APP的 custom scheme
    ]
  }
}
```

如果只通过 `https` URL 和 bundleName 显式拉起，此配置可能非必需，但建议添加以支持未来通过 scheme 匹配。

---

## 八、核心教训

1. **AppLinking 不是万能钥匙。** `openLink(url, {appLinkingOnly: true})` 要求目标APP为该特定 host + pathRegex 组合做了 domainVerify 注册。大多数APP只为核心路径注册，登录/支付等特殊路径通常不在其中。

2. **先 dump 再写代码。** 在尝试跨APP跳转前，先用 `bm dump -n <包名>` 确认目标APP的实际 skills 注册情况，避免盲试。

3. **显式 Want 是底线策略。** 当 AppLinking 的 pathRegex 不匹配时，`startAbility` 显式 Want 是唯一能绕过系统匹配层、直接跟目标APP通信的方式。

4. **始终带兜底。** 显式 Want 受系统安全管控影响，可能在某些设备/版本上失败。DeepLinking（浏览器→APP）作为兜底保证功能不降级到不可用。
