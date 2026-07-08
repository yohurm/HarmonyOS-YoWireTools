import { IdGenerator, Result, ResultError } from 'common_core';
import { DeviceFavoriteRecord, TargetRepository, PreferenceKeys, PreferencesStore } from 'common_storage';
import { ModuleType } from 'feature_debug_core';
import { AddressKind, DeviceIdentity, IdentityStability } from '../../../domain/model/DeviceIdentity';
import { PairingState } from '../../../domain/model/PairingState';
import { BluetoothRecentConnection } from '../../../domain/model/BluetoothRecentConnection';

/**
 * Device identity and favorites per architecture bluetooth/01-§6.2 and 02-§5 / §13.
 */

export class BluetoothIdentityDataSource {
  private static instance: BluetoothIdentityDataSource | undefined;
  private readonly targetRepository: TargetRepository;
  private recentConnections: BluetoothRecentConnection[] = [];
  private recentLoaded: boolean = false;
  private static readonly MAX_RECENT: number = 10;
  private constructor(targetRepository: TargetRepository = TargetRepository.getInstance()) {
    this.targetRepository = targetRepository;
  }
  static getInstance(): BluetoothIdentityDataSource {
    if (BluetoothIdentityDataSource.instance === undefined) {
      BluetoothIdentityDataSource.instance = new BluetoothIdentityDataSource();
    }
    return BluetoothIdentityDataSource.instance;
  }
  buildIdentity(platformDeviceId: string, paired: boolean): DeviceIdentity {
    const hash = BluetoothIdentityDataSource.simpleHash(platformDeviceId);
    const stability = BluetoothIdentityDataSource.resolveStability(platformDeviceId, paired);
    const addressKind = BluetoothIdentityDataSource.resolveAddressKind(platformDeviceId);
    return new DeviceIdentity(
      hash,
      platformDeviceId,
      hash,
      '',
      stability,
      paired ? PairingState.PAIRED : PairingState.UNPAIRED
    );
  }
  resolvePersistentMac(platformDeviceId: string): string {
    if (BluetoothIdentityDataSource.looksLikeMac(platformDeviceId)) {
      return platformDeviceId;
    }
    return '';
  }
  async loadRecentFromStore(): Promise<void> {
    if (this.recentLoaded) {
      return;
    }
    const store = PreferencesStore.getInstance();
    const raw = await store.getString(PreferenceKeys.BLUETOOTH_RECENT_CONNECTIONS, '');
    if (raw.length === 0) {
      this.recentLoaded = true;
      return;
    }
    const lines = raw.split('\n');
    const next: BluetoothRecentConnection[] = [];
    for (let i = 0; i < lines.length; i++) {
      const item = BluetoothRecentConnection.fromJson(lines[i]);
      if (item !== undefined) {
        next.push(item);
      }
    }
    this.recentConnections = next;
    this.recentLoaded = true;
  }
  async saveFavorite(
    deviceId: string,
    displayName: string,
    alias: string,
    protocol: string,
    uuid: string = ''
  ): Promise<Result<void>> {
    const record = new DeviceFavoriteRecord(
      IdGenerator.next('btfav'),
      ModuleType.BLUETOOTH,
      protocol,
      displayName,
      alias,
      deviceId,
      AddressKind.VIRTUAL,
      '',
      0,
      uuid,
      '{}',
      Date.now()
    );
    return this.targetRepository.saveFavorite(record);
  }
  async removeFavorite(id: string): Promise<Result<void>> {
    return this.targetRepository.removeFavorite(id);
  }
  async listFavorites(): Promise<Result<DeviceFavoriteRecord[]>> {
    return this.targetRepository.listFavorites(ModuleType.BLUETOOTH);
  }
  isFavorite(deviceId: string, favorites: DeviceFavoriteRecord[]): boolean {
    for (let i = 0; i < favorites.length; i++) {
      if (favorites[i].address === deviceId) {
        return true;
      }
    }
    return false;
  }
  findAlias(deviceId: string, favorites: DeviceFavoriteRecord[]): string {
    for (let i = 0; i < favorites.length; i++) {
      if (favorites[i].address === deviceId && favorites[i].alias.length > 0) {
        return favorites[i].alias;
      }
    }
    return '';
  }
  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void {
    const next: BluetoothRecentConnection[] = [];
    next.push(new BluetoothRecentConnection(deviceId, displayName, protocol, Date.now()));
    for (let i = 0; i < this.recentConnections.length; i++) {
      const item = this.recentConnections[i];
      if (item.deviceId === deviceId && item.protocol === protocol) {
        continue;
      }
      next.push(item);
      if (next.length >= BluetoothIdentityDataSource.MAX_RECENT) {
        break;
      }
    }
    this.recentConnections = next;
    void this.persistRecent();
  }
  listRecentConnections(): BluetoothRecentConnection[] {
    return this.recentConnections;
  }
  private async persistRecent(): Promise<void> {
    const lines: string[] = [];
    for (let i = 0; i < this.recentConnections.length; i++) {
      lines.push(this.recentConnections[i].toJson());
    }
    await PreferencesStore.getInstance().putString(
      PreferenceKeys.BLUETOOTH_RECENT_CONNECTIONS,
      lines.join('\n')
    );
  }
  private static resolveStability(platformDeviceId: string, paired: boolean): IdentityStability {
    if (paired) {
      return IdentityStability.PAIRED_STABLE;
    }
    if (BluetoothIdentityDataSource.looksLikeMac(platformDeviceId)) {
      return IdentityStability.PERSISTENT_MAC;
    }
    if (platformDeviceId.length > 0) {
      return IdentityStability.EPHEMERAL_RANDOM;
    }
    return IdentityStability.UNKNOWN;
  }
  private static resolveAddressKind(platformDeviceId: string): AddressKind {
    return BluetoothIdentityDataSource.looksLikeMac(platformDeviceId)
      ? AddressKind.REAL
      : AddressKind.VIRTUAL;
  }
  private static looksLikeMac(value: string): boolean {
    return /^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/.test(value);
  }
  private static simpleHash(value: string): string {
    let hash = 0;
    for (let i = 0; i < value.length; i++) {
      hash = ((hash << 5) - hash) + value.charCodeAt(i);
      hash |= 0;
    }
    return `bt-${Math.abs(hash)}`;
  }
}
