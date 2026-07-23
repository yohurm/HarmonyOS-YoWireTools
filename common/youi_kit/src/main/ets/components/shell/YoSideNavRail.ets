import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoNavigationToken } from '../../token/component/YoNavigationToken';
import { YoSize } from '../../token/foundation/YoSize';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoRadius } from '../../token/foundation/YoRadius';
import { YoResourceUtil } from '../../util/YoResourceUtil';

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
    Row({ space: YoSpace.M }) {
      SymbolGlyph(this.item.symbol)
        .fontSize(YoSize.ICON_M)
        .fontColor([this.selected ? YoColor.BRAND_PRIMARY : YoColor.TEXT_SECONDARY])
        .accessibilityLevel('no')
      Text(this.item.label)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontWeight(this.selected ? YoTypeStyle.SUBTITLE_M.weight : YoTypeStyle.BODY_M.weight)
        .fontColor(this.selected ? YoColor.BRAND_PRIMARY : YoColor.TEXT_PRIMARY)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .constraintSize({ minHeight: YoSize.TOUCH_TARGET_MIN })
    .height(YoSize.LIST_ROW_HEIGHT)
    .padding({ left: YoSpace.M, right: YoSpace.M })
    .borderRadius(YoRadius.LARGE)
    .backgroundColor(this.resolveBackground())
    .borderWidth(this.isFocused ? 2 : 0)
    .borderColor(YoColor.BORDER_FOCUSED)
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
    let label = YoResourceUtil.resolveText(this.item.label);
    if (this.selected) {
      label = YoResourceUtil.format($r('app.string.youi_a11y_selected'), label);
    }
    return label;
  }

  private resolveBackground(): ResourceColor {
    if (this.isPressed) {
      return YoColor.INTERACTIVE_PRESSED;
    }
    if (this.isFocused) {
      return YoColor.INTERACTIVE_FOCUSED;
    }
    if (this.isHovered) {
      return YoColor.INTERACTIVE_HOVER;
    }
    if (this.selected) {
      return YoColor.SURFACE_SELECTED;
    }
    return Color.Transparent;
  }
}

/**
 * >=840vp 侧边导航栏（响应式应用架构 · 侧边导航栏）。
 */
@ComponentV2
export struct YoSideNavRail {
  @Param currentIndex: number = 0;
  @Param items: YoSideNavItem[] = [];
  @Event onSelect: (index: number) => void = (_index: number) => {
  };

  build() {
    Column({ space: YoSpace.M }) {
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
    .width(YoNavigationToken.SIDE_NAV_WIDTH)
    .height('100%')
    .padding({
      top: YoSpace.XL,
      bottom: YoSpace.XL,
      left: YoSpace.XL,
      right: YoSpace.XL
    })
    .backgroundColor(YoColor.SURFACE_CARD)
    .alignItems(HorizontalAlign.Start)
  }
}
