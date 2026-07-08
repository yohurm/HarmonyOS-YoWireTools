import { AppThemeMode } from 'common_core';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';

/**
 * V2 global appearance selector: system / light / dark via Menu semantics.
 */
@ComponentV2
export struct ThemeModeSelect {
  @Param selectedMode: AppThemeMode = AppThemeMode.SYSTEM;
  @Event onModeChange: (mode: AppThemeMode) => void = (_mode: AppThemeMode) => {
  };

  build() {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Column({ space: UiSpacing.LABEL_STACK_GAP }) {
        Text($r('app.string.ui_theme_mode_title'))
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .width('100%')
        Text(this.themeSubtitle(this.selectedMode))
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_SECONDARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(this.themeLabel(this.selectedMode))
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.PRIMARY)
        .maxLines(1)
      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor([UiColorToken.TEXT_TERTIARY])
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_ROW_HEIGHT })
    .padding({
      left: UiSpacing.CARD_INNER_PADDING,
      right: UiSpacing.CARD_INNER_PADDING,
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
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
    return mode === this.selectedMode ? `鉁?${label}` : label;
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
