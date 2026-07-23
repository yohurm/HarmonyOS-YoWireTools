/**
 * 按 PRD §9 / 架构 §10 的三层错误展示。
 */
export class YoErrorStateModel {
  readonly userMessage: ResourceStr;
  readonly causeHint: ResourceStr;
  readonly nextStep: ResourceStr;
  readonly appCode: string;
  readonly nativeCode: string;
  readonly retryable: boolean;
  readonly actionLabel: ResourceStr;

  constructor(
    userMessage: ResourceStr = $r('app.string.youi_error_default_title'),
    causeHint: ResourceStr = '',
    nextStep: ResourceStr = '',
    appCode: string = '',
    nativeCode: string = '',
    retryable: boolean = false,
    actionLabel: ResourceStr = $r('app.string.youi_retry')
  ) {
    this.userMessage = userMessage;
    this.causeHint = causeHint;
    this.nextStep = nextStep;
    this.appCode = appCode;
    this.nativeCode = nativeCode;
    this.retryable = retryable;
    this.actionLabel = actionLabel;
  }

  static fromLayers(
    userMessage: ResourceStr,
    causeHint: ResourceStr,
    nextStep: ResourceStr,
    retryable: boolean = true,
    appCode: string = '',
    nativeCode: string = ''
  ): YoErrorStateModel {
    return new YoErrorStateModel(
      userMessage,
      causeHint,
      nextStep,
      appCode,
      nativeCode,
      retryable,
      retryable ? $r('app.string.youi_retry') : ''
    );
  }
}
