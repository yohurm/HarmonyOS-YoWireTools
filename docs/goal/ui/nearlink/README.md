---
id: ui.nearlink
type: ui-design
status: draft
when: phase-c
related:
  - docs/goal/checklist/nearlink.md
  - docs/goal/research/nearlink.md
  - docs/goal/architecture/nearlink
  - docs/goal/ui/nearlink/shell-navigation.md
---

# 星闪界面设计

> 断点、Token、权限墙、深浅色以 [应用壳](../app-shell/README.md) 为准。质量门禁见 [QUALITY-GATE.md](../QUALITY-GATE.md)：**不可进入大规模页面实现**。目录不另建 `wifi_network` 文档树。


本目录是星闪调试模块的界面设计，按屏幕拆分。它不实现功能，也不写 ArkUI 产品代码。

每条清单只在一个屏幕里写验收表现。编号只追溯 `docs/goal/checklist/nearlink.md` 与 `docs/goal/architecture/nearlink/` 里的 NL-001–NL-120。下面的屏幕表是界面落点，不是第二份清单。断点、密度和状态词以应用壳为准。对接的 PR 写在 [质量门禁](../QUALITY-GATE.md)。

| 屏幕 | 文件 | 清单 |
| --- | --- | --- |
| 壳与导航 | [shell-navigation.md](shell-navigation.md) | 离开模块、离开扫描页的导航后果见各屏；本文件不单独占条目 |
| 支持与开关 | [support-radio.md](support-radio.md) | NL-001–NL-018、NL-111、NL-112、NL-115 |
| 扫描与过滤 | [scan-filters.md](scan-filters.md) | NL-019–NL-052、NL-104、NL-110 |
| 广播 | [advertising.md](advertising.md) | NL-053–NL-057 |
| SSAP 客户端 | [ssap-client.md](ssap-client.md) | NL-059–NL-076、NL-105、NL-106、NL-114 |
| SSAP 服务端 | [ssap-server.md](ssap-server.md) | NL-077–NL-079、NL-116–NL-120 |
| 端口终端 | [port-terminal.md](port-terminal.md) | NL-058、NL-080–NL-092、NL-102 |
| 配对与加密 | [pairing-encryption.md](pairing-encryption.md) | NL-093–NL-101 |
| 会话日志 | [session-log.md](session-log.md) | NL-103、NL-107–NL-109、NL-113 |

缺口 NL-036、NL-101、NL-103、NL-113、NL-115 的通过标准是界面写明 Kit 未提供该能力，并且不出现该能力的成功态。出处：`docs/goal/checklist/nearlink.md` 的「必须标明的缺口」。

版本门槛条目在低于起始版本时显示「当前系统版本不提供该能力」和起始版本，不调用该接口。出处：`docs/goal/checklist/nearlink.md` 文首，以及 `docs/goal/research/nearlink.md` 的版本表。
