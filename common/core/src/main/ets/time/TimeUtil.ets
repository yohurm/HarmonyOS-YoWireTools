import { MonotonicClockRegistry } from './MonotonicClockRegistry';

/**
 * Time helpers for session timestamps and log records (millisecond precision per PRD).
 * - nowMs(): wall clock for user-visible timestamps and persistence.
 * - monotonicMs(): elapsed time for timeouts/retries; platform injects uptime via MonotonicClockRegistry.
 */
export class TimeUtil {
  static nowMs(): number {
    return Date.now();
  }

  static monotonicMs(): number {
    return MonotonicClockRegistry.nowMs();
  }

  static formatIso(timestampMs: number): string {
    return new Date(timestampMs).toISOString();
  }

  static formatLocal(timestampMs: number): string {
    const date = new Date(timestampMs);
    const pad = (n: number, width: number = 2): string => {
      const text = `${n}`;
      if (text.length >= width) {
        return text;
      }
      return '0'.repeat(width - text.length) + text;
    };
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ` +
      `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}.${pad(date.getMilliseconds(), 3)}`;
  }

  static elapsedMs(startMs: number, endMs: number = TimeUtil.nowMs()): number {
    return Math.max(0, endMs - startMs);
  }

  static elapsedMonotonicMs(startMs: number, endMs: number = TimeUtil.monotonicMs()): number {
    return Math.max(0, endMs - startMs);
  }
}
