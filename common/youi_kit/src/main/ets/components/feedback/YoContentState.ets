import { PermissionUiState } from 'common_platform';
import { YoEmptyStateModel } from '../../model/YoEmptyStateModel';
import { YoErrorStateModel } from '../../model/YoErrorStateModel';
import { YoLoadingStateModel } from '../../model/YoLoadingStateModel';
import { YoPageState } from '../../model/YoPageState';
import { YoEmpty } from './YoEmpty';
import { YoError } from './YoError';
import { YoLoading } from './YoLoading';
import { YoPermissionDenied } from './YoPermissionDenied';
/**
 * 在 content / loading / empty / error / permission 状态间切换。
 * ViewModel 驱动 `state` 与 model 对象；UI 不直接读取平台回调。
 * @BuilderParam 槽位请用箭头函数委托调用方 @Builder；勿在内联 lambda 中直接调子组件。
 */
@ComponentV2
export struct YoContentState {
  @Param state: YoPageState = YoPageState.CONTENT;
  @Param emptyModel: YoEmptyStateModel = new YoEmptyStateModel();
  @Param errorModel: YoErrorStateModel = new YoErrorStateModel();
  @Param loadingModel: YoLoadingStateModel = new YoLoadingStateModel();
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
      if (this.state === YoPageState.CONTENT) {
        this.content()
      } else if (this.state === YoPageState.LOADING) {
        YoLoading({ model: this.loadingModel })
      } else if (this.state === YoPageState.EMPTY) {
        YoEmpty({
          model: this.emptyModel,
          onPrimaryAction: () => this.onEmptyPrimaryAction(),
          onSecondaryAction: () => this.onEmptySecondaryAction()
        })
      } else if (this.state === YoPageState.ERROR) {
        YoError({
          model: this.errorModel,
          onRetry: () => this.onRetry()
        })
      } else if (this.state === YoPageState.PERMISSION) {
        YoPermissionDenied({
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
