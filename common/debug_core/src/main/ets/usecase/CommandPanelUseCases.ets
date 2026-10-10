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
  static readonly MODULE_MISMATCH: string = 'YW-CMD-2005';
}

/** Reads the command repeat switch. Not the app-settings load use case. */
export class ReadCommandRepeatPolicyUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  async execute(): Promise<Result<boolean>> {
    const loaded = await this.repository.load();
    if (!loaded.success || loaded.value === undefined) {
      return Result.fail(loaded.error ?? new ResultError('YW-CMD-1001', 'Repeat policy unread'));
    }
    return Result.ok(loaded.value.allowRepeatCommand);
  }
}

/** Writes the command repeat switch. App settings does not call this. */
export class SaveCommandRepeatPolicyUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  execute(allowed: boolean): Promise<Result<void>> {
    return this.repository.saveRepeatAllowed(allowed);
  }
}

export class ListModuleCommandTemplatesUseCase {
  private readonly module: ModuleType;
  private readonly repository: CommandRepositoryContract;

  constructor(module: ModuleType, repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    this.module = module;
    this.repository = repository;
  }

  execute(offset: number = 0, limit: number = 50): Promise<Result<PageResult<CommandTemplate>>> {
    return this.repository.listTemplates(this.module, offset, limit);
  }
}

export class SaveModuleCommandTemplateUseCase {
  private readonly module: ModuleType;
  private readonly protocol: ProtocolType;
  private readonly repository: CommandRepositoryContract;

  constructor(
    module: ModuleType,
    protocol: ProtocolType,
    repository: CommandRepositoryContract = new CommandTemplateRepository()
  ) {
    this.module = module;
    this.protocol = protocol;
    this.repository = repository;
  }

  execute(name: string, payload: string, favorite: boolean, lineEnding: LineEndingMode): Promise<Result<CommandTemplate>> {
    const trimmed = name.trim();
    if (trimmed.length === 0 || payload.length === 0) {
      return Promise.resolve(Result.fail(new ResultError('YW-CMD-1003', 'Name and payload required')));
    }
    const template = new CommandTemplate(
      IdGenerator.next('cmd'),
      trimmed,
      payload,
      PayloadEncoding.TEXT,
      lineEnding,
      WriteMode.ONCE,
      5000,
      this.module,
      this.protocol,
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

export class ExecuteModuleCommandUseCase {
  private readonly module: ModuleType;
  private readonly sendCommand: SendCommandUseCase;
  private readonly transports: TransportSessionRegistry;

  constructor(
    module: ModuleType,
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.module = module;
    this.sendCommand = sendCommand;
    this.transports = transports;
  }

  async execute(template: CommandTemplate): Promise<Result<void>> {
    if (template.module !== this.module) {
      return Result.fail(new ResultError(ShellCommandCodes.MODULE_MISMATCH, 'Command module mismatch'));
    }
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

export class RepeatModuleCommandUseCase {
  private readonly module: ModuleType;
  private readonly settings: SettingsRepositoryContract;
  private readonly repeats: RepeatCommandCoordinator;
  private readonly transports: TransportSessionRegistry;

  constructor(
    module: ModuleType,
    settings: SettingsRepositoryContract = new SettingsRepository(),
    repeats: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.module = module;
    this.settings = settings;
    this.repeats = repeats;
    this.transports = transports;
  }

  async start(template: CommandTemplate, intervalMs: number): Promise<Result<void>> {
    if (template.module !== this.module) {
      return Result.fail(new ResultError(ShellCommandCodes.MODULE_MISMATCH, 'Command module mismatch'));
    }
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
