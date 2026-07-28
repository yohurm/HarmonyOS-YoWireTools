import { IdGenerator, TimeUtil } from 'common_core';
import { DebugEvent, LogCaptureService, LogRecordType, ModuleType, ErrorSeverity } from 'debug_core';

/**
 * Logs SPP reconnect sub-events per architecture 02-搂8.1 item 5.
 */
export class SppReconnectEventLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();

  static async logReconnectAttempt(sessionId: string, attempt: number, reason: string): Promise<void> {
    const attrs: Record<string, string | number | boolean> = {};
    attrs['attempt'] = attempt;
    attrs['reason'] = reason;
    const event = new DebugEvent(
      IdGenerator.next('evt'),
      sessionId,
      ModuleType.BLUETOOTH,
      LogRecordType.LIFECYCLE,
      'internal',
      TimeUtil.nowMs(),
      ErrorSeverity.INFO,
      `SPP reconnect attempt ${attempt}: ${reason}`,
      undefined,
      '',
      '',
      attrs
    );
    await SppReconnectEventLogger.logCapture.captureEvent(event);
  }
}
