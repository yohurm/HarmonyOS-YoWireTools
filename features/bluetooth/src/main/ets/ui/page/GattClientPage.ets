import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import {
  BluetoothConstants,
  BluetoothErrorCodes,
  BluetoothRepository,
  ConnectGattUseCase,
  ConnectionParamPreset,
  DiscoverGattServicesUseCase,
  GattConnectParams,
  MtuBounds,
  ReadGattCharacteristicUseCase,
  ReadGattRssiUseCase,
  RequestBleMtuUseCase,
  SetGattNotificationUseCase,
  ThroughputSession,
  UpdateGattConnectionParamUseCase,
  WriteGattCharacteristicUseCase
} from 'yobluetooth';
import { BluetoothObjectNavParams } from '../../navigation/BluetoothObjectNavParams';

@ComponentV2
export struct GattClientPage {
  @Param params: BluetoothObjectNavParams = new BluetoothObjectNavParams();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: (sessionId: string) => void = (_sessionId: string) => {
  };
  @Local sessionId: string = '';
  @Local serviceUuid: string = '';
  @Local characteristicUuid: string = '';
  @Local payloadHex: string = '';
  @Local mtuText: string = '23';
  @Local mtuShown: number = BluetoothConstants.BLE_DEFAULT_MTU;
  @Local mtuPending: boolean = false;
  @Local rssiText: string = '';
  @Local statusText: string = '';
  @Local securityHint: string = '';
  @Local throughputBytes: number = 0;
  @Local throughputRunning: boolean = false;
  private readonly connectGatt: ConnectGattUseCase = new ConnectGattUseCase();
  private readonly disconnectGatt: DisconnectGattUseCase = new DisconnectGattUseCase();
  private readonly discover: DiscoverGattServicesUseCase = new DiscoverGattServicesUseCase();
  private readonly readChar: ReadGattCharacteristicUseCase = new ReadGattCharacteristicUseCase();
  private readonly writeChar: WriteGattCharacteristicUseCase = new WriteGattCharacteristicUseCase();
  private readonly notify: SetGattNotificationUseCase = new SetGattNotificationUseCase();
  private readonly requestMtu: RequestBleMtuUseCase = new RequestBleMtuUseCase();
  private readonly readRssi: ReadGattRssiUseCase = new ReadGattRssiUseCase();
  private readonly updateParam: UpdateGattConnectionParamUseCase = new UpdateGattConnectionParamUseCase();
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private throughput: ThroughputSession | undefined = undefined;

  aboutToDisappear(): void {
    if (this.throughput !== undefined) {
      this.throughput.stop();
    }
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_gatt_client_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.OBJECT,
      onBack: this.onBack,
      content: this.body
    })
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      Text(this.params.displayName)
        .fontSize(YoTypeStyle.BODY_M.size)
        .width('100%')
      Text($r('app.string.bt_address_virtual'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .width('100%')
      Text(this.mtuPending ? $r('app.string.bt_mtu_negotiating') : `${this.mtuShown}`)
        .fontSize(YoTypeStyle.BODY_M.size)
        .width('100%')
      TextInput({ text: this.mtuText, placeholder: $r('app.string.bt_mtu_request') })
        .onChange((value: string) => {
          this.mtuText = value;
        })
      Text($r('app.string.bt_phy_unverified'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_connection_param_presets_only'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.securityHint === '2901005') {
        Text($r('app.string.bt_gatt_security_encryption'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.securityHint === '2901006') {
        Text($r('app.string.bt_gatt_security_authentication'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.securityHint === '2901007') {
        Text($r('app.string.bt_gatt_security_authorization'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.statusText.length > 0) {
        Text(this.statusText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.rssiText.length > 0) {
        Text(this.rssiText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }
      TextInput({ text: this.serviceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.serviceUuid = value;
        })
      TextInput({ text: this.characteristicUuid, placeholder: $r('app.string.bt_gatt_characteristic') })
        .onChange((value: string) => {
          this.characteristicUuid = value;
        })
      TextInput({ text: this.payloadHex, placeholder: $r('app.string.bt_gatt_payload_hex') })
        .onChange((value: string) => {
          this.payloadHex = value;
        })
      YoActionButton({
        label: $r('app.string.bt_gatt_connect'),
        kind: YoActionButtonKind.PRIMARY,
        isEnabled: this.params.connectable,
        onTap: () => {
          void this.connect();
        }
      })
      if (!this.params.connectable) {
        Text($r('app.string.bt_ble_not_connectable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_conn_low_power')).onClick(() => {
          void this.applyPreset(ConnectionParamPreset.LOW_POWER);
        })
        Button($r('app.string.bt_conn_balanced')).onClick(() => {
          void this.applyPreset(ConnectionParamPreset.BALANCED);
        })
        Button($r('app.string.bt_conn_high')).onClick(() => {
          void this.applyPreset(ConnectionParamPreset.HIGH);
        })
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_gatt_read')).onClick(() => {
          void this.readValue();
        })
        Button($r('app.string.bt_gatt_write')).onClick(() => {
          void this.writeValue(false);
        })
        Button($r('app.string.bt_gatt_write_no_response')).onClick(() => {
          void this.writeValue(true);
        })
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_gatt_notify')).onClick(() => {
          void this.subscribe(false);
        })
        Button($r('app.string.bt_gatt_indicate')).onClick(() => {
          void this.subscribe(true);
        })
        Button($r('app.string.bt_gatt_rssi')).onClick(() => {
          void this.readLinkRssi();
        })
        Button($r('app.string.bt_mtu_apply')).onClick(() => {
          void this.applyMtu();
        })
      }
      Text(`${this.throughputBytes}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      YoActionButton({
        label: this.throughputRunning ? $r('app.string.bt_throughput_stop') : $r('app.string.bt_throughput_start'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          if (this.throughputRunning) {
            this.stopThroughput();
          } else {
            void this.startThroughput();
          }
        }
      })
      YoActionButton({
        label: $r('app.string.bt_entry_session_log'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          this.onOpenLog(this.sessionId);
        }
      })
    }
    .width('100%')
  }

  private async connect(): Promise<void> {
    if (!this.params.connectable) {
      this.statusText = 'not_connectable';
      return;
    }
    const connected = await this.connectGatt.execute(
      new GattConnectParams(this.params.deviceId, this.params.displayName)
    );
    if (!connected.success || connected.value === undefined) {
      this.noteError(connected.error?.code ?? '', connected.error?.message ?? '');
      return;
    }
    this.sessionId = connected.value.sessionId;
    this.mtuShown = this.repository.gattCurrentMtu(this.sessionId);
    const discovered = await this.discover.execute(this.sessionId, this.params.deviceId, this.mtuShown);
    if (!discovered.success) {
      this.noteError(discovered.error?.code ?? '', discovered.error?.message ?? '');
    }
  }

  private async applyMtu(): Promise<void> {
    const requested = Number(this.mtuText);
    const bounds = MtuBounds.accept(requested);
    if (!bounds.success) {
      this.statusText = bounds.error?.message ?? '';
      return;
    }
    this.mtuPending = true;
    const result = await this.requestMtu.execute(this.sessionId, requested);
    this.mtuPending = this.repository.gattMtuPending(this.sessionId);
    this.mtuShown = this.repository.gattCurrentMtu(this.sessionId);
    if (!result.success) {
      this.mtuPending = false;
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  private async applyPreset(preset: ConnectionParamPreset): Promise<void> {
    const result = await this.updateParam.execute(this.sessionId, preset);
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  private async readValue(): Promise<void> {
    const result = await this.readChar.execute(this.sessionId, this.serviceUuid, this.characteristicUuid);
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
      return;
    }
    this.statusText = result.value ?? '';
  }

  private async writeValue(noResponse: boolean): Promise<void> {
    const bytes = GattClientPage.hexToBytes(this.payloadHex);
    if (bytes === undefined) {
      this.statusText = 'invalid_hex';
      return;
    }
    const result = await this.writeChar.execute(
      this.sessionId,
      this.serviceUuid,
      this.characteristicUuid,
      bytes,
      noResponse
    );
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  private async subscribe(indication: boolean): Promise<void> {
    const result = await this.notify.execute(
      this.sessionId,
      this.serviceUuid,
      this.characteristicUuid,
      true,
      indication
    );
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  private async readLinkRssi(): Promise<void> {
    const result = await this.readRssi.execute(this.sessionId);
    if (!result.success || result.value === undefined) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
      return;
    }
    this.rssiText = `${result.value} dBm`;
  }

  private async startThroughput(): Promise<void> {
    const bytes = GattClientPage.hexToBytes(this.payloadHex.length > 0 ? this.payloadHex : '00');
    if (bytes === undefined) {
      return;
    }
    const session = new ThroughputSession();
    this.throughput = session;
    this.throughputRunning = true;
    const result = await session.run(
      this.sessionId,
      bytes,
      this.mtuShown,
      async (chunk: Uint8Array) => {
        return this.writeChar.execute(this.sessionId, this.serviceUuid, this.characteristicUuid, chunk, true);
      }
    );
    const snapshot = session.snapshot();
    this.throughputBytes = snapshot.bytesSent;
    this.throughputRunning = false;
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  private stopThroughput(): void {
    if (this.throughput !== undefined) {
      this.throughput.stop();
      const snapshot = this.throughput.snapshot();
      this.throughputBytes = snapshot.bytesSent;
    }
    this.throughputRunning = false;
  }

  private noteError(code: string, message: string): void {
    this.statusText = message.length > 0 ? message : code;
    if (code === BluetoothErrorCodes.GATT_INSUFFICIENT_ENCRYPTION) {
      this.securityHint = '2901005';
      return;
    }
    if (code === BluetoothErrorCodes.GATT_INSUFFICIENT_AUTHENTICATION) {
      this.securityHint = '2901006';
      return;
    }
    if (code === BluetoothErrorCodes.GATT_INSUFFICIENT_AUTHORIZATION) {
      this.securityHint = '2901007';
      return;
    }
    if (code === BluetoothErrorCodes.GATT_TIMEOUT || code === BluetoothErrorCodes.GATT_SEQUENCE) {
      this.securityHint = '';
      this.statusText = code;
    }
  }

  private static hexToBytes(text: string): Uint8Array | undefined {
    const normalized = text.replace(/\s+/g, '');
    if (normalized.length === 0 || normalized.length % 2 !== 0) {
      return undefined;
    }
    const bytes = new Uint8Array(normalized.length / 2);
    for (let i = 0; i < bytes.length; i++) {
      const value = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
      if (Number.isNaN(value)) {
        return undefined;
      }
      bytes[i] = value;
    }
    return bytes;
  }
}
