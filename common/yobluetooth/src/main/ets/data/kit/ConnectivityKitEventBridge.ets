import { access, baseProfile, ble, connection, socket } from '@kit.ConnectivityKit';
import { Result } from 'common_core';
import { KitEventSubscription } from 'common_platform';

/**
 * Connectivity Kit event bridge per WSL ohos.bluetooth.access / connection / ble / socket / baseProfile.
 * All kit on()/off() calls live here so DataSources stay throw-safe.
 */
export class ConnectivityKitEventBridge {
  static subscribeAccessStateChange(
    handler: (state: access.BluetoothState) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      access.on('stateChange', handler);
    }, 'access.stateChange');
  }

  static unsubscribeAccessStateChange(handler: (state: access.BluetoothState) => void): void {
    KitEventSubscription.unsubscribe(() => {
      access.off('stateChange', handler);
    }, 'access.stateChange');
  }

  static subscribeDiscoveryResult(
    handler: (results: Array<connection.DiscoveryResult>) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      connection.on('discoveryResult', handler);
    }, 'connection.discoveryResult');
  }

  static unsubscribeDiscoveryResult(handler: (results: Array<connection.DiscoveryResult>) => void): void {
    KitEventSubscription.unsubscribe(() => {
      connection.off('discoveryResult', handler);
    }, 'connection.discoveryResult');
  }

  static subscribeBluetoothDeviceFind(handler: (deviceIds: Array<string>) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      connection.on('bluetoothDeviceFind', handler);
    }, 'connection.bluetoothDeviceFind');
  }

  static unsubscribeBluetoothDeviceFind(handler: (deviceIds: Array<string>) => void): void {
    KitEventSubscription.unsubscribe(() => {
      connection.off('bluetoothDeviceFind', handler);
    }, 'connection.bluetoothDeviceFind');
  }

  static subscribeBondStateChange(handler: (param: connection.BondStateParam) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      connection.on('bondStateChange', handler);
    }, 'connection.bondStateChange');
  }

  static unsubscribeBondStateChange(handler: (param: connection.BondStateParam) => void): void {
    KitEventSubscription.unsubscribe(() => {
      connection.off('bondStateChange', handler);
    }, 'connection.bondStateChange');
  }

  static subscribeLegacyBleDeviceFind(handler: (results: Array<ble.ScanResult>) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      ble.on('BLEDeviceFind', handler);
    }, 'ble.BLEDeviceFind');
  }

  static unsubscribeLegacyBleDeviceFind(handler: (results: Array<ble.ScanResult>) => void): void {
    KitEventSubscription.unsubscribe(() => {
      ble.off('BLEDeviceFind', handler);
    }, 'ble.BLEDeviceFind');
  }

  static subscribeScannerBleDeviceFind(
    scanner: ble.BleScanner,
    handler: (report: ble.ScanReport) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      scanner.on('BLEDeviceFind', handler);
    }, 'bleScanner.BLEDeviceFind');
  }

  static unsubscribeScannerBleDeviceFind(
    scanner: ble.BleScanner,
    handler: (report: ble.ScanReport) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      scanner.off('BLEDeviceFind', handler);
    }, 'bleScanner.BLEDeviceFind');
  }

  static subscribeGattConnectionStateChange(
    client: ble.GattClientDevice,
    handler: (state: ble.BLEConnectionChangeState) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('BLEConnectionStateChange', handler);
    }, 'gatt.BLEConnectionStateChange');
  }

  static unsubscribeGattConnectionStateChange(
    client: ble.GattClientDevice,
    handler: (state: ble.BLEConnectionChangeState) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('BLEConnectionStateChange', handler);
    }, 'gatt.BLEConnectionStateChange');
  }

  static subscribeGattCharacteristicChange(
    client: ble.GattClientDevice,
    handler: (characteristic: ble.BLECharacteristic) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('BLECharacteristicChange', handler);
    }, 'gatt.BLECharacteristicChange');
  }

  static unsubscribeGattCharacteristicChange(
    client: ble.GattClientDevice,
    handler: (characteristic: ble.BLECharacteristic) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('BLECharacteristicChange', handler);
    }, 'gatt.BLECharacteristicChange');
  }

  static subscribeSppRead(
    clientSocket: number,
    handler: (data: ArrayBuffer) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      socket.on('sppRead', clientSocket, handler);
    }, 'socket.sppRead');
  }

  static unsubscribeSppRead(clientSocket: number, handler: (data: ArrayBuffer) => void): void {
    KitEventSubscription.unsubscribe(() => {
      socket.off('sppRead', clientSocket, handler);
    }, 'socket.sppRead');
  }

  static subscribeProfileConnectionStateChange(
    profile: baseProfile.BaseProfile,
    handler: (param: baseProfile.StateChangeParam) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      profile.on('connectionStateChange', handler);
    }, 'profile.connectionStateChange');
  }

  static unsubscribeProfileConnectionStateChange(
    profile: baseProfile.BaseProfile,
    handler?: (param: baseProfile.StateChangeParam) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      if (handler !== undefined) {
        profile.off('connectionStateChange', handler);
      } else {
        profile.off('connectionStateChange');
      }
    }, 'profile.connectionStateChange');
  }
}
