export class WifiNavRoutes {
  static readonly OVERVIEW: string = 'wifi/overview';
  static readonly SCAN: string = 'wifi/scan';
  static readonly DIAGNOSTICS: string = 'wifi/diagnostics';
  static readonly SOCKET: string = 'wifi/socket';
  static readonly HTTP: string = 'wifi/http';
  static readonly WEBSOCKET: string = 'wifi/websocket';
  static readonly MQTT: string = 'wifi/mqtt';
  static readonly LAN: string = 'wifi/lan';
  static readonly MODULE_SETTINGS: string = 'wifi/module_settings';
}

export class WifiNavParams {
  readonly host: string;
  readonly port: number;

  constructor(host: string = '', port: number = 0) {
    this.host = host;
    this.port = port;
  }
}
