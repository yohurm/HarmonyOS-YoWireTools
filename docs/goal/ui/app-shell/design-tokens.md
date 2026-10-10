# Design Token

手机档。实现时映射到资源，本 PR 不改 `youi_kit`，不改 `color.json`。名字是规范名，不是 Kit 类名。

度量来自 `yohurm/HarmonyOS-Developer-docs`：

- 间隔：`设计/设计指南/通用设计基础/视觉风格/间隔参数.md`（4vp/8vp 网格；手机左右 16vp；卡片 12vp；有边界控件 16vp；无边界 8vp；主次文本上下 2vp、左右 8vp）
- 圆角：`圆角参数.md`（4 / 8 / 16 / 20 / 32vp）
- 字号：`文本排版.md` 手机列。工具界面最小用到 Caption_L 12vp，不用 Caption_M 10vp 做列表次行
- 列表行：`控件/容器类/列表.md` 效率型 48、56、64vp
- 底栏：`底部页签.md` 悬浮式 56vp，图标 24vp
- 热区：`触摸热区设置.md` 写明 API 26 起 Button、Toggle 的 Button 模式、Select、Chip 默认最小命中高度为 32vp。本应用主操作和列表行按设计指南做到更高，并用 `responseRegion` 保证图标按钮命中不小于 40×40vp

## 间距

| Token | vp | 用在 |
| --- | --- | --- |
| space.2 | 2 | 主行与次行 |
| space.4 | 4 | 色点与文字、胶囊内边 |
| space.8 | 8 | 无边界控件、图标与文字 |
| space.12 | 12 | 卡片之间、列表右侧元素与正文 |
| space.16 | 16 | 屏幕左右边距、有边界控件、sheet 内边距 |
| space.24 | 24 | 结果标题区与列表之间 |
| space.32 | 32 | 空态图示与按钮 |

## 圆角

| Token | vp | 用在 |
| --- | --- | --- |
| radius.4 | 4 | 状态胶囊、色点 |
| radius.8 | 8 | 列表内小图标底 |
| radius.16 | 16 | 内容卡、数据卡 |
| radius.20 | 20 | 按钮、Select、TextInput。高度 40vp 时呈胶囊，与 wifi 选择字段一致 |
| radius.32 | 32 | bindSheet、AlertDialog、CustomDialog |

同一层级只用一档。不把卡片做成 20、按钮做成 16。

## 字号（手机）

| Token | 对应 | 字重 | vp |
| --- | --- | --- | --- |
| type.title.m | Title_M | Bold | 24 |
| type.title.s | Title_S | Bold | 20 |
| type.subtitle.m | Subtitle_M | Medium | 16 |
| type.subtitle.s | Subtitle_S | Medium | 14 |
| type.body.l | Body_L | Medium | 16 |
| type.body.m | Body_M | Regular | 14 |
| type.body.s | Body_S | Regular | 12 |
| type.caption.l | Caption_L | Medium | 12 |

扫描结果标题用 type.title.m。页标题走系统标题栏，不在内容区再放一个 Title_L。数据卡上的数字用 type.title.s。日志行用 type.body.s。

字体是 HarmonyOS Sans。十六进制和计数值加 `fontFeature` `tnum`。

## 尺寸

| Token | vp | 用在 |
| --- | --- | --- |
| touch.40 | 40 | 文字按钮、图标按钮、Select、页签的最小高度。图标视觉可以是 24，命中用 responseRegion 扩到 40 |
| row.48 | 48 | 单行设置、侧栏项、日志行 |
| row.56 | 56 | 带一行辅文的设置 |
| row.64 | 64 | 扫描结果、WLAN 列表（主行 +「加密」或地址） |
| icon.24 | 24 | 列表主图标、底栏图标 |
| icon.16 | 16 | 行内锁、信息 |
| bar.56 | 56 | 窄屏悬浮底栏 |
| sheet.pad | 16 | sheet 内容边距 |
| detail.label | 8 | 详情里空值灰条的高度 |

## 颜色角色

不写死十六进制。浅色资源与深色资源成对，规则见 [color-scheme.md](color-scheme.md)。

| 角色 | 界面 |
| --- | --- |
| canvas | 页面底。截图里是灰底，卡片是白的。对应二级背景，不是卡片色 |
| surface | 列表组、输入框、数据卡 |
| text.primary | 主行、结果标题 |
| text.secondary | 辅文、详情标签、未选中页签 |
| text.disabled | 禁用行 |
| brand | 一颗主按钮的填充、文字按钮、选中页签、当前底栏项 |
| on.brand | 主按钮上的字 |
| status.success / warning / error / info | 胶囊字色。胶囊底用对应的浅容器色，圆角 radius.4 |
| scrim | 半模态遮罩 |
| divider | 组与组之间。行与行能靠 8vp 间距分开时不加线 |

状态胶囊只有这四色加中性（中性用 text.secondary，底用 canvas）。不为每种协议加一种颜色。

## 按下、禁用

主按钮用系统 `Button` 的 EMPHASIZED，按下和禁用走控件自带状态，不另画一层。列表行按下时表面叠一层按压色（仍是 surface 的按下资源），松手恢复。禁用行：文字 text.disabled，尾部按钮 `enabled` false，不响应按下。
