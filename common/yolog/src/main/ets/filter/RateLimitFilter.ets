/**
 * Limits repeated identical messages within a sliding window.
 */
export class RateLimitFilter {
  private readonly windowMs: number;
  private readonly maxCount: number;
  private readonly counts: Map<string, number> = new Map();
  private readonly windows: Map<string, number> = new Map();

  constructor(windowMs: number, maxCount: number) {
    this.windowMs = windowMs;
    this.maxCount = maxCount;
  }

  accept(key: string, nowMs: number): boolean {
    const windowStart = this.windows.get(key);
    if (windowStart === undefined || nowMs - windowStart >= this.windowMs) {
      this.windows.set(key, nowMs);
      this.counts.set(key, 1);
      return true;
    }
    const count = (this.counts.get(key) ?? 0) + 1;
    this.counts.set(key, count);
    return count <= this.maxCount;
  }
}
