# Wi-Fi / 网络文档完整性（Audit-A）

被审提交：`cursor/wifi-network-phase-d-4072` 的 `dcd5a65fd9ad636fe0742c5a2eacb78f0c6e4466`。只读该提交，没有把它并入本分支。对照时用过的其他提交单独标明，不代替被审 HEAD。

文档门禁：**不通过**。

缺号：无。冲突编号：无。空口号：无。界面六态缺失：无。

不通过的原因是验收清单仍标为草稿，不是缺文件或缺编号。WN-001 至 WN-132 在研究、模块清单、架构和界面上都能对上，逐条判定为完整。

## 本地审计交叉核对

| 主张 | 结论 | 文件与编号 |
| --- | --- | --- |
| WN-001–WN-132 各有一份架构文件 | 成立 | `docs/goal/architecture/wifi-network/WN-001.md` 至 `WN-132.md`，132 个文件，编号连续。每份都有：条目与非目标、模块边界与分层、架构图、序列图、数据模型、层间接口、权限与生命周期、日志、反模式。架构图至少一张 mermaid，序列图含成功与失败两张 |
| 界面文档按屏幕覆盖每一条 | 成立 | `docs/goal/ui/wifi-network/README.md` 的屏幕表，以及下表 12 个屏幕文件。每个屏幕都有默认、按下、禁用、空、错误、加载，正文非空。壳页 `shell-and-navigation.md` 同样六态，并写 WN-131、WN-132 的导航约束 |
| Wi-Fi 清单仍标记 draft | 成立 | `docs/goal/checklist/wifi-network.md` 文首 `status: draft`。同句也出现在被审历史里的阶段 A 尖端 `1ca1090f67a6f319c6d88c6027a7851fd9fe3091` |
| 设计与实现 PR 不在 main | 成立 | `main` 为 `d1250482c96d5506b973088965898f6c803498a8`，没有 `docs/goal`。PR #7（架构，`cursor/wifi-network-phase-b-efc8` @ `a5d202385cd37108da16f86b94c86cf4b73aee79`）、PR #10（界面，`cursor/wifi-network-phase-c-ui-f6c1` @ `73a0a8d709f41af01b996ad3769f76c7a0ab0d90`）、PR #12（实现，本被审分支）均为打开的草稿，`mergedAt` 为空，都不是 `main` 的祖先 |

与这四条没有相反结论。补充，不改判定：

- 13 个屏幕文件和界面 README 的文首同样是 `status: draft`。架构文件没有 `status` 字段。
- 架构 PR 尖端 `a5d2023` 不是被审提交的祖先。相对被审提交，它只改了 WN-021、WN-024、WN-025 的反引号粘连（各约 10 行）。被审提交里这三份文件仍在，九节仍在。粘连是可读性残留，不把这三条改判为缺口。
- 被审提交的 `docs/goal/checklist/` 只有 `wifi-network.md`，没有 `master.md`。总表在 PR #5，提交 `95c4f93d1b316f76f098a15da20d5b1fecbd9b7d`。该总表的 Wi-Fi 分桶、分组和条数与模块清单文末一致（普通应用 108、受限 10、系统或企业 4、开发者选项 3、缺口 5、真机 2，合计 132）。模块文件胜出；这里没有漂移，所以不把总表不在本提交记成 132 条冲突。总表同样不在 `main`。

## 屏幕归属

| 屏幕文件 | 编号 |
| --- | --- |
| `permissions-and-capability.md` | WN-001–WN-010 |
| `wlan-state.md` | WN-011–WN-018 |
| `scan-filter-channel.md` | WN-019–WN-039 |
| `link.md` | WN-040–WN-050 |
| `connect-and-auth.md` | WN-051–WN-064 |
| `reconnect-and-default-network.md` | WN-065–WN-073 |
| `address-dns-route-ports.md` | WN-074–WN-090 |
| `throughput.md` | WN-091–WN-096 |
| `in-app-connection-inspect.md` | WN-097–WN-111 |
| `lan-discovery.md` | WN-112–WN-117 |
| `capture-boost-permission-walls.md` | WN-118–WN-127 |
| `session-log.md` | WN-128–WN-132 |

跨文件提到的编号（例如 WN-008 同时出现在权限页和链路页）是引用，归属以上表为准。范围内每个编号都能在归属文件里搜到。

## 与研究的对照

研究来源是同提交的 `docs/goal/research/wifi-network.md`。模块清单 132 条的 Given / When / Then 与研究里的权限墙、30 秒缓存、前台 4 次/2 分钟、后台 30 分钟、`ConnState`、候选网络、连接属性可空、探测与路由跟踪的版本和 ACL、开发者选项抓包、不做洪泛，方向一致。没有一条写成研究明确否定的结果。

清单里有些符号研究正文没有逐字写出，行为仍能对上，因此不改判：

| 编号 | 清单里的符号 | 研究里对应的说法 |
| --- | --- | --- |
| WN-015、WN-016 | `isConnected` | 连接状态来自 `getLinkedInfo` 与 `ConnState` |
| WN-041 | `linkSpeed` | 上下行速率与最大协商速率分成两项 |
| WN-042 | `wifiRssiChange` | 已连接链路含 RSSI |
| WN-045 | `isRestricted` | 链路能力里的「限流」 |
| WN-046 | `wifiLinkType` | `WifiLinkType18+` |
| WN-047 | 不把数值 0 显示成 `0.0.0.0` | IPv4 是 number，须转点分十进制；空属性不补假地址 |
| WN-056 | `getCandidateConfigs`、`isHiddenSsid` | 隐藏 SSID 走候选网络 |
| WN-060、WN-129 | `2501007` | 研究写了 2501000、2501001、2501005、2501006，没有写 2501007 的词条 |
| WN-073 | `netBlockStatusChange` | 研究写了 `netAvailable` / `netLost` / `netUnavailable` 等，没有写阻塞回调 |
| WN-094 | `linkDownBandwidthKbps` | 研究点名的是 `linkUpBandwidthKbps`，并写带宽为 0 时不得显示成 0 Mbps |
| WN-110 | `2103019` | `getSelfTrafficStats22+`，最长 31 天；错误码数字未写入研究 |
| WN-112 | `_http._tcp` | mDNS 的 `serviceFound`，类型由调用方给出 |

WLAN 不进入蓝牙或星闪：每份架构的「非目标」和「层间接口」都写明 `features/bluetooth` 与 `features/nearlink` 不承接本条。`.projectark` 与 `docs/goal` 不一致时以后者为准，本审计不把 `.projectark` 当作缺口来源。

## 逐条判定

| 编号 | 判定 |
| --- | --- |
| WN-001 | 完整 |
| WN-002 | 完整 |
| WN-003 | 完整 |
| WN-004 | 完整 |
| WN-005 | 完整 |
| WN-006 | 完整 |
| WN-007 | 完整 |
| WN-008 | 完整 |
| WN-009 | 完整 |
| WN-010 | 完整 |
| WN-011 | 完整 |
| WN-012 | 完整 |
| WN-013 | 完整 |
| WN-014 | 完整 |
| WN-015 | 完整 |
| WN-016 | 完整 |
| WN-017 | 完整 |
| WN-018 | 完整 |
| WN-019 | 完整 |
| WN-020 | 完整 |
| WN-021 | 完整 |
| WN-022 | 完整 |
| WN-023 | 完整 |
| WN-024 | 完整 |
| WN-025 | 完整 |
| WN-026 | 完整 |
| WN-027 | 完整 |
| WN-028 | 完整 |
| WN-029 | 完整 |
| WN-030 | 完整 |
| WN-031 | 完整 |
| WN-032 | 完整 |
| WN-033 | 完整 |
| WN-034 | 完整 |
| WN-035 | 完整 |
| WN-036 | 完整 |
| WN-037 | 完整 |
| WN-038 | 完整 |
| WN-039 | 完整 |
| WN-040 | 完整 |
| WN-041 | 完整 |
| WN-042 | 完整 |
| WN-043 | 完整 |
| WN-044 | 完整 |
| WN-045 | 完整 |
| WN-046 | 完整 |
| WN-047 | 完整 |
| WN-048 | 完整 |
| WN-049 | 完整 |
| WN-050 | 完整 |
| WN-051 | 完整 |
| WN-052 | 完整 |
| WN-053 | 完整 |
| WN-054 | 完整 |
| WN-055 | 完整 |
| WN-056 | 完整 |
| WN-057 | 完整 |
| WN-058 | 完整 |
| WN-059 | 完整 |
| WN-060 | 完整 |
| WN-061 | 完整 |
| WN-062 | 完整 |
| WN-063 | 完整 |
| WN-064 | 完整 |
| WN-065 | 完整 |
| WN-066 | 完整 |
| WN-067 | 完整 |
| WN-068 | 完整 |
| WN-069 | 完整 |
| WN-070 | 完整 |
| WN-071 | 完整 |
| WN-072 | 完整 |
| WN-073 | 完整 |
| WN-074 | 完整 |
| WN-075 | 完整 |
| WN-076 | 完整 |
| WN-077 | 完整 |
| WN-078 | 完整 |
| WN-079 | 完整 |
| WN-080 | 完整 |
| WN-081 | 完整 |
| WN-082 | 完整 |
| WN-083 | 完整 |
| WN-084 | 完整 |
| WN-085 | 完整 |
| WN-086 | 完整 |
| WN-087 | 完整 |
| WN-088 | 完整 |
| WN-089 | 完整 |
| WN-090 | 完整 |
| WN-091 | 完整 |
| WN-092 | 完整 |
| WN-093 | 完整 |
| WN-094 | 完整 |
| WN-095 | 完整 |
| WN-096 | 完整 |
| WN-097 | 完整 |
| WN-098 | 完整 |
| WN-099 | 完整 |
| WN-100 | 完整 |
| WN-101 | 完整 |
| WN-102 | 完整 |
| WN-103 | 完整 |
| WN-104 | 完整 |
| WN-105 | 完整 |
| WN-106 | 完整 |
| WN-107 | 完整 |
| WN-108 | 完整 |
| WN-109 | 完整 |
| WN-110 | 完整 |
| WN-111 | 完整 |
| WN-112 | 完整 |
| WN-113 | 完整 |
| WN-114 | 完整 |
| WN-115 | 完整 |
| WN-116 | 完整 |
| WN-117 | 完整 |
| WN-118 | 完整 |
| WN-119 | 完整 |
| WN-120 | 完整 |
| WN-121 | 完整 |
| WN-122 | 完整 |
| WN-123 | 完整 |
| WN-124 | 完整 |
| WN-125 | 完整 |
| WN-126 | 完整 |
| WN-127 | 完整 |
| WN-128 | 完整 |
| WN-129 | 完整 |
| WN-130 | 完整 |
| WN-131 | 完整 |
| WN-132 | 完整 |

## 门禁

不通过。WN-001 至 WN-132 没有缺文件、缺屏幕、缺六态、缺号、空口号或与研究相反的条目。验收清单 `docs/goal/checklist/wifi-network.md` 仍是 `status: draft`，文档门禁不能收口。本审计不检查实现。
