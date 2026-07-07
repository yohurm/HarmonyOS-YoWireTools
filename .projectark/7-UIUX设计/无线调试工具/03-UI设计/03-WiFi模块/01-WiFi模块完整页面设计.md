# WiFi 模块完整页面设计

> **状态**：v2 全量重构版  
> **范围**：WiFi 环境分析、网络协议调试、LAN 与网络诊断、WiFi 设置

---

## 1. 模块首页

| 区域 | 内容 |
| --- | --- |
| 顶部 | 当前 SSID、IP、RSSI、权限和刷新状态 |
| 任务切换 | 环境分析 / 网络协议 / LAN 与诊断 |
| 主体 | 当前任务列表、图表或会话 |
| 设置入口 | WiFi 模块设置 NavDestination |

---

## 2. WiFi 环境分析

### 2.1 用户流程

```text
进入 WiFi -> 环境分析
-> 检查权限和位置/网络可见性
-> 扫描 AP
-> 过滤 SSID/Band/Strength/Security
-> 选择 AP
-> 查看详情、信道图、RSSI 时间图
-> 导出扫描结果
```

### 2.2 布局

| 断点 | 布局 |
| --- | --- |
| 手机 | 当前网络 -> 扫描列表 -> AP 详情 -> 图表 |
| 600-839vp | 左 AP 列表，右详情和图表 |
| 840vp+ | A WiFi 任务，B AP 列表，C AP 详情/信道图/RSSI 图 |

### 2.3 AP 列表字段

| 字段 | 要求 |
| --- | --- |
| SSID | 隐藏 SSID 显示 Hidden SSID |
| BSSID | 受限时显示受限标识 |
| RSSI | 数值、强度文本、趋势 |
| 频段/信道 | 2.4G、5G、6G |
| 安全 | Open、WPA、WPA2、WPA3 等 |
| 标准 | 802.11 标准，未知时显示 Unknown |

---

## 3. 网络协议调试

### 3.1 支持任务

| 任务 | 页面 |
| --- | --- |
| TCP Client | Host、Port、连接、发送、日志 |
| TCP Server | Port、监听、客户端列表、日志 |
| UDP Client | Host、Port、发送、接收 |
| UDP Server | Port、监听、广播风险确认 |
| HTTP | Method、URL、Headers、Body、Response |
| WebSocket | URL、连接、Message、Frame Log |
| MQTT | Broker、Topic、QoS、Retain、Pub/Sub |

### 3.2 布局

| 断点 | 布局 |
| --- | --- |
| 手机 | 协议选择 -> 参数表单 -> 终端/响应 -> 日志 |
| 600-839vp | 左会话列表，右协议表单和日志 |
| 840vp+ | A WiFi 任务，B 协议会话列表，C 终端/响应/Traffic Log |

### 3.3 输入与日志

| 区域 | 内容 |
| --- | --- |
| 参数栏 | Host、Port、URL、Topic、QoS 等 |
| Payload 编辑 | Text、HEX、JSON 视图 |
| 发送栏 | Send、Resend、周期发送、清空 |
| Traffic Log | 时间、方向、协议、大小、状态码、耗时 |
| 导出 | TXT、CSV、JSON |

---

## 4. LAN 与网络诊断

| 功能 | UI |
| --- | --- |
| LAN 扫描 | 子网、进度、设备列表 |
| Ping | Host、次数、延迟图、丢包率 |
| DNS | 域名、记录类型、结果 |
| Trace | Hop 列表、耗时 |
| Whois | 查询结果文本 |

诊断结果必须同时提供摘要和原始输出。

---

## 5. WiFi 设置

WiFi 设置是 NavDestination 页面。

| 分组 | 内容 |
| --- | --- |
| 会话与日志 | 网络会话、扫描结果、导出、清理 |
| 命令面板 | TCP/UDP/HTTP/WebSocket/MQTT 模板 |
| 扫描 | 扫描周期、默认过滤、安全类型 |
| 协议 | 默认超时、重连、Payload 格式 |
| LAN/诊断 | 默认子网、Ping 次数、Trace 限制 |

---

## 6. 状态与恢复

| 状态 | UI |
| --- | --- |
| WiFi 未连接 | 当前网络卡显示未连接，引导检查系统网络 |
| 权限受限 | AP 列表 Banner，说明 BSSID/SSID 可能受限 |
| 扫描中 | 列表顶部 Progress 和停止 |
| 无 AP | 空态说明和重试 |
| 连接失败 | 协议会话错误卡 |
| 广播风险 | Dialog 确认 |
| 周期发送中 | 固定停止控制 |

