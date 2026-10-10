import { Result, ResultError } from 'common_core';
import { DebugSessionSummary } from '../runtime/DebugSessionState';
import { SessionLogQuery } from '../domain/model/SessionLogQuery';
import { WorkbenchLogLine } from '../domain/model/WorkbenchLogLine';
import { SessionLogRepositoryContract } from '../domain/repository/SessionLogRepositoryContract';
import { SessionLogRepository } from '../data/repository/SessionLogRepository';
import { SessionRuntimeStore } from '../runtime/SessionRuntimeStore';
import { TransportSessionRegistry } from '../service/TransportSessionRegistry';

export { WorkbenchLogLine } from '../domain/model/WorkbenchLogLine';

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
  private readonly repository: SessionLogRepositoryContract;

  constructor(repository: SessionLogRepositoryContract = new SessionLogRepository()) {
    this.repository = repository;
  }

  async execute(query: SessionLogQuery): Promise<Result<WorkbenchLogLine[]>> {
    const listed = await this.repository.list(query);
    if (!listed.success || listed.value === undefined) {
      return Result.fail(listed.error ?? new ResultError('YW-LOG-1001', 'Session log list failed'));
    }
    return Result.ok(listed.value.items);
  }
}

export class ExportSessionLogUseCase {
  private readonly repository: SessionLogRepositoryContract;

  constructor(repository: SessionLogRepositoryContract = new SessionLogRepository()) {
    this.repository = repository;
  }

  execute(module: string, keyword: string): Promise<Result<string>> {
    return this.repository.exportSession('', module, keyword);
  }
}

export class ClearSessionLogUseCase {
  private readonly repository: SessionLogRepositoryContract;

  constructor(repository: SessionLogRepositoryContract = new SessionLogRepository()) {
    this.repository = repository;
  }

  async execute(lines: WorkbenchLogLine[], clearAll: boolean): Promise<Result<void>> {
    const seen: string[] = [];
    for (let i = 0; i < lines.length; i++) {
      const sessionId = lines[i].sessionId;
      if (sessionId.length > 0 && seen.indexOf(sessionId) < 0) {
        seen.push(sessionId);
      }
    }
    for (let i = 0; i < seen.length; i++) {
      const deleted = await this.repository.deleteBySession(seen[i]);
      if (!deleted.success) {
        return Result.fail(deleted.error ?? new ResultError('YW-LOG-1002', 'Session log delete failed'));
      }
    }
    if (clearAll) {
      const cleaned = await this.repository.cleanup(0);
      if (!cleaned.success) {
        return Result.fail(cleaned.error ?? new ResultError('YW-LOG-1003', 'Session log cleanup failed'));
      }
    }
    return Result.ok(undefined);
  }
}
