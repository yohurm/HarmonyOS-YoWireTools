import { IdGenerator, Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  DebugTarget,
  ITransportSession,
  ModuleType,
  ProtocolType,
  SessionType,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { bluetoothRepository } from '../../repository/BluetoothRepositories';
import { ConnectSppResult, SppConnectParams } from '../../model/SppConnectParams';
import { BluetoothTransportPolicy, BluetoothTransportType } from '../../model/BluetoothTransportType';
import { asSppTransportFacet } from '../../model/spp/ISppTransportFacet';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';
import { ResolveSppTargetAddressUseCase } from './SppAddressUseCases';
import { SppReconnectCoordinator } from '../../service/SppReconnectCoordinator';
import { SppSessionAdmissionPolicy } from '../../service/spp/SppSessionAdmissionPolicy';
import { SppSessionLedger } from '../../service/spp/SppSessionLedger';
import { SppSessionTeardown } from '../../service/spp/SppSessionTeardown';
import { SppSessionKey } from '../../model/SppSessionKey';

/**
 * SPP connect pipeline (architecture bluetooth/02 v1.2):
 * guard → resolve → admission/ledger.reserve → stop discovery → bootstrap → connect → register → promote → bind reconnect.
 */
export class ConnectSppUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly resolveAddress: ResolveSppTargetAddressUseCase;
  private readonly ledger: SppSessionLedger;
  private readonly admissionPolicy: SppSessionAdmissionPolicy;

  constructor(
    repository: BluetoothRepositoryContract = bluetoothRepository(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    resolveAddress: ResolveSppTargetAddressUseCase = new ResolveSppTargetAddressUseCase(),
    ledger: SppSessionLedger = SppSessionLedger.getInstance()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
    this.transportRegistry = transportRegistry;
    this.resolveAddress = resolveAddress;
    this.ledger = ledger;
    this.admissionPolicy = new SppSessionAdmissionPolicy(ledger);
  }

  async execute(params: SppConnectParams): Promise<Result<ConnectSppResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    const address = this.resolveAddress.executeFromAddress(params.classicDeviceId, params.transport);
    if (!address.success || address.value === undefined || address.value.length === 0) {
      return Result.fail(address.error ?? new ResultError(
        BluetoothErrorCodes.SPP_BLE_ADDRESS_REJECTED,
        'classic address required'
      ));
    }
    if (params.transport === BluetoothTransportType.LE) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_TARGET_LE_ONLY, 'LE-only rejected'));
    }
    if (params.transport !== BluetoothTransportType.UNKNOWN &&
      !BluetoothTransportPolicy.isClassicCandidate(params.transport)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_TARGET_LE_ONLY, 'transport not classic'));
    }
    const classicId = SppSessionKey.normalizeClassicId(address.value);
    const connectParams = new SppConnectParams(
      classicId,
      params.displayName,
      params.uuid,
      params.secure,
      params.timeoutMs,
      params.autoReconnect,
      params.reconnectPolicy,
      params.transport === BluetoothTransportType.UNKNOWN ?
        BluetoothTransportType.BR_EDR :
        params.transport,
      params.bleDeviceId
    );
    const sessionKey = SppSessionKey.fromParts(classicId, connectParams.uuid);
    // Pre-check shares SessionKey normalization with QuerySppConnectEligibilityUseCase.
    const eligible = this.admissionPolicy.ensureCanConnect(sessionKey);
    if (!eligible.success) {
      return Result.fail(eligible.error ?? new ResultError(
        BluetoothErrorCodes.SPP_DUPLICATE_SESSION,
        'SPP admission rejected'
      ));
    }
    const pendingSessionId = IdGenerator.next('spp');
    const reserved = this.ledger.tryReserve(sessionKey, pendingSessionId);
    if (!reserved.success) {
      return Result.fail(reserved.error ?? new ResultError(
        BluetoothErrorCodes.SPP_DUPLICATE_SESSION,
        'SPP ledger reserve failed'
      ));
    }
    await this.repository.ensureClassicDiscoveryStopped();
    const target = new DebugTarget(
      classicId,
      ModuleType.BLUETOOTH,
      connectParams.displayName,
      ProtocolType.SPP,
      classicId,
      'virtual',
      '',
      0,
      connectParams.uuid
    );
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.SPP,
      `SPP ${connectParams.displayName}`,
      AppMode.EXPERT,
      target
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      this.ledger.release(sessionKey, 'session_create_failed');
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    this.ledger.bindSessionId(sessionKey, session.value.id);
    this.ledger.markConnecting(sessionKey);
    // Inject connecting paired target into classic scan list immediately (app-layer keep-alive).
    this.repository.republishClassicDevices();
    const created = this.repository.createSppTransport(session.value.id, connectParams);
    const transport = created as ITransportSession;
    const facet = asSppTransportFacet(created);
    if (facet === undefined) {
      transport.destroy();
      await SppSessionTeardown.failCleanup(session.value.id, 'spp_facet_missing');
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, 'SPP transport facet missing'));
    }
    try {
      await transport.connect(connectParams.toConnectRecord());
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      await SppSessionTeardown.failCleanup(session.value.id, 'connect_failed');
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err.message, err));
    }
    this.transportRegistry.register(session.value.id, transport);
    this.ledger.promoteConnected(sessionKey, facet.getClientSocketId());
    if (connectParams.autoReconnect) {
      SppReconnectCoordinator.getInstance().bind(
        session.value.id,
        classicId,
        (): Promise<void> => facet.reopenForReconnect(),
        connectParams.reconnectPolicy
      );
    }
    this.repository.recordRecentConnection(classicId, connectParams.displayName, 'spp');
    this.repository.republishClassicDevices();
    return Result.ok(new ConnectSppResult(session.value.id, transport.id, sessionKey));
  }
}

/**
 * Disconnect order (architecture bluetooth/02 §5.1):
 * Coordinator.unbind → queue.reset → disconnect → TSR.remove → markClosing → release → stopSession → republish.
 */
export class DisconnectSppUseCase {
  async execute(sessionId: string): Promise<Result<void>> {
    SppReconnectCoordinator.getInstance().unbind(sessionId);
    return await SppSessionTeardown.userDisconnectCleanup(sessionId);
  }
}
