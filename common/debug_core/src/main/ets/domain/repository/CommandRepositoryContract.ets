import { PageResult, Result } from 'common_core';
import { CommandTemplate } from '../model/CommandTemplate';

export interface CommandRepositoryContract {
  listTemplates(offset: number, limit: number): Promise<Result<PageResult<CommandTemplate>>>;
  saveTemplate(template: CommandTemplate): Promise<Result<void>>;
  deleteTemplate(id: string): Promise<Result<void>>;
}
