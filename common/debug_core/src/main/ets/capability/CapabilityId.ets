import { ModuleType } from '../domain/enums/DomainEnums';

/**
 * Product capability identifiers (19 items per architecture §8.1).
 */
export class CapabilityId {
  static readonly BLUETOOTH_ADAPTER_STATE: string = 'bluetooth.adapter.state';
  static readonly BLUETOOTH_CLASSIC_DISCOVERY: string = 'bluetooth.classic.discovery';
  static readonly BLUETOOTH_SPP_CLIENT: string = 'bluetooth.spp.client';
  static readonly BLUETOOTH_SPP_SERVER: string = 'bluetooth.spp.server';
  static readonly BLUETOOTH_BLE_SCAN: string = 'bluetooth.ble.scan';
  static readonly BLUETOOTH_BLE_GATT_CLIENT: string = 'bluetooth.ble.gatt.client';
  static readonly BLUETOOTH_BLE_MTU: string = 'bluetooth.ble.mtu';
  static readonly WIFI_SCAN: string = 'wifi.scan';
  static readonly WIFI_LINKED_INFO: string = 'wifi.linked.info';
  static readonly NETWORK_TCP_CLIENT: string = 'network.tcp.client';
  static readonly NETWORK_TCP_SERVER: string = 'network.tcp.server';
  static readonly NETWORK_UDP: string = 'network.udp';
  static readonly NETWORK_HTTP: string = 'network.http';
  static readonly NETWORK_WEBSOCKET_CLIENT: string = 'network.websocket.client';
  static readonly NETWORK_WEBSOCKET_SERVER: string = 'network.websocket.server';
  static readonly NEARLINK_SUPPORTED: string = 'nearlink.supported';
  static readonly NEARLINK_SCAN: string = 'nearlink.scan';
  static readonly NEARLINK_SSAP_CLIENT: string = 'nearlink.ssap.client';
  static readonly NEARLINK_DATA_TRANSFER: string = 'nearlink.data_transfer';

  static all(): string[] {
    return [
      CapabilityId.BLUETOOTH_ADAPTER_STATE,
      CapabilityId.BLUETOOTH_CLASSIC_DISCOVERY,
      CapabilityId.BLUETOOTH_SPP_CLIENT,
      CapabilityId.BLUETOOTH_SPP_SERVER,
      CapabilityId.BLUETOOTH_BLE_SCAN,
      CapabilityId.BLUETOOTH_BLE_GATT_CLIENT,
      CapabilityId.BLUETOOTH_BLE_MTU,
      CapabilityId.WIFI_SCAN,
      CapabilityId.WIFI_LINKED_INFO,
      CapabilityId.NETWORK_TCP_CLIENT,
      CapabilityId.NETWORK_TCP_SERVER,
      CapabilityId.NETWORK_UDP,
      CapabilityId.NETWORK_HTTP,
      CapabilityId.NETWORK_WEBSOCKET_CLIENT,
      CapabilityId.NETWORK_WEBSOCKET_SERVER,
      CapabilityId.NEARLINK_SUPPORTED,
      CapabilityId.NEARLINK_SCAN,
      CapabilityId.NEARLINK_SSAP_CLIENT,
      CapabilityId.NEARLINK_DATA_TRANSFER
    ];
  }

  static moduleOf(capabilityId: string): ModuleType {
    if (capabilityId.startsWith('bluetooth.')) {
      return ModuleType.BLUETOOTH;
    }
    if (capabilityId.startsWith('wifi.') || capabilityId.startsWith('network.')) {
      return ModuleType.WIFI;
    }
    if (capabilityId.startsWith('nearlink.')) {
      return ModuleType.NEARLINK;
    }
    return ModuleType.SYSTEM;
  }
}
