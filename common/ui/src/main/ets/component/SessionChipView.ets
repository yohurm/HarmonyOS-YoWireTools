import { UiColorToken } from '../theme/UiColorToken';
import { UiTypography } from '../theme/UiTypography';
import { StatusPillTone, StatusPillView } from './StatusPillView';
/**
 * Compact active session chip for ContextStrip / headers.
 */
@ComponentV2
export struct SessionChipView {
  @Param label: string = '';
  @Param tone: StatusPillTone = 'brand';
  @Event onTap: () => void = () => {
  };
  build() {
    Row() {
      StatusPillView({ label: this.label, tone: this.tone })
    }
    .padding({ left: 4, right: 4, top: 4, bottom: 4 })
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(20)
    .onClick(() => this.onTap())
  }
}
