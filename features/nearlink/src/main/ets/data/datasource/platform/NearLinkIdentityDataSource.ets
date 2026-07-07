import { IdGenerator, Result } from 'common_core';
import { DeviceFavoriteRecord, TargetRepository } from 'common_storage';
import { ModuleType } from 'feature_debug_core';
import { NearLinkRecentConnection } from '../../../domain/model/NearLinkRecentConnection';
import { NearLinkDevice } from '../../../domain/model/NearLinkDevice';

export class NearLinkIdentityDataSource {
  private static instance: NearLinkIdentityDataSource | undefined;
  private readonly targetRepository: TargetRepository;
  private recentConnections: NearLinkRecentConnection[] = [];
  private static readonly MAX_RECENT: number = 10;

  private constructor(targetRepository: TargetRepository = TargetRepository.getInstance()) {
    this.targetRepository = targetRepository;
  }

  static getInstance(): NearLinkIdentityDataSource {
    if (NearLinkIdentityDataSource.instance === undefined) {
      NearLinkIdentityDataSource.instance = new NearLinkIdentityDataSource();
    }
    return NearLinkIdentityDataSource.instance;
  }

  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void {
    const now = Date.now();
    const filtered = this.recentConnections.filter((item: NearLinkRecentConnection) =>
      item.deviceId !== deviceId || item.protocol !== protocol);
    filtered.unshift(new NearLinkRecentConnection(deviceId, displayName, protocol, now));
    this.recentConnections = filtered.slice(0, NearLinkIdentityDataSource.MAX_RECENT);
  }

  listRecentConnections(): NearLinkRecentConnection[] {
    return [...this.recentConnections];
  }

  async listFavorites(): Promise<Result<DeviceFavoriteRecord[]>> {
    return this.targetRepository.listFavorites(ModuleType.NEARLINK);
  }

  async saveFavorite(device: NearLinkDevice, alias: string, protocol: string, uuid: string = ''): Promise<Result<void>> {
    const record = new DeviceFavoriteRecord(
      IdGenerator.next('nlfav'),
      ModuleType.NEARLINK,
      protocol,
      device.displayName,
      alias,
      device.randomAddress,
      'random',
      '',
      0,
      uuid,
      '{}',
      Date.now()
    );
    return this.targetRepository.saveFavorite(record);
  }
}
