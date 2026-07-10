import { AppThemeMode } from 'common_core';
import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';

/**
 * V2 global appearance selector: system / light / dark via Menu semantics.
 */
@ComponentV2
export struct ThemeModeSelect {
  @Param selectedMode: AppThemeMode = AppThemeMode.SYSTEM;
  @Event onModeChange: (mode: AppThemeMode) => void = (_mode: AppThemeMode) => {
  };

  build() {
    Row({ space: UiSpace.M }) {
      Column({ space: UiSpace.XXS }) {
        Text($r('app.string.ui_theme_mode_title'))
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(UiColor.TEXT_PRIMARY)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .width('100%')
        Text(this.themeSubtitle(this.selectedMode))
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_SECONDARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(this.themeLabel(this.selectedMode))
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.BRAND_PRIMARY)
        .maxLines(1)
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(UiSize.ICON_S)
        .fontColor([UiColor.ICON_TERTIARY])
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.LIST_ROW_HEIGHT })
    .padding(CardToken.PADDING_COMPACT)
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS)
    .bindMenu([
      {
        value: this.menuItemLabel(AppThemeMode.SYSTEM),
        action: () => {
          this.onModeChange(AppThemeMode.SYSTEM);
        }
      },
      {
        value: this.menuItemLabel(AppThemeMode.LIGHT),
        action: () => {
          this.onModeChange(AppThemeMode.LIGHT);
        }
      },
      {
        value: this.menuItemLabel(AppThemeMode.DARK),
        action: () => {
          this.onModeChange(AppThemeMode.DARK);
        }
      }
    ])
  }

  private menuItemLabel(mode: AppThemeMode): string {
    const label = this.themeLabel(mode) as string;
    return mode === this.selectedMode ?
      UiResourceUtil.format($r('app.string.ui_selected_prefix'), label) : label;
  }

  private themeLabel(mode: AppThemeMode): ResourceStr {
    switch (mode) {
      case AppThemeMode.LIGHT:
        return $r('app.string.ui_theme_light');
      case AppThemeMode.DARK:
        return $r('app.string.ui_theme_dark');
      default:
        return $r('app.string.ui_theme_system');
    }
  }

  private themeSubtitle(mode: AppThemeMode): ResourceStr {
    switch (mode) {
      case AppThemeMode.LIGHT:
        return $r('app.string.ui_theme_light_subtitle');
      case AppThemeMode.DARK:
        return $r('app.string.ui_theme_dark_subtitle');
      default:
        return $r('app.string.ui_theme_system_subtitle');
    }
  }
}
