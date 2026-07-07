import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { StatusPillTone, StatusPillView } from './StatusPillView';
import { YoActionButton, YoActionButtonKind } from './YoActionButton';
/**
 * Active/recent session card for workbench and module overview.
 */
@ComponentV2
export struct SessionCardView {
  @Param moduleLabel: string = '';
  @Param sessionName: string = '';
  @Param protocolLabel: string = '';
  @Param targetLabel: string = '';
  @Param statusLabel: string = '';
  @Param statusTone: StatusPillTone = 'neutral';
  @Param lastActivity: string = '';
  @Param logCount: number = 0;
  @Param errorCount: number = 0;
  @Param failureSummary: string = '';
  @Event onEnter: () => void = () => {
  };
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      if (this.failureSummary.length > 0) {
        Row({ space: UiSpacing.ITEM_GAP }) {
          SymbolGlyph($r('sys.symbol.exclamationmark_circle_fill'))
            .fontSize(16)
            .fontColor([UiColorToken.ERROR])
          Text(this.failureSummary)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.ERROR)
            .layoutWeight(1)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
      Row({ space: UiSpacing.ITEM_GAP }) {
        Column({ space: 2 }) {
          Text(this.sessionName)
            .fontSize(UiTypography.SUBTITLE_SIZE)
            .fontWeight(FontWeight.Medium)
            .fontColor(UiColorToken.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          Text(`${this.moduleLabel} · ${this.protocolLabel}`)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
            .width('100%')
          Text(this.targetLabel)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_SECONDARY)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        StatusPillView({ label: this.statusLabel, tone: this.statusTone })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      Row({ space: UiSpacing.ITEM_GAP }) {
        Text(this.lastActivity)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .layoutWeight(1)
        Text(`日志 ${this.logCount}`)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
        if (this.errorCount > 0) {
          Text(`错误 ${this.errorCount}`)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.ERROR)
        }
        YoActionButton({
          label: '进入',
          kind: YoActionButtonKind.TEXT,
          fullWidth: false,
          compact: true,
          onTap: () => this.onEnter()
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(UiSpacing.CARD_INNER_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
    .onClick(() => this.onEnter())
  }
}
