# 星闪文档完整性审计（Audit-A）

本文件只审计文档是否齐、是否互相打架。不审计实现，不改产品源码。

## 读取位置

| 项 | 值 |
| --- | --- |
| 被审计分支 | `cursor/nearlink-phase-d-b651` |
| 实际读取的 HEAD | `7dc19776cbaac5d161f0daf3e706b2f3e335fbff` |
| 该提交说明 | `feat(phase-d): surface the remaining NearLink checklist paths` |
| 本审计分支的基线 | `main` @ `d1250482c96d5506b973088965898f6c803498a8` |
| 官方规范对照 | `yohurm/HarmonyOS-Developer-docs` @ `1d85fab`（研究笔记自己写的镜像版本） |

已 `git fetch` 该分支，没有把它合并进本分支。`main` 上没有 `docs/goal/`。下面的文件路径都相对于被审计的 HEAD，除非另行标明。

模块清单与总表不一致时，以 `docs/goal/checklist/nearlink.md` 为准。`.projectark` 与 `docs/goal` 不一致时，以 `docs/goal` 为准。星闪不归 `common/yobluetooth` 或 `features/bluetooth`；被审计的架构文件在非目标里写的是这条边界，没有把星闪放进这两个包。

## 对本地审计四条结论的核对

| 本地结论 | 核对 | 依据 |
| --- | --- | --- |
| NL-001–NL-120 都有架构文件 | 成立 | `docs/goal/architecture/nearlink/NL-001.md` 至 `NL-120.md` 共 120 个文件，无缺号、无重复。每份都有「条目与非目标、模块边界与分层、架构图、序列图、数据模型、层间接口、权限与生命周期、日志、反模式」。标题与清单标题一致。 |
| 界面文档按屏幕覆盖每一条 | 成立 | `docs/goal/ui/nearlink/README.md` 把 120 条各分到一个屏幕，没有一条分给两个屏幕。各屏幕正文都出现了分给它的编号。`验收对照` 把 `NL-031–NL-033`、`NL-041–NL-048`、`NL-051–NL-052` 写成区间，展开后仍是 120 条，且没有一条出现在两张验收表里。 |
| 星闪清单仍标记为草稿 | 成立 | `docs/goal/checklist/nearlink.md` 文首 `status: draft`。研究笔记是 `status: active`。 |
| 设计与实现 PR 不在 main | 成立 | 见下一节。`main` 不含这些提交，也不含 `docs/goal`。 |

设计与实现的 PR 都还开着，`mergedAt` 为空：

| PR | 内容 | 头分支 | 状态 |
| --- | --- | --- | --- |
| [#2](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/2) | 阶段 A 研究与清单 | `cursor/nearlink-phase-a-research-2e98` | OPEN，draft |
| [#6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6) | 阶段 B 架构 | `cursor/nearlink-phase-b-architecture-9768` | OPEN，draft；基线是阶段 A 分支，不是 `main` |
| [#9](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/9) | 阶段 C 界面 | `cursor/nearlink-phase-c-ui-099b` | OPEN，draft；基线是阶段 B 分支 |
| [#14](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/14) | 阶段 D 实现 | `cursor/nearlink-phase-d-b651` | OPEN，draft；基线是阶段 C 分支 |

相对 `main` 多出来、且不在 `main` 上的提交是 `11c6e9f`、`c8153b8`、`45188bf`、`ef35546`、`4cfeac0`、`0fc12bc`、`7dc1977`。

## 判定

一条要同时满足下面四项才记为 **完整**：

1. `docs/goal/checklist/nearlink.md` 有该编号，并含前置、动作、结果、证据。
2. 对应架构文件九节都有本条内容，不是空标题。
3. 一个屏幕的正文和验收表覆盖该编号；该屏幕的「控件六态」表有「默认、按下、禁用、空、错误、加载」六列。
4. 结果能在 `docs/goal/research/nearlink.md` 里找到同一件事。研究笔记不使用 NL 编号，对照的是结论，不是编号字符串。

**缺口**：上述某一项在被审计树上不存在，或研究有结论但清单没有对应编号。

**冲突**：清单、研究、架构、界面或总表对同一件事的说法相反。总表若只是没进这棵树、分桶却与模块清单一致，不算条目冲突。

| 判定 | 编号 |
| --- | --- |
| 完整 | NL-001–NL-058、NL-060–NL-120（119 条） |
| 冲突 | NL-059 |
| 缺口 | 无缺号。另有研究结论没有编号，见下文，不占用 NL-001–NL-120 |

## 冲突

### NL-059 同一远端只建一次客户端

清单写的是：已经为地址 A 创建 Client 之后，再次连接 A 要复用该 Client，不创建第二个实例。

研究「关键结论」表把「一个应用对一个远端设备只建一次 Server」写在 **SSAP 服务端** 那一行。清单里没有服务端「只建一次」的编号。`只建一次` 在清单中只出现在 NL-059。

官方 API 参考 `开发/API参考/系统/网络/NearLink Kit（星闪服务）/ArkTS API/ssap（星闪SSAP连接能力）.md`（镜像 `1d85fab`）两处都写了「一个应用针对一个远端设备只需要创建一次实例」：`createClient` 段说的是 Client，`createServer` 段说的是 Server。清单只记下了客户端这一半，研究关键结论表只记下了服务端这一半，两边主语不同。

因此 NL-059 与研究笔记冲突。服务端那一半没有编号，记在「研究有结论、清单无编号」。

## 缺失编号

NL-001–NL-120 的编号集合连续，没有缺号，没有重复编号。

冲突编号：NL-059。

没有「文件不存在」的编号。

## 空口号

架构 120 份的九节都有本条正文。没有「待定」「同上」「占位」「TODO」一类空节。节与节之间的哈希也不全部相同：条目与非目标、模块边界、架构图、序列图、数据模型、反模式各有 120 种正文；层间接口 116 种，权限与生命周期 115 种，日志 118 种。重复的是少数共享句，不是空节。

## 编号排列不连续

集合连续，正文顺序不连续。`docs/goal/checklist/nearlink.md` 在 NL-079 之后先写 NL-116–NL-120，再回到 NL-080，然后写到 NL-115。文末分组表把 NL-116–NL-120 放在 SSAP 服务端，并写明三条分桶互斥、合计 120。这是服务端条目插在端口数传之前，不是缺号。

未合并的总表也写了「编号 NL-116–NL-120 位于 SSAP 服务端」，与模块文件的分组一致。

## 界面状态

占编号的八个屏幕都有「控件六态」表，表头六列齐全：`support-radio.md`、`scan-filters.md`、`advertising.md`、`ssap-client.md`、`ssap-server.md`、`port-terminal.md`、`pairing-encryption.md`、`session-log.md`。

`shell-navigation.md` 不占编号。它在「状态词」里定义了默认、按下、禁用、空、错误、加载，没有再做一张按控件展开的六态表。

下面这些格子写成「无」，是作者标明该控件没有这一态，不是漏了列：

| 屏幕 | 控件 | 写成「无」的态 |
| --- | --- | --- |
| `advertising.md` | 包含本机名 | 加载 |
| `advertising.md` | 角色说明入口 | 禁用、错误、加载 |
| `pairing-encryption.md` | 禁止发送开关 | 空、错误、加载 |
| `pairing-encryption.md` | 终端发送（受本开关影响） | 空 |
| `port-terminal.md` | 断开 | 空 |
| `port-terminal.md` | 销毁 | 空 |
| `scan-filters.md` | 停止 | 空 |
| `scan-filters.md` | 模式分段 | 错误、加载 |
| `session-log.md` | 记录行 | 禁用 |
| `session-log.md` | 筛选 | 禁用、错误、加载 |
| `ssap-client.md` | 重连 | 空 |
| `ssap-server.md` | 回复有响应写 | 空 |
| `ssap-server.md` | 删除服务 | 空 |

`support-radio.md` 的六态表没有「无」格。

屏幕归属（每条只在一处验收）：

| 屏幕 | 编号 |
| --- | --- |
| `support-radio.md` | NL-001–NL-018、NL-111、NL-112、NL-115 |
| `scan-filters.md` | NL-019–NL-052、NL-104、NL-110 |
| `advertising.md` | NL-053–NL-057 |
| `port-terminal.md` | NL-058、NL-080–NL-092、NL-102 |
| `ssap-client.md` | NL-059–NL-076、NL-105、NL-106、NL-114 |
| `ssap-server.md` | NL-077–NL-079、NL-116–NL-120 |
| `pairing-encryption.md` | NL-093–NL-101 |
| `session-log.md` | NL-103、NL-107–NL-109、NL-113 |

别的屏幕会点到这些编号（例如扫描页提到 NL-006、NL-013，广播页用一句话链到 NL-058），验收表仍只归上面这一处。

## 总表

被审计的 HEAD 上没有 `docs/goal/checklist/master.md`，因此这棵树上没有星闪总表行。

总表只存在于未合并的 [#5](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/5)（`cursor/phase-a-master-checklist-d24f` @ `95c4f93d1b316f76f098a15da20d5b1fecbd9b7d`），同样不在 `main`。该文件里的星闪分桶与模块清单文末一致：可验收实现 104、版本门槛 11（NL-001、NL-003、NL-023、NL-024、NL-034、NL-035、NL-051、NL-052、NL-076、NL-097、NL-100）、必须标明的缺口 5（NL-036、NL-101、NL-103、NL-113、NL-115），合计 120。这是文件不在被审计树上，不是分桶漂移。条目正文仍以模块清单为准。

## 研究有结论、清单无编号

这些不是 NL-001–NL-120 里的缺号，而是研究写了、清单没有单独编号：

| 研究里的结论 | 清单现状 |
| --- | --- |
| `getDeviceInformation()` 可读厂商与型号，起始 6.1.1(24) | 清单未出现该接口 |
| 不能配置扫描 interval/window，应标成缺口 | NL-028 只排除低时延模式，没有窗口不可配这一条 |
| SSAP Server 对一个远端只创建一次实例 | 见 NL-059；清单没有服务端对应编号 |
| 无共存仲裁、无共享天线状态 API，应标成缺口 | NL-111 只要求星闪关闭不跟着蓝牙打开，没有这条缺口 |

低时延扫描、服务 UUID 不能当系统过滤、不能解除配对、连接后不能读 RSSI、无空口抓包、合作设备集不是前提，分别落在 NL-028、NL-036、NL-101、NL-103、NL-113、NL-115，与研究的缺口表对得上。

## 与 `.projectark` 的差异

`.projectark` 里的 NL-001 是「权限与设备支持检查」，`docs/goal` 的 NL-001 是「支持查询为真」。旧编号体系不覆盖本次 120 条。按规则，`.projectark` 在不一致时作废，不把 `docs/goal` 的 NL-001 改判成冲突。

## 与本地审计的分歧

四条原结论都成立，见文首对照表。分歧是本地结论没有写出下面这些，它们同样影响门禁：

1. **NL-059 与研究冲突**，不是「除草稿和未进 main 之外，条目都齐」。官方 API 同时要求 Client 与 Server 各建一次；研究表只写了 Server，清单只写了 Client。
2. **被审计 HEAD 上没有总表。** 未合并的 PR #5 分桶与模块清单一致，所以不是行文漂移，但这棵树上没有 NL-001–NL-120 的总表行。
3. **界面设计也是草稿。** `docs/goal/ui/nearlink/` 下九个文件的 `status` 都是 `draft`，不只是清单。架构文件没有 `status` 字段。
4. **清单正文顺序不连续**（NL-079 之后跳到 NL-116），编号集合本身没有洞。

## 门禁

**不通过。**

119 条在清单、架构九节和屏幕验收上是齐的。门禁仍不通过，因为：NL-059 与研究笔记冲突；研究里还有四项结论没有清单编号；清单（以及界面设计）仍是 `draft`；`docs/goal/checklist/master.md` 不在被审计的 HEAD 上；阶段 A/B/C 的设计 PR（#2、#6、#9）和阶段 D 的实现 PR（#14）都没有进入 `main`。
