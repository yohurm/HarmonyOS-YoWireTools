import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { StatusPillTone, StatusPillView } from './StatusPillView';/**
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
    .padding(UiSpacing.INLINE_STACK_GAP)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CHIP_PILL_RADIUS)
    .onClick(() => this.onTap())
  }
}
