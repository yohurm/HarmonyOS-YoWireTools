import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResponsive } from '../token/semantic/UiResponsive';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';

export interface YoContextStripItem {
  label: ResourceStr;
  value: ResourceStr;
  tone?: StatusPillTone;
}

@ComponentV2
export struct YoContextStrip {
  @Param items: YoContextStripItem[] = [];
  @Param riskMessage: ResourceStr = '';
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    if (this.items.length === 0 && !UiResourceUtil.hasText(this.riskMessage)) {
      Blank()
    } else {
      Column({ space: UiSpace.M }) {
        if (UiResourceUtil.hasText(this.riskMessage)) {
          Row({ space: UiSpace.M }) {
            SymbolGlyph($r('sys.symbol.exclamationmark_triangle_fill'))
              .fontSize(UiSize.ICON_M)
              .fontColor([UiColor.WARNING])
            Text(this.riskMessage)
              .fontSize(UiTypeStyle.BODY_S.size)
              .fontColor(UiColor.WARNING)
              .layoutWeight(1)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(UiSpace.M)
          .backgroundColor(UiColor.WARNING_CONTAINER)
          .borderRadius(CardToken.RADIUS)
        }
        Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
          ForEach(this.items.slice(0, 4), (item: YoContextStripItem, index: number) => {
            Row({ space: UiSpace.XS }) {
              Text(item.label)
                .fontSize(UiTypeStyle.BODY_S.size)
                .fontColor(UiColor.TEXT_TERTIARY)
              if (item.tone !== undefined) {
                StatusPillView({ label: item.value, tone: item.tone })
              } else {
                Text(item.value)
                  .fontSize(UiTypeStyle.BODY_S.size)
                  .fontColor(UiColor.TEXT_SECONDARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .margin({ right: UiSpace.XL, bottom: UiSpace.M })
          }, (item: YoContextStripItem, index: number) => `${index}_${item.label}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding({
        left: UiResponsive.pageHorizontal(this.metrics.breakpoint),
        right: UiResponsive.pageHorizontal(this.metrics.breakpoint),
        top: UiSpace.M,
        bottom: UiSpace.M
      })
    }
  }
}
