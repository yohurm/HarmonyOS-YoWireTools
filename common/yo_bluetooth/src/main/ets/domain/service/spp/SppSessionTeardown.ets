import { Result } from 'common_core';
import {
  StopSessionUseCase,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { asSppTransportFacet } from '../../model/spp/ISppTransportFacet';
import { SppSessionKey } from '../../model/SppSessionKey';
import { CommandWriteQueue } from '../queue/CommandWriteQueue';
import { SppSessionLedger } from './SppSessionLedger';

/**
 * Shared SPP session teardown (architecture bluetooth/02 §5.1 / H1).
 * Callers must stop reconnect scheduling (Coordinator.unbind) before invoke when bound.
 * Does not import concrete SppTransportSession or Coordinator (avoids cycles).
 */
export class SppSessionTeardown {
  /**
   * Full fail cleanup: queue reset → FAILED → TSR.remove(destroy/close)
   * → ledger.release → stopSession → republish.
   * Safe when registry entry already gone (connect-fail / double call).
   */
  static async failCleanup(sessionId: string, reason: string): Promise<Result<void>> {
    if (sessionId.length === 0) {
      return Result.ok(undefined);
    }
    new CommandWriteQueue(sessionId).reset();

    const ledger = SppSessionLedger.getInstance();
    let sessionKey: SppSessionKey | undefined = ledger.findBySessionId(sessionId)?.sessionKey;

    const registry = TransportSessionRegistry.getInstance();
    const transport = registry.get(sessionId);
    if (transport !== undefined) {
      const facet = asSppTransportFacet(transport);
      if (facet !== undefined) {
        facet.cancelReconnect();
        facet.notifyFailed(reason);
        const key = facet.getSessionKey();
        if (key !== undefined) {
          sessionKey = key;
        }
      }
      // remove → destroy → close RFCOMM + defensive ledger.release
      registry.remove(sessionId);
    }

    if (sessionKey !== undefined) {
      ledger.release(sessionKey, reason);
    }
    const stopped = await new StopSessionUseCase().execute(sessionId, `spp_failed:${reason}`);
    BluetoothRepository.getInstance().republishClassicDevices();
    return stopped;
  }

  /**
   * User disconnect body (architecture bluetooth/02 §5.1):
   * queue.reset → disconnect → TSR.remove → markClosing → release → stopSession → republish.
   * Caller should Coordinator.unbind first to cancel in-flight reconnect.
   */
  static async userDisconnectCleanup(sessionId: string): Promise<Result<void>> {
    new CommandWriteQueue(sessionId).reset();

    const ledger = SppSessionLedger.getInstance();
    let sessionKey: SppSessionKey | undefined = ledger.findBySessionId(sessionId)?.sessionKey;

    const registry = TransportSessionRegistry.getInstance();
    const transport = registry.get(sessionId);
    if (transport !== undefined) {
      const facet = asSppTransportFacet(transport);
      if (facet !== undefined) {
        facet.cancelReconnect();
        const key = facet.getSessionKey();
        if (key !== undefined) {
          sessionKey = key;
        }
      }
      await transport.disconnect('user_disconnect');
      registry.remove(sessionId);
    }

    if (sessionKey !== undefined) {
      ledger.markClosing(sessionKey);
      ledger.release(sessionKey, 'user_disconnect');
    }
    const stopped = await new StopSessionUseCase().execute(sessionId, 'spp_disconnected');
    BluetoothRepository.getInstance().republishClassicDevices();
    return stopped;
  }
}