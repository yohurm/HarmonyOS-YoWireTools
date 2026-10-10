/**
 * Settings read model. Theme comes from app_setting. Other keys come from preferences.
 */
export class SettingsSnapshot {
  readonly themeMode: string;
  readonly appMode: string;
  readonly logRetentionDays: number;
  readonly logMaxSizeMb: number;
  readonly logDefaultDisplay: string;
  readonly allowBackgroundConnection: boolean;
  readonly allowRepeatCommand: boolean;
  readonly commandLineEnding: string;
  readonly bluetoothAutoStopDiscovery: boolean;
  readonly wifiScanCooldownMs: number;
  readonly nearlinkRequireFilter: boolean;
  readonly maskAddress: boolean;
  readonly maskHeaders: boolean;
  readonly loaded: boolean;

  constructor(
    themeMode: string,
    appMode: string,
    logRetentionDays: number,
    logMaxSizeMb: number,
    logDefaultDisplay: string,
    allowBackgroundConnection: boolean,
    allowRepeatCommand: boolean,
    commandLineEnding: string,
    bluetoothAutoStopDiscovery: boolean,
    wifiScanCooldownMs: number,
    nearlinkRequireFilter: boolean,
    maskAddress: boolean,
    maskHeaders: boolean,
    loaded: boolean
  ) {
    this.themeMode = themeMode;
    this.appMode = appMode;
    this.logRetentionDays = logRetentionDays;
    this.logMaxSizeMb = logMaxSizeMb;
    this.logDefaultDisplay = logDefaultDisplay;
    this.allowBackgroundConnection = allowBackgroundConnection;
    this.allowRepeatCommand = allowRepeatCommand;
    this.commandLineEnding = commandLineEnding;
    this.bluetoothAutoStopDiscovery = bluetoothAutoStopDiscovery;
    this.wifiScanCooldownMs = wifiScanCooldownMs;
    this.nearlinkRequireFilter = nearlinkRequireFilter;
    this.maskAddress = maskAddress;
    this.maskHeaders = maskHeaders;
    this.loaded = loaded;
  }
}
