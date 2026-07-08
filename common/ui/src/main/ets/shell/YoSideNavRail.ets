import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';

export interface YoSideNavItem {
  index: number;
  label: ResourceStr;
  symbol: Resource;
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
    Column({ space: UiSpacing.ITEM_GAP }) {
      ForEach(this.items, (item: YoSideNavItem) => {
        this.navItem(item)
      }, (item: YoSideNavItem) => `${item.index}`)
    }
    .width(UiLayoutConstants.SIDE_NAV_WIDTH)
    .height('100%')
    .padding({
      top: UiSpacing.SECTION_GAP,
      bottom: UiSpacing.SECTION_GAP,
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING
    })
    .backgroundColor(UiColorToken.SURFACE)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private navItem(item: YoSideNavItem) {
    Row({ space: UiSpacing.ITEM_GAP }) {
      SymbolGlyph(item.symbol)
        .fontSize(UiSpacing.ICON_SIZE)
        .fontColor([item.index === this.currentIndex ?
          UiColorToken.PRIMARY : UiColorToken.TEXT_SECONDARY])
      Text(item.label)
        .fontSize(UiTypography.BODY_SIZE)
        .fontWeight(item.index === this.currentIndex ? UiTypography.TITLE_WEIGHT : FontWeight.Regular)
        .fontColor(item.index === this.currentIndex ? UiColorToken.PRIMARY : UiColorToken.TEXT_PRIMARY)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(UiLayoutConstants.LIST_ROW_HEIGHT)
    .padding({ left: UiSpacing.ITEM_GAP, right: UiSpacing.ITEM_GAP })
    .borderRadius(UiSpacing.CORNER_RADIUS)
    .backgroundColor(item.index === this.currentIndex ? $r('app.color.ui_emphasize_tertiary') : Color.Transparent)
    .onClick(() => {
      if (item.index !== this.currentIndex) {
        this.onSelect(item.index);
      }
    })
  }
}
