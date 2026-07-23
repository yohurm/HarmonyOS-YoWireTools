import { Subscription } from 'common_core';
import { Direction } from '../domain/enums/DomainEnums';
import { SessionStatePatch } from '../runtime/DebugSessionState';
import { SessionRuntimeStore } from '../runtime/SessionRuntimeStore';
import { IncomingPayload, ITransportSession, TransportStateSnapshot } from '../transport/TransportContracts';
import { LogCaptureService } from './LogCaptureService';

/**
 * Bridges transport callbacks into log capture and runtime store per §5.4.
 */
export class TransportLogBinder {
  bind(sessionId: string, transport: ITransportSession): () => void {
    const logCapture = LogCaptureService.getInstance();
    const runtimeStore = SessionRuntimeStore.getInstance();
    const subscriptions: Subscription[] = [];
    subscriptions.push(transport.observeIncoming().subscribe((payload: IncomingPayload) => {
      void logCapture.captureBytes(
        sessionId,
        transport.module,
        transport.protocol,
        Direction.INBOUND,
        payload.bytes
      );
    }, false));
    subscriptions.push(transport.observeState().subscribe((snapshot: TransportStateSnapshot) => {
      runtimeStore.applyPatch(sessionId, new SessionStatePatch(
        undefined,
        snapshot.state,
        undefined,
        snapshot.reason
      ));
    }, false));
    return () => {
      for (let i = 0; i < subscriptions.length; i++) {
        subscriptions[i].dispose();
      }
    };
  }
}
