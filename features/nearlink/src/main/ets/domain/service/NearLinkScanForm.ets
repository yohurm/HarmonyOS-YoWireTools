import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkScanFilter, NearLinkScanMode, NearLinkSystemFilter } from '../model/NearLinkScanFilter';

export class NearLinkScanForm {
  static toFilter(
    address: string,
    deviceName: string,
    manufacturerIdText: string,
    manufacturerDataHex: string,
    manufacturerMaskHex: string,
    rssiText: string,
    systemRssi: boolean,
    mode: NearLinkScanMode,
    durationText: string,
    scanAll: boolean,
    localUuid: string,
    localUuidEnabled: boolean,
    addressB: string = '',
    nameB: string = ''
  ): NearLinkScanFilter {
    const manufacturerId = NearLinkScanForm.readManufacturerId(manufacturerIdText);
    const rssi = NearLinkScanForm.readNumber(rssiText);
    const hasRssi = rssiText.trim().length > 0;
    const group = new NearLinkSystemFilter(
      address.trim(),
      deviceName.trim(),
      manufacturerId,
      manufacturerDataHex.trim(),
      manufacturerMaskHex.trim(),
      systemRssi && hasRssi ? rssi : 0,
      systemRssi && hasRssi
    );
    const duration = durationText.trim().length === 0 ? 0 : NearLinkScanForm.readNumber(durationText);
    const groups: NearLinkSystemFilter[] = [group];
    const secondAddress = addressB.trim();
    const secondName = nameB.trim();
    if (secondAddress.length > 0 || secondName.length > 0) {
      groups.push(new NearLinkSystemFilter(secondAddress, secondName));
    }
    return new NearLinkScanFilter(
      groups,
      mode,
      duration,
      scanAll,
      localUuid.trim(),
      localUuidEnabled && localUuid.trim().length > 0,
      !systemRssi && hasRssi ? rssi : 0,
      !systemRssi && hasRssi
    );
  }

  static modeFromIndex(index: number): NearLinkScanMode {
    return index === 1 ? NearLinkScanMode.BALANCED : NearLinkScanMode.LOW_POWER;
  }

  private static readManufacturerId(text: string): number {
    if (text.trim().length === 0) {
      return -1;
    }
    const parsed = parseInt(text.trim(), 10);
    if (Number.isNaN(parsed)) {
      return NearLinkConstants.MANUFACTURER_ID_MAX + 1;
    }
    return parsed;
  }

  private static readNumber(text: string): number {
    const parsed = parseInt(text.trim(), 10);
    if (Number.isNaN(parsed)) {
      return -1;
    }
    return parsed;
  }
}
