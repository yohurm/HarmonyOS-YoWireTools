import { Result, ResultError, Subscription } from 'common_core';
import { SessionRuntimeStore, TransportSessionRegistry } from 'debug_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { SppSessionDescriptor } from '../../model/SppSessionDescriptor';
import { SppSessionKey } from '../../model/SppSessionKey';
import { asSppTransportFacet } from '../../model/spp/ISppTransportFacet';
import { SppSessionAdmissionPolicy } from '../../service/spp/SppSessionAdmissionPolicy';
import { SppSessionCatalog } from '../../service/spp/SppSessionCatalog';

/**
 * Pre-flight check for scan-list connect button state.
 */
export class QuerySppConnectEligibilityUseCase {
  private readonly admissionPolicy: SppSessionAdmissionPolicy;

  constructor(admissionPolicy: SppSessionAdmissionPolicy) {
    this.admissionPolicy = admissionPolicy;
  }

  execute(classicDeviceId: string, serviceUuid: string = BluetoothConstants.DEFAULT_SPP_UUID): Result<void> {
    return this.admissionPolicy.ensureCanConnect(SppSessionKey.fromParts(classicDeviceId, serviceUuid));
  }

  isKeyActive(classicDeviceId: string, serviceUuid: string = BluetoothConstants.DEFAULT_SPP_UUID): boolean {
    return this.admissionPolicy.hasActiveKey(SppSessionKey.fromParts(classicDeviceId, serviceUuid));
  }
}

/**
 * Observes RuntimeStore active-session list; Catalog merges with Ledger
 * (no active row without Ledger key — architecture bluetooth/02).
 */
export class ObserveSppSessionsUseCase {
  private readonly runtimeStore: SessionRuntimeStore;
  private readonly catalog: SppSessionCatalog;

  constructor(
    runtimeStore: SessionRuntimeStore,
    catalog: SppSessionCatalog
  ) {
    this.runtimeStore = runtimeStore;
    this.catalog = catalog;
  }

  execute(onSessions: (sessions: SppSessionDescriptor[]) => void): Subscription {
    return this.runtimeStore.observeActiveSessions().subscribe((_summaries) => {
      onSessions(this.catalog.listActiveDescriptors());
    });
  }
}

/**
 * Reads getMaxTransmitDataSize for an open socket. Failure stays a failure, not a zero limit.
 */
export class QuerySppMaxTransmitUseCase {
  private readonly registry: TransportSessionRegistry;

  constructor(registry: TransportSessionRegistry) {
    this.registry = registry;
  }

  execute(sessionId: string): Result<number> {
    const facet = asSppTransportFacet(this.registry.get(sessionId));
    if (facet === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'SPP session missing'));
    }
    return facet.maxTransmitBytes();
  }
}
