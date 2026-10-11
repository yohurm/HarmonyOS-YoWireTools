---
id: ui.bluetooth.advertising-gatt-server
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-062, BT-063, BT-064, BT-065, BT-066, BT-067, BT-068]
verdict_notes: BT-063 是缺口，没有自定义 AD Type 的成功态
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/architecture/bluetooth/BT-062.md
  - docs/goal/architecture/bluetooth/BT-063.md
---

# 广播与 GATT 服务端

路由 `/bluetooth/ble/peripheral`。从 BLE 扫描页的菜单进入。状态放在 `features/bluetooth` 的外围 ViewModel。广播和服务端调用只进 `common/yobluetooth`。

本页是调试台的外围角色，不是星闪广播。

## 结构

`YoPageShell`，`MODULE`，标题「外围」。`YoSegmentButton` 两段：「广播」「服务端」。分段在外层布局里定宽。

广播段，线性表单，间距 `YoResponsive.FORM_GAP`：

- 设备名、服务 UUID、serviceData、厂商数据。四项对应固定 Type：0x09、服务 UUID、0x16、0xFF。
- 只读字节计数，传统模式下上限 31。
- 扩展广播开关。打开后出现「可连接」和「扫描响应」。
- 持续或定时。`duration` 未设或 0 时文案「一直广播，离开会停止」。
- 主按钮「开始广播 / 停止广播」。

服务端段：

- 本地服务列表：服务 UUID，其下特征 UUID 与属性胶囊。
- 请求列表：对端读或写到达后一行，含需要 `sendResponse` 的状态。
- 主按钮「应答」或「发送通知」，取决于选中行。
- 「关闭服务端」用 `DANGER`。

`≥600vp`：左段是表单或服务树，右段是当前广播字节预览或选中请求。

## 信息密度

广播预览只显示四个固定字段和字节数，例如「24 / 31」。不提供 Type 数值输入。扩展广播的互斥写在开关旁：「可连接时不能再带扫描响应」。

服务端请求行：方向、特征 UUID、值的长度、是否已应答。值用等宽，两行省略。通知的值与读响应的值分列，不混成一条日志。

## 控件

| 区域 | 符号 |
| --- | --- |
| 广播 / 服务端 | `YoSegmentButton` |
| 开始、停止、应答、通知 | `YoActionButton` |
| 关闭 | `YoActionButton` `DANGER` |
| 广播中、未应答 | `YoStatusPill` |
| 超长或互斥 | 段内 `YoError` |
| 没有本地服务 | `YoEmpty` |
| 自定义 Type 限制 | `YoStatusPill` `warning` |

文本用系统 `TextInput`。没有自定义 Type 的输入框。

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 未广播。四个字段为空。计数 0 / 31。服务端未打开。限制胶囊可见：「广播类型只有名称、服务 UUID、服务数据和厂商数据」 |
| 按下 | 「开始广播」松手后才提交。「应答」按下只应答选中请求 |
| 禁用 | 扩展广播同时要求可连接和非空扫描响应时，「开始广播」禁用，原因「扩展广播下二者不能同时开启」（BT-064）。服务端未打开时通知禁用。已 `close` 后读写按钮禁用，原因「服务端已关闭」（BT-068） |
| 空 | 服务端已打开但还没有对端请求：请求区 `YoEmpty`「还没有读写请求」。未广播不是空列表，顶栏胶囊是「未广播」 |
| 错误 | 传统广播合计超过 31 字节：失败可见，码 2902054，胶囊不变成「正在广播」（BT-062）。对端订阅因未应答停住时，请求行保持「未应答」，说明若不 `sendResponse` 对端会停在 2900099（BT-066） |
| 加载 | `startAdvertising` 未返回时按钮 `loading`，胶囊仍是「未广播」。成功事件到达后才是 `info`「正在广播」。持续广播在用户停止或离开页面后调用停止，停止完成前按钮是「停止中」（BT-065） |

通知发送成功后，该次值出现在本地发出列表，语气不代替对端是否收到的确认；对端接收不在本机画成成功，除非本页只记录「已调用通知」（BT-067 的本机完成是调用已发出）。

## 缺口

BT-063：页面上没有「自定义 Type」字段，没有 Type 0x01 或其他未列出 Type 的成功路径。限制胶囊保持 `warning`。开始广播的成功只可能来自上述四个固定字段。flags 不能当可写字段。

## 导航

返回 BLE 扫描。离开页面时持续广播停止。服务端关闭是显式按钮；仅返回时 ViewModel 按架构停止持续广播，不在返回时假装服务端仍在应答。

## 非目标

- 不把原始字节拼进广播并显示已发送。
- 不在本页做中心角色的扫描。
