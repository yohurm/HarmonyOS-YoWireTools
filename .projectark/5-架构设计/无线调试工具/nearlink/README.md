# 星闪模块详细设计索引

本目录细化 NearLink/星闪模块设计。依据 PRD、`04-星闪模块架构设计.md`、WSL 官方参考文档中的 NearLink manager、scan、SSAP、dataTransfer、remoteDevice、常见问题和示例工程编写。

## 文档列表

1. `01-能力探测扫描与广播解析设计.md`
   - NearLink 支持状态、开关状态、扫描过滤、随机地址、广播字段解析。
2. `02-SSAP客户端服务属性与MTU设计.md`
   - SSAP Client、连接状态、服务发现、Property 读写、通知、MTU。
3. `03-dataTransfer端口数传配对加密与拥塞设计.md`
   - dataTransfer port、连接、收发、拥塞、配对加密、资源释放。

## 星闪模块总原则

1. NearLink 必须先做设备支持、系统开关、权限三层探测。
2. 所有 NearLink API 仅按 Stage 模型设计。
3. 扫描结果地址是随机地址，不能作为长期稳定身份。
4. API 13 扫描过滤器不能全空；API 26 可传 null 但官方不建议。
5. SSAP 一个远端设备只创建一个 Client 实例。
6. dataTransfer 不保证链路加密，加密必须走配对并验证 ACB 状态。
