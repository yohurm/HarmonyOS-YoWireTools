---
id: research.kai-morich-simple-bluetooth-terminal
type: project-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [java]
  frameworks: [android]
also_relevant: []
utilization: [adapt, lesson-only]
source:
  platform: github
  repo: kai-morich/SimpleBluetoothTerminal
  url: https://github.com/kai-morich/SimpleBluetoothTerminal
  head: 688a628e04cea5c1e7ce253229a5feb90d104ea9
  cloned_to: "/tmp/YoAgentResearch/kai-morich--SimpleBluetoothTerminal"
studied_at: 2026-10-09
related: [research.kai-morich-simple-bluetooth-le-terminal, research.synthesis.client-runtime]
---

# kai-morich/SimpleBluetoothTerminal

## 入选理由

它是仍在维护的经典蓝牙 SPP 终端（约 584 star，HEAD 为 2026-04-12，API 36）。代码量小，边界清楚：已配对列表、RFCOMM 套接字、终端、后台队列。它故意不做 Inquiry。这正好标出「SPP 调试」和「经典发现」是两件事。

## 项目是什么

Android 终端，用标准 Serial Port UUID 连接已配对的经典蓝牙设备，收发字节。菜单提供清屏、换行（CRLF / LF）、HEX 输入、后台通知开关。

## 架构

- `DevicesFragment.refresh()` 只遍历 `BluetoothAdapter.getBondedDevices()`。全仓库 Java/XML 没有 `startDiscovery`。
- `SerialSocket` 固定 `00001101-0000-1000-8000-00805F9B34FB`，`createRfcommSocketToServiceRecord` 后在工作线程 `connect()`。读循环用 1024 字节缓冲，`Arrays.copyOf(buffer, len)` 把一次 `read` 原样交给监听者。
- 构造函数拒绝 Activity 作 Context，套接字绑在 Service。`ACTION_ACL_DISCONNECTED` 一类广播触发 `background disconnect`，立刻 `disconnect()`，不把错误排队到界面回来。
- `SerialService` 前台服务。界面不在前台时，连接/读/错误进 `queue1`/`queue2`，回到前台再刷。`write` 在未连接时抛 `not connected`。
- `TextUtil.HexWatcher` 约束 HEX 输入。`TerminalFragment` 默认换行 `newline_crlf`。

## 利用价值

| 点 | 方式 | 说明 |
|----|------|------|
| 一次 read 即一段字节 | reuse-pattern | 不做业务分包。日志保存这次回调的原始长度，显示层再决定如何拼行。 |
| 已配对才进 SPP | adapt | 经典 SPP 依赖配对。发现与配对是另一条链路，连上之前必须先停发现。 |
| 固定标准 UUID | lesson-only | 本应用不能改 UUID。调试台需要标准 UUID 默认值，同时允许自定义 UUID，因为 HarmonyOS `sppConnect` 的 UUID 必须与对端注册值一致。 |
| 后台双队列 | adapt | 离开页面时字节不能丢，也不能在界面线程上读。HarmonyOS 用会话队列加长时任务，不抄 Android Service。 |
| 把发现和 SPP 写在同一个按钮里 | anti-pattern | 本仓库把发现留在系统设置。若产品要发现，必须单独停止扫描后再连接。 |

## 架构设计经验

套接字线程与界面分离；未连接的写立即失败；后台断开立即拆连接，避免回到前台才看到半开套接字。HEX 与文本是显示/输入模式，线上仍是字节。

## 与当前工作

能直接用的：标准 SPP UUID 作为默认；原始字节日志；未连接不可写；清屏只清显示不改链路。

必须改写的：没有自定义 UUID、没有服务端、没有发现。HarmonyOS 用 `socket.sppConnect` / `sppListen`，地址是虚拟 MAC，配对走 `connection.pairDevice` 与系统对话框。

明确不要用的：不要假设系统里已经配对就等于本应用可以跳过配对引导；不要用 Android `createRfcommSocketToServiceRecord` 的通道号猜测去对 HarmonyOS SDP。

## 阅读范围

读过：`SerialSocket.java` 全文；`DevicesFragment.java` 的方法列表与 `getBondedDevices`；`SerialService.java` 的队列与 `startForeground`；`menu_terminal.xml`；`TextUtil.java` 的换行常量与 `HexWatcher` 类声明。未读布局 XML 与图标资源。
