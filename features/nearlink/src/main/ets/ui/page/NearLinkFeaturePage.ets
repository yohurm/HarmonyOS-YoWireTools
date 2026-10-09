import {
  YoContentState,
  YoLoadingStateModel,
  YoNavDestinationKind,
  YoPageShell,
  YoPageState
} from 'youi_kit';
import { NearLinkOverviewViewModel } from '../../viewmodel/NearLinkOverviewViewModel';
import { NearLinkOverviewContentView } from '../view/NearLinkOverviewContentView';

@ComponentV2
export struct NearLinkFeaturePage {
  @Local vm: NearLinkOverviewViewModel = new NearLinkOverviewViewModel();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.onPageDisappear();
  }

  private resolvePageState(): YoPageState {
    if (!this.vm.hasLoaded) {
      return YoPageState.LOADING;
    }
    if (!this.vm.permissionGranted) {
      return YoPageState.PERMISSION;
    }
    return YoPageState.CONTENT;
  }

  @LocalBuilder
  pageContent() {
    YoContentState({
      state: this.resolvePageState(),
      loadingModel: new YoLoadingStateModel($r('app.string.youi_loading_default_message')),
      permissionState: this.vm.permissionUiState,
      content: this.pageBody,
      onRequestPermission: () => {
        void this.vm.requestPermission();
      },
      onOpenSettings: () => {
        void this.vm.requestPermission();
      }
    })
  }

  @LocalBuilder
  pageBody() {
    NearLinkOverviewContentView({ vm: this.vm })
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      immersiveTitleBar: true,
      content: this.pageContent
    })
  }
}
