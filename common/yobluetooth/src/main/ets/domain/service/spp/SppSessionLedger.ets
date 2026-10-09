import { Result, ResultError, TimeUtil } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { SppLedgerPhase } from '../../model/spp/SppLedgerPhase';
import { SppSessionKey } from '../../model/SppSessionKey';

/**
 * One reserved / active SPP RFCOMM slot (architecture bluetooth/02 §4.2).
 */
export class SppLedgerEntry {
  readonly sessionKey: SppSessionKey;
  sessionId: string;
  phase: SppLedgerPhase;
  readonly reservedAtMs: number;
  clientSocket: number;

  constructor(
    sessionKey: SppSessionKey,
    sessionId: string,
    phase: SppLedgerPhase = SppLedgerPhase.RESERVED,
    reservedAtMs: number = TimeUtil.nowMs(),
    clientSocket: number = -1
  ) {
    this.sessionKey = sessionKey;
    this.sessionId = sessionId;
    this.phase = phase;
    this.reservedAtMs = reservedAtMs;
    this.clientSocket = clientSocket;
  }
}

/**
 * Single source of truth for SPP multi-session slots.
 * Identity key = (classicDeviceId, serviceUuid); cap = SPP_MAX_SESSIONS.
 */
export class SppSessionLedger {
  private static instance: SppSessionLedger | undefined;
  private readonly entries: Map<string, SppLedgerEntry> = new Map();

  static getInstance(): SppSessionLedger {
    if (SppSessionLedger.instance === undefined) {
      SppSessionLedger.instance = new SppSessionLedger();
    }
    return SppSessionLedger.instance;
  }

  tryReserve(key: SppSessionKey, sessionId: string): Result<void> {
    if (!key.isValid()) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_INVALID_PARAMS,
        'classicDeviceId and serviceUuid required'
      ));
    }
    const composite = key.compositeKey();
    if (this.entries.has(composite)) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_DUPLICATE_SESSION,
        `SPP session already active for ${composite}`
      ));
    }
    if (this.entries.size >= BluetoothConstants.SPP_MAX_SESSIONS) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_SESSION_LIMIT,
        `SPP session limit ${BluetoothConstants.SPP_MAX_SESSIONS}`
      ));
    }
    this.entries.set(composite, new SppLedgerEntry(key, sessionId, SppLedgerPhase.RESERVED));
    return Result.ok(undefined);
  }

  markConnecting(key: SppSessionKey): void {
    const entry = this.entries.get(key.compositeKey());
    if (entry === undefined) {
      return;
    }
    entry.phase = SppLedgerPhase.CONNECTING;
  }

  /**
   * Classic addresses with ledger phase CONNECTED（已连接的已配对，非仅配对）.
   */
  listConnectedClassicAddresses(): string[] {
    const addresses: string[] = [];
    const seen = new Set<string>();
    const values = Array.from(this.entries.values());
    for (let i = 0; i < values.length; i++) {
      const entry = values[i];
      if (entry.phase !== SppLedgerPhase.CONNECTED) {
        continue;
      }
      const id = entry.sessionKey.classicDeviceId;
      if (id.length === 0 || seen.has(id)) {
        continue;
      }
      seen.add(id);
      addresses.push(id);
    }
    return addresses;
  }

  /** First ledger phase for a classicDeviceId, or undefined. */
  findPhaseByClassicId(classicDeviceId: string): SppLedgerPhase | undefined {
    const normalized = SppSessionKey.normalizeClassicId(classicDeviceId);
    if (normalized.length === 0) {
      return undefined;
    }
    const values = Array.from(this.entries.values());
    for (let i = 0; i < values.length; i++) {
      if (values[i].sessionKey.classicDeviceId === normalized) {
        return values[i].phase;
      }
    }
    return undefined;
  }

  /**
   * After RuntimeStore creates the real session id, rebind the reserved ledger row.
   */
  bindSessionId(key: SppSessionKey, sessionId: string): void {
    const entry = this.entries.get(key.compositeKey());
    if (entry === undefined || sessionId.length === 0) {
      return;
    }
    entry.sessionId = sessionId;
  }

  promoteConnected(key: SppSessionKey, clientSocket: number): void {
    const entry = this.entries.get(key.compositeKey());
    if (entry === undefined) {
      return;
    }
    entry.phase = SppLedgerPhase.CONNECTED;
    entry.clientSocket = clientSocket;
  }

  markReconnecting(key: SppSessionKey): void {
    const entry = this.entries.get(key.compositeKey());
    if (entry === undefined) {
      return;
    }
    entry.phase = SppLedgerPhase.RECONNECTING;
    entry.clientSocket = -1;
  }

  markClosing(key: SppSessionKey): void {
    const entry = this.entries.get(key.compositeKey());
    if (entry === undefined) {
      return;
    }
    entry.phase = SppLedgerPhase.CLOSING;
    entry.clientSocket = -1;
  }

  /**
   * Unique slot exit. Idempotent — safe after FAILED / pair-lost / disconnect paths.
   */
  release(key: SppSessionKey, _reason: string = ''): void {
    this.entries.delete(key.compositeKey());
  }

  hasKey(key: SppSessionKey): boolean {
    return this.entries.has(key.compositeKey());
  }

  getActiveCount(): number {
    return this.entries.size;
  }

  findBySessionId(sessionId: string): SppLedgerEntry | undefined {
    if (sessionId.length === 0) {
      return undefined;
    }
    const values = Array.from(this.entries.values());
    for (let i = 0; i < values.length; i++) {
      if (values[i].sessionId === sessionId) {
        return values[i];
      }
    }
    return undefined;
  }

  listActive(): SppLedgerEntry[] {
    return Array.from(this.entries.values());
  }

  closeAll(): void {
    this.entries.clear();
  }

  /** Test-only reset. */
  resetForTests(): void {
    this.closeAll();
  }
}
