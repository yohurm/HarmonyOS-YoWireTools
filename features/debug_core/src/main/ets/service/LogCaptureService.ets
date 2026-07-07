import { IdGenerator, Result, TimeUtil } from 'common_core';
import { LogRepository } from 'common_storage';
import { AppLogger, AppLogTag, LogParams } from 'common_platform';
import { Direction, DisplayHint, LogRecordType, ModuleType, ProtocolType } from '../domain/enums/DomainEnums';
import { DebugEvent } from '../domain/model/DebugEvent';
import { DebugLogRecord } from '../domain/model/DebugLogRecord';
import { LogMapper } from '../mapper/LogMapper';
import { SessionStatePatch } from '../runtime/DebugSessionState';
import { SessionRuntimeStore } from '../runtime/SessionRuntimeStore';
import { NormalizedPayload, PayloadNormalizer } from './PayloadNormalizer';

const logger = new AppLogger(AppLogTag.SESSION);

/**
 * Log capture pipeline: normalize -> persist -> runtime bus per §5.4.
 */
export class LogCaptureService {
  private static instance: LogCaptureService | undefined;
  private readonly logRepository: LogRepository;
  private readonly runtimeStore: SessionRuntimeStore;

  private constructor(
    logRepository: LogRepository = LogRepository.getInstance(),
    runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance()
  ) {
    this.logRepository = logRepository;
    this.runtimeStore = runtimeStore;
  }

  static getInstance(): LogCaptureService {
    if (LogCaptureService.instance === undefined) {
      LogCaptureService.instance = new LogCaptureService();
    }
    return LogCaptureService.instance;
  }

  async captureBytes(
    sessionId: string,
    module: ModuleType,
    protocol: ProtocolType,
    direction: Direction,
    bytes: Uint8Array,
    appCode: string = '',
    nativeCode: string = ''
  ): Promise<Result<DebugLogRecord>> {
    const normalized = PayloadNormalizer.normalize(bytes, direction, module, protocol);
    return this.captureRecord(sessionId, module, protocol, direction, normalized, bytes, appCode, nativeCode);
  }

  async captureEvent(event: DebugEvent, payload?: Uint8Array): Promise<Result<DebugLogRecord>> {
    const normalized = new NormalizedPayload(event.summary, DisplayHint.NONE, event.eventType);
    const session = this.runtimeStore.getSession(event.sessionId);
    const module = session?.module ?? event.moduleType;
    const protocol = session?.protocol ?? ProtocolType.NONE;
    return this.captureRecord(
      event.sessionId,
      module,
      protocol,
      event.direction as Direction,
      normalized,
      payload ?? new Uint8Array(0),
      event.appCode,
      event.nativeCode
    );
  }

  private async captureRecord(
    sessionId: string,
    module: ModuleType,
    protocol: ProtocolType,
    direction: Direction,
    normalized: NormalizedPayload,
    bytes: Uint8Array,
    appCode: string,
    nativeCode: string
  ): Promise<Result<DebugLogRecord>> {
    const record = new DebugLogRecord(
      IdGenerator.next('log'),
      sessionId,
      module,
      protocol,
      direction,
      normalized.recordType,
      TimeUtil.nowMs(),
      bytes.length,
      normalized.summary,
      normalized.displayHint,
      undefined,
      TimeUtil.monotonicMs(),
      appCode,
      nativeCode
    );
    const indexRecord = LogMapper.toIndexRecord(record);
    const payload = bytes.length > 0 ? bytes : undefined;
    const saved = await this.logRepository.append(indexRecord, payload);
    if (!saved.success) {
      logger.error(`log_capture failed, sessionId=${sessionId}`);
      return Result.fail(saved.error!);
    }
    const inDelta = direction === Direction.INBOUND ? bytes.length : 0;
    const outDelta = direction === Direction.OUTBOUND ? bytes.length : 0;
    this.runtimeStore.applyPatch(sessionId, new SessionStatePatch(
      undefined,
      undefined,
      undefined,
      normalized.summary,
      inDelta,
      outDelta,
      1
    ));
    logger.params('log_capture', LogParams.create()
      .put('sessionId', sessionId)
      .put('direction', `${direction}`)
      .put('size', bytes.length));
    return Result.ok(record);
  }
}
