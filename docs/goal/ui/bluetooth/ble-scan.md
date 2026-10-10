# BLE 扫描

现路由 `/bluetooth/ble`。模式：过滤后扫描（FastBle 的顺序）+ 扫描列表。过滤表单在 sheet，不嵌在每一行。

## 布局

标题栏「低功耗」，右侧文字按钮「过滤」。

头与经典扫描相同：标题、辅文、开始或重新搜索。有行后 `List` 64vp：名称、地址 Body_S、次行 RSSI 与是否可连接。不可连接的行仍显示，右侧按钮文案「不可连接」且 enabled false，行点击不 push。可连接行右侧「连接」，点击 push GATT 详情并带上地址参数；连接过程中的进度在详情页，不在扫描页打开第二张 sheet。

过滤 sheet：`Select` 或 `TextInput` 四项里只放 ViewModel 已有的条件（名称、服务 UUID、RSSI）。没有的字段不画。主按钮「用此过滤重新扫描」，关闭 sheet 并开始扫描。点遮罩关闭且不扫描。

空过滤：若 ViewModel 允许，主按钮可点，sheet 内 Body_S「未填写条件将看到更多设备」。若不允许，主按钮 enabled false，这句改为「至少填一项」。

宽屏：列表最大宽 600vp。sheet 居中。不在扫描页右侧展开 GATT。

## 组件树

```text
NavDestination 「低功耗」
  标题栏 Button TEXTUAL 「过滤」
  Column
    结果头 同经典扫描
    List
      ListItem 64
        Column
          Text Body_L 名称或「未命名」
          Text Body_S 地址
          Text Body_S  「RSSI -60」 「可连接」|「不可连接」
        Button TEXTUAL 「连接」|「不可连接」
bindSheet 「过滤」
  Column gap 16 padding 16
    TextInput 提示「名称」
    TextInput 提示「服务 UUID」
    TextInput 提示「最低 RSSI」 type Number
    Text Body_S 空过滤说明
    Button EMPHASIZED 「用此过滤重新扫描」
```

## 状态

| 态 | 界面 |
| --- | --- |
| 默认 | 标题「搜索成功」，列表有行，可连接行的「连接」可点 |
| 按下 | 行与按钮按下态。过滤字段获焦时边框用 brand，这是 TextInput 的焦点，不是按下 |
| 禁用 | 蓝牙未开：与经典扫描相同的缺口短结构。「不可连接」按钮始终禁用 |
| 空 | 「尚未搜索」+ 图示 +「开始搜索」。无「已搜索到设备」 |
| 错 | 「搜索失败」+ 消息。过滤 sheet 若开着，错误写在 sheet 结果行，不关 sheet |
| 加载 | 「正在搜索」+ LoadingProgress。新行插入列表。按钮变为「停止」 |
| 无权限 | 权限墙。过滤按钮不渲染 |

## 对照

| 参考 | 取舍 |
| --- | --- |
| wifi 选择 | 过滤 sheet 用输入而不是 Wi-Fi 下拉；仍是一颗主按钮 |
| 蓝牙扫描 | 结果头与列表 |
| WLAN 信息 | 行是双行文本，没有「加密」锁图标，除非 ViewModel 提供安全字段 |
| NetworkQuery | 不用场景 Tab |
| 智慧家居 | 不用设备海报 |
| 控制台 | 广播原文不在本列表展开，进详情再看 |
| FastBle | 采用「先过滤再扫」。没有它的截图，不模仿未见过的控件皮肤 |
| BLE 通信 | RSSI 留在次行，不做成全宽数据卡 |
