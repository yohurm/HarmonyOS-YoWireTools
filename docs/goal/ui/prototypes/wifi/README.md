# 网络模块原型

## 总则

这些画面是网络模块的界面目标，对应 `docs/goal/ui/modules/wifi/`。SVG 与 PNG 成对。改画面时改 `generate.py` 后重新导出，避免手改 PNG。

画布：

| 文件 | 窗口 | 说明 |
| --- | --- | --- |
| `01`–`27` | 360×800 | 手机模块内页面与状态 |
| `32-wide-md-air` | 800×640 | 中屏：子页签 + 列表 + 信道图 |
| `28`–`31` | 1280×800 | 宽屏：透镜轨 + 对象 + 证据 + 检查器 |

手机画面不画应用底部页签。那是工作台的结构，本模块不改。底部短条是系统导航条的位置。

## 目录

| 文件 | 页面与状态 |
| --- | --- |
| `01-link-ready` | 链路就绪 |
| `02-link-wifi-off` | WLAN 关闭 |
| `03-link-permission` | 无 `GET_WIFI_INFO` |
| `04-link-portal` | 门户拦截 |
| `05-link-diagnose-running` | 路径检查进行中 |
| `06-link-diagnose-partial` | 解析失败，后续跳过 |
| `07-air-list` | 空口列表 |
| `08-air-scanning` | 扫描中，旧结果仍在 |
| `09-air-empty` | 缓存为空 |
| `10-air-throttled` | 冷却，展示缓存 |
| `11-air-channel` | 信道图，与选中接入点同步 |
| `12-air-rssi` | 时间图 |
| `13-ap-detail` | 接入点详情，含未返回字段 |
| `14-assoc-sheet` | 可交给系统 WLAN |
| `15-assoc-blocked` | 不能交接，改为复制 SSID |
| `16-hosts-scanning` | 私网探测中 |
| `17-hosts-list` | 主机结果 |
| `18-hosts-empty` | 网段无响应 |
| `19-host-ports` | 主机端口 |
| `20-session-list` | 会话列表 |
| `21-session-terminal` | TCP 报文与发送栏 |
| `22-session-connect` | 新建会话半模态 |
| `23-session-http` | 同一终端的 HTTP 形态 |
| `24-session-mqtt` | 同一终端的 MQTT 形态 |
| `25-session-lost` | 回前台后会话断开 |
| `26-link-ready-dark` | 链路的深色 Token |
| `27-port-scan-confirm` | 大范围端口确认 |
| `28-wide-lg-air` | 宽屏空口：列表、信道图、检查器 |
| `29-wide-lg-link` | 宽屏链路：历史、路径、选中的一跳 |
| `30-wide-lg-host` | 宽屏主机：端口证据和开会话表单 |
| `31-wide-lg-session` | 宽屏会话：报文与连接参数 |
| `32-wide-md-air` | 中屏空口：无透镜轨 |

导出：

```text
python3 docs/goal/ui/prototypes/wifi/generate.py
rsvg-convert -o png/同名.png svg/同名.svg
```
