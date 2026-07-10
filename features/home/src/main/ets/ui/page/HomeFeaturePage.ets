import {
  ContentStateHost,
  LoadingStateModel,
  ModuleCapabilityCard,
  UiPageState,
  UiResponsive,
  YoNavDestinationKind,
  YoPageShell
} from 'common_ui';

@ComponentV2
export struct HomeFeaturePage {
  @Local private isLoading: boolean = true;

  aboutToAppear(): void {
    this.isLoading = false;
  }

  @LocalBuilder
  pageContent() {
    ContentStateHost({
      state: this.isLoading ? UiPageState.LOADING : UiPageState.CONTENT,
      loadingModel: new LoadingStateModel($r('app.string.ui_loading_default_message')),
      content: this.pageBody
    })
  }

  @LocalBuilder
  pageBody() {
    Column({ space: UiResponsive.SECTION_GAP }) {
      ModuleCapabilityCard({
        moduleName: $r('app.string.home_module_bluetooth'),
        statusLabel: $r('app.string.home_status_ready'),
        statusTone: 'success',
        description: $r('app.string.home_module_bluetooth_desc'),
        actionLabel: $r('app.string.ui_session_enter'),
        sessionCount: 2,
        onAction: () => {
        },
        onTap: () => {
        }
      })
      ModuleCapabilityCard({
        moduleName: $r('app.string.home_module_wifi'),
        statusLabel: $r('app.string.home_status_ready'),
        statusTone: 'brand',
        description: $r('app.string.home_module_wifi_desc'),
        actionLabel: $r('app.string.ui_session_enter'),
        sessionCount: 1,
        onAction: () => {
        },
        onTap: () => {
        }
      })
      ModuleCapabilityCard({
        moduleName: $r('app.string.home_module_nearlink'),
        statusLabel: $r('app.string.home_status_blocked'),
        statusTone: 'warning',
        description: $r('app.string.home_module_nearlink_desc'),
        disabled: true,
        onTap: () => {
        }
      })
    }
    .width('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.home_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: true,
      content: this.pageContent
    })
  }
}
