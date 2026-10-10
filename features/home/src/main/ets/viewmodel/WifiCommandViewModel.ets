import {
  ExecuteWifiCommandUseCase,
  ListWifiCommandTemplatesUseCase,
  RepeatWifiCommandUseCase,
  SaveWifiCommandTemplateUseCase
} from 'debug_core';
import { CommandPanelViewModel } from './CommandPanelViewModel';

@ObservedV2
export class WifiCommandViewModel extends CommandPanelViewModel {
  constructor() {
    super(
      new ListWifiCommandTemplatesUseCase(),
      new SaveWifiCommandTemplateUseCase(),
      new ExecuteWifiCommandUseCase(),
      new RepeatWifiCommandUseCase()
    );
  }
}