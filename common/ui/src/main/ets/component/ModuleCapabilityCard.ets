import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';
import { YoActionButton, YoActionButtonKind } from './YoActionButton';

/**
 * Module capability summary card for workbench and module overview pages.
 */
@ComponentV2
export struct ModuleCapabilityCard {
  @Param moduleName: ResourceStr = '';
  @Param statusLabel: ResourceStr = '';
  @Param statusTone: StatusPillTone = 'brand';
  @Param description: ResourceStr = '';
  @Param actionLabel: ResourceStr = '';
  @Param sessionCount: number = 0;
  @Param disabled: boolean = false;
  @Event onAction: () => void = () => {
  };
  @Event onTap: () => void = () => {
  };

  build() {
    Column({ space: UiSpace.M }) {
      Row({ space: UiSpace.M }) {
        Text(this.moduleName)
          .fontSize(UiTypeStyle.SUBTITLE_M.size)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .fontColor(UiColor.TEXT_PRIMARY)
          .layoutWeight(1)
        StatusPillView({ label: this.statusLabel, tone: this.statusTone })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Text(this.description)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.TEXT_SECONDARY)
        .width('100%')
        .maxLines(this.disabled ? 3 : 2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: UiSpace.M }) {
        if (this.sessionCount > 0) {
          Text(UiResourceUtil.format($r('app.string.ui_active_sessions'), this.sessionCount))
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_TERTIARY)
            .layoutWeight(1)
        } else {
          Blank().layoutWeight(1)
        }
        if (UiResourceUtil.hasText(this.actionLabel)) {
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
    .padding(CardToken.PADDING)
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS)
    .onClick(() => this.onTap())
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private buildAccessibilityLabel(): string {
    return UiResourceUtil.format(
      $r('app.string.ui_a11y_join_three'),
      UiResourceUtil.resolveText(this.moduleName),
      UiResourceUtil.resolveText(this.statusLabel),
      UiResourceUtil.resolveText(this.description)
    );
  }
}
