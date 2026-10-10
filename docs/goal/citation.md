---
id: goal.citation
type: index
status: active
when: design
when_to_use: UI Goal 引用功能清单路径和编号范围时
related:
  - docs/goal/checklist/master.md
  - docs/goal/checklist/bluetooth.md
  - docs/goal/checklist/nearlink.md
  - docs/goal/checklist/wifi-network.md
  - docs/goal/checklist/workbench.md
  - docs/goal/checklist/log.md
  - docs/goal/checklist/settings.md
  - docs/goal/checklist/app.md
---

# 功能编号引用

给 UI Goal 引用。本文件只列清单路径和编号范围。条目正文以各清单为准，架构正文以同编号的架构文件为准。

视觉不在本 PR。屏名仍沿用：工作台 `screen.workbench.home`，命令面板 `screen.workbench.command`，日志中心 `screen.log.center`，日志详情 `screen.log.detail`，设置 `screen.settings.hub`。

`WB-` 覆盖工作台和命令面板。`LOG-` 覆盖日志中心和日志详情。`SET-` 覆盖设置。视觉不在本 PR。

## 清单

| 清单 | 编号 | 来源 |
| --- | --- | --- |
| [docs/goal/checklist/bluetooth.md](checklist/bluetooth.md) | BT-001–BT-098 | 本 PR 从蓝牙树 `fba7e5d6dc3dd725f1baf3af4dea322943baf506` 复制 `docs/goal`。同一清单仍在未合并的 [PR #13](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/13)（`cursor/bluetooth-phase-d-06c7`）。本 PR 不复制该树上的 ets |
| [docs/goal/checklist/nearlink.md](checklist/nearlink.md) | NL-001–NL-120 | 本 PR 从星闪树 `d58de1c9b6e7681bada1e642c1955c1a02079570` 复制 `docs/goal`。同一清单仍在未合并的 [PR #14](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/14)（`cursor/nearlink-phase-d-b651`）。本 PR 不复制该树上的 ets |
| [docs/goal/checklist/wifi-network.md](checklist/wifi-network.md) | WN-001–WN-132 | 本 PR 从 `7295d1771288a0fb957021bd0e948073f435d96c` 复制。同一文件仍在未合并的 [PR #12](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/12)（`cursor/wifi-network-phase-d-4072`） |
| [docs/goal/checklist/workbench.md](checklist/workbench.md) | WB-001–WB-012 | 本 PR 新写。工作台 WB-001–WB-007，命令面板 WB-008–WB-012 |
| [docs/goal/checklist/log.md](checklist/log.md) | LOG-001–LOG-008 | 本 PR 新写。日志中心与日志详情 |
| [docs/goal/checklist/settings.md](checklist/settings.md) | SET-001–SET-006 | 本 PR 新写 |
| [docs/goal/checklist/app.md](checklist/app.md) | APP-001–APP-006 | 整机架构。不计入 350，也不改写 WB / LOG / SET。壳行为仍以 `139ddc61d1f82e3d8f5c92980d420f19230bffec` 为准 |
| [docs/goal/checklist/master.md](checklist/master.md) | 索引，不是条目 | 从 [PR #5](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/5) 的 `95c4f93d1b316f76f098a15da20d5b1fecbd9b7d` 复制。三模块合计仍以该文件的 350 为准。WB / LOG / SET / APP 不计入那 350 |

研究笔记与本 PR 一起复制，仍留在未合并的模块 PR 上：

| 研究 | 树 |
| --- | --- |
| [docs/goal/research/bluetooth.md](research/bluetooth.md) | `fba7e5d6dc3dd725f1baf3af4dea322943baf506`，PR #13 |
| [docs/goal/research/nearlink.md](research/nearlink.md) | `d58de1c9b6e7681bada1e642c1955c1a02079570`，PR #14 |
| [docs/goal/research/wifi-network.md](research/wifi-network.md) | `7295d1771288a0fb957021bd0e948073f435d96c`，PR #12 |

Phase A 清单原文还在未合并的 [PR #3](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/3)、[#2](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/2)、[#4](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/4)。Phase B 架构原文还在 [#8](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/8)、[#6](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/6)、[#7](https://github.com/yohurm/HarmonyOS-YoWireTools/pull/7)。本 PR 复制的是上表提交里的 `docs/goal/research`、`docs/goal/checklist`、`docs/goal/architecture`，不含 `docs/goal/ui/`。

## 架构文件

每条清单有同编号的架构文件，九节：条目与非目标、模块边界与分层、架构图、序列图、数据模型、层间接口、权限与生命周期、日志、反模式。

| 目录 | 编号 |
| --- | --- |
| `docs/goal/architecture/bluetooth/` | BT-001–BT-098 |
| `docs/goal/architecture/nearlink/` | NL-001–NL-120 |
| `docs/goal/architecture/wifi-network/` | WN-001–WN-132 |
| `docs/goal/architecture/workbench/` | WB-001–WB-012 |
| `docs/goal/architecture/log/` | LOG-001–LOG-008 |
| `docs/goal/architecture/settings/` | SET-001–SET-006 |
| `docs/goal/architecture/app/` | APP-001–APP-006 |

## 跨模块日志

读路径只有一条：UI → ViewModel/State → UseCase → RepositoryContract → DataSource → 表 `debug_log_index`。

终点是已有日志库 `LogRepository` 的这张表，不是 Kit，也不是 hilog。蓝牙、星闪、Wi-Fi 共用这一条。说明在 [LOG-003](architecture/log/LOG-003.md)。第二日志库算违规的位置写在 [LOG-008](architecture/log/LOG-008.md)。日志中心与日志详情已接到这条读路径（LOG-001、LOG-002、LOG-003）。工作台不读这张表。命令面板走命令契约（WB-008–WB-012）。工作台三枚能力读数走各模块仓库的开关读取（WB-003）。会话摘要计数在 `WorkbenchViewModel`（WB-005）。WB-004、WB-006 仍是缺口。射频仍是待真机。
