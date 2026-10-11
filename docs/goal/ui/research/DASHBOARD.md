---
id: yowire.ui.research.dashboard
type: topic-study
status: active
when: research
---

# 工作台：数据看板

工作台页面编号 `DB-BOARD`。打开应用先回答「哪条无线链路现在异常、读数从哪来、点下去落到哪一页」。底栏里的「看板」就是这一页，它不承担模块入口。

一块看板上同时有五类信息，缺一不可：

1. **状态**：蓝牙、Wi-Fi、星闪射频与关联是否可读。
2. **指标**：有单位的当前值。没有采样时写「未采样」，不用 0 表示健康。
3. **趋势**：有时间轴、至少 4 个点时才画折线。
4. **告警**：一条最高优先级告警占据视觉焦点，下面最多再列 4 条。
5. **下钻**：每个数字、每一行告警只跳到拥有该信号的那一页，并带上模块、对象、错误码、时间窗。下钻目标见下表，定义见 [MODULE-PAGE-MAP.md](MODULE-PAGE-MAP.md)。

禁止把工作台做成快捷入口、最近会话列表或功能宫格。综合工具宫格（[evidence/zonghe-tool-home.png](evidence/zonghe-tool-home.png)）和物联工厂的设备宫格（[evidence/iot-factory-phones.png](evidence/iot-factory-phones.png)）都是入口首页，结构不采用。

## 版面顺序

手机上自上而下，同一滚动页：

1. 射频状态带：三枚文字状态（蓝牙 / Wi-Fi / 星闪），每枚是「开、关、未知、无权限」之一，带最后采样时间。
2. 焦点指标：当前最高优先级告警的标题与错误码。没有告警时，焦点改为活跃会话数。
3. 次级指标三枚：Wi-Fi 关联 RSSI、近 15 分钟失败次数、活跃会话数（若焦点已占用会话数，第三枚改为 AP 可见数）。
4. 告警列表：时间倒序。
5. 趋势：关联 AP 的 RSSI 折线，或失败次数折线。点数不足时用一句话写「样本不足」，不画空坐标。

宽屏把 1–3 留在主栏，告警与趋势进右栏。右栏不是模块入口。组合方式见 [COMPONENT-COMPOSITION.md](COMPONENT-COMPOSITION.md) 的 C1、C2。

指标排版采用「标签小、数字大、单位与涨落次级」：interface-design 把同一指标的平铺 14px 与「11px 标签 + 28px 数字」作过对照（`/tmp/YoAgentResearch/DammyJay93--interface-design`，HEAD `2f9be32`，`.claude/skills/interface-design/SKILL.md`）。莓创图表示例是「大数字 + 平滑折线 + 柱状对比」（[evidence/mccharts-dashboard.png](evidence/mccharts-dashboard.png)）。YoWire 的柱只出现在信道页，不堆在这块看板上。

## 推荐指标与数据源

「已有模型」指 `main` 上已经有的类型。「假设」指总纲要求的读模型，当前代码里还没有统一采样器。平台待验证的能力不在看板上显示成已成功。

| 编号 | 指标 | 单位 | 数据源 | 下钻 |
| --- | --- | --- | --- | --- |
| DB-M01 | 蓝牙射频 | 开 / 关 / 未知 | **假设**。系统蓝牙开关。仓库有蓝牙状态卡，没有跨页采样器。读失败写「未知」 | `BT-BOARD` |
| DB-M02 | 活跃经典链路 | 条 | **假设**。读 SPP 会话注册表的连接中数量与最近错误。引擎在 `common/yobluetooth`，看板只读计数 | 一条时 `BT-SPP-TERMINAL`，多条时 `BT-BOARD` |
| DB-M03 | BLE 扫描产出 | 台 / 窗口 | **假设**。最近一次 BLE 扫描会话的设备数与结束原因。未扫描写「未采样」 | `BT-BLE-SCAN` |
| DB-M04 | Wi-Fi 关联 | SSID 或未关联；附 RSSI dBm、链路速率 Mbps、IP | **已有模型** `WifiLinkedInfoSnapshot`：`wifiActive`、`connected`、`ssid`、`rssi`、`linkSpeed`、`ipAddress` | `NW-BOARD` |
| DB-M05 | AP 可见数 | 台 | **已有模型** `WifiOverviewSnapshot`：`scanApCount`、`scanFromCache`、`lastScanAtMs`、`warnings` | `NW-SPECTRUM` |
| DB-M06 | 星闪能力 | 支持 / 不支持 / 未知 | **已有方向** `NearLinkCapabilityService`。开关、模拟器、API 版本以星闪 PRD 能力表为准，未在真机确认的项保持「未知」 | `NL-BOARD` |
| DB-M07 | 活跃会话 | 条，每条含协议与目标 | **假设**。内存索引覆盖 SPP、GATT 通知、TCP/UDP、WebSocket、MQTT、星闪 dataTransfer。PRD 定义了会话，`main` 没有统一读模型 | 点一条进入对应终端页 |
| DB-M08 | 近 15 分钟失败 | 次 | **假设**。滚动计数来自 `yolog` 的 `LogRecord`（`level`、`tag`、`domain`、`message`、`timestampMs`）。该类型没有会话 ID；按会话过滤要等日志 Goal 扩展字段，此前失败次数只按 tag 与级别 | `LOG-STREAM`，带级别与时间窗 |
| DB-M09 | 吞吐 | B/s，入与出 | **假设**。各终端 10 秒滑窗字节数。没有计数器时该格为「未采样」 | 对应终端页 |
| DB-M10 | 最高优先级告警 | 标题 + 错误码 | 优先级：无权限 > 关射频 > 能力不支持 > 最近失败码 > 扫描节流。Wi-Fi 侧已有 `warnings: string[]`；其余模块用各自最后错误码 | 拥有该信号的页面，带参数 |

15 分钟窗口是本总纲的采样假设，不是系统 API 的字段。

趋势用折线：时间序列应使用折线，少于 4 个点时改用数字，多于 6 条序列会互相遮挡（ui-ux-pro-max `charts.csv` 第 1 行，仓库 `nextlevelbuilder/ui-ux-pro-max-skill` HEAD `50d8a7d`）。qCharts 的 `LineChart` 提供多线与点击提示（`qingkouwei/qcharts` HEAD `27c3278`）。官方 `DataPanel` 只表达占比，最多 9 个值（[DataPanel](https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0.2-Release/zh-cn/application-dev/reference/apis-arkui/arkui-ts/ts-basic-components-datapanel.md)），不用于 RSSI。环图适合不超过 5 类的占比（`charts.csv` 第 3 行）；账单环图（[evidence/bill-donut.png](evidence/bill-donut.png)）不用于射频。

仪表图只适合「一个指标对照一个目标」（`charts.csv` 第 8 行）。测速页的大数字（[evidence/net-speed-phone.png](evidence/net-speed-phone.png)）属于 `NW-DIAG-RUN`，不放在工作台中央。

## 主状态

| 状态 | 看板上用户看到的 |
| --- | --- |
| 默认 | 五段都在。至少一个射频读数不是「未采样」 |
| 空 | 全部射频未采样且没有历史告警。文案「还没有采样」，主按钮「读取射频状态」 |
| 加载 | 数字与告警行是骨架。骨架晚于 300ms 再出现（ui-design-brain，HEAD `38f04c5`，SKILL.md States） |
| 失败 | 顶栏写采样失败与错误码，保留上次成功读数和时间 |
| 关射频 | 对应格子写「关」。页面仍是看板。三路射频都关时，焦点告警为「射频都已关闭」，每条可下钻 |
| 权限 | 缺哪一项，哪一格写「无权限」并给出「去授权」。其余格保持 |

告警全表是另一页 `DB-ALERTS`，不是第二块看板。字段与状态见页面地图。

## 下钻参数

从看板进入目标页时携带：

- `module`：`bluetooth` / `wifi` / `nearlink` / `log`
- `objectId`：地址、SSID、BSSID、主机、会话 ID；没有对象则省略
- `code`：错误码或告警种类
- `windowStartMs` / `windowEndMs`

目标页用这些参数选中对象或过滤列表。不把用户送回一个菜单。
