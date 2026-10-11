export enum NearLinkDestination {
  ROOT = 'root',
  SCAN = 'scan',
  DETAIL = 'detail',
  ADVERTISING = 'advertising',
  SSAP_CLIENT = 'ssap_client',
  SSAP_SERVER = 'ssap_server',
  PORT = 'port',
  PAIRING = 'pairing',
  LOG = 'log',
  CDSM = 'cdsm'
}

export enum NearLinkSupportCategory {
  LOADING = 'loading',
  SUPPORTED = 'supported',
  UNSUPPORTED = 'unsupported',
  VERSION = 'version_unavailable',
  CAPABILITY = 'capability_unsupported',
  EMULATOR = 'emulator'
}

export enum NearLinkRadioCategory {
  UNKNOWN = 'unknown',
  ON = 'on',
  OFF = 'off',
  TURNING_ON = 'turning_on',
  TURNING_OFF = 'turning_off'
}

export enum NearLinkScanUiPhase {
  IDLE = 'idle',
  SCANNING = 'scanning',
  STOPPED = 'stopped',
  FAILED = 'failed'
}

export class NearLinkGap {
  static readonly SCAN_SERVICE_UUID: string = 'scan_service_uuid';
  static readonly UNPAIR: string = 'unpair';
  static readonly PHY: string = 'phy_interval_peer_rssi';
  static readonly AIR: string = 'air_capture';
  static readonly CDSM: string = 'cdsm';

  static hasSuccessPath(_gapId: string): boolean {
    return false;
  }
}
