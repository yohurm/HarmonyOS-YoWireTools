---
id: research.nordicsemiconductor-android-nrf-toolbox
type: project-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [kotlin]
  frameworks: [android, kotlin-ble-library]
also_relevant: []
utilization: [adapt, lesson-only]
source:
  platform: github
  repo: NordicSemiconductor/Android-nRF-Toolbox
  url: https://github.com/NordicSemiconductor/Android-nRF-Toolbox
  head: c7f8e443ab706fe5a2c03368a05488880c8299ed
  cloned_to: "/tmp/YoAgentResearch/NordicSemiconductor--Android-nRF-Toolbox"
studied_at: 2026-10-09
related: [research.synthesis.client-runtime]
---

# NordicSemiconductor/Android-nRF-Toolbox

## 入选理由

它是仍在维护的 BLE 专业工具箱（约 1227 star，本克隆 HEAD 提交说明为 2026-08-26 的依赖升级）。README 把 UART 与 Throughput 列为正式 profile，而不是演示页。连接由单一前台 `ProfileService` 管多设备，和「调试会话不跟页面一起死」的需求同构。通用 GATT 浏览器不在这个仓库里，所以它回答吞吐、UART 宏和日志，不回答任意服务树。

## 项目是什么

Android 容器应用，把 Nordic 的标准 BLE profile 收进一个入口：心率、血压、CSC/RSC、血糖、UART、吞吐、Blinky、Channel Sounding 等。生产连接依赖 Kotlin BLE Library 与 Nordic Common Library（权限、扫描器）。DFU 已从本应用移走，README 指向 Android-DFU-Library 与 nRF Connect Device Manager。

## 架构

- `app/`：首页与扫描入口（`ScannerDestination.kt`、`HomeView.kt` 按 `Profile.UART` 分流）。
- `lib_service/`：`ProfileService` 前台服务。README 写明一个服务管理全部连接；Activity 解绑后连接仍在；断连原因向外发布。
- `profile_manager/`：每个 profile 一个 `ServiceManager`。`ThroughputManager` 绑定固定服务 UUID 与特征 `00001524-0000-1000-8000-00805F9B34FB`，用 `WriteType.WITHOUT_RESPONSE` 按 `maxWriteValueLength` 分片写，再用 `measureTime` 计时，最后 `read()` 取对端统计。测试期间把 `peripheral.logger` 置空，结束再挂回。
- `UARTManager.sendText` 把字符串按 `maxWriteLength` `chunked` 再写。宏、换行和配置在 `profile_data/.../uart/`（`UARTMacro`、`MacroEol`、`UARTConfiguration`）。
- 日志走 nRF Logger API，按设备一份 logger，不是把 logcat 当会话记录。

## 利用价值

| 点 | 方式 | 说明 |
|----|------|------|
| 吞吐与日志互斥 | adapt | 压测时关闭逐包日志，否则吞吐数字失真。HarmonyOS 侧同样应把「记录原始字节」和「测速率」分成两种会话模式。 |
| 按 ATT 载荷分片 | adapt | 分片长度来自当前可写长度，不写死 20。对应 `setBLEMtuSize` 协商结果减 ATT 开销。 |
| UART 预设与通用 GATT 分开 | reuse-pattern | Nordic UART 是快捷路径。任意服务仍走 GATT 浏览器，预设不能替代服务树。 |
| 前台服务保住连接 | lesson-only | Android 前台服务不能抄成 HarmonyOS 实现。后台要走长时任务 `BLUETOOTH_INTERACTION`，见横向总结。 |
| 把 DFU 塞进通用调试台 | anti-pattern | README 已把 DFU 迁出。固件升级是独立危险操作，不属于通用收发。 |

## 架构设计经验

Profile 是插件：发现服务后按 UUID 挂 `ServiceManager`，缺服务要通知观察者，而不是在 UI 里写死特征值。吞吐 profile 还要求特征可写，不满足就失败，不静默改用别的特征。多设备共用一个连接宿主，避免一设备一服务。

## 与当前工作

能直接用的决策：UART 与通用 GATT 分入口；写操作按协商后的载荷分片；吞吐数字与逐包日志分开；断连要带原因。

必须改写的：连接库是 Kotlin BLE，不能把 `CentralManager` / `WriteType` 搬进 ArkTS。HarmonyOS 写类型是 `GattWriteType.WRITE` 与 `WRITE_NO_RESPONSE`。

明确不要用的：本仓库没有 SPP，没有空口抓包，没有通用 GATT 树编辑。目录里残留的 DFU 视图以 README「已移出」为准，不要把 DFU 当成当前产品能力。

## 阅读范围

读过：`README.md`；`profile_manager/.../ThroughputManager.kt`；`profile_manager/.../UARTManager.kt` 的 `sendText` 分片；`app/.../HomeView.kt` 中 UART 分流；profile 视图目录（含 `view/throughput`、`view/uart`）。未读各医疗 profile 的解析器与 Channel Sounding 实现，不据此下结论。
