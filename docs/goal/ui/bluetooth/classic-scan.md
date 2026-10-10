# 经典蓝牙扫描

目标名 `/bluetooth/classic-scan`。`main` 未注册，入口按缺口墙处理。来源：H2 状态标题 +「重新搜索」+ 列表；E3 卡片尺寸与连接中进度；E1 的「已连接」分组。

## 布局

上：标题 20「尚未搜索 / 正在搜索 / 搜索成功 / 搜索失败」。辅文 14。文字按钮在标题行右侧。无结果且未搜索时，中部 48vp Symbol（SDK 核对后）和一句「附近的设备会出现在这里」。有结果后图示收起。

`List` 两组：`ListItemGroup`「已连接」，`ListItemGroup`「可用」。行 76vp，圆角 16，左右 16，间距 12。主行名称 16，次行地址 14 `tnum`。右侧文字按钮「连接」，与正文间隔 12。连接中该按钮内放 20vp `LoadingProgress`，色 `brand`（E3 用了 `#FF0A59F7`，本文改 Token）。

已连接行不放「断开」。断开在终端页菜单，或本行 `bindMenu` 一项「断开」。长按不出删除，经典配对记录的删除不在本页发明。

## 树

```
Column
  Row
    Column
      Text 20
      Text 14
    Button TEXTUAL  「开始搜索」|「停止」|「重新搜索」
  List layoutWeight 1  或空态 Column
    ListItemGroup header 已连接
    ListItemGroup header 可用
      ListItem
        Row
          Column 名称 / 地址
          Button TEXTUAL 连接
```

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 标题「搜索成功」，按钮「重新搜索」，列表可见 |
| 按下 | 行 `interactive_pressed`；按钮按系统按下 |
| 禁用 | 适配器关：按钮 enabled false，标题「蓝牙已关闭」 |
| 空 | 搜索结束 0 台：标题「搜索成功」，辅文「没有设备」，无 List |
| 错误 | 标题「搜索失败」，辅文为 ViewModel 短句，按钮「重新搜索」 |
| 加载 | 标题「正在搜索」，标题旁 16vp `LoadingProgress`，已出现的行保留，按钮「停止」 |
| 无权限 | 权限墙替换整页 |
