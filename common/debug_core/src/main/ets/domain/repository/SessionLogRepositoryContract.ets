import { PageResult, Result } from 'common_core';
import { SessionLogQuery } from '../model/SessionLogQuery';
import { WorkbenchLogLine } from '../model/WorkbenchLogLine';

export interface SessionLogRepositoryContract {
  list(query: SessionLogQuery): Promise<Result<PageResult<WorkbenchLogLine>>>;
  deleteBySession(sessionId: string): Promise<Result<void>>;
  cleanup(retentionDays: number): Promise<Result<number>>;
  exportSession(sessionId: string, module: string, keyword: string): Promise<Result<string>>;
}
