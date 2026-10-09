---
id: research.hub.yowire.bluetooth
type: hub
status: active
when: research
when_to_use: 查找本仓库蓝牙专业调试能力的联网深研时
related: [playbook.online-deep-research]
---

# 联网项目总结（蓝牙调试）

本目录只归档 **YoWireTools 蓝牙专业调试** 的 Phase A 深研。源码在系统临时目录 `/tmp/YoAgentResearch/`，这里只有 Markdown。

目录按 YoAgentDocs 手册的能力层归档，不按 HarmonyOS / Android / Windows 建文件夹。平台写在各篇 frontmatter。

| 能力层 | 含义 | 横向总结 | 文档 |
|--------|------|----------|------|
| client-runtime | 蓝牙调试应用：扫描、配对、GATT/SPP、吞吐、日志 | [横向](by-stack/client-runtime/_synthesis.md) | [nRF Toolbox](by-stack/client-runtime/NordicSemiconductor--Android-nRF-Toolbox.md)、[SimpleBluetoothTerminal](by-stack/client-runtime/kai-morich--SimpleBluetoothTerminal.md)、[SimpleBluetoothLeTerminal](by-stack/client-runtime/kai-morich--SimpleBluetoothLeTerminal.md)、[Bluetooth LE Explorer](by-stack/client-runtime/microsoft--BluetoothLEExplorer.md) |

可测试特性清单不在本 Hub：见 [docs/goal/checklist/bluetooth.md](../checklist/bluetooth.md)。

落盘说明：手册要求 `research/by-stack/<capability>/`。本仓库把该树放在 `docs/goal/research/` 下，不改 YoAgentDocs 知识库，也不另写单文件 `bluetooth.md`。
