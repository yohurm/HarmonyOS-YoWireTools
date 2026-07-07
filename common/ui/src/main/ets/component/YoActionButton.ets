import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
export enum YoActionButtonKind {
  PRIMARY = 0,
  SECONDARY = 1,
  TEXT = 2,
  DANGER = 3
}
/**
 * V2 action button with loading/disabled-reason support. One primary per page.
 */
@ComponentV2
export struct YoActionButton {
  @Param label: string = '';
  @Param kind: YoActionButtonKind = YoActionButtonKind.PRIMARY;
  @Param isEnabled: boolean = true;
  @Param loading: boolean = false;
  @Param disabledReason: string = '';
  @Param compact: boolean = false;
  @Param fullWidth: boolean = true;
  @Event onTap: () => void = () => {
  };
  build() {
    Column({ space: 4 }) {
      Button(this.loading ? '处理中…' : this.label, { type: ButtonType.Normal })
        .width(this.fullWidth ? '100%' : undefined)
        .height(this.compact ? UiLayoutConstants.LIST_ROW_HEIGHT : UiSpacing.BUTTON_HEIGHT)
        .constraintSize({ minWidth: UiLayoutConstants.TOUCH_TARGET, minHeight: UiLayoutConstants.TOUCH_TARGET })
        .borderRadius(this.compact ? 8 : UiLayoutConstants.CARD_RADIUS_SMALL)
        .fontSize(UiTypography.BODY_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.resolveButtonFontColor())
        .backgroundColor(this.resolveButtonBackground())
        .enabled(this.isEnabled && !this.loading)
        .opacity(this.isEnabled ? 1 : 0.38)
        .onClick(() => {
          if (this.isEnabled && !this.loading) {
            this.onTap();
          }
        })
      if (!this.isEnabled && this.disabledReason.length > 0) {
        Text(this.disabledReason)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(this.fullWidth ? '100%' : undefined)
    .alignItems(HorizontalAlign.Start)
  }
  private resolveButtonFontColor(): ResourceColor {
    if (this.kind === YoActionButtonKind.TEXT) {
      return UiColorToken.PRIMARY;
    }
    if (this.kind === YoActionButtonKind.SECONDARY) {
      return UiColorToken.TEXT_PRIMARY;
    }
    return Color.White;
  }
  private resolveButtonBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.DANGER:
        return UiColorToken.ERROR;
      case YoActionButtonKind.SECONDARY:
        return UiColorToken.SURFACE;
      case YoActionButtonKind.TEXT:
        return Color.Transparent;
      default:
        return UiColorToken.PRIMARY;
    }
  }
}
