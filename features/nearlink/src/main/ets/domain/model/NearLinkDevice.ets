import { ModuleType, ProtocolType } from 'debug_core';
import { NearLinkScanPhase } from './NearLinkScanPhase';

export class NearLinkDevice {
  readonly randomAddress: string;
  readonly displayName: string;
  readonly alias: string;
  readonly rssi: number;
  readonly rssiValid: boolean;
  readonly connectable: boolean;
  readonly favorite: boolean;
  readonly lastSeenMs: number;
  readonly firstSeenMs: number;
  readonly serviceUuids: string[];
  readonly rawHex: string;
  readonly seenCount: number;
  readonly deviceClass: string;
  readonly belowLocalRssiGate: boolean;

  constructor(
    randomAddress: string,
    displayName: string,
    rssi: number = 0,
    rssiValid: boolean = true,
    connectable: boolean = true,
    favorite: boolean = false,
    lastSeenMs: number = Date.now(),
    firstSeenMs: number = lastSeenMs,
    serviceUuids: string[] = [],
    alias: string = '',
    rawHex: string = '',
    seenCount: number = 1,
    deviceClass: string = '',
    belowLocalRssiGate: boolean = false
  ) {
    this.randomAddress = randomAddress;
    this.displayName = displayName;
    this.alias = alias;
    this.rssi = rssi;
    this.rssiValid = rssiValid;
    this.connectable = connectable;
    this.favorite = favorite;
    this.lastSeenMs = lastSeenMs;
    this.firstSeenMs = firstSeenMs;
    this.serviceUuids = serviceUuids;
    this.rawHex = rawHex;
    this.seenCount = seenCount;
    this.deviceClass = deviceClass;
    this.belowLocalRssiGate = belowLocalRssiGate;
  }

  get effectiveName(): string {
    return this.alias.length > 0 ? this.alias : this.displayName;
  }

  withSeen(rssi: number, rssiValid: boolean, lastSeenMs: number): NearLinkDevice {
    return new NearLinkDevice(
      this.randomAddress,
      this.displayName,
      rssi,
      rssiValid,
      this.connectable,
      this.favorite,
      lastSeenMs,
      this.firstSeenMs,
      this.serviceUuids,
      this.alias,
      this.rawHex,
      this.seenCount + 1,
      this.deviceClass,
      this.belowLocalRssiGate
    );
  }

  withFavorite(favorite: boolean, alias: string = this.alias): NearLinkDevice {
    return new NearLinkDevice(
      this.randomAddress,
      this.displayName,
      this.rssi,
      this.rssiValid,
      this.connectable,
      favorite,
      this.lastSeenMs,
      this.firstSeenMs,
      this.serviceUuids,
      alias,
      this.rawHex,
      this.seenCount,
      this.deviceClass,
      this.belowLocalRssiGate
    );
  }
}

export class NearLinkAdapterSnapshot {
  readonly supported: boolean;
  readonly enabled: boolean;
  readonly stateCode: number;
  readonly label: string;

  constructor(supported: boolean, enabled: boolean, stateCode: number, label: string) {
    this.supported = supported;
    this.enabled = enabled;
    this.stateCode = stateCode;
    this.label = label;
  }
}

export class NearLinkCapabilitySnapshot {
  readonly permissionGranted: boolean;
  readonly supported: boolean;
  readonly switchOn: boolean;
  readonly readyForScan: boolean;
  readonly readyForConnect: boolean;
  readonly simulatorNote: string;

  constructor(
    permissionGranted: boolean,
    supported: boolean,
    switchOn: boolean,
    readyForScan: boolean = false,
    readyForConnect: boolean = false,
    simulatorNote: string = 'NearLink requires a real device; emulator is not supported'
  ) {
    this.permissionGranted = permissionGranted;
    this.supported = supported;
    this.switchOn = switchOn;
    this.readyForScan = readyForScan;
    this.readyForConnect = readyForConnect;
    this.simulatorNote = simulatorNote;
  }
}

export class NearLinkOverviewSnapshot {
  readonly adapter: NearLinkAdapterSnapshot;
  readonly permissionGranted: boolean;
  readonly scanPhase: NearLinkScanPhase;
  readonly deviceCount: number;
  readonly favoriteCount: number;
  readonly activeSessionCount: number;
  readonly warnings: string[];

  constructor(
    adapter: NearLinkAdapterSnapshot,
    permissionGranted: boolean,
    scanPhase: NearLinkScanPhase,
    deviceCount: number,
    favoriteCount: number,
    activeSessionCount: number,
    warnings: string[] = []
  ) {
    this.adapter = adapter;
    this.permissionGranted = permissionGranted;
    this.scanPhase = scanPhase;
    this.deviceCount = deviceCount;
    this.favoriteCount = favoriteCount;
    this.activeSessionCount = activeSessionCount;
    this.warnings = warnings;
  }
}

export class NearLinkTargetAttributes {
  static moduleType(): ModuleType {
    return ModuleType.NEARLINK;
  }

  static scanProtocol(): ProtocolType {
    return ProtocolType.NEARLINK_SCAN;
  }

  static ssapProtocol(): ProtocolType {
    return ProtocolType.SSAP;
  }

  static dataTransferProtocol(): ProtocolType {
    return ProtocolType.DATA_TRANSFER;
  }
}
