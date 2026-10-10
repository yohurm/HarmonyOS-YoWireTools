---
id: research.nearlink-debug
type: topic-study
status: active
when: research
stack:
  capability: client-runtime
  languages: [ArkTS, C++, Kotlin, JSON]
  frameworks: [HarmonyOS NearLink Kit, OpenHarmony NearLink, Android BLE]
also_relevant: [ui-kit]
utilization: [adapt, lesson-only, anti-pattern]
source:
  platform: github
  url: https://github.com/yohurm/HarmonyOS-Developer-docs
  repos:
    - HarmonyOS_Samples/nearlink-kit_-sample-code
    - openharmony/communication_nearlink_service
    - MiraHikari/nearlink-firmwares
    - NordicSemiconductor/Android-nRF-Toolbox
  cloned_to:
    - /tmp/YoAgentResearch/yohurm--HarmonyOS-Developer-docs
    - /tmp/YoAgentResearch/HarmonyOS_Samples--nearlink-kit_-sample-code
    - /tmp/YoAgentResearch/openharmony--communication_nearlink_service
    - /tmp/YoAgentResearch/MiraHikari--nearlink-firmwares
    - /tmp/YoAgentResearch/NordicSemiconductor--Android-nRF-Toolbox
studied_at: 2026-10-09
related: [docs/goal/checklist/nearlink.md]
---

# 星闪专业调试能力

## 总则

本文只覆盖 HarmonyOS 星闪（NearLink / SLE）专业调试与测试能力：发现、过滤、角色、配对、SSAP 与端口收发、吞吐与拥塞、报文检查、重连、日志、权限和与蓝牙的边界。结论给后续实现引用，本阶段不改产品代码。

官方规范以镜像仓 `yohurm/HarmonyOS-Developer-docs` 的 `1d85fab`（2026-10-09）为准。应用侧主文档是 NearLink Kit；Connectivity Kit 下的 `@ohos.nearlink.*` 与「星闪常见问题」仍保留随机地址等约束，两套同时引用时以 NearLink Kit API 参考的字段表为准。

## 背景

星闪调试工具要回答的问题与 nRF Toolbox 一类无线调试器相同：设备是否可见、过滤是否生效、链路是否连上、属性或字节是否按预期往返、失败时错误码是什么、日志能否复现。星闪公开应用调试器很少，芯片侧更常见的是串口 AT 工具和实验室综测仪。因此入选名单同时包含官方示例、协议栈、星闪工具箱命令目录，以及 BLE 专业调试器作同类能力对照。

本仓库 `features/nearlink` 目前只有空的页壳，领域模型里已有扫描过滤草稿。下文把它当上下文，不把它当架构。

```mermaid
flowchart LR
  A["能力与权限"] --> B["扫描或广播"]
  B --> C["配对与 ACB"]
  C --> D["SSAP 或端口"]
  D --> E["收发与日志"]
```

## 关键结论

应用能做成的调试面，和专业无线分析仪能做成的调试面，边界在 Kit 是否暴露该字段。

| 能力 | 应用 Kit 现状 | 版本门槛 | 调试含义 |
| --- | --- | --- | --- |
| 是否支持星闪 | `manager.isNearLinkSupported()` | 6.1.0(23) | 更早系统靠调用返回 801 判断 |
| 开关 | `getState` / `stateChange`，四态 | 5.0.1(13) | 应用不能代开星闪 |
| 权限 | `ohos.permission.ACCESS_NEARLINK`，normal，user_grant | 权限起始版本 12 | 未授权返回 201 |
| 扫描 | `startScan` / `stopScan` / `deviceFound` | 5.0.1(13)；`filters` 允许 null 自 26.0.0 | 5.0.1 全空过滤返回 401 |
| 扫描过滤字段 | 地址、设备名、厂商 ID、厂商数据及掩码；RSSI 门限 | RSSI 门限自 26.0.0 | 组间或、组内与 |
| 扫描模式 | 仅低功耗、均衡 | 5.0.1(13) | 协议栈另有低时延等模式，应用枚举未公开 |
| 广播 | `startAdvertising` 返回广播 ID | 5.0.1(13) | 外围角色可用，不是缺失 API |
| SSAP 客户端 | 连接、服务、读写、通知、MTU | 5.0.1(13) | MTU 请求范围 [22, 512]，默认 256。一个应用针对一个远端设备只需要创建一次 Client 实例 |
| SSAP 服务端 | 加服务、读写请求、响应、通知 | 5.0.1(13) | 一个应用针对一个远端设备只需要创建一次 Server 实例 |
| 端口数传 | `createPort` / `connect` / `writeData` / `readData` | 5.1.0(18) | 两端 UUID 必须相同；任一端可发起连接 |
| 端口 MTU | `ConnectionParams.mtu`，范围 [0, 65535]，默认 512 | 5.1.0(18) | 与 SSAP MTU 不是同一范围 |
| 加密 | 数传默认不保证加密；`getAcbState` 的 `ENCRYPTED` 才算已加密 | ACB 自 5.1.0(18) | 配对走系统弹窗 |
| 已配对列表 | `getPairedDevices()` | 6.0.1(21) | 应用 API 没有解除配对 |
| 设备信息 | `getDeviceInformation()` 厂商与型号 | 6.1.1(24) | 名称截断不能只看 `deviceName` |
| 模拟器 | Kit 明确不支持 | 全版本 | 必须真机 |
| 空口抓包 | 应用 Kit 无星闪 HCI/空口日志 | 缺口 | 蓝牙 HCI 日志不能当作星闪抓包 |

设备范围：Phone、PC/2in1、Tablet、TV、Wearable。系统能力 `SystemCapability.Communication.NearLink.Core`。接口仅 Stage 模型。

标准 16 比特服务 UUID 展开后的 128 比特基础标识是 `37BEA880-FC70-11EA-B720-000000000000`，后 16 比特由星闪联盟分配。扫描指南示例里的 `FFFFFFFF-1234-5678-ABCD-...` 是示例占位，不能当成标准基。

## 能力映射

下表把调试器常见能力落到 Kit。「缺口」表示应用按文档无法直接做到，界面必须标明，不能显示成已测量或已加密。

| 调试能力 | 行业对照 | HarmonyOS 落点 | 结论 |
| --- | --- | --- | --- |
| 发现列表 | nRF Toolbox 按设备维持连接与状态；官方示例按 `deviceFound` 列名称和地址 | `ScanResults.address/deviceName/rssi/data/isConnectable`，5.1.0(18) 起可选 `deviceClass` | 可做。RSSI 127 表示无效 |
| 名称过滤 | 芯片 AT `AT+SLESTARTSCAN` 前可设扫描参数；官方示例只填 `deviceName` | `ScanFilters.deviceName`，长度 [0, 30] | 可做。名称以服务数据 TLV 为准时，完整本地名过滤会扫不到 |
| 地址过滤 | AT `AT+SLECONN` 带地址类型 | `ScanFilters.address` | 可做。地址是随机地址 |
| 厂商数据过滤 | 原生 `SleScanFilter` 与应用字段一致 | `manufacturerId` [1, 65535]，数据与掩码等长 | 可做 |
| 服务 UUID 过滤 | 原生过滤器有 `SetServiceUuid` 与掩码、Solicitation UUID、Service Data | 应用 `ScanFilters` 无这些字段 | 缺口。收到 `data` 后自行解析 |
| RSSI 门限 | nRF 类工具常按 RSSI 排序；AT 有 `AT+SLEREADPEERRSSI` | 扫描门限自 26.0.0，含义是大于等于门限才上报 | 低版本只能在结果里后滤。连接后读 RSSI 是缺口 |
| 扫描占空比 | AT `AT+SLESETSCANPAR` 有 interval/window；原生 `SCAN_MODE` 有低时延和多档 OP | 应用只有两种 `ScanMode` 加可选 `duration` [10, 60] 秒 | 缺口：不能配置窗口。默认不填 duration 为全时段扫描 |
| 低时延扫描 | 原生 `SCAN_MODE_LOW_LATENCY = 0x02` | 应用枚举只有 0 和 1 | 缺口。官方示例 `scanMode: 2` 不能当公开契约 |
| 角色 | 中心扫描连接，外围广播；端口两端对等 | `scan` 与 `advertising`；SSAP Client/Server；`dataTransfer` 不分客户端 | 可做。手机/平板/PC 之间不能靠系统设置界面维持连接 |
| 配对 | AT 有 `AT+SLEPAIR` / `AT+SLEUNPAIR` | `startPairing`、`getPairingState`、配对原因与类型 | 配对可做。解除配对是缺口 |
| SSAP 浏览 | 类似 GATT 浏览器，粒度是 Service/Property | `getServices`，Property 含 UUID、值、operation 位 | 可做。没有独立 Handle 字段 |
| 读写与通知 | nRF UART 按特征写、按通知收 | `readProperty` / `writeProperty` / `setPropertyNotification` / `propertyChange` | 通知五条件缺一则收不到；断线后通知失效 |
| 端口终端 | 星闪工具箱串口终端的近场对应物 | `writeData` / `readData`，模式 `BASIC` 或 `RELIABLE` | 可做。连续写建议间隔 10ms，拥塞码 `1009700023` |
| 吞吐 | nRF Throughput 统计写入次数、字节和 bps | Kit 无吞吐接口 | 缺口。只能用本端收发时间戳估算，并标明是应用层估算 |
| 空口帧检查 | 蓝牙开发者选项 HCI 日志；实验室 SL6230 | 应用只能看广播 `data`、属性值和端口载荷 | 缺口：无星闪空口抓包 |
| 重连 | nRF `ProfileService` 把断连原因交给 UI | 无自动重连接口。断线后重新 `connect`，并重新打开通知 | 可做应用侧重连。不能宣称系统会自动重连 |
| 日志 | nRF Logger 按设备一份日志 | 本仓库 `common/debug_core` 已有会话与日志类型 | 星闪事件写入统一日志，不另造日志库 |
| 与蓝牙共存 | 设置路径有时写作「星闪和蓝牙」；FAQ 把两边 MTU 分开写 | 无共存仲裁、无共享天线状态 API | 缺口。蓝牙 HCI 日志不覆盖星闪 |

## 入选项目

Top 4。相关度优先于 Star。穿戴扫描示例已克隆并阅读，因只覆盖扫描且含反例，放入落选备忘。

### HarmonyOS_Samples/nearlink-kit_-sample-code

**入选理由：** 指南把扫描、SSAP、广播、端口示例指到这个仓库，它是应用侧唯一完整的官方路径。

**项目是什么：** HarmonyOS 示例工程。页面为 `ScanConfigPage`、`MainPage`、`SsapClientPage`、`SsapServerPage`。HEAD `f70be9ba`（2026-03-18）。

**架构：** `Index` 在进入时调用 `requestPermissionsFromUser`，权限名只有 `ACCESS_NEARLINK`。扫描页用一个 `deviceName` 过滤器调用 `startScan`。服务端页发广播并 `createPort` 后等对端连接；客户端页 `createClient`、发现服务，同时 `createPort` 再 `connect`。端口连接参数把 `mtu` 写成 1024。日志使用 `hilog`，成功失败多用 Toast。

**利用价值：**

| 点 | 方式 | 说明 |
| --- | --- | --- |
| 权限只申请星闪 | adapt | 与穿戴示例同时申请蓝牙权限对照，星闪调试不应捆绑 `ACCESS_BLUETOOTH` |
| 过滤数组与组内字段 | adapt | 注释写明数组可多项，单项可带地址和名称 |
| 端口两端都要 `createPort` | adapt | UUID 常量两边一致 |
| `scanMode: 2` | anti-pattern | 公开 `ScanMode` 只有 0 和 1。2 对应原生低时延，不是应用文档值 |
| `usedScene.abilities` 写成 `EntryFormAbility` | anti-pattern | 模块里的 Ability 名是 `EntryAbility`，不要照抄 |
| 不查 `isNearLinkSupported`、不看 ACB | lesson-only | 示例能跑通演示，不能当作加密和能力探测的完成态 |

**架构经验：** 官方示例把 SSAP 和端口写在同一页。调试工具应把两条传输分成可独立开关的会话，否则用户无法判断失败发生在属性协议还是端口。

**与当前工作：** `features/nearlink` 的空页不能从该示例直接堆 UI。可复用的是调用顺序：先权限，再订阅，再 `startScan`；端口先注册再连接。必须改写扫描模式常量。明确不要用示例里的 16 比特 UUID 拼接方式，标准基以常见问题文档为准。

**阅读范围：** `entry/src/main/module.json5`，`pages/Index.ets`、`ScanConfigPage.ets`、`SsapClientPage.ets`（`createPort` 至 `transferData`），并用检索确认 `SsapServerPage.ets`、`MainPage.ets` 含 `startAdvertising`。未逐行读完服务端属性表构造。

### openharmony/communication_nearlink_service

**入选理由：** 应用 Kit 没写的过滤器、扫描模式和端口号池，在这份协议栈里能看到边界。HEAD `745c523c`（2026-09-30）。

**项目是什么：** OpenHarmony 星闪服务。扫描、广播、SSAP、数传、CDSM、HID、测距头文件都在 `interfaces/inner_api/include`。

**架构：** `SleScanFilter` 除地址、名称、厂商数据外，还有服务 UUID 及掩码、Solicitation UUID、Service Data 及掩码、RSSI 门限。`SCAN_MODE` 从 `LOW_POWER`、`BALANCED`、`LOW_LATENCY` 一直到多档 `OP_*` 和 `FULL_SCAN`。`SleDataTransferService::CreatePortInner` 从本地端口号 `30300` 分配到 `40959`，池耗尽时返回 0。连接等待超时常量是 11000ms。这些是服务内部实现，不是应用 API 契约。

**利用价值：**

| 点 | 方式 | 说明 |
| --- | --- | --- |
| 过滤器比应用多的字段 | lesson-only | 用来标缺口，不在应用里调用 inner API |
| 扫描模式多于两种 | lesson-only | 解释官方示例数字 2 的来源，同时禁止把它写成公开模式 |
| 端口号池 30300–40959 | anti-pattern | 不能写成「应用最多注册 10660 个端口」。应用错误码只说超上限，不公布个数 |
| HID、测距、TWS 头文件 | lesson-only | `@kit.NearLinkKit` 参考目录没有这些模块 |

**架构经验：** 调试器只依赖 ArkTS Kit。协议栈多出来的能力记成缺口，避免用 native 枚举填应用参数。

**与当前工作：** `NearLinkScanFilter` 草稿里的 `LOW_LATENCY` 与原生值 2 同名，但应用 `ScanMode` 文档没有这一项。后续实现只能提交文档中的两种模式；低时延保持为未公开能力。

**阅读范围：** `interfaces/inner_api/include/nearlink_sle_scanner.h` 的 `SleScanFilter`，`interfaces/def/nearlink_def.h` 的 `SCAN_MODE`，`services/service/src/datatransfer/nearlink_sle_datatransfer_service.cpp` 的端口常量与 `CreatePortInner`。未读 HID/测距实现体。

### MiraHikari/nearlink-firmwares

**入选理由：** 公开仓库里最接近「星闪工具箱」的维护项目。它覆盖的是芯片串口调试，不是手机空口调试。HEAD `79f09f6c`（2025-05-01）。桌面程序源码不在该仓库。

**项目是什么：** 固件包、说明和串口命令 JSON。README 描述 Tauri 工具的串口调试、帧速率、AT 快捷命令和烧写。本轮读到的是命令目录，不是那个桌面程序。

**架构：** 命令集按分类存放。`Hihope HH-D03 多命令集合 专业版.json` 中星闪相关命令包括 `AT+SLEENABLE`、广播参数与数据、扫描参数（interval/window）、扫描起停、名称与地址、连接与断开、PHY、配对、解除配对、已配对查询、连接参数更新、读对端 RSSI、断开全部。

**利用价值：**

| 点 | 方式 | 说明 |
| --- | --- | --- |
| 命令名、分类、参数、快捷键 | adapt | 端口终端的命令收藏可沿用「分类 + 参数说明 + 原文」 |
| 扫描 interval/window、PHY、解除配对、读 RSSI | lesson-only | 这些是模组 AT 能力，手机 Kit 没有对应接口 |
| 把串口 AT 当成星闪空口日志 | anti-pattern | 串口字节是模组控制面，不是 `ScanResults.data` |

**架构经验：** 专业调试要同时承认两条链路：手机应用对另一台星闪设备，以及开发板串口对模组。本模块范围是前者。AT 命令集可以作为「发送收藏」的数据形状，不能当成 Kit 封装。

**与当前工作：** `common/debug_core` 已有 `CommandTemplate`。星闪命令收藏应复用它，载荷走端口或 SSAP 写，而不是假设本机有 AT 串口。

**阅读范围：** 仓库 `README.md` 目录说明，`firmwares/hihopehhd03at/Hihope HH-D03 多命令集合 专业版.json` 的分类与 `AT+SLE*` 命令名。未运行桌面程序，也未读烧写工具二进制。

### NordicSemiconductor/Android-nRF-Toolbox

**入选理由：** 星闪专用的手机调试器公开源码稀缺。nRF Toolbox 是仍在维护的专业 BLE 调试器，UART、吞吐和按设备日志直接对应本模块要做的终端能力。HEAD `c7f8e443`（2026-08-26）。

**项目是什么：** 一个前台 `ProfileService` 管多设备 BLE 连接，UI 解绑后连接仍在。配置文件包括 UART 和 Throughput。日志进 nRF Logger，每台设备一份。

**架构：** `UARTManager` 找到 RX/TX 特征，订阅通知，`sendText` 按 `maxWriteLength` 切片后写入，并记录方向、文本和字节数。`ThroughputMetrics` 记录 GATT 写次数、累计字节和 bps。宏是「图标 + 命令文本 + 行尾」。

**利用价值：**

| 点 | 方式 | 说明 |
| --- | --- | --- |
| 收发日志带方向和字节数 | adapt | 对应 `debug_core` 的 `Direction` 与 `LogRecordType.BYTES` |
| 按 MTU/协商长度切片 | adapt | SSAP 以协商 MTU 为上限；端口以 `ConnectionResult.mtu` 为上限 |
| 吞吐由计数器计算 | adapt | 星闪没有吞吐 API，指标必须标成应用层估算 |
| 宏命令 | adapt | 与工具箱命令收藏同一类需求 |
| 前台服务保活多连接 | lesson-only | 星闪后台策略官方未写扫描能否进后台。不能照搬 Android 前台服务 |
| UART 特征 UUID | anti-pattern | Nordic UART UUID 不是星闪 SSAP UUID |

**架构经验：** 调试器把「传输会话」和「配置文件解析」分开。星闪同样应把端口字节流、SSAP 属性树分成两种会话，解析器只吃字节，不调用 Kit。

**与当前工作：** 会话状态已有 `CREATED` 到 `CANCELLED`。星闪连接态还要映射 Kit 的 `STATE_CONNECTING/CONNECTED/DISCONNECTING/DISCONNECTED`，以及 ACB 的 `ENCRYPTED`。不要把 BLE GATT 句柄模型抄进 SSAP。

**阅读范围：** `README.md` 的 ProfileService 与 UART 说明，`UARTManager.kt`，`UARTMacro.kt`，`ThroughputMetrics.kt`。未读心率等标准 Profile 解析器。

## 横向总结

### 本层已研项目

| 仓库 | 一句话 | 利用方式 |
| --- | --- | --- |
| HarmonyOS_Samples/nearlink-kit_-sample-code | 官方应用调用顺序 | adapt，扫描模式数字 2 排除 |
| openharmony/communication_nearlink_service | 应用未公开的过滤与模式 | lesson-only |
| MiraHikari/nearlink-firmwares | 模组 AT 与命令收藏形状 | adapt 收藏结构 |
| NordicSemiconductor/Android-nRF-Toolbox | 终端、切片、吞吐和分设备日志 | adapt 会话日志 |

### 共同架构经验

调试会话都分成发现、连接、传输、日志四段。过滤在扫描开始前生效；传输失败要留下错误码而不是只 Toast。身份不能只靠一次扫到的地址。大流量和小数据用不同通道：星闪文档把小数据给 SSAP，把大流量给端口。

### 分歧与取舍

| 题目 | 分歧 | 取舍 |
| --- | --- | --- |
| 扫描模式 | 示例传 2，文档只有 0 和 1，协议栈还有更多档 | 应用只提供文档中的两种 |
| UUID 基 | 指南示例用占位前缀，常见问题给出联盟基 | 16 比特标准服务用 `37BEA880-FC70-11EA-B720-000000000000` |
| 谁是客户端 | SSAP 有客户端/服务端；端口对等 | 界面分开写，端口不显示「客户端角色」 |
| 加密默认值 | 数传指南写明不保证加密 | 未读到 `ENCRYPTED` 时显示未加密或未验证，发送敏感数据前由用户选择阻止 |
| 吞吐 | 芯片 AT 能设 PHY；nRF 能算 bps；Kit 不能 | 只显示本端字节计数和时间，并写明不是空口速率 |
| 保活 | Android 前台服务可留连接 | 星闪扫描在本仓库背景策略里是离开即停。官方没有后台扫描专章，不把 Android 保活写成星闪能力 |

### 对本知识库规则的候选修订

只记录，不改 YoAgentDocs。

- 星闪 16 比特 UUID 展开必须使用联盟基础标识，指南代码块里的占位前缀需要在实现规范里点名排除。
- 应用扫描模式与 OpenHarmony `SCAN_MODE` 不是同一枚举，不能按数值透传。

### 入选与落选备忘

入选四项见上。落选：

| 对象 | 原因 |
| --- | --- |
| Explore-In-HMOS-Wearable/how-to-scan-nearby-devices-by-nearlink-kit | 已克隆（HEAD `38464796`）。只做厂商 ID 扫描和按地址合并，同时申请蓝牙权限，不解析广播。与官方示例能力重叠，留作反例 |
| hufeidev/nearlink | 描述为 NearLink tool，无星、2025-03 后无更新，未克隆 |
| OpenSparklink/nearlink_sdr_sim | 体积大，面向 SDR 仿真，不是手机调试器 |
| 智网信测 SL6230 | 实验室射频/协议一致性系统，公开页可见，无源码 |
| 星闪工具箱桌面程序本体 | `nearlink-firmwares` 不含 Tauri 源码，不把 README 功能表写成已读实现 |

## 与当前工作

能直接用的：

- `common/platform` 已声明 `ohos.permission.ACCESS_NEARLINK`，并有权限编排。星闪在用户触发扫描、连接或广播时申请，拒绝后入口保持不可用。
- `common/debug_core` 已有星闪权限场景、扫描与数传的后台类别、会话状态和字节日志类型。
- `common/core` 的 `Result`、串行队列和单调时钟够用来做扫描结果合并、写队列和耗时，不必新造基础类型。
- `NearLinkConstants` 里的 SSAP MTU [22, 512]、无效 RSSI 127、扫描时长 [10, 60]、拥塞码 `1009700023` 与 API 参考一致。

必须改写的：

- `NearLinkScanMode.LOW_LATENCY` 不在应用 `ScanMode` 文档中。
- 过滤草稿把「名称包含」做成结果后滤。Kit 的 `deviceName` 过滤是扫描条件本身，空过滤器在 5.0.1(13) 会 401。两套规则要分开：系统过滤失败与本地后滤不是同一条错误。
- `features/nearlink` 页是空壳。官方示例的页面写法不能直接搬进来。

明确不要用的：

- 不要把 PR #1 的空页或 `.projectark` 里的预留分层当成本次已验证架构。
- 不要调用 OpenHarmony inner API 补服务 UUID 过滤、PHY、解除配对或连接后 RSSI。
- 不要把蓝牙 HCI 日志、Nordic UART UUID、AT 串口字节当成星闪空口证据。

当前 HAR 的 `deviceTypes` 写的是 `default`、`tablet`、`2in1`。Kit 还列出 TV 与 Wearable。这是工程设备类型配置，不是 Kit 能力消失。

## 错误码与失败路径

应用特有码（镜像 `开发/API参考/系统/网络/NearLink Kit（星闪服务）/ArkTS API/ArkTS API错误码.md`；该页标注官网已下线，镜像仍保留正文）：

| 码 | 信息 | 调试器应留下的结果 |
| --- | --- | --- |
| 201 | Permission denied | 未授权。提供再次申请或前往设置的入口 |
| 401 | Invalid parameter | 参数不合法。扫描全空过滤、厂商数据与掩码不等长、MTU 越界都走这里 |
| 801 | Capability not supported | 设备或系统能力不支持。与「开关关闭」分开显示 |
| 1009700003 | NearLink is off | 开关关闭。引导到设置里的星闪，而不是蓝牙开关 |
| 1009700020 | UUID 已注册 | 先 `destroyPort` 再注册 |
| 1009700021 | 端口数量超上限 | 销毁不用的端口。不显示虚构的个数上限 |
| 1009700022 | UUID 未注册 | 销毁前先确认已注册 |
| 1009700023 | 写入拥塞 | 停止连发，按至少 10ms 间隔重试，并把拥塞记入日志 |
| 1009700050 | 不支持合作设备集 | CDSM 不是通用调试前提 |
| 1009700099 | Operation failed | 含已配对再次 `startPairing`。展示码与 `reasonMsg`（26.0.0 起，仅日志） |

SSAP `requestMtuSize` 必须在连接成功之后调用，否则可能得到 `1009700099`。范围外同样失败。

## 广播与名称

`ScanResults.data` 按类型解析。指南给出的类型包括发现等级 `0x01`、16/128 比特服务数据、完整与不完整服务 UUID 列表、缩短名 `0x0A`、完整本地名 `0x0B`、厂商数据 `0xFF`。长度为零或类型未知时保留原始字节。

设备名只有 9 个字符时，常见原因是设备信息管理服务（UUID `0x0609`）里本地名称 TLV 的长度写成 `0x09`，系统以这段服务数据覆盖 `0x0B`。过滤完整期望名会失败，过滤被截断的 9 字符会成功。调试器要同时显示 `deviceName` 和从原始广播解析出的 `0x0B`，两者不一致时两条都留下。

随机地址：扫描上报的是随机地址。映射存续期内不变，已配对设备的映射长期保留，映射清除后再次扫描会变。收藏和长期身份要同时保存名称、设备类型、配对关系和最近一次地址。连接使用当前扫描地址。

## 来源与阅读范围

镜像 HEAD `1d85fab`。实际阅读的仓库相对路径：

- `开发/指南/开发/系统/网络/NearLink Kit（星闪服务）/` 下简介、开发准备、是否支持、开关、扫描、广播、数传、SSAP 客户端、SSAP 服务端、常见问题、合作设备集合指南标题
- `开发/API参考/系统/网络/NearLink Kit（星闪服务）/ArkTS API/` 下 scan、ssap、dataTransfer、manager、remoteDevice、constant、advertising、cdsm、错误码
- `开发/指南/系统/网络/Connectivity Kit（短距通信服务）/星闪常见问题.md`（随机地址、端口角色、设置界面连不上）
- `开发/FAQ/系统开发/网络/星闪（NearLink）/解决星闪扫描的设备广播名称只有9个字符长度的问题.md`
- `开发/FAQ/系统开发/网络/短距通信（Connectivity）/如何解决蓝牙／星闪协商MTU参数失败的问题.md`
- `开发/指南/系统/网络/Connectivity Kit（短距通信服务）/蓝牙/蓝牙常见问题/如何抓取蓝牙HCI日志/如何抓取蓝牙HCI日志.md`
- `开发/指南/开发/系统/安全/程序访问控制/应用权限管控/应用权限列表/开放权限（用户授权）.md` 中 `ohos.permission.ACCESS_NEARLINK`
- 版本说明：`开发/版本说明/最新版本(26.0.0 Beta)/26.0.0/OS平台能力/API变更清单/` 的 Beta1（`startScan` 允许 null）与 Beta2（`rssi` 过滤、`reasonMsg`）；`开发/版本说明/HarmonyOS 6.1.124 Beta/OS平台能力/API变更清单/NearLink Kit.md`（CDSM 与 `getDeviceInformation`）

未读：CDSM 业务语义细节、广播发射功率每个枚举的功率毫瓦、SSAP Server 示例的全部属性表、Wireshark 是否已有星闪解析器。未把未读内容写成能力。

本仓库只作上下文：`features/nearlink/src/main/ets/ui/page/NearLinkFeaturePage.ets`、`domain/model/NearLinkScanFilter.ets`、`constants/NearLinkConstants.ets`、`common/debug_core` 的权限场景与后台目录、`common/platform` 的 `AppPermission.ACCESS_NEARLINK`。
