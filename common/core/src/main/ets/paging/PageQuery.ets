/**
 * Pagination query for log repository and list screens.
 */
export class PageQuery {
  readonly offset: number;
  readonly limit: number;

  constructor(offset: number = 0, limit: number = 50) {
    this.offset = Math.max(0, offset);
    this.limit = Math.max(1, limit);
  }

  nextPage(): PageQuery {
    return new PageQuery(this.offset + this.limit, this.limit);
  }
}
