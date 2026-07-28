# yolog 日志模块设计

## 1. 定位

`common/yolog` 是应用**观测性日志**底座，负责：

1. HiLog 输出（开发态 / 系统观测）
2. 应用沙箱文件日志（`filesDir/yolog/`，可导出、可轮转）
3. 内存环形缓冲（崩溃邻近 dump）

它与 `debug_core` 的**会话证据日志**（`DebugLogRecord` + RDB + payload 分片）职责分离：

| | yolog | debug_core 会话日志 |
| --- | --- | --- |
| 目的 | 稳定性 / 排障 / 运维 | 调试会话可复现 |
| 内容 | 短文本、状态、错误码 | 原始 payload + 结构化事件 |
| 存储 | `filesDir/yolog/` | RDB + `files/debug_payload/` |
| HiLog | 是 | 否（仅元信息旁路 YoLog） |

## 2. 模块依赖

```text
yolog          # 零 common 依赖；仅 Kit
platform       # 依赖 yolog
storage        # 依赖 yolog
debug_core     # 依赖 yolog
product/phone  # bootstrap YoLog
```

## 3. 架构

```text
YoLog / YoLogger
  -> LevelFilter + RateLimitFilter
  -> HiLogAppender
  -> MemoryRingAppender
  -> FileAppender -> AsyncLogQueue -> rotate/clean -> filesDir/yolog/
```

## 4. Bootstrap

```text
EntryAbility.onCreate
  -> YoLog.bootstrapFromFilesDir(context.filesDir)
EntryAbility.onBackground / LifecycleCoordinator.onAppBackground
  -> YoLog.flush()
EntryAbility.onDestroy
  -> YoLog.terminate()
PlatformBootstrap.initialize
  -> YoLog.ensureBootstrapped(filesDir)  // 兜底
```

debug 构建：全局 / HiLog / 文件默认 DEBUG。  
release 构建：默认 INFO。

## 5. 文件策略

| 项 | 默认 |
| --- | --- |
| 目录 | `{filesDir}/yolog/` |
| 当前文件 | `app.current.log` |
| 轮转名 | `app.yyyy-MM-dd.N.log` |
| 单文件上限 | 5 MB |
| 保留个数 | 10（不含 current） |
| 缓冲 | 64 行 / 800ms 刷盘；ERROR+ 立即刷 |

## 6. 公共 API

```typescript
import { YoLog, YoLogTag, LogParams, LogLevel } from 'yolog';

const log = YoLog.tag(YoLogTag.APP);
log.i('platform_bootstrap successful');
log.params('permission_granted', LogParams.create().put('scenario', id));
log.state('spp', 'IDLE', 'CONNECTING', 'user');
log.d(() => expensive());

await YoLog.flush();
YoLog.listFiles();
YoLog.dumpRing();
await YoLog.terminate();
```

Tag 约定（ASCII ≤31）：`YoWire.App` / `Perm` / `Cap` / `Life` / `Session`。

## 7. 观测规范（对齐原 §11）

1. 正常高频 payload 不进 YoLog / HiLog。
2. 状态迁移：`state_name:s1->s2, reason=xxx`。
3. 参数：`name=value`。
4. HiLog 单条按字节拆分（≤4000）。
5. 文件 IO 失败只降级 HiLog，不抛业务。

## 8. 非目标

1. 云上报、日志加密（后续可选）。
2. 装饰器自动追踪。
3. 系统 `hilog setOutputType` 沙箱 API（文档未稳定，不依赖）。
4. 协议 payload 写入 yolog 文件。
