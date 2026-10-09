import { describe, it, expect } from '@ohos/hypium';
import { WifiChannelCalculator } from '../main/ets/domain/service/WifiChannelCalculator';
import { WifiScanCooldownTracker } from '../main/ets/domain/service/WifiScanCooldownTracker';
import { PrivateNetworkGuard } from '../main/ets/domain/service/PrivateNetworkGuard';
import { CidrAddressGenerator } from '../main/ets/domain/service/CidrAddressGenerator';
import { HttpHeaderSanitizer } from '../main/ets/domain/service/HttpHeaderSanitizer';
import { WifiAccessPointSnapshot } from '../main/ets/domain/model/WifiAccessPointSnapshot';
import { BssidMaskReason } from '../main/ets/domain/model/WifiScanState';
import { WifiNetworkConstants } from '../main/ets/constants/WifiNetworkConstants';
import { WifiNetworkDeviceVerificationChecklist } from '../main/ets/data/verification/WifiNetworkDeviceVerificationChecklist';
import { MqttWireCodec } from '../main/ets/domain/service/MqttWireCodec';
import { HttpRequestTemplateCodec } from '../main/ets/domain/service/HttpRequestTemplateCodec';
import { SsdpUrlParser } from '../main/ets/domain/service/SsdpUrlParser';
import { HttpRequestDraft, KeyValueParam } from '../main/ets/domain/model/HttpModels';

export default function localUnitTest() {
  describe('WifiNetworkLocalUnitTest', () => {
    it('WifiChannelCalculator_2g4_channel', 0, () => {
      expect(WifiChannelCalculator.fromFrequency(2437)).assertEqual(6);
      expect(WifiChannelCalculator.bandLabel(1)).assertEqual('2.4GHz');
    });

    it('WifiChannelCalculator_5g_channel', 0, () => {
      expect(WifiChannelCalculator.fromFrequency(5180)).assertEqual(36);
      expect(WifiChannelCalculator.bandLabel(2)).assertEqual('5GHz');
    });

    it('WifiScanCooldownTracker_limits', 0, () => {
      const tracker = new WifiScanCooldownTracker();
      const now = Date.now();
      tracker.recordScan(now);
      expect(tracker.canScanNow(now + 1000)).assertTrue();
      tracker.recordScan(now + 1000);
      tracker.recordScan(now + 2000);
      tracker.recordScan(now + 3000);
      expect(tracker.canScanNow(now + 4000)).assertFalse();
      expect(tracker.remainingCooldownMs(now + 4000)).assertLarger(0);
    });

    it('PrivateNetworkGuard_private_ip', 0, () => {
      expect(PrivateNetworkGuard.isPrivateIpv4('192.168.1.1')).assertTrue();
      expect(PrivateNetworkGuard.isPrivateIpv4('8.8.8.8')).assertFalse();
      expect(PrivateNetworkGuard.isPrivateCidr('192.168.0.0/24')).assertTrue();
    });

    it('PrivateNetworkGuard_large_range', 0, () => {
      expect(PrivateNetworkGuard.isLargeRange(1, 1000)).assertTrue();
      expect(PrivateNetworkGuard.portRangeSize(80, 90)).assertEqual(11);
    });

    it('CidrAddressGenerator_hosts', 0, () => {
      const hosts = CidrAddressGenerator.listHosts('192.168.1.0/24', 10);
      expect(hosts.length).assertEqual(10);
      expect(hosts[0]).assertEqual('192.168.1.1');
    });

    it('HttpHeaderSanitizer_masks_auth', 0, () => {
      const sanitized = HttpHeaderSanitizer.sanitize({ 'Authorization': 'Bearer secret', 'Accept': 'json' });
      expect(sanitized['Authorization']).assertEqual('***');
      expect(sanitized['Accept']).assertEqual('json');
    });

    it('WifiAccessPointSnapshot_masked_bssid', 0, () => {
      const masked = WifiAccessPointSnapshot.maskedBssid('AA:BB:CC:DD:EE:FF', false, BssidMaskReason.PERMISSION_DENIED);
      expect(masked).assertEqual('');
    });

    it('WifiNetworkConstants_defaults', 0, () => {
      expect(WifiNetworkConstants.FOREGROUND_SCAN_MAX_COUNT).assertEqual(4);
      expect(WifiNetworkConstants.DEFAULT_PORT_SCAN_CONCURRENCY).assertEqual(32);
    });

    it('VerificationChecklist_has_items', 0, () => {
      const items = WifiNetworkDeviceVerificationChecklist.listAll();
      expect(items.length).assertLarger(10);
    });

    it('MqttWireCodec_connect_packet', 0, () => {
      const packet = MqttWireCodec.buildConnect('client-1');
      expect(packet.length).assertLarger(10);
      expect(packet[0]).assertEqual(0x10);
    });

    it('MqttWireCodec_publish_packet', 0, () => {
      const packet = MqttWireCodec.buildPublish('test/topic', 'hello');
      expect(packet[0]).assertEqual(0x30);
    });

    it('HttpRequestTemplateCodec_roundtrip', 0, () => {
      const draft = new HttpRequestDraft('t1', 'GET', 'https://example.com', [], [new KeyValueParam('Accept', 'json')]);
      const record = HttpRequestTemplateCodec.toTemplateRecord('t1', 'demo', draft);
      const loaded = HttpRequestTemplateCodec.fromTemplateRecord(record);
      expect(loaded).assertNotUndefined();
      expect(loaded?.method).assertEqual('GET');
    });

    it('HttpRequestTemplateCodec_exportExchange_json', 0, () => {
      const draft = new HttpRequestDraft('t1', 'POST', 'https://example.com/api', [], [], '{"ok":true}');
      const exported = HttpRequestTemplateCodec.exportExchange(draft);
      const parsed = JSON.parse(exported) as Record<string, Object>;
      expect(parsed['method']).assertEqual('POST');
      expect(parsed['requestBodyLength']).assertEqual(10);
    });

    it('SsdpUrlParser_parse_location', 0, () => {
      const parsed = SsdpUrlParser.parseUrl('http://192.168.1.10:8080/desc.xml');
      expect(parsed).assertNotUndefined();
      expect(parsed?.host).assertEqual('192.168.1.10');
      expect(parsed?.port).assertEqual(8080);
    });

    it('SsdpUrlParser_header_value', 0, () => {
      const text = 'HTTP/1.1 200 OK\r\nLOCATION: http://device.local/\r\n\r\n';
      expect(SsdpUrlParser.headerValue(text, 'LOCATION')).assertEqual('http://device.local/');
    });
  });
}
