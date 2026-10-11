---
id: ui.wifi-network.permissions
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 权限与能力

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
