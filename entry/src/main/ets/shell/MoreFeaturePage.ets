import { AppThemeMode } from 'common_core';
import {
  EmptyStateModel,
  EmptyStateView,
  ThemeModeSelect,
  UiResponsive,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@ComponentV2
export struct MoreFeaturePage {
  @Local private themeMode: AppThemeMode = AppThemeMode.SYSTEM;

  @LocalBuilder
  listPane() {
    Column({ space: UiResponsive.CONTROL_GAP }) {
      ThemeModeSelect({
        selectedMode: this.themeMode,
        onModeChange: (mode: AppThemeMode) => {
          this.themeMode = mode;
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding(UiResponsive.CARD_CONTENT_PADDING)
  }

  @LocalBuilder
  detailPane() {
    Column() {
      EmptyStateView({
        model: new EmptyStateModel(
          $r('app.string.more_settings_detail_title'),
          $r('app.string.more_settings_detail_message')
        )
      })
    }
    .width('100%')
    .height('100%')
    .padding(UiResponsive.CARD_CONTENT_PADDING)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @LocalBuilder
  pageContent() {
    YoSplitScaffold({
      listPane: this.listPane,
      detailPane: this.detailPane
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.more_hub_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
