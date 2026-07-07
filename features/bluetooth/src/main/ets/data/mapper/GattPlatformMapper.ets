import { ble } from '@kit.ConnectivityKit';
import {
  GattCharacteristicNode,
  GattDescriptorNode,
  GattNotifyState,
  GattServiceNode
} from '../../domain/model/GattServiceTree';
import { GattCharacteristicRef, GattDescriptorRef } from '../../domain/model/GattCharacteristicRef';

/**
 * Maps ConnectivityKit GATT types to domain models.
 */
export class GattPlatformMapper {
  static fromPlatformServices(services: Array<ble.GattService>): GattServiceNode[] {
    const nodes: GattServiceNode[] = [];
    for (let i = 0; i < services.length; i++) {
      nodes.push(GattPlatformMapper.fromService(services[i]));
    }
    return nodes;
  }

  static toCharacteristicRef(item: ble.BLECharacteristic): GattCharacteristicRef {
    return new GattCharacteristicRef(
      item.serviceUuid,
      item.characteristicUuid,
      GattPlatformMapper.inferProperties(item)
    );
  }

  static toDescriptorRef(item: ble.BLEDescriptor): GattDescriptorRef {
    return new GattDescriptorRef(item.serviceUuid, item.characteristicUuid, item.descriptorUuid);
  }

  static valueToHex(value: ArrayBuffer | undefined): string {
    if (value === undefined) {
      return '';
    }
    const bytes = new Uint8Array(value);
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join(' ');
  }

  private static fromService(service: ble.GattService): GattServiceNode {
    const characteristics: GattCharacteristicNode[] = [];
    const chars = service.characteristics ?? [];
    for (let i = 0; i < chars.length; i++) {
      characteristics.push(GattPlatformMapper.fromCharacteristic(service.serviceUuid, chars[i]));
    }
    return new GattServiceNode(service.serviceUuid, service.isPrimary ?? true, characteristics, []);
  }

  private static fromCharacteristic(serviceUuid: string, item: ble.BLECharacteristic): GattCharacteristicNode {
    const descriptors: GattDescriptorNode[] = [];
    const descList = item.descriptors ?? [];
    for (let i = 0; i < descList.length; i++) {
      const desc = descList[i];
      descriptors.push(new GattDescriptorNode(
        serviceUuid,
        item.characteristicUuid,
        desc.descriptorUuid,
        [],
        GattPlatformMapper.valueToHex(desc.descriptorValue)
      ));
    }
    const properties = GattPlatformMapper.inferProperties(item);
    return new GattCharacteristicNode(
      serviceUuid,
      item.characteristicUuid,
      properties,
      [],
      descriptors,
      GattNotifyState.DISABLED,
      GattPlatformMapper.valueToHex(item.characteristicValue)
    );
  }

  private static inferProperties(item: ble.BLECharacteristic): string[] {
    const props: string[] = [];
    if (item.properties !== undefined) {
      const p = item.properties;
      if (p.read) {
        props.push('read');
      }
      if (p.write) {
        props.push('write');
      }
      if (p.writeNoResponse) {
        props.push('writeNoResponse');
      }
      if (p.notify) {
        props.push('notify');
      }
      if (p.indicate) {
        props.push('indicate');
      }
    }
    return props;
  }
}
