---
id: ui.wifi-network.throughput
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 吞吐

本页测用户填写的 HTTP 地址，并单独显示系统带宽估计和一次请求的 `PerformanceTiming`。实测 Mbps 与系统估计分属两块。页内没有公共测速服务器列表，没有弱网滑杆。

## 布局

`YoPageShell` 标题「吞吐」，`MODULE`。

1. 地址 `TextInput`，占位「HTTP 下载地址」。
2. 阶段胶囊：未开始、下载、上传、完成、中止、失败。
3. 两行速率。标题「下载 Mbps」「上传 Mbps」。进行中显示进度，结束后显示数值。上传行在下载结束前写「等待下载结束」（WN-093）。
4. 系统估计。`linkDownBandwidthKbps` 换算成 Mbps 时标题仍是「系统估计」。值为 0 时该格「无法评估」（WN-094）。
5. 计时。DNS、TCP、TLS、首字节、总完成，五列，单位毫秒（WN-095）。没有计时数据时五格都是「未返回」。
6. 底栏「开始」「中止」。中止只在下载或上传进行中可点。

`<600vp` 五列计时折成五条行，仍保留五个标签。`≥600vp` 用一行五格，格间距 8vp。速率数字用 `YoTypeStyle.TITLE_M`，单位用 `BODY_S`，避免合成一个没有单位的数。

## 状态

### 默认

阶段「未开始」。两行速率为「未测」。系统估计显示当前能力位里的值，或「无法评估」。地址为空时开始按钮禁用。

### 按下

「开始」「中止」按下走 `YoActionButton` 按下态。开始后「开始」进入 `loading`，直到阶段离开下载和上传。

### 禁用

地址为空、正在测速时「开始」禁用。未开始时「中止」禁用，`disabledReason`「当前没有进行中的测速」。阶段为失败后进度回到未开始，「开始」恢复（WN-096）。

### 空

从未测速：速率块用「未测」，不用 `0 Mbps`。这是内容里的空值，不是整页 `EMPTY`。整页 `EMPTY` 只在用户清空地址且要求看历史、而历史条数为 0 时使用，标题「还没有测速记录」。

### 错误

地址不可达：`ERROR`，原因可见，阶段回到「未开始」，进度不留在下载中（WN-096）。中止：阶段「中止」，速率格保持「未完成」，不写入完成值（WN-092）。把系统估计写进实测格视为不符合本页，两块标题必须同时可见（WN-091）。

### 加载

下载阶段 `LOADING` 区域只盖住速率块，文案「下载中」，进度从该阶段更新（WN-091）。下载结束后才把文案改为「上传中」。中止、失败、完成都离开加载。

## 依据

- `docs/goal/architecture/wifi-network/WN-091.md` 至 `WN-096.md`
- `docs/goal/research/wifi-network.md` 中 librespeed 可改编的分阶段与中止
- `设计/设计指南/通用设计基础/布局/布局基础.md`
- `common/youi_kit/src/main/ets/token/semantic/YoTypeStyle.ets`
