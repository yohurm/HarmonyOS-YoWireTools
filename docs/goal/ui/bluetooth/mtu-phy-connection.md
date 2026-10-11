---
id: ui.bluetooth.mtu-phy-connection
type: ui-design
status: draft
when: design
phase: C
checklist: [BT-080, BT-081, BT-082, BT-083, BT-084, BT-085]
verdict_notes: BT-084 的数字间隔是缺口。三档枚举可以成功。BT-085 待证，不画 PHY 已切换
related:
  - docs/goal/ui/bluetooth/index.md
  - docs/goal/ui/bluetooth/gatt-client.md
  - docs/goal/architecture/bluetooth/BT-080.md
  - docs/goal/architecture/bluetooth/BT-084.md
  - docs/goal/architecture/bluetooth/BT-085.md
---

# MTU、PHY 与连接参数

这块在 GATT 客户端页的右栏或窄屏的下一段，不单独占一个 Tab。状态仍由 `BleMainViewModel` 展示。协商和三档参数只进 `common/yobluetooth` 的 `GattClientDataSource`。

## 结构

三段 `Column`，段间距 16vp。每段一个小标题（`YoTypeStyle.SUBTITLE_S`）加一行事实加操作。

1. MTU。只读当前值。输入框请求新值。主按钮「协商」。说明行「范围 23 到 517。未协商时是 23」。
2. 连接参数。`YoSegmentButton` 三档：低功耗、均衡、高速率。旁边一句限制：「没有间隔、从机延迟、监督超时的数字」。API 22 以下整段禁用。
3. PHY。只读一行「待证」。没有 1M / 2M / Coded 的选中结果，没有「应用」按钮。

无响应写的分段不在本段操作，在客户端写操作和日志里显示段数。本段只展示当前 MTU，供分段使用（BT-083）。

## 信息密度

当前 MTU 用大号 `TITLE_S` 加单位「字节」，保证调试时一眼能读到。请求值用等宽输入。协商中不把请求值写进「当前」。事件到达后当前值改为事件里的值，可以小于请求值，旁边用 `BODY_S` 写「请求 185，结果 158」这类对照（BT-082）。

三档分段的选中项表示「将要提交」或「最近一次已提交的枚举」。不把档位换成毫秒。

PHY 区固定两行：第一行胶囊「待证」，第二行「没有设备证据之前不读取、不切换」。

## 控件

| 区域 | 符号 |
| --- | --- |
| 协商、提交三档 | `YoActionButton` |
| 三档 | `YoSegmentButton` |
| 当前 MTU、待证 | `YoStatusPill`：MTU 已有值 `info`，协商中 `warning`，PHY `warning` |
| 越界 | 输入下错误文案，`YoColor.ERROR` |
| 未连接 | 整区禁用，原因在客户端连接条 |

## 状态

| 状态 | 本屏 |
| --- | --- |
| 默认 | 已连接，未协商。当前 MTU 显示 23（BT-080）。三档停在均衡，尚未提交时不显示「已更新」。PHY 为待证 |
| 按下 | 「协商」和三档的「应用」松手后才提交。PHY 区没有可按下的切换 |
| 禁用 | 未连接时全部禁用。请求小于 23 或大于 517 时「协商」禁用，原因「范围是 23 到 517」（BT-081）。API 22 以下三档禁用，原因「当前系统没有连接参数枚举」。数字间隔没有输入框，因此没有可启用的数字提交（BT-084） |
| 空 | 未连接时不使用空态代替禁用。没有「暂无 MTU」这种会把 23 藏起来的空画面 |
| 错误 | 协商调用失败：当前值保持事件确认过的值，没有事件则保持 23，`YoError` 给出平台原因。三档调用失败：分段回到上一次成功枚举，失败原因可见。不把失败显示成毫秒已更新 |
| 加载 | `setBLEMtuSize` 已返回但 `BLEMtuChange` 未到：胶囊「协商中」，当前数字不变（BT-082）。三档请求未返回时该分段按钮 `loading`，不提前打勾 |

三档调用成功是支持项：成功后胶囊写「已提交：均衡」这类枚举名，不写毫秒。

无响应写按当前 MTU 载荷分段、段间不并发。段数出现在会话日志，不在本区画成 PHY 变化（BT-083）。

## 缺口

BT-084：完成态是三枚枚举。页面不出现连接间隔、从机延迟、监督超时三个数字框，也不出现「已按 7.5 ms 更新」的成功胶囊。

## 待证

BT-085：PHY 区保持「待证」。不显示已切换到 2M 或 Coded。不把扫描占空或广播 PHY 显示成连接 PHY。本阶段不放置会调用 `readPhy` 或 `setPhy` 的按钮。将来若证据返回 801，也只把胶囊改为「当前设备不支持」，仍然不是已切换。

## 导航

本区随客户端页返回而离开。不单独登记为星闪或网络的子页。

## 非目标

- 不预画 PHY 成功序列。
- 不把请求 MTU 在事件到达前写成当前 MTU。
