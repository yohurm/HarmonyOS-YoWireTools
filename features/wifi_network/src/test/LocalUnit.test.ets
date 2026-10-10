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
import { WifiScanSource } from '../main/ets/domain/model/WifiScanState';
import { WifiScanListPolicy } from '../main/ets/domain/service/WifiScanListPolicy';
import { WifiCandidateRules } from '../main/ets/domain/service/WifiCandidateRules';
import { WifiChannelOccupancy } from '../main/ets/domain/service/WifiChannelOccupancy';
import { WifiFieldLabels } from '../main/ets/domain/service/WifiFieldLabels';
import { WifiDistanceEstimator } from '../main/ets/domain/service/WifiDistanceEstimator';
import { WifiCandidateDraft, WifiChannelOccupancyRow } from '../main/ets/domain/model/WifiDebugFacts';

function accessPoint(
  id: string,
  ssid: string,
  bssid: string,
  rssi: number,
  level: number,
  band: number,
  frequency: number,
  security: string
): WifiAccessPointSnapshot {
  return new WifiAccessPointSnapshot(
    id, ssid, bssid, false, '', rssi, level, band, frequency, 0, security, WifiScanSource.CACHE, 1
  );
}

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

    it('WifiChannelCalculator_more_bands', 0, () => {
      expect(WifiChannelCalculator.fromFrequency(2412)).assertEqual(1);
      expect(WifiChannelCalculator.fromFrequency(2484)).assertEqual(Math.round((2484 - 2407) / 5));
      expect(WifiChannelCalculator.fromChannel24(14)).assertEqual(2484);
      expect(WifiChannelCalculator.fromFrequency(5955)).assertEqual(1);
      expect(WifiChannelCalculator.bandLabel(3)).assertEqual('6GHz');
    });

    it('WifiScanCooldownTracker_background_window', 0, () => {
      const tracker = new WifiScanCooldownTracker();
      const now = 1700000000000;
      expect(tracker.canScanInBackground(now)).assertTrue();
      tracker.recordBackgroundScan(now);
      expect(tracker.canScanInBackground(now + 1000)).assertFalse();
      expect(tracker.canScanInBackground(now + WifiNetworkConstants.BACKGROUND_SCAN_WINDOW_MS)).assertTrue();
      expect(tracker.remainingCooldownMs(now)).assertEqual(0);
    });

    it('WifiScanListPolicy_filter_and_sort', 0, () => {
      const home = accessPoint('a', 'Home', 'aa', -40, 4, 1, 2412, 'PSK');
      const guest = accessPoint('b', 'Guest', 'bb', -70, 2, 2, 5180, 'SAE');
      const filtered = WifiScanListPolicy.filter([home, guest], 'Ho', 4, 'PSK', 1);
      expect(filtered.length).assertEqual(1);
      expect(filtered[0].ssid).assertEqual('Home');
      const sorted = WifiScanListPolicy.sortByRssiDesc([guest, home]);
      expect(sorted[0].ssid).assertEqual('Home');
      expect(sorted[1].ssid).assertEqual('Guest');
    });

    it('WifiCandidateRules_validation', 0, () => {
      const wep = new WifiCandidateDraft('n', 'k', 'WEP', false, '', '', false, -1);
      expect(WifiCandidateRules.validate(wep)?.message).assertEqual('候选配置不支持 WEP');
      const openKey = new WifiCandidateDraft('n', 'secret', 'OPEN', false, '', '', false, -1);
      expect(WifiCandidateRules.validate(openKey)?.message).assertEqual('开放网络密钥必须为空');
      const openOk = new WifiCandidateDraft('n', '', 'OPEN', false, '', '', false, -1);
      expect(WifiCandidateRules.validate(openOk) === undefined).assertTrue();
      const shortPsk = new WifiCandidateDraft('n', '1234567', 'PSK', false, '', '', false, -1);
      expect(WifiCandidateRules.validate(shortPsk)?.message).assertEqual('PSK 密钥最短 8 字节');
      const emptySae = new WifiCandidateDraft('n', '', 'SAE', false, '', '', false, -1);
      expect(WifiCandidateRules.validate(emptySae)?.message).assertEqual('SAE 密钥至少 1 字节');
      const emptyEap = new WifiCandidateDraft('n', '', 'EAP', false, '', '', false, -1);
      expect(WifiCandidateRules.validate(emptyEap)?.message).assertEqual('身份或密码为空');
      const badAction = new WifiCandidateDraft('n', '12345678', 'PSK', false, '', '', true, -1);
      const rejected = WifiCandidateRules.validate(badAction);
      expect(rejected?.message).assertEqual('参数无效');
      expect(rejected?.nativeCode).assertEqual(WifiNetworkConstants.NATIVE_PARAM_INVALID);
      expect(WifiCandidateRules.maskSecret('secret')).assertEqual('********');
    });

    it('WifiChannelOccupancy_excludes_connected_and_recommends_quiet', 0, () => {
      const connected = accessPoint('c', 'Home', 'aa:bb', -30, 4, 1, 2412, 'PSK');
      const other = accessPoint('d', 'Other', 'cc:dd', -80, 1, 1, 2412, 'PSK');
      const rows = WifiChannelOccupancy.rate([connected, other], 'aa:bb');
      expect(rows[0].strongestRssi).assertEqual(-80);
      expect(rows[0].intensity > WifiChannelOccupancy.RECOMMEND_MAX_INTENSITY).assertTrue();
      const quiet = new WifiChannelOccupancyRow(6, 0, 0, 0);
      const loud = new WifiChannelOccupancyRow(1, 2, -80, 2);
      const recommended = WifiChannelOccupancy.recommend([quiet, loud]);
      expect(recommended.length).assertEqual(1);
      expect(recommended[0].channel).assertEqual(6);
    });

    it('WifiFieldLabels_errors_and_ipv4', 0, () => {
      expect(WifiFieldLabels.errorSentence('201', 'denied')).assertEqual('权限被拒绝');
      expect(WifiFieldLabels.errorSentence('801', 'missing')).assertEqual('本机不支持');
      expect(WifiFieldLabels.errorSentence('2501000', 'fail')).assertEqual('操作失败');
      expect(WifiFieldLabels.errorSentence('2501001', 'sta')).assertEqual('STA 未打开');
      expect(WifiFieldLabels.errorSentence('2501005', 'wait')).assertEqual('用户未响应');
      expect(WifiFieldLabels.errorSentence('2501006', 'no')).assertEqual('用户拒绝');
      expect(WifiFieldLabels.errorSentence('2501007', 'bad')).assertEqual('参数无效');
      expect(WifiFieldLabels.errorSentence('', 'moving freeze state')).assertEqual('静止管控');
      expect(WifiFieldLabels.ipv4Text(0)).assertEqual(WifiNetworkConstants.NOT_OBTAINED);
      expect(WifiFieldLabels.ipv4Text(0x0100007f)).assertEqual('127.0.0.1');
    });

    it('WifiDistanceEstimator_zero_frequency', 0, () => {
      expect(WifiDistanceEstimator.meters(-50, 0)).assertEqual(0);
    });
  });
}
