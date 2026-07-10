import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';
import { YoActionButton, YoActionButtonKind } from './YoActionButton';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

/**
 * Active/recent session card for workbench and module overview.
 */
@ComponentV2
export struct SessionCardView {
  @Param moduleLabel: ResourceStr = '';
  @Param sessionName: ResourceStr = '';
  @Param protocolLabel: ResourceStr = '';
  @Param targetLabel: ResourceStr = '';
  @Param statusLabel: ResourceStr = '';
  @Param statusTone: StatusPillTone = 'neutral';
  @Param lastActivity: ResourceStr = '';
  @Param logCount: number = 0;
  @Param errorCount: number = 0;
  @Param failureSummary: ResourceStr = '';
  @Event onEnter: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Column({ space: UiSpace.M }) {
      if (UiResourceUtil.hasText(this.failureSummary)) {
        Row({ space: UiSpace.M }) {
          SymbolGlyph($r('sys.symbol.exclamationmark_circle_fill'))
            .fontSize(UiSize.ICON_S)
            .fontColor([UiColor.ERROR])
            .accessibilityLevel('no')
          Text(this.failureSummary)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.ERROR)
            .layoutWeight(1)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }
      Row({ space: UiSpace.M }) {
        Column({ space: UiSpace.XXS }) {
          Text(this.sessionName)
            .fontSize(UiTypeStyle.SUBTITLE_M.size)
            .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
            .fontColor(UiColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          Text(UiResourceUtil.format(
            $r('app.string.ui_list_separator'),
            UiResourceUtil.resolveText(this.moduleLabel),
            UiResourceUtil.resolveText(this.protocolLabel)
          ))
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_TERTIARY)
            .width('100%')
          Text(this.targetLabel)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_SECONDARY)
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
      Row({ space: UiSpace.M }) {
        Text(this.lastActivity)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .layoutWeight(1)
        Text(UiResourceUtil.format($r('app.string.ui_session_log_count'), this.logCount))
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
        if (this.errorCount > 0) {
          Text(UiResourceUtil.format($r('app.string.ui_session_error_count'), this.errorCount))
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.ERROR)
        }
        YoActionButton({
          label: $r('app.string.ui_session_enter'),
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
    .padding(CardToken.PADDING)
    .backgroundColor(this.resolveBackground())
    .borderRadius(CardToken.RADIUS)
    .borderWidth(this.isFocused ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .focusable(true)
    .onClick(() => this.onEnter())
    .onHover((isHover: boolean) => {
      this.isHovered = isHover;
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onFocus(() => {
      this.isFocused = true;
    })
    .onBlur(() => {
      this.isFocused = false;
      this.isPressed = false;
    })
    .onKeyEvent((event: KeyEvent) => {
      if (event.type !== KeyType.Down) {
        return;
      }
      if (event.keyCode === KEY_CODE_ENTER || event.keyCode === KEY_CODE_SPACE) {
        this.onEnter();
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private resolveBackground(): ResourceColor {
    if (this.isPressed) {
      return UiColor.INTERACTIVE_PRESSED;
    }
    if (this.isFocused) {
      return UiColor.INTERACTIVE_FOCUSED;
    }
    if (this.isHovered) {
      return UiColor.INTERACTIVE_HOVER;
    }
    return CardToken.BACKGROUND;
  }

  private buildAccessibilityLabel(): string {
    const moduleProtocol = UiResourceUtil.format(
      $r('app.string.ui_list_separator'),
      UiResourceUtil.resolveText(this.moduleLabel),
      UiResourceUtil.resolveText(this.protocolLabel)
    );
    let label = UiResourceUtil.format(
      $r('app.string.ui_a11y_join_two'),
      UiResourceUtil.resolveText(this.sessionName),
      moduleProtocol
    );
    if (UiResourceUtil.hasText(this.targetLabel)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.targetLabel)
      );
    }
    if (UiResourceUtil.hasText(this.statusLabel)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.statusLabel)
      );
    }
    if (UiResourceUtil.hasText(this.failureSummary)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.failureSummary)
      );
    }
    label = UiResourceUtil.format(
      $r('app.string.ui_a11y_join_two'),
      label,
      UiResourceUtil.format($r('app.string.ui_session_log_count'), this.logCount)
    );
    if (this.errorCount > 0) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.format($r('app.string.ui_session_error_count'), this.errorCount)
      );
    }
    return label;
  }
}
