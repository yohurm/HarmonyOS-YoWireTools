import { PageQuery, PageResult, Result, ResultError } from 'common_core';
import { CommandRepository, CommandTemplateRecord, StoreErrorCodes } from 'common_storage';
import { CommandFavoriteMark } from '../../command/CommandFavoriteMark';
import {
  CommandTemplate,
  CommandVariable,
  RepeatPolicy
} from '../../domain/model/CommandTemplate';
import {
  LineEndingMode,
  ModuleType,
  PayloadEncoding,
  ProtocolType,
  WriteMode
} from '../../domain/enums/DomainEnums';
import { CommandRepositoryContract } from '../../domain/repository/CommandRepositoryContract';

export class CommandTemplateRepository implements CommandRepositoryContract {
  private readonly store: CommandRepository;

  constructor(store: CommandRepository = CommandRepository.getInstance()) {
    this.store = store;
  }

  async listTemplates(module: ModuleType, offset: number, limit: number): Promise<Result<PageResult<CommandTemplate>>> {
    const listed = await this.store.listTemplatesByModule(`${module}`, offset, limit);
    if (!listed.success || listed.value === undefined) {
      return Result.fail(listed.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'List templates failed'));
    }
    const items: CommandTemplate[] = [];
    const records = listed.value.items;
    for (let i = 0; i < records.length; i++) {
      items.push(CommandTemplateRepository.toDomain(records[i]));
    }
    return Result.ok(new PageResult(items, listed.value.total, new PageQuery(offset, limit)));
  }

  async saveTemplate(template: CommandTemplate): Promise<Result<void>> {
    return this.store.saveTemplate(CommandTemplateRepository.toRecord(template));
  }

  async deleteTemplate(id: string): Promise<Result<void>> {
    return this.store.deleteTemplate(id);
  }

  private static toDomain(record: CommandTemplateRecord): CommandTemplate {
    const tags = CommandTemplateRepository.readTags(record.tagsJson);
    const favorite = CommandTemplateRepository.containsFavorite(tags);
    return new CommandTemplate(
      record.id,
      record.name,
      record.payload,
      CommandTemplateRepository.encoding(record.payloadEncoding),
      CommandTemplateRepository.lineEnding(record.lineEnding),
      CommandTemplateRepository.writeMode(record.writeMode),
      record.timeoutMs,
      CommandTemplateRepository.moduleOf(record.module),
      CommandTemplateRepository.protocolOf(record.protocol),
      undefined,
      tags,
      [] as CommandVariable[],
      record.createdAtMs,
      record.updatedAtMs,
      favorite
    );
  }

  private static toRecord(template: CommandTemplate): CommandTemplateRecord {
    const tags: string[] = [];
    for (let i = 0; i < template.tags.length; i++) {
      if (template.tags[i] !== CommandFavoriteMark.TAG) {
        tags.push(template.tags[i]);
      }
    }
    if (template.favorite) {
      tags.push(CommandFavoriteMark.TAG);
    }
    const repeatJson = template.repeatPolicy === undefined ? '' : CommandTemplateRepository.repeatJson(template.repeatPolicy);
    return new CommandTemplateRecord(
      template.id,
      template.name,
      `${template.module}`,
      `${template.protocol}`,
      `${template.payloadEncoding}`,
      template.payload,
      `${template.lineEnding}`,
      `${template.writeMode}`,
      repeatJson,
      template.timeoutMs,
      CommandTemplateRepository.writeTags(tags),
      template.createdAtMs,
      template.updatedAtMs
    );
  }

  private static repeatJson(policy: RepeatPolicy): string {
    return `{"intervalMs":${policy.intervalMs},"maxCount":${policy.maxCount}}`;
  }

  private static writeTags(tags: string[]): string {
    let body = '';
    for (let i = 0; i < tags.length; i++) {
      if (i > 0) {
        body += ',';
      }
      body += `"${tags[i]}"`;
    }
    return `[${body}]`;
  }

  private static readTags(raw: string): string[] {
    const tags: string[] = [];
    if (raw.length < 2) {
      return tags;
    }
    const inner = raw.substring(1, raw.length - 1);
    if (inner.length === 0) {
      return tags;
    }
    const parts = inner.split(',');
    for (let i = 0; i < parts.length; i++) {
      const trimmed = parts[i].trim();
      if (trimmed.length >= 2 && trimmed.charAt(0) === '"') {
        tags.push(trimmed.substring(1, trimmed.length - 1));
      }
    }
    return tags;
  }

  private static containsFavorite(tags: string[]): boolean {
    for (let i = 0; i < tags.length; i++) {
      if (tags[i] === CommandFavoriteMark.TAG) {
        return true;
      }
    }
    return false;
  }

  private static encoding(raw: string): PayloadEncoding {
    if (raw === PayloadEncoding.HEX) {
      return PayloadEncoding.HEX;
    }
    return PayloadEncoding.TEXT;
  }

  private static lineEnding(raw: string): LineEndingMode {
    if (raw === LineEndingMode.CRLF) {
      return LineEndingMode.CRLF;
    }
    if (raw === LineEndingMode.CR) {
      return LineEndingMode.CR;
    }
    if (raw === LineEndingMode.NONE) {
      return LineEndingMode.NONE;
    }
    return LineEndingMode.LF;
  }

  private static writeMode(raw: string): WriteMode {
    if (raw === WriteMode.REPEAT) {
      return WriteMode.REPEAT;
    }
    return WriteMode.ONCE;
  }

  private static moduleOf(raw: string): ModuleType {
    if (raw === ModuleType.BLUETOOTH) {
      return ModuleType.BLUETOOTH;
    }
    if (raw === ModuleType.WIFI) {
      return ModuleType.WIFI;
    }
    if (raw === ModuleType.NEARLINK) {
      return ModuleType.NEARLINK;
    }
    return ModuleType.SYSTEM;
  }

  private static protocolOf(raw: string): ProtocolType {
    if (raw === ProtocolType.SPP) {
      return ProtocolType.SPP;
    }
    if (raw === ProtocolType.BLE_GATT) {
      return ProtocolType.BLE_GATT;
    }
    if (raw === ProtocolType.TCP_CLIENT) {
      return ProtocolType.TCP_CLIENT;
    }
    if (raw === ProtocolType.UDP) {
      return ProtocolType.UDP;
    }
    if (raw === ProtocolType.SSAP) {
      return ProtocolType.SSAP;
    }
    return ProtocolType.NONE;
  }
}
