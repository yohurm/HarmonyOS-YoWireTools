import { EncodingUtil, TimeUtil } from 'common_core';
import {
  Direction,
  DisplayHint,
  LogRecordType,
  ModuleType,
  ProtocolType
} from '../domain/enums/DomainEnums';
import { DebugLogRecord } from '../domain/model/DebugLogRecord';

export class NormalizedPayload {
  readonly summary: string;
  readonly displayHint: DisplayHint;
  readonly recordType: LogRecordType;

  constructor(summary: string, displayHint: DisplayHint, recordType: LogRecordType) {
    this.summary = summary;
    this.displayHint = displayHint;
    this.recordType = recordType;
  }
}

/**
 * Normalizes transport payloads without business interpretation per §5.4.
 */
export class PayloadNormalizer {
  static normalize(
    bytes: Uint8Array,
    direction: Direction,
    module: ModuleType,
    protocol: ProtocolType
  ): NormalizedPayload {
    const size = bytes.length;
    const textResult = EncodingUtil.utf8BytesToString(bytes);
    const isPrintable = PayloadNormalizer.isMostlyPrintable(textResult);
    let summary = `${direction} ${module}/${protocol} ${size} bytes`;
    let displayHint = DisplayHint.HEX;
    let recordType = LogRecordType.BYTES;
    if (size === 0) {
      summary = `${direction} empty payload`;
      displayHint = DisplayHint.NONE;
    } else if (isPrintable) {
      const preview = textResult.length > 64 ? `${textResult.substring(0, 64)}...` : textResult;
      summary = `${direction} text: ${preview}`;
      displayHint = DisplayHint.MIXED;
      recordType = LogRecordType.TEXT;
    }
    return new NormalizedPayload(summary, displayHint, recordType);
  }

  private static isMostlyPrintable(text: string): boolean {
    if (text.length === 0) {
      return false;
    }
    let printable = 0;
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i);
      if (code >= 32 && code <= 126) {
        printable++;
      }
    }
    return printable / text.length >= 0.8;
  }
}
