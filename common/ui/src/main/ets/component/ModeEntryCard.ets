import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';

/**
 * Compact mode entry tile: title + status + one-line hint.
 * Whole card is tappable to maximize space on dual-entry rows.
 */
@ComponentV2
export struct ModeEntryCard {
  @Param title: ResourceStr = '';
  @Param description: ResourceStr = '';
  @Param statusLabel: ResourceStr = '';
  @Param statusTone: StatusPillTone = 'brand';
  @Param disabled: boolean = false;
  @Param disabledReason: ResourceStr = '';
  @Event onTap: () => void = () => {
  };

  build() {
    Column({ space: UiSpace.S }) {
      Text(this.title)
        .fontSize(UiTypeStyle.SUBTITLE_M.size)
        .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
        .fontColor(this.disabled ? UiColor.TEXT_TERTIARY : UiColor.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      if (UiResourceUtil.hasText(this.statusLabel)) {
        StatusPillView({ label: this.statusLabel, tone: this.statusTone })
      }
      if (UiResourceUtil.hasText(this.description)) {
        Text(this.description)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_SECONDARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      if (this.disabled && UiResourceUtil.hasText(this.disabledReason)) {
        Text(this.disabledReason)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.WARNING)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
    }
    .width('100%')
    .padding(CardToken.PADDING_COMPACT)
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS)
    .opacity(this.disabled ? 0.72 : 1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .accessibilityGroup(true)
    .accessibilityText(this.buildInfoAccessibilityLabel())
    .onClick(() => {
      if (!this.disabled) {
        this.onTap();
      }
    })
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
    if (UiResourceUtil.hasText(this.description)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.description)
      );
    }
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
