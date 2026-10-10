# 权限与缺口墙

界面不申请权限，不调用 Kit。缺权限时整块内容换成墙，不在列表底下叠一层不可点的灰行假装还能用。

墙的树沿 M5 通用状态服务：内容在中部，主按钮贴底，不在标题旁边横排三颗演示芯片。

```
Column  宽 100%  高 100%  background background_secondary
  Column layoutWeight 1  justify Center  padding 16
    Text 20 Bold font_primary     标题由 ViewModel 给出，例如「需要蓝牙权限」
    Text 14 font_secondary        说明，上间隔 8
  Button EMPHASIZED             文案「去授权」  最宽 448  左右 16  底 16
```

按下：按钮 `interactive_pressed`。禁用：没有恢复动作时不渲染按钮，只留说明。加载：墙不出现，页面走自己的加载态。错误：权限被拒绝且用户点过「去授权」后，说明改为 ViewModel 的拒绝原因，按钮仍在。空：不适用。无权限：就是这面墙。

哪个权限字符串、哪一次系统弹窗，由未合并契约决定。墙只显示 ViewModel 已经放进状态里的标题和说明。

路由还没有注册时，入口行可以显示，点击不 `push`。次行追加「不能打开」，颜色 `font_secondary`。不造一个假页面去填 §7.2 的名字。
