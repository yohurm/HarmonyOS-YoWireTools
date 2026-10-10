import { WifiAccessPointSnapshot } from './WifiAccessPointSnapshot';
import { WifiScanSource } from './WifiScanState';

export class WifiFeatureFact {
  readonly name: string;
  readonly supported: boolean;
  readonly nativeCode: string;

  constructor(name: string, supported: boolean, nativeCode: string = '') {
    this.name = name;
    this.supported = supported;
    this.nativeCode = nativeCode;
  }
}

export class WifiIpv4Facts {
  readonly address: string;
  readonly gateway: string;
  readonly netmask: string;
  readonly primaryDns: string;
  readonly secondDns: string;
  readonly dhcpServer: string;
  readonly leaseSeconds: string;

  constructor(
    address: string,
    gateway: string,
    netmask: string,
    primaryDns: string,
    secondDns: string,
    dhcpServer: string,
    leaseSeconds: string
  ) {
    this.address = address;
    this.gateway = gateway;
    this.netmask = netmask;
    this.primaryDns = primaryDns;
    this.secondDns = secondDns;
    this.dhcpServer = dhcpServer;
    this.leaseSeconds = leaseSeconds;
  }
}

export class WifiIpv6Facts {
  readonly linkAddress: string;
  readonly globalAddress: string;
  readonly gateway: string;
  readonly dns: string;
  readonly randomGlobal: string;

  constructor(linkAddress: string, globalAddress: string, gateway: string, dns: string, randomGlobal: string) {
    this.linkAddress = linkAddress;
    this.globalAddress = globalAddress;
    this.gateway = gateway;
    this.dns = dns;
    this.randomGlobal = randomGlobal;
  }
}

export class WifiScanBatch {
  readonly rows: WifiAccessPointSnapshot[];
  readonly readAtMs: number;
  readonly source: WifiScanSource;
  readonly scanState: number;

  constructor(rows: WifiAccessPointSnapshot[], readAtMs: number, source: WifiScanSource, scanState: number) {
    this.rows = rows;
    this.readAtMs = readAtMs;
    this.source = source;
    this.scanState = scanState;
  }
}

export class WifiCandidateDraft {
  readonly ssid: string;
  readonly key: string;
  readonly security: string;
  readonly hidden: boolean;
  readonly eapIdentity: string;
  readonly eapPassword: string;
  readonly useUserAction: boolean;
  readonly networkId: number;

  constructor(
    ssid: string,
    key: string,
    security: string,
    hidden: boolean,
    eapIdentity: string,
    eapPassword: string,
    useUserAction: boolean,
    networkId: number = -1
  ) {
    this.ssid = ssid;
    this.key = key;
    this.security = security;
    this.hidden = hidden;
    this.eapIdentity = eapIdentity;
    this.eapPassword = eapPassword;
    this.useUserAction = useUserAction;
    this.networkId = networkId;
  }
}

export class WifiChannelOccupancyRow {
  readonly channel: number;
  readonly apCount: number;
  readonly strongestRssi: number;
  readonly intensity: number;

  constructor(channel: number, apCount: number, strongestRssi: number, intensity: number) {
    this.channel = channel;
    this.apCount = apCount;
    this.strongestRssi = strongestRssi;
    this.intensity = intensity;
  }
}
