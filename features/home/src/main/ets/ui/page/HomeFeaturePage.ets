import {
  YoContentState,
  YoErrorStateModel,
  YoLoadingStateModel,
  YoNavDestinationKind,
  YoPageShell,
  YoPageState
} from 'youi_kit';
import { HomeWorkbenchViewModel } from '../../viewmodel/HomeWorkbenchViewModel';
import { HomeWorkbenchContentView } from '../view/HomeWorkbenchContentView';

@ComponentV2
export struct HomeFeaturePage {
  @Event onOpenTarget: (target: string) => void = (_target: string) => {
  };
  @Local vm: HomeWorkbenchViewModel = new HomeWorkbenchViewModel();

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
    if (this.vm.loadFailed) {
      return YoPageState.ERROR;
    }
    return YoPageState.CONTENT;
  }

  @LocalBuilder
  pageContent() {
    YoContentState({
      state: this.resolvePageState(),
      loadingModel: new YoLoadingStateModel($r('app.string.youi_loading_default_message')),
      errorModel: YoErrorStateModel.fromLayers(
        $r('app.string.home_error_title'),
        $r('app.string.home_error_cause'),
        $r('app.string.home_error_next'),
        true
      ),
      content: this.pageBody,
      onRetry: () => {
        void this.vm.refresh();
      }
    })
  }

  @LocalBuilder
  pageBody() {
    HomeWorkbenchContentView({
      vm: this.vm,
      onOpenTarget: (target: string) => {
        this.onOpenTarget(target);
      }
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.home_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      immersiveTitleBar: true,
      content: this.pageContent
    })
  }
}
