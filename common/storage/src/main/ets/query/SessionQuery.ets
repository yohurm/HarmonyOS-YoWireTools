/**
 * Session list query parameters.
 */
export class SessionQuery {
  readonly module: string;
  readonly state: string;
  readonly offset: number;
  readonly limit: number;

  constructor(module: string = '', state: string = '', offset: number = 0, limit: number = 50) {
    this.module = module;
    this.state = state;
    this.offset = offset;
    this.limit = limit;
  }
}
