/**
 * Preferences keys per architecture 05-§6.2.
 */
export class PreferenceKeys {
  static readonly APP_MODE: string = 'app.mode';
  static readonly THEME_MODE: string = 'app.themeMode';
  static readonly LOG_DEFAULT_DISPLAY: string = 'log.defaultDisplay';
  static readonly LOG_RETENTION_DAYS: string = 'log.retentionDays';
  static readonly LOG_MAX_SIZE_MB: string = 'log.maxSizeMb';
  static readonly COMMAND_DEFAULT_LINE_ENDING: string = 'command.defaultLineEnding';
  static readonly BACKGROUND_ALLOW_CONNECTION: string = 'background.allowConnection';
  static readonly BACKGROUND_ALLOW_REPEAT_COMMAND: string = 'background.allowRepeatCommand';
  static readonly PRIVACY_EXPORT_MASK_ADDRESS: string = 'privacy.exportMaskAddress';
  static readonly PRIVACY_EXPORT_MASK_HEADERS: string = 'privacy.exportMaskHeaders';
  static readonly WIFI_SCAN_COOLDOWN_MS: string = 'wifi.scanCooldownMs';
  static readonly BLUETOOTH_AUTO_STOP_DISCOVERY: string = 'bluetooth.autoStopDiscoveryBeforeConnect';
  static readonly BLUETOOTH_RECENT_CONNECTIONS: string = 'bluetooth.recentConnections';
  /** SPP 自定义 UUID 收藏列表（行协议，见 SppUuidFavoriteEntry）。 */
  static readonly BLUETOOTH_SPP_UUID_FAVORITES: string = 'bluetooth.spp.uuidFavorites';
  static readonly NEARLINK_REQUIRE_FILTER: string = 'nearlink.requireFilterForScan';
}
