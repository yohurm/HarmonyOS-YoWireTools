# 蓝牙概览

现路由 `/bluetooth/overview`，槽位「蓝牙」。模式：App shell 里的入口列表，不是扫描列表。扫描放在下一级，避免概览同时出现雷达和两张大卡。

数据：`BtOverviewViewModel` 已有加载、权限、适配器开关。规范不新增 Kit 调用。开关和权限的文案用 ViewModel 已有字段；没有字段的能力显示「未读取」。

## 布局

窄屏：标题栏「蓝牙」。内容不滚动时 `Column` 即可；入口超过一屏时改 `List`。左右 space.16，上 space.16。

1. 状态行：一枚胶囊（已开启 / 未开启 / 未授权 / 不可用）+ 右侧文字按钮。未授权时按钮「去授权」；未开启时「打开系统设置」。
2. `SubHeader`「入口」。
3. 两行 64vp：经典、低功耗。次行是一句能力（经典可连接 / 低功耗可扫描，或「未就绪」）。行尾箭头。行点击 push。禁用时行仍在，箭头变 text.disabled，点击无 push。

宽屏 ≥600vp：状态行与列表仍上下排列，不把两个入口做成左右海报。列表宽最多 600vp，剩余空白留在右侧，不拉伸行高。

## 组件树

```text
NavDestination 标题「蓝牙」
  Column padding 16  gap 16
    Row height 40  align center
      Row 胶囊 radius 4  padding 水平 8
        Text Caption_L  「已开启」|「未开启」|「未授权」|「不可用」
      Blank
      Button TEXTUAL height 40  「去授权」|「打开系统设置」| 不渲染
    SubHeader 「入口」
    List lanes 1
      ListItem height 64
        Row
          SymbolGlyph 24  蓝牙符号（资源名实现时核对 sys.symbol）
          Column gap 2
            Text Body_L 「经典」
            Text Body_S text.secondary 「可连接」|「未就绪」
          SymbolGlyph 16 箭头
      ListItem height 64  结构同上，文案「低功耗」
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 胶囊「已开启」成功色。两行次行都是「可连接」或「可扫描」。文字按钮不出现 |
| 按下 | 行表面叠按压色。文字按钮若存在，走 Button 按下态。胶囊不变色 |
| 禁用 | 适配器关：胶囊「未开启」警告色。两行次行「未就绪」，文字 text.disabled，点击不 push。右侧「打开系统设置」可点 |
| 空 | 不使用空列表插画。没有设备行可空。入口行始终两行 |
| 错 | 标题下插入一行 Body_M status.error，内容是 ViewModel 消息，例如读取适配器失败。入口行仍在，次行「未读取」 |
| 加载 | 胶囊位置改为 16vp LoadingProgress + Body_S「正在读取」。入口行保留，次行「未读取」，点击不 push |
| 无权限 | 整块换成 [权限墙](../app-shell/permission-gap-wall.md)：标题「需要蓝牙权限」，主按钮「去授权」。没有入口列表 |

## 对照

| 参考 | 取舍 |
| --- | --- |
| wifi 选择 | 不在概览放密码框 |
| 蓝牙扫描 | 雷达和「重新搜索」放在经典扫描，不放概览 |
| WLAN 信息 | 入口用列表行，不用左右双机 |
| NetworkQuery | 不用四格页签 |
| 智慧家居 | 只作为壳的底栏；这里不放设备海报 |
| 控制台 | 不放日志页签 |
| FastBle | 过滤不在概览 |
| BLE 通信 | 不放体温式数据卡 |
