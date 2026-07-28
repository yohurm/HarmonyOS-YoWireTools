import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BleSerialEndpoints } from '../../model/BleSerialPreset';
import { GattServiceNode, GattServiceTreeSnapshot } from '../../model/GattServiceTree';
import { ProfileMatchResult, SerialProfileId } from '../../model/uart/UartConnectPhase';

/**
 * Match discovered GATT services to known UART serial profiles (architecture bluetooth/04).
 * Nordic is P0; TI / Microchip / Telit are P1 auto-match when present.
 */
export class SerialProfileMatcher {
  match(tree: GattServiceTreeSnapshot): ProfileMatchResult {
    const nordic = this.matchNordic(tree.services);
    if (nordic !== undefined) {
      return ProfileMatchResult.ok(SerialProfileId.NORDIC_UART, nordic);
    }
    const ti = this.matchTi(tree.services);
    if (ti !== undefined) {
      return ProfileMatchResult.ok(SerialProfileId.TI_CC254X, ti);
    }
    return ProfileMatchResult.none('no serial profile found');
  }

  private matchNordic(services: GattServiceNode[]): BleSerialEndpoints | undefined {
    const service = this.findService(services, BluetoothConstants.NORDIC_UART_SERVICE_UUID);
    if (service === undefined) {
      return undefined;
    }
    const hasRx = this.hasCharacteristic(service, BluetoothConstants.NORDIC_UART_RX_UUID);
    const hasTx = this.hasCharacteristic(service, BluetoothConstants.NORDIC_UART_TX_UUID);
    if (!hasRx || !hasTx) {
      return undefined;
    }
    return new BleSerialEndpoints(
      BluetoothConstants.NORDIC_UART_SERVICE_UUID,
      BluetoothConstants.NORDIC_UART_RX_UUID,
      BluetoothConstants.NORDIC_UART_TX_UUID
    );
  }

  private matchTi(services: GattServiceNode[]): BleSerialEndpoints | undefined {
    const service = this.findService(services, BluetoothConstants.TI_UART_SERVICE_UUID);
    if (service === undefined) {
      return undefined;
    }
    if (!this.hasCharacteristic(service, BluetoothConstants.TI_UART_CHAR_UUID)) {
      return undefined;
    }
    return new BleSerialEndpoints(
      BluetoothConstants.TI_UART_SERVICE_UUID,
      BluetoothConstants.TI_UART_CHAR_UUID,
      BluetoothConstants.TI_UART_CHAR_UUID
    );
  }

  private findService(services: GattServiceNode[], uuid: string): GattServiceNode | undefined {
    const normalized = uuid.toUpperCase();
    for (let i = 0; i < services.length; i++) {
      if (services[i].serviceUuid.toUpperCase() === normalized) {
        return services[i];
      }
    }
    return undefined;
  }

  private hasCharacteristic(service: GattServiceNode, uuid: string): boolean {
    const normalized = uuid.toUpperCase();
    for (let i = 0; i < service.characteristics.length; i++) {
      if (service.characteristics[i].characteristicUuid.toUpperCase() === normalized) {
        return true;
      }
    }
    return false;
  }
}
