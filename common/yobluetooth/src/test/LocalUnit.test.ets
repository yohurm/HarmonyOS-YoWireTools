import { describe, it, expect } from '@ohos/hypium';
import { BleManufacturerMaskMatcher } from '../main/ets/domain/service/BleManufacturerMaskMatcher';
import { GattWriteChunker } from '../main/ets/domain/service/GattWriteChunker';
import { ReconnectPolicy } from '../main/ets/domain/model/ReconnectPolicy';
import { GattPlatformMapper } from '../main/ets/data/mapper/GattPlatformMapper';
import { BleAdvertisingPlatformMapper } from '../main/ets/data/mapper/BleAdvertisingPlatformMapper';
import { BleAdStructureParser } from '../main/ets/domain/service/BleAdStructureParser';
import { DeviceNameSource } from '../main/ets/domain/model/BleAdvertisingPacket';
import { ScanResultMerger } from '../main/ets/domain/service/ScanResultMerger';
import { ClassicScanVisibilityPolicy, ConnectedSppLedgerRef } from '../main/ets/domain/service/ClassicScanVisibilityPolicy';
import { ClassicScanKeepAliveCollector } from '../main/ets/domain/service/ClassicScanKeepAliveCollector';
import { ClassicConnectedSnapshot } from '../main/ets/domain/model/ClassicConnectedSnapshot';
import { ClassicProfileCapability } from '../main/ets/domain/service/ClassicProfileCapability';
import { ClassicDeviceMajorFilter, ClassicScanFilter } from '../main/ets/domain/model/ClassicScanFilter';
import { ClassicScanCapability } from '../main/ets/domain/model/ClassicScanCapability';
import { SppSessionKey } from '../main/ets/domain/model/SppSessionKey';
import { SppLedgerPhase } from '../main/ets/domain/model/spp/SppLedgerPhase';
import { SppSessionLedger } from '../main/ets/domain/service/spp/SppSessionLedger';
import { SppSessionAdmissionPolicy } from '../main/ets/domain/service/spp/SppSessionAdmissionPolicy';
import { QuerySppConnectEligibilityUseCase } from '../main/ets/domain/usecase/classic/SppSessionQueryUseCases';
import { SppSessionCatalog } from '../main/ets/domain/service/spp/SppSessionCatalog';
import { asSppTransportFacet } from '../main/ets/domain/model/spp/ISppTransportFacet';
import { SppReadStrategy } from '../main/ets/domain/model/SppRuntimeState';
import { SppUuidLabel } from '../main/ets/domain/service/spp/SppUuidLabel';
import { BluetoothConstants } from '../main/ets/constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../main/ets/constants/BluetoothErrorCodes';
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

    it('ClassicProfileCapability_formats_labels', 0, () => {
      const text = ClassicProfileCapability.formatDisplayText([
        '00001101-0000-1000-8000-00805F9B34FB',
        '0000110B-0000-1000-8000-00805F9B34FB',
        '0000111E-0000-1000-8000-00805F9B34FB'
      ]);
      expect(text).assertEqual('SPP · A2DP · HFP');
      expect(ClassicProfileCapability.hasClassicHint([])).assertFalse();
      expect(ClassicProfileCapability.hasClassicHint([
        '00001101-0000-1000-8000-00805F9B34FB'
      ])).assertTrue();
      expect(ClassicScanCapability.LIST_RAIL).assertEqual(BluetoothListRail.CLASSIC_SCAN);
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
      const keepAlive = new Set<string>();
      expect(ClassicScanVisibilityPolicy.isVisibleInScanList(pairedOnly, keepAlive)).assertFalse();
      expect(ClassicScanVisibilityPolicy.isVisibleInScanList(live, keepAlive)).assertTrue();
    });

    it('ClassicScanVisibilityPolicy_keeps_connected_paired_without_broadcast', 0, () => {
      const connectedPaired = makeClassicDevice(
        'Connected Paired',
        'CC:CC:CC:CC:CC:CC',
        0,
        ClassicDeviceMajorFilter.PHONE as number,
        DiscoverySource.PAIRED,
        true
      );
      const keepAlive = new Set<string>(['CC:CC:CC:CC:CC:CC']);
      expect(ClassicScanVisibilityPolicy.isVisibleInScanList(connectedPaired, keepAlive)).assertTrue();
    });

    it('ClassicScanFilter_includeConnectedPaired_default_true', 0, () => {
      expect(ClassicScanFilter.empty().includeConnectedPaired).assertTrue();
      expect(ClassicScanFilter.empty().withIncludeConnectedPaired(false).includeConnectedPaired).assertFalse();
    });

    it('ClassicScanKeepAliveCollector_merges_profile_and_respects_switch', 0, () => {
      const platform = new ClassicConnectedSnapshot(['DD:DD:DD:DD:DD:DD'], 1, false);
      const on = ClassicScanKeepAliveCollector.collect(true, platform, [], [], (_id: string) => '');
      expect(on.addresses.has('DD:DD:DD:DD:DD:DD')).assertTrue();
      expect(on.profileCount).assertEqual(1);
      const off = ClassicScanKeepAliveCollector.collect(false, platform, [], [], (_id: string) => '');
      expect(off.addresses.size).assertEqual(0);
    });

    it('ClassicScanKeepAliveCollector_includes_connecting_ledger', 0, () => {
      const ledgerRefs = [
        new ConnectedSppLedgerRef('EE:EE:EE:EE:EE:EE', SppLedgerPhase.CONNECTING)
      ];
      const snap = ClassicScanKeepAliveCollector.collect(
        true,
        ClassicConnectedSnapshot.empty(),
        ledgerRefs,
        [],
        (_id: string) => ''
      );
      expect(snap.addresses.has('EE:EE:EE:EE:EE:EE')).assertTrue();
      expect(snap.sppConnectingCount).assertEqual(1);
    });

    it('ClassicScanVisibilityPolicy_sorts_keepalive_first', 0, () => {
      const live = makeClassicDevice(
        'Live',
        '11:11:11:11:11:11',
        -40,
        ClassicDeviceMajorFilter.AUDIO_VIDEO as number,
        DiscoverySource.DISCOVERY_RESULT,
        false
      );
      const connected = makeClassicDevice(
        'Connected',
        '22:22:22:22:22:22',
        0,
        ClassicDeviceMajorFilter.PHONE as number,
        DiscoverySource.PAIRED,
        true
      );
      const keepAlive = new Set<string>(['22:22:22:22:22:22']);
      const sorted = ClassicScanVisibilityPolicy.sortScanList([live, connected], keepAlive);
      expect(sorted.length).assertEqual(2);
      expect(sorted[0].primaryDeviceId).assertEqual('22:22:22:22:22:22');
      expect(sorted[1].primaryDeviceId).assertEqual('11:11:11:11:11:11');
    });

    it('ScanResultMerger_excludes_rssi_zero_without_active_session', 0, () => {
      const merger = new ScanResultMerger();
      merger.replaceAll([
        makeClassicDevice('Silent', '44:44:44:44:44:44', 0, ClassicDeviceMajorFilter.PHONE as number)
      ]);
      const filtered = merger.filter(new ClassicScanFilter('', '', -70), new Set());
      expect(filtered.length).assertEqual(0);
    });

    it('SppSessionKey_normalizes_uuid_and_composite', 0, () => {
      const key = SppSessionKey.fromParts('AA:BB:CC:DD:EE:FF', '00001101-0000-1000-8000-00805F9B34FB');
      expect(key.compositeKey()).assertEqual('AA:BB:CC:DD:EE:FF#00001101-0000-1000-8000-00805f9b34fb');
      expect(key.isValid()).assertTrue();
      const upper = SppSessionKey.fromParts('AA:BB:CC:DD:EE:FF', '00001101-0000-1000-8000-00805F9B34FB');
      const mixed = SppSessionKey.fromParts('AA:BB:CC:DD:EE:FF', '00001101-0000-1000-8000-00805f9b34fb');
      expect(upper.compositeKey()).assertEqual(mixed.compositeKey());
    });

    it('SppSessionKey_normalizes_mac_case_and_rejects_empty', 0, () => {
      const lower = SppSessionKey.fromParts('aa:bb:cc:dd:ee:ff', ' 00001101-0000-1000-8000-00805F9B34FB ');
      expect(lower.classicDeviceId).assertEqual('AA:BB:CC:DD:EE:FF');
      expect(lower.serviceUuid).assertEqual('00001101-0000-1000-8000-00805f9b34fb');
      expect(lower.compositeKey()).assertEqual(
        SppSessionKey.fromParts('AA:BB:CC:DD:EE:FF', BluetoothConstants.DEFAULT_SPP_UUID).compositeKey()
      );
      expect(SppSessionKey.fromParts('', BluetoothConstants.DEFAULT_SPP_UUID).isValid()).assertFalse();
      expect(SppSessionKey.fromParts('AA:BB:CC:DD:EE:FF', '').isValid()).assertFalse();
      expect(SppSessionKey.normalizeClassicId(' aa:bb ')).assertEqual('AA:BB');
      expect(SppSessionKey.normalizeUuid(' ABC ')).assertEqual('abc');
    });

    it('SppSessionLedger_reserve_duplicate_limit_release', 0, () => {
      const ledger = SppSessionLedger.getInstance();
      ledger.resetForTests();
      const keyA = SppSessionKey.fromParts('11:11:11:11:11:11', BluetoothConstants.DEFAULT_SPP_UUID);
      const keyB = SppSessionKey.fromParts('22:22:22:22:22:22', BluetoothConstants.DEFAULT_SPP_UUID);
      const keyC = SppSessionKey.fromParts('33:33:33:33:33:33', BluetoothConstants.DEFAULT_SPP_UUID);
      const keyD = SppSessionKey.fromParts('44:44:44:44:44:44', BluetoothConstants.DEFAULT_SPP_UUID);
      const keyE = SppSessionKey.fromParts('55:55:55:55:55:55', BluetoothConstants.DEFAULT_SPP_UUID);

      const reservedA = ledger.tryReserve(keyA, 'spp-a');
      expect(reservedA.success).assertTrue();
      expect(ledger.getActiveCount()).assertEqual(1);
      expect(ledger.hasKey(keyA)).assertTrue();
      expect(ledger.findBySessionId('spp-a')?.phase).assertEqual(SppLedgerPhase.RESERVED);

      const duplicate = ledger.tryReserve(keyA, 'spp-a2');
      expect(duplicate.success).assertFalse();
      expect(duplicate.error?.code).assertEqual(BluetoothErrorCodes.SPP_DUPLICATE_SESSION);

      expect(ledger.tryReserve(keyB, 'spp-b').success).assertTrue();
      expect(ledger.tryReserve(keyC, 'spp-c').success).assertTrue();
      expect(ledger.tryReserve(keyD, 'spp-d').success).assertTrue();
      expect(ledger.getActiveCount()).assertEqual(BluetoothConstants.SPP_MAX_SESSIONS);

      const limited = ledger.tryReserve(keyE, 'spp-e');
      expect(limited.success).assertFalse();
      expect(limited.error?.code).assertEqual(BluetoothErrorCodes.SPP_SESSION_LIMIT);

      ledger.markConnecting(keyA);
      ledger.promoteConnected(keyA, 42);
      expect(ledger.findBySessionId('spp-a')?.phase).assertEqual(SppLedgerPhase.CONNECTED);
      expect(ledger.findBySessionId('spp-a')?.clientSocket).assertEqual(42);

      ledger.markReconnecting(keyA);
      expect(ledger.hasKey(keyA)).assertTrue();
      expect(ledger.findBySessionId('spp-a')?.phase).assertEqual(SppLedgerPhase.RECONNECTING);
      expect(ledger.findBySessionId('spp-a')?.clientSocket).assertEqual(-1);

      ledger.release(keyA, 'test');
      expect(ledger.hasKey(keyA)).assertFalse();
      expect(ledger.getActiveCount()).assertEqual(3);
      expect(ledger.tryReserve(keyA, 'spp-a-again').success).assertTrue();
      ledger.resetForTests();
    });

    it('SppSessionLedger_failed_pair_lost_and_exhausted_release_slot', 0, () => {
      const ledger = SppSessionLedger.getInstance();
      ledger.resetForTests();
      const key = SppSessionKey.fromParts('66:66:66:66:66:66', BluetoothConstants.DEFAULT_SPP_UUID);
      expect(ledger.tryReserve(key, 'spp-fail').success).assertTrue();
      ledger.markConnecting(key);
      ledger.promoteConnected(key, 7);
      ledger.markReconnecting(key);
      expect(ledger.getActiveCount()).assertEqual(1);

      // Simulate pair-lost / reconnect-exhausted / FAILED: must free slot.
      ledger.release(key, 'pair lost');
      expect(ledger.hasKey(key)).assertFalse();
      expect(ledger.getActiveCount()).assertEqual(0);
      expect(ledger.findBySessionId('spp-fail') === undefined).assertTrue();

      expect(ledger.tryReserve(key, 'spp-retry').success).assertTrue();
      ledger.markClosing(key);
      expect(ledger.findBySessionId('spp-retry')?.phase).assertEqual(SppLedgerPhase.CLOSING);
      ledger.release(key, 'user_disconnect');
      expect(ledger.hasKey(key)).assertFalse();

      // Idempotent release
      ledger.release(key, 'again');
      expect(ledger.getActiveCount()).assertEqual(0);
      ledger.resetForTests();
    });

    it('SppSessionLedger_case_insensitive_key_collision', 0, () => {
      const ledger = SppSessionLedger.getInstance();
      ledger.resetForTests();
      const upper = SppSessionKey.fromParts('AA:BB:CC:DD:EE:01', '00001101-0000-1000-8000-00805F9B34FB');
      const lower = SppSessionKey.fromParts('aa:bb:cc:dd:ee:01', '00001101-0000-1000-8000-00805f9b34fb');
      expect(ledger.tryReserve(upper, 'spp-1').success).assertTrue();
      const dup = ledger.tryReserve(lower, 'spp-2');
      expect(dup.success).assertFalse();
      expect(dup.error?.code).assertEqual(BluetoothErrorCodes.SPP_DUPLICATE_SESSION);
      ledger.resetForTests();
    });

    it('SppSessionAdmissionPolicy_mirrors_ledger_eligibility', 0, () => {
      const ledger = SppSessionLedger.getInstance();
      ledger.resetForTests();
      const policy = new SppSessionAdmissionPolicy(ledger);
      const eligibility = new QuerySppConnectEligibilityUseCase(policy);
      const key = SppSessionKey.fromParts('77:77:77:77:77:77', BluetoothConstants.DEFAULT_SPP_UUID);

      expect(eligibility.execute('77:77:77:77:77:77').success).assertTrue();
      expect(eligibility.isKeyActive('77:77:77:77:77:77')).assertFalse();

      expect(ledger.tryReserve(key, 'spp-elig').success).assertTrue();
      const blocked = eligibility.execute('77:77:77:77:77:77');
      expect(blocked.success).assertFalse();
      expect(blocked.error?.code).assertEqual(BluetoothErrorCodes.SPP_DUPLICATE_SESSION);
      expect(eligibility.isKeyActive('aa:bb:cc:dd:ee:ff')).assertFalse();
      expect(eligibility.isKeyActive('77:77:77:77:77:77')).assertTrue();

      // Same normalization as Connect: mixed-case MAC still blocked.
      expect(eligibility.execute('77:77:77:77:77:77', '00001101-0000-1000-8000-00805F9B34FB').success)
        .assertFalse();

      ledger.release(key, 'test');
      expect(eligibility.execute('77:77:77:77:77:77').success).assertTrue();

      // Fill to limit via admission
      const keys: SppSessionKey[] = [
        SppSessionKey.fromParts('01:01:01:01:01:01', BluetoothConstants.DEFAULT_SPP_UUID),
        SppSessionKey.fromParts('02:02:02:02:02:02', BluetoothConstants.DEFAULT_SPP_UUID),
        SppSessionKey.fromParts('03:03:03:03:03:03', BluetoothConstants.DEFAULT_SPP_UUID),
        SppSessionKey.fromParts('04:04:04:04:04:04', BluetoothConstants.DEFAULT_SPP_UUID)
      ];
      for (let i = 0; i < keys.length; i++) {
        expect(ledger.tryReserve(keys[i], `spp-lim-${i}`).success).assertTrue();
      }
      const limited = eligibility.execute('05:05:05:05:05:05');
      expect(limited.success).assertFalse();
      expect(limited.error?.code).assertEqual(BluetoothErrorCodes.SPP_SESSION_LIMIT);
      expect(policy.getActiveCount()).assertEqual(BluetoothConstants.SPP_MAX_SESSIONS);
      ledger.resetForTests();
    });

    it('SppUuidLabel_formats_standard_spp', 0, () => {
      expect(SppUuidLabel.formatShort(BluetoothConstants.DEFAULT_SPP_UUID)).assertEqual('SPP');
      expect(SppUuidLabel.formatShort('6E400001-B5A3-F393-E0A9-E50E24DCCA9E')).assertEqual('6e400001');
    });

    it('SppSessionCatalog_shouldSurfaceSession_requires_ledger_key', 0, () => {
      const ledger = SppSessionLedger.getInstance();
      ledger.resetForTests();
      const key = SppSessionKey.fromParts('88:88:88:88:88:88', BluetoothConstants.DEFAULT_SPP_UUID);
      expect(SppSessionCatalog.shouldSurfaceSession(key, ledger)).assertFalse();
      expect(ledger.tryReserve(key, 'spp-obs').success).assertTrue();
      expect(SppSessionCatalog.shouldSurfaceSession(key, ledger)).assertTrue();
      ledger.release(key, 'observe_gate');
      expect(SppSessionCatalog.shouldSurfaceSession(key, ledger)).assertFalse();
      expect(SppSessionCatalog.shouldSurfaceSession(
        SppSessionKey.fromParts('', BluetoothConstants.DEFAULT_SPP_UUID),
        ledger
      )).assertFalse();
      ledger.resetForTests();
    });

    it('asSppTransportFacet_requires_spp_brand', 0, () => {
      expect(asSppTransportFacet(undefined) === undefined).assertTrue();
      expect(asSppTransportFacet({}) === undefined).assertTrue();
      const branded = new FakeSppFacet(
        SppSessionKey.fromParts('99:99:99:99:99:99', BluetoothConstants.DEFAULT_SPP_UUID)
      );
      const facet = asSppTransportFacet(branded);
      expect(facet !== undefined).assertTrue();
      expect(facet?.getClientSocketId()).assertEqual(9);
      expect(facet?.getSessionKey()?.classicDeviceId).assertEqual('99:99:99:99:99:99');
    });

    it('SppSessionLedger_bindSessionId_and_findBySessionId', 0, () => {
      const ledger = SppSessionLedger.getInstance();
      ledger.resetForTests();
      const key = SppSessionKey.fromParts('AA:00:00:00:00:01', BluetoothConstants.DEFAULT_SPP_UUID);
      expect(ledger.tryReserve(key, 'pending-id').success).assertTrue();
      ledger.bindSessionId(key, 'runtime-session-1');
      expect(ledger.findBySessionId('pending-id') === undefined).assertTrue();
      expect(ledger.findBySessionId('runtime-session-1')?.sessionKey.compositeKey())
        .assertEqual(key.compositeKey());
      ledger.release(key, 'test');
      expect(ledger.findBySessionId('runtime-session-1') === undefined).assertTrue();
      ledger.resetForTests();
    });
  });
}

class FakeSppFacet {
  readonly sppFacetBrand: 'spp' = 'spp';
  private readonly key: SppSessionKey;

  constructor(key: SppSessionKey) {
    this.key = key;
  }

  getSessionKey(): SppSessionKey | undefined {
    return this.key;
  }

  getClientSocketId(): number {
    return 9;
  }

  getReadStrategy(): SppReadStrategy {
    return SppReadStrategy.ASYNC_LOOP;
  }

  cancelReconnect(): void {
  }

  notifyFailed(_reason: string): void {
  }
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
