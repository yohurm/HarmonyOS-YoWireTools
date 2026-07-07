import { IMonotonicClock } from './IMonotonicClock';
import { WallClockMonotonicFallback } from './WallClockMonotonicFallback';

/**
 * Injectable monotonic clock registry. Platform layer should register
 * systemDateTime.getUptime(TimeType.ACTIVE) during bootstrap.
 */
export class MonotonicClockRegistry {
  private static clock: IMonotonicClock = new WallClockMonotonicFallback();

  static register(clock: IMonotonicClock): void {
    MonotonicClockRegistry.clock = clock;
  }

  static nowMs(): number {
    return MonotonicClockRegistry.clock.nowMs();
  }

  static resetForTest(): void {
    MonotonicClockRegistry.clock = new WallClockMonotonicFallback();
  }
}
