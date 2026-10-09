---
id: research.microsoft-bluetooth-le-explorer
type: project-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [csharp]
  frameworks: [uwp, windows-bluetooth-le]
also_relevant: []
utilization: [adapt, lesson-only]
source:
  platform: github
  repo: microsoft/BluetoothLEExplorer
  url: https://github.com/microsoft/BluetoothLEExplorer
  head: 494ccc99d7e615498af71ecb71ba8945083adb35
  cloned_to: "/tmp/YoAgentResearch/microsoft--BluetoothLEExplorer"
studied_at: 2026-10-09
related: [research.synthesis.client-runtime]
---

# microsoft/BluetoothLEExplorer

## 入选理由

公开源码里，它是结构完整的 GATT 浏览器：广播监视、服务/特征/描述符、十六进制读写、协议错误翻译、本机外设发布。维护停在 2022-09-08（约 294 star），活跃度不如另外三份。仍然入选，是因为 nRF Toolbox 与两个终端都不提供任意 GATT 树，而 Nordic 桌面版 `pc-nrfconnect-ble` 的引擎已不在仓库里。

## 项目是什么

Windows 通用应用。发现 BLE 设备，展开 GATT，读写特征；另有广播监视、信标、虚拟外设和 HID 键盘外设。

## 架构

- `GattSampleContext` 持有 `BluetoothLEAdvertisementWatcher`。`StartAdvertisementWatcher(BluetoothLEScanningMode)` 与 `StopAdvertisementWatcher` 成对。`AdvertisementWatcher_Received` 收广播。
- `ObservableBluetoothLEAdvertisementFilter` 按广播段过滤：`SectionType`、`SectionOffset`、`SectionDataString`，数据格式为 Hex 或 String，再变成 `BluetoothLEAdvertisementBytePattern`。这是「按 AD 结构过滤」，不是只按设备名。
- `ObservableBluetoothLEDevice.FromIdAsync` 连接。`CharacteristicPage` 的写入框在 Hex 模式下逐字校验，非法字符把输入标红，不把非法串送进写调用。
- `GattProtocolErrorParser` 把 ATT 错误译成可读原因：`ReadNotPermitted`、`WriteNotPermitted`、`InsufficientAuthentication`、`InsufficientAuthorization`、`InsufficientEncryption`、`InvalidAttributeValueLength`、`PrepareQueueFull` 等。
- 外设：`VirtualKeyboard` 用 `GattServiceProvider.CreateAsync` 发布 HID 服务，并监听 `AdvertisementStatus`。`GenericGattServiceViewModel.IsPublishing` 表示本机服务是否正在发布。

## 利用价值

| 点 | 方式 | 说明 |
|----|------|------|
| GATT 树与串口预设分开 | reuse-pattern | 浏览器是 BLE 主路径。预设只是匹配成功后的快捷终端。 |
| 广播段过滤器 | adapt | 对应 HarmonyOS `ScanFilter` 的 serviceData / manufactureData 及 mask，外加回调里保留原始 `data`。不要发明任意 AD Type 写入。 |
| ATT 错误人话 | adapt | 对照错误码 2901000–2901007（禁止读/写、未加密、未认证、未授权、服务不存在）显示原因。 |
| Hex 写前校验 | reuse-pattern | 非法 HEX 停在输入框，不发空写或半字节。 |
| 整份 UWP API | lesson-only | `GattServiceProvider` 不是 ArkTS API。本机外设用 `ble.createGattServer` 与 `startAdvertising`。 |

## 架构设计经验

一个上下文对象握住 watcher 与当前设备，页面只观察。过滤条件是数据，不是扫描函数里的 if。协议错误与传输错误分开显示。发布外设要有「正在广播」状态，停止要可观察。

## 与当前工作

能直接用的：服务 → 特征 → 描述符三级；读、写、通知分开；原始值与解析值同时保留；外设发布状态可见。

必须改写的：Windows 扫描模式、配对 UI、HID 服务发布。HarmonyOS 广播不能任意设置 AD Type，字段各自对应固定 Type（见横向总结）。

明确不要用的：不要把 2022 年的 Windows 行为当成 HarmonyOS 限制；不要因为本仓库能做虚拟键盘，就在调试台里做 HID 注入。HID 属于 `ohos.bluetooth.hid`，且错误码 2903050 要求 HID 在前台，超出本次通用调试范围。

## 阅读范围

读过：`ObservableBluetoothLEAdvertisementFilter.cs` 字段区；`GattSampleContext.cs` 中 watcher 启停符号（检索）；`CharacteristicPage.xaml.cs` 的 Hex 校验；`GattProtocolErrorParser.cs` 的错误分支；`VirtualKeyboard.cs` 的 `GattServiceProvider` 发布。未读各标准服务页（心率、血压等）的测量解析。
