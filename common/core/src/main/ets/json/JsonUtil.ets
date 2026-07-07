import { Result } from '../result/Result';
import { ResultError } from '../result/ResultError';

/**
 * Safe JSON parse/stringify helpers for storage and export.
 */
export class JsonUtil {
  static stringify(value: Object): Result<string> {
    try {
      return Result.ok(JSON.stringify(value));
    } catch (error) {
      const err = error as Error;
      return Result.fail(ResultError.fromError('CORE-JSON-001', err));
    }
  }

  static parse<T>(text: string): Result<T> {
    try {
      const parsed = JSON.parse(text) as T;
      return Result.ok(parsed);
    } catch (error) {
      const err = error as Error;
      return Result.fail(ResultError.fromError('CORE-JSON-002', err));
    }
  }
}
