import { IdGenerator, Subscription, TimeUtil } from 'common_core';
import { Direction, ErrorSeverity, LogRecordType } from '../domain/enums/DomainEnums';
import { DebugEvent } from '../domain/model/DebugEvent';
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
    let lastState: string = `${transport.state}`;
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
      const nextState = `${snapshot.state}`;
      if (nextState !== lastState) {
        const summary = snapshot.reason.length > 0 ?
          `transport:${lastState}->${nextState}, reason=${snapshot.reason}` :
          `transport:${lastState}->${nextState}`;
        const attrs: Record<string, string | number | boolean> = {};
        attrs['from'] = lastState;
        attrs['to'] = nextState;
        attrs['reason'] = snapshot.reason;
        const event = new DebugEvent(
          IdGenerator.next('evt'),
          sessionId,
          transport.module,
          LogRecordType.STATE,
          'internal',
          TimeUtil.nowMs(),
          ErrorSeverity.INFO,
          summary,
          undefined,
          '',
          '',
          attrs
        );
        lastState = nextState;
        void logCapture.captureEvent(event);
      }
    }, false));
    return () => {
      for (let i = 0; i < subscriptions.length; i++) {
        subscriptions[i].dispose();
      }
    };
  }
}
