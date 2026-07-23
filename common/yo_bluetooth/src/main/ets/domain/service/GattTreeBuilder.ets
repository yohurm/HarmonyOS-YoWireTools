import {
  GattCharacteristicNode,
  GattServiceNode
} from '../model/GattServiceTree';

const CCCD_UUID = '00002902-0000-1000-8000-00805f9b34fb';

/**
 * Domain-only GATT service tree utilities (no platform types).
 */
export class GattTreeBuilder {
  static findCharacteristic(
    tree: GattServiceNode[],
    serviceUuid: string,
    characteristicUuid: string
  ): GattCharacteristicNode | undefined {
    for (let i = 0; i < tree.length; i++) {
      if (tree[i].serviceUuid.toUpperCase() !== serviceUuid.toUpperCase()) {
        continue;
      }
      for (let j = 0; j < tree[i].characteristics.length; j++) {
        const item = tree[i].characteristics[j];
        if (item.characteristicUuid.toUpperCase() === characteristicUuid.toUpperCase()) {
          return item;
        }
      }
    }
    return undefined;
  }

  static hasCccd(node: GattCharacteristicNode): boolean {
    for (let i = 0; i < node.descriptors.length; i++) {
      if (node.descriptors[i].descriptorUuid.toUpperCase() === CCCD_UUID) {
        return true;
      }
    }
    return false;
  }
}
