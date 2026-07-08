import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';
import { YoActionButton, YoActionButtonKind } from './YoActionButton';

@ComponentV2
export struct ModeEntryCard {
  @Param title: ResourceStr = '';
  @Param description: ResourceStr = '';
  @Param statusLabel: ResourceStr = '';
  @Param statusTone: StatusPillTone = 'brand';
  @Param primaryLabel: ResourceStr = '';
  @Param secondaryLabel: ResourceStr = '';
  @Param disabled: boolean = false;
  @Param disabledReason: ResourceStr = '';
  @Event onPrimary: () => void = () => {
  };
  @Event onSecondary: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Row({ space: UiSpacing.ITEM_GAP }) {
        Text(this.title)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .layoutWeight(1)
        if (UiResourceUtil.hasText(this.statusLabel)) {
          StatusPillView({ label: this.statusLabel, tone: this.statusTone })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Text(this.description)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .width('100%')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.disabled && UiResourceUtil.hasText(this.disabledReason)) {
        Text(this.disabledReason)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.WARNING)
          .width('100%')
      }
      Row({ space: UiSpacing.ITEM_GAP }) {
        if (UiResourceUtil.hasText(this.secondaryLabel)) {
          YoActionButton({
            label: this.secondaryLabel,
            kind: YoActionButtonKind.SECONDARY,
            fullWidth: false,
            compact: true,
            isEnabled: !this.disabled,
            onTap: () => this.onSecondary()
          })
            .layoutWeight(1)
        }
        if (UiResourceUtil.hasText(this.primaryLabel)) {
          YoActionButton({
            label: this.primaryLabel,
            kind: YoActionButtonKind.PRIMARY,
            fullWidth: false,
            compact: true,
            isEnabled: !this.disabled,
            disabledReason: this.disabledReason,
            onTap: () => this.onPrimary()
          })
            .layoutWeight(1)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(UiSpacing.CARD_INNER_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
  }
}
