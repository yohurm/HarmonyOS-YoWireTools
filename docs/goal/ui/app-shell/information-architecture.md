# 信息架构

来源：E4 一级页签；E6 设置分组；E2 四个网络场景；H6 控制台分类；现有 `AppRoutes` 与架构 §7.2 的屏幕名。§7.2 未合并进运行时代码的路由，下面标成「目标名」。

```
工作台
  最近会话
  日志中心          目标名 /log/list
    日志详情        目标名 /log/detail
  命令面板          目标名 /command/list
蓝牙
  总览              /bluetooth/overview
  经典扫描          目标名 /bluetooth/classic-scan
  SPP               /bluetooth/spp
    SPP 终端        /bluetooth/spp/terminal
  BLE 扫描          /bluetooth/ble
    GATT 详情       目标名 /bluetooth/gatt-detail
网络
  总览              /wifi/overview
  扫描              目标名，对齐 E1 列表
  链路详情          目标名，对齐 E1 详情
  诊断              目标名 /wifi/diagnostics（连接 / 状态 / 定位 / 故障）
  Socket 终端       目标名 /wifi/socket-terminal
  HTTP              目标名 /wifi/http-client
  WebSocket         目标名 /wifi/websocket
  局域网发现        目标名 /wifi/lan-discovery
星闪
  总览              /nearlink/overview
  扫描              目标名 /nearlink/scan
  SSAP              目标名 /nearlink/ssap-client
  数据传输          目标名 /nearlink/data-transfer
更多
  枢纽              /more/hub
  设置              目标名 /settings/index
```

模块页由各自 HAR 提供内容构建器，壳只负责栈和页签。HAR 之间不互相引用界面（E5 navigation-router 的方向；该仓库本次未克隆，不把它的 API 写进树）。跨模块只通过壳上的路由名。

工作台不放三张「蓝牙 / 网络 / 星闪」大卡去重复底栏。底栏已经是这三项目的地。
