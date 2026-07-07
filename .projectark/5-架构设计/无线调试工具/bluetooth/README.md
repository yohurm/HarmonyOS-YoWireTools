# 蓝牙模块详细设计索引

本目录细化蓝牙模块设计。依据 PRD、`02-蓝牙模块架构设计.md`、WSL 官方参考文档中的传统蓝牙、BLE、`ohos.bluetooth.socket`、`ohos.bluetooth.ble`、`ohos.bluetooth.connection`、权限和后台资源约束编写。

## 文档列表

1. `01-经典蓝牙发现配对与设备身份设计.md`
   - 经典蓝牙扫描、已配对设备、配对状态、虚拟地址、收藏与最近设备。
2. `02-SPP终端连接收发与日志设计.md`
   - SPP/RFCOMM Client、读写策略、byte stream 日志、自动重连、保活与功耗。
3. `03-BLE扫描GATT与串口预设设计.md`
   - BLE 扫描、广播解析、GATT Client、服务树、读写、Notify/Indicate、MTU 与分片。

## 蓝牙模块总原则

1. 蓝牙页面不直接持有平台连接真相，连接真相由 Repository/DataSource 进入 `SessionRuntimeStore`。
2. 经典蓝牙发现、SPP 连接、BLE 扫描、GATT 连接是四类独立会话，不能混用状态。
3. SPP/RFCOMM 是 byte stream，日志必须保留原始 chunk，不默认做业务帧切分。
4. BLE GATT 是服务/特征/描述符模型，必须在服务发现完成后才能读写和订阅。
5. 配对和权限交给系统能力，应用只负责触发、监听、解释和降级。
6. 所有 `on` 注册必须有对应 `off`；所有 socket/GATT client 必须有 close/disconnect 路径。
