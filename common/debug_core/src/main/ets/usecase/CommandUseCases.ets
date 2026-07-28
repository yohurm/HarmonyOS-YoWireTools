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
    const encoded = PayloadTextCodec.encodeText(input.payloadText, input.encoding);
    if (!encoded.success) {
      return Result.fail(new ResultError('YW-CMD-1001', 'Command encoding failed'));
    }
    let bytes = EncodingUtil.stringToUtf8Bytes(encoded.getOrThrow());
    if (input.lineEnding !== LineEndingMode.LF && input.lineEnding !== LineEndingMode.NONE) {
      const withEnding = PayloadTextCodec.appendLineEnding(encoded.getOrThrow(), input.lineEnding);
      bytes = EncodingUtil.stringToUtf8Bytes(withEnding);
    }
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
