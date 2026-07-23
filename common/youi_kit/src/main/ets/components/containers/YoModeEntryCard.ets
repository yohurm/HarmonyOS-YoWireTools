import { YoCardToken } from '../../token/component/YoCardToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoResourceUtil } from '../../util/YoResourceUtil';
import { YoStatusPillTone, YoStatusPill } from './YoStatusPill';

/**
 * 紧凑模式入口卡片：标题 + 状态 + 单行提示。
 * 整卡可点，便于双入口行节省空间。
 */
@ComponentV2
export struct YoModeEntryCard {
  @Param title: ResourceStr = '';
  @Param description: ResourceStr = '';
  @Param statusLabel: ResourceStr = '';
  @Param statusTone: YoStatusPillTone = 'brand';
  @Param disabled: boolean = false;
  @Param disabledReason: ResourceStr = '';
  @Event onTap: () => void = () => {
  };

  build() {
    Column({ space: YoSpace.S }) {
      Text(this.title)
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontWeight(YoTypeStyle.SUBTITLE_M.weight)
        .fontColor(this.disabled ? YoColor.TEXT_TERTIARY : YoColor.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      if (YoResourceUtil.hasText(this.statusLabel)) {
        YoStatusPill({ label: this.statusLabel, tone: this.statusTone })
      }
      if (YoResourceUtil.hasText(this.description)) {
        Text(this.description)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      if (this.disabled && YoResourceUtil.hasText(this.disabledReason)) {
        Text(this.disabledReason)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
    }
    .width('100%')
    .padding(YoCardToken.PADDING_COMPACT)
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(YoCardToken.RADIUS)
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
    let label = YoResourceUtil.resolveText(this.title);
    if (YoResourceUtil.hasText(this.statusLabel)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.statusLabel)
      );
    }
    if (YoResourceUtil.hasText(this.description)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.description)
      );
    }
    if (this.disabled && YoResourceUtil.hasText(this.disabledReason)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.disabledReason)
      );
    } else if (this.disabled) {
      label = YoResourceUtil.format($r('app.string.youi_a11y_disabled'), label);
    }
    return label;
  }
}
