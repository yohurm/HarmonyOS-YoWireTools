import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';

export enum YoActionButtonKind {
  PRIMARY = 0,
  SECONDARY = 1,
  TEXT = 2,
  DANGER = 3
}

@ComponentV2
export struct YoActionButton {
  @Param label: ResourceStr = '';
  @Param kind: YoActionButtonKind = YoActionButtonKind.PRIMARY;
  @Param isEnabled: boolean = true;
  @Param loading: boolean = false;
  @Param disabledReason: ResourceStr = '';
  @Param compact: boolean = false;
  @Param fullWidth: boolean = true;
  @Event onTap: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.INLINE_STACK_GAP }) {
      Button(this.loading ? $r('app.string.ui_action_processing') : this.label, { type: ButtonType.Normal })
        .width(this.fullWidth ? '100%' : undefined)
        .height(this.compact ? UiLayoutConstants.LIST_ROW_HEIGHT : UiSpacing.BUTTON_HEIGHT)
        .constraintSize({ minWidth: UiLayoutConstants.TOUCH_TARGET, minHeight: UiLayoutConstants.TOUCH_TARGET })
        .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
        .fontSize(UiTypography.BODY_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.resolveButtonFontColor())
        .backgroundColor(this.resolveButtonBackground())
        .enabled(this.isEnabled && !this.loading)
        .opacity(this.isEnabled ? 1 : UiLayoutConstants.DISABLED_BUTTON_OPACITY)
        .onClick(() => {
          if (this.isEnabled && !this.loading) {
            this.onTap();
          }
        })
      if (!this.isEnabled && UiResourceUtil.hasText(this.disabledReason)) {
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
    return UiColorToken.TEXT_INVERSE;
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
