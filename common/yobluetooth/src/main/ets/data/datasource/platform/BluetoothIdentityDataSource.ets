import { IdGenerator, Result } from 'common_core';
import { DeviceFavoriteRecord, TargetRepository, PreferenceKeys, PreferencesStore } from 'common_storage';
import { ModuleType } from 'debug_core';
import { DeviceIdentity, IdentityStability } from '../../../domain/model/DeviceIdentity';
import {
  AddressPrivacyKind,
  BluetoothListRail,
  BluetoothTransportType
} from '../../../domain/model/BluetoothTransportType';
import { PairingState } from '../../../domain/model/PairingState';
import { BluetoothRecentConnection } from '../../../domain/model/BluetoothRecentConnection';

/**
 * Device identity and favorites per architecture bluetooth/00 + 01-搂6.2.
 */
export class BluetoothIdentityDataSource {
  private static instance: BluetoothIdentityDataSource | undefined;
  private readonly targetRepository: TargetRepository;
  private recentConnections: BluetoothRecentConnection[] = [];
  private recentLoaded: boolean = false;
  private readonly dualLinks: Map<string, DeviceIdentity> = new Map();
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

  buildIdentityForRail(
    address: string,
    paired: boolean,
    rail: BluetoothListRail,
    transport: BluetoothTransportType
  ): DeviceIdentity {
    const linked = this.findLinkedByAnyAddress(address);
    if (linked !== undefined) {
      return linked;
    }
    const hash = BluetoothIdentityDataSource.simpleHash(address);
    const stability = BluetoothIdentityDataSource.resolveStability(address, paired);
    const classicId = rail === BluetoothListRail.CLASSIC_SCAN ? address : '';
    const bleId = rail === BluetoothListRail.BLE_SCAN ? address : '';
    return new DeviceIdentity(
      hash,
      classicId,
      bleId,
      classicId.length > 0 ? hash : '',
      bleId.length > 0 ? hash : '',
      transport,
      '',
      '',
      stability,
      paired ? PairingState.PAIRED : PairingState.UNPAIRED
    );
  }

  linkDualModeIdentity(
    classicDeviceId: string,
    bleDeviceId: string,
    displayNameHint: string = ''
  ): DeviceIdentity {
    const identityId = BluetoothIdentityDataSource.simpleHash(`${classicDeviceId}|${bleDeviceId}`);
    const linked = new DeviceIdentity(
      identityId,
      classicDeviceId,
      bleDeviceId,
      BluetoothIdentityDataSource.simpleHash(classicDeviceId),
      BluetoothIdentityDataSource.simpleHash(bleDeviceId),
      BluetoothTransportType.DUAL,
      displayNameHint,
      '',
      IdentityStability.PAIRED_STABLE,
      PairingState.PAIRED,
      0,
      Date.now()
    );
    this.dualLinks.set(classicDeviceId.toUpperCase(), linked);
    this.dualLinks.set(bleDeviceId.toUpperCase(), linked);
    this.dualLinks.set(identityId, linked);
    return linked;
  }

  findLinkedByAnyAddress(deviceId: string): DeviceIdentity | undefined {
    return this.dualLinks.get(deviceId.toUpperCase());
  }

  resolvePersistentMac(_address: string): string {
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
    address: string,
    displayName: string,
    alias: string,
    protocol: string,
    uuid: string = '',
    addressPrivacy: AddressPrivacyKind = AddressPrivacyKind.VIRTUAL
  ): Promise<Result<void>> {
    const record = new DeviceFavoriteRecord(
      IdGenerator.next('btfav'),
      ModuleType.BLUETOOTH,
      protocol,
      displayName,
      alias,
      address,
      addressPrivacy,
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

  isFavorite(address: string, favorites: DeviceFavoriteRecord[]): boolean {
    for (let i = 0; i < favorites.length; i++) {
      if (favorites[i].address === address) {
        return true;
      }
    }
    return false;
  }

  findAlias(address: string, favorites: DeviceFavoriteRecord[]): string {
    for (let i = 0; i < favorites.length; i++) {
      if (favorites[i].address === address && favorites[i].alias.length > 0) {
        return favorites[i].alias;
      }
    }
    return '';
  }

  recordRecentConnection(targetAddress: string, displayName: string, protocol: string): void {
    const next: BluetoothRecentConnection[] = [];
    next.push(new BluetoothRecentConnection(targetAddress, displayName, protocol, Date.now()));
    for (let i = 0; i < this.recentConnections.length; i++) {
      const item = this.recentConnections[i];
      if (item.targetAddress === targetAddress && item.protocol === protocol) {
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

  /**
   * Unpaired scan addresses stay ephemeral. addPersistentDeviceId is not called,
   * so a MAC-shaped virtual address is not a persisted-address success.
   */
  private static resolveStability(address: string, paired: boolean): IdentityStability {
    if (paired) {
      return IdentityStability.PAIRED_STABLE;
    }
    if (address.length > 0) {
      return IdentityStability.EPHEMERAL_RANDOM;
    }
    return IdentityStability.UNKNOWN;
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
