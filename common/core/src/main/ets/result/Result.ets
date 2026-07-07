import { ResultError } from './ResultError';

/**
 * Discriminated success/failure result for repository and use-case boundaries.
 * Success is determined solely by {@link success}, not by whether value is defined.
 */
export class Result<T> {
  readonly success: boolean;
  readonly value: T | undefined;
  readonly error: ResultError | undefined;

  private constructor(success: boolean, value: T | undefined, error: ResultError | undefined) {
    this.success = success;
    this.value = value;
    this.error = error;
  }

  static ok<T>(value?: T): Result<T> {
    return new Result<T>(true, value, undefined);
  }

  static fail<T>(error: ResultError): Result<T> {
    return new Result<T>(false, undefined, error);
  }

  static failMessage<T>(code: string, message: string): Result<T> {
    return Result.fail(new ResultError(code, message));
  }

  getOrThrow(): T {
    if (this.success) {
      return this.value as T;
    }
    if (this.error !== undefined) {
      throw new Error(`${this.error.code}: ${this.error.message}`);
    }
    throw new Error('Result failed without error detail');
  }

  map<U>(mapper: (value: T) => U): Result<U> {
    if (!this.success) {
      return Result.fail(this.error ?? new ResultError('CORE-MAP-001', 'Cannot map failed result'));
    }
    try {
      return Result.ok(mapper(this.value as T));
    } catch (error) {
      const err = error as Error;
      return Result.fail(ResultError.fromError('CORE-MAP-002', err));
    }
  }

  async mapAsync<U>(mapper: (value: T) => Promise<U>): Promise<Result<U>> {
    if (!this.success) {
      return Result.fail(this.error ?? new ResultError('CORE-MAP-003', 'Cannot map failed result'));
    }
    try {
      const mapped = await mapper(this.value as T);
      return Result.ok(mapped);
    } catch (error) {
      const err = error as Error;
      return Result.fail(ResultError.fromError('CORE-MAP-004', err));
    }
  }
}
