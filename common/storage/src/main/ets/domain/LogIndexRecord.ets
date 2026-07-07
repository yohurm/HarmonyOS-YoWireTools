import { StoragePayloadRef } from './StoragePayloadRef';

/**
 * Log index record mapped to debug_log_index table.
 */
export class LogIndexRecord {
  readonly id: string;
  readonly sessionId: string;
  readonly module: string;
  readonly protocol: string;
  readonly direction: string;
  readonly recordType: string;
  readonly timestampMs: number;
  readonly payloadRef: StoragePayloadRef | undefined;
  readonly payloadSize: number;
  readonly summary: string;
  readonly displayHint: string;
  readonly appCode: string;
  readonly nativeCode: string;
  readonly attributesJson: string;

  constructor(
    id: string,
    sessionId: string,
    module: string,
    protocol: string,
    direction: string,
    recordType: string,
    timestampMs: number,
    payloadSize: number,
    summary: string,
    displayHint: string,
    payloadRef?: StoragePayloadRef,
    appCode: string = '',
    nativeCode: string = '',
    attributesJson: string = '{}'
  ) {
    this.id = id;
    this.sessionId = sessionId;
    this.module = module;
    this.protocol = protocol;
    this.direction = direction;
    this.recordType = recordType;
    this.timestampMs = timestampMs;
    this.payloadSize = payloadSize;
    this.summary = summary;
    this.displayHint = displayHint;
    this.payloadRef = payloadRef;
    this.appCode = appCode;
    this.nativeCode = nativeCode;
    this.attributesJson = attributesJson;
  }
}
