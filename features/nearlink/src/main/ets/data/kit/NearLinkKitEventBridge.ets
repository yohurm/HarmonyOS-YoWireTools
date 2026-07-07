import { manager, scan, ssap, dataTransfer } from '@kit.NearLinkKit';
import { Result } from 'common_core';
import { KitEventSubscription } from 'common_platform';

export class NearLinkKitEventBridge {
  static subscribeStateChange(handler: (state: manager.NearlinkState) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      manager.on('stateChange', handler);
    }, 'manager.stateChange');
  }

  static unsubscribeStateChange(handler: (state: manager.NearlinkState) => void): void {
    KitEventSubscription.unsubscribe(() => {
      manager.off('stateChange', handler);
    }, 'manager.stateChange');
  }

  static subscribeDeviceFound(handler: (results: scan.ScanResults[]) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      scan.on('deviceFound', handler);
    }, 'scan.deviceFound');
  }

  static unsubscribeDeviceFound(handler: (results: scan.ScanResults[]) => void): void {
    KitEventSubscription.unsubscribe(() => {
      scan.off('deviceFound', handler);
    }, 'scan.deviceFound');
  }

  static subscribeConnectionStateChange(
    client: ssap.Client,
    handler: (state: ssap.ConnectionChangeState) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('connectionStateChange', handler);
    }, 'ssap.connectionStateChange');
  }

  static unsubscribeConnectionStateChange(
    client: ssap.Client,
    handler: (state: ssap.ConnectionChangeState) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('connectionStateChange', handler);
    }, 'ssap.connectionStateChange');
  }

  static subscribePropertyChange(
    client: ssap.Client,
    handler: (property: ssap.Property) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('propertyChange', handler);
    }, 'ssap.propertyChange');
  }

  static unsubscribePropertyChange(
    client: ssap.Client,
    handler: (property: ssap.Property) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('propertyChange', handler);
    }, 'ssap.propertyChange');
  }

  static subscribeMtuChange(
    client: ssap.Client,
    handler: (mtu: number) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      client.on('mtuChange', handler);
    }, 'ssap.mtuChange');
  }

  static unsubscribeMtuChange(client: ssap.Client, handler: (mtu: number) => void): void {
    KitEventSubscription.unsubscribe(() => {
      client.off('mtuChange', handler);
    }, 'ssap.mtuChange');
  }

  static subscribeDataTransferConnectionState(
    handler: (state: dataTransfer.ConnectionResult) => void
  ): Result<void> {
    return KitEventSubscription.subscribe(() => {
      dataTransfer.on('connectionStateChanged', handler);
    }, 'dataTransfer.connectionStateChanged');
  }

  static unsubscribeDataTransferConnectionState(
    handler: (state: dataTransfer.ConnectionResult) => void
  ): void {
    KitEventSubscription.unsubscribe(() => {
      dataTransfer.off('connectionStateChanged', handler);
    }, 'dataTransfer.connectionStateChanged');
  }

  static subscribeReadData(handler: (payload: dataTransfer.DataParams) => void): Result<void> {
    return KitEventSubscription.subscribe(() => {
      dataTransfer.on('readData', handler);
    }, 'dataTransfer.readData');
  }

  static unsubscribeReadData(handler: (payload: dataTransfer.DataParams) => void): void {
    KitEventSubscription.unsubscribe(() => {
      dataTransfer.off('readData', handler);
    }, 'dataTransfer.readData');
  }
}
