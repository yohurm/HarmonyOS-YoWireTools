import { ble } from '@kit.ConnectivityKit';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BleSerialEndpoints } from '../../domain/model/BleSerialPreset';

/**
 * Resolves BLE serial UART endpoints from platform GATT services.
 */
export class BleSerialPlatformMapper {
  static resolveNordicUart(services: Array<ble.GattService>): BleSerialEndpoints | undefined {
    return BleSerialPlatformMapper.resolveByUuids(
      services,
      BluetoothConstants.NORDIC_UART_SERVICE_UUID,
      BluetoothConstants.NORDIC_UART_RX_UUID,
      BluetoothConstants.NORDIC_UART_TX_UUID
    );
  }

  static autoDetectSerial(services: Array<ble.GattService>): BleSerialEndpoints | undefined {
    const nordic = BleSerialPlatformMapper.resolveNordicUart(services);
    if (nordic !== undefined) {
      return nordic;
    }
    for (let i = 0; i < services.length; i++) {
      const service = services[i];
      const rx = BleSerialPlatformMapper.detectWritableCandidate(service);
      const tx = BleSerialPlatformMapper.detectNotifyCandidate(service);
      if (rx !== undefined && tx !== undefined) {
        return new BleSerialEndpoints(
          service.serviceUuid,
          rx.characteristicUuid,
          tx.characteristicUuid
        );
      }
    }
    return undefined;
  }

  static resolveByUuids(
    services: Array<ble.GattService>,
    serviceUuid: string,
    rxUuid: string,
    txUuid: string
  ): BleSerialEndpoints | undefined {
    const normalizedService = serviceUuid.toUpperCase();
    const normalizedRx = rxUuid.toUpperCase();
    const normalizedTx = txUuid.toUpperCase();
    for (let i = 0; i < services.length; i++) {
      const service = services[i];
      if (service.serviceUuid.toUpperCase() !== normalizedService) {
        continue;
      }
      const characteristics = service.characteristics ?? [];
      let rxFound = false;
      let txFound = false;
      for (let j = 0; j < characteristics.length; j++) {
        const uuid = characteristics[j].characteristicUuid.toUpperCase();
        if (uuid === normalizedRx) {
          rxFound = true;
        }
        if (uuid === normalizedTx) {
          txFound = true;
        }
      }
      if (rxFound && txFound) {
        return new BleSerialEndpoints(serviceUuid, rxUuid, txUuid);
      }
    }
    return undefined;
  }

  private static detectWritableCandidate(service: ble.GattService): ble.BLECharacteristic | undefined {
    const characteristics = service.characteristics ?? [];
    for (let i = 0; i < characteristics.length; i++) {
      const item = characteristics[i];
      if (BleSerialPlatformMapper.canWrite(item)) {
        return item;
      }
    }
    return undefined;
  }

  private static detectNotifyCandidate(service: ble.GattService): ble.BLECharacteristic | undefined {
    const characteristics = service.characteristics ?? [];
    for (let i = 0; i < characteristics.length; i++) {
      const item = characteristics[i];
      if (BleSerialPlatformMapper.canNotify(item) || BleSerialPlatformMapper.canIndicate(item)) {
        return item;
      }
    }
    return undefined;
  }

  private static canWrite(item: ble.BLECharacteristic): boolean {
    return item.properties?.write === true || item.properties?.writeNoResponse === true;
  }

  private static canNotify(item: ble.BLECharacteristic): boolean {
    return item.properties?.notify === true;
  }

  private static canIndicate(item: ble.BLECharacteristic): boolean {
    return item.properties?.indicate === true;
  }
}
