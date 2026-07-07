import { PermissionUiState } from 'common_platform';
import { EmptyStateModel } from '../model/EmptyStateModel';
import { ErrorStateModel } from '../model/ErrorStateModel';
import { LoadingStateModel } from '../model/LoadingStateModel';
import { UiPageState } from '../model/UiPageState';
import { EmptyStateView } from './EmptyStateView';
import { ErrorStateView } from './ErrorStateView';
import { LoadingStateView } from './LoadingStateView';
import { PermissionDeniedView } from './PermissionDeniedView';
/**
 * Switches between content / loading / empty / error / permission states.
 * ViewModel drives `state` and model objects; UI never reads platform callbacks directly.
 */
@ComponentV2
export struct ContentStateHost {
  @Param state: UiPageState = UiPageState.CONTENT;
  @Param emptyModel: EmptyStateModel = new EmptyStateModel();
  @Param errorModel: ErrorStateModel = new ErrorStateModel();
  @Param loadingModel: LoadingStateModel = new LoadingStateModel();
  @Param permissionState: PermissionUiState | undefined = undefined;
  @BuilderParam content: () => void = this.defaultContent;
  @Event onEmptyPrimaryAction: () => void = () => {
  };
  @Event onEmptySecondaryAction: () => void = () => {
  };
  @Event onRetry: () => void = () => {
  };
  @Event onRequestPermission: () => void = () => {
  };
  @Event onOpenSettings: () => void = () => {
  };
  @Builder
  defaultContent() {
  }
  build() {
    Stack() {
      if (this.state === UiPageState.CONTENT) {
        this.content()
      } else if (this.state === UiPageState.LOADING) {
        LoadingStateView({ model: this.loadingModel })
      } else if (this.state === UiPageState.EMPTY) {
        EmptyStateView({
          model: this.emptyModel,
          onPrimaryAction: () => this.onEmptyPrimaryAction(),
          onSecondaryAction: () => this.onEmptySecondaryAction()
        })
      } else if (this.state === UiPageState.ERROR) {
        ErrorStateView({
          model: this.errorModel,
          onRetry: () => this.onRetry()
        })
      } else if (this.state === UiPageState.PERMISSION) {
        PermissionDeniedView({
          state: this.permissionState,
          onRequestPermission: () => this.onRequestPermission(),
          onOpenSettings: () => this.onOpenSettings()
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
