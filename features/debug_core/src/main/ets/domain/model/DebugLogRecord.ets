import { PayloadRef } from './PayloadRef';
import {
  Direction,
  DisplayHint,
  LogRecordType,
  ModuleType,
  ProtocolType
} from '../enums/DomainEnums';

/**
 * Domain log record per 05-§3.3.
 */
export class DebugLogRecord {
  readonly id: string;
  readonly sessionId: string;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly direction: Direction;
  readonly recordType: LogRecordType;
  readonly timestampMs: number;
  readonly monotonicMs: number;
  readonly summary: string;
  readonly payloadRef: PayloadRef | undefined;
  readonly payloadSize: number;
  readonly displayHint: DisplayHint;
  readonly appCode: string;
  readonly nativeCode: string;
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    id: string,
    sessionId: string,
    module: ModuleType,
    protocol: ProtocolType,
    direction: Direction,
    recordType: LogRecordType,
    timestampMs: number,
    payloadSize: number,
    summary: string,
    displayHint: DisplayHint,
    payloadRef?: PayloadRef,
    monotonicMs: number = 0,
    appCode: string = '',
    nativeCode: string = '',
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.id = id;
    this.sessionId = sessionId;
    this.module = module;
    this.protocol = protocol;
    this.direction = direction;
    this.recordType = recordType;
    this.timestampMs = timestampMs;
    this.monotonicMs = monotonicMs;
    this.summary = summary;
    this.payloadRef = payloadRef;
    this.payloadSize = payloadSize;
    this.displayHint = displayHint;
    this.appCode = appCode;
    this.nativeCode = nativeCode;
    this.attributes = attributes;
  }
}
