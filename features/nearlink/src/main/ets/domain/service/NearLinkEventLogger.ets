import { IdGenerator, TimeUtil } from 'common_core';
import {
  DebugEvent,
  Direction,
  ErrorSeverity,
  LogCaptureService,
  LogRecordType,
  ModuleType,
  ProtocolType
} from 'feature_debug_core';

/**
 * Unified NearLink log pipeline per architecture 04-§8 and nearlink sub-docs.
 */
export class NearLinkEventLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();

  static async logLifecycle(
    sessionId: string,
    protocol: ProtocolType,
    summary: string,
    nativeCode: string = ''
  ): Promise<void> {
    await NearLinkEventLogger.captureEvent(sessionId, protocol, LogRecordType.LIFECYCLE, summary, nativeCode);
  }

  static async logAdvDiscovery(
    sessionId: string,
    addressMasked: string,
    rawHex: string,
    summary: string
  ): Promise<void> {
    await NearLinkEventLogger.captureEvent(
      sessionId,
      ProtocolType.NEARLINK_SCAN,
      LogRecordType.LIFECYCLE,
      `deviceFound addr=${addressMasked} ${summary} rawLen=${rawHex.length / 2}`
    );
    if (rawHex.length >= 2) {
      const normalized = rawHex.replace(/\s/g, '');
      const bytes = new Uint8Array(normalized.length / 2);
      for (let i = 0; i < bytes.length; i++) {
        bytes[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
      }
      await NearLinkEventLogger.logCapture.captureBytes(
        sessionId,
        ModuleType.NEARLINK,
        ProtocolType.NEARLINK_SCAN,
        Direction.INBOUND,
        bytes
      );
    }
  }

  static async logSsapState(sessionId: string, summary: string, nativeCode: string = ''): Promise<void> {
    await NearLinkEventLogger.captureEvent(sessionId, ProtocolType.SSAP, LogRecordType.LIFECYCLE, summary, nativeCode);
  }

  static async logSsapPayload(
    sessionId: string,
    direction: Direction,
    serviceUuid: string,
    propertyUuid: string,
    bytes: Uint8Array
  ): Promise<void> {
    await NearLinkEventLogger.logCapture.captureBytes(
      sessionId,
      ModuleType.NEARLINK,
      ProtocolType.SSAP,
      direction,
      bytes,
      '',
      `${serviceUuid}:${propertyUuid}`
    );
  }

  static async logSsapMtu(sessionId: string, mtu: number): Promise<void> {
    await NearLinkEventLogger.captureEvent(
      sessionId,
      ProtocolType.SSAP,
      LogRecordType.LIFECYCLE,
      `MTU negotiated=${mtu}`
    );
  }

  static async logDataTransferState(sessionId: string, summary: string, nativeCode: string = ''): Promise<void> {
    await NearLinkEventLogger.captureEvent(
      sessionId,
      ProtocolType.DATA_TRANSFER,
      LogRecordType.LIFECYCLE,
      summary,
      nativeCode
    );
  }

  static async logDataTransferPayload(
    sessionId: string,
    direction: Direction,
    uuid: string,
    bytes: Uint8Array,
    appCode: string = ''
  ): Promise<void> {
    await NearLinkEventLogger.logCapture.captureBytes(
      sessionId,
      ModuleType.NEARLINK,
      ProtocolType.DATA_TRANSFER,
      direction,
      bytes,
      appCode,
      uuid
    );
  }

  static async logSecurity(sessionId: string, summary: string, appCode: string = ''): Promise<void> {
    await NearLinkEventLogger.captureEvent(
      sessionId,
      ProtocolType.DATA_TRANSFER,
      LogRecordType.LIFECYCLE,
      summary,
      '',
      appCode
    );
  }

  private static async captureEvent(
    sessionId: string,
    protocol: ProtocolType,
    recordType: LogRecordType,
    summary: string,
    nativeCode: string = '',
    appCode: string = ''
  ): Promise<void> {
    const event = new DebugEvent(
      IdGenerator.next('evt'),
      sessionId,
      ModuleType.NEARLINK,
      recordType,
      'internal',
      TimeUtil.nowMs(),
      ErrorSeverity.INFO,
      summary,
      undefined,
      appCode,
      nativeCode,
      {}
    );
    await NearLinkEventLogger.logCapture.captureEvent(event);
  }
}
