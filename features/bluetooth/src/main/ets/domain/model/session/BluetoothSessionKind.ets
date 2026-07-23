/**
 * Bluetooth session kinds — independent state machines (architecture bluetooth/05).
 */
export enum BluetoothSessionKind {
  CLASSIC_SCAN = 'classic_scan',
  BLE_SCAN = 'ble_scan',
  SPP = 'spp',
  BLE_GATT = 'ble_gatt',
  BLE_UART = 'ble_uart'
}

/**
 * Connection-class session lifecycle (scan kinds use ScanPhase instead).
 */
export enum SessionLifecycle {
  PREPARING = 'preparing',
  CONNECTING = 'connecting',
  READY = 'ready',
  WRITING = 'writing',
  DISCONNECTING = 'disconnecting',
  RECONNECTING = 'reconnecting',
  FAILED = 'failed',
  CLOSED = 'closed'
}

/**
 * Cross-path session summary for UI / SessionRuntimeStore observation.
 */
export class BluetoothSessionSummary {
  readonly sessionId: string;
  readonly kind: BluetoothSessionKind;
  readonly lifecycle: SessionLifecycle;
  readonly displayName: string;
  readonly classicDeviceId: string;
  readonly bleDeviceId: string;
  readonly bytesIn: number;
  readonly bytesOut: number;
  readonly startedAtMs: number;

  constructor(
    sessionId: string,
    kind: BluetoothSessionKind,
    lifecycle: SessionLifecycle,
    displayName: string,
    classicDeviceId: string = '',
    bleDeviceId: string = '',
    bytesIn: number = 0,
    bytesOut: number = 0,
    startedAtMs: number = Date.now()
  ) {
    this.sessionId = sessionId;
    this.kind = kind;
    this.lifecycle = lifecycle;
    this.displayName = displayName;
    this.classicDeviceId = classicDeviceId;
    this.bleDeviceId = bleDeviceId;
    this.bytesIn = bytesIn;
    this.bytesOut = bytesOut;
    this.startedAtMs = startedAtMs;
  }
}
