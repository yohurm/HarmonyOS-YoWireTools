import { Result } from 'common_core';
import { PermissionStatus } from 'common_platform';
import {
  EnsurePermissionUseCase,
  PermissionScenario,
  PermissionScenarioCoordinator
} from 'debug_core';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiAccessPointSnapshot } from '../model/WifiAccessPointSnapshot';
import { WifiOverviewSnapshot } from '../model/WifiOverviewSnapshot';

export class WifiOverviewLoaded {
  readonly wifiInfoGranted: boolean;
  readonly peersMacGranted: boolean;
  readonly snapshot: WifiOverviewSnapshot;
  readonly accessPoints: WifiAccessPointSnapshot[];

  constructor(
    wifiInfoGranted: boolean,
    peersMacGranted: boolean,
    snapshot: WifiOverviewSnapshot,
    accessPoints: WifiAccessPointSnapshot[]
  ) {
    this.wifiInfoGranted = wifiInfoGranted;
    this.peersMacGranted = peersMacGranted;
    this.snapshot = snapshot;
    this.accessPoints = accessPoints;
  }
}

/**
 * WiFi overview read path: request GET_WIFI_INFO, check peer-MAC without prompting,
 * then load the repository snapshot and cached scan rows.
 */
export class LoadWifiOverviewUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly coordinator: PermissionScenarioCoordinator;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    coordinator: PermissionScenarioCoordinator = PermissionScenarioCoordinator.getInstance()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.coordinator = coordinator;
  }

  async execute(): Promise<Result<WifiOverviewLoaded>> {
    const wifiPerm = await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    const macUi = await this.coordinator.buildUiStateForScenario(PermissionScenario.WIFI_PEERS_MAC);
    const peersMacGranted = LoadWifiOverviewUseCase.areGranted(macUi.statuses);
    const snapshot = await this.repository.loadOverview(wifiPerm.granted, peersMacGranted);
    const accessPoints = wifiPerm.granted ? this.repository.getLastScanResults() : [];
    return Result.ok(new WifiOverviewLoaded(wifiPerm.granted, peersMacGranted, snapshot, accessPoints));
  }

  private static areGranted(statuses: PermissionStatus[]): boolean {
    if (statuses.length === 0) {
      return false;
    }
    for (let i = 0; i < statuses.length; i++) {
      if (statuses[i] !== PermissionStatus.GRANTED) {
        return false;
      }
    }
    return true;
  }
}
