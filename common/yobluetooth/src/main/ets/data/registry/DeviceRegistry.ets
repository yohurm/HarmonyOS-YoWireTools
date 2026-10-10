import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { BluetoothIdentityDataSource } from '../datasource/platform/BluetoothIdentityDataSource';
import { BluetoothDevice } from '../../domain/model/BluetoothDevice';
import { BluetoothRecentConnection } from '../../domain/model/BluetoothRecentConnection';
import { DeviceIdentity } from '../../domain/model/DeviceIdentity';
import { AddressPrivacyKind } from '../../domain/model/BluetoothTransportType';

/**
 * Device identity registry — favorites, recent, dual-mode links.
 * Lives in data so the domain layer does not import a DataSource.
 */
export class DeviceRegistry {
  private static instance: DeviceRegistry | undefined;
  private readonly identity: BluetoothIdentityDataSource;

  private constructor(identity: BluetoothIdentityDataSource = BluetoothIdentityDataSource.getInstance()) {
    this.identity = identity;
  }

  static getInstance(): DeviceRegistry {
    if (DeviceRegistry.instance === undefined) {
      DeviceRegistry.instance = new DeviceRegistry();
    }
    return DeviceRegistry.instance;
  }

  linkDualMode(classicDeviceId: string, bleDeviceId: string, displayNameHint: string = ''): DeviceIdentity {
    return this.identity.linkDualModeIdentity(classicDeviceId, bleDeviceId, displayNameHint);
  }

  listRecentConnections(): BluetoothRecentConnection[] {
    return this.identity.listRecentConnections();
  }

  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void {
    this.identity.recordRecentConnection(deviceId, displayName, protocol);
  }

  async listFavorites(): Promise<Result<DeviceFavoriteRecord[]>> {
    return this.identity.listFavorites();
  }

  async saveFavorite(
    device: BluetoothDevice,
    alias: string,
    protocol: string,
    uuid: string = ''
  ): Promise<Result<void>> {
    const address = device.classicDeviceId.length > 0 ?
      device.classicDeviceId :
      (device.bleDeviceId.length > 0 ? device.bleDeviceId : device.primaryDeviceId);
    const displayName = device.effectiveName.length > 0 ? device.effectiveName : address;
    return this.identity.saveFavorite(
      address,
      displayName,
      alias,
      protocol,
      uuid,
      AddressPrivacyKind.VIRTUAL
    );
  }

  async removeFavorite(id: string): Promise<Result<void>> {
    return this.identity.removeFavorite(id);
  }
}
