import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  DebugTarget,
  ModuleType,
  ProtocolType,
  SessionType,
  StopSessionUseCase,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { GattConnectParams } from '../../model/GattConnectParams';
import { SerialProfileId, UartConnectPhase } from '../../model/uart/UartConnectPhase';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';
import { CommandWriteQueue } from '../../service/queue/CommandWriteQueue';

export class ConnectUartResult {
  readonly sessionId: string;
  readonly transportId: string;
  readonly profileId: SerialProfileId;
  readonly phase: UartConnectPhase;

  constructor(
    sessionId: string,
    transportId: string,
    profileId: SerialProfileId,
    phase: UartConnectPhase
  ) {
    this.sessionId = sessionId;
    this.transportId = transportId;
    this.profileId = profileId;
    this.phase = phase;
  }
}

/**
 * BLE-UART connect via GattTransportSession (Nordic + autoDetect) 鈥?architecture bluetooth/04.
 */
export class ConnectUartUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
  }

  async execute(
    bleDeviceId: string,
    displayName: string,
    onPhase: (phase: UartConnectPhase) => void = (_p: UartConnectPhase) => {
    }
  ): Promise<Result<ConnectUartResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    if (bleDeviceId.length === 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED,
        'bleDeviceId required for UART'
      ));
    }
    if (!this.repository.tryReserveBleConnection()) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.BLE_GATT_SESSION_LIMIT,
        `GATT session limit ${BluetoothConstants.GATT_MAX_SESSIONS}`
      ));
    }
    this.repository.stopBleScan();
    onPhase(UartConnectPhase.CONNECTING);
    const target = new DebugTarget(
      bleDeviceId,
      ModuleType.BLUETOOTH,
      displayName,
      ProtocolType.BLE_UART,
      bleDeviceId,
      'virtual'
    );
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.BLE_UART,
      `UART ${displayName}`,
      AppMode.EXPERT,
      target
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      this.repository.releaseBleConnection();
      onPhase(UartConnectPhase.FAILED);
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const params = new GattConnectParams(
      bleDeviceId,
      displayName,
      BluetoothConstants.NORDIC_UART_SERVICE_UUID,
      BluetoothConstants.NORDIC_UART_RX_UUID,
      BluetoothConstants.NORDIC_UART_TX_UUID,
      true,
      true
    );
    onPhase(UartConnectPhase.DISCOVERING);
    onPhase(UartConnectPhase.MATCHING_PROFILE);
    const opened = await this.repository.connectGattTransport(session.value.id, params.toConnectRecord());
    if (!opened.success || opened.value === undefined) {
      this.repository.releaseBleConnection();
      const message = opened.error !== undefined ? opened.error.message : '';
      if (message.indexOf('serial') >= 0 || message.indexOf('characteristic') >= 0) {
        onPhase(UartConnectPhase.FAILED_NO_PROFILE);
        return Result.fail(opened.error ?? new ResultError(BluetoothErrorCodes.BLE_UART_NO_PROFILE, message));
      }
      onPhase(UartConnectPhase.FAILED);
      return Result.fail(opened.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, message));
    }
    onPhase(UartConnectPhase.READY);
    this.repository.recordRecentConnection(bleDeviceId, displayName, 'ble_uart');
    return Result.ok(new ConnectUartResult(
      session.value.id,
      opened.value,
      SerialProfileId.NORDIC_UART,
      UartConnectPhase.READY
    ));
  }
}

export class DisconnectUartUseCase {
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly stopSession: StopSessionUseCase;
  private readonly repository: BluetoothRepository;

  constructor(
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.transportRegistry = transportRegistry;
    this.stopSession = stopSession;
    this.repository = repository;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport !== undefined) {
      new CommandWriteQueue(transport.id).reset();
      await transport.disconnect('user_disconnect');
      this.transportRegistry.remove(sessionId);
      this.repository.releaseBleConnection();
    }
    return this.stopSession.execute(sessionId, 'uart_disconnected');
  }
}
