import { EncodingUtil, Result, ResultError } from 'common_core';
import { Direction, LineEndingMode, PayloadEncoding } from '../domain/enums/DomainEnums';
import { PayloadTextCodec } from '../command/PayloadTextCodec';
import { DebugLogRecord } from '../domain/model/DebugLogRecord';
import { LogCaptureService } from '../service/LogCaptureService';
import { TransportWriteQueueRegistry } from '../service/TransportWriteQueueRegistry';
import { ITransportSession, WriteOptions } from '../transport/TransportContracts';

export class SendCommandInput {
  readonly sessionId: string;
  readonly transport: ITransportSession;
  readonly payloadText: string;
  readonly encoding: PayloadEncoding;
  readonly lineEnding: LineEndingMode;

  constructor(
    sessionId: string,
    transport: ITransportSession,
    payloadText: string,
    encoding: PayloadEncoding = PayloadEncoding.TEXT,
    lineEnding: LineEndingMode = LineEndingMode.LF
  ) {
    this.sessionId = sessionId;
    this.transport = transport;
    this.payloadText = payloadText;
    this.encoding = encoding;
    this.lineEnding = lineEnding;
  }
}

/**
 * Send command flow per architecture §6.2.
 */
export class SendCommandUseCase {
  private readonly logCapture: LogCaptureService;
  private readonly queueRegistry: TransportWriteQueueRegistry;

  constructor(
    logCapture: LogCaptureService = LogCaptureService.getInstance(),
    queueRegistry: TransportWriteQueueRegistry = TransportWriteQueueRegistry.getInstance()
  ) {
    this.logCapture = logCapture;
    this.queueRegistry = queueRegistry;
  }

  async execute(input: SendCommandInput): Promise<Result<DebugLogRecord>> {
    const bytesResult = SendCommandUseCase.toWriteBytes(input.payloadText, input.encoding, input.lineEnding);
    if (!bytesResult.success) {
      return Result.fail(bytesResult.error ?? new ResultError('YW-CMD-1001', 'Command encoding failed'));
    }
    const bytes = bytesResult.getOrThrow();
    const queue = this.queueRegistry.getQueue(input.transport.id);
    const writeResult = await queue.enqueue(async () => {
      return input.transport.write(bytes, new WriteOptions(false));
    });
    if (!writeResult.success) {
      const appCode = writeResult.appCode.length > 0 ? writeResult.appCode : 'YW-CMD-1002';
      await this.logCapture.captureBytes(
        input.sessionId,
        input.transport.module,
        input.transport.protocol,
        Direction.OUTBOUND,
        bytes,
        appCode,
        writeResult.nativeCode
      );
      return Result.fail(new ResultError(appCode, writeResult.message, undefined, {}, writeResult.nativeCode));
    }
    return this.logCapture.captureBytes(
      input.sessionId,
      input.transport.module,
      input.transport.protocol,
      Direction.OUTBOUND,
      bytes
    );
  }

  /**
   * TEXT：按 Latin-1/ASCII 单字节落盘（产测 AT^ 命令必须是 ASCII，勿走 UTF-8 多字节）。
   * HEX：按字面量解析（如 "0A FF" → bytes）。
   * BASE64：经 PayloadTextCodec 再 UTF-8。
   */
  static toWriteBytes(
    payloadText: string,
    encoding: PayloadEncoding,
    lineEnding: LineEndingMode
  ): Result<Uint8Array> {
    let bytes: Uint8Array;
    if (encoding === PayloadEncoding.HEX) {
      const normalized = payloadText.replace(/\s+/g, '');
      if (normalized.length === 0) {
        return Result.fail(new ResultError('YW-CMD-1001', 'Empty hex payload'));
      }
      if (normalized.length % 2 !== 0) {
        return Result.fail(new ResultError('YW-CMD-1001', 'Invalid hex payload'));
      }
      for (let i = 0; i < normalized.length; i++) {
        const c = normalized.charCodeAt(i);
        const isHex = (c >= 0x30 && c <= 0x39) || (c >= 0x41 && c <= 0x46) || (c >= 0x61 && c <= 0x66);
        if (!isHex) {
          return Result.fail(new ResultError('YW-CMD-1001', 'Invalid hex payload'));
        }
      }
      bytes = EncodingUtil.hexToBytes(normalized);
    } else if (encoding === PayloadEncoding.TEXT) {
      bytes = SendCommandUseCase.textToAsciiBytes(payloadText);
    } else {
      const encoded = PayloadTextCodec.encodeText(payloadText, encoding);
      if (!encoded.success) {
        return Result.fail(encoded.error ?? new ResultError('YW-CMD-1001', 'Command encoding failed'));
      }
      bytes = EncodingUtil.stringToUtf8Bytes(encoded.getOrThrow());
    }
    if (lineEnding === LineEndingMode.NONE) {
      return Result.ok(bytes);
    }
    const ending = SendCommandUseCase.textToAsciiBytes(PayloadTextCodec.toLineSequence(lineEnding));
    const merged = new Uint8Array(bytes.length + ending.length);
    merged.set(bytes, 0);
    merged.set(ending, bytes.length);
    return Result.ok(merged);
  }

  /** AT/产测文本 → 单字节 ASCII/Latin-1（与 GATT TEXT 写一致）。 */
  static textToAsciiBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i) & 0xFF;
    }
    return bytes;
  }
}

export class AppendLogUseCase {
  private readonly logCapture: LogCaptureService;

  constructor(logCapture: LogCaptureService = LogCaptureService.getInstance()) {
    this.logCapture = logCapture;
  }

  async execute(
    sessionId: string,
    module: import('../domain/enums/DomainEnums').ModuleType,
    protocol: import('../domain/enums/DomainEnums').ProtocolType,
    direction: Direction,
    bytes: Uint8Array
  ): Promise<Result<DebugLogRecord>> {
    return this.logCapture.captureBytes(sessionId, module, protocol, direction, bytes);
  }
}
