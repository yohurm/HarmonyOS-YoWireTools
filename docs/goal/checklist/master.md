---
id: checklist.goal.master
type: index
status: active
when: research
when_to_use: 查三模块 Phase A 的编号范围与分桶时；条目正文以模块文件为准
related:
  - docs/goal/checklist/bluetooth.md
  - docs/goal/checklist/nearlink.md
  - docs/goal/checklist/wifi-network.md
  - docs/goal/research/bluetooth.md
  - docs/goal/research/nearlink.md
  - docs/goal/research/wifi-network.md
  - docs/goal/checklist/workbench.md
  - docs/goal/checklist/log.md
  - docs/goal/checklist/settings.md
  - docs/goal/citation.md
---

# Phase A 清单总表

本文件只索引编号范围、条数，以及各模块自己的分桶。条目的前置、动作、结果与证据留在模块清单里。

模块清单与研究笔记随 PR [#2](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/2)（星闪）、[#3](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/3)（蓝牙）、[#4](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/4)（Wi-Fi/网络）进入仓库。

## 共用规则

- 本索引与模块文件不一致时，以模块文件为准。
- 缺口保持原标记。
- 真机与 hvigor 条目保持未完成。
- 本索引不是架构文档。

## 合计

编号在各模块内连续，无缺号。条数按清单标题逐条点过，并与各文件文末汇总核对。合计 **350**。

| 模块 | 编号 | 条数 | 清单 | 研究 |
| --- | --- | --- | --- | --- |
| 蓝牙 | BT-001–BT-098 | 98 | [bluetooth.md](./bluetooth.md) | [bluetooth.md](../research/bluetooth.md) |
| 星闪 | NL-001–NL-120 | 120 | [nearlink.md](./nearlink.md) | [nearlink.md](../research/nearlink.md) |
| Wi-Fi / 网络 | WN-001–WN-132 | 132 | [wifi-network.md](./wifi-network.md) | [wifi-network.md](../research/wifi-network.md) |
| 合计 |  | 350 |  |  |

三套分桶用词保持各模块原文。

## 蓝牙

分桶是支持、缺口、待证。计数按每条「判定」的开头，与清单文末「覆盖统计」一致。同一条若同时写到支持与缺口，仍只按开头归入一档；括号里的版本、应用层或场景限定留在原文。

| 分桶 | 条数 |
| --- | --- |
| 支持 | 86 |
| 缺口 | 10 |
| 待证 | 2 |
| 合计 | 98 |

缺口：BT-008、BT-015、BT-023、BT-024、BT-034、BT-035、BT-063、BT-084、BT-088、BT-089。待证：BT-030、BT-085。

| 分组 | 编号 | 条数 |
| --- | --- | --- |
| 权限与适配器 | BT-001–BT-008 | 8 |
| 经典发现 | BT-009–BT-018 | 10 |
| 配对 | BT-019–BT-026 | 8 |
| 地址 | BT-027–BT-036 | 10 |
| SPP | BT-037–BT-046 | 10 |
| L2CAP | BT-047–BT-049 | 3 |
| BLE 扫描 | BT-050–BT-061 | 12 |
| 广播与 GATT 服务端 | BT-062–BT-068 | 7 |
| GATT 客户端 | BT-069–BT-079 | 11 |
| MTU、PHY、连接参数 | BT-080–BT-085 | 6 |
| 吞吐、报文、日志 | BT-086–BT-090 | 5 |
| 回连、后台、诊断 | BT-091–BT-098 | 8 |

## 星闪

分桶是可验收实现、版本门槛、必须标明的缺口。三条集合互斥。编号 NL-116–NL-120 位于 SSAP 服务端。

| 分桶 | 条数 |
| --- | --- |
| 可验收实现 | 104 |
| 版本门槛 | 11 |
| 必须标明的缺口 | 5 |
| 合计 | 120 |

版本门槛：NL-001、NL-003、NL-023、NL-024、NL-034、NL-035、NL-051、NL-052、NL-076、NL-097、NL-100。必须标明的缺口：NL-036、NL-101、NL-103、NL-113、NL-115。其余 104 条的名单在清单「覆盖摘要」。

| 分组 | 编号 | 条数 |
| --- | --- | --- |
| 设备与开关 | NL-001–NL-012 | 12 |
| 权限 | NL-013–NL-018 | 6 |
| 扫描与过滤 | NL-019–NL-040 | 22 |
| 广播解析与身份 | NL-041–NL-052 | 12 |
| 角色与广播 | NL-053–NL-058 | 6 |
| SSAP 客户端 | NL-059–NL-076 | 18 |
| SSAP 服务端 | NL-077–NL-079、NL-116–NL-120 | 8 |
| 端口数传 | NL-080–NL-092 | 13 |
| 配对与加密 | NL-093–NL-101 | 9 |
| 吞吐、重连、日志 | NL-102–NL-110 | 9 |
| 与蓝牙边界 | NL-111–NL-115 | 5 |

## Wi-Fi / 网络

分桶是普通应用、受限、系统或企业、开发者选项、缺口、真机。一条只归入一个主标记。计数与清单文末汇总一致。

| 分桶 | 条数 |
| --- | --- |
| 普通应用 | 108 |
| 受限 | 10 |
| 系统或企业 | 4 |
| 开发者选项 | 3 |
| 缺口 | 5 |
| 真机 | 2 |
| 合计 | 132 |

受限：WN-008、WN-009、WN-063、WN-082、WN-083、WN-090、WN-111、WN-123、WN-125、WN-126。系统或企业：WN-010、WN-018、WN-062、WN-127。开发者选项：WN-118、WN-119、WN-122。缺口：WN-036、WN-049、WN-120、WN-121、WN-132。真机：WN-039、WN-124。

| 分组 | 编号 | 条数 |
| --- | --- | --- |
| 权限与能力 | WN-001–WN-010 | 10 |
| WLAN 状态 | WN-011–WN-018 | 8 |
| 扫描、过滤与信道 | WN-019–WN-039 | 21 |
| 已连接链路 | WN-040–WN-050 | 11 |
| 连接与认证 | WN-051–WN-064 | 14 |
| 重连与默认网络 | WN-065–WN-073 | 9 |
| 地址、DNS、路由与端口 | WN-074–WN-090 | 17 |
| 吞吐 | WN-091–WN-096 | 6 |
| 本应用连接检查 | WN-097–WN-111 | 15 |
| 局域网发现 | WN-112–WN-117 | 6 |
| 抓包、加速与权限墙 | WN-118–WN-127 | 10 |
| 日志与失败总则 | WN-128–WN-132 | 5 |

## 壳与跨模块

下面每一条都在壳清单和同编号架构文件里。判定与清单相同。这些编号不计入上面的 350。命令面板 WB-008–WB-012 是缺口，不是已经实现。

| 编号 | 判定 | 标题 | 清单 |
| --- | --- | --- | --- |
| WB-001 | 支持 | 工作台是根 Tab，标题为「工作台」 | [workbench.md](./workbench.md) |
| WB-002 | 支持 | 一条 Navigation、一个 NavPathStack、Stack 模式 | [workbench.md](./workbench.md) |
| WB-003 | 缺口 | 工作台不显示蓝牙、WLAN、星闪状态胶囊 | [workbench.md](./workbench.md) |
| WB-004 | 缺口 | 工作台没有三张模块入口卡 | [workbench.md](./workbench.md) |
| WB-005 | 缺口 | 工作台不列出最近会话 | [workbench.md](./workbench.md) |
| WB-006 | 缺口 | 工作台没有日志中心和命令面板入口 | [workbench.md](./workbench.md) |
| WB-007 | 支持 | 工作台不弹出射频或网络授权 | [workbench.md](./workbench.md) |
| WB-008 | 缺口 | 命令面板没有页面，也没有路由 | [workbench.md](./workbench.md) |
| WB-009 | 缺口 | 命令面板没有收藏列表和只读参数 | [workbench.md](./workbench.md) |
| WB-010 | 缺口 | 命令面板不能执行一次 | [workbench.md](./workbench.md) |
| WB-011 | 缺口 | 命令面板不能周期发送 | [workbench.md](./workbench.md) |
| WB-012 | 缺口 | 没有「新建命令」成功态 | [workbench.md](./workbench.md) |
| LOG-001 | 缺口 | 日志中心没有页面 | [log.md](./log.md) |
| LOG-002 | 缺口 | 日志详情没有页面 | [log.md](./log.md) |
| LOG-003 | 缺口 | 跨模块读路径还没有接到页面 | [log.md](./log.md) |
| LOG-004 | 支持 | 三模块会话行写入同一张 debug_log_index | [log.md](./log.md) |
| LOG-005 | 缺口 | LogQuery 不能按模块或关键字过滤 | [log.md](./log.md) |
| LOG-006 | 缺口 | 预览行丢掉模块和协议 | [log.md](./log.md) |
| LOG-007 | 缺口 | 导出和清空没有接到日志中心 | [log.md](./log.md) |
| LOG-008 | 支持 | 没有任何界面把 YoLog 或 hilog 当成会话列表 | [log.md](./log.md) |
| SET-001 | 缺口 | 设置八组没有出现，更多页是空壳 | [settings.md](./settings.md) |
| SET-002 | 缺口 | 设置页没有页面状态，启动读设置也不经过页面 | [settings.md](./settings.md) |
| SET-003 | 支持 | 设置页不申请蓝牙、星闪或 WLAN 权限 | [settings.md](./settings.md) |
| SET-004 | 缺口 | 主题在关系库，其余设置键在用户首选项 | [settings.md](./settings.md) |
| SET-005 | 缺口 | 没有清除本地数据的确认 | [settings.md](./settings.md) |
| SET-006 | 缺口 | 设置页不展示专家或轻量 | [settings.md](./settings.md) |

本段与 WB / LOG / SET 清单不一致时，以那份清单为准。三模块 350 条仍以各模块清单为准。
