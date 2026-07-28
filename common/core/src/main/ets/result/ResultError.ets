/**
 * Generic error carrier for Result without business domain codes.
 * Domain-specific errors (DebugError) live in debug_core.
 */
export class ResultError {
  readonly code: string;
  readonly message: string;
  readonly cause?: Error;
  readonly attributes: Record<string, string | number | boolean>;
  readonly nativeCode: string;

  constructor(
    code: string,
    message: string,
    cause?: Error,
    attributes: Record<string, string | number | boolean> = {},
    nativeCode: string = ''
  ) {
    this.code = code;
    this.message = message;
    this.cause = cause;
    this.attributes = attributes;
    this.nativeCode = nativeCode.length > 0 ? nativeCode : ResultError.readNativeCode(cause, attributes);
  }

  static fromError(code: string, error: Error): ResultError {
    const native = ResultError.extractNativeCode(error);
    return new ResultError(code, error.message, error, {}, native);
  }

  /**
   * Prefer this at Kit / BusinessError boundaries so platform codes survive to UI/logs.
   */
  static fromBusinessError(appCode: string, err: Object, message: string = ''): ResultError {
    const asError = err as Error;
    const resolvedMessage = message.length > 0 ? message : (typeof asError.message === 'string' ? asError.message : `${err}`);
    const native = ResultError.extractNativeCode(err);
    return new ResultError(appCode, resolvedMessage, asError, {}, native);
  }

  private static readNativeCode(
    cause: Error | undefined,
    attributes: Record<string, string | number | boolean>
  ): string {
    const fromAttr = attributes['nativeCode'];
    if (fromAttr !== undefined) {
      return `${fromAttr}`;
    }
    if (cause !== undefined) {
      return ResultError.extractNativeCode(cause);
    }
    return '';
  }

  private static extractNativeCode(err: Object): string {
    const record = err as Record<string, string | number | boolean | undefined>;
    const code = record['code'];
    if (typeof code === 'number' || typeof code === 'string') {
      return `${code}`;
    }
    return '';
  }
}
