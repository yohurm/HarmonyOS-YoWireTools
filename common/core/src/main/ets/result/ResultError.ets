/**
 * Generic error carrier for Result without business domain codes.
 * Domain-specific errors (DebugError) live in feature_debug_core.
 */
export class ResultError {
  readonly code: string;
  readonly message: string;
  readonly cause?: Error;
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    code: string,
    message: string,
    cause?: Error,
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.code = code;
    this.message = message;
    this.cause = cause;
    this.attributes = attributes;
  }

  static fromError(code: string, error: Error): ResultError {
    return new ResultError(code, error.message, error);
  }
}
