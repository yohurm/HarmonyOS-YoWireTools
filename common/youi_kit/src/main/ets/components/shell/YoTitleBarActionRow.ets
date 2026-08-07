import { YoSize } from '../../token/foundation/YoSize';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoTitleBarMenuItem } from '../../model/YoTitleBarMenuItem';

/**
 * Dialog / 非 HdsNavigation 表面的标题栏操作图标行。
 * 数据模型同 {@link YoTitleBarMenuItem}；视觉对齐 HDS 浅色 menuStyle
 *（icon_primary + comp_background_tertiary 圆形底）。
 */
@Component
export struct YoTitleBarActionRow {
  @Prop items: YoTitleBarMenuItem[] = [];

  build() {
    Row({ space: YoSpace.M }) {
      ForEach(this.items, (item: YoTitleBarMenuItem) => {
        Row() {
          SymbolGlyph(item.icon)
            .fontSize(YoSize.ICON_M)
            .fontColor([item.iconColor !== undefined ? item.iconColor : $r('sys.color.icon_primary')])
            .width(YoSize.ICON_M)
            .height(YoSize.ICON_M)
        }
        .width(YoSize.BUTTON_HEIGHT_COMPACT)
        .height(YoSize.BUTTON_HEIGHT_COMPACT)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(YoSize.BUTTON_HEIGHT_COMPACT / 2)
        .opacity(item.enabled ? 1 : 0.4)
        .enabled(item.enabled)
        .id(item.componentId.length > 0 ? item.componentId : item.key)
        .onClick(() => {
          if (item.enabled) {
            item.action();
          }
        })
      }, (item: YoTitleBarMenuItem) => item.key)
    }
    .alignItems(VerticalAlign.Center)
  }
}
