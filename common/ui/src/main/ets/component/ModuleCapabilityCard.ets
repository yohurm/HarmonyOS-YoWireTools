import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { StatusPillTone, StatusPillView } from './StatusPillView';
import { YoActionButton, YoActionButtonKind } from './YoActionButton';
/**
 * Module capability summary card for workbench and module overview pages.
 */
@ComponentV2
export struct ModuleCapabilityCard {
  @Param moduleName: string = '';
  @Param statusLabel: string = '';
  @Param statusTone: StatusPillTone = 'brand';
  @Param description: string = '';
  @Param actionLabel: string = '';
  @Param sessionCount: number = 0;
  @Param disabled: boolean = false;
  @Event onAction: () => void = () => {
  };
  @Event onTap: () => void = () => {
  };
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Row({ space: UiSpacing.ITEM_GAP }) {
        Text(this.moduleName)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .layoutWeight(1)
        StatusPillView({ label: this.statusLabel, tone: this.statusTone })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Text(this.description)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .width('100%')
        .maxLines(this.disabled ? 3 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: UiSpacing.ITEM_GAP }) {
        if (this.sessionCount > 0) {
          Text(`${this.sessionCount} 个活跃会话`)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
            .layoutWeight(1)
        } else {
          Blank().layoutWeight(1)
        }
        if (this.actionLabel.length > 0) {
          YoActionButton({
            label: this.actionLabel,
            kind: YoActionButtonKind.TEXT,
            fullWidth: false,
            compact: true,
            isEnabled: !this.disabled,
            onTap: () => this.onAction()
          })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(UiSpacing.CARD_INNER_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
    .onClick(() => this.onTap())
  }
}
