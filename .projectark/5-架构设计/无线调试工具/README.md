# 无线调试工具架构设计文档索引

本文档集基于 `.projectark/2-需求文档/无线调试工具/PRD`、本仓库 HarmonyOS 开发规范、项目开发经验，以及 WSL 参考文档 `\\wsl.localhost\Ubuntu-24.04\home\yohurm\yovo-harmonyos-docs` 中的 HarmonyOS 官方架构、包管理、Bluetooth、WLAN/Network、NearLink、权限、后台任务、日志、存储和并发文档编写。

当前仓库仍是单 `entry` HAP 起步工程，尚未形成业务代码。本设计因此采用“目标模块化架构 + 可分阶段落地”的方式：第一阶段可以在 `entry` 中按相同分层目录实现，第二阶段按官方产品层/特性层/公共能力层拆分 HAR 模块。

## 文档列表

1. `00-总体架构与工程模块化设计.md`
   - 产品架构目标、技术边界、HAP/HAR/HSP 选择、模块拆分、依赖规则、路由与状态总线。
2. `01-公共底座架构设计.md`
   - 统一会话、日志、命令面板、权限、后台任务、能力探测、错误码、观测性、存储与导出。
3. `02-蓝牙模块架构设计.md`
   - 经典蓝牙 SPP、BLE GATT、传输类型/双地址底座、扫描配对、MTU/分片、自动重连与验证清单。
4. `03-WiFi与网络模块架构设计.md`
   - WiFi 环境分析、网络诊断、Socket/TCP/UDP、HTTP、WebSocket、MQTT、LAN 发现与端口扫描。
5. `04-星闪模块架构设计.md`
   - NearLink 能力探测、扫描、广播解析、SSAP Client、dataTransfer、配对加密、服务端预留。
6. `05-数据模型接口测试与实施计划.md`
   - 核心领域模型、Repository/UseCase 接口、错误码映射、测试策略、实施阶段和评审清单。

## 模块详细设计目录

### Bluetooth

目录：`bluetooth/`（建议先读 `00`）

1. `bluetooth/00-传输类型与双地址身份模型设计.md`
   - `getRemoteDeviceTransport`（BR_EDR/LE/DUAL）、classic/ble 双地址、SPP 非 LE 白名单、BLE→Classic 桥接。
2. `bluetooth/01-经典蓝牙发现配对与设备身份设计.md`
   - Inquiry、已配对经典候选、配对状态、CoD 与 transport 分字段、收藏与最近设备。
3. `bluetooth/02-SPP终端连接收发与日志设计.md`
   - 仅经典地址 `sppConnect`、RFCOMM 收发、byte stream 日志、重连与保活。
4. `bluetooth/03-BLE扫描GATT与串口预设设计.md`
   - BLE 多路/单路扫描、广播解析、GATT 服务树、读写、Notify/Indicate、MTU 与串口预设。

### WiFi And Network

目录：`wifi_network/`

1. `wifi_network/01-WiFi扫描STA信息与环境分析设计.md`
   - WiFi 状态、扫描结果、链路信息、信道/RSSI、权限和扫描频率限制。
2. `wifi_network/02-Socket诊断LAN发现与端口扫描设计.md`
   - TCP/UDP/Multicast、网络诊断、LAN 主机发现、端口扫描、并发和后台恢复。
3. `wifi_network/03-HTTP-WebSocket-MQTT调试设计.md`
   - HTTP 请求生命周期、流式响应、WebSocket Client/Server、MQTT 选型和统一日志。

### NearLink

目录：`nearlink/`

1. `nearlink/01-能力探测扫描与广播解析设计.md`
   - NearLink 支持状态、开关状态、扫描过滤、随机地址、广播字段解析。
2. `nearlink/02-SSAP客户端服务属性与MTU设计.md`
   - SSAP Client、连接状态、服务发现、Property 读写、通知、MTU。
3. `nearlink/03-dataTransfer端口数传配对加密与拥塞设计.md`
   - dataTransfer port、连接、收发、拥塞、配对加密、资源释放。

## 阅读顺序

先读 `00` 和 `01`，确认架构基线与公共底座；再读 `02`、`03`、`04` 获得三个模块总体边界；随后进入 `bluetooth/`、`wifi_network/`、`nearlink/` 子目录阅读细化设计；最后读 `05` 将模型、接口、测试和任务拆分串起来。
