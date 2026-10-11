---
id: ui.wifi-network.session-log
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 会话日志

会话日志是各屏动作的同一条时间线。每行有时间、动作、终态。页面状态写入 `common/debug_core` 的 `LogCaptureService`，本页只读已写入的记录。密钥、证书私钥、预共享密钥以掩码出现（WN-064）。

从任意网络子页的标题菜单进入。`destinationKind = MODULE`。返回回到进入前的子页。

## 布局

`YoPageShell` 标题「会话日志」，`scrollable = false`，`contentEdgeToEdge = true`。

顶栏：`YoSegmentButton` 过滤动作来源，标签为全部、扫描、连接、网络、诊断、交换。过滤只隐藏行，不改存储。

列表主行：`HH:mm:ss` 与动作名。次行：终态，必要时加 `nativeCode` 和一句说明。行高 56vp，间距 `YoListToken.ITEM_GAP`。超过一屏时列表自己滚动。

底栏：「清空」`DANGER`，「导出」`SECONDARY`。导出沿用 `common/storage` 的导出写入，掩码规则与屏上一致。

`≥600vp` 左列表、右选中行的三个字段大号重排：时间、动作、终态。仍然是这三字段，不增加原始 Kit 对象。

## 行内容

成功的扫描、连接、探测、HTTP 各占一行，三字段齐全（WN-128）。再次连接是新时间的新行，不改上一行终态（WN-066）。

Wi-Fi 错误码在终态旁同时有数字和一句说明（WN-129）：

| 码 | 说明 |
| --- | --- |
| 2501000 | 操作失败 |
| 2501001 | STA 未打开 |
| 2501005 | 用户未响应 |
| 2501006 | 用户拒绝 |
| 2501007 | 参数无效 |

静止管控仍用 2501000，说明句用「静止管控」，数字保留。201 与 801 也保留数字，说明分别是「权限被拒绝」和「本机不支持」。

同一次开关事件只出现一行。离开页面再进入后，不因重复订阅写出第二行来源相同的记录（WN-131）。行上来源字段写订阅登记的那一处。

洪泛、其他应用阻断、密码破解没有动作名，过滤分段里也没有这些标签（WN-132）。

## 状态

### 默认

列表按时间从新到旧。最新一行贴在列表顶部。选中行在宽窗右栏重复三字段。

### 按下

行按下透明度为 `YoOpacity.PRESSED`，松手在窄窗展开次行全文。清空、导出按下走按钮按下态。导出完成 `YoToast`「已导出」。

### 禁用

列表为空时「清空」和「导出」禁用，`disabledReason`「没有日志」。过滤分段在加载历史时禁用。

### 空

清空之后，或本会话尚无记录：`YoEmpty` 标题「没有会话日志」，说明「下一次扫描、连接或探测会写在这里」。清空完成后列表就是这个空态，随后新动作仍能追加（WN-130）。

### 错误

导出失败：`YoError`，列表不丢。写入失败的那次动作若没有终态，不补一行假的成功。错误行本身要有时间、动作、终态「失败」和错误码。

### 加载

打开页面读取已有记录时 `LOADING`「正在读取会话日志」。读取结束、清空结束、或写入失败后离开加载。新行到达时不整页加载。

## 模拟器标记

若记录来自模拟器上的扫描，终态旁可有「未用真机」。这条不把 WN-039 显示成通过。P2P、VPN、网络加速若被拒绝，终态是「模拟器不支持」，WN-124 保持未通过。日志页不提供「标记为通过」的动作。

## 依据

- `docs/goal/architecture/wifi-network/WN-128.md` 至 `WN-132.md`
- `docs/goal/architecture/wifi-network/WN-039.md`
- `docs/goal/architecture/wifi-network/WN-064.md`
- `docs/goal/architecture/wifi-network/WN-124.md`
- `common/youi_kit/src/main/ets/components/feedback/YoToast.ets`
- `common/youi_kit/src/main/ets/token/component/YoListToken.ets`
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/学习UI范式状态管理/MVVM模式（V2）.md`
