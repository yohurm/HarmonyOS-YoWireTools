import { Result, ResultError } from 'common_core';
import {
  DebugLogRecord,
  LineEndingMode,
  PayloadEncoding,
  SendCommandInput,
  SendCommandUseCase,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { CommandWriteQueue } from '../../service/queue/CommandWriteQueue';

/**
 * SPP terminal send 鈥?debug_core encoding + TX depth gate (architecture bluetooth/05).
 */
export class SendSppCommandUseCase {
  private readonly sendCommand: SendCommandUseCase;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.sendCommand = sendCommand;
    this.transportRegistry = transportRegistry;
  }

  async execute(
    sessionId: string,
    payloadText: string,
    encoding: PayloadEncoding = PayloadEncoding.TEXT,
    lineEnding: LineEndingMode = LineEndingMode.LF
  ): Promise<Result<DebugLogRecord>> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'SPP transport missing'));
    }
    const queue = new CommandWriteQueue(transport.id);
    if (queue.pendingCount >= BluetoothConstants.COMMAND_WRITE_QUEUE_MAX_DEPTH) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.WRITE_QUEUE_FULL,
        `TX queue full (max ${BluetoothConstants.COMMAND_WRITE_QUEUE_MAX_DEPTH})`
      ));
    }
    return this.sendCommand.execute(new SendCommandInput(
      sessionId,
      transport,
      payloadText,
      encoding,
      lineEnding
    ));
  }
}
