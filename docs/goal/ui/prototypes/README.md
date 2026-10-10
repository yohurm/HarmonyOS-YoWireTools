# 可视化原型

这是整 App 的静态原型，不是 ArkUI 组件树，也不是页面实现。图按 `docs/goal/ui/` 已定文案、信息架构和单根 `Navigation` 绘制。蓝牙、星闪、Wi-Fi 是同一壳下的三个目的地，不是三个 App。

质量门禁第 10–12、14 项仍然阻塞。有图也不表示可以铺业务页面。

## 怎么在 PR 里看

打开本目录下的 PNG。GitHub 会直接预览 PNG；同名 SVG 是可缩放的源图。屏文档里的图片用相对路径指向这里。

窄屏逻辑宽 360vp，套同一只手机框。底栏五项是：工作台、蓝牙、网络、星闪、更多。宽屏换成 240vp 侧栏，项与底栏相同。内容高出一屏时，图按滚动展开，底栏画在末尾。

胶囊用浅色目标色（成功 `#44923D`、警告 `#D45C11`），不是当前 Kit 里待替换的浅色值。未上真机。

## 窄屏

| 文件 | 屏 | 状态 |
| --- | --- | --- |
| [phone-workbench.png](phone-workbench.png) | 工作台 `screen.workbench.home` | 默认（轻量） |
| [phone-workbench-empty.png](phone-workbench-empty.png) | 工作台 | 空：还没有会话 |
| [phone-command-panel.png](phone-command-panel.png) | 命令面板 `screen.workbench.command` | 默认：执行一次可点，周期发送禁用 |
| [phone-command-panel-empty.png](phone-command-panel-empty.png) | 命令面板 | 空：还没有命令 |
| [phone-command-panel-permission.png](phone-command-panel-permission.png) | 命令面板 | 无权限：去该模块授权 |
| [phone-log-center.png](phone-log-center.png) | 日志中心 `screen.log.center` | 默认；其中一行是权限失败 |
| [phone-log-center-empty.png](phone-log-center-empty.png) | 日志中心 | 空：没有会话日志 |
| [phone-log-center-error.png](phone-log-center-error.png) | 日志中心 | 错误：日志来源未收口 |
| [phone-settings.png](phone-settings.png) | 设置 `screen.settings.hub` | 默认：八组，未读取，开关禁用 |
| [phone-settings-error.png](phone-settings-error.png) | 设置 | 错误：一行读取失败 |
| [phone-bluetooth-overview.png](phone-bluetooth-overview.png) | 蓝牙概览 | 默认：已打开 |
| [phone-bluetooth-overview-permission.png](phone-bluetooth-overview-permission.png) | 蓝牙概览 | 无权限：授权 |
| [phone-bluetooth-overview-gap.png](phone-bluetooth-overview-gap.png) | 蓝牙概览 | 禁用：BT-008 蓝牙不可用 |
| [phone-nearlink-overview.png](phone-nearlink-overview.png) | 星闪概览 | 默认：支持且已打开；进入不弹授权 |
| [phone-nearlink-overview-error.png](phone-nearlink-overview-error.png) | 星闪概览 | 错误：801 |
| [phone-nearlink-overview-closed.png](phone-nearlink-overview-closed.png) | 星闪概览 | 禁用：星闪已关闭 |
| [phone-wifi-overview.png](phone-wifi-overview.png) | Wi-Fi 概览 | 默认：状态带与入口卡 |
| [phone-wifi-overview-empty.png](phone-wifi-overview-empty.png) | Wi-Fi 概览 | 空：尚未读取 |
| [phone-wifi-overview-error.png](phone-wifi-overview-error.png) | Wi-Fi 概览 | 错误：声明缺失 201，不是运行时权限墙 |

## 宽屏

| 文件 | 屏 | 状态 |
| --- | --- | --- |
| [wide-shell-workbench.png](wide-shell-workbench.png) | 应用壳 + 工作台 | 侧栏展开，同一组五项 |
| [wide-log-center.png](wide-log-center.png) | 应用壳 + 日志中心 | 侧栏仍高亮工作台；列表与详情分栏 |

## 图注里的待对齐

只标架构还没定的地方，不改屏上的规范文案。

| 图 | 图注 |
| --- | --- |
| 工作台默认 / 空 | 最近会话读模型未命名，无 WB 编号 |
| 命令面板默认 / 空 / 无权限 | 没有入库的执行函数；周期上限不写死；跨模块跳转契约未到 |
| 日志中心默认 / 错误，宽屏日志 | LOG-003 仍是缺口，行是示意 |
| 设置默认 / 错误 | 没有 SET 存储。蓝牙 / Wi-Fi / 星闪只链到模块 |
| 蓝牙概览默认 | 回连与诊断未画成第三张卡，根页行为细则只有经典和低功耗 |
| 星闪概览默认 | 页面状态类型未到 |
| Wi-Fi 概览默认 | 入口按壳的目的地表逐卡，没有收成 PRD 的三类工作台 |
| 两张宽屏 | 整 App 导航契约未到，沿用一个 `Navigation` |

## 假设

规范没有写死、图画的时候采用的做法：

- 设置页标题用「设置」，底栏用现有资源「更多」。
- 设置每组只画关键行，未画出的行名以设置屏文档为准。
- 命令名、会话行、日志行是示意，不是已入库数据。
- 按下只改按下色，没有单独出图。
- 星闪根页的无权限态就是不弹框，权限墙在扫描页，所以概览没有第二张权限墙。
- Wi-Fi 声明缺失按错误 201 画，不画运行时「授权」按钮。

## 屏文档

| 屏 | 文档 |
| --- | --- |
| 工作台 | [home.md](../workbench/home.md) |
| 命令面板 | [command-panel.md](../workbench/command-panel.md) |
| 日志中心 | [center.md](../log/center.md) |
| 设置 | [hub.md](../settings/hub.md) |
| 蓝牙概览 | [adapter-permissions.md](../bluetooth/adapter-permissions.md) |
| 星闪概览 | [support-radio.md](../nearlink/support-radio.md) |
| Wi-Fi 概览 | [shell-and-navigation.md](../wifi-network/shell-and-navigation.md) |
| 宽屏壳 | [navigation.md](../app-shell/navigation.md) |
