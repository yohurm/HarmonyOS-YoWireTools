import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { ReconnectPolicy } from './ReconnectPolicy';
import { BluetoothTransportType } from './BluetoothTransportType';
import { SppSessionKey } from './SppSessionKey';
import { SppSocketKind } from './SppSocketKind';

/**
 * SPP connect params — classicDeviceId only (architecture bluetooth/00 + 02).
 */
export class SppConnectParams {
  readonly classicDeviceId: string;
  readonly displayName: string;
  readonly uuid: string;
  readonly secure: boolean;
  readonly timeoutMs: number;
  readonly autoReconnect: boolean;
  readonly reconnectPolicy: ReconnectPolicy;
  readonly transport: BluetoothTransportType;
  readonly bleDeviceId: string;
  readonly socketKind: SppSocketKind;
  readonly psm: number;

  constructor(
    classicDeviceId: string,
    displayName: string,
    uuid: string = BluetoothConstants.DEFAULT_SPP_UUID,
    secure: boolean = false,
    timeoutMs: number = BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS,
    autoReconnect: boolean = false,
    reconnectPolicy: ReconnectPolicy = ReconnectPolicy.defaultPolicy(),
    transport: BluetoothTransportType = BluetoothTransportType.BR_EDR,
    bleDeviceId: string = '',
    socketKind: SppSocketKind = SppSocketKind.RFCOMM,
    psm: number = 0
  ) {
    this.classicDeviceId = SppSessionKey.normalizeClassicId(classicDeviceId);
    this.displayName = displayName;
    this.uuid = SppSessionKey.normalizeUuid(uuid);
    this.secure = secure;
    this.timeoutMs = timeoutMs;
    this.autoReconnect = autoReconnect;
    this.reconnectPolicy = reconnectPolicy;
    this.transport = transport;
    this.bleDeviceId = bleDeviceId.trim();
    this.socketKind = socketKind;
    this.psm = psm;
  }

  toConnectRecord(): Record<string, string | number | boolean> {
    const record: Record<string, string | number | boolean> = {};
    record['classicDeviceId'] = this.classicDeviceId;
    record['bleDeviceId'] = this.bleDeviceId;
    record['socketKind'] = this.socketKind;
    record['psm'] = this.psm;
    record['transport'] = this.transport;
    record['displayName'] = this.displayName;
    record['uuid'] = this.uuid;
    record['secure'] = this.secure;
    record['timeoutMs'] = this.timeoutMs;
    record['autoReconnect'] = this.autoReconnect;
    record['maxReconnectAttempts'] = this.reconnectPolicy.maxAttempts;
    record['reconnectInitialDelayMs'] = this.reconnectPolicy.initialDelayMs;
    record['reconnectMaxDelayMs'] = this.reconnectPolicy.maxDelayMs;
    record['reconnectBackoffFactor'] = this.reconnectPolicy.backoffFactor;
    record['stopOnPairLost'] = this.reconnectPolicy.stopOnPairLost;
    record['stopOnPermissionLost'] = this.reconnectPolicy.stopOnPermissionLost;
    return record;
  }
}

export class ConnectSppResult {
  readonly sessionId: string;
  readonly transportId: string;
  readonly sessionKey: SppSessionKey;

  constructor(sessionId: string, transportId: string, sessionKey: SppSessionKey) {
    this.sessionId = sessionId;
    this.transportId = transportId;
    this.sessionKey = sessionKey;
  }
}
