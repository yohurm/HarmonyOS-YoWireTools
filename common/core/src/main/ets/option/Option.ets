/**
 * Optional value wrapper for nullable domain fields without using undefined alone.
 */
export class Option<T> {
  readonly hasValue: boolean;
  readonly value: T | undefined;

  private constructor(hasValue: boolean, value: T | undefined) {
    this.hasValue = hasValue;
    this.value = value;
  }

  static some<T>(value: T): Option<T> {
    return new Option<T>(true, value);
  }

  static none<T>(): Option<T> {
    return new Option<T>(false, undefined);
  }

  static fromNullable<T>(value: T | undefined | null): Option<T> {
    if (value === undefined || value === null) {
      return Option.none();
    }
    return Option.some(value);
  }

  getOrDefault(defaultValue: T): T {
    if (this.hasValue && this.value !== undefined) {
      return this.value;
    }
    return defaultValue;
  }

  map<U>(mapper: (value: T) => U): Option<U> {
    if (!this.hasValue || this.value === undefined) {
      return Option.none();
    }
    return Option.some(mapper(this.value));
  }
}
