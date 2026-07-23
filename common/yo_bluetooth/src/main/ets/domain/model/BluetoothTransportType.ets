/**
 * Transport type, list rail and address privacy per architecture bluetooth/00.
 */

export enum BluetoothTransportType {
  BR_EDR = 'brEdr',
  LE = 'le',
  DUAL = 'dual',
  UNKNOWN = 'unknown'
}

export enum BluetoothListRail {
  CLASSIC_SCAN = 'classicScan',
  BLE_SCAN = 'bleScan'
}

export enum AddressPrivacyKind {
  VIRTUAL = 'virtual',
  REAL = 'real',
  UNKNOWN = 'unknown'
}

export enum BluetoothRawAddrKind {
  PUBLIC = 'public',
  RANDOM = 'random',
  UNKNOWN = 'unknown'
}

/**
 * Classic / SPP list admission and BLE list admission.
 */
export class BluetoothTransportPolicy {
  static isClassicCandidate(transport: BluetoothTransportType): boolean {
    return transport === BluetoothTransportType.BR_EDR ||
      transport === BluetoothTransportType.DUAL;
  }

  static isBleCandidate(transport: BluetoothTransportType): boolean {
    return transport === BluetoothTransportType.LE ||
      transport === BluetoothTransportType.DUAL;
  }

  /**
   * Inquiry-sourced UNKNOWN may temporarily enter classic rail.
   * Paired LE-only must never enter.
   */
  static admitClassicPaired(transport: BluetoothTransportType): boolean {
    return BluetoothTransportPolicy.isClassicCandidate(transport);
  }

  static admitClassicDiscovery(
    transport: BluetoothTransportType,
    fromClassicInquiry: boolean
  ): boolean {
    if (transport === BluetoothTransportType.LE) {
      return false;
    }
    if (BluetoothTransportPolicy.isClassicCandidate(transport)) {
      return true;
    }
    return fromClassicInquiry && transport === BluetoothTransportType.UNKNOWN;
  }

  static fromPlatformCode(code: number): BluetoothTransportType {
    if (code === 0) {
      return BluetoothTransportType.BR_EDR;
    }
    if (code === 1) {
      return BluetoothTransportType.LE;
    }
    if (code === 2) {
      return BluetoothTransportType.DUAL;
    }
    return BluetoothTransportType.UNKNOWN;
  }

  /**
   * Typical BR/EDR profile UUID short forms from getRemoteProfileUuids.
   * Used only as UNKNOWN paired fallback (architecture bluetooth/00 §5.1).
   */
  static hasClassicProfileHint(uuids: string[]): boolean {
    for (let i = 0; i < uuids.length; i++) {
      const uuid = uuids[i].toLowerCase();
      if (uuid.indexOf('1101') >= 0 || // SPP
        uuid.indexOf('110a') >= 0 || // A2DP Source
        uuid.indexOf('110b') >= 0 || // A2DP Sink
        uuid.indexOf('111e') >= 0 || // HFP HF
        uuid.indexOf('111f') >= 0 || // HFP AG
        uuid.indexOf('1124') >= 0) { // HID
        return true;
      }
    }
    return false;
  }
}
