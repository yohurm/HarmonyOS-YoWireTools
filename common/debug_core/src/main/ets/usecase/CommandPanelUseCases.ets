import { IdGenerator, PageResult, Result, ResultError } from 'common_core';
import { CommandTemplate, RepeatPolicy } from '../domain/model/CommandTemplate';
import { LineEndingMode, ModuleType, PayloadEncoding, ProtocolType, WriteMode } from '../domain/enums/DomainEnums';
import { CommandRepositoryContract } from '../domain/repository/CommandRepositoryContract';
import { SettingsRepositoryContract } from '../domain/repository/SettingsRepositoryContract';
import { CommandTemplateRepository } from '../data/repository/CommandTemplateRepository';
import { SettingsRepository } from '../data/repository/SettingsRepository';
import { RepeatCommandCoordinator } from '../service/RepeatCommandCoordinator';
import { TransportSessionRegistry } from '../service/TransportSessionRegistry';
import { SendCommandInput, SendCommandUseCase } from './CommandUseCases';

export class ShellCommandCodes {
  static readonly NO_TRANSPORT: string = 'YW-CMD-2004';
  static readonly REPEAT_DISABLED: string = 'YW-CMD-2003';
}

export class ListCommandTemplatesUseCase {
  private readonly repository: CommandRepositoryContract;

  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    this.repository = repository;
  }

  execute(offset: number = 0, limit: number = 50): Promise<Result<PageResult<CommandTemplate>>> {
    return this.repository.listTemplates(offset, limit);
  }
}

export class SaveCommandTemplateUseCase {
  private readonly repository: CommandRepositoryContract;

  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    this.repository = repository;
  }

  execute(name: string, payload: string, favorite: boolean): Promise<Result<CommandTemplate>> {
    const trimmed = name.trim();
    if (trimmed.length === 0 || payload.length === 0) {
      return Promise.resolve(Result.fail(new ResultError('YW-CMD-1003', 'Name and payload required')));
    }
    const template = new CommandTemplate(
      IdGenerator.next('cmd'),
      trimmed,
      payload,
      PayloadEncoding.TEXT,
      LineEndingMode.LF,
      WriteMode.ONCE,
      5000,
      ModuleType.SYSTEM,
      ProtocolType.NONE,
      undefined,
      [],
      [],
      Date.now(),
      Date.now(),
      favorite
    );
    return this.repository.saveTemplate(template).then((saved) => {
      if (!saved.success) {
        return Result.fail(saved.error ?? new ResultError('YW-CMD-1003', 'Save failed'));
      }
      return Result.ok(template);
    });
  }
}

export class ExecuteSavedCommandUseCase {
  private readonly sendCommand: SendCommandUseCase;
  private readonly transports: TransportSessionRegistry;

  constructor(
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.sendCommand = sendCommand;
    this.transports = transports;
  }

  async execute(template: CommandTemplate): Promise<Result<void>> {
    const ids = this.transports.listSessionIds();
    if (ids.length === 0) {
      return Result.fail(new ResultError(ShellCommandCodes.NO_TRANSPORT, 'No active transport'));
    }
    const transport = this.transports.get(ids[0]);
    if (transport === undefined) {
      return Result.fail(new ResultError(ShellCommandCodes.NO_TRANSPORT, 'No active transport'));
    }
    const sent = await this.sendCommand.execute(new SendCommandInput(
      ids[0],
      transport,
      template.payload,
      template.payloadEncoding,
      template.lineEnding
    ));
    if (!sent.success) {
      return Result.fail(sent.error ?? new ResultError('YW-CMD-1002', 'Send failed'));
    }
    return Result.ok(undefined);
  }
}

export class RepeatSavedCommandUseCase {
  private readonly settings: SettingsRepositoryContract;
  private readonly repeats: RepeatCommandCoordinator;
  private readonly transports: TransportSessionRegistry;

  constructor(
    settings: SettingsRepositoryContract = new SettingsRepository(),
    repeats: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.settings = settings;
    this.repeats = repeats;
    this.transports = transports;
  }

  async start(template: CommandTemplate, intervalMs: number): Promise<Result<void>> {
    const loaded = await this.settings.load();
    if (!loaded.success || loaded.value === undefined || !loaded.value.allowRepeatCommand) {
      return Result.fail(new ResultError(ShellCommandCodes.REPEAT_DISABLED, 'Repeat disabled'));
    }
    const ids = this.transports.listSessionIds();
    if (ids.length === 0) {
      return Result.fail(new ResultError(ShellCommandCodes.NO_TRANSPORT, 'No active transport'));
    }
    const transport = this.transports.get(ids[0]);
    if (transport === undefined) {
      return Result.fail(new ResultError(ShellCommandCodes.NO_TRANSPORT, 'No active transport'));
    }
    const policy = new RepeatPolicy(intervalMs, 0, 0, true, false);
    return this.repeats.start(
      template.id,
      new SendCommandInput(ids[0], transport, template.payload, template.payloadEncoding, template.lineEnding),
      policy
    );
  }

  stop(templateId: string): void {
    this.repeats.stop(templateId);
  }

  isRunning(templateId: string): boolean {
    return this.repeats.isRunning(templateId);
  }
}
