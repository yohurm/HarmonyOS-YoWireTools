# 蓝牙总览

路由 `/bluetooth/overview`（已在 `main`）。来源：扫描列表的入口简化，不用 H2 的雷达；E6 的分组行；密度文档的双行 64vp。

焦点是两行入口：经典、低功耗。状态胶囊在标题下，不是第三张大卡。

## 布局

`Column` 边距 16，背景 `background_secondary`。

1. 标题沿壳的页签，本页不再重复「蓝牙」大标题。
2. 状态行高 56：左文案「蓝牙」14 `font_secondary`，右胶囊（开 / 关 / 未授权）。
3. `List` 两项，行高 64，圆角卡片，间距 12。主行 16「经典蓝牙」「低功耗」，次行 14 一句能力或「未就绪」。行尾 16vp 箭头。

经典点击：若 `/bluetooth/spp` 已注册则 `push`（`main` 已注册 SPP 与终端）。低功耗点击 `push` `/bluetooth/ble`。经典扫描目标名 `/bluetooth/classic-scan` 尚未注册时，经典行次行写「不能打开」，点击不跳。

## 树

```
Column
  Row 高 56
    Text 「蓝牙」
    Blank
    胶囊 Text
  List space 12
    ListItem 高 64  经典
    ListItem 高 64  低功耗
```

## 状态

| 态 | 表现 |
| --- | --- |
| 默认 | 胶囊「已开启」用 confirm 浅底。两行可点 |
| 按下 | 行背景 `interactive_pressed` |
| 禁用 | 适配器关：胶囊「已关闭」`font_secondary`，行仍在，箭头 `icon_fourth`，点击不 push |
| 空 | 没有「空设备」。无会话不是本页的空 |
| 错误 | 标题下 14 `warning` 一行原因，入口保留 |
| 加载 | 胶囊换成 16vp `LoadingProgress` 加「正在读取」。行次行「未读取」，不 push |
| 无权限 | 整页换成权限墙，不渲染两行 |
