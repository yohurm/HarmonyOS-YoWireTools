import { IdGenerator, TimeUtil } from 'common_core';
import {
  DebugEvent,
  ErrorSeverity,
  LogCaptureService,
  LogRecordType,
  ModuleType
} from 'debug_core';

/**
 * Writes classic/BLE scan lifecycle events to LogCaptureService per architecture 搂4.2.
 */
export class BluetoothScanLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();

  static async logClassic(sessionId: string, summary: string, nativeCode: string = ''): Promise<void> {
    await BluetoothScanLogger.capture(sessionId, summary, nativeCode);
  }

  static async logBle(sessionId: string, summary: string, nativeCode: string = ''): Promise<void> {
    await BluetoothScanLogger.capture(sessionId, summary, nativeCode);
  }

  private static async capture(sessionId: string, summary: string, nativeCode: string): Promise<void> {
    const event = new DebugEvent(
      IdGenerator.next('evt'),
      sessionId,
      ModuleType.BLUETOOTH,
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
    await BluetoothScanLogger.logCapture.captureEvent(event);
  }
}
