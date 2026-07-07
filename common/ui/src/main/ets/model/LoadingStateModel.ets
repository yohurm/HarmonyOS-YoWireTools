/**
 * Loading overlay / full-page loading presentation model.
 */
export class LoadingStateModel {
  readonly message: string;
  readonly showProgress: boolean;

  constructor(message: string = '加载中...', showProgress: boolean = true) {
    this.message = message;
    this.showProgress = showProgress;
  }
}
