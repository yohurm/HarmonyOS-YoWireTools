import { ProtocolType } from 'feature_debug_core';
import { NearLinkEventLogger } from './NearLinkEventLogger';

export class NearLinkScanLogger {
  static async logScan(sessionId: string, summary: string, nativeCode: string = ''): Promise<void> {
    await NearLinkEventLogger.logLifecycle(sessionId, ProtocolType.NEARLINK_SCAN, summary, nativeCode);
  }
}
