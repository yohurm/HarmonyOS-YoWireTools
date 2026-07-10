import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { NavigationToken } from '../token/component/NavigationToken';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiRadius } from '../token/foundation/UiRadius';
import { UiResourceUtil } from '../util/UiResourceUtil';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

export interface YoSideNavItem {
  index: number;
  label: ResourceStr;
  symbol: Resource;
}

@ComponentV2
struct YoSideNavRailItem {
  @Param item: YoSideNavItem = { index: 0, label: '', symbol: $r('sys.symbol.circle') };
  @Param selected: boolean = false;
  @Event onSelect: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row({ space: UiSpace.M }) {
      SymbolGlyph(this.item.symbol)
        .fontSize(UiSize.ICON_M)
        .fontColor([this.selected ? UiColor.BRAND_PRIMARY : UiColor.TEXT_SECONDARY])
        .accessibilityLevel('no')
      Text(this.item.label)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontWeight(this.selected ? UiTypeStyle.SUBTITLE_M.weight : UiTypeStyle.BODY_M.weight)
        .fontColor(this.selected ? UiColor.BRAND_PRIMARY : UiColor.TEXT_PRIMARY)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.TOUCH_TARGET_MIN })
    .height(UiSize.LIST_ROW_HEIGHT)
    .padding({ left: UiSpace.M, right: UiSpace.M })
    .borderRadius(UiRadius.LARGE)
    .backgroundColor(this.resolveBackground())
    .borderWidth(this.isFocused ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .focusable(true)
    .onClick(() => {
      if (!this.selected) {
        this.onSelect();
      }
    })
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
        this.onSelect();
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private buildAccessibilityLabel(): string {
    let label = UiResourceUtil.resolveText(this.item.label);
    if (this.selected) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_selected'), label);
    }
    return label;
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
    return Color.Transparent;
  }
}

/**
 * Side navigation rail for >=840vp (响应式应用架构 · 侧边导航栏).
 */
@ComponentV2
export struct YoSideNavRail {
  @Param currentIndex: number = 0;
  @Param items: YoSideNavItem[] = [];
  @Event onSelect: (index: number) => void = (_index: number) => {
  };

  build() {
    Column({ space: UiSpace.M }) {
      ForEach(this.items, (item: YoSideNavItem) => {
        YoSideNavRailItem({
          item: item,
          selected: item.index === this.currentIndex,
          onSelect: () => {
            this.onSelect(item.index);
          }
        })
      }, (item: YoSideNavItem) => `${item.index}`)
    }
    .width(NavigationToken.SIDE_NAV_WIDTH)
    .height('100%')
    .padding({
      top: UiSpace.XL,
      bottom: UiSpace.XL,
      left: UiSpace.XL,
      right: UiSpace.XL
    })
    .backgroundColor(UiColor.SURFACE_CARD)
    .alignItems(HorizontalAlign.Start)
  }
}
