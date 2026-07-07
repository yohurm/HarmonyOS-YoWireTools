export class NearLinkNavRoutes {
  static readonly OVERVIEW: string = 'nearlink/overview';
  static readonly SCAN: string = 'nearlink/scan';
  static readonly DEVICE_DETAIL: string = 'nearlink/device_detail';
  static readonly SSAP_CLIENT: string = 'nearlink/ssap_client';
  static readonly DATA_TRANSFER: string = 'nearlink/data_transfer';
  static readonly MODULE_SETTINGS: string = 'nearlink/module_settings';
}

export class NearLinkNavParams {
  readonly deviceId: string;
  readonly displayName: string;
  readonly sessionId: string;

  constructor(deviceId: string = '', displayName: string = '', sessionId: string = '') {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.sessionId = sessionId;
  }
}
