import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
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

  build() {
    if (this.items.length === 0 && !UiResourceUtil.hasText(this.riskMessage)) {
      Blank()
    } else {
      Column({ space: UiSpacing.ITEM_GAP }) {
        if (UiResourceUtil.hasText(this.riskMessage)) {
          Row({ space: UiSpacing.ITEM_GAP }) {
            SymbolGlyph($r('sys.symbol.exclamationmark_triangle_fill'))
              .fontSize(UiSpacing.ICON_SIZE)
              .fontColor([UiColorToken.WARNING])
            Text(this.riskMessage)
              .fontSize(UiTypography.CAPTION_SIZE)
              .fontColor(UiColorToken.WARNING)
              .layoutWeight(1)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding({
            left: UiSpacing.PAGE_PADDING,
            right: UiSpacing.PAGE_PADDING,
            top: UiSpacing.ITEM_GAP,
            bottom: UiSpacing.ITEM_GAP
          })
          .backgroundColor(UiColorToken.SURFACE)
          .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
        }
        Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center }) {
          ForEach(this.items.slice(0, 4), (item: YoContextStripItem, index: number) => {
            Row({ space: UiSpacing.INLINE_STACK_GAP }) {
              Text(item.label)
                .fontSize(UiTypography.CAPTION_SIZE)
                .fontColor(UiColorToken.TEXT_TERTIARY)
              if (item.tone !== undefined) {
                StatusPillView({ label: item.value, tone: item.tone })
              } else {
                Text(item.value)
                  .fontSize(UiTypography.CAPTION_SIZE)
                  .fontColor(UiColorToken.TEXT_SECONDARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .margin({ right: UiSpacing.FORM_GAP, bottom: UiSpacing.ITEM_GAP })
          }, (item: YoContextStripItem, index: number) => `${index}_${item.label}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding({
        left: UiSpacing.PAGE_PADDING,
        right: UiSpacing.PAGE_PADDING,
        top: UiSpacing.ITEM_GAP,
        bottom: UiSpacing.ITEM_GAP
      })
    }
  }
}
