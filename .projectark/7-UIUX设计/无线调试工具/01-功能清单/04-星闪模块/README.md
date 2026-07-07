# 星闪模块功能清单 — 索引

> **状态**：深研草稿  
> **目录**：`.projectark/7-UIUX设计/无线调试工具/01-功能清单/04-星闪模块/`  
> **上游深研**：`.research/feature-inventory/20`、`04`、`18`、`22` §6  
> **PRD**：`.projectark/2-需求文档/无线调试工具/PRD/05-星闪模块PRD.md`、`06-权限…` §7.3  
> **IA 原则**：模块自治；日志/命令在 **星闪 ⚙ 设置**；无全局日志中心

---

## 1. 子文档索引

| 文档 | 范围 | 功能 ID |
| --- | --- | --- |
| [01-星闪全量功能清单.md](./01-星闪全量功能清单.md) | N-NL-01～14 · SSAP · dataTransfer · 加密 · 降级 · 设置 · 840vp | `N-NL-*` `NL-*` `NL-DG-*` |

---

## 2. 模块 IA 树

```text
星闪 Tab
├── L0 首页
│   ├── CapabilityBanner（N-NL-01）
│   ├── 扫描列表（N-NL-02）
│   ├── 最近设备 / 收藏 / 活跃 Session
│   └── 高级能力说明（N-NL-13 预留）
├── L1 设备详情
│   ├── 广播详情（NL-ADV-*）
│   └── 连接路径选择：SSAP | dataTransfer
├── L2 SSAP Client（N-NL-04/05/11）
│   └── C：服务树 + Log pane
├── L2 dataTransfer（N-NL-06/07/12）
│   └── C：终端 + 加密条
└── ⚙ 星闪设置（五分组）
    ├── 会话与日志（N-NL-10）
    ├── 命令与面板（N-NL-09）
    ├── 连接（加密策略、自动重连）
    ├── 扫描
    └── 收藏与设备（N-NL-08）
```

---

## 3. N-NL-01～14 速查

| ID | 一句话 |
| --- | --- |
| N-NL-01 | 能力 Banner：Unsupported/Denied/Degraded/Ready |
| N-NL-02 | 扫描列表字段 + 过滤 |
| N-NL-03 | stopScan 后连接 + 阶段条 |
| N-NL-04 | SSAP 树 R/W/Subscribe |
| N-NL-05 | Write Sheet + 高风险确认 |
| N-NL-06 | dataTransfer 终端 |
| N-NL-07 | 加密状态展示与记录 |
| N-NL-08 | 多维收藏（非单地址） |
| N-NL-09 | 命令面板 SSAP + dataTransfer |
| N-NL-10 | 会话导出 TXT/CSV/JSON |
| N-NL-11 | SSAP MTU [22,512] 默认 256 |
| N-NL-12 | Port UUID / MTU / 拥塞退避 |
| N-NL-13 | SSAP Server / Advertising 预留 |
| N-NL-14 | 单连接优先 |

---

## 4. PRD 差距分级（doc 22 §6）

| 分级 | 能力 |
| --- | --- |
| **P0** | Banner、扫描、SSAP 树、dataTransfer、加密条、MTU、会话导出 |
| **P1** | 配对验证、拥塞退避、收藏、Write 确认、840vp |
| **P2** | Property 曲线、Reliable Write 专家项 |
| **P3** | SSAP Server、Advertising |

---

## 5. 证据 ID 对照

| 前缀 | 含义 | 文档 |
| --- | --- | --- |
| **N-NL-xx** | 产品功能细项 | `01-星闪全量功能清单.md` · `20-v2` §1 |
| **NL-xx** | 用户逐步流程 | `20-v2` §4 |
| **NL-DG-xx** | 降级项 | `06-权限PRD` §7.3 |
| **NL-Cx** | 加密场景 | PRD §9 |
| **NL-Ax / NL-Bx** | SSAP / dataTransfer 阶段 | `20-v2` §4.2–4.3 |

---

## 6. UI 设计下游

| 功能清单 | 页面设计 |
| --- | --- |
| 能力/降级 | `03-UI设计/04-星闪模块/01-能力检测与降级设计.md` |
| SSAP | `03-UI设计/04-星闪模块/02-SSAP-Client页面设计.md` |
| dataTransfer | `03-UI设计/04-星闪模块/03-dataTransfer终端页面设计.md` |
| 模块设置 | `03-UI设计/04-星闪模块/04-星闪模块设置页设计.md` |
| 840vp | `.research/feature-inventory/18-HarmonyOS-840vp-星闪模块三分栏线框-v2.md` |

---

## 7. 阅读顺序

1. 本 README  
2. **01-星闪全量功能清单.md** — N-NL-01～14 全表  
3. `20-星闪模块-功能清单与逐步流程-v2.md` — 逐步 NL-01～B8  
4. `22` §6 — PRD Gap  
5. `05-星闪模块PRD.md` — 产品边界
