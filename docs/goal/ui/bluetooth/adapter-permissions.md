---
id: ui.bluetooth.adapter-permissions
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-001, BT-002, BT-003, BT-004, BT-005, BT-006, BT-007, BT-008]
verdict_notes: BT-008 是缺口，没有成功扫描
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-001.md
  - docs/goal/architecture/bluetooth/BT-008.md
  - product/phone/src/main/ets/pages/bluetooth/BluetoothOverviewPage.ets
---

# 适配器与权限

蓝牙 Tab 的根页面。页面是 `BluetoothOverviewPage`，状态在 `BtOverviewViewModel`。数据来自 `common/yobluetooth` 的适配器快照和 `common/debug_core` 的 `PermissionScenario.BLUETOOTH_SCAN_CONNECT`。权限名是 `ohos.permission.ACCESS_BLUETOOTH`。`USE_BLUETOOTH` 不出现在这页（BT-007）。

## 结构

`YoPageShell`，标题「蓝牙」，`destinationKind` 为 `ROOT_TAB`，`scrollable` 为假。内容是纵向 `Column`，间距 `YoResponsive.SECTION_GAP`（`…/组件布局/布局概述.md` 的线性布局）。

自上而下：

1. 状态卡。现有 `BtStatusCard` 放在 `YoImmersiveSurface` 里，只负责材质。卡内一行胶囊加两句说明。
2. 两个入口：`YoModeEntryCard`「经典」和「低功耗」。描述各一行。卡片横排在 `≥600vp`，竖排在更窄宽度。用 `Row` 加 `layoutWeight`，不用栅格组件。
3. 主操作区最多两个 `YoActionButton`：打开或关闭蓝牙（`SECONDARY`），以及在未授权时的再次申请（`PRIMARY`）。开关的真正结果来自系统框之后的状态事件。

胶囊文案只取快照里的状态名：关闭、正在打开、已打开、正在关闭、低功耗打开、低功耗正在打开。只有 `STATE_ON` 时入口卡可进发现和扫描（BT-005）。

## 信息密度

状态卡同时只强调一件事：当前是未授权、未打开、切换中、已打开，或模拟器不可用。已打开时才显示「可发现 / 可扫描」两个短句。不在根页列设备、不列 GATT、不放吞吐。

错误码 2900003 出现在原因行，用户句是「蓝牙关闭」，下一步是打开蓝牙（BT-006）。不把该码渲染成空列表。

## 控件

| 区域 | 符号 | 状态来源 |
| --- | --- | --- |
| 页框 | `YoPageShell` | 标题资源 |
| 整页切换 | `YoContentState` | `YoPageState` |
| 未授权 | `YoPermissionDenied` | `PermissionUiState` |
| 查询中 | `YoLoading` | `YoLoadingStateModel` |
| 开关失败 | `YoError` | 平台码与三层文案 |
| 入口 | `YoModeEntryCard` | 经典 / BLE 是否可进 |
| 开关与申请 | `YoActionButton` | 适配器快照 |
| 状态 | `YoStatusPill` | 状态枚举到语气的映射放在特性页 |

映射：已打开 `success`，切换中 `warning`，关闭 `neutral`，错误 `error`，模拟器不可用 `warning`。模拟器不使用 `success`。

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 已授权且 `STATE_ON`。胶囊「已打开」。两张入口卡可点。主按钮是「关闭蓝牙」 |
| 按下 | 入口卡和按钮按下用 `YoColor.INTERACTIVE_PRESSED` / 按钮已有按下色。松手才发出打开、关闭或进入子页。按下不把状态改成已打开 |
| 禁用 | `STATE_TURNING_ON`、`STATE_TURNING_OFF`、`STATE_BLE_TURNING_ON`、`STATE_BLE_ON` 时，发现和连接入口 `disabled`，原因「尚未完全打开」。按钮 `loading` 时同样不可再点。模拟器上全部蓝牙操作禁用，原因「蓝牙不可用」（BT-008） |
| 空 | 根页不用空态。没有附近设备不是这页的结果 |
| 错误 | 未授权走 `PERMISSION`：标题说明需要蓝牙权限，主操作「授权」，可再次申请（BT-001、BT-002）。用户在系统框拒绝打开后保持关闭，入口仍禁用（BT-003）。用户拒绝关闭后保持已打开（BT-004）。2900001 用 `YoError`，文案「蓝牙服务已停止」 |
| 加载 | 进入页面查询快照时整页 `YoLoading`，文案「正在读取蓝牙状态」。系统框出现后到状态事件到达前，开关按钮为 `loading`，胶囊仍是动作前的状态 |

## 缺口

BT-008：运行环境探针为模拟器时，胶囊为「蓝牙不可用」，语气 `warning`。两张入口卡禁用。页面上没有可点后产生设备的按钮，没有成功扫描的空列表。`common/yobluetooth` 不被调用。这是该缺口的完成态。

## 导航

点「经典」push `/bluetooth/spp`。点「低功耗」push `/bluetooth/ble`。未打开或未授权时卡片不导航。从子页返回仍在蓝牙 Tab。

## 非目标

- 不在这页申请 `PERSISTENT_BLUETOOTH_PEERS_MAC` 或 `MANAGE_BLUETOOTH`。
- 不把星闪或 Wi‑Fi 的开关放进这张状态卡。
