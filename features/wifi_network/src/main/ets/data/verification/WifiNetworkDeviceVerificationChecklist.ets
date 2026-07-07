export class WifiVerificationItem {
  readonly id: string;
  readonly title: string;
  readonly description: string;

  constructor(id: string, title: string, description: string) {
    this.id = id;
    this.title = title;
    this.description = description;
  }
}

/**
 * Architecture 03-§16 device verification checklist as executable catalog.
 */
export class WifiNetworkDeviceVerificationChecklist {
  static listAll(): WifiVerificationItem[] {
    return [
      new WifiVerificationItem('wifi-v-01', 'WiFi permission flow', 'Grant/deny GET_WIFI_INFO and restore from settings'),
      new WifiVerificationItem('wifi-v-02', 'Linked info', 'Read current WiFi connection after permission grant'),
      new WifiVerificationItem('wifi-v-03', 'BSSID masking', 'BSSID masked without GET_WIFI_PEERS_MAC'),
      new WifiVerificationItem('wifi-v-04', 'Scan cache', 'Load system scan cache results'),
      new WifiVerificationItem('wifi-v-05', 'Active scan', 'Trigger startScan when API available'),
      new WifiVerificationItem('wifi-v-06', 'Scan cooldown', 'Respect foreground rate limit countdown'),
      new WifiVerificationItem('wifi-v-07', 'TCP client', 'Connect and exchange with local server'),
      new WifiVerificationItem('wifi-v-08', 'UDP terminal', 'Bind and send/receive datagrams'),
      new WifiVerificationItem('wifi-v-09', 'HTTP request', 'GET/POST with destroy in finally'),
      new WifiVerificationItem('wifi-v-10', 'WebSocket open', 'Wait for open event before send'),
      new WifiVerificationItem('wifi-v-11', 'LAN scan cancel', 'Cancel host discovery mid-run'),
      new WifiVerificationItem('wifi-v-12', 'Port scan limit', 'Concurrent port scan with cancellation'),
      new WifiVerificationItem('wifi-v-13', 'Network diagnostics', 'Run DNS/TCP/HTTP probe pipeline'),
      new WifiVerificationItem('wifi-v-14', 'Background reconcile', 'Socket state after foreground resume'),
      new WifiVerificationItem('wifi-v-15', 'TCP server clients', 'Accept/send/disconnect multiple TCP clients'),
      new WifiVerificationItem('wifi-v-16', 'mDNS/SSDP discovery', 'Discover and save network services'),
      new WifiVerificationItem('wifi-v-17', 'HTTP template/export', 'Save template and export exchange JSON')
    ];
  }
}
