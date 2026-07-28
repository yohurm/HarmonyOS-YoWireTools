/**
 * Typed key-value bag for structured log events (ArkTS forbids untyped object literals).
 */
export class LogParams {
  private readonly keys: string[] = [];
  private readonly values: Array<string | number | boolean> = [];

  static create(): LogParams {
    return new LogParams();
  }

  put(key: string, value: string | number | boolean): LogParams {
    this.keys.push(key);
    this.values.push(value);
    return this;
  }

  toRecord(): Record<string, string | number | boolean> {
    const record: Record<string, string | number | boolean> = {};
    for (let i = 0; i < this.keys.length; i++) {
      record[this.keys[i]] = this.values[i];
    }
    return record;
  }

  format(): string {
    let body = '';
    for (let i = 0; i < this.keys.length; i++) {
      if (i > 0) {
        body += ', ';
      }
      body += `${this.keys[i]}=${this.values[i]}`;
    }
    return body;
  }
}
