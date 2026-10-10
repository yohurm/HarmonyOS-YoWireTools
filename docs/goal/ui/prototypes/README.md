# 原型

高保真静态图。SVG 是源文件，PNG 是 2 倍导出，PR 里直接看 PNG。手机画布 360×800，宽屏 900×640。说明见 `REWORK.md`。

主分支没有单独的界面屏文档。页面范围以这次工具库调研和产品任务为准。

## 路径 → 屏 → 状态

| 路径 | 屏 | 状态 |
| --- | --- | --- |
| `phone/home-default.svg` | 首页 | 默认 |
| `phone/home-empty.svg` | 首页 | 空 |
| `phone/home-error.svg` | 首页 | 探测失败 |
| `phone/home-permission.svg` | 首页 | 无权限 |
| `phone/debug-default.svg` | 调试 | 默认。蓝牙、Wi-Fi、星闪同一列表 |
| `phone/wifi-list-default.svg` | Wi-Fi 列表 | 默认 |
| `phone/wifi-list-empty.svg` | Wi-Fi 列表 | 空 |
| `phone/wifi-list-error.svg` | Wi-Fi 列表 | 未开启 |
| `phone/wifi-list-permission.svg` | Wi-Fi 列表 | 无权限 |
| `phone/wifi-detail.svg` | Wi-Fi 详情 | 默认 |
| `phone/wifi-connect.svg` | Wi-Fi 连接 | 半模态，下一步 |
| `phone/wifi-diag-default.svg` | 网络诊断 | 默认 |
| `phone/wifi-diag-error.svg` | 网络诊断 | 失败 |
| `phone/bt-scan-default.svg` | 蓝牙扫描 | 已搜到 |
| `phone/bt-scan-empty.svg` | 蓝牙扫描 | 空 |
| `phone/bt-scan-error.svg` | 蓝牙扫描 | 未开启 |
| `phone/bt-scan-permission.svg` | 蓝牙扫描 | 无权限 |
| `phone/bt-connect.svg` | 蓝牙串口连接 | 半模态 |
| `phone/bt-terminal.svg` | 串口终端 | 默认 |
| `phone/bt-terminal-empty.svg` | 串口终端 | 空 |
| `phone/bt-terminal-error.svg` | 串口终端 | 发送失败 |
| `phone/ble-scan.svg` | BLE 扫描 | 默认 |
| `phone/ble-gatt.svg` | BLE GATT | 默认 |
| `phone/nl-scan-default.svg` | 星闪扫描 | 已搜到 |
| `phone/nl-scan-empty.svg` | 星闪扫描 | 空 |
| `phone/nl-scan-error.svg` | 星闪扫描 | 本机不支持 |
| `phone/nl-scan-permission.svg` | 星闪扫描 | 无权限 |
| `phone/nl-ssap.svg` | 星闪 SSAP | 默认 |
| `phone/nl-transfer.svg` | 星闪数传 | 默认 |
| `phone/console-log.svg` | 控制台 · 日志 | 默认 |
| `phone/console-log-empty.svg` | 控制台 · 日志 | 空 |
| `phone/console-log-error.svg` | 控制台 · 日志 | 读失败 |
| `phone/console-network.svg` | 控制台 · 网络 | 默认 |
| `phone/console-command.svg` | 控制台 · 命令 | 默认 |
| `phone/settings-default.svg` | 我的 / 设置 | 默认 |
| `phone/settings-error.svg` | 我的 / 设置 | 导出路径不可写 |
| `wide/wifi-split.svg` | Wi-Fi 列表 + 详情 | 宽屏，同一条任务 |

每个 SVG 旁边有同名 PNG。
