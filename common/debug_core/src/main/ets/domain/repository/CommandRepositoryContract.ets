import { PageResult, Result } from 'common_core';
import { ModuleType } from '../enums/DomainEnums';
import { CommandTemplate } from '../model/CommandTemplate';

export interface CommandRepositoryContract {
  listTemplates(module: ModuleType, offset: number, limit: number): Promise<Result<PageResult<CommandTemplate>>>;
  saveTemplate(template: CommandTemplate): Promise<Result<void>>;
  deleteTemplate(id: string): Promise<Result<void>>;
}
