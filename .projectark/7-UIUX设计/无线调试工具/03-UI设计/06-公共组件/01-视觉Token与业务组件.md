# 视觉 Token 与业务组件

> **状态**：v2 全量重构版

---

## 1. 视觉方向

YoWire 的视觉风格应是专业、清晰、低干扰。界面以信息密度和可扫描性为核心，不使用营销式大卡片堆叠，不使用装饰性渐变背景。

---

## 2. Token

| Token | 用途 |
| --- | --- |
| `spacing.1` 4vp | 紧密间距 |
| `spacing.2` 8vp | 基础间距 |
| `spacing.3` 12vp | 行内组 |
| `spacing.4` 16vp | 页面基础边距 |
| `spacing.6` 24vp | 平板/宽屏区块间距 |
| `radius.sm` 4vp | 输入框、标签 |
| `radius.md` 8vp | 卡片、列表组 |
| `font.body` 14fp | 正文 |
| `font.log` 12fp | 日志 |
| `font.title` 18-22fp | 页面标题 |

---

## 3. 基础组件

| 组件 | 规范 |
| --- | --- |
| AppHeader | 标题、状态摘要、1 个主操作、更多菜单 |
| StatusBanner | 权限、能力、后台、错误恢复 |
| TaskSegment | 模块内任务切换 |
| FilterSheet | 多条件过滤，含 Apply、Reset、Close |
| RiskDialog | 高风险确认 |
| EmptyState | 说明原因和下一步 |
| SessionCard | 最近会话和运行中任务 |
| LogPanel | 日志列表、过滤、暂停、导出 |
| TerminalInputDock | 输入模式、Payload、发送、周期发送 |
| MetricStrip | RSSI、MTU、收发字节、延迟 |

---

## 4. TerminalInputDock

| 区域 | 内容 |
| --- | --- |
| 模式 | Text / HEX |
| 输入 | 单行或多行，跟随键盘安全区 |
| 选项 | 追加换行、周期发送、最近命令 |
| 主按钮 | Send |
| 状态 | 未连接禁用，周期发送显示停止条 |

---

## 5. LogPanel

| 区域 | 内容 |
| --- | --- |
| Header | 会话名、暂停、过滤、导出 |
| List | 时间、方向、摘要、长度 |
| Detail | HEX、Text、解析字段 |
| Footer | 自动滚动、条数、丢弃提示 |

日志颜色不作为唯一状态表达，必须有方向符号或文本。

