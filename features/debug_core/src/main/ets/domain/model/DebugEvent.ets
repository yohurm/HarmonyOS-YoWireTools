import { ErrorSeverity, LogRecordType, ModuleType } from '../enums/DomainEnums';
import { PayloadRef } from './PayloadRef';

/**
 * Protocol-agnostic event envelope per 00-§8.3.
 */
export class DebugEvent {
  readonly id: string;
  readonly sessionId: string;
  readonly moduleType: ModuleType;
  readonly eventType: LogRecordType;
  readonly direction: string;
  readonly timestampMs: number;
  readonly severity: ErrorSeverity;
  readonly summary: string;
  readonly payloadRef: PayloadRef | undefined;
  readonly nativeCode: string;
  readonly appCode: string;
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    id: string,
    sessionId: string,
    moduleType: ModuleType,
    eventType: LogRecordType,
    direction: string,
    timestampMs: number,
    severity: ErrorSeverity,
    summary: string,
    payloadRef?: PayloadRef,
    nativeCode: string = '',
    appCode: string = '',
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.id = id;
    this.sessionId = sessionId;
    this.moduleType = moduleType;
    this.eventType = eventType;
    this.direction = direction;
    this.timestampMs = timestampMs;
    this.severity = severity;
    this.summary = summary;
    this.payloadRef = payloadRef;
    this.nativeCode = nativeCode;
    this.appCode = appCode;
    this.attributes = attributes;
  }
}
