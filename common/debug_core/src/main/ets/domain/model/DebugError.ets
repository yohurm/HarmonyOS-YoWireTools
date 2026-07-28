import { ResultError } from 'common_core';
import { ErrorSeverity } from '../enums/DomainEnums';

/**
 * Application error per architecture §10 / 05-§3.5.
 */
export class DebugError {
  readonly appCode: string;
  readonly message: string;
  readonly userAction: string;
  readonly nativeCode: string;
  readonly nativeMessage: string;
  readonly severity: ErrorSeverity;
  readonly retryable: boolean;
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    appCode: string,
    message: string,
    userAction: string = '',
    nativeCode: string = '',
    nativeMessage: string = '',
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    retryable: boolean = false,
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.appCode = appCode;
    this.message = message;
    this.userAction = userAction;
    this.nativeCode = nativeCode;
    this.nativeMessage = nativeMessage;
    this.severity = severity;
    this.retryable = retryable;
    this.attributes = attributes;
  }

  static fromResultError(
    err: ResultError,
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    retryable: boolean = false,
    userAction: string = ''
  ): DebugError {
    const nativeMessage = err.cause?.message ?? '';
    return new DebugError(
      err.code,
      err.message,
      userAction,
      err.nativeCode,
      nativeMessage,
      severity,
      retryable,
      err.attributes
    );
  }
}
