import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { PageQuery, PageResult, Result, ResultError } from 'common_core';
import { CommandHistoryRecord } from '../domain/CommandHistoryRecord';
import { CommandTemplateRecord } from '../domain/CommandTemplateRecord';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RecordMapper } from '../rdb/RecordMapper';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbCountRunner } from '../rdb/RdbCountRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Command template and history repository per 05-§4.3.
 */
export class CommandRepository {
  private static instance: CommandRepository | undefined;

  private constructor() {
  }

  static getInstance(): CommandRepository {
    if (CommandRepository.instance === undefined) {
      CommandRepository.instance = new CommandRepository();
    }
    return CommandRepository.instance;
  }

  async saveTemplate(template: CommandTemplateRecord): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      await store.insert(DatabaseSchema.TABLE_COMMAND_TEMPLATE, {
        id: template.id,
        name: template.name,
        module: template.module,
        protocol: template.protocol,
        payload_encoding: template.payloadEncoding,
        payload: template.payload,
        line_ending: template.lineEnding,
        write_mode: template.writeMode,
        repeat_policy: template.repeatPolicyJson,
        timeout_ms: template.timeoutMs,
        tags: template.tagsJson,
        created_at_ms: template.createdAtMs,
        updated_at_ms: template.updatedAtMs
      });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async deleteTemplate(id: string): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_COMMAND_TEMPLATE);
      predicates.equalTo('id', id);
      await store.delete(predicates);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async listTemplates(offset: number, limit: number): Promise<Result<PageResult<CommandTemplateRecord>>> {
    return this.listTemplatesFiltered('', offset, limit);
  }

  async listTemplatesByModule(module: string, offset: number, limit: number): Promise<Result<PageResult<CommandTemplateRecord>>> {
    return this.listTemplatesFiltered(module, offset, limit);
  }

  private async listTemplatesFiltered(module: string, offset: number, limit: number): Promise<Result<PageResult<CommandTemplateRecord>>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const countPredicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_COMMAND_TEMPLATE);
    if (module.length > 0) {
      countPredicates.equalTo('module', module);
    }
    const counted = RdbCountRunner.countSync(store, countPredicates);
    if (!counted.success) {
      return Result.fail(counted.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Count failed'));
    }
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_COMMAND_TEMPLATE);
    if (module.length > 0) {
      predicates.equalTo('module', module);
    }
    predicates.orderByDesc('updated_at_ms');
    predicates.limitAs(limit);
    predicates.offsetAs(offset);
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
    }
    const set = queried.value;
    try {
      const items: CommandTemplateRecord[] = [];
      if (set.rowCount > 0) {
        RdbResultSetReader.goToFirstRow(set);
        do {
          items.push(RecordMapper.commandTemplateFromRow(set));
        } while (RdbResultSetReader.goToNextRow(set));
      }
      return Result.ok(new PageResult(items, counted.value ?? 0, new PageQuery(offset, limit)));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }

  async listHistory(offset: number, limit: number, sessionId: string = ''): Promise<Result<PageResult<CommandHistoryRecord>>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const countPredicates = CommandRepository.buildHistoryPredicates(sessionId);
    const counted = RdbCountRunner.countSync(store, countPredicates);
    if (!counted.success) {
      return Result.fail(counted.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Count failed'));
    }
    const predicates = CommandRepository.buildHistoryPredicates(sessionId);
    predicates.orderByDesc('sent_at_ms');
    predicates.limitAs(limit);
    predicates.offsetAs(offset);
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
    }
    const set = queried.value;
    try {
      const items: CommandHistoryRecord[] = [];
      if (set.rowCount > 0) {
        RdbResultSetReader.goToFirstRow(set);
        do {
          items.push(RecordMapper.commandHistoryFromRow(set));
        } while (RdbResultSetReader.goToNextRow(set));
      }
      return Result.ok(new PageResult(items, counted.value ?? 0, new PageQuery(offset, limit)));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }

  async appendHistory(history: CommandHistoryRecord): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      await store.insert(DatabaseSchema.TABLE_COMMAND_HISTORY, {
        id: history.id,
        template_id: history.templateId,
        session_id: history.sessionId,
        module: history.module,
        protocol: history.protocol,
        payload: history.payload,
        payload_encoding: history.payloadEncoding,
        sent_at_ms: history.sentAtMs,
        result: history.resultJson,
        attributes: history.attributesJson
      });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  private static buildHistoryPredicates(sessionId: string): relationalStore.RdbPredicates {
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_COMMAND_HISTORY);
    if (sessionId.length > 0) {
      predicates.equalTo('session_id', sessionId);
    }
    return predicates;
  }
}
