# 应用壳

一个 `product/phone` HAP 里的一套壳。五个一级目的地与 `main` 上的底栏文案一致：工作台、蓝牙、网络、星闪、更多。

| 文件 | 内容 |
| --- | --- |
| [information-architecture.md](information-architecture.md) | 目的地与从属屏 |
| [navigation.md](navigation.md) | 一棵 Navigation、窄底栏、宽侧栏、对齐位 |
| [layout-patterns.md](layout-patterns.md) | 八个参考对应的布局模式 |
| [design-tokens.md](design-tokens.md) | 间距、圆角、字号、热区、颜色角色 |
| [density.md](density.md) | 工具类密度：层级、行、胶囊、宽窄 |
| [permission-gap-wall.md](permission-gap-wall.md) | 无权限与能力缺口时界面上有什么 |
| [color-scheme.md](color-scheme.md) | 浅色 / 深色 |

壳不读取射频 Kit，不在工作台弹出蓝牙、星闪或 WLAN 授权。
