import {
  BluetoothConstants,
  BluetoothErrorCodes,
  BluetoothRepository,
  BluetoothUseCaseFactory,
  ConnectGattUseCase,
  ConnectionParamPreset,
  DisconnectGattUseCase,
  DiscoverGattServicesUseCase,
  GattConnectParams,
  HexPayload,
  MtuBounds,
  ReadGattCharacteristicUseCase,
  ReadGattDescriptorUseCase,
  ReadGattRssiUseCase,
  RequestBleMtuUseCase,
  SetGattNotificationUseCase,
  ThroughputSession,
  UpdateGattConnectionParamUseCase,
  WriteGattCharacteristicUseCase,
  WriteGattDescriptorUseCase
} from 'yobluetooth';

@ObservedV2
export class GattClientViewModel {
  @Trace sessionId: string = '';
  @Trace serviceUuid: string = '';
  @Trace characteristicUuid: string = '';
  @Trace descriptorUuid: string = '';
  @Trace payloadHex: string = '';
  @Trace mtuText: string = '23';
  @Trace mtuShown: number = BluetoothConstants.BLE_DEFAULT_MTU;
  @Trace mtuPending: boolean = false;
  @Trace rssiText: string = '';
  @Trace statusText: string = '';
  @Trace securityHint: string = '';
  @Trace throughputBytes: number = 0;
  @Trace throughputRunning: boolean = false;

  private readonly connectGatt: ConnectGattUseCase = BluetoothUseCaseFactory.connectGatt();
  private readonly disconnectGatt: DisconnectGattUseCase = BluetoothUseCaseFactory.disconnectGatt();
  private readonly discover: DiscoverGattServicesUseCase = BluetoothUseCaseFactory.discoverGattServices();
  private readonly readChar: ReadGattCharacteristicUseCase = BluetoothUseCaseFactory.readGattCharacteristic();
  private readonly writeChar: WriteGattCharacteristicUseCase = BluetoothUseCaseFactory.writeGattCharacteristic();
  private readonly readDescriptor: ReadGattDescriptorUseCase = BluetoothUseCaseFactory.readGattDescriptor();
  private readonly writeDescriptor: WriteGattDescriptorUseCase = BluetoothUseCaseFactory.writeGattDescriptor();
  private readonly notify: SetGattNotificationUseCase = BluetoothUseCaseFactory.setGattNotification();
  private readonly requestMtu: RequestBleMtuUseCase = BluetoothUseCaseFactory.requestBleMtu();
  private readonly readRssi: ReadGattRssiUseCase = BluetoothUseCaseFactory.readGattRssi();
  private readonly updateParam: UpdateGattConnectionParamUseCase = BluetoothUseCaseFactory.updateGattConnectionParam();
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private throughput: ThroughputSession | undefined = undefined;

  onDisappear(): void {
    if (this.throughput !== undefined) {
      this.throughput.stop();
    }
  }

  async connect(deviceId: string, displayName: string, connectable: boolean): Promise<void> {
    if (!connectable) {
      this.statusText = 'not_connectable';
      return;
    }
    const connected = await this.connectGatt.execute(new GattConnectParams(deviceId, displayName));
    if (!connected.success || connected.value === undefined) {
      this.noteError(connected.error?.code ?? '', connected.error?.message ?? '');
      return;
    }
    this.sessionId = connected.value.sessionId;
    this.mtuShown = this.repository.gattCurrentMtu(this.sessionId);
    const discovered = await this.discover.execute(this.sessionId, deviceId, this.mtuShown);
    if (!discovered.success) {
      this.noteError(discovered.error?.code ?? '', discovered.error?.message ?? '');
    }
  }

  async applyMtu(): Promise<void> {
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

  async applyPreset(preset: ConnectionParamPreset): Promise<void> {
    const result = await this.updateParam.execute(this.sessionId, preset);
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  async readValue(): Promise<void> {
    const result = await this.readChar.execute(this.sessionId, this.serviceUuid, this.characteristicUuid);
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
      return;
    }
    this.statusText = result.value ?? '';
  }

  async readDescriptorValue(): Promise<void> {
    const result = await this.readDescriptor.execute(
      this.sessionId,
      this.serviceUuid,
      this.characteristicUuid,
      this.descriptorUuid
    );
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
      return;
    }
    this.statusText = result.value ?? '';
  }

  async writeDescriptorValue(): Promise<void> {
    const parsed = HexPayload.parse(this.payloadHex);
    if (!parsed.success || parsed.value === undefined) {
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const result = await this.writeDescriptor.execute(
      this.sessionId,
      this.serviceUuid,
      this.characteristicUuid,
      this.descriptorUuid,
      parsed.value
    );
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  async disconnect(): Promise<void> {
    if (this.sessionId.length === 0) {
      this.statusText = 'not_connected';
      return;
    }
    const result = await this.disconnectGatt.execute(this.sessionId);
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
      return;
    }
    this.sessionId = '';
    this.mtuPending = false;
  }

  async writeValue(noResponse: boolean): Promise<void> {
    const parsed = HexPayload.parse(this.payloadHex);
    if (!parsed.success || parsed.value === undefined) {
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const result = await this.writeChar.execute(
      this.sessionId,
      this.serviceUuid,
      this.characteristicUuid,
      parsed.value,
      noResponse
    );
    if (!result.success) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
    }
  }

  async subscribe(indication: boolean): Promise<void> {
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

  async readLinkRssi(): Promise<void> {
    const result = await this.readRssi.execute(this.sessionId);
    if (!result.success || result.value === undefined) {
      this.noteError(result.error?.code ?? '', result.error?.message ?? '');
      return;
    }
    this.rssiText = `${result.value} dBm`;
  }

  async startThroughput(): Promise<void> {
    const parsed = HexPayload.parse(this.payloadHex.length > 0 ? this.payloadHex : '00');
    if (!parsed.success || parsed.value === undefined) {
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const session = new ThroughputSession();
    this.throughput = session;
    this.throughputRunning = true;
    const result = await session.run(
      this.sessionId,
      parsed.value,
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

  stopThroughput(): void {
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
}
