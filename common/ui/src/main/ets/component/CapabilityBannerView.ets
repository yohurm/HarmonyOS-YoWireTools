import { WindowMetricsRegistry, WindowMetricsState } from 'common_platform';
import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResponsive } from '../token/semantic/UiResponsive';
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
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    Column({ space: UiSpace.M }) {
      Row({ space: UiSpace.M }) {
        SymbolGlyph(this.resolveSymbol())
          .fontSize(UiSize.ICON_M)
          .fontColor([this.resolveAccent()])
        Column({ space: UiSpace.XS }) {
          if (UiResourceUtil.hasText(this.title)) {
            Text(this.title)
              .fontSize(UiTypeStyle.SUBTITLE_M.size)
              .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
              .fontColor(UiColor.TEXT_PRIMARY)
              .width('100%')
          }
          Text(this.message)
            .fontSize(UiTypeStyle.BODY_M.size)
            .fontColor(UiColor.TEXT_SECONDARY)
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
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(this.resolveAccent())
          .backgroundColor(Color.Transparent)
          .height(UiSize.TOUCH_TARGET_MIN)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .padding({
      left: UiResponsive.pageHorizontal(this.metrics.breakpoint),
      right: UiResponsive.pageHorizontal(this.metrics.breakpoint),
      top: UiResponsive.SECTION_GAP,
      bottom: UiResponsive.SECTION_GAP
    })
    .backgroundColor(this.resolveBackground())
    .borderRadius(CardToken.RADIUS)
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
        return UiColor.ERROR;
      case 'warning':
        return UiColor.WARNING;
      case 'success':
        return UiColor.SUCCESS;
      default:
        return UiColor.INFO;
    }
  }

  private resolveBackground(): ResourceColor {
    switch (this.tone) {
      case 'error':
        return UiColor.ERROR_CONTAINER;
      case 'warning':
        return UiColor.WARNING_CONTAINER;
      case 'success':
        return UiColor.SUCCESS_CONTAINER;
      default:
        return UiColor.INFO_CONTAINER;
    }
  }
}

export function capabilityStatusPillTone(enabled: boolean): StatusPillTone {
  return enabled ? 'success' : 'warning';
}
