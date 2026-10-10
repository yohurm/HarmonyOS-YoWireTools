# SSAP 客户端

目标路由从扫描行 push，路径名等契约对齐（架构里有 SSAP 客户端，第 7.2 节写的是 `/nearlink/ssap-client`）。模式：list + detail，结构同 GATT 详情。服务组、属性行、读与写、通知 Toggle、MTU 一张数据卡。

差异只在文案：标题「SSAP」，分组头是服务标识，写入 sheet 的主按钮「写入」，失败行用 ViewModel 消息。未连接时胶囊「未连接」，读写真通知禁用。

不连接第二颗主按钮。发现服务若还没完成，树区显示「正在发现服务」和 LoadingProgress，不显示空文案「还没有服务」。发现结束且零服务才用空文案。

状态矩阵与 [GATT 详情](../bluetooth/gatt-detail.md) 相同，把「服务」理解成 SSAP 服务，把权限墙文案换成「需要星闪权限」。

## 对照

采用 WLAN 的标签/值与宽屏分栏、BLE 通信的单张数值卡（仅 MTU）、wifi 选择的 sheet 节奏（写入）。不采用扫描雷达、场景 Tab、家居壳、控制台页签、FastBle 过滤。
