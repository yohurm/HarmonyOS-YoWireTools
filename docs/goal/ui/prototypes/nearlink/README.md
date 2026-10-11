# 星闪原型

## 总则

这些图是星闪模块的手机浅色原型，画板 390×844。每个状态同时有 SVG 和 PNG。它们对应 `docs/goal/ui/modules/nearlink/` 里的页面，不包含蓝牙、Wi-Fi 或其他模块。

宽屏分栏和深色 Token 写在模块设计的视觉篇里。这里不把手机页面横向拉成另一套列表。

## 文件

| 文件 | 页面 | 状态 |
| --- | --- | --- |
| `01-bench-ready` | 能力工作台 | 支持、开关已开、已授权、三个平面可进入 |
| `02-bench-unsupported` | 能力工作台 | 硬件不支持，平面入口收起 |
| `03-bench-switch-off` | 能力工作台 | 开关关闭，去系统设置 |
| `04-bench-permission` | 能力工作台 | 未授予 ACCESS_NEARLINK |
| `05-discovery-filter` | 发现台 | 先填写过滤契约 |
| `06-discovery-scanning` | 发现台 | 按契约发现中 |
| `07-discovery-results` | 发现台 | 广播卡片，含名称冲突和无效 RSSI |
| `08-discovery-empty` | 发现台 | 没有匹配广播 |
| `09-discovery-rejected` | 发现台 | API 13 空过滤被拒绝 |
| `10-adv-inspect` | 广播检视 | 原始 HEX 与解析字段 |
| `11-session-bind` | 会话绑定 | 服务平面或端口平面 |
| `12-ssap-connecting` | SSAP | 创建 Client 后连接中 |
| `13-ssap-tree` | SSAP | 服务树就绪，队列空闲 |
| `14-ssap-property` | SSAP | 属性半模态，无读权限 |
| `15-ssap-connect-failed` | SSAP | 连接失败且 Client 未 close |
| `16-port-register` | 端口 | 注册 UUID |
| `17-port-terminal` | 端口终端 | 已连接收发，加密未要求 |
| `18-port-congested` | 端口终端 | 写拥塞，发送暂停 |
| `19-port-unencrypted` | 端口终端 | 要求加密但链路未加密，发送被阻止 |

同名 `.svg` 与 `.png` 是同一张图。PNG 宽度 780 像素。
