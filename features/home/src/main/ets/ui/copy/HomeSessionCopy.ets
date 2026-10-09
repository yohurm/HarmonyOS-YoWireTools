import { ProtocolType } from 'debug_core';

export class HomeSessionCopy {
  static protocolLabel(protocol: string): ResourceStr {
    if (protocol === ProtocolType.SPP) {
      return $r('app.string.home_protocol_spp');
    }
    if (protocol === ProtocolType.CLASSIC_SCAN) {
      return $r('app.string.home_protocol_classic_scan');
    }
    if (protocol === ProtocolType.BLE_SCAN) {
      return $r('app.string.home_protocol_ble_scan');
    }
    if (protocol === ProtocolType.BLE_GATT) {
      return $r('app.string.home_protocol_ble_gatt');
    }
    if (protocol === ProtocolType.BLE_UART) {
      return $r('app.string.home_protocol_ble_uart');
    }
    if (protocol === ProtocolType.WIFI_SCAN) {
      return $r('app.string.home_protocol_wifi_scan');
    }
    if (protocol === ProtocolType.NEARLINK_SCAN) {
      return $r('app.string.home_protocol_nearlink_scan');
    }
    if (protocol === ProtocolType.SSAP) {
      return $r('app.string.home_protocol_ssap');
    }
    if (protocol === ProtocolType.DATA_TRANSFER) {
      return $r('app.string.home_protocol_data_transfer');
    }
    if (protocol === ProtocolType.TCP_CLIENT ||
      protocol === ProtocolType.TCP_SERVER ||
      protocol === ProtocolType.UDP ||
      protocol === ProtocolType.HTTP ||
      protocol === ProtocolType.WEBSOCKET ||
      protocol === ProtocolType.MQTT ||
      protocol === ProtocolType.NETWORK_DIAGNOSTICS) {
      return $r('app.string.home_protocol_network');
    }
    return $r('app.string.home_protocol_other');
  }
}
