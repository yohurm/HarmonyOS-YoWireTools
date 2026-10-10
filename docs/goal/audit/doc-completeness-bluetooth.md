---
id: audit.goal.bluetooth.doc-completeness
type: audit
status: active
when: audit
phase: Audit-A
read_branch: cursor/bluetooth-phase-d-06c7
read_sha: 307de7f0651d0c1ce944148d3c713b18108966d4
gate: 不通过
---

# 蓝牙文档完整性审计（Audit-A）

只核对文档是否成套。不改产品源码，不开始实现对齐审计。被读分支没有并入本分支。

## 结论

文档门禁：**不通过**。

已编号条目里，BT-001–BT-086、BT-088、BT-089、BT-091、BT-093–BT-098 为 **完整**。**缺口** 是 BT-087、BT-090、BT-092。**冲突** 没有。

另外有两处不挂在单个已编号条目上的缺口：被读提交里没有总表；研究笔记里有判定、模块清单里没有对应编号。

## 读取范围

| 项 | 值 |
| --- | --- |
| 仓库 | `yohurm/HarmonyOS-YoWireTools` |
| 分支 | `cursor/bluetooth-phase-d-06c7` |
| 实际读取的 HEAD | `307de7f0651d0c1ce944148d3c713b18108966d4` |
| 提交说明 | `feat(phase-d): connect the remaining Bluetooth screens` |
| 本审计分支的基线 | `main` @ `d1250482c96d5506b973088965898f6c803498a8` |

在该提交上读了：

- `docs/goal/checklist/bluetooth.md`
- `docs/goal/checklist/master.md`（该路径不存在）
- `docs/goal/architecture/bluetooth/BT-001.md`–`BT-098.md`
- `docs/goal/ui/bluetooth/` 下 14 个文件
- `docs/goal/research/bluetooth.md`

判定档以模块清单为准。总表若与模块清单不一致，模块清单胜出。`.projectark` 与 `docs/goal` 不一致时，以 `docs/goal` 为准，不把旧架构记成条目冲突。

架构一节要有：条目与非目标、模块边界与分层、架构图、序列图、数据模型、层间接口、权限与生命周期、日志、反模式。界面六态是：默认、按下、禁用、空、错误、加载。

## 与一份本地审计的对照

| 主张 | 本审计 | 依据 |
| --- | --- | --- |
| BT-001–BT-098 都有架构文件 | **同意** | 该 SHA 上 `docs/goal/architecture/bluetooth/BT-001.md` 至 `BT-098.md` 各一份，共 98 个，无缺号、无重号、无多余编号。每份都有上面九节，且九节正文互不重复。最小文件 `BT-049.md` 仍有 4252 字节 |
| 界面文档按屏幕覆盖每一条 | **同意** | 见下方屏幕归属。每条只出现在一个屏幕的 `checklist` 里。`BT-052` 的编号字符串只写在 `ble-scan.md` 文首，正文用过滤字段描述了同一行为（name、serviceUuid、掩码、厂商数据），仍然算这屏覆盖 |
| 缺口是 `shell-navigation.md` 的 `checklist: []` | **事实同意，不把它当编号缺口** | 该文件第 7 行就是 `checklist: []`。`index.md` 把这一屏标成「全部屏幕的进出」，不分配 BT 编号。同文件「状态」表写全了六态。空清单表示这屏不拥有特性编号，没有因此漏掉 BT-001–BT-098 |
| 设计 PR 和实现 PR 不在 `main` | **同意** | `main`（`d125048`）上没有 `docs/goal`。下列提交都不是 `main` 的祖先，PR 均为打开且未合并 |

设计与实现：

| PR | 角色 | head | 基线 | 状态 |
| --- | --- | --- | --- | --- |
| [#8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8) | 架构设计 | `acdc64fbebe693e4b3fc020c0dc98d6d8202cee5` | `cursor/bluetooth-phase-a-research-a36a`，不是 `main` | 打开 |
| [#11](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/11) | 界面设计 | `dd2a4256dbe42486aaf1bb60fb044fed9e6552e7` | `cursor/bluetooth-phase-b-architecture-d1ff`，不是 `main` | 打开 |
| [#13](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/13) | 实现 | `307de7f0651d0c1ce944148d3c713b18108966d4` | `cursor/bluetooth-phase-c-ui-e5a0`，不是 `main` | 打开 |

研究 PR [#3](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/3) 和总表 PR [#5](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/5) 同样没有进入 `main`。这不推翻「设计与实现不在 main」，只说明不在 `main` 的不只有这两类。

## 逐条分类

范围内除下表点名的三条以外，每一条都是 **完整**：模块清单有判定、Given、When、Then 和证据；架构文件九节写的是这一条；界面归到一个屏幕，该屏六态都有正文。

| 编号 | 分类 | 架构 | 屏幕 |
| --- | --- | --- | --- |
| BT-001–BT-008 | 完整 | `BT-001.md`–`BT-008.md` | `ui/bluetooth/adapter-permissions.md` |
| BT-009–BT-018 | 完整 | `BT-009.md`–`BT-018.md` | `ui/bluetooth/classic-discovery.md` |
| BT-019–BT-026 | 完整 | `BT-019.md`–`BT-026.md` | `ui/bluetooth/pairing.md` |
| BT-027–BT-036 | 完整 | `BT-027.md`–`BT-036.md` | `ui/bluetooth/address-identity.md` |
| BT-037–BT-046 | 完整 | `BT-037.md`–`BT-046.md` | `ui/bluetooth/spp-terminal.md` |
| BT-047–BT-049 | 完整 | `BT-047.md`–`BT-049.md` | `ui/bluetooth/l2cap.md` |
| BT-050–BT-061 | 完整 | `BT-050.md`–`BT-061.md` | `ui/bluetooth/ble-scan.md` |
| BT-062–BT-068 | 完整 | `BT-062.md`–`BT-068.md` | `ui/bluetooth/advertising-gatt-server.md` |
| BT-069–BT-079 | 完整 | `BT-069.md`–`BT-079.md` | `ui/bluetooth/gatt-client.md` |
| BT-080–BT-086 | 完整 | `BT-080.md`–`BT-086.md` | `mtu-phy-connection.md`（080–085），`throughput-packets-log.md`（086） |
| BT-087 | 缺口 | `BT-087.md` 九节都在 | `throughput-packets-log.md` |
| BT-088–BT-089 | 完整 | `BT-088.md`、`BT-089.md` | `throughput-packets-log.md` |
| BT-090 | 缺口 | `BT-090.md` 九节都在 | `throughput-packets-log.md` |
| BT-091 | 完整 | `BT-091.md` | `reconnect-background-diagnostics.md` |
| BT-092 | 缺口 | `BT-092.md` 九节都在 | `reconnect-background-diagnostics.md` |
| BT-093–BT-098 | 完整 | `BT-093.md`–`BT-098.md` | `reconnect-background-diagnostics.md` |

`ui/bluetooth/index.md` 和 `ui/bluetooth/shell-navigation.md` 不拥有编号。索引表把 001–098 分到上面 12 个屏幕，并集正好是这 98 条，没有一条进了两个屏幕的 `checklist`。

### 缺口编号

三条的缺口都在模块清单：有判定和 Given / When / Then，没有证据行。同号架构文件写了证据句，但是自述「平台没有这个 API」，没有指向 HarmonyOS 文档或研究笔记里的具体段落。

| 编号 | 清单标题 | 缺什么 |
| --- | --- | --- |
| BT-087 | 吞吐可被用户停止 | `checklist/bluetooth.md` 该条没有 `证据`。架构证据句是「应用层吞吐没有平台停止 API，停止就是不再继续写」 |
| BT-090 | 会话日志可按条导出且含原始值 | 清单没有 `证据`。架构证据句是「应用层会话日志。平台不提供该导出」 |
| BT-092 | 回连失败次数可见且能停止 | 清单没有 `证据`。架构证据句是「应用层自动回连。平台没有统一回连器」 |

其余 95 条清单都有证据行。判定开头与架构一致：支持 86、缺口 10、待证 2，和清单文末统计相同。架构把括号里的限定写成了短判定（例如清单 BT-054 是「支持（API 23+）；更低版本为缺口」，架构文首写「支持」），正文仍保留低版本不提交门限。BT-084 清单写「缺口（数字间隔）；三档为支持」，架构文首写「缺口」，正文仍是三档枚举、没有数字间隔。这是文首缩写，不是行为冲突，不改分类。

### 冲突编号

无。

## 总表

被读 SHA **没有** `docs/goal/checklist/master.md`。因此这一支上不存在蓝牙总表行。

总表在未合并分支 `cursor/phase-a-master-checklist-d24f` 的 `95c4f93d1b316f76f098a15da20d5b1fecbd9b7d`，本次没有把它并进来，只用来判断是不是正文漂移。那份总表自己写明：条目正文留在模块清单；不一致时以模块文件为准。它索引的是范围而不是 98 行正文：蓝牙 BT-001–BT-098 共 98 条，支持 86、缺口 10（BT-008、BT-015、BT-023、BT-024、BT-034、BT-035、BT-063、BT-084、BT-088、BT-089）、待证 2（BT-030、BT-085）。这与 `checklist/bluetooth.md` 文末一致，没有逐条冲突。

按「模块文件胜出」，不把「总表未进入本 SHA」改写成 98 条冲突。总表文件本身仍是本分支的结构缺口。

## 清单必须对上研究笔记

`docs/goal/research/bluetooth.md` 是清单的来源。已有编号的判定档与研究表一致的部分包括：权限与 `ACCESS_BLUETOOTH`、开关与 `STATE_ON`、经典发现与平台过滤缺口、BLE 过滤、配对与取消配对缺口、虚拟地址与免配对固化待证、双模方向、SPP、L2CAP、GATT、广播与任意 AD Type 缺口、MTU、PHY 待证、连接参数三档、应用层吞吐、HCI 缺口、回连销毁客户端、长时任务。清单文末排除星闪、A2DP 听歌、HID 注入、DFU，与研究的取舍一致。

研究表里有判定、清单里没有编号的：

| 研究里的能力 | 研究判定 | 清单 |
| --- | --- | --- |
| 本机可被发现（`setBluetoothScanMode`） | 待证 | 全文无此 API，也无「可被发现」 |
| 已连接设备枚举（`getConnectedBLEDevices`、`onAclStateChange`，以及 SPP 是否出现在系统「已连接」） | ACL 为版本新能力；SPP 是否出现为待证 | BT-025 只写了 `connectAllowedProfiles` 不等于 SPP 已连接，没有 ACL 监听，也没有这条待证 |
| Profile 电量（`getRemoteDeviceBatteryInfo`，且不是 GATT `0x180F`） | 支持该 API | 清单无电量、无该 API |

研究还要求调试台单独呈现 2900010（资源上限）。清单没有这个错误码。2900001、2900003、2900007、2900009、2900011、2900016、2900099、2901000、2901001、2901003、2901005–2901007、2902050、2902054 已有对应条目。范围内未点名的是 2901002 和 2901004。

`.projectark/5-架构设计/无线调试工具/bluetooth/01-经典蓝牙发现配对与设备身份设计.md` 写「当前工程 SDK 无 ACL API」。研究笔记写镜像里 API 26.0.0 有 `onAclStateChange`，并以镜像为准。按规则 `docs/goal` 胜出，这不构成某一条 BT 的冲突；缺的是清单没有把这条待证写成编号。

## 空口号、编号连续性、界面六态

空口号：没有。架构九节没有互为拷贝的空段，也没有「待补充」「TODO」「TBD」。检索到的「略」都在「忽略」或「策略」里，不是省略号。

编号连续性：模块清单和架构目录都是 BT-001 到 BT-098，连续，无缺号，无重号。

界面六态：下列屏幕的「状态」表都有默认、按下、禁用、空、错误、加载，单元格都写了本屏看见什么。

| 文件 | 六态 |
| --- | --- |
| `adapter-permissions.md` | 齐。空态写明根页不用空列表，并说明原因 |
| `classic-discovery.md` | 齐 |
| `pairing.md` | 齐 |
| `address-identity.md` | 齐 |
| `spp-terminal.md` | 齐 |
| `l2cap.md` | 齐 |
| `ble-scan.md` | 齐 |
| `advertising-gatt-server.md` | 齐 |
| `gatt-client.md` | 齐 |
| `mtu-phy-connection.md` | 齐 |
| `throughput-packets-log.md` | 齐 |
| `reconnect-background-diagnostics.md` | 齐 |
| `shell-navigation.md` | 齐。空清单不是缺态 |

没有缺少六态的屏幕。

## 门禁

**不通过。**

已编号缺口：BT-087、BT-090、BT-092。已编号冲突：无。

未编号缺口：被读 SHA 缺少 `docs/goal/checklist/master.md`；研究中的本机可被发现、已连接设备枚举、Profile 电量没有清单编号；清单未出现研究点名的 2900010。

与本地审计的分歧：不把 `shell-navigation.md` 的 `checklist: []` 当作漏编号。该文件六态齐全，BT-001–BT-098 已分别归到其余屏幕。
