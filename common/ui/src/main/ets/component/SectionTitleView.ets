import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiColor } from '../token/semantic/UiColor';
import { UiResponsive } from '../token/semantic/UiResponsive';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct SectionTitleView {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param actionLabel: ResourceStr = '';
  @Event onAction: () => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    Row() {
      Column({ space: UiResponsive.LABEL_STACK_GAP }) {
        Text(this.title)
          .fontSize(UiTypeStyle.SUBTITLE_M.size)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .fontColor(UiColor.TEXT_PRIMARY)
          .width('100%')
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_TERTIARY)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .accessibilityGroup(true)
      .accessibilityText(this.buildHeaderAccessibilityLabel())
      if (UiResourceUtil.hasText(this.actionLabel)) {
        Button(this.actionLabel)
          .type(ButtonType.Normal)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontWeight(UiTypeStyle.BODY_S.weight)
          .fontColor(UiColor.BRAND_PRIMARY)
          .backgroundColor(Color.Transparent)
          .constraintSize({ minHeight: UiSize.TOUCH_TARGET_MIN, minWidth: UiSize.TOUCH_TARGET_MIN })
          .onClick(() => this.onAction())
          .accessibilityGroup(true)
          .accessibilityText(UiResourceUtil.resolveText(this.actionLabel))
      }
    }
    .width('100%')
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: UiResponsive.SECTION_GAP,
      bottom: UiResponsive.CONTROL_GAP
    })
  }

  private buildHeaderAccessibilityLabel(): string {
    const title = UiResourceUtil.resolveText(this.title);
    if (UiResourceUtil.hasText(this.subtitle)) {
      return UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        title,
        UiResourceUtil.resolveText(this.subtitle)
      );
    }
    return title;
  }
}
