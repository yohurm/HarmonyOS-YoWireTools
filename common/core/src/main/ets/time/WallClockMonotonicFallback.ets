import { IMonotonicClock } from './IMonotonicClock';

/**
 * Fallback monotonic clock when platform has not injected a real uptime source.
 * Uses wall clock and is therefore vulnerable to system time adjustments.
 */
export class WallClockMonotonicFallback implements IMonotonicClock {
  nowMs(): number {
    return Date.now();
  }
}
