import { describe, it, expect } from '@ohos/hypium';
import { NearLinkScanFilter, NearLinkScanMode } from '../main/ets/domain/model/NearLinkScanFilter';
import { NearLinkErrorCodes } from '../main/ets/constants/NearLinkErrorCodes';
import { NearLinkAdvParser } from '../main/ets/domain/service/NearLinkAdvParser';
import { NearLinkExtendedUseCases } from '../main/ets/domain/usecase/NearLinkExtendedUseCases';
import { DeviceNameSource } from '../main/ets/domain/model/NearLinkAdvertisingPacket';

export default function localUnitTest() {
  describe('NearLinkLocalUnitTest', () => {
    it('NearLinkScanFilter_rejects_empty_without_null_flag', 0, () => {
      const filter = new NearLinkScanFilter();
      const validated = filter.validate();
      expect(validated.success).assertFalse();
      expect(validated.error?.code).assertEqual(NearLinkErrorCodes.EMPTY_FILTER);
    });

    it('NearLinkScanFilter_rejects_mask_length_mismatch', 0, () => {
      const filter = new NearLinkScanFilter('', '', 1, 'aabb', 'aa');
      const validated = filter.validate();
      expect(validated.success).assertFalse();
      expect(validated.error?.code).assertEqual(NearLinkErrorCodes.MASK_LENGTH_MISMATCH);
    });

    it('NearLinkScanFilter_matches_post_filter_rssi_and_name', 0, () => {
      const filter = new NearLinkScanFilter('', 'Yo', -1, '', '', false, NearLinkScanMode.BALANCED, 0, -50);
      expect(filter.matchesPostFilter('YoWire Device', -40, true)).assertTrue();
      expect(filter.matchesPostFilter('Other', -40, true)).assertFalse();
      expect(filter.matchesPostFilter('YoWire', -80, true)).assertFalse();
    });

    it('NearLinkAdvParser_hex_roundtrip_via_usecase', 0, () => {
      const bytes = NearLinkExtendedUseCases.hexToBytes('59 6F');
      expect(bytes.length).assertEqual(2);
      expect(bytes[0]).assertEqual(0x59);
      expect(NearLinkAdvParser.toHex(bytes)).assertEqual('596F');
    });

    it('NearLinkAdvParser_parses_complete_name', 0, () => {
      const bytes = new Uint8Array([0x06, 0x09, 0x59, 0x6F, 0x57, 0x69, 0x72, 0x65]);
      const parsed = NearLinkAdvParser.parseBytes(bytes);
      expect(parsed.localName).assertEqual('YoWire');
      expect(parsed.nameSource).assertEqual(DeviceNameSource.ADV_LOCAL_NAME);
    });
  });
}
