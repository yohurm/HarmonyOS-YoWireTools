/**
 * Log retention and cleanup policy.
 */
export class LogCleanupPolicy {
  readonly retentionDays: number;
  readonly maxSizeMb: number;
  readonly beforeTimestampMs: number;

  constructor(retentionDays: number, maxSizeMb: number, beforeTimestampMs: number = 0) {
    this.retentionDays = retentionDays;
    this.maxSizeMb = maxSizeMb;
    this.beforeTimestampMs = beforeTimestampMs;
  }
}
