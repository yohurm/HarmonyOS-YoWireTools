/**
 * Classic Bluetooth (BR/EDR) Inquiry 列表过滤器（architecture bluetooth/01 §8）。
 * 不属于 SPP 协议过滤；SPP 页扫描段复用本过滤器。
 * RSSI slider range aligns with common BT tools: -100 (all) … -40 (nearby).
 */
export enum ClassicDeviceMajorFilter {
  ALL = 0,
  COMPUTER = 0x0100,
  PHONE = 0x0200,
  AUDIO_VIDEO = 0x0400,
  PERIPHERAL = 0x0500,
  IMAGING = 0x0600,
  WEARABLE = 0x0700,
  HEALTH = 0x0900,
  /** Uncategorized / misc major classes. */
  OTHER = -1
}

export class ClassicScanFilter {
  /** Weakest allowed threshold on the slider (effectively off). */
  static readonly RSSI_SLIDER_MIN: number = -100;
  /** Strongest "nearby only" threshold (competitive apps often cap near -40). */
  static readonly RSSI_SLIDER_MAX: number = -40;
  static readonly RSSI_DEFAULT: number = ClassicScanFilter.RSSI_SLIDER_MIN;

  readonly nameQuery: string;
  readonly addressQuery: string;
  readonly minRssi: number;
  readonly majorFilter: ClassicDeviceMajorFilter;
  readonly pairedOnly: boolean;
  readonly favoritesOnly: boolean;

  constructor(
    nameQuery: string = '',
    addressQuery: string = '',
    minRssi: number = ClassicScanFilter.RSSI_DEFAULT,
    majorFilter: ClassicDeviceMajorFilter = ClassicDeviceMajorFilter.ALL,
    pairedOnly: boolean = false,
    favoritesOnly: boolean = false
  ) {
    this.nameQuery = nameQuery;
    this.addressQuery = addressQuery;
    this.minRssi = minRssi;
    this.majorFilter = majorFilter;
    this.pairedOnly = pairedOnly;
    this.favoritesOnly = favoritesOnly;
  }

  static empty(): ClassicScanFilter {
    return new ClassicScanFilter();
  }

  hasActiveConstraints(): boolean {
    return this.nameQuery.trim().length > 0 ||
      this.addressQuery.trim().length > 0 ||
      this.minRssi > ClassicScanFilter.RSSI_SLIDER_MIN ||
      this.majorFilter !== ClassicDeviceMajorFilter.ALL ||
      this.pairedOnly ||
      this.favoritesOnly;
  }

  withName(nameQuery: string): ClassicScanFilter {
    return new ClassicScanFilter(
      nameQuery,
      this.addressQuery,
      this.minRssi,
      this.majorFilter,
      this.pairedOnly,
      this.favoritesOnly
    );
  }

  withAddress(addressQuery: string): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery,
      addressQuery,
      this.minRssi,
      this.majorFilter,
      this.pairedOnly,
      this.favoritesOnly
    );
  }

  withMinRssi(minRssi: number): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery,
      this.addressQuery,
      minRssi,
      this.majorFilter,
      this.pairedOnly,
      this.favoritesOnly
    );
  }

  withMajorFilter(majorFilter: ClassicDeviceMajorFilter): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery,
      this.addressQuery,
      this.minRssi,
      majorFilter,
      this.pairedOnly,
      this.favoritesOnly
    );
  }
}
