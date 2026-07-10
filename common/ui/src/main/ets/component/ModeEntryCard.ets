import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
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
    Column({ space: UiSpace.M }) {
      Column({ space: UiSpace.M }) {
        Row({ space: UiSpace.M }) {
          Text(this.title)
            .fontSize(UiTypeStyle.SUBTITLE_M.size)
            .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
            .fontColor(UiColor.TEXT_PRIMARY)
            .layoutWeight(1)
          if (UiResourceUtil.hasText(this.statusLabel)) {
            StatusPillView({ label: this.statusLabel, tone: this.statusTone })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        Text(this.description)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(UiColor.TEXT_SECONDARY)
          .width('100%')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.disabled && UiResourceUtil.hasText(this.disabledReason)) {
          Text(this.disabledReason)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.WARNING)
            .width('100%')
        }
      }
      .width('100%')
      .accessibilityGroup(true)
      .accessibilityText(this.buildInfoAccessibilityLabel())
      Row({ space: UiSpace.M }) {
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
    .padding(CardToken.PADDING)
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS)
  }

  private buildInfoAccessibilityLabel(): string {
    let label = UiResourceUtil.resolveText(this.title);
    if (UiResourceUtil.hasText(this.statusLabel)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.statusLabel)
      );
    }
    label = UiResourceUtil.format(
      $r('app.string.ui_a11y_join_two'),
      label,
      UiResourceUtil.resolveText(this.description)
    );
    if (this.disabled && UiResourceUtil.hasText(this.disabledReason)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.disabledReason)
      );
    } else if (this.disabled) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_disabled'), label);
    }
    return label;
  }
}
