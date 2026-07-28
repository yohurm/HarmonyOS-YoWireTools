import { Result } from 'common_core';
import { LogQuery, LogRepository } from 'common_storage';
import { DebugSessionSummary } from '../runtime/DebugSessionState';
import { SessionRuntimeStore } from '../runtime/SessionRuntimeStore';
import { TransportSessionRegistry } from '../service/TransportSessionRegistry';

export class WorkbenchLogLine {
  readonly id: string;
  readonly timestampMs: number;
  readonly direction: string;
  readonly summary: string;
  readonly payloadSize: number;
  readonly appCode: string;
  readonly nativeCode: string;

  constructor(
    id: string,
    timestampMs: number,
    direction: string,
    summary: string,
    payloadSize: number,
    appCode: string = '',
    nativeCode: string = ''
  ) {
    this.id = id;
    this.timestampMs = timestampMs;
    this.direction = direction;
    this.summary = summary;
    this.payloadSize = payloadSize;
    this.appCode = appCode;
    this.nativeCode = nativeCode;
  }
}

/**
 * Workbench queries against real session registry and log repository.
 */
export class LoadWorkbenchOverviewUseCase {
  private readonly runtimeStore: SessionRuntimeStore;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.runtimeStore = runtimeStore;
    this.transportRegistry = transportRegistry;
  }

  execute(): Result<DebugSessionSummary[]> {
    const summaries = this.runtimeStore.listActiveSummaries();
    const transportIds = this.transportRegistry.listSessionIds();
    if (summaries.length === 0 && transportIds.length > 0) {
      const fallback: DebugSessionSummary[] = [];
      for (let i = 0; i < transportIds.length; i++) {
        const session = this.runtimeStore.getSession(transportIds[i]);
        if (session !== undefined) {
          fallback.push(new DebugSessionSummary(
            session.id,
            session.displayName,
            session.module,
            session.protocol,
            session.state,
            session.startAtMs,
            0
          ));
        }
      }
      return Result.ok(fallback);
    }
    return Result.ok(summaries);
  }
}

export class LoadSessionLogPreviewUseCase {
  async execute(sessionId: string, limit: number = 50): Promise<Result<WorkbenchLogLine[]>> {
    if (sessionId.length === 0) {
      return Result.ok([]);
    }
    const listed = await LogRepository.getInstance().list(new LogQuery(sessionId, 0, limit));
    if (!listed.success || listed.value === undefined) {
      return Result.fail(listed.error!);
    }
    const lines: WorkbenchLogLine[] = [];
    for (let i = 0; i < listed.value.items.length; i++) {
      const record = listed.value.items[i];
      lines.push(new WorkbenchLogLine(
        record.id,
        record.timestampMs,
        record.direction,
        record.summary,
        record.payloadSize,
        record.appCode,
        record.nativeCode
      ));
    }
    return Result.ok(lines);
  }
}
