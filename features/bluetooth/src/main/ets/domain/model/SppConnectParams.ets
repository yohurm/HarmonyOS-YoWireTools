import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { ReconnectPolicy } from './ReconnectPolicy';

export class SppConnectParams {
  readonly deviceId: string;
  readonly displayName: string;
  readonly uuid: string;
  readonly secure: boolean;
  readonly timeoutMs: number;
  readonly autoReconnect: boolean;
  readonly reconnectPolicy: ReconnectPolicy;

  constructor(
    deviceId: string,
    displayName: string,
    uuid: string = BluetoothConstants.DEFAULT_SPP_UUID,
    secure: boolean = false,
    timeoutMs: number = BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS,
    autoReconnect: boolean = false,
    reconnectPolicy: ReconnectPolicy = ReconnectPolicy.defaultPolicy()
  ) {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.uuid = uuid;
    this.secure = secure;
    this.timeoutMs = timeoutMs;
    this.autoReconnect = autoReconnect;
    this.reconnectPolicy = reconnectPolicy;
  }

  toConnectRecord(): Record<string, string | number | boolean> {
    const record: Record<string, string | number | boolean> = {};
    record['deviceId'] = this.deviceId;
    record['displayName'] = this.displayName;
    record['uuid'] = this.uuid;
    record['secure'] = this.secure;
    record['timeoutMs'] = this.timeoutMs;
    record['autoReconnect'] = this.autoReconnect;
    record['maxReconnectAttempts'] = this.reconnectPolicy.maxAttempts;
    record['reconnectInitialDelayMs'] = this.reconnectPolicy.initialDelayMs;
    record['reconnectMaxDelayMs'] = this.reconnectPolicy.maxDelayMs;
    record['reconnectBackoffFactor'] = this.reconnectPolicy.backoffFactor;
    return record;
  }
}

export class ConnectSppResult {
  readonly sessionId: string;
  readonly transportId: string;

  constructor(sessionId: string, transportId: string) {
    this.sessionId = sessionId;
    this.transportId = transportId;
  }
}
