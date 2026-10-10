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

export class ListBluetoothCommandTemplatesUseCase extends ListModuleCommandTemplatesUseCase {
  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    super(ModuleType.BLUETOOTH, repository);
  }
}

export class SaveBluetoothCommandTemplateUseCase extends SaveModuleCommandTemplateUseCase {
  constructor(repository: CommandRepositoryContract = new CommandTemplateRepository()) {
    super(ModuleType.BLUETOOTH, ProtocolType.SPP, repository);
  }
}

export class ExecuteBluetoothCommandUseCase extends ExecuteModuleCommandUseCase {
  constructor(
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    super(ModuleType.BLUETOOTH, sendCommand, transports);
  }
}

export class RepeatBluetoothCommandUseCase extends RepeatModuleCommandUseCase {
  constructor(
    settings: SettingsRepositoryContract = new SettingsRepository(),
    repeats: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance(),
    transports: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    super(ModuleType.BLUETOOTH, settings, repeats, transports);
  }
}
