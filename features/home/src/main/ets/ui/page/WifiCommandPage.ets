import { CommandPanelViewModel } from '../../viewmodel/CommandPanelViewModel';
import { WifiCommandViewModel } from '../../viewmodel/WifiCommandViewModel';
import { CommandPanelTemplate } from './CommandPanelTemplate';

@ComponentV2
export struct WifiCommandPage {
  @Event onBack: () => void = () => {
  };
  @Local vm: CommandPanelViewModel = new WifiCommandViewModel();

  build() {
    CommandPanelTemplate({
      vm: this.vm,
      title: $r('app.string.command_title_wifi'),
      onBack: () => {
        this.onBack();
      }
    })
  }
}
