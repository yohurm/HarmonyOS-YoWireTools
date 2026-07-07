/**
 * Monotonic elapsed-time source for timeouts, retry intervals and log ordering.
 * Implementations must not go backwards when system wall clock is adjusted.
 */
export interface IMonotonicClock {
  nowMs(): number;
}
