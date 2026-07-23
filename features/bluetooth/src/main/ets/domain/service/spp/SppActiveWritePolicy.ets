import { Result, ResultError } from 'common_core';
import { ProtocolType, TransportSessionRegistry, TransportState } from 'feature_debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';

/**
 * SPP single-active-writer policy (architecture bluetooth/05).
 * At most one Ready SPP transport may accept writes.
 */
export class SppActiveWritePolicy {
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()) {
    this.transportRegistry = transportRegistry;
  }

  /**
   * Returns existing active SPP session id if another writer is already connected.
   */
  findOtherActiveSession(excludingSessionId: string = ''): string {
    const ids = this.transportRegistry.listSessionIds();
    for (let i = 0; i < ids.length; i++) {
      const sessionId = ids[i];
      if (excludingSessionId.length > 0 && sessionId === excludingSessionId) {
        continue;
      }
      const transport = this.transportRegistry.get(sessionId);
      if (transport === undefined) {
        continue;
      }
      if (transport.protocol !== ProtocolType.SPP) {
        continue;
      }
      if (transport.state === TransportState.CONNECTED || transport.state === TransportState.CONNECTING) {
        return sessionId;
      }
    }
    return '';
  }

  ensureCanOpenNewWriter(): Result<void> {
    const other = this.findOtherActiveSession();
    if (other.length > 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.OPERATION_BUSY,
        `SPP single-active writer: session ${other} already active`
      ));
    }
    return Result.ok(undefined);
  }
}
