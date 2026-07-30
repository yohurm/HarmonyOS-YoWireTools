import { ModuleType, ProtocolType, SessionState } from 'debug_core';
import {
  ClassicConnectedSnapshot,
  ClassicKeepAliveSnapshot
} from '../model/ClassicConnectedSnapshot';
import { SppLedgerPhase } from '../model/spp/SppLedgerPhase';
import { ActiveSppSessionRef, ConnectedSppLedgerRef } from './ClassicScanVisibilityPolicy';

/**
 * Merges platform Profile-connected + app SPP connected/connecting into scan keep-alive.
 * Never includes silent paired-only addresses.
 */
export class ClassicScanKeepAliveCollector {
  static isKeepAliveLedgerPhase(phase: SppLedgerPhase): boolean {
    return phase === SppLedgerPhase.CONNECTED ||
      phase === SppLedgerPhase.RESERVED ||
      phase === SppLedgerPhase.CONNECTING ||
      phase === SppLedgerPhase.RECONNECTING;
  }

  static isConnectedLedgerPhase(phase: SppLedgerPhase): boolean {
    return phase === SppLedgerPhase.CONNECTED;
  }

  static isConnectingLedgerPhase(phase: SppLedgerPhase): boolean {
    return phase === SppLedgerPhase.RESERVED ||
      phase === SppLedgerPhase.CONNECTING ||
      phase === SppLedgerPhase.RECONNECTING;
  }

  /** Session states that mean RFCOMM already up (or briefly wrapping up). */
  static isConnectedSessionState(state: SessionState): boolean {
    return state === SessionState.RUNNING ||
      state === SessionState.SUSPENDED ||
      state === SessionState.STOPPING;
  }

  /** Session states while SPP connect is in flight. */
  static isConnectingSessionState(state: SessionState): boolean {
    return state === SessionState.CREATED ||
      state === SessionState.PREPARING;
  }

  static collect(
    includeConnected: boolean,
    platform: ClassicConnectedSnapshot,
    ledgerRefs: ConnectedSppLedgerRef[],
    summaries: ActiveSppSessionRef[],
    resolveAddress: (sessionId: string) => string
  ): ClassicKeepAliveSnapshot {
    if (!includeConnected) {
      return ClassicKeepAliveSnapshot.empty();
    }

    const addresses = new Set<string>();
    let sppConnectedCount = 0;
    let sppConnectingCount = 0;

    for (let i = 0; i < platform.addresses.length; i++) {
      const id = platform.addresses[i];
      if (id.length > 0) {
        addresses.add(id);
      }
    }

    for (let i = 0; i < ledgerRefs.length; i++) {
      const ref = ledgerRefs[i];
      if (!ClassicScanKeepAliveCollector.isKeepAliveLedgerPhase(ref.phase)) {
        continue;
      }
      if (ref.classicDeviceId.length === 0) {
        continue;
      }
      addresses.add(ref.classicDeviceId);
      if (ClassicScanKeepAliveCollector.isConnectedLedgerPhase(ref.phase)) {
        sppConnectedCount++;
      } else if (ClassicScanKeepAliveCollector.isConnectingLedgerPhase(ref.phase)) {
        sppConnectingCount++;
      }
    }

    for (let i = 0; i < summaries.length; i++) {
      const summary = summaries[i];
      if (summary.module !== ModuleType.BLUETOOTH || summary.protocol !== ProtocolType.SPP) {
        continue;
      }
      const connected = ClassicScanKeepAliveCollector.isConnectedSessionState(summary.state);
      const connecting = ClassicScanKeepAliveCollector.isConnectingSessionState(summary.state);
      if (!connected && !connecting) {
        continue;
      }
      const address = resolveAddress(summary.id);
      if (address.length === 0) {
        continue;
      }
      addresses.add(address);
      if (connected) {
        sppConnectedCount++;
      } else {
        sppConnectingCount++;
      }
    }

    return new ClassicKeepAliveSnapshot(
      addresses,
      platform.profileConnectedCount,
      sppConnectedCount,
      sppConnectingCount
    );
  }
}
