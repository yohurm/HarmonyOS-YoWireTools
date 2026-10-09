---
id: ui.wifi-network.scan
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 扫描、过滤与信道

扫描页展示 `getScanInfoList` 的缓存，并始终标出缓存时间和剩余冷却。主动刷新只来自 `startScan`。完成后看 `wifiScanStateChange`：1 再读列表，0 保持上一份成功结果并显示失败。

语义以 API 参考为准：`startScan`（API 21，`SET_WIFI_INFO`）是应用接口；`getScanInfoList` 是当前时刻前 30 秒的缓存。扫描指南里「主动扫描仅系统应用」那一句与 API 参考冲突，本页不采用。指南里的连接过程中不扫描、WLAN 关闭不扫描、温度与静止管控，仍然显示为失败。废弃的 `scan` / `getScanResults` 不出现在菜单或说明里。本页不申请位置权限。

## 布局

`YoPageShell` 标题「扫描」，`scrollable = false`，`contentEdgeToEdge = true`，以便列表滚动条贴齐视口。

自上而下：

1. 状态条，高 56vp，始终可见。左：`YoStatusPill`「缓存」。中：缓存时间，格式「缓存于 HH:mm:ss」或「距读取 n 秒」。右：冷却，前台文案「2 分钟内还可扫描 n 次」或「冷却中 mm:ss」；第 5 次起次数为 0。
2. 过滤条。频段、信号档、加密各用一个 `YoSegmentButton`，标签由外层 `Scroll` 容纳宽度，不在 `SegmentButton` 上链式改宽度。SSID 用 `TextInput`。排序与分组放标题菜单：按 RSSI 从强到弱、按 SSID 分组。
3. 列表。主行 SSID（空 SSID 写「空 SSID」）。次行四个事实：加密、RSSI dBm、频率、带宽。再下一行小字：信道「n · 由频率换算」、地址种类「随机地址」。
4. 底栏动作：`YoActionButton`「扫描」与次按钮「暂停」。导出在标题菜单。

`≥600vp`：`YoSplitScaffold` 左列表、右详情。详情含该 BSSID 的频率、RSSI、加密、带宽、信道换算。过滤只改变列表，不调用 `startScan`（WN-027、WN-032）。

信道页是独立 `OBJECT`。每个信道一行：信道号、落入该频率范围的 AP 数量、干扰档。已连接 AP 不计入「最强干扰」（WN-034）。推荐只列出最低两档，行尾胶囊「重叠估计」（WN-035）。

噪声、SNR、MCS、重传四列固定出现，单元格文案「未提供」（WN-036）。

## 扫描条

| 情况 | 状态条文案 | 列表 |
| --- | --- | --- |
| 首次 `startScan` 且回调为 1 | 「缓存」+ 本次读取时间 + 剩余次数 | 行含 SSID、加密、RSSI dBm、频率、带宽（WN-019） |
| 只刷新列表、未再 `startScan` | 「缓存」+ 原缓存时间。不出现「新扫描」 | 行保持（WN-020） |
| 前台 2 分钟内已成功 4 次，再点扫描 | 「剩余冷却」+ 倒计时 | 列表保留，扫描不启动（WN-021） |
| 后台间隔不足 30 分钟 | 回到前台后状态条「该次未执行」 | 无新的成功列表（WN-022） |
| 回调为 0 | 状态条改错误「扫描失败」 | 上一份成功结果还在（WN-023） |
| WLAN 关闭 | 「先打开 WLAN」 | 不追加新行（WN-024） |
| 正在关联 | 「连接过程中不允许扫描」 | 无新的成功列表（WN-025） |
| 静止管控 | 「静止管控」+ `2501000` | 不自动重试（WN-026） |

缓存时间在紧跟成功回调的那一次读取上也要显示。来源字段在详情里写 `CACHE` 或 `ACTIVE_SCAN`，列表胶囊统一先写「缓存」，因为列表数据来自 30 秒缓存接口。`ACTIVE_SCAN` 只表示这次读取之前调用过 `startScan` 且回调为 1。

## 过滤、排序、信道

- SSID 子串：只留包含该子串的行。清空输入后行数恢复（WN-027）。
- 信号档：`YoSegmentButton` 为全部、0、1、2、3、4。选中一档后其他档消失。行上同时保留 dBm（WN-028）。
- 加密：全部、OPEN、PSK、SAE、EAP。选中后只留该类型（WN-029）。
- 频段：全部、2.4 GHz、5 GHz。只看 2.4 时，频率落在 5 GHz 的行消失（WN-030）。
- 分组：同一 SSID 一个组头，组内每条仍可展开频率与 RSSI（WN-031）。组头按下展开，不合并成一条。
- 排序：第一条 RSSI 大于或等于最后一条（WN-032）。排序不触发扫描。
- 信道号旁固定「由频率换算」（WN-033）。

导出文本含 SSID、频率、RSSI、加密、时间戳。文件中不出现候选网络密钥（WN-038）。导出完成用 `YoToast`「已导出」。

暂停后底栏主按钮文案改为「继续」。暂停期间不再出现新的 `startScan`，缓存列表还在（WN-037）。

## 状态

### 默认

WLAN 已打开、已有一份缓存：状态条与列表同时可见。模拟器上另外一条 `warning` 胶囊「未通过 · 未用真机」（WN-039）。这份胶囊保持未通过，列表行数多少都不把它改成成功。

### 按下

「扫描」「暂停」「继续」、分段、列表行按下时透明度为 `YoOpacity.PRESSED`。列表行松手推入接入点详情，不在同一次点击里连接。

### 禁用

冷却中、WLAN 关闭、正在关联、缺少 `SET_WIFI_INFO`、或已暂停时，「扫描」`isEnabled = false`。`disabledReason` 与状态条同一句，例如「剩余冷却 mm:ss」或「先打开 WLAN」。已有列表仍可滚动、过滤。暂停中「暂停」禁用，「继续」可点。

### 空

回调为 1 且 `getScanInfoList` 为空：`YoEmpty` 标题「缓存中没有接入点」，说明带缓存时间。这是唯一的扫描空态。回调为 0、WLAN 关闭、冷却拒绝、权限 201 都不用空列表表示。

### 错误

`YoError` 或列表上方的错误条（列表仍在时不用整页错误替换上一份结果）：

- 201：未声明 `SET_WIFI_INFO`，扫描不启动（WN-003）。
- 2501000：操作失败；若信息含静止管控，用户句用「静止管控」（WN-026）。
- 回调 0：用户句「扫描失败」（WN-023）。

### 加载

从点击扫描到 `wifiScanStateChange` 到达前，状态条为 `LOADING`，文案「正在扫描」。列表保留上一份。回调到达、冷却拒绝或 801 后离开加载。801 的文案是「本机不支持」加 `801`。

## 依据

- `docs/goal/architecture/wifi-network/WN-019.md` 至 `WN-039.md`
- `docs/goal/research/wifi-network.md`「扫描文档与 API 参考不一致」
- `开发/API参考/系统/网络/Connectivity Kit（短距通信服务）/ArkTS API/ohos.wifiManager WLAN.md`
- `开发/指南/开发/系统/网络/Connectivity Kit（短距通信服务）/WLAN/Wi-Fi扫描开发指南.md`（连接中禁扫、关闭不扫、静止与温度管控；不采用「仅系统应用」那一句）
- `common/youi_kit/src/main/ets/components/controls/YoSegmentButton.ets`
- `common/youi_kit/src/main/ets/token/component/YoListToken.ets`
- `设计/设计指南/通用设计基础/布局/布局基础.md`
