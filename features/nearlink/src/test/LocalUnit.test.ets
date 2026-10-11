import { describe, it, expect } from '@ohos/hypium';
import { NearLinkConstants } from '../main/ets/constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../main/ets/constants/NearLinkErrorCodes';
import { NearLinkScanFilter, NearLinkScanMode, NearLinkSystemFilter } from '../main/ets/domain/model/NearLinkScanFilter';
import { NearLinkGap } from '../main/ets/domain/model/NearLinkScreenCategory';
import { NearLinkLogEntry } from '../main/ets/domain/model/NearLinkLogEntry';
import {
  NearLinkGapFacts,
  NearLinkLogBook,
  NearLinkPairedPresentation,
  NearLinkReasonPolicy,
  NearLinkSlicePlan
} from '../main/ets/domain/service/NearLinkDebugRules';
import { NearLinkScanForm } from '../main/ets/domain/service/NearLinkScanForm';
import { NearLinkPayloadRules, NearLinkScanPolicy } from '../main/ets/domain/service/NearLinkScanPolicy';
import { NearLinkScreenRules } from '../main/ets/domain/service/NearLinkScreenRules';

export default function localUnitTest() {
  describe('NearLinkLocalUnitTest', () => {
    it('rejects_empty_filter_with_401', 0, () => {
      const filter = new NearLinkScanFilter();
      const validated = filter.validate();
      expect(validated.success).assertFalse();
      expect(validated.error?.code).assertEqual(NearLinkErrorCodes.EMPTY_FILTER);
      expect(validated.error?.nativeCode).assertEqual(`${NearLinkConstants.NATIVE_INVALID}`);
    });

    it('accepts_named_filter', 0, () => {
      const filter = NearLinkScanFilter.named('YoWire');
      expect(filter.validate().success).assertTrue();
      expect(filter.scanMode).assertEqual(NearLinkScanMode.LOW_POWER);
    });

    it('rejects_duration_and_name_and_manufacturer', 0, () => {
      const duration = new NearLinkScanFilter([new NearLinkSystemFilter('', 'Yo')], NearLinkScanMode.LOW_POWER, 9);
      expect(duration.validate().error?.code).assertEqual(NearLinkErrorCodes.DURATION_RANGE);
      const named = new NearLinkScanFilter([new NearLinkSystemFilter('', '1234567890123456789012345678901')]);
      expect(named.validate().error?.code).assertEqual(NearLinkErrorCodes.NAME_LENGTH);
      const maker = new NearLinkScanFilter([new NearLinkSystemFilter('', '', 0, 'aa')]);
      expect(maker.validate().error?.code).assertEqual(NearLinkErrorCodes.MANUFACTURER_ID_RANGE);
      const mask = new NearLinkScanFilter([new NearLinkSystemFilter('', '', 1, 'aabb', 'aa')]);
      expect(mask.validate().error?.code).assertEqual(NearLinkErrorCodes.MASK_LENGTH_MISMATCH);
    });

    it('keeps_local_rssi_off_the_system_filter_below_26', 0, () => {
      const filter = NearLinkScanForm.toFilter('11:22', 'Yo', '', '', '', '-70', false,
        NearLinkScanMode.BALANCED, '', false, '', false);
      expect(filter.groups[0].hasRssi).assertFalse();
      expect(filter.hasLocalRssiGate).assertTrue();
      expect(NearLinkScanForm.modeFromIndex(99)).assertEqual(NearLinkScanMode.LOW_POWER);
    });

    it('local_uuid_filter_off_keeps_the_row', 0, () => {
      const open = NearLinkScanPolicy.matchesLocalUuid(['37BEA880'], '0609', false);
      const closed = NearLinkScanPolicy.matchesLocalUuid(['AAAA'], '0609', true);
      expect(open).assertTrue();
      expect(closed).assertFalse();
      expect(NearLinkScanPolicy.rssiSortKey(127, false)).assertEqual(-1000);
    });

    it('payload_rules_reject_bad_hex_mtu_and_write_type', 0, () => {
      expect(NearLinkPayloadRules.isEvenHex('abc')).assertFalse();
      expect(NearLinkPayloadRules.isEvenHex('0a')).assertTrue();
      expect(NearLinkPayloadRules.validateSsapMtu(21).success).assertFalse();
      expect(NearLinkPayloadRules.validateSsapMtu(256).success).assertTrue();
      expect(NearLinkPayloadRules.validatePortMtu(1, false).value).assertEqual(NearLinkConstants.PORT_MTU_DEFAULT);
      expect(NearLinkPayloadRules.writeAllowed(NearLinkConstants.OP_WRITE_NO_RESPONSE, true)).assertFalse();
      expect(NearLinkPayloadRules.canNotify(NearLinkConstants.OP_NOTIFY, false)).assertFalse();
      expect(NearLinkPayloadRules.validateAdvertisingInterval(10).success).assertFalse();
      expect(NearLinkPayloadRules.shouldRespondToWrite(1)).assertTrue();
      expect(NearLinkPayloadRules.shouldRespondToWrite(2)).assertFalse();
    });

    it('slice_waits_for_confirmation', 0, () => {
      const bytes = new Uint8Array(30);
      const blocked = NearLinkSlicePlan.plan(bytes, 22, false);
      expect(blocked.success).assertFalse();
      const allowed = NearLinkSlicePlan.plan(bytes, 22, true);
      expect(allowed.success).assertTrue();
      expect(allowed.value?.length).assertEqual(2);
    });

    it('gaps_have_no_success_path_and_reason_msg_does_not_branch', 0, () => {
      expect(NearLinkGapFacts.successPathCount()).assertEqual(0);
      expect(NearLinkGap.hasSuccessPath(NearLinkGap.UNPAIR)).assertFalse();
      expect(NearLinkReasonPolicy.affectsUiBranch('detail')).assertFalse();
      expect(NearLinkReasonPolicy.pairingCategory('remote_canceled', 'ignore-me')).assertEqual('remote_canceled');
      expect(NearLinkPairedPresentation.showEmptyAsNone(true, 0)).assertFalse();
      expect(NearLinkPairedPresentation.showEmptyAsNone(false, 0)).assertTrue();
    });

    it('export_keeps_entries_when_format_is_reused', 0, () => {
      const entry = new NearLinkLogEntry('1', 1, 'out', 'writeData', '', '', 'hidden', '0A0B', false);
      const text = NearLinkLogBook.format([entry]);
      expect(text.indexOf('writeData') >= 0).assertTrue();
      expect(text.indexOf('0A0B') >= 0).assertTrue();
      expect(text.indexOf('reasonMsg=hidden') >= 0).assertTrue();
      const kept = NearLinkLogBook.retainOnFailure([entry]);
      expect(kept.length).assertEqual(1);
    });

    it('screen_rules_name_validation_and_version_gates', 0, () => {
      expect(NearLinkScreenRules.sentenceKey(NearLinkErrorCodes.EMPTY_FILTER)).assertEqual('need_filter');
      expect(NearLinkScreenRules.sentenceKey(NearLinkErrorCodes.DURATION_RANGE)).assertEqual('duration_range');
      expect(NearLinkScreenRules.sentenceKey(NearLinkErrorCodes.MANUFACTURER_DATA_NEEDS_ID)).assertEqual('mfg_need_id');
      expect(NearLinkScreenRules.sentenceKey(NearLinkErrorCodes.ADV_INTERVAL_RANGE)).assertEqual('adv_interval');
      expect(NearLinkScreenRules.blocksApi(23, NearLinkConstants.API_REASON_MSG)).assertTrue();
      expect(NearLinkScreenRules.blocksApi(26, NearLinkConstants.API_RSSI_FILTER)).assertFalse();
      expect(NearLinkScreenRules.localNameCodeWhenOff(true)).assertEqual(`${NearLinkConstants.NATIVE_RADIO_OFF}`);
      expect(NearLinkScreenRules.localNameCodeWhenOff(false)).assertEqual('');
      expect(NearLinkScreenRules.durationElapsed(10, 10)).assertTrue();
      expect(NearLinkScreenRules.durationElapsed(9, 9)).assertFalse();
      expect(NearLinkScreenRules.readEnabled(NearLinkConstants.OP_WRITE_NO_RESPONSE)).assertFalse();
      expect(NearLinkScreenRules.discoverAllowed(false)).assertFalse();
      expect(NearLinkScreenRules.portIsConnected(1)).assertTrue();
      expect(NearLinkScreenRules.portIsConnected(3)).assertFalse();
      expect(NearLinkScreenRules.rejectBluetoothMtu('2900099')).assertEqual(`${NearLinkConstants.NATIVE_OPERATION_FAILED}`);
      expect(NearLinkScreenRules.addressDiffers('aa', 'bb')).assertTrue();
      expect(NearLinkScreenRules.gapHasSuccess(NearLinkGap.AIR)).assertFalse();
      expect(NearLinkScreenRules.notifyLine(true, false, false)).assertEqual('not_enabled');
      expect(NearLinkScreenRules.notifyLine(false, false, true)).assertEqual('reenable');
      const missingId = new NearLinkScanFilter([new NearLinkSystemFilter('', '', -1, 'aa')]);
      expect(missingId.validate().error?.code).assertEqual(NearLinkErrorCodes.MANUFACTURER_DATA_NEEDS_ID);
      const grouped = NearLinkScanForm.toFilter('AA', '', '', '', '', '', false,
        NearLinkScanMode.LOW_POWER, '10', false, '', false, 'BB', 'NameB');
      expect(grouped.groups.length).assertEqual(2);
      expect(grouped.groups[0].address).assertEqual('AA');
      expect(grouped.groups[1].deviceName).assertEqual('NameB');
      expect(NearLinkPayloadRules.validateAdvertisingInterval(10).error?.code).assertEqual(NearLinkErrorCodes.ADV_INTERVAL_RANGE);
    });
  });
}
