import { Result, Subscription, TimeUtil } from 'common_core';
import { UiPageState } from 'common_ui';
import { BluetoothRepository } from '../data/repository/BluetoothRepository';
import {
  ConnectGattUseCase,
  DisconnectGattUseCase
} from '../domain/usecase/BluetoothUseCases';
import {
  ConnectGattBrowserUseCase,
  DiscoverGattServicesUseCase,
  ReadGattCharacteristicUseCase,
  ReadGattDescriptorUseCase,
  RequestBleMtuUseCase,
  SetGattNotificationUseCase,
  WriteGattCharacteristicUseCase,
  WriteGattDescriptorUseCase
} from '../domain/usecase/BluetoothExtendedUseCases';
import { ConnectGattResult, GattConnectParams } from '../domain/model/GattConnectParams';
import { GattCharacteristicChangeEvent } from '../domain/model/GattCharacteristicRef';
import { GattServiceTreeSnapshot, GattClientState } from '../domain/model/GattServiceTree';
import { BluetoothConstants } from '../constants/BluetoothConstants';
import { BleGattReconnectCoordinator } from '../domain/service/BleGattReconnectCoordinator';
import { IdentityStability } from '../domain/model/DeviceIdentity';
import { BluetoothIdentityDataSource } from '../data/datasource/platform/BluetoothIdentityDataSource';
import { GattWritePayloadCodec, WritePayloadEncoding } from '../domain/service/GattWritePayloadCodec';
import { RssiSample } from '../domain/model/RssiSample';

@ObservedV2
export class GattDetailViewModel {
  @Trace pageState: UiPageState = UiPageState.CONTENT;
  @Trace deviceId: string = '';
  @Trace displayName: string = '';
  @Trace sessionId: string = '';
  @Trace gattState: GattClientState = GattClientState.IDLE;
  @Trace serviceTree: GattServiceTreeSnapshot | undefined;
  @Trace mtu: number = BluetoothConstants.BLE_DEFAULT_MTU;
  @Trace writeHex: string = '';
  @Trace readResultHex: string = '';
  @Trace notifyLog: string[] = [];
  @Trace notifySamples: RssiSample[] = [];
  @Trace statusMessage: string = '';
  @Trace useSerialPreset: boolean = true;
  @Trace customServiceUuid: string = BluetoothConstants.NORDIC_UART_SERVICE_UUID;
  @Trace customRxUuid: string = BluetoothConstants.NORDIC_UART_RX_UUID;
  @Trace customTxUuid: string = BluetoothConstants.NORDIC_UART_TX_UUID;
  @Trace autoDetectSerial: boolean = false;
  @Trace descriptorReadHex: string = '';

  @Trace writeDialogVisible: boolean = false;
  @Trace pendingServiceUuid: string = '';
  @Trace pendingCharacteristicUuid: string = '';

  private treeSub: Subscription | undefined;
  private identityStability: IdentityStability = IdentityStability.UNKNOWN;
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private readonly connectGatt: ConnectGattUseCase = new ConnectGattUseCase();
  private readonly connectBrowser: ConnectGattBrowserUseCase = new ConnectGattBrowserUseCase();
  private readonly disconnectGatt: DisconnectGattUseCase = new DisconnectGattUseCase();
  private readonly discoverServices: DiscoverGattServicesUseCase = new DiscoverGattServicesUseCase();
  private readonly readChar: ReadGattCharacteristicUseCase = new ReadGattCharacteristicUseCase();
  private readonly writeChar: WriteGattCharacteristicUseCase = new WriteGattCharacteristicUseCase();
  private readonly readDesc: ReadGattDescriptorUseCase = new ReadGattDescriptorUseCase();
  private readonly writeDesc: WriteGattDescriptorUseCase = new WriteGattDescriptorUseCase();
  private readonly setNotify: SetGattNotificationUseCase = new SetGattNotificationUseCase();
  private readonly requestMtu: RequestBleMtuUseCase = new RequestBleMtuUseCase();

  bindTarget(deviceId: string, displayName: string): void {
    this.deviceId = deviceId;
    this.displayName = displayName;
    const identity = BluetoothIdentityDataSource.getInstance().buildIdentity(deviceId, false);
    this.identityStability = identity.identityStability;
  }

  initializeObservers(): void {
    this.treeSub = this.repository.observeGattTree().subscribe((tree: GattServiceTreeSnapshot) => {
      this.serviceTree = tree;
      this.gattState = tree.state;
      this.mtu = tree.mtu;
    });
  }

  dispose(): void {
    this.treeSub?.dispose();
    BleGattReconnectCoordinator.getInstance().unbind();
  }

  async connectSerial(): Promise<void> {
    await this.connectWithParams(new GattConnectParams(this.deviceId, this.displayName));
  }

  async connectCustomSerial(): Promise<void> {
    this.useSerialPreset = false;
    await this.connectWithParams(new GattConnectParams(
      this.deviceId,
      this.displayName,
      this.customServiceUuid,
      this.customRxUuid,
      this.customTxUuid,
      false
    ));
  }

  async connectAutoDetectSerial(): Promise<void> {
    this.autoDetectSerial = true;
    this.useSerialPreset = false;
    await this.connectWithParams(new GattConnectParams(
      this.deviceId,
      this.displayName,
      '',
      '',
      '',
      false,
      true
    ));
  }

  private async connectWithParams(params: GattConnectParams): Promise<void> {
    const result: Result<ConnectGattResult> = await this.connectGatt.execute(params);
    if (!result.success || result.value === undefined) {
      this.statusMessage = result.error?.message ?? 'GATT connect failed';
      return;
    }
    this.sessionId = result.value.sessionId;
    this.gattState = GattClientState.READY;
    this.statusMessage = 'GATT connected';
    this.bindReconnectCoordinator();
  }

  async connectBrowserAction(): Promise<void> {
    this.useSerialPreset = false;
    const result: Result<ConnectGattResult> = await this.connectBrowser.execute(this.deviceId, this.displayName);
    if (!result.success || result.value === undefined) {
      this.statusMessage = result.error?.message ?? 'GATT browser connect failed';
      return;
    }
    this.sessionId = result.value.sessionId;
    this.gattState = GattClientState.READY;
    this.statusMessage = 'GATT browser connected';
    this.bindBrowserNotifyObserver();
    this.bindReconnectCoordinator();
    await this.discoverServices.execute(this.sessionId, this.deviceId, this.mtu);
  }

  private bindReconnectCoordinator(): void {
    if (!BleGattReconnectCoordinator.canFastReconnect(this.identityStability)) {
      return;
    }
    BleGattReconnectCoordinator.getInstance().bind(
      this.deviceId,
      this.identityStability,
      async () => {
        if (this.useSerialPreset) {
          await this.connectSerial();
        } else if (this.autoDetectSerial) {
          await this.connectAutoDetectSerial();
        } else {
          await this.connectCustomSerial();
        }
        if (this.sessionId.length > 0) {
          await this.discoverServices.execute(this.sessionId, this.deviceId, this.mtu);
        }
      }
    );
  }

  private bindBrowserNotifyObserver(): void {
    const subscribed = this.repository.subscribeGattCharacteristicChanges(
      this.sessionId,
      (event: GattCharacteristicChangeEvent) => {
        this.appendNotifyLine(`${event.serviceUuid}/${event.characteristicUuid}: ${event.valueHex}`);
        this.appendNotifySample(GattDetailViewModel.hexByteLength(event.valueHex));
      }
    );
    if (!subscribed.success) {
      this.statusMessage = subscribed.error?.message ?? 'Notify subscribe failed';
    }
  }

  async disconnect(): Promise<void> {
    BleGattReconnectCoordinator.getInstance().markUserDisconnect();
    if (this.sessionId.length === 0) {
      return;
    }
    await this.disconnectGatt.execute(this.sessionId);
    this.repository.releaseGattClient(this.sessionId);
    this.sessionId = '';
    this.serviceTree = undefined;
    this.statusMessage = 'GATT disconnected';
  }

  async requestMtuAction(requested: number): Promise<void> {
    if (this.sessionId.length === 0) {
      return;
    }
    const result: Result<number> = await this.requestMtu.execute(this.sessionId, requested);
    this.statusMessage = result.success ? `MTU ${result.value}` : (result.error?.message ?? 'MTU failed');
  }

  async readByUuid(serviceUuid: string, characteristicUuid: string): Promise<void> {
    await this.readOrWriteByUuid(serviceUuid, characteristicUuid, false);
  }

  async writeByUuid(serviceUuid: string, characteristicUuid: string): Promise<void> {
    this.openWriteDialog(serviceUuid, characteristicUuid);
  }

  async notifyByUuid(
    serviceUuid: string,
    characteristicUuid: string,
    enable: boolean,
    indicate: boolean = false
  ): Promise<void> {
    if (this.sessionId.length === 0) {
      return;
    }
    const result = await this.setNotify.execute(
      this.sessionId,
      serviceUuid,
      characteristicUuid,
      enable,
      indicate
    );
    this.statusMessage = result.success
      ? (enable ? 'Subscribed' : 'Unsubscribed')
      : (result.error?.message ?? 'Notify failed');
  }

  openWriteDialog(serviceUuid: string, characteristicUuid: string): void {
    this.pendingServiceUuid = serviceUuid;
    this.pendingCharacteristicUuid = characteristicUuid;
    this.writeDialogVisible = true;
  }

  dismissWriteDialog(): void {
    this.writeDialogVisible = false;
  }

  async confirmWrite(payload: string, encoding: WritePayloadEncoding): Promise<void> {
    const decoded = GattWritePayloadCodec.toBytes(payload, encoding);
    if (!decoded.success || decoded.value === undefined) {
      this.statusMessage = decoded.error?.message ?? 'Invalid payload';
      return;
    }
    this.writeHex = GattDetailViewModel.toHex(decoded.value);
    await this.readOrWriteByUuid(this.pendingServiceUuid, this.pendingCharacteristicUuid, true, decoded.value);
  }

  async readDescriptorByUuid(
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string
  ): Promise<void> {
    if (this.sessionId.length === 0) {
      return;
    }
    const result = await this.readDesc.execute(
      this.sessionId,
      serviceUuid,
      characteristicUuid,
      descriptorUuid
    );
    if (result.success && result.value !== undefined) {
      this.descriptorReadHex = result.value;
    } else {
      this.statusMessage = result.error?.message ?? 'Descriptor read failed';
    }
  }

  async writeDescriptorByUuid(
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string,
    payload: string,
    encoding: WritePayloadEncoding
  ): Promise<void> {
    const decoded = GattWritePayloadCodec.toBytes(payload, encoding);
    if (!decoded.success || decoded.value === undefined) {
      this.statusMessage = decoded.error?.message ?? 'Invalid payload';
      return;
    }
    if (this.sessionId.length === 0) {
      return;
    }
    const result = await this.writeDesc.execute(
      this.sessionId,
      serviceUuid,
      characteristicUuid,
      descriptorUuid,
      decoded.value
    );
    this.statusMessage = result.success ? 'Descriptor write OK' : (result.error?.message ?? 'Descriptor write failed');
  }

  private async readOrWriteByUuid(
    serviceUuid: string,
    characteristicUuid: string,
    write: boolean,
    bytes?: Uint8Array
  ): Promise<void> {
    if (this.sessionId.length === 0) {
      return;
    }
    if (write) {
      const payload = bytes ?? GattDetailViewModel.fromHex(this.writeHex);
      const result = await this.writeChar.execute(this.sessionId, serviceUuid, characteristicUuid, payload);
      this.statusMessage = result.success ? 'Write OK' : (result.error?.message ?? 'Write failed');
    } else {
      const result = await this.readChar.execute(this.sessionId, serviceUuid, characteristicUuid);
      if (result.success && result.value !== undefined) {
        this.readResultHex = result.value;
      } else {
        this.statusMessage = result.error?.message ?? 'Read failed';
      }
    }
  }

  appendNotifyLine(line: string): void {
    const next = [...this.notifyLog, line];
    this.notifyLog = next.length > 50 ? next.slice(next.length - 50) : next;
  }

  private appendNotifySample(byteLength: number): void {
    const sample = new RssiSample(TimeUtil.nowMs(), Math.min(100, byteLength));
    const next = [...this.notifySamples, sample];
    this.notifySamples = next.length > 30 ? next.slice(next.length - 30) : next;
  }

  private static hexByteLength(hex: string): number {
    const normalized = hex.replace(/\s/g, '');
    return Math.floor(normalized.length / 2);
  }

  private static toHex(bytes: Uint8Array): string {
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join(' ');
  }

  private static fromHex(hex: string): Uint8Array {
    const normalized = hex.replace(/\s/g, '');
    const length = Math.floor(normalized.length / 2);
    const bytes = new Uint8Array(length);
    for (let i = 0; i < length; i++) {
      bytes[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
    }
    return bytes;
  }
}
