import { describe, it, expect } from '@ohos/hypium';
import { NearLinkAdvParser } from '../main/ets/domain/service/NearLinkAdvParser';
import { DeviceNameSource } from '../main/ets/domain/model/NearLinkAdvertisingPacket';
import { NearLinkConstants } from '../main/ets/constants/NearLinkConstants';

export default function nearLinkAdvParserTest() {
  describe('NearLinkAdvParser', () => {
    it('parses_complete_and_short_names', 0, () => {
      const bytes = new Uint8Array([
        0x0B, 0x06, 0x59, 0x6F, 0x57, 0x69, 0x72, 0x65,
        0x0A, 0x02, 0x4E, 0x4C
      ]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.completeLocalName).assertEqual('YoWire');
      expect(parsed.shortLocalName).assertEqual('NL');
      expect(parsed.nameSource).assertEqual(DeviceNameSource.COMPLETE);
    });

    it('expands_16_bit_uuid_on_the_alliance_base', 0, () => {
      const bytes = new Uint8Array([0x05, 0x02, 0x09, 0x06]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.serviceUuids.length).assertEqual(1);
      expect(parsed.serviceUuids[0]).assertEqual(`${NearLinkConstants.UUID_BASE_TAIL}0609`);
      expect(parsed.serviceUuids[0].indexOf('FFFFFFFF-1234-5678-ABCD') >= 0).assertFalse();
    });

    it('keeps_unknown_type_and_rejects_empty_payload', 0, () => {
      const parsed = NearLinkAdvParser.parseBytes(new Uint8Array([0x12, 0x01, 0xAB]));
      expect(parsed.unknownTlvs.length).assertEqual(1);
      expect(parsed.unknownTlvs[0].typeCode).assertEqual(0x12);
      expect(parsed.unknownTlvs[0].valueHex).assertEqual('AB');
      const empty = NearLinkAdvParser.parseRawData(new ArrayBuffer(0), 'reported');
      expect(empty.isEmpty).assertTrue();
      expect(empty.reportedDeviceName).assertEqual('reported');
    });

    it('records_device_info_name_byte_length', 0, () => {
      const bytes = new Uint8Array([
        0x03, 0x0B,
        0x09, 0x06,
        0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39
      ]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.deviceInfoNameByteLength).assertEqual(9);
    });

    it('marks_rssi_127_invalid', 0, () => {
      expect(NearLinkAdvParser.isRssiValid(127)).assertFalse();
      expect(NearLinkAdvParser.isRssiValid(-60)).assertTrue();
    });
  });
}
