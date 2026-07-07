import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
@ComponentV2
export struct YoSelectRow {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param value: string = '';
  @Param isEnabled: boolean = true;
  @Event onTap: () => void = () => {
  };
  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_SECONDARY)
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(this.value)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .margin({ right: UiSpacing.ITEM_GAP })
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([UiColorToken.TEXT_TERTIARY])
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_ROW_HEIGHT })
    .padding({
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING,
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiSpacing.CORNER_RADIUS)
    .enabled(this.isEnabled)
    .opacity(this.isEnabled ? 1 : 0.4)
    .onClick(() => this.onTap())
  }
}
