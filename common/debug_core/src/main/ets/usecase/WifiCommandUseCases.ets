import { ModuleType, ProtocolType } from '../domain/enums/DomainEnums';
import { CommandRepositoryContract } from '../domain/repository/CommandRepositoryContract';
import { SettingsRepositoryContract } from '../domain/repository/SettingsRepositoryContract';
import { CommandTemplateRepository } from '../data/repository/CommandTemplateRepository';
import { SettingsRepository } from '../data/repository/SettingsRepository';
import { RepeatCommandCoordinator } from '../service/RepeatCommandCoordinator';
import { TransportSessionRegistry } from '../service/TransportSessionRegistry';
import { SendCommandUseCase } from './CommandUseCases';
import {
  ExecuteModuleCommandUseCase,
  ListModuleCommandTemplatesUseCase,
  RepeatModuleCommandUseCase,
  SaveModuleCommandTemplateUseCase
} from './CommandPanelUseCases';

export class ListWifiCommandTemplatesUseCase extends ListModuleCommandTemplatesUseCase {
  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    super(ModuleType.WIFI, repository);
  }
}

export class SaveWifiCommandTemplateUseCase extends SaveModuleCommandTemplateUseCase {
  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    super(ModuleType.WIFI, ProtocolType.TCP_CLIENT, repository);
  }
}

export class ExecuteWifiCommandUseCase extends ExecuteModuleCommandUseCase {
  constructor(
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    super(ModuleType.WIFI, sendCommand, transports);
  }
}

export class RepeatWifiCommandUseCase extends RepeatModuleCommandUseCase {
  constructor(
    settings: SettingsRepositoryContract = new SettingsRepository(),
    repeats: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    super(ModuleType.WIFI, settings, repeats, transports);
  }
}
