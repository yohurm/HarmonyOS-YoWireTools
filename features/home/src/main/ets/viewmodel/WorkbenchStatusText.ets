import { RadioSwitchReading } from 'debug_core';
import { YoResourceUtil, YoStatusPillTone } from 'youi_kit';

/** Turns a switch reading into the capsule sentence. Unread is never shown as off. */
export class WorkbenchStatusText {
  static label(moduleName: ResourceStr, reading: string): string {
    const name = YoResourceUtil.resolveText(moduleName);
    const status = YoResourceUtil.resolveText(WorkbenchStatusText.statusResource(reading));
    if (name.length === 0) {
      return status;
    }
    return `${name} ${status}`;
  }

  static tone(reading: string): YoStatusPillTone {
    if (reading === RadioSwitchReading.ON) {
      return 'success';
    }
    if (reading === RadioSwitchReading.OFF) {
      return 'warning';
    }
    if (reading === RadioSwitchReading.DENIED) {
      return 'error';
    }
    return 'neutral';
  }

  private static statusResource(reading: string): Resource {
    if (reading === RadioSwitchReading.ON) {
      return $r('app.string.home_radio_on');
    }
    if (reading === RadioSwitchReading.OFF) {
      return $r('app.string.home_radio_off');
    }
    if (reading === RadioSwitchReading.DENIED) {
      return $r('app.string.home_radio_denied');
    }
    if (reading === RadioSwitchReading.UNSUPPORTED) {
      return $r('app.string.home_radio_unsupported');
    }
    return $r('app.string.home_radio_unread');
  }
}
