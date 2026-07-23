/**
 * 加载遮罩 / 全页加载展示模型。
 */
export class YoLoadingStateModel {
  readonly message: ResourceStr;
  readonly showProgress: boolean;

  constructor(message: ResourceStr = $r('app.string.youi_loading_default_message'), showProgress: boolean = true) {
    this.message = message;
    this.showProgress = showProgress;
  }
}
