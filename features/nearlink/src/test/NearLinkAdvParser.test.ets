import { describe, it, expect } from '@ohos/hypium';
import { NearLinkAdvParser } from '../main/ets/domain/service/NearLinkAdvParser';
import { DeviceNameSource } from '../main/ets/domain/model/NearLinkAdvertisingPacket';

export default function nearLinkAdvParserTest() {
  describe('NearLinkAdvParser', () => {
    it('parses_complete_name_tlv', 0, () => {
      const bytes = new Uint8Array([
        0x06, 0x09, 0x59, 0x6F, 0x57, 0x69, 0x72, 0x65
      ]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.localName).assertEqual('YoWire');
      expect(parsed.nameSource).assertEqual(DeviceNameSource.ADV_LOCAL_NAME);
    });

    it('parses_short_local_name_tlv', 0, () => {
      const bytes = new Uint8Array([
        0x04, 0x08, 0x4E, 0x4C
      ]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.localName).assertEqual('NL');
    });

    it('warns_on_tlv_overflow', 0, () => {
      const bytes = new Uint8Array([0xFF, 0x09, 0x01]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.parseWarnings.length > 0).assertTrue();
    });

    it('detects_invalid_rssi', 0, () => {
      expect(NearLinkAdvParser.isRssiValid(127)).assertFalse();
      expect(NearLinkAdvParser.isRssiValid(-60)).assertTrue();
    });
  });
}
