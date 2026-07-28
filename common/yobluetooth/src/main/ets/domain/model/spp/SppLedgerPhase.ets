/**
 * SPP session ledger lifecycle (architecture bluetooth/02 v1.2).
 * One compositeKey (classicDeviceId + serviceUuid) maps to at most one ledger entry.
 */
export enum SppLedgerPhase {
  RESERVED = 'reserved',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  RECONNECTING = 'reconnecting',
  CLOSING = 'closing'
}
