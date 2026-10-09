import { Result, ResultError } from 'common_core';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkGap, NearLinkRadioCategory, NearLinkSupportCategory } from '../model/NearLinkScreenCategory';
import { NearLinkLogEntry } from '../model/NearLinkLogEntry';
import { NearLinkPayloadRules } from './NearLinkScanPolicy';

export class NearLinkReasonPolicy {
  static pairingCategory(reasonToken: string, _reasonMsg: string): string {
    return reasonToken;
  }

  static affectsUiBranch(_reasonMsg: string): boolean {
    return false;
  }
}

export class NearLinkEntryPolicy {
  static modesEnabled(support: string, radio: string, emulator: boolean): boolean {
    return support === NearLinkSupportCategory.SUPPORTED &&
      radio === NearLinkRadioCategory.ON &&
      !emulator;
  }
}

export class NearLinkPairedPresentation {
  static showEmptyAsNone(versionUnavailable: boolean, count: number): boolean {
    return !versionUnavailable && count === 0;
  }
}

export class NearLinkSlicePlan {
  static plan(bytes: Uint8Array, mtu: number, confirmed: boolean): Result<Uint8Array[]> {
    if (!NearLinkPayloadRules.exceedsMtu(bytes.length, mtu)) {
      const single: Uint8Array[] = [bytes];
      return Result.ok(single);
    }
    if (!confirmed) {
      return Result.fail(new ResultError(NearLinkErrorCodes.VALIDATION, 'api=writeProperty;slice=required'));
    }
    const chunks: Uint8Array[] = [];
    const size = mtu > 0 ? mtu : NearLinkConstants.DEFAULT_MTU;
    for (let offset = 0; offset < bytes.length; offset += size) {
      const end = offset + size < bytes.length ? offset + size : bytes.length;
      chunks.push(bytes.subarray(offset, end));
    }
    return Result.ok(chunks);
  }
}

export class NearLinkLogBook {
  static format(entries: NearLinkLogEntry[]): string {
    const lines: string[] = [];
    for (let i = 0; i < entries.length; i++) {
      const entry = entries[i];
      lines.push(
        `${entry.timeMs} ${entry.direction} api=${entry.apiName} code=${entry.nativeCode} hex=${entry.hex} ${entry.summary}`
      );
      if (entry.reasonMsg.length > 0) {
        lines.push(`reasonMsg=${entry.reasonMsg}`);
      }
    }
    return lines.join('\n');
  }

  static retainOnFailure(entries: NearLinkLogEntry[]): NearLinkLogEntry[] {
    return entries;
  }
}

export class NearLinkGapFacts {
  static successPathCount(): number {
    const ids: string[] = [
      NearLinkGap.SCAN_SERVICE_UUID,
      NearLinkGap.UNPAIR,
      NearLinkGap.PHY,
      NearLinkGap.AIR,
      NearLinkGap.CDSM
    ];
    let count = 0;
    for (let i = 0; i < ids.length; i++) {
      if (NearLinkGap.hasSuccessPath(ids[i])) {
        count++;
      }
    }
    return count;
  }
}
