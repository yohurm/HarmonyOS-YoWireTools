import { IdGenerator, Observable, Result, ResultError, TimeUtil } from 'common_core';
import {
  ModuleType,
  ProtocolType,
  TransportState
} from 'debug_core';
import {
  ITransportSession,
  IncomingPayload,
  TransportCapabilities,
  TransportStateSnapshot,
  WriteOptions,
  WriteResult
} from 'debug_core';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { GattClientDataSource } from '../datasource/platform/GattClientDataSource';
import { BleSerialEndpoints } from '../../domain/model/BleSerialPreset';
import { BleSerialPlatformMapper } from '../mapper/BleSerialPlatformMapper';
import { GattConnectParams } from '../../domain/model/GattConnectParams';
import { GattOperationQueue } from '../../domain/service/GattOperationQueue';

/**
 * BLE GATT serial transport per architecture bluetooth/03 and WSL bpta-bluetooth-low-energy.
 */
export class GattTransportSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType = ModuleType.BLUETOOTH;
  readonly protocol: ProtocolType = ProtocolType.BLE_GATT;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;
  private readonly dataSource: GattClientDataSource;
  private readonly operationQueue: GattOperationQueue = new GattOperationQueue();
  private endpoints: BleSerialEndpoints | undefined;
  private connectParams: GattConnectParams | undefined;
  private userDisconnect: boolean = false;

  constructor(
    sessionId: string,
    dataSource: GattClientDataSource = new GattClientDataSource()
  ) {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('gatt');
    this.dataSource = dataSource;
    const maxWrite = BluetoothConstants.BLE_DEFAULT_MTU - BluetoothConstants.BLE_GATT_OVERHEAD_BYTES;
    this.capabilities = new TransportCapabilities(
      true,
      false,
      maxWrite,
      true,
      true,
      false,
      false,
      false,
      false
    );
    this.incomingObservable = new Observable<IncomingPayload>(
      new IncomingPayload(new Uint8Array(0), 0)
    );
    this.stateObservable = new Observable<TransportStateSnapshot>(
      new TransportStateSnapshot(TransportState.IDLE)
    );
  }

  get state(): TransportState {
    return this.currentState;
  }

  async connect(params: Record<string, string | number | boolean>): Promise<void> {
    const bleDeviceId = `${params['bleDeviceId'] ?? ''}`;
    if (bleDeviceId.length === 0) {
      throw new Error('bleDeviceId required for GATT');
    }
    const displayName = `${params['displayName'] ?? bleDeviceId}`;
    const usePreset = params['useNordicPreset'] !== false;
    const autoDetect = params['autoDetect'] === true;
    const serviceUuid = `${params['serviceUuid'] ?? BluetoothConstants.NORDIC_UART_SERVICE_UUID}`;
    const rxUuid = `${params['rxCharacteristicUuid'] ?? BluetoothConstants.NORDIC_UART_RX_UUID}`;
    const txUuid = `${params['txCharacteristicUuid'] ?? BluetoothConstants.NORDIC_UART_TX_UUID}`;
    this.connectParams = new GattConnectParams(
      bleDeviceId,
      displayName,
      serviceUuid,
      rxUuid,
      txUuid,
      usePreset,
      autoDetect
    );
    this.userDisconnect = false;
    this.transition(TransportState.CONNECTING);
    const created = this.dataSource.createClient(bleDeviceId);
    if (!created.success) {
      this.transition(TransportState.FAILED, created.error?.message ?? 'create client failed');
      throw new Error(created.error?.message ?? 'GATT create failed');
    }
    const connected = await this.dataSource.waitForConnected(BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS);
    if (!connected.success) {
      this.transition(TransportState.FAILED, connected.error?.message ?? 'connect failed');
      throw new Error(connected.error?.message ?? 'GATT connect failed');
    }
    this.transition(TransportState.CONNECTING, 'discovering_services');
    const services = await this.dataSource.discoverServices();
    if (!services.success || services.value === undefined) {
      this.transition(TransportState.FAILED, services.error?.message ?? 'discover failed');
      throw new Error(services.error?.message ?? 'GATT discover failed');
    }
    let endpoints = usePreset
      ? BleSerialPlatformMapper.resolveNordicUart(services.value)
      : BleSerialPlatformMapper.resolveByUuids(services.value, serviceUuid, rxUuid, txUuid);
    if (endpoints === undefined && autoDetect) {
      endpoints = BleSerialPlatformMapper.autoDetectSerial(services.value);
    }
    if (endpoints === undefined && !usePreset) {
      endpoints = BleSerialPlatformMapper.autoDetectSerial(services.value);
    }
    if (endpoints === undefined) {
      this.transition(TransportState.FAILED, 'serial endpoints not found');
      throw new Error('BLE serial characteristics not found');
    }
    const serialEndpoints = endpoints;
    this.endpoints = serialEndpoints;
    const notifyRegistered = this.dataSource.onCharacteristicChange((characteristic) => {
      if (characteristic.characteristicValue === undefined) {
        return;
      }
      const bytes = new Uint8Array(characteristic.characteristicValue);
      if (bytes.length > 0) {
        this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), false));
      }
    });
    if (!notifyRegistered.success) {
      this.transition(TransportState.FAILED, notifyRegistered.error?.message ?? 'GATT notify subscribe failed');
      throw new Error(notifyRegistered.error?.message ?? 'GATT notify subscribe failed');
    }
    const txCharacteristic = this.dataSource.findCharacteristic(
      serialEndpoints.serviceUuid,
      serialEndpoints.txCharacteristicUuid
    );
    if (txCharacteristic === undefined) {
      this.transition(TransportState.FAILED, 'TX characteristic not found');
      throw new Error('BLE TX characteristic not found');
    }
    const notify = await this.operationQueue.enqueue(() =>
      this.dataSource.enableNotification(txCharacteristic)
    );
    if (!notify.success) {
      this.transition(TransportState.FAILED, notify.error?.message ?? 'notify failed');
      throw new Error(notify.error?.message ?? 'GATT notify failed');
    }
    this.transition(TransportState.CONNECTED);
  }

  async disconnect(reason: string): Promise<void> {
    this.userDisconnect = true;
    this.transition(TransportState.DISCONNECTING, reason);
    if (this.endpoints !== undefined) {
      const txCharacteristic = this.dataSource.findCharacteristic(
        this.endpoints.serviceUuid,
        this.endpoints.txCharacteristicUuid
      );
      if (txCharacteristic !== undefined) {
        await this.operationQueue.enqueue(() =>
          this.dataSource.disableNotification(txCharacteristic)
        );
      }
    }
    this.dataSource.offCharacteristicChange();
    this.dataSource.release();
    this.endpoints = undefined;
    this.operationQueue.reset();
    this.transition(TransportState.DISCONNECTED, reason);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.currentState !== TransportState.CONNECTED || this.endpoints === undefined) {
      return new WriteResult(false, 0, BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected');
    }
    const written = await this.operationQueue.enqueue(async (): Promise<Result<void>> => {
      const rxCharacteristic = this.dataSource.findCharacteristic(
        this.endpoints!.serviceUuid,
        this.endpoints!.rxCharacteristicUuid
      );
      if (rxCharacteristic === undefined) {
        return Result.fail<void>(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'RX characteristic not found'));
      }
      return this.dataSource.writeCharacteristic(rxCharacteristic, payload);
    });
    if (!written.success) {
      return new WriteResult(
        false,
        0,
        written.error?.code ?? BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED,
        written.error?.message ?? 'write failed',
        written.error?.nativeCode ?? ''
      );
    }
    return new WriteResult(true, payload.length);
  }

  observeIncoming(): Observable<IncomingPayload> {
    return this.incomingObservable;
  }

  observeState(): Observable<TransportStateSnapshot> {
    return this.stateObservable;
  }

  destroy(): void {
    this.userDisconnect = true;
    this.dataSource.release();
    this.endpoints = undefined;
    this.operationQueue.reset();
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }
}
