---
id: ui.app-shell.walls
type: ui-design
status: draft
when: design
related:
  - docs/goal/ui/app-shell/color-scheme.md
  - common/youi_kit/src/main/ets/components/feedback/YoPermissionDenied.ets
  - common/youi_kit/src/main/ets/model/YoPageState.ets
---

# 权限墙与缺口墙

两种墙都占内容区的同一块表面：`YoColor.SURFACE_CARD`，页边距走 `YoResponsive.pageHorizontal`，标题 `YoTypeStyle.SUBTITLE_M`，说明 `BODY_M`，下一步 `BODY_S`。差别在胶囊语气和有没有主操作。

进入模块不弹授权。用户点击扫描、连接或读取之后，才进入权限墙。这与 NL-013、WN-001、BT-001 的方向一致。

## 权限墙

`YoPageState.PERMISSION`，宿主 `YoContentState`，内容 `YoPermissionDenied`。

| 情况 | 屏上 | 主操作 |
| --- | --- | --- |
| 可以再次申请 | 标题说明缺什么权限。不出现空列表，不出现成功胶囊 | 「授权」。点击交给页面状态，页面不调用 `requestPermissionsFromUser` |
| 系统不再弹框 | 同上，并写前往应用设置 | 「去设置」 |
| 系统授权未声明（Wi-Fi 的 201） | 这是声明缺失，不是运行时弹窗。用 `YoError`，`nativeCode` 为 201，`retryable` 为假 | 没有「授权」按钮。下一步指向权限与能力页 |

权限墙不用 `YoEmpty`。空是「操作正常结束且确实没有行」。

Wi-Fi 四项 `GET_WIFI_INFO`、`SET_WIFI_INFO`、`GET_NETWORK_INFO`、`INTERNET` 是系统授权。已声明时打开页面不弹运行时窗（WN-001）。未声明时按 WN-002 至 WN-005 显示 201。

蓝牙运行时权限是 `ohos.permission.ACCESS_BLUETOOTH`。不用已废弃的 `USE_BLUETOOTH` 当作 API 10+ 的替代（BT-007）。星闪运行时权限是 `ohos.permission.ACCESS_NEARLINK`，不捆绑蓝牙权限（NL-017）。

## 缺口墙

平台没有该能力时，页面保持 `YoPageState.CONTENT`。顶上 `YoStatusPill` 语气 `warning` 或 `neutral`，文案写限制，不写「已完成」「已测量」「已抓包」「已解除」。没有会执行该能力的主按钮。

| 例子 | 屏上禁止出现 |
| --- | --- |
| BT-008 模拟器蓝牙不可用 | 成功扫描 |
| BT-015 经典发现没有平台过滤参数 | 「平台已按名称扫描」 |
| BT-023、NL-101 应用不能取消配对 | 可成功的「取消配对」 |
| BT-088、NL-113 应用内不能抓空口 | 「开始抓包」成功 |
| WN-118 至 WN-127 抓包、加速、防火墙 | 看起来像暂时禁用、其实会成功的按钮 |
| WN-036、WN-049 噪声与 SNR 未提供 | 用 0 填充的测量值 |
| NL-036 服务 UUID 不能作为系统过滤 | 「已按系统过滤」 |

缺口行可以点开说明。说明用 `bindSheet` 或页内展开，不新做对话框组件。半模态模式来自 [guide-snippets 的 BindSheet](https://gitcode.com/HarmonyOS_Samples/guide-snippets/tree/master/ArkUISample/BindSheet) 和 [HarmonyOSComponentUXExamples](https://gitcode.com/HarmonyOS_Samples/HarmonyOSComponentUXExamples) 的 `products/phone/src/main/ets/components/container/bindsheet/`。

破坏性确认（清空日志）用 `AlertDialog`。样例里的消息框、操作框在 `products/phone/src/main/ets/components/container/dialog/`。不采用 [NativeDialogSample](https://gitcode.com/HarmonyOS_Samples/guide-snippets/tree/master/ArkUISample/NativeDialogSample) 的 NDK 弹窗。

## 组件树

```text
Column
├── YoStatusPill                 // 权限：warning；缺口：warning 或 neutral
├── Text                         // 标题
├── Text                         // 原因，含 nativeCode（若有）
├── Text                         // 下一步
└── YoActionButton               // 仅权限墙且 canRequest / 可去设置时出现
    └── Button
```

整页替换时，这棵树放在 `YoContentState` 里，列表不同时显示成「0 条成功」。

## 七态里的位置

权限墙是「无权限」，不是「错误」也不是「空」。Kit 拒绝、超时、服务停止仍是「错误」（`YoError`）。缺口墙在「默认」里呈现限制，不进入成功胶囊。
# 权限与缺口

两种墙都占满内容区，底栏还在。不使用扫描成功的雷达图，避免看起来像已经扫到设备。

## 无权限

`Column`，左右 space.16，垂直居中偏上 24vp：

- 标题 type.title.m：「需要蓝牙权限」或对应射频的一句。星闪、网络各用自己的一句，不复用蓝牙文案。
- 说明 type.body.m，最多两行，二级色。说明来自 ViewModel 的原因字符串。规范不新写权限名。
- 一颗主按钮。首次拒绝前文案「去授权」。永久拒绝后文案「去设置」。不会两颗同时出现。
- 没有列表，没有「重新搜索」。

出现这面墙时，该页不发起扫描、不打开连接 sheet。工作台和更多不因为未授权而显示这面墙（现有页面本来也不申请射频权限）。

按下：主按钮走系统按下态。禁用：没有禁用态；墙本身就是挡住操作。若授权请求进行中，按钮文案改为「正在请求」，`enabled` false，旁边 16vp `LoadingProgress`。

## 缺口

设备不支持、开关关闭、模拟器没有射频、声明缺失，都走同一结构，文案不同：

- 标题：「蓝牙未打开」「此设备没有星闪」或 ViewModel 给出的短句。
- 说明一行：开关关闭时写「到系统设置打开」；不支持时写「不能在此设备上扫描」。
- 开关关闭：文字按钮「打开系统设置」，没有主按钮去假装应用能打开星闪开关。
- 不支持：没有按钮。列表区域不渲染。

错误（扫描失败、连接失败）不是这面墙。错误留在原布局里：结果标题改成失败短句，辅文是 ViewModel 的消息，列表清空或保留上次成功的行并在 `SubHeader` 标明「上次结果」。连接失败留在 sheet 里，结果行用 status.error，主按钮恢复可点，文案仍是「连接」。

加载不是墙。加载见各屏：标题旁 16vp `LoadingProgress`，已有的行继续显示。
