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
# 原型目录

高保真还没画。这里只有信息架构草图，用来看页面怎么挂在同一个导航上。颜色、密度、标题栏和组件外观都还没定，要等华为工具库截图、更多官方页面样例和高星开源对照之后再出。

## 怎么看

PR 里直接打开同名 PNG。SVG 是源文件，用浏览器打开即可。每张图角上标了「信息架构草图 · 非高保真」。

`references/harmonyos-component-ux-phone.png` 是组件示例仓库自带的手机截图，只说明看过那一个橱窗，不是本 App 的稿。

主分支上没有单独的界面屏文档。页面范围写在 `REWORK.md`，不从已作废的 PR #19 抄规范。
# 原型

高保真静态图。SVG 是源文件，PNG 是 2 倍导出，PR 里直接看 PNG。手机画布 360×800，宽屏 900×640。说明见 `REWORK.md`。

主分支没有单独的界面屏文档。页面范围以这次工具库调研和产品任务为准。

## 路径 → 屏 → 状态

| 路径 | 屏 | 状态 |
| --- | --- | --- |
| `ia/nav.svg` | 单根导航总图 | 结构草图。窄屏栈、宽屏同一批目的地。 |
| `ia/workbench.svg` | 工作台 | 草图。列表入口和宫格入口并列，未选定。 |
| `ia/list.svg` | 列表页（扫描、日志、发现共用） | 草图。默认布局，并标出空、错、无权限都留在内容区。 |
| `ia/command.svg` | 命令面板 | 草图。整页和半模态并列，未选定。 |
| `ia/logs-settings.svg` | 日志、设置 | 草图。日志含列表和详情；设置按组，不按三种无线拆首页。 |
| `ia/radios.svg` | 蓝牙、星闪、Wi-Fi | 草图。三条链路的关键页，仍进同一栈。 |
| `ia/sheet-terminal.svg` | 配对/连接半模态、终端 | 草图。半模态不叠两层；终端分摘要、接收、发送。 |
| `ia/wide.svg` | 宽屏分栏 | 草图。左侧是同一导航，返回键隐藏。栏宽未选定。 |

每张 SVG 旁有同名 PNG。
| `phone/home-default.svg` | 首页 | 默认 |
| `phone/home-empty.svg` | 首页 | 空 |
| `phone/home-error.svg` | 首页 | 探测失败 |
| `phone/home-permission.svg` | 首页 | 无权限 |
| `phone/debug-default.svg` | 调试 | 默认。蓝牙、Wi-Fi、星闪同一列表 |
| `phone/wifi-list-default.svg` | Wi-Fi 列表 | 默认 |
| `phone/wifi-list-empty.svg` | Wi-Fi 列表 | 空 |
| `phone/wifi-list-error.svg` | Wi-Fi 列表 | 未开启 |
| `phone/wifi-list-permission.svg` | Wi-Fi 列表 | 无权限 |
| `phone/wifi-detail.svg` | Wi-Fi 详情 | 默认 |
| `phone/wifi-connect.svg` | Wi-Fi 连接 | 半模态，下一步 |
| `phone/wifi-diag-default.svg` | 网络诊断 | 默认 |
| `phone/wifi-diag-error.svg` | 网络诊断 | 失败 |
| `phone/bt-scan-default.svg` | 蓝牙扫描 | 已搜到 |
| `phone/bt-scan-empty.svg` | 蓝牙扫描 | 空 |
| `phone/bt-scan-error.svg` | 蓝牙扫描 | 未开启 |
| `phone/bt-scan-permission.svg` | 蓝牙扫描 | 无权限 |
| `phone/bt-connect.svg` | 蓝牙串口连接 | 半模态 |
| `phone/bt-terminal.svg` | 串口终端 | 默认 |
| `phone/bt-terminal-empty.svg` | 串口终端 | 空 |
| `phone/bt-terminal-error.svg` | 串口终端 | 发送失败 |
| `phone/ble-scan.svg` | BLE 扫描 | 默认 |
| `phone/ble-gatt.svg` | BLE GATT | 默认 |
| `phone/nl-scan-default.svg` | 星闪扫描 | 已搜到 |
| `phone/nl-scan-empty.svg` | 星闪扫描 | 空 |
| `phone/nl-scan-error.svg` | 星闪扫描 | 本机不支持 |
| `phone/nl-scan-permission.svg` | 星闪扫描 | 无权限 |
| `phone/nl-ssap.svg` | 星闪 SSAP | 默认 |
| `phone/nl-transfer.svg` | 星闪数传 | 默认 |
| `phone/console-log.svg` | 控制台 · 日志 | 默认 |
| `phone/console-log-empty.svg` | 控制台 · 日志 | 空 |
| `phone/console-log-error.svg` | 控制台 · 日志 | 读失败 |
| `phone/console-network.svg` | 控制台 · 网络 | 默认 |
| `phone/console-command.svg` | 控制台 · 命令 | 默认 |
| `phone/settings-default.svg` | 我的 / 设置 | 默认 |
| `phone/settings-error.svg` | 我的 / 设置 | 导出路径不可写 |
| `wide/wifi-split.svg` | Wi-Fi 列表 + 详情 | 宽屏，同一条任务 |

每个 SVG 旁边有同名 PNG。
