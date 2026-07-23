import { describe, it, expect } from '@ohos/hypium';
import {
  SessionState,
  SessionType,
  ModuleType,
  ProtocolType,
  AppMode,
  Direction
} from '../main/ets/domain/enums/DomainEnums';
import { CreateSessionInput, DebugSession } from '../main/ets/domain/model/DebugSession';
import { SessionStateMachine } from '../main/ets/runtime/SessionStateMachine';
import { SessionRuntimeStore } from '../main/ets/runtime/SessionRuntimeStore';
import { PayloadNormalizer } from '../main/ets/service/PayloadNormalizer';
import { FakeTransportSession } from '../main/ets/transport/FakeTransportSession';
import { TransportWriteQueueRegistry } from '../main/ets/service/TransportWriteQueueRegistry';
import { EncodingUtil } from 'common_core';

export default function localUnitTest() {
  describe('FeatureDebugCoreLocalUnitTest', () => {
    it('SessionStateMachine_valid_transitions', 0, () => {
      expect(SessionStateMachine.canTransition(SessionState.CREATED, SessionState.PREPARING)).assertTrue();
      expect(SessionStateMachine.canTransition(SessionState.PREPARING, SessionState.RUNNING)).assertTrue();
      expect(SessionStateMachine.canTransition(SessionState.RUNNING, SessionState.STOPPING)).assertTrue();
      expect(SessionStateMachine.canTransition(SessionState.COMPLETED, SessionState.RUNNING)).assertFalse();
    });

    it('SessionStateMachine_terminal_states', 0, () => {
      expect(SessionStateMachine.isTerminal(SessionState.COMPLETED)).assertTrue();
      expect(SessionStateMachine.isTerminal(SessionState.RUNNING)).assertFalse();
    });

    it('SessionRuntimeStore_register_and_observe', 0, () => {
      const store = SessionRuntimeStore.getInstance();
      store.clear();
      const input = new CreateSessionInput(
        SessionType.CONNECTION,
        ModuleType.BLUETOOTH,
        ProtocolType.SPP,
        'Test Session',
        AppMode.EXPERT
      );
      const session = new DebugSession(
        'sess_test_1',
        input.type,
        input.module,
        input.protocol,
        input.displayName,
        input.mode,
        SessionState.CREATED,
        Date.now()
      );
      store.register(session);
      expect(store.getSession('sess_test_1')?.displayName).assertEqual('Test Session');
      const summaries = store.listActiveSummaries();
      expect(summaries.length).assertEqual(1);
      store.clear();
    });

    it('PayloadNormalizer_text_payload', 0, () => {
      const bytes = EncodingUtil.stringToUtf8Bytes('Hello');
      const normalized = PayloadNormalizer.normalize(bytes, Direction.INBOUND, ModuleType.BLUETOOTH, ProtocolType.SPP);
      expect(normalized.summary.indexOf('Hello') >= 0).assertTrue();
    });

    it('FakeTransportSession_write_when_connected', 0, async () => {
      const transport = new FakeTransportSession('t1', ModuleType.BLUETOOTH, ProtocolType.SPP);
      await transport.connect({});
      const bytes = EncodingUtil.stringToUtf8Bytes('ping');
      const result = await transport.write(bytes);
      expect(result.success).assertTrue();
      expect(result.bytesWritten).assertEqual(4);
      transport.destroy();
    });

    it('TransportWriteQueueRegistry_serializes', 0, async () => {
      const registry = TransportWriteQueueRegistry.getInstance();
      registry.clear();
      const queue = registry.getQueue('transport-1');
      const order: number[] = [];
      await queue.enqueue(async () => {
        order.push(1);
      });
      await queue.enqueue(async () => {
        order.push(2);
      });
      expect(order[0]).assertEqual(1);
      expect(order[1]).assertEqual(2);
    });
  });
}
