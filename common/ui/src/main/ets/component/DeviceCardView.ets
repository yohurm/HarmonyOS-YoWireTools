import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

/**
 * Unified device / session list card (72vp content-type list).
 */
@ComponentV2
export struct DeviceCardView {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param statusLabel: ResourceStr = '';
  @Param statusTone: StatusPillTone = 'neutral';
  @Param trailingText: ResourceStr = '';
  @Param selected: boolean = false;
  @Event onTap: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row({ space: UiSpace.M }) {
      Column({ space: UiSpace.XS }) {
        Text(this.title)
          .fontSize(UiTypeStyle.SUBTITLE_M.size)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .fontColor(UiColor.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Column({ space: UiSpace.XS }) {
        if (UiResourceUtil.hasText(this.statusLabel)) {
          StatusPillView({ label: this.statusLabel, tone: this.statusTone })
        }
        if (UiResourceUtil.hasText(this.trailingText)) {
          Text(this.trailingText)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_TERTIARY)
        }
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .constraintSize({ minHeight: CardToken.HEIGHT_LIST })
    .padding(CardToken.PADDING)
    .backgroundColor(this.resolveBackground())
    .borderRadius(CardToken.RADIUS)
    .borderWidth(this.resolveBorderWidth())
    .borderColor(this.isFocused ? UiColor.BORDER_FOCUSED : UiColor.BRAND_PRIMARY)
    .focusable(true)
    .onClick(() => this.onTap())
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
        this.onTap();
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
    if (this.selected) {
      return UiColor.SURFACE_SELECTED;
    }
    return CardToken.BACKGROUND;
  }

  private resolveBorderWidth(): number {
    if (this.isFocused) {
      return 2;
    }
    if (this.selected) {
      return CardToken.SELECTED_BORDER_WIDTH;
    }
    return 0;
  }

  private buildAccessibilityLabel(): string {
    let label = UiResourceUtil.resolveText(this.title);
    if (UiResourceUtil.hasText(this.subtitle)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.subtitle)
      );
    }
    if (UiResourceUtil.hasText(this.statusLabel)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.statusLabel)
      );
    }
    if (UiResourceUtil.hasText(this.trailingText)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.trailingText)
      );
    }
    if (this.selected) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_selected'), label);
    }
    return label;
  }
}
