import {
  ModuleType,
  ProtocolType,
  SessionRuntimeStore,
  SessionState,
  TransportSessionRegistry
} from 'debug_core';
import { SppSessionDescriptor } from '../../model/SppSessionDescriptor';
import { SppSessionKey } from '../../model/SppSessionKey';
import { asSppTransportFacet } from '../../model/spp/ISppTransportFacet';
import { SppSessionLedger } from './SppSessionLedger';
import { SppUuidLabel } from './SppUuidLabel';

/**
 * Builds SPP session read-models from RuntimeStore ∩ Ledger (+ optional Transport facet).
 * Never surfaces active rows without a Ledger key (architecture bluetooth/02 Observe).
 */
export class SppSessionCatalog {
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly runtimeStore: SessionRuntimeStore;
  private readonly ledger: SppSessionLedger;

  constructor(
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance(),
    ledger: SppSessionLedger = SppSessionLedger.getInstance()
  ) {
    this.transportRegistry = transportRegistry;
    this.runtimeStore = runtimeStore;
    this.ledger = ledger;
  }

  listActiveDescriptors(): SppSessionDescriptor[] {
    const summaries = this.runtimeStore.listActiveSummaries();
    const descriptors: SppSessionDescriptor[] = [];
    for (let i = 0; i < summaries.length; i++) {
      const summary = summaries[i];
      if (summary.module !== ModuleType.BLUETOOTH || summary.protocol !== ProtocolType.SPP) {
        continue;
      }
      if (!SppSessionCatalog.isActiveSummaryState(summary.state)) {
        continue;
      }
      const session = this.runtimeStore.getSession(summary.id);
      const runtimeState = this.runtimeStore.getState(summary.id);
      const transport = this.transportRegistry.get(summary.id);
      const facet = asSppTransportFacet(transport);
      const classicAddress = session?.target?.address ?? '';
      const serviceUuid = session?.target?.uuid ?? '';
      let sessionKey = SppSessionKey.fromParts(classicAddress, serviceUuid);
      let clientSocket = -1;
      let transportState = `${summary.state}`;
      let transportId = transport?.id ?? summary.id;

      if (facet !== undefined) {
        clientSocket = facet.getClientSocketId();
        if (transport !== undefined) {
          transportState = `${transport.state}`;
          transportId = transport.id;
        }
        const transportKey = facet.getSessionKey();
        if (transportKey !== undefined) {
          sessionKey = transportKey;
        }
      } else if (transport !== undefined) {
        transportState = `${transport.state}`;
      }

      // Ledger is admission truth — drop Runtime ghosts without a reserved/active key.
      if (!SppSessionCatalog.shouldSurfaceSession(sessionKey, this.ledger)) {
        continue;
      }

      descriptors.push(new SppSessionDescriptor(
        summary.id,
        transportId,
        sessionKey,
        summary.displayName,
        sessionKey.classicDeviceId,
        sessionKey.serviceUuid,
        SppUuidLabel.formatShort(sessionKey.serviceUuid),
        transportState,
        clientSocket,
        runtimeState?.bytesIn ?? 0,
        runtimeState?.bytesOut ?? 0
      ));
    }
    return descriptors;
  }

  findDescriptor(sessionId: string): SppSessionDescriptor | undefined {
    const all = this.listActiveDescriptors();
    for (let i = 0; i < all.length; i++) {
      if (all[i].sessionId === sessionId) {
        return all[i];
      }
    }
    return undefined;
  }

  /** Pure gate used by listActiveDescriptors — unit-testable without RuntimeStore. */
  static shouldSurfaceSession(sessionKey: SppSessionKey, ledger: SppSessionLedger): boolean {
    return sessionKey.isValid() && ledger.hasKey(sessionKey);
  }

  private static isActiveSummaryState(state: SessionState): boolean {
    return state === SessionState.CREATED ||
      state === SessionState.PREPARING ||
      state === SessionState.RUNNING ||
      state === SessionState.SUSPENDED ||
      state === SessionState.STOPPING;
  }
}
