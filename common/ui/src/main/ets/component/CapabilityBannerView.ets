import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';

import { StatusPillTone } from './StatusPillView';

export type CapabilityBannerTone = 'info' | 'warning' | 'error' | 'success';

@ComponentV2
export struct CapabilityBannerView {
  @Param title: ResourceStr = '';
  @Param message: ResourceStr = '';
  @Param tone: CapabilityBannerTone = 'info';
  @Param actionLabel: ResourceStr = '';
  @Event onAction: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Row({ space: UiSpacing.ITEM_GAP }) {
        SymbolGlyph(this.resolveSymbol())
          .fontSize(UiSpacing.ICON_SIZE)
          .fontColor([this.resolveAccent()])
        Column({ space: UiSpacing.INLINE_STACK_GAP }) {
          if (UiResourceUtil.hasText(this.title)) {
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
      if (UiResourceUtil.hasText(this.actionLabel)) {
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
        return UiColorToken.PRIMARY;
    }
  }
}

export function capabilityStatusPillTone(enabled: boolean): StatusPillTone {
  return enabled ? 'success' : 'warning';
}

