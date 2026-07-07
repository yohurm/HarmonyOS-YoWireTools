import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { StatusPillTone, StatusPillView } from './StatusPillView';
/**
 * Unified device / session list card (72vp content-type list).
 */
@ComponentV2
export struct DeviceCardView {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param statusLabel: string = '';
  @Param statusTone: StatusPillTone = 'neutral';
  @Param trailingText: string = '';
  @Param selected: boolean = false;
  @Event onTap: () => void = () => {
  };
  build() {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Column({ space: 4 }) {
        if (this.statusLabel.length > 0) {
          StatusPillView({ label: this.statusLabel, tone: this.statusTone })
        }
        if (this.trailingText.length > 0) {
          Text(this.trailingText)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
        }
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_CARD_HEIGHT })
    .padding({
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING,
      top: UiSpacing.SECTION_GAP,
      bottom: UiSpacing.SECTION_GAP
    })
    .backgroundColor(this.selected ? $r('app.color.ui_emphasize_tertiary') : UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS)
    .borderWidth(this.selected ? 1 : 0)
    .borderColor(UiColorToken.PRIMARY)
    .onClick(() => this.onTap())
  }
}
