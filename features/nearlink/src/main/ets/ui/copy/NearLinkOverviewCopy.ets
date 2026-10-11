import { YoErrorStateModel } from 'youi_kit';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';

export class NearLinkOverviewCopy {
  static scanError(code: string): YoErrorStateModel {
    if (code === NearLinkErrorCodes.EMPTY_FILTER) {
      return YoErrorStateModel.fromLayers(
        $r('app.string.nl_error_filter_title'),
        $r('app.string.nl_error_filter_cause'),
        $r('app.string.nl_error_filter_next'),
        true,
        code
      );
    }
    if (code === NearLinkErrorCodes.OPERATION_BUSY) {
      return YoErrorStateModel.fromLayers(
        $r('app.string.nl_error_busy_title'),
        $r('app.string.nl_error_busy_cause'),
        $r('app.string.nl_error_busy_next'),
        false,
        code
      );
    }
    if (code === NearLinkErrorCodes.SWITCH_OFF) {
      return YoErrorStateModel.fromLayers(
        $r('app.string.nl_error_switch_title'),
        $r('app.string.nl_error_switch_cause'),
        $r('app.string.nl_error_switch_next'),
        false,
        code
      );
    }
    if (code === NearLinkErrorCodes.UNSUPPORTED) {
      return YoErrorStateModel.fromLayers(
        $r('app.string.nl_error_unsupported_title'),
        $r('app.string.nl_error_unsupported_cause'),
        $r('app.string.nl_error_unsupported_next'),
        false,
        code
      );
    }
    return YoErrorStateModel.fromLayers(
      $r('app.string.nl_error_scan_title'),
      $r('app.string.nl_error_scan_cause'),
      $r('app.string.nl_error_scan_next'),
      true,
      code
    );
  }
}
