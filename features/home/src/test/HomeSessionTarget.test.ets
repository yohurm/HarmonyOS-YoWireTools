import { describe, it, expect } from '@ohos/hypium';
import { ModuleType, ProtocolType } from 'debug_core';
import { HomeSessionTarget } from '../main/ets/domain/HomeSessionTarget';

export default function homeSessionTargetTest() {
  describe('HomeSessionTarget', () => {
    it('routes_spp_and_classic_scan_to_spp_page', 0, () => {
      expect(HomeSessionTarget.resolve(ModuleType.BLUETOOTH, ProtocolType.SPP))
        .assertEqual(HomeSessionTarget.BLUETOOTH_SPP);
      expect(HomeSessionTarget.resolve(ModuleType.BLUETOOTH, ProtocolType.CLASSIC_SCAN))
        .assertEqual(HomeSessionTarget.BLUETOOTH_SPP);
    });

    it('routes_ble_protocols_to_ble_page', 0, () => {
      expect(HomeSessionTarget.resolve(ModuleType.BLUETOOTH, ProtocolType.BLE_SCAN))
        .assertEqual(HomeSessionTarget.BLUETOOTH_BLE);
      expect(HomeSessionTarget.resolve(ModuleType.BLUETOOTH, ProtocolType.BLE_GATT))
        .assertEqual(HomeSessionTarget.BLUETOOTH_BLE);
      expect(HomeSessionTarget.resolve(ModuleType.BLUETOOTH, ProtocolType.BLE_UART))
        .assertEqual(HomeSessionTarget.BLUETOOTH_BLE);
    });

    it('routes_other_bluetooth_sessions_to_overview', 0, () => {
      expect(HomeSessionTarget.resolve(ModuleType.BLUETOOTH, ProtocolType.NONE))
        .assertEqual(HomeSessionTarget.BLUETOOTH);
    });

    it('routes_wifi_and_nearlink_modules', 0, () => {
      expect(HomeSessionTarget.resolve(ModuleType.WIFI, ProtocolType.WIFI_SCAN))
        .assertEqual(HomeSessionTarget.WIFI);
      expect(HomeSessionTarget.resolve(ModuleType.NEARLINK, ProtocolType.SSAP))
        .assertEqual(HomeSessionTarget.NEARLINK);
    });

    it('hides_generated_scan_titles', 0, () => {
      expect(HomeSessionTarget.visibleTitle('WiFi Scan')).assertEqual('');
      expect(HomeSessionTarget.visibleTitle('NearLink Scan')).assertEqual('');
      expect(HomeSessionTarget.visibleTitle('BLE Scan')).assertEqual('');
      expect(HomeSessionTarget.visibleTitle('Classic Bluetooth Scan')).assertEqual('');
      expect(HomeSessionTarget.visibleTitle('SPP Meter')).assertEqual('SPP Meter');
    });

    it('returns_empty_for_unknown_module', 0, () => {
      expect(HomeSessionTarget.resolve(ModuleType.SYSTEM, ProtocolType.NONE)).assertEqual('');
      expect(HomeSessionTarget.resolve('unknown', ProtocolType.SPP)).assertEqual('');
    });
  });
}
