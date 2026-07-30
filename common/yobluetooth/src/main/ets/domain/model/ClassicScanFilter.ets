/**
 * Classic Bluetooth (BR/EDR) Inquiry 列表过滤器（architecture bluetooth/01 §8）。
 * 不属于 SPP 协议过滤；SPP 页扫描段复用本过滤器。
 *
 * Platform startBluetoothDiscovery() 无 includeBonded/includeConnected 参数（HarmonyOS FAQ）。
 * 「已连接」与「仅已配对未连接」由应用层 includeConnectedPaired + KeepAliveCollector 区分。
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
  static readonly RSSI_SLIDER_MIN: number = -100;
  static readonly RSSI_SLIDER_MAX: number = -40;
  static readonly RSSI_DEFAULT: number = ClassicScanFilter.RSSI_SLIDER_MIN;

  readonly nameQuery: string;
  readonly addressQuery: string;
  readonly minRssi: number;
  readonly majorFilter: ClassicDeviceMajorFilter;
  readonly pairedOnly: boolean;
  readonly favoritesOnly: boolean;
  /**
   * 为 true 时，扫描列表额外保活「已连接的已配对」设备（SPP ledger CONNECTED /
   * session RUNNING 等），即使本轮无 Inquiry 广播。
   * 不为 true 时不会倾倒全部静默已配对（仅配对、未连接）设备。
   */
  readonly includeConnectedPaired: boolean;

  constructor(
    nameQuery: string = '',
    addressQuery: string = '',
    minRssi: number = ClassicScanFilter.RSSI_DEFAULT,
    majorFilter: ClassicDeviceMajorFilter = ClassicDeviceMajorFilter.ALL,
    pairedOnly: boolean = false,
    favoritesOnly: boolean = false,
    includeConnectedPaired: boolean = true
  ) {
    this.nameQuery = nameQuery;
    this.addressQuery = addressQuery;
    this.minRssi = minRssi;
    this.majorFilter = majorFilter;
    this.pairedOnly = pairedOnly;
    this.favoritesOnly = favoritesOnly;
    this.includeConnectedPaired = includeConnectedPaired;
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
      this.favoritesOnly ||
      !this.includeConnectedPaired;
  }

  withName(nameQuery: string): ClassicScanFilter {
    return new ClassicScanFilter(
      nameQuery, this.addressQuery, this.minRssi, this.majorFilter,
      this.pairedOnly, this.favoritesOnly, this.includeConnectedPaired
    );
  }

  withAddress(addressQuery: string): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery, addressQuery, this.minRssi, this.majorFilter,
      this.pairedOnly, this.favoritesOnly, this.includeConnectedPaired
    );
  }

  withMinRssi(minRssi: number): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery, this.addressQuery, minRssi, this.majorFilter,
      this.pairedOnly, this.favoritesOnly, this.includeConnectedPaired
    );
  }

  withMajorFilter(majorFilter: ClassicDeviceMajorFilter): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery, this.addressQuery, this.minRssi, majorFilter,
      this.pairedOnly, this.favoritesOnly, this.includeConnectedPaired
    );
  }

  withIncludeConnectedPaired(includeConnectedPaired: boolean): ClassicScanFilter {
    return new ClassicScanFilter(
      this.nameQuery, this.addressQuery, this.minRssi, this.majorFilter,
      this.pairedOnly, this.favoritesOnly, includeConnectedPaired
    );
  }
}
