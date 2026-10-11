---
id: ui.wifi-network.connect
type: ui-design
status: draft
when: phase-c
related: [ui.wifi-network.shell, checklist.wifi-network]
---

# 连接与认证

> 壳、Token、权限墙和深浅色以 [应用壳](../app-shell/README.md) 为准。下文保留 Phase-C 行为细则。冲突时应用壳优先。页面只读页面状态，不调用 Kit。

## 布局

本屏层级见 `YoNavDestinationKind`，结构见下方组件树。 窄屏单列。窗口宽度不小于 600vp 且本屏同时有列表和详情时，用 `YoSplitScaffold`： 普通列表 4:6，终端 6:4，每栏至少 280vp。 页边距 `YoResponsive.pageHorizontal`，分区间距 `YoSpace.XL`（16vp）。 字号 `YoTypeStyle`，地址和 HEX 用 `MONO_S`。 原 Phase-C 若在下文另写了断点或底栏，与 [导航](../app-shell/navigation.md) 冲突时以导航为准。

## ArkUI 组件树

```text
Navigation
└── NavDestination
    └── YoPageShell
        └── Scroll
            └── Column
                ├── Row
                │   ├── Text
                │   └── YoStatusPill
                ├── TextInput
                ├── YoSegmentButton
                ├── List
                │   └── ListItem
                └── YoActionButton
```

`ListItem` 设置 `accessibilityGroup(true)`，朗读文本包含胶囊文案。胶囊组件自身不发声。过滤和配对说明用 `bindSheet`。破坏性确认用 `AlertDialog`。不使用 `HdsListItem`。

## 状态矩阵

| 态 | 本屏 |
| --- | --- |
| 默认 | 见下方行为细则中的同名描述。 |
| 按下 | 见下方行为细则中的同名描述。 |
| 禁用 | 见下方行为细则中的同名描述。 |
| 空 | 见下方行为细则中的同名描述。 |
| 错误 | 见下方行为细则中的同名描述。 |
| 加载 | 见下方行为细则中的同名描述。 |
| 无权限 | 不弹运行时授权。声明缺失回到权限与能力页的 201。用户拒绝确认连接是 2501006，属于错误（WN-057）。 |

按下只改变控件外观。松手后才把意图交给页面状态。禁用控件不进入按下。错误行若仍写着未授权，归到无权限，不另做一套权限样式。组件树是该页类型的上限：行为细则没有分段就不渲染 `YoSegmentButton`，没有过滤输入就不渲染 `TextInput`。缺口墙的写法见 [权限墙与缺口墙](../app-shell/permission-gap-wall.md)。

## 编号追溯

| 项 | 值 |
| --- | --- |
| 设计屏 | `wifi-network/connect-and-auth` |
| 架构编号 | WN-053 至 WN-063（行为细则里逐条出现） |
| 架构 PR | https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7 。文件不在 `main` |
| 工作台入口 | 工作台「网络」卡片，或底栏网络槽（下标 2） 。工作台没有 WB 编号，槽位是 `AppRoutes.TAB_INDEX_WORKBENCH` = 0 |

## 行为细则


本页管理本应用添加的候选网络，并显示连接终态。它不读取系统已保存的预共享密钥，不断开系统当前 STA。扫描行不能直接打开本页并提交连接。

## 布局

`YoPageShell` 标题「连接」，`MODULE`。

上半是候选列表：主行 SSID，次行加密类型与候选 ID。隐藏网络次行加「隐藏」。密钥不在列表里出现。

下半是表单，间距 `YoResponsive.FORM_GAP`（16vp）：

- SSID：`TextInput`。
- 加密：`YoSegmentButton`，项为 OPEN、PSK、SAE、EAP。WEP 不在可选项里。若从旧数据遇到 WEP，表单顶部一条说明「候选配置不支持 WEP」，提交按钮禁用（WN-053）。
- 密钥：`TextInput`，`type` 为密码。OPEN 时输入框禁用并清空。
- EAP 身份与密码：仅 EAP 时出现。空字段在提交前标红，文案指出哪一项为空（WN-055）。
- 隐藏：一枚说明文字「isHiddenSsid」。用 `YoActionButton` `SECONDARY` 在「隐藏」「可见」之间切换，选中态用 `YoStatusPill`。
- 连接方式：`YoSegmentButton`「需用户确认」「直接连接」。

底栏两个按钮：「添加并连接」`PRIMARY`，「移除」`DANGER`。移除只对当前选中的候选 ID 可用。

`≥600vp` 左列表右表单。`<600vp` 表单在列表下方，随 `YoPageShell` 滚动；底栏动作固定，避开导航条安全区。

用户确认连接使用系统对话框。本页只在对话框结束后显示结果，不自绘第二套确认窗。直接连接的结果区不出现「用户已允许」或「用户已拒绝」（WN-059）。

## 校验与终态

| 条件 | 提交前 | 终态文案 |
| --- | --- | --- |
| PSK 短于 8 字节 | 按钮禁用，「PSK 至少 8 字节」 | 不调用添加 |
| OPEN 且密钥非空 | 按钮禁用，「开放网络密钥必须为空」 | 不调用添加（WN-052） |
| SAE 密钥为空 | 按钮禁用，「SAE 至少 1 字节」 | 不调用添加 |
| SAE 密钥至少 1 字节 | 可提交 | 「已连接」或 Wi-Fi 错误码（WN-054） |
| PSK 长度够 | 可提交 | 日志先有 `CONNECTING` 或 `AUTHENTICATING`，再有 `CONNECTED` 或 `UNKNOWN`（WN-051） |
| EAP 身份或密码为空 | 指出空字段 | 不发送空身份（WN-055） |
| 隐藏且 SSID 完整 | 可提交 | 候选列表能读回该 SSID（WN-056） |
| 用户拒绝 | — | `2501006`，状态不是 `CONNECTED`（WN-057） |
| 用户超时未操作 | — | `2501005`（WN-058） |
| 候选 ID `< 0` | — | `2501007`「参数无效」（WN-060） |
| 已移除再连接同一 ID | — | 失败可见，列表无该 SSID（WN-061） |

错误码旁的一句说明与会话日志一致：2501000 操作失败，2501001 STA 未打开，2501005 用户未响应，2501006 用户拒绝，2501007 参数无效。

离开页面、导出、写日志时，密钥显示为掩码。掩码用固定长度的圆点，不保留首尾字符（WN-064）。

## 状态

### 默认

WLAN 已打开，表单为空，列表为当前 `getCandidateConfigs`。选中一项时表单回填 SSID 与加密，密钥框保持掩码。

### 按下

「添加并连接」「移除」、分段按下走对应组件的按下透明度。提交后按钮进入 `loading = true`，标签变为处理中，直到终态。

### 禁用

WLAN 未打开、校验未过、WEP、或正在提交时，主按钮禁用。`disabledReason` 用上表的那一句。移除在没有选中 ID 时禁用，「先选择候选网络」。

### 空

没有任何候选配置：列表区 `YoEmpty`「还没有候选网络」，主动作「填写 SSID」。表单仍在。这与「移除后列表不再有该 SSID」一致。连接失败不用空列表代替错误码。

### 错误

终态失败时结果区 `YoError`，`nativeCode` 可见，`retryable` 在参数错误时为 false。用户拒绝与用户未响应分成两句，不互换。断开当前 STA 的入口不在本页；若从别处进入，结果是错误「需在系统设置中断开」，系统连接保持（WN-062）。读取系统已保存 PSK 的行写「企业权限」，格子里没有密钥（WN-063）。

### 加载

从提交到 `ConnState` 终态前，结果区 `LOADING`，文案用当前状态名：`CONNECTING`、`AUTHENTICATING`、`OBTAINING_IPADDR`。到达 `CONNECTED`、`DISCONNECTED`、`UNKNOWN` 或错误码后离开加载。没有终态就一直加载，视为本页错误，页面状态应在失败路径上结束加载。

## 系统或企业、受限

WN-062、WN-063 没有应用内成功态。本页不出现「已断开系统 WLAN」或明文 PSK。

## 依据

- `docs/goal/architecture/wifi-network/WN-051.md` 至 `WN-064.md`
- `docs/goal/research/wifi-network.md` 连接状态
- `开发/指南/开发/应用框架/ArkUI（方舟UI框架）/UI开发 (ArkTS声明式开发范式)/组件布局/构建布局/线性布局 (Row／Column).md`
- `common/youi_kit/src/main/ets/components/controls/YoActionButton.ets`
