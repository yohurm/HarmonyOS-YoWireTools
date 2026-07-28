import {
  Direction,
  LogCaptureService,
  ModuleType,
  ProtocolType
} from 'debug_core';

/**
 * Session evidence helper for message-oriented WiFi protocols (WS / MQTT)
 * that are not yet wrapped as ITransportSession.
 */
export class WifiMessageLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();
  private static readonly MAX_BODY_BYTES: number = 256 * 1024;

  static async logText(
    sessionId: string,
    protocol: ProtocolType,
    direction: Direction,
    text: string,
    summaryPrefix: string = ''
  ): Promise<void> {
    const bytes = WifiMessageLogger.textToBytes(text);
    const truncated = bytes.length > WifiMessageLogger.MAX_BODY_BYTES;
    const stored = truncated ? bytes.subarray(0, WifiMessageLogger.MAX_BODY_BYTES) : bytes;
    const prefix = summaryPrefix.length > 0 ? `${summaryPrefix} ` : '';
    const summary = truncated ?
      `${prefix}size=${text.length} truncated=${WifiMessageLogger.MAX_BODY_BYTES}` :
      `${prefix}size=${text.length}`;
    if (stored.length > 0) {
      await WifiMessageLogger.logCapture.captureBytes(
        sessionId,
        ModuleType.WIFI,
        protocol,
        direction,
        stored
      );
      return;
    }
    await WifiMessageLogger.logCapture.captureBytes(
      sessionId,
      ModuleType.WIFI,
      protocol,
      direction,
      WifiMessageLogger.textToBytes(summary.length > 0 ? summary : 'empty')
    );
  }

  private static textToBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i) & 0xff;
    }
    return bytes;
  }
}
