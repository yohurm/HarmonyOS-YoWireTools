import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { StatusPillTone } from './StatusPillView';
export type CapabilityBannerTone = 'info' | 'warning' | 'error' | 'success';
/**
 * Permission / capability / degradation banner per UI design spec.
 */
@ComponentV2
export struct CapabilityBannerView {
  @Param title: string = '';
  @Param message: string = '';
  @Param tone: CapabilityBannerTone = 'info';
  @Param actionLabel: string = '';
  @Event onAction: () => void = () => {
  };
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Row({ space: UiSpacing.ITEM_GAP }) {
        SymbolGlyph(this.resolveSymbol())
          .fontSize(UiSpacing.ICON_SIZE)
          .fontColor([this.resolveAccent()])
        Column({ space: 4 }) {
          if (this.title.length > 0) {
            Text(this.title)
              .fontSize(UiTypography.SUBTITLE_SIZE)
              .fontWeight(FontWeight.Medium)
              .fontColor(UiColorToken.TEXT_PRIMARY)
              .width('100%')
          }
          Text(this.message)
            .fontSize(UiTypography.BODY_SIZE)
            .fontColor(UiColorToken.TEXT_SECONDARY)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      if (this.actionLabel.length > 0) {
        Button(this.actionLabel)
          .type(ButtonType.Normal)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.PRIMARY)
          .backgroundColor(Color.Transparent)
          .height(UiLayoutConstants.TOUCH_TARGET)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .padding({
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING,
      top: UiSpacing.SECTION_GAP,
      bottom: UiSpacing.SECTION_GAP
    })
    .backgroundColor($r('app.color.ui_emphasize_tertiary'))
    .borderRadius(UiLayoutConstants.CARD_RADIUS)
  }
  private resolveSymbol(): Resource {
    switch (this.tone) {
      case 'error':
        return $r('sys.symbol.exclamationmark_circle');
      case 'warning':
        return $r('sys.symbol.exclamationmark_triangle');
      case 'success':
        return $r('sys.symbol.checkmark_circle');
      default:
        return $r('sys.symbol.info_circle');
    }
  }
  private resolveAccent(): ResourceColor {
    switch (this.tone) {
      case 'error':
        return UiColorToken.ERROR;
      case 'warning':
        return UiColorToken.WARNING;
      case 'success':
        return UiColorToken.SUCCESS;
      default:
        return UiColorToken.INFO;
    }
  }
}
export function capabilityStatusPillTone(status: string): StatusPillTone {
  const normalized = status.toLowerCase();
  if (normalized === 'available') {
    return 'success';
  }
  if (normalized === 'limited') {
    return 'warning';
  }
  if (normalized === 'unavailable') {
    return 'error';
  }
  return 'neutral';
}
