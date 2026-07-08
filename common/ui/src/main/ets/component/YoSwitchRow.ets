import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
@ComponentV2
export struct YoSwitchRow {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param checked: boolean = false;
  @Param isEnabled: boolean = true;
  @Event onCheckedChange: (checked: boolean) => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  build() {
    Row() {
      Column({ space: UiSpacing.INLINE_STACK_GAP }) {
        Text(this.title)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_PRIMARY)
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.checked })
        .enabled(this.isEnabled)
        .onChange((isOn: boolean) => this.onCheckedChange(isOn))
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_ROW_HEIGHT })
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiSpacing.CORNER_RADIUS)
  }
}
