import { IdGenerator, TimeUtil } from 'common_core';
import {
  DebugEvent,
  ErrorSeverity,
  LogCaptureService,
  LogRecordType,
  ModuleType
} from 'debug_core';

export class WifiScanLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();

  static async log(sessionId: string, summary: string, nativeCode: string = ''): Promise<void> {
    const event = new DebugEvent(
      IdGenerator.next('evt'),
      sessionId,
      ModuleType.WIFI,
      LogRecordType.LIFECYCLE,
      'internal',
      TimeUtil.nowMs(),
      ErrorSeverity.INFO,
      summary,
      undefined,
      nativeCode,
      '',
      {}
    );
    await WifiScanLogger.logCapture.captureEvent(event);
  }
}
