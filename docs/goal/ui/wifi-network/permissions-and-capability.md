---
id: ui.wifi-network.permissions
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 权限与能力

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Scroll
            └── Column
                ├── Row
                │   ├── Text
                │   └── YoStatusPill
                ├── TextInput
                ├── YoSegmentButton
                ├── List
                │   └── ListItem
                └── YoActionButton
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 见下方行为细则中的同名描述。 |
| 按下 | 见下方行为细则中的同名描述。 |
| 禁用 | 见下方行为细则中的同名描述。 |
| 空 | 见下方行为细则中的同名描述。 |
| 错误 | 见下方行为细则中的同名描述。 |
| 加载 | 见下方行为细则中的同名描述。 |
| 无权限 | 四项系统授权未声明时是错误 201，不弹运行时窗（WN-001 至 WN-005）。本页没有「申请运行时权限」按钮。本机 MAC 无权限时单元格留空（WN-009）。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/permissions-and-capability` |
| 架构编号 | WN-007, WN-001, WN-009, WN-008, WN-010, WN-002, WN-003, WN-004, WN-005, WN-006 |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 。文件不在 `main` |
| 工作台入口 | 工作台「网络」卡片，或底栏网络槽（下标 2） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


本页核对安装包已经声明的系统授权，并逐项显示 `isFeatureSupported` 的是或否。页面状态读 `PermissionScenario` 的 `WIFI_INFO`、`WIFI_CONTROL`、`NETWORK_INFO`、`NETWORK_ACCESS`。页面不调用 `abilityAccessCtrl`，不调用 `requestPermissionsFromUser`。

## 布局

`YoPageShell` 标题「权限与能力」，`destinationKind = MODULE`。

内容分三块，块间距 `YoResponsive.SECTION_GAP`（16vp）：

1. 系统授权。四行：`GET_WIFI_INFO`、`SET_WIFI_INFO`、`GET_NETWORK_INFO`、`INTERNET`。主行是权限名，次行是「系统授权，已声明」或「未声明」。右侧 `YoStatusPill`。
2. 能力。六行固定出现：基础结构、5 GHz、Wi-Fi Direct、Soft AP、SAE、增强开放。每行右侧只有「是」或「否」（WN-007）。
3. 受限与系统项。这些行的默认文案就是拒绝，见下节。

`<600vp` 单列。`≥600vp` 左栏放三块标题，右栏放当前块的行。行高 56vp。错误码放在次行，字号 `YoTypeStyle.BODY_S`，颜色 `YoColor.TEXT_SECONDARY`。

## 状态

### 默认

四项均已声明：胶囊「已声明」，色 `success`。不出现系统授权弹窗（WN-001）。能力六行都有是或否。本机 MAC 行写「无权限」，地址单元格为空（WN-009）。对端地址行写「随机地址」（WN-008）。打开或关闭系统 WLAN 的位置显示说明「需要系统应用或企业权限」，旁边没有开关（WN-010）。

### 按下

行按下透明度为 `YoOpacity.PRESSED`。松手只展开该行的一句说明，不申请权限。说明页里的「知道了」用 `YoActionButton` `TEXT`。

### 禁用

本页没有「申请运行时权限」按钮。若实现时保留一个动作位，`isEnabled = false`，`disabledReason` 为「系统授权不走运行时申请」。WN-010 不提供可点的 WLAN 开关；开关控件不出现，因此也没有按下态。

### 空

能力查询尚未返回且没有错误时，能力块用 `YoEmpty`，标题「尚未取得能力结论」，说明「等待 isFeatureSupported」。有任意一行无结论时整页不算默认成功。未声明权限不用空态。

### 错误

未声明 `GET_WIFI_INFO`：整页 `ERROR`，`userMessage`「权限被拒绝」，`nativeCode`「201」。列表区域不渲染成空白成功（WN-002）。未声明 `SET_WIFI_INFO` 时，扫描入口在本页显示同一错误，扫描按钮不出现在加载中（WN-003）。未声明 `INTERNET` 或 `GET_NETWORK_INFO` 时，对应行进入错误，次行分别是「DNS 与 HTTP 将失败」和「不显示网关」（WN-004、WN-005）。

设备返回 801：该能力行离开加载，胶囊「本机不支持」，次行保留 `801`（WN-006）。`YoError.retryable = false`。

### 加载

进入页面时能力块为 `LOADING`，文案「正在读取能力」。每一项返回后该行改为是或否。任一项失败则该行改错误，其余行继续。全部返回或失败后整块离开加载。

## 受限、系统或企业

这些行没有应用内成功态。

| 条目 | 默认可见结果 |
| --- | --- |
| WN-008 受限 | 扫描与链路里的 BSSID 标「随机地址」。不显示厂商，不用星号代替地址 |
| WN-009 受限 | 本机 WLAN MAC 行写「无权限」。单元格无占位 MAC |
| WN-010 系统或企业 | 文案「需要系统应用或企业权限」。WLAN 开关状态保持进入页面前的值。页内没有打开或关闭系统 WLAN 的成功反馈 |

`YoPermissionDenied` 只在用户授权项真正需要去系统设置时使用。上述四项系统授权的 201 用 `YoError`，因为下一步是改安装声明，不是弹出授权窗。

## 依据

- `docs/goal/architecture/wifi-network/WN-001.md` 至 `WN-010.md`
- `docs/goal/checklist/wifi-network.md` 权限与能力
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`
- `common/youi_kit/src/main/ets/components/feedback/YoContentState.ets`
- `common/youi_kit/src/main/ets/components/feedback/YoPermissionDenied.ets`
