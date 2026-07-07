/**
 * Three-layer error presentation per PRD §9 / architecture §10.
 * userMessage → causeHint → nextStep
 */
export class ErrorStateModel {
  readonly userMessage: string;
  readonly causeHint: string;
  readonly nextStep: string;
  readonly appCode: string;
  readonly nativeCode: string;
  readonly retryable: boolean;
  readonly actionLabel: string;

  constructor(
    userMessage: string = '',
    causeHint: string = '',
    nextStep: string = '',
    appCode: string = '',
    nativeCode: string = '',
    retryable: boolean = false,
    actionLabel: string = ''
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
    userMessage: string,
    causeHint: string,
    nextStep: string,
    retryable: boolean = true,
    appCode: string = '',
    nativeCode: string = ''
  ): ErrorStateModel {
    return new ErrorStateModel(
      userMessage,
      causeHint,
      nextStep,
      appCode,
      nativeCode,
      retryable,
      retryable ? 'Retry' : ''
    );
  }
}
