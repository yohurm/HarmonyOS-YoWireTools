import { PageQuery } from './PageQuery';
/**
 * Pagination result wrapper for repository queries.
 */
export class PageResult<T> {
  readonly items: T[];
  readonly total: number;
  readonly query: PageQuery;
  constructor(items: T[], total: number, query: PageQuery) {
    this.items = items;
    this.total = total;
    this.query = query;
  }
  get hasMore(): boolean {
    return this.query.offset + this.items.length < this.total;
  }
}
