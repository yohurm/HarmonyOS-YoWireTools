import {
  ExecuteNearLinkCommandUseCase,
  ListNearLinkCommandTemplatesUseCase,
  RepeatNearLinkCommandUseCase,
  SaveNearLinkCommandTemplateUseCase
} from 'debug_core';
import { CommandPanelViewModel } from './CommandPanelViewModel';

@ObservedV2
export class NearLinkCommandViewModel extends CommandPanelViewModel {
  constructor() {
    super(
      new ListNearLinkCommandTemplatesUseCase(),
      new SaveNearLinkCommandTemplateUseCase(),
      new ExecuteNearLinkCommandUseCase(),
      new RepeatNearLinkCommandUseCase()
    );
  }
}
