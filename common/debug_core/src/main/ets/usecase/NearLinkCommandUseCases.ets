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

export class ListNearLinkCommandTemplatesUseCase extends ListModuleCommandTemplatesUseCase {
  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    super(ModuleType.NEARLINK, repository);
  }
}

export class SaveNearLinkCommandTemplateUseCase extends SaveModuleCommandTemplateUseCase {
  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    super(ModuleType.NEARLINK, ProtocolType.SSAP, repository);
  }
}

export class ExecuteNearLinkCommandUseCase extends ExecuteModuleCommandUseCase {
  constructor(
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    super(ModuleType.NEARLINK, sendCommand, transports);
  }
}

export class RepeatNearLinkCommandUseCase extends RepeatModuleCommandUseCase {
  constructor(
    settings: SettingsRepositoryContract = new SettingsRepository(),
    repeats: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    super(ModuleType.NEARLINK, settings, repeats, transports);
  }
}
