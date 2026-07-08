/**
 * Loading overlay / full-page loading presentation model.
 */
export class LoadingStateModel {
  readonly message: ResourceStr;
  readonly showProgress: boolean;

  constructor(message: ResourceStr = $r('app.string.ui_loading_default_message'), showProgress: boolean = true) {
    this.message = message;
    this.showProgress = showProgress;
  }
}
