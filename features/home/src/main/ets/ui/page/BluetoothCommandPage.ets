import { CommandPanelViewModel } from '../../viewmodel/CommandPanelViewModel';
import { BluetoothCommandViewModel } from '../../viewmodel/BluetoothCommandViewModel';
import { CommandPanelTemplate } from './CommandPanelTemplate';

@ComponentV2
export struct BluetoothCommandPage {
  @Event onBack: () => void = () => {
  };
  @Local vm: CommandPanelViewModel = new BluetoothCommandViewModel();

  build() {
    CommandPanelTemplate({
      vm: this.vm,
      title: $r('app.string.command_title_bluetooth'),
      onBack: () => {
        this.onBack();
      }
    })
  }
}
