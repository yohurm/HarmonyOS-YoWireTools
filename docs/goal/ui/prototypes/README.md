# 原型索引

手机画布 360×800，宽屏 900×640。每屏同时有 SVG 和 PNG。中文界面。`main` 没有逐屏 UI 规格，下表是这套原型自己的路径、屏幕、状态和参照，不回填 PR #19。

壳层只有一条导航。底栏是首页、调试、控制台、设置。Wi-Fi、蓝牙、星闪从「调试」推进去。

| 路径 | 屏幕 | 状态 | 参照 |
| --- | --- | --- | --- |
| `phone/home-default.svg` | 首页 | 默认 | multi-nav-bar 底栏；PRD 工作台（能力 + 最近会话）；NavigationSettings 分组；D2 雪域灰 / 宇宙蓝；智慧家居模板的浅底白卡 |
| `phone/home-empty.svg` | 首页 | 空 | HarmonyKit Empty；空态留在「最近会话」区域 |
| `phone/home-error.svg` | 首页 | 错误 | HarmonyKit EmptyError；PRD 失败要给出下一步 |
| `phone/home-permission.svg` | 首页 | 无权限 | BluetoothLowEnergy 权限检查；PRD 权限不足 |
| `phone/debug-default.svg` | 调试 | 默认 | multi-nav-bar 同一组目的地；三行进入 Wi-Fi / 蓝牙 / 星闪，不另做底栏 |
| `phone/wifi-home.svg` | Wi-Fi 首页 | 默认 | network-query 四场景改成分组列表；PRD 当前网络 + 环境 / 诊断 / 协议 / 局域网；wlan-info 连接行 |
| `phone/wifi-list-default.svg` | 环境分析 | 默认 | wlan-info-query 已连接 / 可用；H3 列表；PRD 信道占用 |
| `phone/wifi-list-empty.svg` | 环境分析 | 空 | HarmonyKit Empty；PRD 空列表要说明原因 |
| `phone/wifi-list-error.svg` | 环境分析 | 错误 | 同上，WLAN 未开启 |
| `phone/wifi-list-permission.svg` | 环境分析 | 无权限 | 扫描需要位置权限 |
| `phone/wifi-detail.svg` | 热点详情 | 默认 | wlan-info `InfoItemView` 左标签右值；H3 详情；一个主按钮「网络诊断」 |
| `phone/wifi-connect.svg` | 连接网络 | 半模态 | H1 灰选择框、密码与眼睛、居中「下一步」；手机用底部半模态，不套第二层 |
| `phone/wifi-diag-default.svg` | 网络诊断 | 默认 | network-query `NetworkDiagnostics`；H4 |
| `phone/wifi-diag-error.svg` | 网络诊断 | 错误 | 样例无网络时清空内容；HarmonyKit 空态 |
| `phone/wifi-protocol.svg` | 协议调试 | 默认 | PRD TCP / UDP / HTTP / WebSocket / MQTT；NavigationSettings 行 |
| `phone/bt-home.svg` | 蓝牙首页 | 默认 | PRD 经典蓝牙与 BLE 分开；NavigationSettings 行 |
| `phone/bt-scan-default.svg` | 经典蓝牙扫描 | 默认 | H2 搜索成功、雷达、蓝色「重新搜索」；BluetoothLowEnergy 白卡片和 `#F1F3F5` |
| `phone/bt-scan-empty.svg` | 经典蓝牙扫描 | 空 | BLE 空页 |
| `phone/bt-scan-error.svg` | 经典蓝牙扫描 | 错误 | 蓝牙未开启 |
| `phone/bt-scan-permission.svg` | 经典蓝牙扫描 | 无权限 | BLE 权限列表 |
| `phone/bt-connect.svg` | SPP 连接 | 半模态 | PRD 连接配置；复选框表示安全连接；主按钮只有「连接」 |
| `phone/bt-terminal.svg` | SPP 终端 | 默认 | PRD 终端结构；hadice 日志行；等宽只用于报文 |
| `phone/bt-terminal-empty.svg` | SPP 终端 | 空 | 已连接但还没有收发 |
| `phone/bt-terminal-error.svg` | SPP 终端 | 错误 | 发送失败并给出重新连接 |
| `phone/ble-scan.svg` | BLE 扫描 | 默认 | BluetoothLowEnergy 设备行；PRD 过滤。不用心率卡片 |
| `phone/ble-gatt.svg` | GATT | 默认 | PRD 服务树；读 / 写 / 通知用文字；JhSetCell 右值 |
| `phone/nl-home.svg` | 星闪首页 | 默认 | PRD 先展示能力、开关和权限 |
| `phone/nl-scan-default.svg` | 星闪扫描 | 默认 | H2 的雷达构图；PRD 地址和名称 |
| `phone/nl-scan-empty.svg` | 星闪扫描 | 空 | BLE 空页文案换成星闪 |
| `phone/nl-scan-unsupported.svg` | 星闪扫描 | 能力不支持 | PRD：不支持时不要进入空白扫描 |
| `phone/nl-scan-permission.svg` | 星闪扫描 | 无权限 | ACCESS_NEARLINK |
| `phone/nl-ssap.svg` | SSAP | 默认 | PRD Property 读、写、通知；MTU |
| `phone/nl-transfer.svg` | dataTransfer | 默认 | PRD 终端；alert 色提示默认不保证加密 |
| `phone/console-log.svg` | 控制台日志 | 默认 | H6 / IKConsoleKit 分栏；hadice 级别、暂停、清空、导出 |
| `phone/console-log-empty.svg` | 控制台日志 | 空 | HarmonyKit Empty |
| `phone/console-log-error.svg` | 控制台日志 | 错误 | 写入失败并重试 |
| `phone/console-network.svg` | 控制台网络 | 默认 | hadice 网络记录；H6 网络数据 |
| `phone/console-command.svg` | 命令 | 默认 | PRD 命令面板；NavigationSettings 搜索框；行内「执行」 |
| `phone/settings-default.svg` | 设置 | 默认 | NavigationSettings 搜索和分组；PRD 显示 / 日志 / 后台 / 蓝牙 / 关于；JhSetCell；开关只给立刻生效项 |
| `phone/settings-error.svg` | 设置 | 错误 | HarmonyKit EmptyError |
| `wide/wifi-split.svg` | Wi-Fi 分栏 | 默认 | multi-nav-bar lg 竖栏 96，目的地与手机相同；wlan-info 与 H3 的列表\|详情；分栏不画返回 |

每张 PNG 与同名 SVG 放在一起。
