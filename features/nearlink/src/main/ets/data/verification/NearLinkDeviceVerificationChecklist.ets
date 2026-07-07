export class NearLinkVerificationItem {
  readonly id: string;
  readonly title: string;
  readonly description: string;

  constructor(id: string, title: string, description: string) {
    this.id = id;
    this.title = title;
    this.description = description;
  }
}

export class NearLinkDeviceVerificationChecklist {
  static listAll(): NearLinkVerificationItem[] {
    return [
      new NearLinkVerificationItem('nl-v-01', 'Support detection', 'Unsupported/supported device states'),
      new NearLinkVerificationItem('nl-v-02', 'Switch state', 'NearLink off/on and stateChange callback'),
      new NearLinkVerificationItem('nl-v-03', 'Permission flow', 'Grant/deny ACCESS_NEARLINK'),
      new NearLinkVerificationItem('nl-v-04', 'Scan filters', 'API 13+ requires non-empty filters'),
      new NearLinkVerificationItem('nl-v-05', 'Random address', 'Scan results use random address'),
      new NearLinkVerificationItem('nl-v-06', 'RSSI 127', 'Invalid RSSI displayed correctly'),
      new NearLinkVerificationItem('nl-v-07', 'Adv TLV parse', 'Raw data and parsed fields'),
      new NearLinkVerificationItem('nl-v-08', 'SSAP client', 'Connect, discover, read/write/notify, MTU'),
      new NearLinkVerificationItem('nl-v-09', 'dataTransfer', 'createPort/connect/write/read/destroy'),
      new NearLinkVerificationItem('nl-v-10', 'Congestion', '1009700023 backoff handling'),
      new NearLinkVerificationItem('nl-v-11', 'Pairing encryption', 'ACB ENCRYPTED before showing encrypted'),
      new NearLinkVerificationItem('nl-v-12', 'Favorites', 'Favorite random-address devices with alias')
    ];
  }
}
