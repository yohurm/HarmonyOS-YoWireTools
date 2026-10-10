import { CommandPanelViewModel } from '../../viewmodel/CommandPanelViewModel';
import { NearLinkCommandViewModel } from '../../viewmodel/NearLinkCommandViewModel';
import { CommandPanelTemplate } from './CommandPanelTemplate';

@ComponentV2
export struct NearLinkCommandPage {
  @Event onBack: () => void = () => {
  };
  @Local vm: CommandPanelViewModel = new NearLinkCommandViewModel();

  build() {
    CommandPanelTemplate({
      vm: this.vm,
      title: $r('app.string.command_title_nearlink'),
      onBack: () => {
        this.onBack();
      }
    })
  }
}
