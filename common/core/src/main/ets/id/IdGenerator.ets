import { TimeUtil } from '../time/TimeUtil';

/**
 * Generates stable string identifiers for sessions, logs, commands.
 */
export class IdGenerator {
  private static sequence: number = 0;

  static next(prefix: string): string {
    IdGenerator.sequence++;
    return `${prefix}_${TimeUtil.nowMs()}_${IdGenerator.sequence}`;
  }

  static resetSequenceForTest(): void {
    IdGenerator.sequence = 0;
  }
}
