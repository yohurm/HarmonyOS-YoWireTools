import { YoErrorStateModel } from 'youi_kit';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';

export class WifiOverviewCopy {
  static scanError(code: string): YoErrorStateModel {
    if (code === WifiNetworkErrorCodes.SCAN_COOLDOWN) {
      return YoErrorStateModel.fromLayers(
        $r('app.string.wifi_error_scan_cooldown_title'),
        $r('app.string.wifi_error_scan_cooldown_cause'),
        $r('app.string.wifi_error_scan_cooldown_next'),
        true,
        code
      );
    }
    if (code === WifiNetworkErrorCodes.SCAN_LIMITED) {
      return YoErrorStateModel.fromLayers(
        $r('app.string.wifi_error_scan_limited_title'),
        $r('app.string.wifi_error_scan_limited_cause'),
        $r('app.string.wifi_error_scan_limited_next'),
        true,
        code
      );
    }
    return YoErrorStateModel.fromLayers(
      $r('app.string.wifi_error_scan_failed_title'),
      $r('app.string.wifi_error_scan_failed_cause'),
      $r('app.string.wifi_error_scan_failed_next'),
      true,
      code
    );
  }
}
