import { describe, it, expect } from '@ohos/hypium';
import { BleManufacturerMaskMatcher } from '../main/ets/domain/service/BleManufacturerMaskMatcher';
import { GattWriteChunker } from '../main/ets/domain/service/GattWriteChunker';
import { ReconnectPolicy } from '../main/ets/domain/model/ReconnectPolicy';
import { GattPlatformMapper } from '../main/ets/data/mapper/GattPlatformMapper';
import { BleAdvertisingPlatformMapper } from '../main/ets/data/mapper/BleAdvertisingPlatformMapper';
import { BleAdStructureParser } from '../main/ets/domain/service/BleAdStructureParser';
import { DeviceNameSource } from '../main/ets/domain/model/BleAdvertisingPacket';
import { ScanResultMerger } from '../main/ets/domain/service/ScanResultMerger';
import { ClassicScanVisibilityPolicy } from '../main/ets/domain/service/ClassicScanVisibilityPolicy';
import { ClassicDeviceMajorFilter, ClassicScanFilter } from '../main/ets/domain/model/ClassicScanFilter';
import { BluetoothDevice, BluetoothDeviceDraft } from '../main/ets/domain/model/BluetoothDevice';
import { DiscoverySource } from '../main/ets/domain/model/DiscoverySource';
import { BluetoothListRail, BluetoothTransportType } from '../main/ets/domain/model/BluetoothTransportType';
import { PayloadTextCodec } from 'debug_core';
import { PayloadEncoding } from 'debug_core';
import { DebugLogRecord, Direction, DisplayHint, LogRecordType, ModuleType, ProtocolType } from 'debug_core';
import { ble } from '@kit.ConnectivityKit';

export default function localUnitTest() {
  describe('BluetoothLocalUnitTest', () => {
    it('BleAdStructureParser_parses_local_name', 0, () => {
      const bytes = new Uint8Array([0x03, 0x01, 0x06, 0x06, 0x09, 0x54, 0x65, 0x73, 0x74]);
      const parsed = BleAdStructureParser.parse(bytes, false);
      expect(parsed.localName).assertEqual('Test');
      expect(parsed.nameSource).assertEqual(DeviceNameSource.ADV_LOCAL_NAME);
    });

    it('BleAdvertisingPlatformMapper_merges_scan_response_name', 0, () => {
      const result = {
        deviceId: 'AA:BB:CC:DD:EE:FF',
        rssi: -55,
        connectable: true,
        data: new Uint8Array([0x02, 0x01, 0x06]).buffer,
        scanResponse: new Uint8Array([0x05, 0x08, 0x41, 0x42, 0x43]).buffer
      } as ble.ScanResult;
      const packet = BleAdvertisingPlatformMapper.parse(result);
      expect(packet.bleDeviceId).assertEqual('AA:BB:CC:DD:EE:FF');
      expect(packet.localName).assertEqual('ABC');
      expect(packet.nameSource).assertEqual(DeviceNameSource.SCAN_RESPONSE);
    });

    it('BleManufacturerMaskMatcher_matches_masked_bytes', 0, () => {
      expect(BleManufacturerMaskMatcher.matches('aa bb cc', 'aa 00 00', 'ff 00 00')).assertTrue();
      expect(BleManufacturerMaskMatcher.matches('ab bb cc', 'aa 00 00', 'ff 00 00')).assertFalse();
    });

    it('GattWriteChunker_splits_by_mtu', 0, () => {
      const bytes = new Uint8Array(50);
      for (let i = 0; i < bytes.length; i++) {
        bytes[i] = i;
      }
      const chunks = GattWriteChunker.chunk(bytes, 23);
      expect(chunks.length).assertEqual(3);
      expect(chunks[0].length).assertEqual(20);
    });

    it('ReconnectPolicy_exponential_backoff', 0, () => {
      const policy = new ReconnectPolicy(5, 1000, 8000, 2);
      expect(policy.computeDelayMs(0)).assertEqual(1000);
      expect(policy.computeDelayMs(1)).assertEqual(2000);
      expect(policy.computeDelayMs(3)).assertEqual(8000);
    });

    it('GattPlatformMapper_maps_service_nodes', 0, () => {
      const characteristic: ble.BLECharacteristic = {
        serviceUuid: '0000180F-0000-1000-8000-00805F9B34FB',
        characteristicUuid: '00002A19-0000-1000-8000-00805F9B34FB',
        characteristicValue: new ArrayBuffer(1),
        descriptors: []
      };
      const service: ble.GattService = {
        serviceUuid: '0000180F-0000-1000-8000-00805F9B34FB',
        isPrimary: true,
        characteristics: [characteristic]
      };
      const nodes = GattPlatformMapper.fromPlatformServices([service]);
      expect(nodes.length).assertEqual(1);
      expect(nodes[0].characteristics.length).assertEqual(1);
    });

    it('PayloadTextCodec_spp_encoding_roundtrip', 0, () => {
      const encoded = PayloadTextCodec.encodeText('hello', PayloadEncoding.HEX);
      expect(encoded.success).assertTrue();
      const decoded = PayloadTextCodec.decodeText(encoded.value ?? '', PayloadEncoding.HEX);
      expect(decoded.success).assertTrue();
      expect(decoded.value).assertEqual('hello');
    });

    it('DebugLogRecord_payload_fidelity', 0, () => {
      const record = new DebugLogRecord(
        'log-1',
        'sess-1',
        ModuleType.BLUETOOTH,
        ProtocolType.SPP,
        Direction.INBOUND,
        LogRecordType.DATA,
        Date.now(),
        3,
        '010203',
        DisplayHint.HEX
      );
      expect(record.summary).assertEqual('010203');
      expect(record.payloadSize).assertEqual(3);
    });

    it('ScanResultMerger_filters_name_rssi_major', 0, () => {
      const merger = new ScanResultMerger();
      merger.replaceAll([
        makeClassicDevice('Speaker X', '11:11:11:11:11:11', -45, ClassicDeviceMajorFilter.AUDIO_VIDEO as number),
        makeClassicDevice('Phone Y', '22:22:22:22:22:22', -90, ClassicDeviceMajorFilter.PHONE as number),
        makeClassicDevice('Speaker Far', '33:33:33:33:33:33', -95, ClassicDeviceMajorFilter.AUDIO_VIDEO as number)
      ]);
      const filtered = merger.filter(new ClassicScanFilter(
        'Speaker',
        '',
        -70,
        ClassicDeviceMajorFilter.AUDIO_VIDEO
      ));
      expect(filtered.length).assertEqual(1);
      expect(filtered[0].classicDeviceId).assertEqual('11:11:11:11:11:11');
      expect(new ClassicScanFilter('a', '', -70).hasActiveConstraints()).assertTrue();
      expect(ClassicScanFilter.empty().hasActiveConstraints()).assertFalse();
    });

    it('ClassicScanVisibilityPolicy_hides_silent_paired_only', 0, () => {
      const pairedOnly = makeClassicDevice(
        'Paired Silent',
        'AA:AA:AA:AA:AA:AA',
        0,
        ClassicDeviceMajorFilter.PHONE as number,
        DiscoverySource.PAIRED,
        true
      );
      const live = makeClassicDevice(
        'Live Speaker',
        'BB:BB:BB:BB:BB:BB',
        -55,
        ClassicDeviceMajorFilter.AUDIO_VIDEO as number,
        DiscoverySource.DISCOVERY_RESULT,
        false
      );
      const activeAddresses = new Set<string>();
      expect(ClassicScanVisibilityPolicy.isVisibleInScanList(pairedOnly, activeAddresses)).assertFalse();
      expect(ClassicScanVisibilityPolicy.isVisibleInScanList(live, activeAddresses)).assertTrue();
    });

    it('ClassicScanVisibilityPolicy_keeps_active_session_without_broadcast', 0, () => {
      const pairedOnly = makeClassicDevice(
        'Connecting',
        'CC:CC:CC:CC:CC:CC',
        0,
        ClassicDeviceMajorFilter.PHONE as number,
        DiscoverySource.PAIRED,
        true
      );
      const activeAddresses = new Set<string>(['CC:CC:CC:CC:CC:CC']);
      expect(ClassicScanVisibilityPolicy.isVisibleInScanList(pairedOnly, activeAddresses)).assertTrue();
    });

    it('ScanResultMerger_excludes_rssi_zero_without_active_session', 0, () => {
      const merger = new ScanResultMerger();
      merger.replaceAll([
        makeClassicDevice('Silent', '44:44:44:44:44:44', 0, ClassicDeviceMajorFilter.PHONE as number)
      ]);
      const filtered = merger.filter(new ClassicScanFilter('', '', -70), new Set());
      expect(filtered.length).assertEqual(0);
    });
  });
}

function makeClassicDevice(
  name: string,
  address: string,
  rssi: number,
  majorClass: number,
  discoverySource: DiscoverySource = DiscoverySource.DISCOVERY_RESULT,
  paired: boolean = false
): BluetoothDevice {
  const draft = new BluetoothDeviceDraft();
  draft.primaryDeviceId = address;
  draft.classicDeviceId = address;
  draft.displayName = name;
  draft.rssi = rssi;
  draft.majorClass = majorClass;
  draft.transport = BluetoothTransportType.BR_EDR;
  draft.listRail = BluetoothListRail.CLASSIC_SCAN;
  draft.discoverySource = discoverySource;
  draft.paired = paired;
  return new BluetoothDevice(draft);
}
