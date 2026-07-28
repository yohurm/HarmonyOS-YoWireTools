import { Observable } from 'common_core';
import { ModuleType, ProtocolType, TransportState } from '../domain/enums/DomainEnums';

/**
 * Transport capability descriptor per architecture §4.2.
 */
export class TransportCapabilities {
  readonly isByteStream: boolean;
  readonly isMessageBased: boolean;
  readonly maxWriteBytes: number;
  readonly supportsNotify: boolean;
  readonly supportsMtu: boolean;
  readonly supportsSecure: boolean;
  readonly supportsServerMode: boolean;
  readonly supportsReconnect: boolean;
  readonly supportsBackground: boolean;

  constructor(
    isByteStream: boolean = true,
    isMessageBased: boolean = false,
    maxWriteBytes: number = 0,
    supportsNotify: boolean = false,
    supportsMtu: boolean = false,
    supportsSecure: boolean = false,
    supportsServerMode: boolean = false,
    supportsReconnect: boolean = false,
    supportsBackground: boolean = false
  ) {
    this.isByteStream = isByteStream;
    this.isMessageBased = isMessageBased;
    this.maxWriteBytes = maxWriteBytes;
    this.supportsNotify = supportsNotify;
    this.supportsMtu = supportsMtu;
    this.supportsSecure = supportsSecure;
    this.supportsServerMode = supportsServerMode;
    this.supportsReconnect = supportsReconnect;
    this.supportsBackground = supportsBackground;
  }
}

export class IncomingPayload {
  readonly bytes: Uint8Array;
  readonly timestampMs: number;
  readonly isCompleteMessage: boolean;

  constructor(bytes: Uint8Array, timestampMs: number, isCompleteMessage: boolean = false) {
    this.bytes = bytes;
    this.timestampMs = timestampMs;
    this.isCompleteMessage = isCompleteMessage;
  }
}

export class TransportStateSnapshot {
  readonly state: TransportState;
  readonly reason: string;
  readonly timestampMs: number;

  constructor(state: TransportState, reason: string = '', timestampMs: number = Date.now()) {
    this.state = state;
    this.reason = reason;
    this.timestampMs = timestampMs;
  }
}

export class WriteOptions {
  readonly appendLineEnding: boolean;
  readonly chunkSize: number;
  readonly timeoutMs: number;

  constructor(appendLineEnding: boolean = false, chunkSize: number = 0, timeoutMs: number = 5000) {
    this.appendLineEnding = appendLineEnding;
    this.chunkSize = chunkSize;
    this.timeoutMs = timeoutMs;
  }
}

export class WriteResult {
  readonly success: boolean;
  readonly bytesWritten: number;
  readonly appCode: string;
  readonly message: string;
  readonly nativeCode: string;

  constructor(
    success: boolean,
    bytesWritten: number,
    appCode: string = '',
    message: string = '',
    nativeCode: string = ''
  ) {
    this.success = success;
    this.bytesWritten = bytesWritten;
    this.appCode = appCode;
    this.message = message;
    this.nativeCode = nativeCode;
  }
}

/**
 * Protocol-agnostic transport contract per architecture §4.1.
 */
export interface ITransportSession {
  readonly id: string;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly state: TransportState;
  readonly capabilities: TransportCapabilities;

  connect(params: Record<string, string | number | boolean>): Promise<void>;
  disconnect(reason: string): Promise<void>;
  write(payload: Uint8Array, options?: WriteOptions): Promise<WriteResult>;
  observeIncoming(): Observable<IncomingPayload>;
  observeState(): Observable<TransportStateSnapshot>;
  destroy(): void;
}
