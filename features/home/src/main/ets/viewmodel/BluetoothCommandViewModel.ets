import {
  ExecuteBluetoothCommandUseCase,
  ListBluetoothCommandTemplatesUseCase,
  RepeatBluetoothCommandUseCase,
  SaveBluetoothCommandTemplateUseCase
} from 'debug_core';
import { CommandPanelViewModel } from './CommandPanelViewModel';

@ObservedV2
export class BluetoothCommandViewModel extends CommandPanelViewModel {
  constructor() {
    super(
      new ListBluetoothCommandTemplatesUseCase(),
      new SaveBluetoothCommandTemplateUseCase(),
      new ExecuteBluetoothCommandUseCase(),
      new RepeatBluetoothCommandUseCase()
    );
  }
}
